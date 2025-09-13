`timescale 1ns/1ps

module tb_async_fifo;

// 参数定义
parameter DATA_WIDTH = 8;
parameter FIFO_DEPTH = 16;
parameter PTR_WIDTH = 4;
parameter WR_CLK_PERIOD = 10;  // 写时钟周期 10ns (100MHz)
parameter RD_CLK_PERIOD = 14;  // 读时钟周期 14ns (71.4MHz)

// 信号声明
reg                     wr_rst;
reg                     wr_clk;
reg                     wr_en;
reg  [DATA_WIDTH-1:0]   wr_data;
wire                    wr_full;
wire [PTR_WIDTH:0]      wr_cnt;

reg                     rd_rst;
reg                     rd_clk;
reg                     rd_en;
wire [DATA_WIDTH-1:0]   rd_data;
wire                    rd_empty;
wire [PTR_WIDTH:0]      rd_cnt;

// 测试控制信号
reg [DATA_WIDTH-1:0]    test_data_array [0:1023];  // 预期数据数组
integer                 queue_head, queue_tail;     // 队列头尾指针
reg [DATA_WIDTH-1:0]    expected_data;
integer                 write_count;
integer                 read_count;
integer                 error_count;
integer                 i, j;  // 循环变量

// 时钟生成
initial begin
    wr_clk = 0;
    forever #(WR_CLK_PERIOD/2) wr_clk = ~wr_clk;
end

initial begin
    rd_clk = 0;
    forever #(RD_CLK_PERIOD/2) rd_clk = ~rd_clk;
end

// 复位生成
initial begin
    wr_rst = 1;
    rd_rst = 1;
    #100;
    wr_rst = 0;
    rd_rst = 0;
    #50;
end

//=====================================
// 标准模式测试 (DATA_FLOAT_OUT = 0)
//=====================================
async_fifo #(
    .DATA_WIDTH     (DATA_WIDTH),
    .FIFO_DEPTH     (FIFO_DEPTH),
    .DATA_FLOAT_OUT (1'b0)
) u_async_fifo_std (
    .WR_RST         (wr_rst),
    .WR_CLK         (wr_clk),
    .WR_EN          (wr_en),
    .WR_DATA        (wr_data),
    .WR_FULL        (wr_full),
    .WR_CNT         (wr_cnt),
    
    .RD_RST         (rd_rst),
    .RD_CLK         (rd_clk),
    .RD_EN          (rd_en),
    .RD_DATA        (rd_data),
    .RD_EMPTY       (rd_empty),
    .RD_CNT         (rd_cnt)
);

//=====================================
// FWFT模式测试 (DATA_FLOAT_OUT = 1)
//=====================================
wire                    wr_full_fwft;
wire [PTR_WIDTH:0]      wr_cnt_fwft;
wire [DATA_WIDTH-1:0]   rd_data_fwft;
wire                    rd_empty_fwft;
wire [PTR_WIDTH:0]      rd_cnt_fwft;

async_fifo_fwft #(
    .DATA_WIDTH     (DATA_WIDTH),
    .FIFO_DEPTH     (FIFO_DEPTH),
    .DATA_FLOAT_OUT (1'b1)
) u_async_fifo_fwft (
    .WR_RST         (wr_rst),
    .WR_CLK         (wr_clk),
    .WR_EN          (wr_en),
    .WR_DATA        (wr_data),
    .WR_FULL        (wr_full_fwft),
    .WR_CNT         (wr_cnt_fwft),
    
    .RD_RST         (rd_rst),
    .RD_CLK         (rd_clk),
    .RD_EN          (rd_en),
    .RD_DATA        (rd_data_fwft),
    .RD_EMPTY       (rd_empty_fwft),
    .RD_CNT         (rd_cnt_fwft)
);

//=====================================
// 队列操作函数
//=====================================

// 数据入队
task enqueue_data;
    input [DATA_WIDTH-1:0] data;
    begin
        test_data_array[queue_tail] = data;
        // @(posedge wr_clk)
        queue_tail = queue_tail + 1;
        if(queue_tail >= 1024) queue_tail = 0;
    end
endtask

// 数据出队
task dequeue_data;
    output [DATA_WIDTH-1:0] data;
    begin
        if(queue_head != queue_tail) begin
            data = test_data_array[queue_head];
            // @(posedge rd_clk)
            queue_head = queue_head + 1;
            if(queue_head >= 1024) queue_head = 0;
        end
    end
endtask

// 检查队列是否为空
function queue_empty;
    input dummy;  // 虚拟输入
    begin
        queue_empty = (queue_head == queue_tail);
    end
endfunction

// 查看队首数据但不移除
function [DATA_WIDTH-1:0] peek_data;
    input dummy;  // 虚拟输入
    begin
        if(queue_head != queue_tail) begin
            peek_data = test_data_array[queue_head];
        end else begin
            peek_data = 8'h00;
        end
    end
endfunction

//=====================================
// 测试任务定义
//=====================================

// 写数据任务
task write_fifo;
    input [DATA_WIDTH-1:0] data;
    begin
        @(posedge wr_clk);
        wait(!wr_full) @(posedge wr_clk);  // 等待非满
        wr_en = 1;
        wr_data = data;
        enqueue_data(data);                // 记录写入数据
        @(posedge wr_clk);
        wr_en = 0;
        write_count = write_count + 1;
        $display("[%0t] Write data: 0x%02h, write_count=%0d", $time, data, write_count);
    end
endtask

// 读数据任务
task read_fifo;
    begin
        @(posedge rd_clk);
        wait(!rd_empty) @(posedge rd_clk);  // 等待非空
        #1 rd_en = 1;
        @(posedge rd_clk);
        #1 rd_en = 0;
        
        if(!queue_empty(0)) begin
            dequeue_data(expected_data);
            if(rd_data !== expected_data) begin
                $display("[%0t] ERROR: Read data mismatch! Expected: 0x%02h, Got: 0x%02h", 
                         $time, expected_data, rd_data);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] Read data: 0x%02h (Correct)", $time, rd_data);
            end
        end
        read_count = read_count + 1;
    end
endtask

// FWFT模式检查任务
task check_fwft_data;
    begin
        @(posedge rd_clk);
        if(!rd_empty_fwft && !queue_empty(0)) begin
            expected_data = peek_data(0);  // 查看队首但不移除
            if(rd_data_fwft !== expected_data) begin
                $display("[%0t] FWFT ERROR: Data mismatch! Expected: 0x%02h, Got: 0x%02h", 
                         $time, expected_data, rd_data_fwft);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] FWFT: Data ready: 0x%02h (Correct)", $time, rd_data_fwft);
            end
        end
    end
endtask

//=====================================
// 主测试流程
//=====================================
initial begin
    // 初始化
    wr_en = 0;
    rd_en = 0;
    wr_data = 0;
    write_count = 0;
    read_count = 0;
    error_count = 0;
    queue_head = 0;
    queue_tail = 0;
    
    // 等待复位释放
    wait(!wr_rst && !rd_rst);
    #100;
    
    $display("=== 开始异步FIFO测试 ===");
    
    //=====================================
    // 测试1: 基本读写功能
    //=====================================
    $display("\n--- 测试1: 基本读写功能 ---");
    
    // 写入几个数据
    write_fifo(8'hAA);
    write_fifo(8'h55);
    write_fifo(8'hCC);
    write_fifo(8'h33);
    
    #200;  // 等待一段时间
    
    // 读出数据
    read_fifo();
    read_fifo();
    read_fifo();
    read_fifo();
    
    //=====================================
    // 测试2: 满标志测试
    //=====================================
    $display("\n--- 测试2: 满标志测试 ---");
    
    // 写满FIFO
    for(i = 0; i < FIFO_DEPTH; i = i + 1) begin
        write_fifo(i);
    end
    
    // 检查满标志
    @(posedge wr_clk);
    if(!wr_full) begin
        $display("[%0t] ERROR: FIFO should be full!", $time);
        error_count = error_count + 1;
    end else begin
        $display("[%0t] FIFO full flag correct", $time);
    end
    
    // 尝试再写入（应该被阻止）
    @(posedge wr_clk);
    wr_en = 1;
    wr_data = 8'hFF;
    @(posedge wr_clk);
    wr_en = 0;
    
    //=====================================
    // 测试3: 空标志测试
    //=====================================
    $display("\n--- 测试3: 空标志测试 ---");
    
    // 读空FIFO
    for(i = 0; i < FIFO_DEPTH; i = i + 1) begin
        read_fifo();
    end
    
    // 检查空标志
    @(posedge rd_clk);
    if(!rd_empty) begin
        $display("[%0t] ERROR: FIFO should be empty!", $time);
        error_count = error_count + 1;
    end else begin
        $display("[%0t] FIFO empty flag correct", $time);
    end
    
    //=====================================
    // 测试4: FWFT模式测试
    //=====================================
    $display("\n--- 测试4: FWFT模式测试 ---");
    
    // 清空队列
    queue_head = 0;
    queue_tail = 0;
    
    // 写入一个数据到FWFT FIFO
    @(posedge wr_clk);
    wr_en = 1;
    wr_data = 8'hF0;
    enqueue_data(8'hF0);
    @(posedge wr_clk);
    wr_en = 0;
    
    // 等待数据传播
    #100;
    
    // 检查FWFT模式：数据应该立即可见，无需读使能
    check_fwft_data();
    
    // 再写入一个数据
    @(posedge wr_clk);
    wr_en = 1;
    wr_data = 8'h0F;
    enqueue_data(8'h0F);
    @(posedge wr_clk);
    wr_en = 0;
    
    #100;
    
    // FWFT模式下，数据应该仍然是第一个数据
    check_fwft_data();
    
    // 执行读操作，下一个数据应该立即出现
    @(posedge rd_clk);
    rd_en = 1;
    dequeue_data(expected_data);
    @(posedge rd_clk);
    rd_en = 0;
    
    #50;
    
    // 现在应该看到第二个数据
      @(posedge rd_clk);
    rd_en = 1;
    // dequeue_data(expected_data);
    @(posedge rd_clk);
    rd_en = 0;
    
    #50;
    
    
    //=====================================
    // 测试5: 连续读写测试
    //=====================================
    $display("\n--- 测试5: 连续读写测试 ---");
    
    // 连续写入
    for(i = 0; i < 20; i = i + 1) begin
        write_fifo(i + 8'h80);
        #50;
    end
    
    #500;  // 等待一段时间
    
    // 连续读出
    for(i = 0; i < 20; i = i + 1) begin
        read_fifo();
        #70;
    end
    
    //=====================================
    // 测试结果
    //=====================================
    // #1000;  // 等待所有操作完成
    
    $display("\n=== 测试完成 ===");
    $display("写入数据数量: %0d", write_count);
    $display("读出数据数量: %0d", read_count);
    $display("错误数量: %0d", error_count);
    
    if(error_count == 0) begin
        $display("*** 测试通过! ***");
    end else begin
        $display("*** 测试失败，发现 %0d 个错误 ***", error_count);
    end
    
    $finish;
end

//=====================================
// 监控信号
//=====================================
always @(posedge wr_clk) begin
    if(wr_en && !wr_full) begin
        $display("[%0t] STD: wr_cnt=%0d, rd_cnt=%0d", $time, wr_cnt, rd_cnt);
    end
end

always @(posedge rd_clk) begin
    if(rd_en && !rd_empty) begin
        $display("[%0t] STD: After read - wr_cnt=%0d, rd_cnt=%0d", $time, wr_cnt, rd_cnt);
    end
end

// FWFT模式监控
always @(posedge wr_clk) begin
    if(wr_en && !wr_full_fwft) begin
        $display("[%0t] FWFT: wr_cnt=%0d, rd_cnt=%0d", $time, wr_cnt_fwft, rd_cnt_fwft);
    end
end

// 生成波形文件
initial begin
    $dumpfile("tb_async_fifo.vcd");
    $dumpvars(0, tb_async_fifo);
end

endmodule
