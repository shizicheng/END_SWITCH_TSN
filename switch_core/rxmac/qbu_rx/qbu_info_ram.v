`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/15
// Design Name: 
// Module Name: qbu_info_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: QBU报文信息RAM模块，分别缓存EMAC和PMAC的报文参数信息
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module qbu_info_ram(
    input     wire                         i_clk                              ,   // 250MHz
    input     wire                         i_rst                              ,

    // 报文参数输入   
    input     wire    [1:0]                i_port_speed                       , // 端口速率
    input     wire    [2:0]                i_vlan_pri                         , // [62:60](3bit) : vlan_priority       
    input     wire    [11:0]               i_vlan_id                          , // 12bit VLAN ID,取值范围 1-4094     
    input     wire                         i_frm_vlan_flag                    , // [27](1bit) : frm_vlan_flag，表明带有802.1Q标签           
    input     wire                         i_frm_qbu                          , // [11](1bit) : 是否为关键帧(Qbu)     
    input     wire                         i_frm_discard                      , // 检验crc是否正确[12](1bit)  
    input     wire    [15:0]               i_rtag_sequence                    , // CB协议 R-TAG字段      
    input     wire                         i_rtag_flag                        , // 是否存在rtag    
    
    input     wire    [47:0]               i_target_mac                       ,  
    input     wire    [47:0]               i_source_mac                       , 
    input     wire    [15:0]               i_ethertype                        , // 以太网类型字段 

    input     wire                         i_emac_info_valid                  , // EMAC信息标志
    input     wire                         i_pmac_info_valid                  , // PMAC信息标志
    
    // 读取参数
    input     wire                         i_rd_emac_info                     , // 读EMAC信息
    input     wire                         i_rd_pmac_info                     , // 读PMAC信息
    output    wire   [1:0]                 o_port_speed                       ,
    output    wire    [2:0]                o_vlan_pri                         ,
    output    wire    [11:0]               o_vlan_id                          ,
    output    wire                         o_frm_vlan_flag                    ,
    output    wire                         o_frm_qbu                          ,
    output    wire                         o_frm_discard                      ,
    output    wire    [15:0]               o_rtag_sequence                    ,
    output    wire                         o_rtag_flag                        ,
    output    wire    [47:0]               o_dmac		                      ,       
    output    wire    [47:0]               o_samc 	                          ,  
    output    wire    [15:0]               o_ethertype                        ,                     
    output    wire                         o_info_valid                       
);

/***************parameter*************/
localparam  DATAWIDTH                   =  149                                 ; // 数据位宽：2+3+12+1+1+1+16+1+48+48+16=149
localparam  DEPT_W                      =  8                                   ; // FIFO深度

/***************reg*******************/
// 输入信号打拍
reg         [1:0]                          ri_port_speed                       ;
reg         [2:0]                          ri_vlan_pri                         ;
reg         [11:0]                         ri_vlan_id                          ;
reg                                        ri_frm_vlan_flag                    ;
reg                                        ri_frm_qbu                          ;
reg                                        ri_frm_discard                      ;
reg         [15:0]                         ri_rtag_sequence                    ;
reg                                        ri_rtag_flag                        ;
reg         [47:0]                         ri_target_mac                       ;
reg         [47:0]                         ri_source_mac                       ;
reg         [15:0]                         ri_ethertype                        ;
// reg                                        ri_info_valid                       ;
reg                                        ri_emac_info_valid                  ;
reg                                        ri_pmac_info_valid                  ;
reg                                        ri_rd_emac_info                     ;
reg                                        ri_rd_pmac_info                     ;

// EMAC FIFO写控制
reg                                        r_emac_wr_en                        ;
reg         [DATAWIDTH-1:0]                r_emac_wr_data                      ;

// PMAC FIFO写控制
reg                                        r_pmac_wr_en                        ;
reg         [DATAWIDTH-1:0]                r_pmac_wr_data                      ;

// EMAC FIFO读控制
wire                                       w_emac_rd_en                        ;
reg                                        r_emac_rd_en_1d                     ;

// PMAC FIFO读控制
wire                                       w_pmac_rd_en                        ;
reg                                        r_pmac_rd_en_1d                     ;

// 输出信号寄存器
reg         [1:0]                          r_port_speed                        ;
reg         [2:0]                          r_vlan_pri                          ;
reg         [11:0]                         r_vlan_id                           ;
reg                                        r_frm_vlan_flag                     ;
reg                                        r_frm_qbu                           ;
reg                                        r_frm_discard                       ;
reg         [15:0]                         r_rtag_sequence                     ;
reg                                        r_rtag_flag                         ;
reg         [47:0]                         r_dmac                              ;
reg         [47:0]                         r_smac                              ;
reg         [15:0]                         r_ethertype                         ;
reg                                        r_info_valid                        ;

/***************wire******************/
// EMAC FIFO接口
wire        [DATAWIDTH-1:0]                w_emac_rd_data                      ;
wire                                       w_emac_empty                        ;
wire                                       w_emac_full                         ;

// PMAC FIFO接口
wire        [DATAWIDTH-1:0]                w_pmac_rd_data                      ;
wire                                       w_pmac_empty                        ;
wire                                       w_pmac_full                         ;

// 数据打包
wire        [DATAWIDTH-1:0]                w_pack_data                         ;

/***************component*************/
// EMAC信息FIFO
sync_fifo #(
    .DEPTH                                 (DEPT_W                             ),
    .WIDTH                                 (DATAWIDTH                          ),
    .ALMOST_FULL_THRESHOLD                 (1                                  ),
    .ALMOST_EMPTY_THRESHOLD                (1                                  ),
    .FLOP_DATA_OUT                         (0                                  )  // 1为fwft，0为standard
) inst_emac_fifo (
    .i_clk                                 (i_clk                              ),
    .i_rst                                 (i_rst                              ),
    .i_wr_en                               (r_emac_wr_en                       ),
    .i_din                                 (r_emac_wr_data                     ),
    .o_full                                (w_emac_full                        ),
    .i_rd_en                               (w_emac_rd_en                       ),
    .o_dout                                (w_emac_rd_data                     ),
    .o_empty                               (w_emac_empty                       ),
    .o_almost_full                         (                                   ),
    .o_almost_empty                        (                                   ),
    .o_data_cnt                            (                                   )
);

// PMAC信息FIFO
sync_fifo #(
    .DEPTH                                 (DEPT_W                             ),
    .WIDTH                                 (DATAWIDTH                          ),
    .ALMOST_FULL_THRESHOLD                 (1                                  ),
    .ALMOST_EMPTY_THRESHOLD                (1                                  ),
    .FLOP_DATA_OUT                         (0                                  )  // 1为fwft，0为standard
) inst_pmac_fifo (
    .i_clk                                 (i_clk                              ),
    .i_rst                                 (i_rst                              ),
    .i_wr_en                               (r_pmac_wr_en                       ),
    .i_din                                 (r_pmac_wr_data                     ),
    .o_full                                (w_pmac_full                        ),
    .i_rd_en                               (w_pmac_rd_en                       ),
    .o_dout                                (w_pmac_rd_data                     ),
    .o_empty                               (w_pmac_empty                       ),
    .o_almost_full                         (                                   ),
    .o_almost_empty                        (                                   ),
    .o_data_cnt                            (                                   )
);

/***************assign****************/
// 数据打包：{rtag_flag, rtag_sequence[15:0], frm_discard, frm_qbu, frm_vlan_flag, vlan_id[11:0], vlan_pri[2:0], port_speed[1:0], target_mac[47:0], source_mac[47:0], ethertype[15:0]}
assign w_pack_data = {
    ri_rtag_flag,
    ri_rtag_sequence,
    ri_frm_discard,
    ri_frm_qbu,
    ri_frm_vlan_flag,
    ri_vlan_id,
    ri_vlan_pri,
    ri_port_speed,
    ri_target_mac,
    ri_source_mac,
    ri_ethertype
};

// 输出信号
assign o_port_speed     = r_port_speed                                         ;
assign o_vlan_pri       = r_vlan_pri                                           ;
assign o_vlan_id        = r_vlan_id                                            ;
assign o_frm_vlan_flag  = r_frm_vlan_flag                                      ;
assign o_frm_qbu        = r_frm_qbu                                            ;
assign o_frm_discard    = r_frm_discard                                        ;
assign o_rtag_sequence  = r_rtag_sequence                                      ;
assign o_rtag_flag      = r_rtag_flag                                          ;
assign o_dmac           = r_dmac                                               ;
assign o_samc           = r_smac                                               ;
assign o_ethertype      = r_ethertype                                          ;
assign o_info_valid     = r_info_valid                                         ;

/***************always****************/
// 输入信号打拍 - 合并到一个always块中
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        ri_port_speed    <= 2'd0;
        ri_vlan_pri      <= 3'd0;
        ri_vlan_id       <= 12'd0;
        ri_frm_vlan_flag <= 1'b0;
        ri_frm_qbu       <= 1'b0;
        ri_frm_discard   <= 1'b0;
        ri_rtag_sequence <= 16'd0;
        ri_rtag_flag     <= 1'b0;
        ri_target_mac    <= 48'd0;
        ri_source_mac    <= 48'd0;
        ri_ethertype     <= 16'd0;
        ri_emac_info_valid     <= 1'b0;
        ri_pmac_info_valid     <= 1'b0;
        ri_rd_emac_info  <= 1'b0;
        ri_rd_pmac_info  <= 1'b0;
    end
    else begin
        ri_port_speed    <= i_port_speed;
        ri_vlan_pri      <= i_vlan_pri;
        ri_vlan_id       <= i_vlan_id;
        ri_frm_vlan_flag <= i_frm_vlan_flag;
        ri_frm_qbu       <= i_frm_qbu;
        ri_frm_discard   <= i_frm_discard;
        ri_rtag_sequence <= i_rtag_sequence;
        ri_rtag_flag     <= i_rtag_flag;
        ri_target_mac    <= i_target_mac;
        ri_source_mac    <= i_source_mac;
        ri_ethertype     <= i_ethertype;
        ri_emac_info_valid     <= i_emac_info_valid;
        ri_pmac_info_valid     <= i_pmac_info_valid;
        ri_rd_emac_info  <= i_rd_emac_info;
        ri_rd_pmac_info  <= i_rd_pmac_info;
    end
end

// EMAC FIFO写使能 - 当信息有效且为EMAC信息时写入
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_emac_wr_en <= 1'b0;
    end
    else begin
        r_emac_wr_en <= (ri_emac_info_valid == 1'b1) ? 1'b1 : 1'b0;
    end
end

// EMAC FIFO写数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_emac_wr_data <= {DATAWIDTH{1'b0}};
    end
    else begin
        r_emac_wr_data <= (ri_emac_info_valid == 1'b1) ? w_pack_data : {DATAWIDTH{1'b0}};
    end
end

// PMAC FIFO写使能 - 当信息有效且为PMAC信息时写入
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_pmac_wr_en <= 1'b0;
    end
    else begin
        r_pmac_wr_en <= (ri_pmac_info_valid == 1'b1) ? 1'b1 : 1'b0;
    end
end

// PMAC FIFO写数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_pmac_wr_data <= {DATAWIDTH{1'b0}};
    end
    else begin
        r_pmac_wr_data <= (ri_pmac_info_valid == 1'b1) ? w_pack_data : {DATAWIDTH{1'b0}};
    end
end

assign w_emac_rd_en = ri_rd_emac_info == 1'b1 && w_emac_empty == 1'b0 ? 1'd1 : 1'd0;
assign w_pmac_rd_en = ri_rd_pmac_info == 1'b1 && w_pmac_empty == 1'b0 ? 1'd1 : 1'd0;

// EMAC FIFO读使能延迟 - 标准模式下数据延迟一拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_emac_rd_en_1d <= 1'b0;
    end
    else begin
        r_emac_rd_en_1d <= w_emac_rd_en;
    end
end

// PMAC FIFO读使能延迟 - 标准模式下数据延迟一拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_pmac_rd_en_1d <= 1'b0;
    end
    else begin
        r_pmac_rd_en_1d <= w_pmac_rd_en;
    end
end

// 输出信号有效标志 - 使用延迟后的读使能信号
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_info_valid <= 1'b0;
    end
    else begin
        r_info_valid <= (r_emac_rd_en_1d == 1'b1 || r_pmac_rd_en_1d == 1'b1) ? 1'b1 : 1'b0;
    end
end

// 输出数据解析 - o_port_speed
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_port_speed <= 2'd0;
    end
    else begin
        r_port_speed <= (r_emac_rd_en_1d == 1'b1) ? 
                        w_emac_rd_data[113:112] :
                        (r_pmac_rd_en_1d == 1'b1) ?
                        w_pmac_rd_data[113:112] :
                        2'd0;
    end
end

// 输出数据解析 - o_vlan_pri
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_vlan_pri <= 3'd0;
    end
    else begin
        r_vlan_pri <= (r_emac_rd_en_1d == 1'b1) ? 
                      w_emac_rd_data[116:114] :
                      (r_pmac_rd_en_1d == 1'b1) ?
                      w_pmac_rd_data[116:114] :
                      3'd0;
    end
end

// 输出数据解析 - o_vlan_id
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_vlan_id <= 12'd0;
    end
    else begin
        r_vlan_id <= (r_emac_rd_en_1d == 1'b1) ? 
                     w_emac_rd_data[128:117] :
                     (r_pmac_rd_en_1d == 1'b1) ?
                     w_pmac_rd_data[128:117] :
                     12'd0;
    end
end

// 输出数据解析 - o_frm_vlan_flag
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_frm_vlan_flag <= 1'b0;
    end
    else begin
        r_frm_vlan_flag <= (r_emac_rd_en_1d == 1'b1) ? 
                           w_emac_rd_data[129] :
                           (r_pmac_rd_en_1d == 1'b1) ?
                           w_pmac_rd_data[129] :
                           1'b0;
    end
end

// 输出数据解析 - o_frm_qbu
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_frm_qbu <= 1'b0;
    end
    else begin
        r_frm_qbu <= (r_emac_rd_en_1d == 1'b1) ? 
                     w_emac_rd_data[130] :
                     (r_pmac_rd_en_1d == 1'b1) ?
                     w_pmac_rd_data[130] :
                     1'b0;
    end
end

// 输出数据解析 - o_frm_discard
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_frm_discard <= 1'b0;
    end
    else begin
        r_frm_discard <= (r_emac_rd_en_1d == 1'b1) ? 
                         w_emac_rd_data[131] :
                         (r_pmac_rd_en_1d == 1'b1) ?
                         w_pmac_rd_data[131] :
                         1'b0;
    end
end

// 输出数据解析 - o_rtag_sequence
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_rtag_sequence <= 16'd0;
    end
    else begin
        r_rtag_sequence <= (r_emac_rd_en_1d == 1'b1) ? 
                           w_emac_rd_data[147:132] :
                           (r_pmac_rd_en_1d == 1'b1) ?
                           w_pmac_rd_data[147:132] :
                           16'd0;
    end
end

// 输出数据解析 - o_rtag_flag
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_rtag_flag <= 1'b0;
    end
    else begin
        r_rtag_flag <= (r_emac_rd_en_1d == 1'b1) ? 
                       w_emac_rd_data[148] :
                       (r_pmac_rd_en_1d == 1'b1) ?
                       w_pmac_rd_data[148] :
                       1'b0;
    end
end

// 输出数据解析 - o_ethertype
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_ethertype <= 16'd0;
    end
    else begin
        r_ethertype <= (r_emac_rd_en_1d == 1'b1) ? 
                       w_emac_rd_data[15:0] :
                       (r_pmac_rd_en_1d == 1'b1) ?
                       w_pmac_rd_data[15:0] :
                       16'd0;
    end
end

// 输出数据解析 - o_smac
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_smac <= 48'd0;
    end
    else begin
        r_smac <= (r_emac_rd_en_1d == 1'b1) ? 
                  w_emac_rd_data[63:16] :
                  (r_pmac_rd_en_1d == 1'b1) ?
                  w_pmac_rd_data[63:16] :
                  48'd0;
    end
end

// 输出数据解析 - o_dmac
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_dmac <= 48'd0;
    end
    else begin
        r_dmac <= (r_emac_rd_en_1d == 1'b1) ? 
                  w_emac_rd_data[111:64] :
                  (r_pmac_rd_en_1d == 1'b1) ?
                  w_pmac_rd_data[111:64] :
                  48'd0;
    end
end

endmodule 