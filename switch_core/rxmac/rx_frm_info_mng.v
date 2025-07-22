module rx_frm_info_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                             ,   // 250MHz
    input               wire                                    i_rst                             ,
    /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
    input              wire                                    i_mac_port_link                    , // 端口的连接状态
    input              wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]             i_mac_port_axi_data                , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input              wire                                    i_mac_axi_data_valid               , // 端口数据有效
    output             wire                                    o_mac_axi_data_ready               , // 交叉总线聚合架构反压流水线信号
    input              wire                                    i_mac_axi_data_last                , // 数据流结束标识
    /* 单 PORT 部分信息流（此模块无法解析出所有的信息，例如[26:19](8bit) : 输入端口，bitmap表示，[51:44](8bit) : acl_frmtype，[43:28](16bit): acl_fetchinfo）*/
    output             wire                                    o_port_speed                       , // [63](1bit) : port_speed 
    output             wire   [2:0]                            o_vlan_pri                         , // [62:60](3bit) : vlan_pri 
    output             wire                                    o_frm_vlan_flag                    , // [27](1bit) : frm_vlan_flag
    output             wire   [PORT_NUM-1:0]                   o_rx_port                          , // [26:19](8bit) : 输入端口，bitmap表示
    output             wire   [1:0]                            o_frm_cb_op                        , // [14:13](2bit) : 冗余复制与消除(cb)，01表示复制，10表示消除，00表示非CB业务帧  
    output             wire                                    o_frm_qbu                          , // [11](1bit) : 是否为关键帧(Qbu)                                               
    /*-------------------------- 内部处理所需的信息流，不作为 metadata 的信息流 ----------------------------*/ 
    // 提取哈希计算需要的输入值
    output             wire   [7:0]                            o_dmac_data                        , // 目的 MAC 地址的值
    output             wire                                    o_damac_data_vld                   , // 数据有效值
    output             wire                                    o_dmac_soc                         ,
    output             wire                                    o_dmac_eoc                         ,
    output             wire   [7:0]                            o_smac_data                        , // 源 MAC 地址的值
    output             wire                                    o_samac_data_vld                   , // 数据有效值
    output             wire                                    o_smac_soc                         ,
    output             wire                                    o_smac_eoc                         ,          
    // 提取转发控制模块需要的信息
    output             wire                                    o_frm_info_vld                     , // 帧信息有效
    output             wire                                    o_broadcast_frm_en                 , // 广播帧
    output             wire                                    o_multicast_frm_en                 , // 组播帧
    output             wire                                    o_lookback_frm_en                    // 环回帧                
    /*
        metadata 数据组成
        [63](1bit) : port_speed 
        [62:60](3bit) : vlan_pri 
        [59:52](8bit) : tx_prot
        [51:44](8bit) : acl_frmtype
        [43:28](16bit): acl_fetchinfo
        [27](1bit) : frm_vlan_flag
        [26:19](8bit) : 输入端口，bitmap表示
        [18:15](4bit) : Qos策略
        [14:13](2bit) : 冗余复制与消除(cb)，01表示复制，10表示消除，00表示非CB业务帧
        [12](1bit) : 丢弃位
        [11](1bit) : 是否为关键帧(Qbu)
        [10:0] ：保留位
    */
   
);



endmodule