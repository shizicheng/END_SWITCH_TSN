`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2025/08/03 15:33:17
// Design Name: 
// Module Name: qbu_rx_timestamp
//////////////////////////////////////////////////////////////////////////////////

module qbu_rx_timestamp#(
    parameter                               DWIDTH          = 'd8                                   
)(
    input       wire                        i_clk                       ,
    input       wire                        i_rst                       ,

    input       wire    [15:0]              i_paket_ethertype           ,
    input       wire                        i_paket_ethertype_valid     ,

    input       wire    [DWIDTH - 1:0]      i_pmac_axis_data            ,          
    input       wire                        i_pmac_axis_valid           ,          

    input       wire    [DWIDTH - 1:0]      i_emac_axis_data            ,          
    input       wire                        i_emac_axis_valid           ,          

    output      wire                        o_mac_time_irq              , // 打时间戳中断信号
    output      wire    [7:0]               o_mac_frame_seq             , // 帧序列号
    output      wire    [7:0]               o_timestamp_addr              // 打时间戳存储的 RAM 地址
);

    //==========================================================================
    // 参数定义
    //==========================================================================
    localparam                              PTP_ETHERTYPE   = 16'h88F7  ; // PTP 协议类型

    //==========================================================================
    // 输入信号寄存器 (ri_ 开头)
    //==========================================================================
    reg         [15:0]                      ri_paket_ethertype          ;
    reg                                     ri_paket_ethertype_valid    ;
    
    reg         [DWIDTH - 1:0]              ri_pmac_axis_data           ;
    reg                                     ri_pmac_axis_valid          ;
    
    reg         [DWIDTH - 1:0]              ri_emac_axis_data           ;
    reg                                     ri_emac_axis_valid          ;

    //==========================================================================
    // 内部逻辑信号
    //==========================================================================
    wire                                    w_data_valid                ; // 数据有效信号
    wire                                    w_ptp_frame_flag            ; // PTP 报文标志
    wire                                    w_ptp_trigger               ; // PTP 时间戳触发条件
    
    //==========================================================================
    // 输出信号寄存器 (ro_ 开头)
    //==========================================================================
    reg                                     ro_mac_time_irq             ;
    reg         [7:0]                       ro_mac_frame_seq            ;
    reg         [7:0]                       ro_timestamp_addr           ;

    //==========================================================================
    // 输出信号赋值
    //==========================================================================
    assign o_mac_time_irq                   = ro_mac_time_irq           ;
    assign o_mac_frame_seq                  = ro_mac_frame_seq          ;
    assign o_timestamp_addr                 = ro_timestamp_addr         ;
    //==========================================================================
    // 输入信号寄存
    //==========================================================================
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            ri_paket_ethertype          <= 16'd0   ;
            ri_paket_ethertype_valid    <= 1'b0    ;
            ri_pmac_axis_data           <= {DWIDTH{1'b0}} ;
            ri_pmac_axis_valid          <= 1'b0    ;
            ri_emac_axis_data           <= {DWIDTH{1'b0}} ;
            ri_emac_axis_valid          <= 1'b0    ;
        end else begin
            ri_paket_ethertype          <= i_paket_ethertype      ;
            ri_paket_ethertype_valid    <= i_paket_ethertype_valid;
            ri_pmac_axis_data           <= i_pmac_axis_data       ;
            ri_pmac_axis_valid          <= i_pmac_axis_valid      ;
            ri_emac_axis_data           <= i_emac_axis_data       ;
            ri_emac_axis_valid          <= i_emac_axis_valid      ;
        end
    end

    //==========================================================================
    // 组合逻辑
    //==========================================================================
    // 数据有效信号：PMAC 或 EMAC 任一路有效数据
    assign w_data_valid = ri_pmac_axis_valid || ri_emac_axis_valid;
    
    // PTP 报文检测：以太网类型为 0x88F7
    assign w_ptp_frame_flag = ri_paket_ethertype_valid && (ri_paket_ethertype == PTP_ETHERTYPE);
    
    // PTP 时间戳触发条件：PTP 报文且数据第一字节[3:0]为 0x0, 0x2, 0x3
    assign w_ptp_trigger = w_ptp_frame_flag && w_data_valid && 
                          ((ri_pmac_axis_data[3:0] == 4'h0) || 
                           (ri_pmac_axis_data[3:0] == 4'h2) || 
                           (ri_pmac_axis_data[3:0] == 4'h3) ||
                           (ri_emac_axis_data[3:0] == 4'h0) || 
                           (ri_emac_axis_data[3:0] == 4'h2) || 
                           (ri_emac_axis_data[3:0] == 4'h3));

    //==========================================================================
    // 时序逻辑
    //==========================================================================
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



endmodule
