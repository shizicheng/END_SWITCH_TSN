`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2025/08/03 15:33:17
// Design Name: 
// Module Name: qbu_tx_timestamp
//////////////////////////////////////////////////////////////////////////////////

module qbu_tx_timestamp#(
    parameter                               DWIDTH          = 'd8                                   
)(
    input       wire                        i_clk                       ,
    input       wire                        i_rst                       ,

    input       wire    [DWIDTH - 1:0]      i_mac_axis_data             ,          
    input       wire                        i_mac_axis_valid            ,              

    output      wire                        o_mac_time_irq              , // 打时间戳中断信号
    output      wire    [7:0]               o_mac_frame_seq             , // 帧序列号
    output      wire    [7:0]               o_timestamp_addr              // 打时间戳存储的 RAM 地址
);

    //==========================================================================
    // 参数定义
    //==========================================================================
    localparam                              PTP_ETHERTYPE   = 16'h88F7  ; // PTP 协议类型
    localparam                              BYTE_CNT_WIDTH  = 'd8       ; // 字节计数器位宽

    //==========================================================================
    // 输入信号寄存器 (ri_ 开头)
    //==========================================================================
    reg         [DWIDTH - 1:0]              ri_mac_axis_data            ;
    reg                                     ri_mac_axis_valid           ;

    //==========================================================================
    // 内部逻辑信号
    //==========================================================================
    wire                                    w_data_valid                ; // 数据有效信号
    wire                                    w_frame_start               ; // 帧开始信号
    wire                                    w_ptp_ethertype_match       ; // PTP 以太网类型匹配
    wire                                    w_ptp_trigger               ; // PTP 时间戳触发条件
    
    //==========================================================================
    // 内部寄存器
    //==========================================================================
    reg         [BYTE_CNT_WIDTH-1:0]        r_byte_counter              ; // 字节计数器
    reg         [15:0]                      r_ethertype_buffer          ; // 以太网类型缓存
    reg                                     r_ptp_frame_flag            ; // PTP 报文标志
    reg         [7:0]                       r_ptp_message_type          ; // PTP 消息类型缓存
    reg                                     r_data_valid_d1             ; // 数据有效信号延迟一拍

    //==========================================================================
    // 输出信号寄存器 (ro_ 开头)
    //==========================================================================
    reg                                     ro_mac_time_irq             ;
    reg         [7:0]                       ro_mac_frame_seq            ;
    reg         [7:0]                       ro_timestamp_addr           ;

    //==========================================================================
    // 输入信号寄存
    //==========================================================================
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            ri_mac_axis_data            <= {DWIDTH{1'b0}} ;
            ri_mac_axis_valid           <= 1'b0    ;
        end else begin
            ri_mac_axis_data            <= i_mac_axis_data ;
            ri_mac_axis_valid           <= i_mac_axis_valid;
        end
    end

    //==========================================================================
    // 组合逻辑
    //==========================================================================
    // 数据有效信号
    assign w_data_valid = ri_mac_axis_valid;
    
    // 帧开始检测：有效数据且前一拍无效
    assign w_frame_start = w_data_valid && (~r_data_valid_d1);
    
    // PTP 以太网类型匹配
    assign w_ptp_ethertype_match = (r_ethertype_buffer == PTP_ETHERTYPE);
    
    // PTP 时间戳触发条件：PTP 报文且消息类型[3:0]为 0x0, 0x2, 0x3
    assign w_ptp_trigger = r_ptp_frame_flag && (r_byte_counter == 8'd11) && w_data_valid &&
                          ((ri_mac_axis_data[3:0] == 4'h0) || 
                           (ri_mac_axis_data[3:0] == 4'h2) || 
                           (ri_mac_axis_data[3:0] == 4'h3));

    //==========================================================================
    // 时序逻辑
    //==========================================================================
    // 数据有效信号延迟
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_data_valid_d1 <= 1'b0;
        end else begin
            r_data_valid_d1 <= w_data_valid;
        end
    end

    // 字节计数器：每帧从0开始计数
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_byte_counter <= 8'd0;
        end else if (w_frame_start) begin
            r_byte_counter <= 8'd1;
        end else if (w_data_valid) begin
            r_byte_counter <= r_byte_counter + 1'b1;
        end
    end

    // 以太网类型缓存：捕获第9、10字节
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_ethertype_buffer <= 16'd0;
        end else if (w_data_valid) begin
            if (r_byte_counter == 8'd9) begin
                r_ethertype_buffer[15:8] <= ri_mac_axis_data;
            end else if (r_byte_counter == 8'd10) begin
                r_ethertype_buffer[7:0] <= ri_mac_axis_data;
            end
        end
    end

    // PTP 报文标志：检测到PTP以太网类型后置位，帧结束后清零
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_ptp_frame_flag <= 1'b0;
        end else if (w_frame_start) begin
            r_ptp_frame_flag <= 1'b0;
        end else if ((r_byte_counter == 8'd10) && w_data_valid && w_ptp_ethertype_match) begin
            r_ptp_frame_flag <= 1'b1;
        end
    end

    // PTP 消息类型缓存：捕获第11字节
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_ptp_message_type <= 8'd0;
        end else if (w_data_valid && (r_byte_counter == 8'd11)) begin
            r_ptp_message_type <= ri_mac_axis_data;
        end
    end

    // 帧序列号计数器：每接收到一个有效数据帧序列号加1
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            ro_mac_frame_seq <= 8'd0;
        end else if (w_data_valid) begin
            ro_mac_frame_seq <= ro_mac_frame_seq + 1'b1;
        end
    end

    // 时间戳中断信号：满足 PTP 触发条件时拉高
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            ro_mac_time_irq <= 1'b0;
        end else begin
            ro_mac_time_irq <= w_ptp_trigger;
        end
    end

    // 时间戳地址计数器：每次产生时间戳中断时地址加1
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            ro_timestamp_addr <= 8'd0;
        end else if (w_ptp_trigger) begin
            ro_timestamp_addr <= ro_timestamp_addr + 1'b1;
        end
    end

    //==========================================================================
    // 输出信号赋值
    //==========================================================================
    assign o_mac_time_irq       = ro_mac_time_irq      ;
    assign o_mac_frame_seq      = ro_mac_frame_seq     ;
    assign o_timestamp_addr     = ro_timestamp_addr    ;

endmodule
