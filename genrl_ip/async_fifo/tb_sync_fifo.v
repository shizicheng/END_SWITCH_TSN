`timescale 1ns/1ps

module tb_sync_fifo;

// 参数定义
parameter DEPTH = 8;
parameter WIDTH = 8;
parameter ALMOST_FULL_THRESHOLD = 2;
parameter ALMOST_EMPTY_THRESHOLD = 2;
parameter CLK_PERIOD = 10;  // 时钟周期 10ns (100MHz)

// 测试信号声明
reg                     clk;
reg                     rst;
reg                     wr_en;
reg  [WIDTH-1:0]        din;
wire                    full;
reg                     rd_en;
wire [WIDTH-1:0]        dout;
wire                    empty;
wire                    almost_full;
wire                    almost_empty;
wire [3:0]              data_cnt;  // log2_cnt(8) = 4

// FWFT模式测试信号
wire                    full_fwft;
wire [WIDTH-1:0]        dout_fwft;
wire                    empty_fwft;
wire                    almost_full_fwft;
wire                    almost_empty_fwft;
wire [3:0]              data_cnt_fwft;

// 测试控制变量
reg [WIDTH-1:0]         test_data_array [0:255];
integer                 queue_head, queue_tail;
reg [WIDTH-1:0]         expected_data;
integer                 write_count;
integer                 read_count;
integer                 error_count;
integer                 i, j;

// 时钟生成
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// 复位生成
initial begin
    rst = 1;
    #(CLK_PERIOD * 3);
    rst = 0;
end

//=====================================
// 标准模式同步FIFO (FLOP_DATA_OUT = 0)
//=====================================
sync_fifo #(
    .DEPTH                 (DEPTH),
    .WIDTH                 (WIDTH),
    .ALMOST_FULL_THRESHOLD (ALMOST_FULL_THRESHOLD),
    .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
    .FLOP_DATA_OUT         (0)
) u_sync_fifo_std (
    .CLK                   (clk),
    .RST                   (rst),
    .WR_EN                 (wr_en),
    .DIN                   (din),
    .FULL                  (full),
    .RD_EN                 (rd_en),
    .DOUT                  (dout),
    .EMPTY                 (empty),
    .ALMOST_FULL           (almost_full),
    .ALMOST_EMPTY          (almost_empty),
    .DATA_CNT              (data_cnt)
);

//=====================================
// FWFT模式同步FIFO (FLOP_DATA_OUT = 1)
//=====================================
sync_fifo #(
    .DEPTH                 (DEPTH),
    .WIDTH                 (WIDTH),
    .ALMOST_FULL_THRESHOLD (ALMOST_FULL_THRESHOLD),
    .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
    .FLOP_DATA_OUT         (1)
) u_sync_fifo_fwft (
    .CLK                   (clk),
    .RST                   (rst),
    .WR_EN                 (wr_en),
    .DIN                   (din),
    .FULL                  (full_fwft),
    .RD_EN                 (rd_en),
    .DOUT                  (dout_fwft),
    .EMPTY                 (empty_fwft),
    .ALMOST_FULL           (almost_full_fwft),
    .ALMOST_EMPTY          (almost_empty_fwft),
    .DATA_CNT              (data_cnt_fwft)
);

//=====================================
// 队列操作任务
//=====================================

// 数据入队
task enqueue_data;
    input [WIDTH-1:0] data;
    begin
        test_data_array[queue_tail] = data;
        queue_tail = queue_tail + 1;
        if(queue_tail >= 256) queue_tail = 0;
    end
endtask

// 数据出队
task dequeue_data;
    output [WIDTH-1:0] data;
    begin
        if(queue_head != queue_tail) begin
            data = test_data_array[queue_head];
            queue_head = queue_head + 1;
            if(queue_head >= 256) queue_head = 0;
        end
    end
endtask

// 检查队列是否为空
function queue_empty;
    input dummy;
    begin
        queue_empty = (queue_head == queue_tail);
    end
endfunction

// 查看队首数据但不移除
function [WIDTH-1:0] peek_data;
    input dummy;
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
    input [WIDTH-1:0] data;
    begin
        @(posedge clk);
        while(full) @(posedge clk);  // 等待非满
        wr_en = 1;
        din = data;
        enqueue_data(data);
        @(posedge clk);
        wr_en = 0;
        write_count = write_count + 1;
        $display("[%0t] Write: 0x%02h, count=%0d, data_cnt=%0d", 
                 $time, data, write_count, data_cnt);
    end
endtask

// 读数据任务（标准模式）
task read_fifo_std;
    begin
        @(posedge clk);
        while(empty) @(posedge clk);  // 等待非空
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        
        if(!queue_empty(0)) begin
            dequeue_data(expected_data);
            if(dout !== expected_data) begin
                $display("[%0t] STD ERROR: Expected: 0x%02h, Got: 0x%02h", 
                         $time, expected_data, dout);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] STD Read: 0x%02h (Correct), data_cnt=%0d", 
                         $time, dout, data_cnt);
            end
        end
        read_count = read_count + 1;
    end
endtask

// 读数据任务（FWFT模式）
task read_fifo_fwft;
    begin
        @(posedge clk);
        while(empty_fwft) @(posedge clk);  // 等待非空
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        
        if(!queue_empty(0)) begin
            dequeue_data(expected_data);
            if(dout_fwft !== expected_data) begin
                $display("[%0t] FWFT ERROR: Expected: 0x%02h, Got: 0x%02h", 
                         $time, expected_data, dout_fwft);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] FWFT Read: 0x%02h (Correct), data_cnt=%0d", 
                         $time, dout_fwft, data_cnt_fwft);
            end
        end
    end
endtask

// 检查FWFT预读功能
task check_fwft_preread;
    begin
        if(!empty_fwft && !queue_empty(0)) begin
            expected_data = peek_data(0);
            if(dout_fwft !== expected_data) begin
                $display("[%0t] FWFT PREREAD ERROR: Expected: 0x%02h, Got: 0x%02h", 
                         $time, expected_data, dout_fwft);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] FWFT PREREAD: 0x%02h (Correct)", $time, dout_fwft);
            end
        end
    end
endtask

// 验证标志位
task check_flags;
    input [3:0] expected_cnt;
    input expected_empty;
    input expected_full;
    input expected_almost_empty;
    input expected_almost_full;
    input [31:0] test_name;
    begin
        if(data_cnt !== expected_cnt) begin
            $display("[%0t] %0s: DATA_CNT ERROR! Expected: %0d, Got: %0d", 
                     $time, test_name, expected_cnt, data_cnt);
            error_count = error_count + 1;
        end
        
        if(empty !== expected_empty) begin
            $display("[%0t] %0s: EMPTY ERROR! Expected: %0b, Got: %0b", 
                     $time, test_name, expected_empty, empty);
            error_count = error_count + 1;
        end
        
        if(full !== expected_full) begin
            $display("[%0t] %0s: FULL ERROR! Expected: %0b, Got: %0b", 
                     $time, test_name, expected_full, full);
            error_count = error_count + 1;
        end
        
        if(almost_empty !== expected_almost_empty) begin
            $display("[%0t] %0s: ALMOST_EMPTY ERROR! Expected: %0b, Got: %0b", 
                     $time, test_name, expected_almost_empty, almost_empty);
            error_count = error_count + 1;
        end
        
        if(almost_full !== expected_almost_full) begin
            $display("[%0t] %0s: ALMOST_FULL ERROR! Expected: %0b, Got: %0b", 
                     $time, test_name, expected_almost_full, almost_full);
            error_count = error_count + 1;
        end
        
        $display("[%0t] %0s: cnt=%0d, empty=%0b, full=%0b, almost_empty=%0b, almost_full=%0b", 
                 $time, test_name, data_cnt, empty, full, almost_empty, almost_full);
    end
endtask

//=====================================
// 主测试流程
//=====================================
initial begin
    // 初始化
    wr_en = 0;
    rd_en = 0;
    din = 0;
    write_count = 0;
    read_count = 0;
    error_count = 0;
    queue_head = 0;
    queue_tail = 0;
    
    // 等待复位释放
    wait(!rst);
    repeat(3) @(posedge clk);
    
    $display("=== 开始同步FIFO测试 ===");
    $display("DEPTH=%0d, ALMOST_FULL_THRESHOLD=%0d, ALMOST_EMPTY_THRESHOLD=%0d", 
             DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD);
    
    //=====================================
    // 测试1: 初始状态检查
    //=====================================
    $display("\n--- 测试1: 初始状态检查 ---");
    @(posedge clk);
    check_flags(0, 1, 0, 1, 0, "INIT");
    
    //=====================================
    // 测试2: 基本写入测试
    //=====================================
    $display("\n--- 测试2: 基本写入测试 ---");
    
    // 写入第一个数据
    write_fifo(8'hAA);
    @(posedge clk);
    check_flags(1, 0, 0, 0, 0, "AFTER_WRITE_1");
    
    // 写入第二个数据
    write_fifo(8'h55);
    @(posedge clk);
    check_flags(2, 0, 0, 0, 0, "AFTER_WRITE_2");
    
    //=====================================
    // 测试3: FWFT预读功能测试
    //=====================================
    $display("\n--- 测试3: FWFT预读功能测试 ---");
    check_fwft_preread();  // 应该能看到第一个写入的数据0xAA
    
    //=====================================
    // 测试4: 几乎满标志测试
    //=====================================
    $display("\n--- 测试4: 几乎满标志测试 ---");
    
    // 继续写入直到触发几乎满
    for(i = 3; i <= (DEPTH - ALMOST_FULL_THRESHOLD); i = i + 1) begin
        write_fifo(i);
        @(posedge clk);
    end
    check_flags(DEPTH - ALMOST_FULL_THRESHOLD, 0, 0, 0, 1, "ALMOST_FULL");
    
    // 写满FIFO
    for(i = (DEPTH - ALMOST_FULL_THRESHOLD + 1); i <= DEPTH; i = i + 1) begin
        write_fifo(i);
        @(posedge clk);
    end
    check_flags(DEPTH, 0, 1, 0, 1, "FULL");
    
    //=====================================
    // 测试5: 满时写入阻止测试
    //=====================================
    $display("\n--- 测试5: 满时写入阻止测试 ---");
    
    // 尝试写入（应该被阻止）
    @(posedge clk);
    wr_en = 1;
    din = 8'hFF;
    @(posedge clk);
    wr_en = 0;
    @(posedge clk);
    
    // 验证计数器没有变化
    if(data_cnt !== DEPTH) begin
        $display("[%0t] ERROR: Write when full should be blocked!", $time);
        error_count = error_count + 1;
    end else begin
        $display("[%0t] Write blocking when full: CORRECT", $time);
    end
    
    //=====================================
    // 测试6: 基本读取测试（标准模式）
    //=====================================
    $display("\n--- 测试6: 基本读取测试（标准模式）---");
    
    // 读取第一个数据
    read_fifo_std();
    @(posedge clk);
    check_flags(DEPTH-1, 0, 0, 0, 1, "AFTER_READ_1");
    
    // 读取第二个数据
    read_fifo_std();
    @(posedge clk);
    check_flags(DEPTH-2, 0, 0, 0, 0, "AFTER_READ_2");
    
    //=====================================
    // 测试7: 几乎空标志测试
    //=====================================
    $display("\n--- 测试7: 几乎空标志测试 ---");
    
    // 继续读取直到触发几乎空
    for(i = 3; i <= (DEPTH - ALMOST_EMPTY_THRESHOLD); i = i + 1) begin
        read_fifo_std();
        @(posedge clk);
    end
    check_flags(ALMOST_EMPTY_THRESHOLD, 0, 0, 1, 0, "ALMOST_EMPTY");
    
    // 读空FIFO
    for(i = 1; i <= ALMOST_EMPTY_THRESHOLD; i = i + 1) begin
        read_fifo_std();
        @(posedge clk);
    end
    check_flags(0, 1, 0, 1, 0, "EMPTY");
    
    //=====================================
    // 测试8: 空时读取阻止测试
    //=====================================
    $display("\n--- 测试8: 空时读取阻止测试 ---");
    
    // 尝试读取（应该被阻止）
    @(posedge clk);
    rd_en = 1;
    @(posedge clk);
    rd_en = 0;
    @(posedge clk);
    
    // 验证计数器没有变化
    if(data_cnt !== 0) begin
        $display("[%0t] ERROR: Read when empty should be blocked!", $time);
        error_count = error_count + 1;
    end else begin
        $display("[%0t] Read blocking when empty: CORRECT", $time);
    end
    
    //=====================================
    // 测试9: FWFT模式完整测试
    //=====================================
    $display("\n--- 测试9: FWFT模式完整测试 ---");
    
    // 清空队列，重新开始
    queue_head = 0;
    queue_tail = 0;
    
    // 写入数据到FWFT FIFO
    write_fifo(8'hF1);
    @(posedge clk);
    check_fwft_preread();  // 检查预读
    
    write_fifo(8'hF2);
    @(posedge clk);
    check_fwft_preread();  // 应该仍然是F1
    
    // 读取第一个数据，第二个应该立即出现
    read_fifo_fwft();
    @(posedge clk);
    check_fwft_preread();  // 现在应该是F2
    
    read_fifo_fwft();
    @(posedge clk);
    
    //=====================================
    // 测试10: 混合读写测试
    //=====================================
    $display("\n--- 测试10: 混合读写测试 ---");
    
    // 清空队列
    queue_head = 0;
    queue_tail = 0;
    
    // 同时进行读写操作
    for(i = 0; i < 20; i = i + 1) begin
        // 写入
        if(i < 15) begin
            write_fifo(8'h80 + i);
        end
        
        // 延迟几个周期
        repeat(2) @(posedge clk);
        
        // 读取（当FIFO不为空时）
        if(i > 2 && !empty) begin
            read_fifo_std();
        end
        
        repeat(1) @(posedge clk);
    end
    
    // 读完剩余数据
    while(!empty) begin
        read_fifo_std();
        @(posedge clk);
    end
    
    //=====================================
    // 测试11: 数据计数器连续性测试
    //=====================================
    $display("\n--- 测试11: 数据计数器连续性测试 ---");
    
    // 清空队列
    queue_head = 0;
    queue_tail = 0;
    
    // 验证计数器在各种操作下的正确性
    for(i = 0; i < DEPTH; i = i + 1) begin
        write_fifo(i);
        @(posedge clk);
        if(data_cnt !== (i + 1)) begin
            $display("[%0t] CNT ERROR after write %0d: Expected %0d, Got %0d", 
                     $time, i, i+1, data_cnt);
            error_count = error_count + 1;
        end
    end
    
    for(i = 0; i < DEPTH; i = i + 1) begin
        read_fifo_std();
        @(posedge clk);
        if(data_cnt !== (DEPTH - i - 1)) begin
            $display("[%0t] CNT ERROR after read %0d: Expected %0d, Got %0d", 
                     $time, i, DEPTH-i-1, data_cnt);
            error_count = error_count + 1;
        end
    end
    
    //=====================================
    // 测试结果
    //=====================================
    repeat(10) @(posedge clk);
    
    $display("\n=== 测试完成 ===");
    $display("写入操作数量: %0d", write_count);
    $display("读取操作数量: %0d", read_count);
    $display("错误数量: %0d", error_count);
    
    if(error_count == 0) begin
        $display("*** 所有测试通过! ***");
    end else begin
        $display("*** 测试失败，发现 %0d 个错误 ***", error_count);
    end

    
end

//=====================================
// 实时监控
//=====================================
always @(posedge clk) begin
    if(wr_en || rd_en) begin
        $display("[%0t] Monitor: wr_en=%0b, rd_en=%0b, data_cnt=%0d, empty=%0b, full=%0b, almost_empty=%0b, almost_full=%0b", 
                 $time, wr_en, rd_en, data_cnt, empty, full, almost_empty, almost_full);
    end
end

// 生成波形文件
initial begin
    $dumpfile("tb_sync_fifo.vcd");
    $dumpvars(0, tb_sync_fifo);
end

endmodule
