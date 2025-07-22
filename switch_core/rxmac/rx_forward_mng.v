module rx_froward_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    /*---------------------------------------- 控制转发相关的寄存器 -------------------------------------------*/
    input              wire                                     i_port_rxmac_down_regs             , // 端口接收方向MAC关闭使能
    input              wire                                     i_port_broadcast_drop_regs         , // 端口广播帧丢弃使能
    input              wire                                     i_port_multicast_drop_regs         , // 端口组播帧丢弃使能
    input              wire                                     i_port_loopback_drop_regs          , // 端口环回帧丢弃使能
    input              wire   [47:0]                            i_port_mac_regs                    , // 端口的 MAC 地址
    input              wire                                     i_port_mac_vld_regs                , // 使能端口 MAC 地址有效
    input              wire   [7:0]                             i_port_mtu_regs                    , // MTU配置值
    input              wire   [PORT_NUM-1:0]                    i_port_mirror_frwd_regs            , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    input              wire   [15:0]                            i_port_flowctrl_cfg_regs           , // 限流管理配置                                                                        
    input              wire   [4:0]                             i_port_rx_ultrashortinterval_num   , // 帧间隔                                                                          
    /*---------------------------------------- rx_frm_info_mng输出的信息流 -------------------------------------------*/
    input              wire                                    i_port_speed                       , // [63](1bit) : port_speed 
    input              wire   [2:0]                            i_vlan_pri                         , // [62:60](3bit) : vlan_pri 
    input              wire                                    i_frm_vlan_flag                    , // [27](1bit) : frm_vlan_flag
    input              wire   [PORT_NUM-1:0]                   i_rx_port                          , // [26:19](8bit) : 输入端口，bitmap表示
    input              wire   [1:0]                            i_frm_cb_op                        , // [14:13](2bit) : 冗余复制与消除(cb)，01表示复制，10表示消除，00表示非CB业务帧  
    input              wire                                    i_frm_qbu                          , // [11](1bit) : 是否为关键帧(Qbu)
    // 内部信息处理使用，不作为metadata字段
    input              wire                                    i_frm_info_vld                     , // 帧信息有效 
    input              wire                                    i_broadcast_frm_en                 , // 广播帧 
    input              wire                                    i_multicast_frm_en                 , // 组播帧 
    input              wire                                    i_lookback_frm_en                  , // 环回帧  
    /*---------------------------------------- 查表模块根据哈希值返回的计算结果 ----------------------------------*/
    input              wire    [PORT_NUM-1:0]                  i_swlist_tx_port                   , // 发送端口信息   
    input              wire                                    i_swlist_vld                       , // 有效使能信号       
    /*---------------------------------------- ACL 匹配后输出的字段 -------------------------------------------*/
    output             wire                                    i_acl_vld                          , // acl匹配表的有效输出信号
    output             wire                                    i_acl_find_match                   , // 是否匹配到正确的条目
    output             wire   [7:0]                            i_acl_frmtype                      , // 匹配出来的帧类型
    output             wire   [15:0]                           i_acl_fetch_info                   ,  // 待定保留 
    /*---------------------------------------- 单 PORT 聚合数据流输入 -------------------------------------------*/
    input              wire                                    i_mac_port_link                    , // 端口的连接状态
    input              wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]             i_mac_port_axi_data                , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input              wire                                    i_mac_axi_data_valid               , // 端口数据有效
    output             wire                                    o_mac_axi_data_ready               , // 交叉总线聚合架构反压流水线信号
    input              wire                                    i_mac_axi_data_last                , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合数据流输出 -------------------------------------------*/
    output             wire                                    o_mac_port_link                    , // 端口的连接状态
    output             wire   [1:0]                            o_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output             wire   [CROSS_DATA_WIDTH:0]             o_mac_port_axi_data                , // 端口数据流，最高位表示crcerr
    output             wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output             wire                                    o_mac_axi_data_valid               , // 端口数据有效
    input              wire                                    i_mac_axi_data_ready               , // 交叉总线聚合架构反压流水线信号
    output             wire                                    o_mac_axi_data_last                , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]             o_cross_metadata                   , // 聚合总线 metadata 数据
    output             wire                                    o_cross_metadata_valid             , // 聚合总线 metadata 数据有效信号
    output             wire                                    o_cross_metadata_last              , // 信息流结束标识
    input              wire                                    i_cross_metadata_ready             , // 下游模块反压流水线 
    /*---------------------------------------- 诊断寄存器 -------------------------------------------*/
    output             wire                                    o_port_rx_ultrashort_frm           , // 端口接收超短帧(小于64字节)
    output             wire                                    o_port_rx_overlength_frm           , // 端口接收超长帧(大于MTU字节)
    output             wire                                    o_port_rx_crcerr_frm               , // 端口接收CRC错误帧
    output             wire  [15:0]                            o_port_rx_loopback_frm_cnt         , // 端口接收环回帧计数器值
    output             wire  [15:0]                            o_port_broadflow_drop_cnt          , // 端口接收到广播限流而丢弃的帧计数器值
    output             wire  [15:0]                            o_port_multiflow_drop_cnt          , // 端口接收到组播限流而丢弃的帧计数器值
    output             wire  [15:0]                            o_port_diag_state                    // 端口状态寄存器，详情见寄存器表说明定义 
);



endmodule