module rx_acllookup_data(
    input               wire                                    i_clk                             ,   // 250MHz
    input               wire                                    i_rst                             ,

    // 二层报文头 一共144bit dmac + smac + vlan + ethertype
    input               wire   [47:0]                           i_dmac_data                       , // 目的 MAC 地址的值 (48bit)
    input               wire   [47:0]                           i_smac_data                       , // 源 MAC 地址的值 (48bit)

    input               wire   [11:0]                           i_vlan_id                         , // 12bit VLAN ID,取值范围 1-4094     
    input               wire   [2:0]                            i_vlan_pri                        , // [62:60](3bit) : vlan_priority
    input               wire   [15:0]                           i_ethertyper                      , //以太网帧类型
    input               wire                                    i_info_vld                        , // 以上字段有效信号
    
    output              wire   [143:0]                          o_mac_cross_port_axi_data         ,   
    output              wire                                    o_mac_cross_axi_data_valid          

);

//---------- 内部信号定义 ----------
// 输入信号打拍
reg             [47:0]                              ri_dmac_data                        ; // 目的MAC地址打拍
reg             [47:0]                              ri_smac_data                        ; // 源MAC地址打拍
reg             [11:0]                              ri_vlan_id                          ; // VLAN ID打拍
reg             [2:0]                               ri_vlan_pri                         ; // VLAN优先级打拍
reg             [15:0]                              ri_ethertyper                       ; // 以太网类型打拍
reg                                                 ri_info_vld                         ; // 信息有效打拍

// 输出数据寄存器
reg             [143:0]                             r_mac_cross_port_axi_data           ; // 144bit数据输出
reg                                                 r_mac_cross_axi_data_valid          ; // 输出有效信号

//---------- 输出信号赋值 ----------
// 144bit数据输出：DMAC[47:0] + SMAC[47:0] + VLAN_TAG[31:0] + EtherType[15:0]
assign o_mac_cross_port_axi_data          = r_mac_cross_port_axi_data    ;
assign o_mac_cross_axi_data_valid         = r_mac_cross_axi_data_valid   ;

//---------- 时序逻辑 ----------
// 输入信号打拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        ri_dmac_data    <= 48'd0;
        ri_smac_data    <= 48'd0;
        ri_vlan_id      <= 12'd0;
        ri_vlan_pri     <= 3'd0;
        ri_ethertyper   <= 16'd0;
        ri_info_vld     <= 1'b0;
    end
    else begin
        ri_dmac_data    <= i_dmac_data;
        ri_smac_data    <= i_smac_data;
        ri_vlan_id      <= i_vlan_id;
        ri_vlan_pri     <= i_vlan_pri;
        ri_ethertyper   <= i_ethertyper;
        ri_info_vld     <= i_info_vld;
    end
end

// 144bit数据拼接输出：DMAC[47:0] + SMAC[47:0] + VLAN_TAG[31:0] + EtherType[15:0]
// VLAN标签格式：0x8100 + priority[2:0] + CFI(0) + VID[11:0]
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_mac_cross_port_axi_data <= 144'd0;
    end
    else begin
        r_mac_cross_port_axi_data <= (ri_info_vld == 1'b1) ?
                                     {ri_dmac_data[47:0], ri_smac_data[47:0], 16'h8100, ri_vlan_pri[2:0], 1'b0, ri_vlan_id[11:0], ri_ethertyper[15:0]} :
                                     144'd0;
    end
end

// 输出数据有效信号 - 延迟1拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_mac_cross_axi_data_valid <= 1'b0;
    end
    else begin
        r_mac_cross_axi_data_valid <= (ri_info_vld == 1'b1) ? 1'b1 : 1'b0;
    end
end

endmodule 