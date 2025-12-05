`timescale 1ns / 1ps

//==============================================================================
// TCAM写表测试工具模块
// 功能：提供通用的TCAM写表测试功能，支持写表、改表、删除表操作
// 特点：独立模块，方便复制移植到其他项目
//==============================================================================

module tcam_write_test_utils #(
    // 参数定义 - 可根据具体项目调整
    parameter                       LOOK_UP_DATA_WIDTH      = 144       ,   // 查找数据宽度
    parameter                       ACTION_WIDTH            = 24        ,   // Action数据位宽  
    parameter                       REG_ADDR_BUS_WIDTH      = 8         ,   // 寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      = 16        ,   // 寄存器数据位宽
    parameter                       TCAM_DATA_WIDTH         = LOOK_UP_DATA_WIDTH * 2,  // TCAM数据宽度：288位
    parameter                       TCAM_ACTION_WIDTH       = ACTION_WIDTH * 2,        // Action TCAM编码宽度：48位
    parameter                       TOTAL_FRAME_WIDTH       = TCAM_DATA_WIDTH + TCAM_ACTION_WIDTH,  // 总帧宽度：336位
    parameter                       ACTUAL_DATA_WIDTH       = LOOK_UP_DATA_WIDTH       // 实际数据位宽：144位
)(
    // 时钟和复位信号
    input               wire                                clk                         ,
    input               wire                                rst                         ,
    
    // 寄存器总线接口 - 连接到TCAM模块的寄存器接口
    output              reg                                 o_reg_bus_we                ,   // 寄存器写使能
    output              reg     [REG_ADDR_BUS_WIDTH-1:0]   o_reg_bus_we_addr           ,   // 寄存器写地址
    output              reg     [REG_DATA_BUS_WIDTH-1:0]   o_reg_bus_we_din            ,   // 寄存器写数据
    output              reg                                 o_reg_bus_we_din_v          ,   // 寄存器写数据有效
    
    // TCAM模块状态信号
    input               wire                                i_tcam_busy                 ,   // TCAM忙信号
    
    // 测试控制接口
    input               wire                                i_write_start               ,   // 开始写表
    input               wire    [2:0]                       i_cmd_type                  ,   // 命令类型：00-写表，01-改表，10-删除表
    input               wire    [ACTUAL_DATA_WIDTH-1:0]     i_raw_data                  ,   // 原始数据
    input               wire    [ACTUAL_DATA_WIDTH-1:0]     i_dont_care_mask            ,   // don't care掩码
    input               wire    [ACTION_WIDTH-1:0]          i_action_data               ,   // Action数据
    
    // 测试状态输出
    output              reg                                 o_write_done                ,   // 写表完成
    output              reg                                 o_write_busy                    // 写表忙
);

//---------- 内部信号定义 ----------
// 状态机状态定义
localparam IDLE         = 3'b000;  // 空闲状态
localparam ENCODE       = 3'b001;  // 编码状态
localparam WAIT_READY   = 3'b010;  // 等待TCAM就绪
localparam WRITE_DATA   = 3'b011;  // 写数据状态
localparam WAIT_DONE    = 3'b100;  // 等待完成状态
localparam DONE         = 3'b101;  // 完成状态

reg     [2:0]                               r_state                         ; // 状态机当前状态
reg     [2:0]                               r_next_state                    ; // 状态机下一状态

// 写表相关寄存器
reg     [2:0]                               r_cmd_type                      ; // 命令类型寄存
reg     [ACTUAL_DATA_WIDTH-1:0]             r_raw_data                      ; // 原始数据寄存
reg     [ACTUAL_DATA_WIDTH-1:0]             r_dont_care_mask                ; // don't care掩码寄存
reg     [ACTION_WIDTH-1:0]                  r_action_data                   ; // Action数据寄存

// 编码后数据
reg     [TCAM_DATA_WIDTH-1:0]               r_encoded_tcam_data             ; // 编码后TCAM数据
reg     [TCAM_ACTION_WIDTH-1:0]             r_encoded_action_data           ; // 编码后Action数据
reg     [TOTAL_FRAME_WIDTH-1:0]             r_complete_frame_data           ; // 完整帧数据

// 写入控制
reg     [7:0]                               r_word_cnt                      ; // 字计数器
reg     [7:0]                               r_total_words                   ; // 总字数
reg     [15:0]                              r_reg_data                      ; // 当前写入的寄存器数据

// 延时计数器
reg     [7:0]                               r_wait_cnt                      ; // 等待计数器

//---------- 函数定义 ----------
// 函数：将1位数据编码为TCAM的2位表示
// 00: 写入0, 01: 写入1, 10: don't care(原始为0), 11: don't care(原始为1)
function [1:0] encode_tcam_bit;
    input data_bit;
    input is_dont_care;
    begin
        if (is_dont_care) begin
            if (data_bit)
                encode_tcam_bit = 2'b11;  // don't care, 原始数据为1
            else
                encode_tcam_bit = 2'b10;  // don't care, 原始数据为0
        end
        else if (data_bit)
            encode_tcam_bit = 2'b01;  // 精确匹配1
        else
            encode_tcam_bit = 2'b00;  // 精确匹配0
    end
endfunction

// 函数：将原始数据编码为TCAM数据
function [TCAM_DATA_WIDTH-1:0] encode_tcam_data;
    input [ACTUAL_DATA_WIDTH-1:0] data;
    input [ACTUAL_DATA_WIDTH-1:0] dont_care_mask;
    integer i;
    begin
        for (i = 0; i < ACTUAL_DATA_WIDTH; i = i + 1) begin
            encode_tcam_data[i*2 +: 2] = encode_tcam_bit(data[i], dont_care_mask[i]);
        end
    end
endfunction

// 函数：对Action数据进行TCAM编码（无don't care）
function [TCAM_ACTION_WIDTH-1:0] encode_tcam_action;
    input [ACTION_WIDTH-1:0] action_data;
    integer i;
    begin
        for (i = 0; i < ACTION_WIDTH; i = i + 1) begin
            encode_tcam_action[i*2 +: 2] = encode_tcam_bit(action_data[i], 1'b0);
        end
    end
endfunction

//---------- 状态机时序逻辑 ----------
always @(posedge clk) begin
    if (rst) begin
        r_state <= IDLE;
    end else begin
        r_state <= r_next_state;
    end
end

//---------- 状态机组合逻辑 ----------
always @(*) begin
    r_next_state = r_state;
    
    case (r_state)
        IDLE: begin
            if (i_write_start) begin
                r_next_state = ENCODE;
            end
        end
        
        ENCODE: begin
            r_next_state = WAIT_READY;
        end
        
        WAIT_READY: begin
            if (!i_tcam_busy) begin
                r_next_state = WRITE_DATA;
            end
        end
        
        WRITE_DATA: begin
            if (r_word_cnt >= r_total_words) begin
                r_next_state = WAIT_DONE;
            end
        end
        
        WAIT_DONE: begin
            if (r_wait_cnt >= 8'd100) begin  // 等待100个时钟周期
                r_next_state = DONE;
            end
        end
        
        DONE: begin
            r_next_state = IDLE;
        end
        
        default: begin
            r_next_state = IDLE;
        end
    endcase
end

//---------- 输入数据锁存 ----------
always @(posedge clk) begin
    if (rst) begin
        r_cmd_type       <= 3'd0;
        r_raw_data       <= {ACTUAL_DATA_WIDTH{1'b0}};
        r_dont_care_mask <= {ACTUAL_DATA_WIDTH{1'b0}};
        r_action_data    <= {ACTION_WIDTH{1'b0}};
    end else if (r_state == IDLE && i_write_start) begin
        r_cmd_type       <= i_cmd_type;
        r_raw_data       <= i_raw_data;
        r_dont_care_mask <= i_dont_care_mask;
        r_action_data    <= i_action_data;
    end
end

//---------- 数据编码处理 ----------
always @(posedge clk) begin
    if (rst) begin
        r_encoded_tcam_data   <= {TCAM_DATA_WIDTH{1'b0}};
        r_encoded_action_data <= {TCAM_ACTION_WIDTH{1'b0}};
        r_complete_frame_data <= {TOTAL_FRAME_WIDTH{1'b0}};
        r_total_words         <= 8'd0;
    end else if (r_state == ENCODE) begin
        // 对原始数据进行TCAM编码
        r_encoded_tcam_data   <= encode_tcam_data(r_raw_data, r_dont_care_mask);
        r_encoded_action_data <= encode_tcam_action(r_action_data);
        r_complete_frame_data <= {encode_tcam_data(r_raw_data, r_dont_care_mask), encode_tcam_action(r_action_data)};
        // 计算需要传输的16位字数
        r_total_words         <= (TOTAL_FRAME_WIDTH + 15) / 16;  // 向上取整
    end
end

//---------- 字计数器 ----------
always @(posedge clk) begin
    if (rst) begin
        r_word_cnt <= 8'd0;
    end else if (r_state == ENCODE) begin
        r_word_cnt <= 8'd0;
    end else if (r_state == WRITE_DATA && !i_tcam_busy) begin
        r_word_cnt <= r_word_cnt + 8'd1;
    end
end

//---------- 等待计数器 ----------
always @(posedge clk) begin
    if (rst) begin
        r_wait_cnt <= 8'd0;
    end else if (r_state == WAIT_DONE) begin
        r_wait_cnt <= r_wait_cnt + 8'd1;
    end else begin
        r_wait_cnt <= 8'd0;
    end
end

//---------- 寄存器数据生成 ----------
always @(posedge clk) begin
    if (rst) begin
        r_reg_data <= 16'd0;
    end else if (r_state == WRITE_DATA) begin
        // 提取16位数据（从高位开始）
        if ((r_word_cnt + 1) * 16 <= TOTAL_FRAME_WIDTH) begin
            // 完整的16位数据
            r_reg_data <= r_complete_frame_data[TOTAL_FRAME_WIDTH-1-r_word_cnt*16 -: 16];
        end else begin
            // 最后不完整的数据：只有8位有效数据
            r_reg_data <= {r_complete_frame_data[7:0], 8'h00};
        end
    end
end

//---------- 寄存器总线输出控制 ----------
always @(posedge clk) begin
    if (rst) begin
        o_reg_bus_we        <= 1'b0;
        o_reg_bus_we_addr   <= {REG_ADDR_BUS_WIDTH{1'b0}};
        o_reg_bus_we_din    <= {REG_DATA_BUS_WIDTH{1'b0}};
        o_reg_bus_we_din_v  <= 1'b0;
    end else if (r_state == WRITE_DATA && !i_tcam_busy) begin
        o_reg_bus_we        <= 1'b1;
        o_reg_bus_we_addr   <= {r_cmd_type[1:0], 6'h00};  // 高2位命令类型，低6位全0
        o_reg_bus_we_din    <= r_reg_data;
        o_reg_bus_we_din_v  <= 1'b1;
    end else begin
        o_reg_bus_we        <= 1'b0;
        o_reg_bus_we_addr   <= {REG_ADDR_BUS_WIDTH{1'b0}};
        o_reg_bus_we_din    <= {REG_DATA_BUS_WIDTH{1'b0}};
        o_reg_bus_we_din_v  <= 1'b0;
    end
end

//---------- 状态输出 ----------
always @(posedge clk) begin
    if (rst) begin
        o_write_done <= 1'b0;
        o_write_busy <= 1'b0;
    end else begin
        o_write_done <= (r_state == DONE);
        o_write_busy <= (r_state != IDLE && r_state != DONE);
    end
end

//---------- 调试输出 ----------
`ifdef SIM
always @(posedge clk) begin
    if (r_state == ENCODE) begin
        $display("[%0t] TCAM Write Utils: Encoding data", $time);
        $display("  Command Type: %0d", r_cmd_type);
        $display("  Raw Data:     %036h", r_raw_data);
        $display("  Don't Care:   %036h", r_dont_care_mask);
        $display("  Action Data:  %06h", r_action_data);
        $display("  Total Words:  %0d", r_total_words);
    end
    
    if (r_state == WRITE_DATA && !i_tcam_busy) begin
        $display("[%0t] TCAM Write Utils: Writing word %0d/%0d, addr=%02h, data=%04h", 
                 $time, r_word_cnt+1, r_total_words, o_reg_bus_we_addr, o_reg_bus_we_din);
    end
    
    if (r_state == DONE) begin
        $display("[%0t] TCAM Write Utils: Write operation completed", $time);
    end
