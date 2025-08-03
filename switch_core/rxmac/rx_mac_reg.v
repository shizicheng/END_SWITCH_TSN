module rx_port_reg#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16         // 接收 MAC 层的配置寄存器数据位宽
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
`ifdef CPU_MAC
    output              wire   [15:0]                           o_hash_ploy_regs_0                  , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_0              , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_0                   ,
    output              wire                                    o_port_rxmac_down_regs_0            , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_0        , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_0        , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_0         , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_0                   , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_0               , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_0                   , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_0           , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_0          , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_0  , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_0                     , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_0                , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_0                , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_0                , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_0              , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_0                , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_0                 , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_0               , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_0           , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_0                  , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_0           , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_0           , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_0               , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_0         , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_0          , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_0          , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_0                 , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_0                ,  // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_0                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_0                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_0             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_0                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_0                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_0                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_0                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_0                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_0                        , // 帧序号
    
`endif
`ifdef MAC1
    output              wire   [15:0]                           o_hash_ploy_regs_1                  , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_1              , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_1                   ,
    output              wire                                    o_port_rxmac_down_regs_1            , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_1        , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_1        , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_1         , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_1                   , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_1               , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_1                   , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_1           , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_1          , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_1  , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_1                     , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_1                , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_1                , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_1                , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_1              , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_1                , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_1                 , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_1               , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_1           , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_1                  , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_1           , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_1           , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_1               , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_1         , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_1          , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_1          , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_1                 , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_1                , // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_1                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_1                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_1             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_1                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_1                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_1                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_1                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_1                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_1                        , // 帧序号
    
`endif
`ifdef MAC2
    output              wire   [15:0]                           o_hash_ploy_regs_2                  , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_2              , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_2                   ,
    output              wire                                    o_port_rxmac_down_regs_2            , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_2        , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_2        , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_2         , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_2                   , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_2               , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_2                   , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_2           , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_2          , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_2  , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_2                     , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_2                , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_2                , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_2                , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_2              , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_2                , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_2                 , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_2               , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_2           , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_2                  , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_2           , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_2           , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_2               , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_2         , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_2          , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_2          , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_2                 , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_2                ,  // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_2                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_2                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_2             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_2                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_2                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_2                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_2                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_2                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_2                        , // 帧序号
    
`endif
`ifdef MAC3
    output              wire   [15:0]                           o_hash_ploy_regs_3                 , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_3             , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_3                  ,
    output              wire                                    o_port_rxmac_down_regs_3           , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_3       , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_3       , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_3        , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_3                  , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_3              , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_3                  , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_3          , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_3         , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_3 , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_3                    , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_3               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_3               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_3               , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_3             , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_3               , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_3                , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_3              , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_3          , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_3                 , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_3          , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_3          , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_3              , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_3        , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_3         , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_3         , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_3                , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_3               ,  // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_3                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_3                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_3             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_3                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_3                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_3                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_3                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_3                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_3                        , // 帧序号
    
`endif
`ifdef MAC4
    output              wire   [15:0]                           o_hash_ploy_regs_4                 , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_4             , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_4                  ,
    output              wire                                    o_port_rxmac_down_regs_4           , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_4       , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_4       , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_4        , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_4                  , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_4              , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_4                  , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_4          , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_4         , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_4 , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_4                    , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_4               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_4               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_4               , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_4             , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_4               , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_4                , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_4              , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_4          , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_4                 , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_4          , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_4          , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_4              , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_4        , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_4         , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_4         , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_4                , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_4               ,  // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_4                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_4                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_4             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_4                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_4                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_4                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_4                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_4                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_4                        , // 帧序号
    
`endif
`ifdef MAC5
    output              wire   [15:0]                           o_hash_ploy_regs_5                 , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_5             , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_5                  ,
    output              wire                                    o_port_rxmac_down_regs_5           , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_5       , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_5       , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_5        , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_5                  , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_5              , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_5                  , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_5          , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_5         , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_5 , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_5                    , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_5               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_5               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_5               , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_5             , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_5               , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_5                , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_5              , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_5          , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_5                 , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_5          , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_5          , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_5              , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_5        , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_5         , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_5         , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_5                , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_5               ,  // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_5                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_5                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_5             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_5                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_5                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_5                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_5                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_5                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_5                        , // 帧序号
    
`endif
`ifdef MAC6
    output              wire   [15:0]                           o_hash_ploy_regs_6                 , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_6             , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_6                  ,
    output              wire                                    o_port_rxmac_down_regs_6           , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_6       , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_6       , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_6        , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_6                  , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_6              , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_6                  , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_6          , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_6         , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_6 , // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_6                    , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_6               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_6               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_6               , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_6             , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_6               , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_6                , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_6              , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_6          , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_6                 , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_6          , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_6          , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_6              , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_6        , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_6         , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_6         , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_6                , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_6               ,  // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_6                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_6                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_6             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_6                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_6                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_6                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_6                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_6                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_6                        , // 帧序号
    
`endif
`ifdef MAC7
    output              wire   [15:0]                           o_hash_ploy_regs_7                , // 哈希多项式
    output              wire   [15:0]                           o_hash_init_val_regs_7            , // 哈希多项式初始值
    output              wire                                    o_hash_regs_vld_7                 ,
    output              wire                                    o_port_rxmac_down_regs_7          , // 端口接收方向MAC关闭使能
    output              wire                                    o_port_broadcast_drop_regs_7      , // 端口广播帧丢弃使能
    output              wire                                    o_port_multicast_drop_regs_7      , // 端口组播帧丢弃使能
    output              wire                                    o_port_loopback_drop_regs_7       , // 端口环回帧丢弃使能
    output              wire   [47:0]                           o_port_mac_regs_7                 , // 端口的 MAC 地址
    output              wire                                    o_port_mac_vld_regs_7             , // 使能端口 MAC 地址有效
    output              wire   [7:0]                            o_port_mtu_regs_7                 , // MTU配置值
    output              wire   [PORT_NUM-1:0]                   o_port_mirror_frwd_regs_7         , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    output              wire   [15:0]                           o_port_flowctrl_cfg_regs_7        , // 限流管理配置
    output              wire   [4:0]                            o_port_rx_ultrashortinterval_num_7, // 帧间隔
    // ACL 寄存
    output              wire   [PORT_NUM-1:0]                   o_acl_port_sel_7                   , // 选择要配置的端口
    output              wire                                    o_acl_clr_list_regs_7              , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_7              , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_7              , // 配置条目选择
    output              wire   [5:0]                            o_acl_item_waddr_regs_7            , // 每个条目最大支持比对 64 字节
    output              wire   [7:0]                            o_acl_item_din_regs_7              , // 需要比较的字节数据
    output              wire                                    o_acl_item_we_regs_7               , // 配置使能信号
    output              wire   [15:0]                           o_acl_item_rslt_regs_7             , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    output              wire                                    o_acl_item_complete_regs_7         , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_7                , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_7         , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_7         , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_7             , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_7       , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_7        , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_7        , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    input              wire  [15:0]                             i_port_rx_byte_cnt_7               , // 端口0接收字节个数计数器值
    input              wire  [15:0]                             i_port_rx_frame_cnt_7              , // 端口0接收帧个数计数器值  

    //qbu_rx寄存器  
    input              wire                                     i_rx_busy_7                          , // 接收忙信号
    input              wire  [15:0]                             i_rx_fragment_cnt_7                  , // 接收分片计数
    input              wire                                     i_rx_fragment_mismatch_7             , // 分片不匹配
    input              wire  [15:0]                             i_err_rx_crc_cnt_7                   , // CRC错误计数
    input              wire  [15:0]                             i_err_rx_frame_cnt_7                 , // 帧错误计数
    input              wire  [15:0]                             i_err_fragment_cnt_7                 , // 分片错误计数
    input              wire  [15:0]                             i_rx_frames_cnt_7                    , // 接收帧计数
    input              wire  [7:0]                              i_frag_next_rx_7                     , // 下一个分片号
    input              wire  [7:0]                              i_frame_seq_7                        , // 帧序号
    
`endif
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    output              wire                                    o_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    output              wire                                    o_switch_err_cnt_clr                , // 刷新错误计数器
    output              wire                                    o_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    output             wire                                     o_switch_reg_bus_we                 , // 寄存器写使能
    output             wire   [REG_ADDR_BUS_WIDTH-1:0]          o_switch_reg_bus_we_addr            , // 寄存器写地址
    output             wire   [REG_DATA_BUS_WIDTH-1:0]          o_switch_reg_bus_we_din             , // 寄存器写数据
    output             wire                                     o_switch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口     
    output             wire                                     o_switch_reg_bus_rd                 , // 寄存器读使能
    output             wire   [REG_ADDR_BUS_WIDTH-1:0]          o_switch_reg_bus_rd_addr            , // 寄存器读地址
    input              wire   [REG_DATA_BUS_WIDTH-1:0]          i_switch_reg_bus_rd_dout            , // 读出寄存器数据
    input              wire                                     i_switch_reg_bus_rd_dout_v           // 读数据有效使能
);



endmodule