end
`endif

endmodule

//==============================================================================
// TCAM写表测试工具集 - 使用示例和简化接口
//==============================================================================

/*
使用示例：

在testbench中包含此文件：
`include "tcam_write_test_utils.v"

实例化写表工具模块：
tcam_write_test_utils #(
    .LOOK_UP_DATA_WIDTH(144),
    .ACTION_WIDTH(24)
) u_tcam_write_utils (
    .clk(tb_clk),
    .rst(tb_rst),
    .o_reg_bus_we(tb_i_switch_reg_bus_we),
    .o_reg_bus_we_addr(tb_i_switch_reg_bus_we_addr),
    .o_reg_bus_we_din(tb_i_switch_reg_bus_we_din),
    .o_reg_bus_we_din_v(tb_i_switch_reg_bus_we_din_v),
    .i_tcam_busy(tb_o_tcam_busy),
    .i_write_start(tb_write_start),
    .i_cmd_type(tb_cmd_type),
    .i_raw_data(tb_raw_data),
    .i_dont_care_mask(tb_dont_care_mask),
    .i_action_data(tb_action_data),
    .o_write_done(tb_write_done),
    .o_write_busy(tb_write_busy)
);

然后在测试中使用：
// 写入一个表项
tb_cmd_type = 3'b000;  // 写表
tb_raw_data = 144'h123456789ABCDEF0123456789ABCDEF0123456789A;
tb_dont_care_mask = 144'h000000000000000000000000000000000000000000FF;  // 最后8位don't care
tb_action_data = 24'h654321;
tb_write_start = 1'b1;
@(posedge tb_clk);
tb_write_start = 1'b0;

// 等待完成
wait(tb_write_done);
$display("Write operation completed!");

*/