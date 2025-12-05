`define CPU_MAC
`define MAC1
`define MAC2
`define MAC3
`define MAC4
`define MAC5
`define MAC6
`define MAC7
module rx_mac_reg#(
    parameter                                                   PORT_NUM                =      8        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      32         // 接收 MAC 层的配置寄存器数据位宽
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
    // ACL 寄存器
    output              wire   [5:0]                   			o_acl_port_sel_0                     , // 选择要配置的端口
	output				wire									o_acl_port_sel_0_valid				 ,
    output              wire                                    o_acl_clr_list_regs_0                , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_0                , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_0                , // 配置条目选择

    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_a1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_a1_valid      , // 写入有效信号
																
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_a2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_a2_valid      , // 写入有效信号
																
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_a3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_a3_valid      , // 写入有效信号
																
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_a4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_a4_valid      , // 写入有效信号
																
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_a5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_a5_valid      , // 写入有效信号
																
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_a6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_a6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_a1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_a1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_a2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_a2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_a3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_a3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_a4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_a4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_a5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_a5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_a6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_a6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_a1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_a1_valid      , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_a2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_a2_valid      , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_a3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_a3_valid      , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_a4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_a4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_a1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_a1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_a2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_a2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_a      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_a_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_a , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_a_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_a        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_a_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_a          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_a_valid    , // 写入有效信号

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
    output             wire                                     o_reset_0                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_1                     , // 选择要配置的端口
	output				wire									o_acl_port_sel_1_valid				 ,
    output              wire                                    o_acl_clr_list_regs_1                , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_1                , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_1                , // 配置条目选择

    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_b1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_b1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_b2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_b2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_b3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_b3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_b4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_b4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_b5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_b5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_b6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_b6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_b1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_b1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_b2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_b2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_b3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_b3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_b4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_b4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_b5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_b5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_b6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_b6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_b1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_b1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_b2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_b2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_b3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_b3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_b4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_b4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_b1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_b1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_b2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_b2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_b      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_b_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_b , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_b_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_b        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_b_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_b          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_b_valid    , // 写入有效信号




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
    output             wire                                     o_reset_1                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_2                     , // 选择要配置的端口
	output				wire									o_acl_port_sel_2_valid				 ,
    output              wire                                    o_acl_clr_list_regs_2                , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_2                , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_2                , // 配置条目选择
    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_c1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_c1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_c2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_c2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_c3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_c3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_c4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_c4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_c5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_c5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_c6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_c6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_c1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_c1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_c2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_c2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_c3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_c3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_c4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_c4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_c5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_c5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_c6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_c6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_c1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_c1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_c2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_c2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_c3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_c3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_c4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_c4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_c1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_c1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_c2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_c2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_c      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_c_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_c , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_c_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_c        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_c_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_c          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_c_valid    , // 写入有效信号

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
    output             wire                                     o_reset_2                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_3                    , // 选择要配置的端口
	output				wire									o_acl_port_sel_3_valid				 ,
    output              wire                                    o_acl_clr_list_regs_3               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_3               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_3               , // 配置条目选择
    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_d1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_d1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_d2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_d2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_d3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_d3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_d4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_d4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_d5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_d5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_d6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_d6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_d1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_d1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_d2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_d2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_d3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_d3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_d4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_d4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_d5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_d5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_d6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_d6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_d1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_d1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_d2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_d2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_d3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_d3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_d4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_d4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_d1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_d1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_d2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_d2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_d      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_d_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_d , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_d_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_d        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_d_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_d          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_d_valid    , // 写入有效信号

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
    output             wire                                     o_reset_3                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_4                    , // 选择要配置的端口
	output				wire									o_acl_port_sel_4_valid				 ,
    output              wire                                    o_acl_clr_list_regs_4               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_4               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_4               , // 配置条目选择
    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_e1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_e1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_e2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_e2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_e3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_e3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_e4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_e4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_e5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_e5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_e6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_e6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_e1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_e1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_e2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_e2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_e3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_e3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_e4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_e4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_e5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_e5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_e6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_e6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_e1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_e1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_e2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_e2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_e3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_e3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_e4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_e4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_e1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_e1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_e2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_e2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_e      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_e_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_e , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_e_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_e        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_e_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_e          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_e_valid    , // 写入有效信号



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
    output             wire                                     o_reset_4                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_5                    , // 选择要配置的端口
	output				wire									o_acl_port_sel_5_valid				 ,
    output              wire                                    o_acl_clr_list_regs_5               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_5               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_5               , // 配置条目选择
    
	// DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_f1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_f1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_f2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_f2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_f3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_f3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_f4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_f4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_f5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_f5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_f6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_f6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_f1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_f1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_f2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_f2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_f3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_f3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_f4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_f4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_f5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_f5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_f6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_f6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_f1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_f1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_f2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_f2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_f3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_f3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_f4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_f4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_f1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_f1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_f2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_f2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_f      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_f_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_f , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_f_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_f        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_f_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_f          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_f_valid    , // 写入有效信号


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
    output             wire                                     o_reset_5                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_6                    , // 选择要配置的端口
	output				wire									o_acl_port_sel_6_valid			    ,
    output              wire                                    o_acl_clr_list_regs_6               , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_6               , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_6               , // 配置条目选择
    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_g1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_g1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_g2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_g2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_g3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_g3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_g4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_g4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_g5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_g5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_g6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_g6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_g1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_g1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_g2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_g2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_g3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_g3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_g4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_g4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_g5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_g5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_g6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_g6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_g1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_g1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_g2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_g2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_g3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_g3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_g4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_g4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_g1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_g1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_g2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_g2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_g      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_g_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_g , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_g_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_g        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_g_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_g          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_g_valid    , // 写入有效信号



    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_6                 , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_6          , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_6          , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_6              , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_6        , // 端口接收环回帧计数器?
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_6         , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_6         , // 端口接收到组播限流而丢弃的帧计数器?
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
    output             wire                                     o_reset_6                            ,
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
    output              wire   [5:0]                   			o_acl_port_sel_7                   , // 选择要配置的端口
	output				wire									o_acl_port_sel_7_valid			   ,
    output              wire                                    o_acl_clr_list_regs_7              , // 清空寄存器列表
    input               wire                                    i_acl_list_rdy_regs_7              , // 配置寄存器操作空闲
    output              wire   [4:0]                            o_acl_item_sel_regs_7              , // 配置条目选择
    // DMAC编码值配置（6个16位字段）
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_h1            , // 端口ACL表项-写入dmac值[15:0]
    output    			wire                             		o_cfg_acl_item_dmac_code_h1_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_h2            , // 端口ACL表项-写入dmac值[31:16]
    output    			wire                             		o_cfg_acl_item_dmac_code_h2_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_h3            , // 端口ACL表项-写入dmac值[47:32]
    output    			wire                             		o_cfg_acl_item_dmac_code_h3_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_h4            , // 端口ACL表项-写入dmac值[63:48]
    output    			wire                             		o_cfg_acl_item_dmac_code_h4_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_h5            , // 端口ACL表项-写入dmac值[79:64]
    output    			wire                             		o_cfg_acl_item_dmac_code_h5_valid      , // 写入有效信号
																						 
    output    			wire [15:0]                      		o_cfg_acl_item_dmac_code_h6            , // 端口ACL表项-写入dmac值[95:80]
    output    			wire                             		o_cfg_acl_item_dmac_code_h6_valid      , // 写入有效信号
	
    // SMAC编码值配置（6个16位字段）	
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_h1            , // 端口ACL表项-写入smac值[15:0]
    output     			wire                             		o_cfg_acl_item_smac_code_h1_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_h2            , // 端口ACL表项-写入smac值[31:16]
    output     			wire                             		o_cfg_acl_item_smac_code_h2_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_h3            , // 端口ACL表项-写入smac值[47:32]
    output     			wire                             		o_cfg_acl_item_smac_code_h3_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_h4            , // 端口ACL表项-写入smac值[63:48]
    output     			wire                             		o_cfg_acl_item_smac_code_h4_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_h5            , // 端口ACL表项-写入smac值[79:64]
    output     			wire                             		o_cfg_acl_item_smac_code_h5_valid      , // 写入有效信号
																	                     
    output     			wire [15:0]                      		o_cfg_acl_item_smac_code_h6            , // 端口ACL表项-写入smac值[95:80]
    output     			wire                             		o_cfg_acl_item_smac_code_h6_valid      , // 写入有效信号
	
    // VLAN编码值配置（4个16位字段）	
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_h1            , // 端口ACL表项-写入vlan值[15:0]
    output    			wire                              		o_cfg_acl_item_vlan_code_h1_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_h2            , // 端口ACL表项-写入vlan值[31:16]
    output    			wire                              		o_cfg_acl_item_vlan_code_h2_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_h3            , // 端口ACL表项-写入vlan值[47:32]
    output    			wire                              		o_cfg_acl_item_vlan_code_h3_valid      , // 写入有效信号
																	                     
    output    			wire [15:0]                       		o_cfg_acl_item_vlan_code_h4            , // 端口ACL表项-写入vlan值[63:48]
    output    			wire                              		o_cfg_acl_item_vlan_code_h4_valid      , // 写入有效信号
														
    // Ethertype编码值配置（2个16位字段）           		
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_h1       , // 端口ACL表项-写入ethertype值[15:0]
    output    			wire                              		o_cfg_acl_item_ethertype_code_h1_valid , // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_ethertype_code_h2       , // 端口ACL表项-写入ethertype值[31:16]
    output    			wire                              		o_cfg_acl_item_ethertype_code_h2_valid , // 写入有效信号
														                                      
    // ACL动作配置                               		                                          
    output    			wire [7:0]                        		o_cfg_acl_item_action_pass_state_h      , // 端口ACL动作-报文状态
    output    			wire                              		o_cfg_acl_item_action_pass_state_h_valid, // 写入有效信号
																	                          
    output    			wire [15:0]                       		o_cfg_acl_item_action_cb_streamhandle_h , // 端口ACL动作-stream_handle值
    output    			wire                              		o_cfg_acl_item_action_cb_streamhandle_h_valid, // 写入有效信号
																	
    output    			wire [5:0]                        		o_cfg_acl_item_action_flowctrl_h        , // 端口ACL动作-报文流控选择
    output    			wire                              		o_cfg_acl_item_action_flowctrl_h_valid  , // 写入有效信号
																	
    output    			wire [15:0]                       		o_cfg_acl_item_action_txport_h          , // 端口ACL动作-报文发送端口映射
    output    			wire                              		o_cfg_acl_item_action_txport_h_valid    , // 写入有效信号



    // 状态寄存器
    input              wire   [15:0]                            i_port_diag_state_7                , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    input              wire                                     i_port_rx_ultrashort_frm_7         , // 端口接收超短帧(小于64字节)
    input              wire                                     i_port_rx_overlength_frm_7         , // 端口接收超长帧(大于MTU字节)
    input              wire                                     i_port_rx_crcerr_frm_7             , // 端口接收CRC错误帧
    input              wire  [15:0]                             i_port_rx_loopback_frm_cnt_7       , // 端口接收环回帧计数器值
    input              wire  [15:0]                             i_port_broadflow_drop_cnt_7        , // 端口接收到广播限流而丢弃的帧计数器值
    input              wire  [15:0]                             i_port_multiflow_drop_cnt_7        , // 端口接收到组播限流而丢弃的帧计数器?
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
    output             wire                                     o_reset_7                            ,
`endif
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    input              wire                                     i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input              wire                                     i_switch_err_cnt_clr                , // 刷新错误计数器
    input              wire                                     i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    input              wire                                     i_switch_reg_bus_we                 , // 寄存器写使能
    input              wire   [REG_ADDR_BUS_WIDTH-1:0]          i_switch_reg_bus_we_addr            , // 寄存器写地址
    input              wire   [REG_DATA_BUS_WIDTH-1:0]          i_switch_reg_bus_we_din             , // 寄存器写数据
    input              wire                                     i_switch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口     
    input              wire                                     i_switch_reg_bus_rd                 , // 寄存器读使能
    input              wire   [REG_ADDR_BUS_WIDTH-1:0]          i_switch_reg_bus_rd_addr            , // 寄存器读地址
    output             wire   [REG_DATA_BUS_WIDTH-1:0]          o_switch_reg_bus_rd_dout            , // 读出寄存器数据
    output             wire                                     o_switch_reg_bus_rd_dout_v           // 读数据有效使能
);

/*---------------------------------------- RXMAC寄存器地址定义 -------------------------------------------*/
localparam  REG_HASH_PLOY                   		=   8'h00                   ;
localparam  REG_HASH_INIT_VAL               		=   8'h01                   ;
localparam  REG_PORT_RXMAC_DOWN            	 		=   8'h02                   ;
localparam  REG_PORT_ACL_ENABLE             		=	8'h03					;
localparam  REG_PORT_BROADCAST_DROP         		=   8'h04					;
localparam  REG_PORT_MULTICAST_DROP                 =   8'h05					;
localparam  REG_PORT_LOOKBACK_DROP                  =   8'h06					;
localparam  REG_PORT_FORCE_RECAL_CRC                =   8'h07					;
localparam  REG_PORT_FLOODFRM_DROP                  =   8'h08					;
localparam  REG_PORT_MULTIFLOOD_DROP                =   8'h09					;
localparam  REG_CFG_RXMAC_PORT_SEL                  =   8'h10					;
localparam  REG_PORTMTU                             =   8'h11					;
localparam  REG_PORTMAC0                            =   8'h12					;
localparam  REG_PORTMAC1                            =   8'h13					;
localparam  REG_PORTMAC2                            =   8'h14					;
localparam  REG_PORTMAC_VALID                       =   8'h15					;
localparam  REG_PORT_MIRROR_FRWD                    =   8'h16					;
localparam  REG_PORT_FLOWCTRL_CFG                   =   8'h17					;
localparam  REG_CFG_ACL_PORT_SEL                    =   8'h20					;
localparam  REG_CFG_ACL_CLR_LIST                    =   8'h21					;
localparam  REG_CFG_ACL_LIST_RDY                    =   8'h22					;
localparam  REG_CFG_ACL_ITEM_SEL                    =   8'h23					;
localparam  REG_CFG_ACL_ITEM_DMAC_CODE_1            =   8'h24					;
localparam  REG_CFG_ACL_ITEM_DMAC_CODE_2            =   8'h25					;
localparam  REG_CFG_ACL_ITEM_DMAC_CODE_3            =   8'h26					;
localparam  REG_CFG_ACL_ITEM_DMAC_CODE_4            =   8'h27					;
localparam  REG_CFG_ACL_ITEM_DMAC_CODE_5            =   8'h28					;
localparam  REG_CFG_ACL_ITEM_DMAC_CODE_6            =   8'h29					;
localparam  REG_CFG_ACL_ITEM_SMAC_CODE_1            =   8'h2A					;
localparam  REG_CFG_ACL_ITEM_SMAC_CODE_2            =   8'h2B					;
localparam  REG_CFG_ACL_ITEM_SMAC_CODE_3            =   8'h2C					;
localparam  REG_CFG_ACL_ITEM_SMAC_CODE_4            =   8'h2D					;
localparam  REG_CFG_ACL_ITEM_SMAC_CODE_5            =   8'h2E					;
localparam  REG_CFG_ACL_ITEM_SMAC_CODE_6            =   8'h2F					;
localparam  REG_CFG_ACL_ITEM_VLAN_CODE_1            =   8'h30					;
localparam  REG_CFG_ACL_ITEM_VLAN_CODE_2            =   8'h31					;
localparam  REG_CFG_ACL_ITEM_VLAN_CODE_3            =   8'h32					;
localparam  REG_CFG_ACL_ITEM_VLAN_CODE_4            =   8'h33					;
localparam  REG_CFG_ACL_ITEM_ETHTYPE_CODE_1         =   8'h34					;
localparam  REG_CFG_ACL_ITEM_ETHTYPE_CODE_2         =   8'h35					;
localparam  REG_CFG_ACL_ITEM_ACTION_PASS_STATE      =   8'h36					;
localparam  REG_CFG_ACL_ITEM_ACTION_CB_STREAMHANDLE =   8'h37					;
localparam  REG_CFG_ACL_ITEM_ACTION_FLOWCTRL		=   8'h38					;
localparam  REG_CFG_ACL_ITEM_ACTION_TXPORT			=   8'h39					;																
localparam  REG_PORT_RX_BYTE_CNT_0					=   8'h50					;
localparam  REG_PORT_RX_FRAME_CNT_0                 =   8'h51					;
localparam  REG_PORT_DIAG_STATE_0                   =   8'h52					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_0        =   8'h53					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_0        =   8'h54					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_0            =   8'h55					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_0          =   8'h56					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_0            =   8'h57					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_0           =   8'h58					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_0           =   8'h59					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_0           =   8'h5A					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_0         =   8'h5B					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_0       =   8'h5C					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_0    =   8'h5D					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_0        =   8'h5E					;
localparam  REG_PORT_RX_BYTE_CNT_1					=   8'h60					;
localparam  REG_PORT_RX_FRAME_CNT_1                 =   8'h61					;
localparam  REG_PORT_DIAG_STATE_1                   =   8'h62					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_1        =   8'h63					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_1        =   8'h64					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_1            =   8'h65					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_1          =   8'h66					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_1            =   8'h67					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_1           =   8'h68					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_1           =   8'h69					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_1           =   8'h6A					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_1         =   8'h6B					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_1       =   8'h6C					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_1    =   8'h6D					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_1        =   8'h6E					;
localparam  REG_PORT_RX_BYTE_CNT_2					=   8'h70					;
localparam  REG_PORT_RX_FRAME_CNT_2                 =   8'h71					;
localparam  REG_PORT_DIAG_STATE_2                   =   8'h72					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_2        =   8'h73					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_2        =   8'h74					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_2            =   8'h75					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_2          =   8'h76					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_2            =   8'h77					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_2           =   8'h78					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_2           =   8'h79					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_2           =   8'h7A					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_2         =   8'h7B					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_2       =   8'h7C					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_2    =   8'h7D					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_2        =   8'h7E					;
localparam  REG_PORT_RX_BYTE_CNT_3					=   8'h80					;
localparam  REG_PORT_RX_FRAME_CNT_3                 =   8'h81					;
localparam  REG_PORT_DIAG_STATE_3                   =   8'h82					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_3        =   8'h83					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_3        =   8'h84					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_3            =   8'h85					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_3          =   8'h86					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_3            =   8'h87					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_3           =   8'h88					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_3           =   8'h89					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_3           =   8'h8A					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_3         =   8'h8B					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_3       =   8'h8C					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_3    =   8'h8D					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_3        =   8'h8E					;
localparam  REG_PORT_RX_BYTE_CNT_4					=   8'h90					;
localparam  REG_PORT_RX_FRAME_CNT_4                 =   8'h91					;
localparam  REG_PORT_DIAG_STATE_4                   =   8'h92					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_4        =   8'h93					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_4        =   8'h94					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_4            =   8'h95					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_4          =   8'h96					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_4            =   8'h97					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_4           =   8'h98					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_4           =   8'h99					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_4           =   8'h9A					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_4         =   8'h9B					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_4       =   8'h9C					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_4    =   8'h9D					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_4        =   8'h9E					;    
localparam  REG_PORT_RX_BYTE_CNT_5					=   8'hA0					;
localparam  REG_PORT_RX_FRAME_CNT_5                 =   8'hA1					;
localparam  REG_PORT_DIAG_STATE_5                   =   8'hA2					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_5        =   8'hA3					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_5        =   8'hA4					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_5            =   8'hA5					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_5          =   8'hA6					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_5            =   8'hA7					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_5           =   8'hA8					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_5           =   8'hA9					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_5           =   8'hAA					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_5         =   8'hAB					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_5       =   8'hAC					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_5    =   8'hAD					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_5        =   8'hAE					;
localparam  REG_PORT_RX_BYTE_CNT_6					=   8'hB0					;
localparam  REG_PORT_RX_FRAME_CNT_6                 =   8'hB1					;
localparam  REG_PORT_DIAG_STATE_6                   =   8'hB2					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_6        =   8'hB3					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_6        =   8'hB4					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_6            =   8'hB5					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_6          =   8'hB6					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_6            =   8'hB7					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_6           =   8'hB8					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_6           =   8'hB9					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_6           =   8'hBA					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_6         =   8'hBB					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_6       =   8'hBC					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_6    =   8'hBD					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_6        =   8'hBE					;
localparam  REG_PORT_RX_BYTE_CNT_7					=   8'hC0					;
localparam  REG_PORT_RX_FRAME_CNT_7                 =   8'hC1					;
localparam  REG_PORT_DIAG_STATE_7                   =   8'hC2					;
localparam  REG_PORT_RX_ULTRASHORT_FRM_CNT_7        =   8'hC3					;
localparam  REG_PORT_RX_OVERLENGTH_FRM_CNT_7        =   8'hC4					;
localparam  REG_PORT_RX_CRCERR_FRM_CNT_7            =   8'hC5					;
localparam  REG_PORT_RX_LOOKBACK_FRM_CNT_7          =   8'hC6					;
localparam  REG_PORT_RX_ERROR_DROP_CNT_7            =   8'hC7					;
localparam  REG_PORT_BROADFLOW_DROP_CNT_7           =   8'hC8					;
localparam  REG_PORT_MULTIFLOW_DROP_CNT_7           =   8'hC9					;
localparam  REG_PORT_FLOODFLOW_DROP_CNT_7           =   8'hCA					;
localparam  REG_PORT_RX_OVERPREMB_FRM_CNT_7         =   8'hCB					;
localparam  REG_PORT_RX_ULTRASHORTPREMB_NUM_7       =   8'hCC					;
localparam  REG_PORT_RX_ULTRASHORTINTERVAL_NUM_7    =   8'hCD					;
localparam  REG_PORT_RX_ERRORPREMB_FRM_CNT_7        =   8'hCE					;
/*---------------------------------------- QBU_RX寄存器地址定义 -------------------------------------------*/
//端口1
localparam  REG_QBU_RESET_0                         =   9'hD0                   ;
localparam  REG_RX_FRAGMENT_CNT_0                   =   9'hD1                   ;
localparam  REG_RX_FRAGMENT_MISMATCH_0              =   9'hD2                   ;
localparam  REG_ERR_RX_CRC_CNT_0                    =   9'hD3                   ;
localparam  REG_ERR_RX_FRAME_CNT_0                  =   9'hD4                   ;
localparam  REG_ERR_FRAGMENT_CNT_0                  =   9'hD5                   ;
localparam  REG_ERR_VERIFI_CNT_0                    =   9'hD6                   ;
localparam  REG_RX_FRAMES_CNT_0                     =   9'hD7                   ;
localparam  REG_FRAG_NEXT_RX_0                      =   9'hD8                   ;
localparam  REG_FRAME_SEQ_0                         =   9'hD9                   ;
//端口2
localparam  REG_QBU_RESET_1                         =   9'hDA                   ;
localparam  REG_RX_FRAGMENT_CNT_1                   =   9'hDB                   ;
localparam  REG_RX_FRAGMENT_MISMATCH_1              =   9'hDC                   ;
localparam  REG_ERR_RX_CRC_CNT_1                    =   9'hDD                   ;
localparam  REG_ERR_RX_FRAME_CNT_1                  =   9'hDE                   ;
localparam  REG_ERR_FRAGMENT_CNT_1                  =   9'hDF                   ;
localparam  REG_ERR_VERIFI_CNT_1                    =   9'hE0                   ;
localparam  REG_RX_FRAMES_CNT_1                     =   9'hE1                   ;
localparam  REG_FRAG_NEXT_RX_1                      =   9'hE2                   ;
localparam  REG_FRAME_SEQ_1                         =   9'hE3                   ;
//端口3
localparam  REG_QBU_RESET_2                         =   9'hE4                   ;
localparam  REG_RX_FRAGMENT_CNT_2                   =   9'hE5                   ;
localparam  REG_RX_FRAGMENT_MISMATCH_2              =   9'hE6                   ;
localparam  REG_ERR_RX_CRC_CNT_2                    =   9'hE7                   ;
localparam  REG_ERR_RX_FRAME_CNT_2                  =   9'hE8                   ;
localparam  REG_ERR_FRAGMENT_CNT_2                  =   9'hE9                   ;
localparam  REG_ERR_VERIFI_CNT_2                    =   9'hEA                   ;
localparam  REG_RX_FRAMES_CNT_2                     =   9'hEB                   ;
localparam  REG_FRAG_NEXT_RX_2                      =   9'hEC                   ;
localparam  REG_FRAME_SEQ_2                         =   9'hED                   ;
//端口4
localparam  REG_QBU_RESET_3                         =   9'hEE                   ;
localparam  REG_RX_FRAGMENT_CNT_3                   =   9'hEF                   ;
localparam  REG_RX_FRAGMENT_MISMATCH_3              =   9'hF0                   ;
localparam  REG_ERR_RX_CRC_CNT_3                    =   9'hF1                   ;
localparam  REG_ERR_RX_FRAME_CNT_3                  =   9'hF2                   ;
localparam  REG_ERR_FRAGMENT_CNT_3                  =   9'hF3                   ;
localparam  REG_ERR_VERIFI_CNT_3                    =   9'hF4                   ;
localparam  REG_RX_FRAMES_CNT_3                     =   9'hF5                   ;
localparam  REG_FRAG_NEXT_RX_3                      =   9'hF6                   ;
localparam  REG_FRAME_SEQ_3                         =   9'hF7                   ;
//端口5
localparam  REG_QBU_RESET_4                         =   9'hF8                   ;
localparam  REG_RX_FRAGMENT_CNT_4                   =   9'hF9                   ;
localparam  REG_RX_FRAGMENT_MISMATCH_4              =   9'hFA                   ;
localparam  REG_ERR_RX_CRC_CNT_4                    =   9'hFB                   ;
localparam  REG_ERR_RX_FRAME_CNT_4                  =   9'hFC                   ;
localparam  REG_ERR_FRAGMENT_CNT_4                  =   9'hFD                   ;
localparam  REG_ERR_VERIFI_CNT_4                    =   9'hFE                   ;
localparam  REG_RX_FRAMES_CNT_4                     =   9'hFF                   ;
localparam  REG_FRAG_NEXT_RX_4                      =   9'h100                  ;
localparam  REG_FRAME_SEQ_4                         =   9'h101                  ;
//端口6
localparam  REG_QBU_RESET_5                         =   9'h102                  ;
localparam  REG_RX_FRAGMENT_CNT_5                   =   9'h103                  ;
localparam  REG_RX_FRAGMENT_MISMATCH_5              =   9'h104                  ;
localparam  REG_ERR_RX_CRC_CNT_5                    =   9'h105                  ;
localparam  REG_ERR_RX_FRAME_CNT_5                  =   9'h106                  ;
localparam  REG_ERR_FRAGMENT_CNT_5                  =   9'h107                  ;
localparam  REG_ERR_VERIFI_CNT_5                    =   9'h108                  ;
localparam  REG_RX_FRAMES_CNT_5                     =   9'h109                  ;
localparam  REG_FRAG_NEXT_RX_5                      =   9'h10A                  ;
localparam  REG_FRAME_SEQ_5                         =   9'h10B                  ;
//端口7
localparam  REG_QBU_RESET_6                         =   9'h10C                  ;
localparam  REG_RX_FRAGMENT_CNT_6                   =   9'h10D                  ;
localparam  REG_RX_FRAGMENT_MISMATCH_6              =   9'h10E                  ;
localparam  REG_ERR_RX_CRC_CNT_6                    =   9'h10F                  ;
localparam  REG_ERR_RX_FRAME_CNT_6                  =   9'h110                  ;
localparam  REG_ERR_FRAGMENT_CNT_6                  =   9'h111                  ;
localparam  REG_ERR_VERIFI_CNT_6                    =   9'h112                  ;
localparam  REG_RX_FRAMES_CNT_6                     =   9'h113                  ;
localparam  REG_FRAG_NEXT_RX_6                      =   9'h114                  ;
localparam  REG_FRAME_SEQ_6                         =   9'h115                  ;
//端口8
localparam  REG_QBU_RESET_7                         =   9'h116                  ;
localparam  REG_RX_FRAGMENT_CNT_7                   =   9'h117                  ;
localparam  REG_RX_FRAGMENT_MISMATCH_7              =   9'h118                  ;
localparam  REG_ERR_RX_CRC_CNT_7                    =   9'h119                  ;
localparam  REG_ERR_RX_FRAME_CNT_7                  =   9'h11A                  ;
localparam  REG_ERR_FRAGMENT_CNT_7                  =   9'h11B                  ;
localparam  REG_ERR_VERIFI_CNT_7                    =   9'h11C                  ;
localparam  REG_RX_FRAMES_CNT_7                     =   9'h11D                  ;
localparam  REG_FRAG_NEXT_RX_7                      =   9'h11E                  ;
localparam  REG_FRAME_SEQ_7                         =   9'h11F                  ;

/*------------------------------------------- 内部信号定义 -----------------------------------------------*/
// 寄存器刷新控制信号  
reg                                         r_refresh_list_pulse                ; // 刷新寄存器列表（状态寄存器和控制寄存器）
reg                                         r_switch_err_cnt_clr                ; // 刷新错误计数器
reg                                         r_switch_err_cnt_stat               ; // 刷新错误状态寄存器
/*------------------------------------------- 寄存器信号定义 ------------------------------------------*/
// 寄存器写控制信号  
reg                                         r_reg_bus_we                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_addr                      ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_data                      ;
reg                                         r_reg_bus_data_vld                  ;
// 寄存器读控制信号
reg                                         r_reg_bus_re                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_raddr                     ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_rdata                     ;
reg                                         r_reg_bus_rdata_vld                 ;
/*========================================  RXMAC寄存器读写控制信号管理 ========================================*/
// 通用寄存器
reg   [15:0]                           r_hash_ploy_regs                  ;// 哈希多项式
reg   [15:0]                           r_hash_init_val_regs              ;// 哈希多项式初始值
reg                                    r_hash_regs_vld                   ;
reg   [7:0]                            r_port_rxmac_down_regs            ;// 端口接收方向MAC关闭使能
reg   [7:0]                            r_port_broadcast_drop_regs        ;// 端口广播帧丢弃使能
reg   [7:0]                            r_port_multicast_drop_regs        ;// 端口组播帧丢弃使能
reg   [7:0]                            r_port_loopback_drop_regs         ;// 端口环回帧丢弃使能
reg   [7:0]                            r_port_force_recal_crc_regs       ;// 端口强制重新计算CRC使能 
reg   [7:0]                            r_port_floodfrm_drop_regs         ;// 端口泛洪帧丢弃使能   
reg   [7:0]                            r_port_multiflood_drop_regs       ;// 端口多播帧丢弃使能 
reg   [7:0]                            r_port_acl_enable_regs                 ;// 端口 ACL 使能  


reg   [2:0]                            r_cfg_rxmac_port_sel              ;// 端口选择
reg   [47:0]                           r_port_mac_regs                   ;// 端口1的 MAC 地址
reg                                    r_port_mac_vld_regs               ;// 使能端口 MAC 地址有效
reg   [10:0]                           r_port_mtu_regs                   ;// MTU配置值
reg   [PORT_NUM-1:0]                   r_port_mirror_frwd_regs           ;// 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
reg   [15:0]                           r_port_flowctrl_cfg_regs          ;// 限流管理配置
reg   [4:0]                            r_port_rx_ultrashortinterval_num_0;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_1;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_2;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_3;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_4;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_5;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_6;// 帧间隔
reg   [4:0]                            r_port_rx_ultrashortinterval_num_7;// 帧间隔
/*========================================  ACL寄存器信号定义 ========================================*/

reg   [5:0]                            r_acl_port_sel                      ; // 选择要配置的端口
reg									   r_acl_port_sel_valid				   ;
reg                                    r_acl_clr_list_regs                 ; // 清空寄存器列表
reg   [4:0]                            r_acl_item_sel_regs                 ; // 配置条目选择
wire  [7:0]                            w_acl_list_rdy_regs                 ;

reg   [15:0]                           r_acl_item_dmac_code_1              ;
reg	  								   r_acl_item_dmac_code_1_valid 	   ;
reg   [15:0]                           r_acl_item_dmac_code_2              ;
reg	  								   r_acl_item_dmac_code_2_valid 	   ;
reg   [15:0]                           r_acl_item_dmac_code_3              ;
reg	  								   r_acl_item_dmac_code_3_valid 	   ;
reg   [15:0]                           r_acl_item_dmac_code_4              ;
reg	  								   r_acl_item_dmac_code_4_valid 	   ;
reg   [15:0]                           r_acl_item_dmac_code_5              ;
reg	  								   r_acl_item_dmac_code_5_valid 	   ;
reg   [15:0]                           r_acl_item_dmac_code_6              ;
reg	  								   r_acl_item_dmac_code_6_valid 	   ;

reg   [15:0]                           r_acl_item_smac_code_1              ;
reg	  								   r_acl_item_smac_code_1_valid 	   ;
reg   [15:0]                           r_acl_item_smac_code_2              ;
reg	  								   r_acl_item_smac_code_2_valid 	   ;
reg   [15:0]                           r_acl_item_smac_code_3              ;
reg	  								   r_acl_item_smac_code_3_valid 	   ;
reg   [15:0]                           r_acl_item_smac_code_4              ;
reg	  								   r_acl_item_smac_code_4_valid 	   ;
reg   [15:0]                           r_acl_item_smac_code_5              ;
reg	  								   r_acl_item_smac_code_5_valid 	   ;
reg   [15:0]                           r_acl_item_smac_code_6              ;
reg	  								   r_acl_item_smac_code_6_valid 	   ;

reg   [15:0]                           r_acl_item_vlan_code_1              ;
reg	  								   r_acl_item_vlan_code_1_valid 	   ;
reg   [15:0]                           r_acl_item_vlan_code_2              ;
reg	  								   r_acl_item_vlan_code_2_valid 	   ;
reg   [15:0]                           r_acl_item_vlan_code_3              ;
reg	  								   r_acl_item_vlan_code_3_valid 	   ;
reg   [15:0]                           r_acl_item_vlan_code_4              ;
reg	  								   r_acl_item_vlan_code_4_valid 	   ;


reg   [15:0]                           r_acl_item_ethtype_code_1           ;
reg	  								   r_acl_item_ethtype_code_1_valid 	   ;
reg   [15:0]                           r_acl_item_ethtype_code_2           ;
reg	  								   r_acl_item_ethtype_code_2_valid 	   ;

reg   [7:0]                            r_acl_item_action_pass_state        ;
reg									   r_acl_item_action_pass_state_valid  ;
reg   [15:0]                           r_acl_item_action_cb_streamhandle   ;
reg                                    r_acl_item_action_cb_streamhandle_valid;
reg   [5:0]                            r_acl_item_action_flowctrl          ;
reg   	                               r_acl_item_action_flowctrl_valid    ;
reg   [15:0]                           r_acl_item_action_txport            ;
reg   		                           r_acl_item_action_txport_valid      ;
/*--------------------------------------- Qbu_rx寄存器信号定义 ----------------------------------------*/
// 端口0
reg                                    r_reset_0                           ;
reg                                    r_reset_1                           ;
reg                                    r_reset_2                           ;
reg                                    r_reset_3                           ;
reg                                    r_reset_4                           ;
reg                                    r_reset_5                           ;
reg                                    r_reset_6                           ;
reg                                    r_reset_7                           ;

/*========================================  通用寄存器控制信号管理 ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_refresh_list_pulse        <= 1'b0;
        r_switch_err_cnt_clr        <= 1'b0;
        r_switch_err_cnt_stat       <= 1'b0;
    end else begin
        r_refresh_list_pulse        <= i_refresh_list_pulse;
        r_switch_err_cnt_clr        <= i_switch_err_cnt_clr;
        r_switch_err_cnt_stat       <= i_switch_err_cnt_stat;
    end
end
/*========================================  寄存器读写控制信号管理 ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_we          <= 1'b0;
        r_reg_bus_addr        <= {REG_ADDR_BUS_WIDTH{1'b0}};
        r_reg_bus_data        <= {REG_DATA_BUS_WIDTH{1'b0}};
        r_reg_bus_data_vld    <= 1'b0;
        r_reg_bus_re          <= 1'b0;
        r_reg_bus_raddr       <= {REG_ADDR_BUS_WIDTH{1'b0}};
    end else begin
        r_reg_bus_we          <= i_switch_reg_bus_we;
        r_reg_bus_addr        <= i_switch_reg_bus_we_addr;
        r_reg_bus_data        <= i_switch_reg_bus_we_din;
        r_reg_bus_data_vld    <= i_switch_reg_bus_we_din_v;
        r_reg_bus_re          <= i_switch_reg_bus_rd;
        r_reg_bus_raddr       <= i_switch_reg_bus_rd_addr;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_hash_ploy_regs <= 16'h180F;
        r_hash_init_val_regs <= 16'hFFFF;
        r_hash_regs_vld <= 1'b0;
        r_port_rxmac_down_regs <= 8'hFF;
        r_port_acl_enable_regs <= 8'hFF;
        r_port_broadcast_drop_regs <= 8'b0;
        r_port_multicast_drop_regs <= 8'b0;
        r_port_loopback_drop_regs <= 8'hFF;
        r_port_force_recal_crc_regs <= 8'b0;
        r_port_floodfrm_drop_regs <= 8'b1;
        r_port_multiflood_drop_regs <= 8'b0;
        r_cfg_rxmac_port_sel <= 3'b0;
        r_port_mac_regs <= 48'b0;
        r_port_mac_vld_regs <= 1'b0;
        r_port_mtu_regs <= 11'd1600;
        r_port_mirror_frwd_regs <= 8'b0;
        r_port_flowctrl_cfg_regs <= 16'b0;
        //r_port_rx_ultrashortinterval_num <= 5'd31;
    end else begin
        r_hash_ploy_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_HASH_PLOY ? r_reg_bus_data[15:0] : r_hash_ploy_regs;
        r_hash_init_val_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_HASH_INIT_VAL ? r_reg_bus_data[15:0] : r_hash_init_val_regs;
        r_hash_regs_vld <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_HASH_INIT_VAL ? 1'b1 : 1'b0;
        r_port_rxmac_down_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RXMAC_DOWN ? r_reg_bus_data[7:0] : r_port_rxmac_down_regs;
        r_port_broadcast_drop_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_BROADCAST_DROP ? r_reg_bus_data[7:0] : r_port_broadcast_drop_regs;
        r_port_multicast_drop_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_MULTICAST_DROP ? r_reg_bus_data[7:0] : r_port_multicast_drop_regs;
        r_port_loopback_drop_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_LOOKBACK_DROP ? r_reg_bus_data[7:0] : r_port_loopback_drop_regs;
        r_port_force_recal_crc_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_FORCE_RECAL_CRC ? r_reg_bus_data[7:0] : r_port_force_recal_crc_regs;
        r_port_floodfrm_drop_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_FLOODFRM_DROP ? r_reg_bus_data[7:0] : r_port_floodfrm_drop_regs;
        r_port_multiflood_drop_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_MULTIFLOOD_DROP ? r_reg_bus_data[7:0] : r_port_multiflood_drop_regs;
        r_cfg_rxmac_port_sel <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_RXMAC_PORT_SEL ? r_reg_bus_data[2:0] : r_cfg_rxmac_port_sel;
        r_port_mac_regs[47:32] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORTMAC0 ? r_reg_bus_data[15:0] : r_port_mac_regs[47:32];
        r_port_mac_regs[31:16] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORTMAC1 ? r_reg_bus_data[15:0] : r_port_mac_regs[31:16];
        r_port_mac_regs[15:0] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORTMAC2 ? r_reg_bus_data[15:0] : r_port_mac_regs[15:0];
        r_port_mac_vld_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORTMAC_VALID ? r_reg_bus_data[0] : r_port_mac_vld_regs;
        r_port_mtu_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORTMTU ? r_reg_bus_data[10:0] : r_port_mtu_regs;
        r_port_mirror_frwd_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_MIRROR_FRWD ? r_reg_bus_data[7:0] : r_port_mirror_frwd_regs;
        r_port_flowctrl_cfg_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_FLOWCTRL_CFG ? r_reg_bus_data[15:0] : r_port_flowctrl_cfg_regs;
        //r_port_rx_ultrashortinterval_num <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num;
        r_port_acl_enable_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_ACL_ENABLE ? r_reg_bus_data[7:0] : r_port_acl_enable_regs;
    end
end
// 端口1
assign o_hash_ploy_regs_0 = r_hash_ploy_regs;
assign o_hash_init_val_regs_0 = r_hash_init_val_regs;
assign o_hash_regs_vld_0 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_0 = r_port_rxmac_down_regs[0];
assign o_port_broadcast_drop_regs_0 = r_port_broadcast_drop_regs[0];
assign o_port_multicast_drop_regs_0 = r_port_multicast_drop_regs[0];
assign o_port_loopback_drop_regs_0 = r_port_loopback_drop_regs[0];
assign o_port_mac_regs_0 = r_cfg_rxmac_port_sel == 3'b000 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_0 = r_cfg_rxmac_port_sel == 3'b000 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_0 = r_cfg_rxmac_port_sel == 3'b000 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_0 = r_cfg_rxmac_port_sel == 3'b000 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_0 = r_cfg_rxmac_port_sel == 3'b000 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_0 = r_cfg_rxmac_port_sel == 3'b000 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口2
assign o_hash_ploy_regs_1 = r_hash_ploy_regs;
assign o_hash_init_val_regs_1 = r_hash_init_val_regs;
assign o_hash_regs_vld_1 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_1 = r_port_rxmac_down_regs[1];
assign o_port_broadcast_drop_regs_1 = r_port_broadcast_drop_regs[1];
assign o_port_multicast_drop_regs_1 = r_port_multicast_drop_regs[1];
assign o_port_loopback_drop_regs_1 = r_port_loopback_drop_regs[1];
assign o_port_mac_regs_1 = r_cfg_rxmac_port_sel == 3'b001 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_1 = r_cfg_rxmac_port_sel == 3'b001 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_1 = r_cfg_rxmac_port_sel == 3'b001 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_1 = r_cfg_rxmac_port_sel == 3'b001 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_1 = r_cfg_rxmac_port_sel == 3'b001 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_1 = r_cfg_rxmac_port_sel == 3'b001 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口3
assign o_hash_ploy_regs_2 = r_hash_ploy_regs;
assign o_hash_init_val_regs_2 = r_hash_init_val_regs;
assign o_hash_regs_vld_2 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_2 = r_port_rxmac_down_regs[2];
assign o_port_broadcast_drop_regs_2 = r_port_broadcast_drop_regs[2];
assign o_port_multicast_drop_regs_2 = r_port_multicast_drop_regs[2];
assign o_port_loopback_drop_regs_2 = r_port_loopback_drop_regs[2];
assign o_port_mac_regs_2 = r_cfg_rxmac_port_sel == 3'b010 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_2 = r_cfg_rxmac_port_sel == 3'b010 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_2 = r_cfg_rxmac_port_sel == 3'b010 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_2 = r_cfg_rxmac_port_sel == 3'b010 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_2 = r_cfg_rxmac_port_sel == 3'b010 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_2 = r_cfg_rxmac_port_sel == 3'b010 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口4
assign o_hash_ploy_regs_3 = r_hash_ploy_regs;
assign o_hash_init_val_regs_3 = r_hash_init_val_regs;
assign o_hash_regs_vld_3 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_3 = r_port_rxmac_down_regs[3];
assign o_port_broadcast_drop_regs_3 = r_port_broadcast_drop_regs[3];
assign o_port_multicast_drop_regs_3 = r_port_multicast_drop_regs[3];
assign o_port_loopback_drop_regs_3 = r_port_loopback_drop_regs[3];
assign o_port_mac_regs_3 = r_cfg_rxmac_port_sel == 3'b011 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_3 = r_cfg_rxmac_port_sel == 3'b011 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_3 = r_cfg_rxmac_port_sel == 3'b011 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_3 = r_cfg_rxmac_port_sel == 3'b011 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_3 = r_cfg_rxmac_port_sel == 3'b011 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_3 = r_cfg_rxmac_port_sel == 3'b011 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口5
assign o_hash_ploy_regs_4 = r_hash_ploy_regs;
assign o_hash_init_val_regs_4 = r_hash_init_val_regs;
assign o_hash_regs_vld_4 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_4 = r_port_rxmac_down_regs[4];
assign o_port_broadcast_drop_regs_4 = r_port_broadcast_drop_regs[4];
assign o_port_multicast_drop_regs_4 = r_port_multicast_drop_regs[4];
assign o_port_loopback_drop_regs_4 = r_port_loopback_drop_regs[4];
assign o_port_mac_regs_4 = r_cfg_rxmac_port_sel == 3'b100 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_4 = r_cfg_rxmac_port_sel == 3'b100 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_4 = r_cfg_rxmac_port_sel == 3'b100 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_4 = r_cfg_rxmac_port_sel == 3'b100 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_4 = r_cfg_rxmac_port_sel == 3'b100 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_4 = r_cfg_rxmac_port_sel == 3'b100 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口6
assign o_hash_ploy_regs_5 = r_hash_ploy_regs;
assign o_hash_init_val_regs_5 = r_hash_init_val_regs;
assign o_hash_regs_vld_5 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_5 = r_port_rxmac_down_regs[5];
assign o_port_broadcast_drop_regs_5 = r_port_broadcast_drop_regs[5];
assign o_port_multicast_drop_regs_5 = r_port_multicast_drop_regs[5];
assign o_port_loopback_drop_regs_5 = r_port_loopback_drop_regs[5];
assign o_port_mac_regs_5 = r_cfg_rxmac_port_sel == 3'b101 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_5 = r_cfg_rxmac_port_sel == 3'b101 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_5 = r_cfg_rxmac_port_sel == 3'b101 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_5 = r_cfg_rxmac_port_sel == 3'b101 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_5 = r_cfg_rxmac_port_sel == 3'b101 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_5 = r_cfg_rxmac_port_sel == 3'b101 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口7
assign o_hash_ploy_regs_6 = r_hash_ploy_regs;
assign o_hash_init_val_regs_6 = r_hash_init_val_regs;
assign o_hash_regs_vld_6 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_6 = r_port_rxmac_down_regs[6];
assign o_port_broadcast_drop_regs_6 = r_port_broadcast_drop_regs[6];
assign o_port_multicast_drop_regs_6 = r_port_multicast_drop_regs[6];
assign o_port_loopback_drop_regs_6 = r_port_loopback_drop_regs[6];
assign o_port_mac_regs_6 = r_cfg_rxmac_port_sel == 3'b110 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_6 = r_cfg_rxmac_port_sel == 3'b110 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_6 = r_cfg_rxmac_port_sel == 3'b110 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_6 = r_cfg_rxmac_port_sel == 3'b110 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_6 = r_cfg_rxmac_port_sel == 3'b110 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_6 = r_cfg_rxmac_port_sel == 3'b110 ? r_port_rx_ultrashortinterval_num : 5'b0;

// 端口8
assign o_hash_ploy_regs_7 = r_hash_ploy_regs;
assign o_hash_init_val_regs_7 = r_hash_init_val_regs;
assign o_hash_regs_vld_7 = r_hash_regs_vld;
assign o_port_rxmac_down_regs_7 = r_port_rxmac_down_regs[7];
assign o_port_broadcast_drop_regs_7 = r_port_broadcast_drop_regs[7];
assign o_port_multicast_drop_regs_7 = r_port_multicast_drop_regs[7];
assign o_port_loopback_drop_regs_7 = r_port_loopback_drop_regs[7];
assign o_port_mac_regs_7 = r_cfg_rxmac_port_sel == 3'b111 ? r_port_mac_regs[47:0] : 48'b0;
assign o_port_mac_vld_regs_7 = r_cfg_rxmac_port_sel == 3'b111 ? r_port_mac_vld_regs : 1'b0;
assign o_port_mtu_regs_7 = r_cfg_rxmac_port_sel == 3'b111 ? r_port_mtu_regs : 8'b0;
assign o_port_mirror_frwd_regs_7 = r_cfg_rxmac_port_sel == 3'b111 ? r_port_mirror_frwd_regs : 8'b0;
assign o_port_flowctrl_cfg_regs_7 = r_cfg_rxmac_port_sel == 3'b111 ? r_port_flowctrl_cfg_regs : 16'b0;
//assign o_port_rx_ultrashortinterval_num_7 = r_cfg_rxmac_port_sel == 3'b111 ? r_port_rx_ultrashortinterval_num : 5'b0;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_rx_ultrashortinterval_num_0 <= 5'd31;
        r_port_rx_ultrashortinterval_num_1 <= 5'd31;
        r_port_rx_ultrashortinterval_num_2 <= 5'd31;
        r_port_rx_ultrashortinterval_num_3 <= 5'd31;
        r_port_rx_ultrashortinterval_num_4 <= 5'd31;
        r_port_rx_ultrashortinterval_num_5 <= 5'd31;
        r_port_rx_ultrashortinterval_num_6 <= 5'd31;
        r_port_rx_ultrashortinterval_num_7 <= 5'd31;
    end else begin
        r_port_rx_ultrashortinterval_num_0 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_0 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_0;
        r_port_rx_ultrashortinterval_num_1 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_1 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_1;
        r_port_rx_ultrashortinterval_num_2 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_2 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_2;
        r_port_rx_ultrashortinterval_num_3 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_3 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_3;
        r_port_rx_ultrashortinterval_num_4 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_4 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_4;
        r_port_rx_ultrashortinterval_num_5 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_5 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_5;
        r_port_rx_ultrashortinterval_num_6 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_6 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_6;
        r_port_rx_ultrashortinterval_num_7 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_RX_ULTRASHORTINTERVAL_NUM_7 ? r_reg_bus_data[4:0] : r_port_rx_ultrashortinterval_num_7;
    end
end

assign o_port_rx_ultrashortinterval_num_0 = r_port_rx_ultrashortinterval_num_0;
assign o_port_rx_ultrashortinterval_num_1 = r_port_rx_ultrashortinterval_num_1;
assign o_port_rx_ultrashortinterval_num_2 = r_port_rx_ultrashortinterval_num_2;
assign o_port_rx_ultrashortinterval_num_3 = r_port_rx_ultrashortinterval_num_3;
assign o_port_rx_ultrashortinterval_num_4 = r_port_rx_ultrashortinterval_num_4;
assign o_port_rx_ultrashortinterval_num_5 = r_port_rx_ultrashortinterval_num_5;
assign o_port_rx_ultrashortinterval_num_6 = r_port_rx_ultrashortinterval_num_6;
assign o_port_rx_ultrashortinterval_num_7 = r_port_rx_ultrashortinterval_num_7;

/*========================================  ACL寄存器写控制信号管理 ========================================*/

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_acl_port_sel <= 6'b0;
		r_acl_port_sel_valid <= 1'b0;
        r_acl_clr_list_regs <= 1'b0;
        r_acl_item_sel_regs <= 5'b0;
    end else begin
        r_acl_port_sel <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_PORT_SEL ? r_reg_bus_data[5:0] : r_acl_port_sel;
        r_acl_port_sel_valid <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_PORT_SEL ? 1'b1 : 1'b0;
		r_acl_clr_list_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_CLR_LIST ? r_reg_bus_data[0] : r_acl_clr_list_regs;
        r_acl_item_sel_regs <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SEL ? r_reg_bus_data[4:0] : r_acl_item_sel_regs;
    end
end

// ACL条目数据写控制
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_acl_item_dmac_code_1 			<= 16'b0;
		r_acl_item_dmac_code_1_valid 	<= 1'b0;
		r_acl_item_dmac_code_2      	<= 16'b0;
		r_acl_item_dmac_code_2_valid    <= 1'b0;
		r_acl_item_dmac_code_3      	<= 16'b0;
		r_acl_item_dmac_code_3_valid    <= 1'b0;
		r_acl_item_dmac_code_4      	<= 16'b0;
		r_acl_item_dmac_code_4_valid    <= 1'b0;
		r_acl_item_dmac_code_5      	<= 16'b0;
		r_acl_item_dmac_code_5_valid    <= 1'b0;
		r_acl_item_dmac_code_6      	<= 16'b0;
		r_acl_item_dmac_code_6_valid    <= 1'b0;
		
		r_acl_item_smac_code_1         <= 16'b0;
		r_acl_item_smac_code_1_valid   <= 1'b0;
		r_acl_item_smac_code_2         <= 16'b0;
		r_acl_item_smac_code_2_valid   <= 1'b0;
		r_acl_item_smac_code_3         <= 16'b0;
		r_acl_item_smac_code_3_valid   <= 1'b0;
		r_acl_item_smac_code_4         <= 16'b0;
		r_acl_item_smac_code_4_valid   <= 1'b0;
		r_acl_item_smac_code_5         <= 16'b0;
		r_acl_item_smac_code_5_valid   <= 1'b0;
		r_acl_item_smac_code_6         <= 16'b0;
		r_acl_item_smac_code_6_valid   <= 1'b0;
		
		r_acl_item_vlan_code_1         <= 16'b0;
		r_acl_item_vlan_code_1_valid   <= 1'b0;
		r_acl_item_vlan_code_2         <= 16'b0;
		r_acl_item_vlan_code_2_valid   <= 1'b0;
		r_acl_item_vlan_code_3         <= 16'b0;
		r_acl_item_vlan_code_3_valid   <= 1'b0;
		r_acl_item_vlan_code_4         <= 16'b0;
		r_acl_item_vlan_code_4_valid   <= 1'b0;
		                               
		                               
		r_acl_item_ethtype_code_1      <= 16'b0;
		r_acl_item_ethtype_code_1_valid<= 1'b0;
		r_acl_item_ethtype_code_2      <= 16'b0;
		r_acl_item_ethtype_code_2_valid<= 1'b0;
		
        r_acl_item_action_pass_state 			<= 8'b0;
		r_acl_item_action_pass_state_valid 		<= 1'b0;
		
        r_acl_item_action_cb_streamhandle 		<= 16'b0;
		r_acl_item_action_cb_streamhandle_valid <= 1'b0;
		
        r_acl_item_action_flowctrl 				<= 6'b0;
		r_acl_item_action_flowctrl_valid		<= 1'b0;
		
        r_acl_item_action_txport 				<= 16'b0;
		r_acl_item_action_txport_valid 			<= 1'b0;
    end else begin
        //if (r_reg_bus_we && r_reg_bus_data_vld) begin
        //    case (r_reg_bus_addr)
        //        REG_CFG_ACL_ITEM_DMAC_CODE_1: r_acl_item_dmac_code_1  <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_DMAC_CODE_2: r_acl_item_dmac_code[31:16] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_DMAC_CODE_3: r_acl_item_dmac_code[47:32] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_DMAC_CODE_4: r_acl_item_dmac_code[63:48] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_DMAC_CODE_5: r_acl_item_dmac_code[79:64] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_DMAC_CODE_6: r_acl_item_dmac_code[95:80] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_SMAC_CODE_1: r_acl_item_smac_code[15:0]  <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_SMAC_CODE_2: r_acl_item_smac_code[31:16] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_SMAC_CODE_3: r_acl_item_smac_code[47:32] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_SMAC_CODE_4: r_acl_item_smac_code[63:48] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_SMAC_CODE_5: r_acl_item_smac_code[79:64] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_SMAC_CODE_6: r_acl_item_smac_code[95:80] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_VLAN_CODE_1: r_acl_item_vlan_code[15:0]  <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_VLAN_CODE_2: r_acl_item_vlan_code[31:16] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_VLAN_CODE_3: r_acl_item_vlan_code[47:32] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_VLAN_CODE_4: r_acl_item_vlan_code[63:48] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_ETHTYPE_CODE_1: r_acl_item_ethtype_code[15:0] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_ETHTYPE_CODE_2: r_acl_item_ethtype_code[31:16] <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_ACTION_PASS_STATE: r_acl_item_action_pass_state <= r_reg_bus_data[5:0];
        //        REG_CFG_ACL_ITEM_ACTION_CB_STREAMHANDLE: r_acl_item_action_cb_streamhandle <= r_reg_bus_data[15:0];
        //        REG_CFG_ACL_ITEM_ACTION_FLOWCTRL: r_acl_item_action_flowctrl <= r_reg_bus_data[5:0];
        //        REG_CFG_ACL_ITEM_ACTION_TXPORT: r_acl_item_action_txport <= r_reg_bus_data[15:0];
        //    endcase
        //end
		r_acl_item_dmac_code_1 			<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_1 ? r_reg_bus_data[15:0] : r_acl_item_dmac_code_1;
		r_acl_item_dmac_code_1_valid 	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_1 ? 1'b1 : 1'b0;
		r_acl_item_dmac_code_2      	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_2 ? r_reg_bus_data[15:0] : r_acl_item_dmac_code_2;
		r_acl_item_dmac_code_2_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_2 ? 1'b1 : 1'b0;
		r_acl_item_dmac_code_3      	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_3 ? r_reg_bus_data[15:0] : r_acl_item_dmac_code_3;
		r_acl_item_dmac_code_3_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_3 ? 1'b1 : 1'b0;
		r_acl_item_dmac_code_4      	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_4 ? r_reg_bus_data[15:0] : r_acl_item_dmac_code_4;
		r_acl_item_dmac_code_4_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_4 ? 1'b1 : 1'b0;
		r_acl_item_dmac_code_5      	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_5 ? r_reg_bus_data[15:0] : r_acl_item_dmac_code_5;
		r_acl_item_dmac_code_5_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_5 ? 1'b1 : 1'b0;
		r_acl_item_dmac_code_6      	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_6 ? r_reg_bus_data[15:0] : r_acl_item_dmac_code_6;
		r_acl_item_dmac_code_6_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_DMAC_CODE_6 ? 1'b1 : 1'b0;
		
		r_acl_item_smac_code_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_1 ? r_reg_bus_data[15:0] : r_acl_item_smac_code_1;
		r_acl_item_smac_code_1_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_1 ? 1'b1 : 1'b0;
		r_acl_item_smac_code_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_2 ? r_reg_bus_data[15:0] : r_acl_item_smac_code_2;
		r_acl_item_smac_code_2_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_2 ? 1'b1 : 1'b0;
		r_acl_item_smac_code_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_3 ? r_reg_bus_data[15:0] : r_acl_item_smac_code_3;
		r_acl_item_smac_code_3_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_3 ? 1'b1 : 1'b0;
		r_acl_item_smac_code_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_4 ? r_reg_bus_data[15:0] : r_acl_item_smac_code_4;
		r_acl_item_smac_code_4_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_4 ? 1'b1 : 1'b0;
		r_acl_item_smac_code_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_5 ? r_reg_bus_data[15:0] : r_acl_item_smac_code_5;
		r_acl_item_smac_code_5_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_5 ? 1'b1 : 1'b0;
		r_acl_item_smac_code_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_6 ? r_reg_bus_data[15:0] : r_acl_item_smac_code_6;
		r_acl_item_smac_code_6_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_SMAC_CODE_6 ? 1'b1 : 1'b0;
		
		r_acl_item_vlan_code_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_1 ? r_reg_bus_data[15:0] : r_acl_item_vlan_code_1;
		r_acl_item_vlan_code_1_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_1 ? 1'b1 : 1'b0;
		r_acl_item_vlan_code_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_2 ? r_reg_bus_data[15:0] : r_acl_item_vlan_code_2;
		r_acl_item_vlan_code_2_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_2 ? 1'b1 : 1'b0;
		r_acl_item_vlan_code_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_3 ? r_reg_bus_data[15:0] : r_acl_item_vlan_code_3;
		r_acl_item_vlan_code_3_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_3 ? 1'b1 : 1'b0;
		r_acl_item_vlan_code_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_4 ? r_reg_bus_data[15:0] : r_acl_item_vlan_code_4;
		r_acl_item_vlan_code_4_valid    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_VLAN_CODE_4 ? 1'b1 : 1'b0;
		                               
		                               
		r_acl_item_ethtype_code_1       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_ETHTYPE_CODE_1 ? r_reg_bus_data[15:0] : r_acl_item_ethtype_code_1;
		r_acl_item_ethtype_code_1_valid <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_ETHTYPE_CODE_1 ? 1'b1 : 1'b0;
		r_acl_item_ethtype_code_2       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_ETHTYPE_CODE_2 ? r_reg_bus_data[15:0] : r_acl_item_ethtype_code_2;
		r_acl_item_ethtype_code_2_valid <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_ETHTYPE_CODE_2 ? 1'b1 : 1'b0;
		
		
		r_acl_item_action_pass_state 		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_PASS_STATE ? r_reg_bus_data[7:0] : r_acl_item_action_pass_state;
		r_acl_item_action_pass_state_valid 	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_PASS_STATE ? 1'b1 : 1'b0;
		
		r_acl_item_action_cb_streamhandle 	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_CB_STREAMHANDLE     ? r_reg_bus_data[15:0] : r_acl_item_action_cb_streamhandle;
		r_acl_item_action_cb_streamhandle_valid <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CFG_ACL_ITEM_ACTION_CB_STREAMHANDLE  ? 1'b1 : 1'b0;
		
		r_acl_item_action_flowctrl 	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_FLOWCTRL		 ? r_reg_bus_data[5:0] : r_acl_item_action_flowctrl;
		r_acl_item_action_flowctrl_valid	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_FLOWCTRL ? 1'b1 : 1'b0;
		
		r_acl_item_action_txport 	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_TXPORT	 ? r_reg_bus_data[15:0] : r_acl_item_action_txport;
		r_acl_item_action_txport_valid 	<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==	REG_CFG_ACL_ITEM_ACTION_TXPORT	 ? 1'b1 : 1'b0;
		
    end
end

// 端口1
assign o_acl_port_sel_0 = r_acl_port_sel;
assign o_acl_port_sel_0_valid = r_acl_port_sel_valid;
assign o_acl_clr_list_regs_0 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_0 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_a1 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_a1_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_a2 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_a2_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_a3 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_a3_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_a4 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_a4_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_a5 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_a5_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_a6 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_a6_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_a1 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_a1_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_a2 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_a2_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_a3 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_a3_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_a4 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_a4_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_a5 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_a5_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_a6 		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_a6_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_a1		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_a1_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_a2		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_a2_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_a3		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_a3_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_a4		 = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_a4_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_a1		  = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_a1_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_a2		  = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_a2_valid = r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_a	= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_a_valid= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_a= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_a_valid= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_a= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_a_valid= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_a= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_a_valid= r_acl_port_sel[2:0] == 3'b000 ? r_acl_item_action_txport_valid : 1'b0;

// 端口2
assign o_acl_port_sel_1 							= r_acl_port_sel;
assign o_acl_port_sel_1_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_1 = r_acl_port_sel[2:0] == 3'b001 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_1 = r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_b1 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_b1_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_b2 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_b2_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_b3 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_b3_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_b4 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_b4_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_b5 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_b5_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_b6 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_b6_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_b1 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_b1_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_b2 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_b2_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_b3 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_b3_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_b4 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_b4_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_b5 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_b5_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_b6 					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_b6_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_b1					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_b1_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_b2					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_b2_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_b3					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_b3_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_b4					= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_b4_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_b1		  		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_b1_valid 		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_b2		  		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_b2_valid 		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_b			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_b_valid		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_b		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_b_valid= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_b				= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_b_valid		= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_b				= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_b_valid			= r_acl_port_sel[2:0] == 3'b001 ? r_acl_item_action_txport_valid : 1'b0;

// 端口3
assign o_acl_port_sel_2 							= r_acl_port_sel;
assign o_acl_port_sel_2_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_2 = r_acl_port_sel[2:0] == 3'b010 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_2 = r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_c1 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_c1_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_c2 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_c2_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_c3 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_c3_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_c4 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_c4_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_c5 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_c5_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_c6 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_c6_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_c1 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_c1_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_c2 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_c2_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_c3 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_c3_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_c4 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_c4_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_c5 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_c5_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_c6 					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_c6_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_c1					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_c1_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_c2					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_c2_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_c3					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_c3_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_c4					= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_c4_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_c1		  		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_c1_valid 		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_c2		  		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_c2_valid 		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_c			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_c_valid		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_c		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_c_valid= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_c				= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_c_valid		= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_c				= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_c_valid			= r_acl_port_sel[2:0] == 3'b010 ? r_acl_item_action_txport_valid : 1'b0;
// 端口4
assign o_acl_port_sel_3 							= r_acl_port_sel;
assign o_acl_port_sel_3_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_3 = r_acl_port_sel[2:0] == 3'b011 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_3 = r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_d1 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_d1_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_d2 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_d2_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_d3 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_d3_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_d4 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_d4_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_d5 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_d5_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_d6 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_d6_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_d1 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_d1_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_d2 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_d2_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_d3 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_d3_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_d4 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_d4_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_d5 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_d5_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_d6 					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_d6_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_d1					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_d1_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_d2					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_d2_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_d3					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_d3_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_d4					= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_d4_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_d1		  		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_d1_valid 		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_d2		  		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_d2_valid 		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_d			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_d_valid		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_d		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_d_valid= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_d				= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_d_valid		= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_d				= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_d_valid			= r_acl_port_sel[2:0] == 3'b011 ? r_acl_item_action_txport_valid : 1'b0;

// 端口5
assign o_acl_port_sel_4 							= r_acl_port_sel;
assign o_acl_port_sel_4_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_4 = r_acl_port_sel[2:0] == 3'b100 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_4 = r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_e1 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_e1_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_e2 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_e2_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_e3 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_e3_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_e4 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_e4_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_e5 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_e5_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_e6 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_e6_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_e1 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_e1_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_e2 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_e2_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_e3 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_e3_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_e4 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_e4_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_e5 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_e5_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_e6 					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_e6_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_e1					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_e1_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_e2					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_e2_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_e3					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_e3_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_e4					= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_e4_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_e1		  		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_e1_valid 		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_e2		  		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_e2_valid 		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_e			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_e_valid		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_e		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_e_valid= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_e				= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_e_valid		= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_e				= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_e_valid			= r_acl_port_sel[2:0] == 3'b100 ? r_acl_item_action_txport_valid : 1'b0;

// 端口6
assign o_acl_port_sel_5 							= r_acl_port_sel;
assign o_acl_port_sel_5_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_5 = r_acl_port_sel[2:0] == 3'b101 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_5 = r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_f1 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_f1_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_f2 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_f2_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_f3 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_f3_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_f4 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_f4_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_f5 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_f5_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_f6 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_f6_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_f1 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_f1_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_f2 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_f2_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_f3 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_f3_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_f4 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_f4_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_f5 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_f5_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_f6 					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_f6_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_f1					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_f1_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_f2					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_f2_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_f3					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_f3_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_f4					= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_f4_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_f1		  		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_f1_valid 		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_f2		  		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_f2_valid 		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_f			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_f_valid		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_f		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_f_valid= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_f				= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_f_valid		= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_f				= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_f_valid			= r_acl_port_sel[2:0] == 3'b101 ? r_acl_item_action_txport_valid : 1'b0;

// 端口7
assign o_acl_port_sel_6 							= r_acl_port_sel;
assign o_acl_port_sel_6_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_6 = r_acl_port_sel[2:0] == 3'b110 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_6 = r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_g1 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_g1_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_g2 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_g2_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_g3 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_g3_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_g4 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_g4_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_g5 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_g5_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_g6 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_g6_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_g1 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_g1_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_g2 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_g2_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_g3 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_g3_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_g4 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_g4_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_g5 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_g5_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_g6 					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_g6_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_g1					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_g1_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_g2					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_g2_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_g3					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_g3_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_g4					= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_g4_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_g1		  		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_g1_valid 		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_g2		  		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_g2_valid 		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_g			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_g_valid		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_g		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_g_valid= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_g				= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_g_valid		= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_g				= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_g_valid			= r_acl_port_sel[2:0] == 3'b110 ? r_acl_item_action_txport_valid : 1'b0;

// 端口8
assign o_acl_port_sel_7 							= r_acl_port_sel;
assign o_acl_port_sel_7_valid 						= r_acl_port_sel_valid;
assign o_acl_clr_list_regs_7 = r_acl_port_sel[2:0] == 3'b111 ? r_acl_clr_list_regs : 1'b0;
assign o_acl_item_sel_regs_7 = r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_sel_regs : 5'b0;
assign o_cfg_acl_item_dmac_code_h1 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_1 : 16'h0000;
assign o_cfg_acl_item_dmac_code_h1_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_1_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_h2 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_2 : 16'h0000;
assign o_cfg_acl_item_dmac_code_h2_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_2_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_h3 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_3 : 16'h0000;
assign o_cfg_acl_item_dmac_code_h3_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_3_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_h4 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_4 : 16'h0000;
assign o_cfg_acl_item_dmac_code_h4_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_4_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_h5 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_5 : 16'h0000;
assign o_cfg_acl_item_dmac_code_h5_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_5_valid : 1'b0;
assign o_cfg_acl_item_dmac_code_h6 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_6 : 16'h0000;
assign o_cfg_acl_item_dmac_code_h6_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_dmac_code_6_valid : 1'b0;
assign o_cfg_acl_item_smac_code_h1 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_1 : 16'h0000;
assign o_cfg_acl_item_smac_code_h1_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_1_valid : 1'b0;
assign o_cfg_acl_item_smac_code_h2 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_2 : 16'h0000;
assign o_cfg_acl_item_smac_code_h2_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_2_valid : 1'b0;
assign o_cfg_acl_item_smac_code_h3 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_3 : 16'h0000;
assign o_cfg_acl_item_smac_code_h3_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_3_valid : 1'b0;
assign o_cfg_acl_item_smac_code_h4 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_4 : 16'h0000;
assign o_cfg_acl_item_smac_code_h4_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_4_valid : 1'b0;
assign o_cfg_acl_item_smac_code_h5 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_5 : 16'h0000;
assign o_cfg_acl_item_smac_code_h5_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_5_valid : 1'b0;
assign o_cfg_acl_item_smac_code_h6 					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_6 : 16'h0000;
assign o_cfg_acl_item_smac_code_h6_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_smac_code_6_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_h1					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_1 : 16'h0000;
assign o_cfg_acl_item_vlan_code_h1_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_1_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_h2					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_2 : 16'h0000;
assign o_cfg_acl_item_vlan_code_h2_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_2_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_h3					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_3 : 16'h0000;
assign o_cfg_acl_item_vlan_code_h3_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_3_valid : 1'b0;
assign o_cfg_acl_item_vlan_code_h4					= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_4 : 16'h0000;
assign o_cfg_acl_item_vlan_code_h4_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_vlan_code_4_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_h1		  		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_ethtype_code_1 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_h1_valid 		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_ethtype_code_1_valid : 1'b0;
assign o_cfg_acl_item_ethertype_code_h2		  		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_ethtype_code_2 : 16'h0000;
assign o_cfg_acl_item_ethertype_code_h2_valid 		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_ethtype_code_2_valid : 1'b0;
assign o_cfg_acl_item_action_pass_state_h			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_pass_state : 8'h00;	
assign o_cfg_acl_item_action_pass_state_h_valid		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_pass_state_valid : 1'b0;
assign o_cfg_acl_item_action_cb_streamhandle_h		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_cb_streamhandle : 16'h0000;
assign o_cfg_acl_item_action_cb_streamhandle_h_valid= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_cb_streamhandle_valid : 1'b0;
assign o_cfg_acl_item_action_flowctrl_h				= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_flowctrl : 6'h00;
assign o_cfg_acl_item_action_flowctrl_h_valid		= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_flowctrl_valid : 1'b0;
assign o_cfg_acl_item_action_txport_h				= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_txport : 16'h0000;
assign o_cfg_acl_item_action_txport_h_valid			= r_acl_port_sel[2:0] == 3'b111 ? r_acl_item_action_txport_valid : 1'b0;


/*========================================  qbu_rx寄存器写控制信号管理 ========================================*/

// QBU复位寄存器写控制 - 所有端口
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reset_0 <= 1'b0;
        r_reset_1 <= 1'b0;
        r_reset_2 <= 1'b0;
        r_reset_3 <= 1'b0;
        r_reset_4 <= 1'b0;
        r_reset_5 <= 1'b0;
        r_reset_6 <= 1'b0;
        r_reset_7 <= 1'b0;
    end else begin
        r_reset_0 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_0 ? r_reg_bus_data[0] : 1'b0;
        r_reset_1 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_1 ? r_reg_bus_data[0] : 1'b0;
        r_reset_2 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_2 ? r_reg_bus_data[0] : 1'b0;
        r_reset_3 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_3 ? r_reg_bus_data[0] : 1'b0;
        r_reset_4 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_4 ? r_reg_bus_data[0] : 1'b0;
        r_reset_5 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_5 ? r_reg_bus_data[0] : 1'b0;
        r_reset_6 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_6 ? r_reg_bus_data[0] : 1'b0;
        r_reset_7 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_7 ? r_reg_bus_data[0] : 1'b0;
    end
end

assign o_reset_0 = r_reset_0;
assign o_reset_1 = r_reset_1;
assign o_reset_2 = r_reset_2;
assign o_reset_3 = r_reset_3;
assign o_reset_4 = r_reset_4;
assign o_reset_5 = r_reset_5;
assign o_reset_6 = r_reset_6;
assign o_reset_7 = r_reset_7;

assign w_acl_list_rdy_regs = {i_acl_list_rdy_regs_7,i_acl_list_rdy_regs_6,i_acl_list_rdy_regs_5,i_acl_list_rdy_regs_4,
                              i_acl_list_rdy_regs_3,i_acl_list_rdy_regs_2,i_acl_list_rdy_regs_1,i_acl_list_rdy_regs_0};
/*========================================= 寄存器读控制逻辑 =========================================*/
// 寄存器读数据逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else if (r_reg_bus_re) begin
        case (r_reg_bus_raddr)
            // rxmac 通用
            REG_HASH_PLOY:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_hash_ploy_regs; 
            REG_HASH_INIT_VAL:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_hash_init_val_regs; 
            REG_PORT_RXMAC_DOWN:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_rxmac_down_regs; 
            REG_PORT_ACL_ENABLE:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_acl_enable_regs; 
            REG_PORT_BROADCAST_DROP:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_broadcast_drop_regs; 
            REG_PORT_MULTICAST_DROP:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_multicast_drop_regs; 
            REG_PORT_LOOKBACK_DROP:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_loopback_drop_regs; 
            REG_PORT_FORCE_RECAL_CRC:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_force_recal_crc_regs; 
            REG_PORT_FLOODFRM_DROP:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_floodfrm_drop_regs; 
            REG_PORT_MULTIFLOOD_DROP:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_multiflood_drop_regs; 
            REG_CFG_RXMAC_PORT_SEL:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cfg_rxmac_port_sel; 
            REG_PORTMTU:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_mtu_regs; 
            REG_PORTMAC0:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_mac_regs[47:32]; 
            REG_PORTMAC1:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_mac_regs[31:16];
            REG_PORTMAC2:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_mac_regs[15:0];
            REG_PORTMAC_VALID:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_mac_vld_regs;
            REG_PORT_MIRROR_FRWD:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_mirror_frwd_regs;
            REG_PORT_FLOWCTRL_CFG:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_flowctrl_cfg_regs;
            // acl寄存器
            REG_CFG_ACL_PORT_SEL:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_port_sel;
            REG_CFG_ACL_CLR_LIST:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_clr_list_regs;
            REG_CFG_ACL_LIST_RDY:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | w_acl_list_rdy_regs;
            REG_CFG_ACL_ITEM_SEL:  r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_sel_regs;
            REG_CFG_ACL_ITEM_DMAC_CODE_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_dmac_code_1;
            REG_CFG_ACL_ITEM_DMAC_CODE_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_dmac_code_2;
            REG_CFG_ACL_ITEM_DMAC_CODE_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_dmac_code_3;
            REG_CFG_ACL_ITEM_DMAC_CODE_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_dmac_code_4;
            REG_CFG_ACL_ITEM_DMAC_CODE_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_dmac_code_5;
            REG_CFG_ACL_ITEM_DMAC_CODE_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_dmac_code_6;
            REG_CFG_ACL_ITEM_SMAC_CODE_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_smac_code_1;
            REG_CFG_ACL_ITEM_SMAC_CODE_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_smac_code_2;
            REG_CFG_ACL_ITEM_SMAC_CODE_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_smac_code_3;
            REG_CFG_ACL_ITEM_SMAC_CODE_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_smac_code_4;
            REG_CFG_ACL_ITEM_SMAC_CODE_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_smac_code_5;
            REG_CFG_ACL_ITEM_SMAC_CODE_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_smac_code_6;
            REG_CFG_ACL_ITEM_VLAN_CODE_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_vlan_code_1;
            REG_CFG_ACL_ITEM_VLAN_CODE_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_vlan_code_2;
            REG_CFG_ACL_ITEM_VLAN_CODE_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_vlan_code_3;
            REG_CFG_ACL_ITEM_VLAN_CODE_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_vlan_code_4;
            REG_CFG_ACL_ITEM_ETHTYPE_CODE_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_ethtype_code_1;
            REG_CFG_ACL_ITEM_ETHTYPE_CODE_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_ethtype_code_2;
            REG_CFG_ACL_ITEM_ACTION_PASS_STATE: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_action_pass_state;
            REG_CFG_ACL_ITEM_ACTION_CB_STREAMHANDLE: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_action_cb_streamhandle;
            REG_CFG_ACL_ITEM_ACTION_FLOWCTRL: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_action_flowctrl;
            REG_CFG_ACL_ITEM_ACTION_TXPORT: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_acl_item_action_txport;
            // rxmac port
            // 端口1
            REG_PORT_RX_BYTE_CNT_0:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_0;
            REG_PORT_RX_FRAME_CNT_0:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_0;
            REG_PORT_DIAG_STATE_0:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_0};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_0; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_0; 
            //REG_PORT_RX_CRCERR_FRM_CNT_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_0;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_0; 
            REG_PORT_BROADFLOW_DROP_CNT_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_0; 
            REG_PORT_MULTIFLOW_DROP_CNT_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_0; 
            // 端口2
            REG_PORT_RX_BYTE_CNT_1:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_1;
            REG_PORT_RX_FRAME_CNT_1:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_1;
            REG_PORT_DIAG_STATE_1:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_1};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_1; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_1; 
            //REG_PORT_RX_CRCERR_FRM_CNT_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_1;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_1; 
            REG_PORT_BROADFLOW_DROP_CNT_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_1; 
            REG_PORT_MULTIFLOW_DROP_CNT_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_1; 
            // 端口3
            REG_PORT_RX_BYTE_CNT_2:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_2;
            REG_PORT_RX_FRAME_CNT_2:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_2;
            REG_PORT_DIAG_STATE_2:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_2};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_2; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_2; 
            //REG_PORT_RX_CRCERR_FRM_CNT_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_2;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_2; 
            REG_PORT_BROADFLOW_DROP_CNT_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_2; 
            REG_PORT_MULTIFLOW_DROP_CNT_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_2; 
            // 端口4
            REG_PORT_RX_BYTE_CNT_3:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_3;
            REG_PORT_RX_FRAME_CNT_3:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_3;
            REG_PORT_DIAG_STATE_3:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_3};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_3; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_3; 
            //REG_PORT_RX_CRCERR_FRM_CNT_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_3;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_3; 
            REG_PORT_BROADFLOW_DROP_CNT_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_3; 
            REG_PORT_MULTIFLOW_DROP_CNT_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_3; 
            // 端口5
            REG_PORT_RX_BYTE_CNT_4:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_4;
            REG_PORT_RX_FRAME_CNT_4:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_4;
            REG_PORT_DIAG_STATE_4:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_4};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_4; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_4; 
            //REG_PORT_RX_CRCERR_FRM_CNT_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_4;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_4; 
            REG_PORT_BROADFLOW_DROP_CNT_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_4; 
            REG_PORT_MULTIFLOW_DROP_CNT_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_4; 
            // 端口6
            REG_PORT_RX_BYTE_CNT_5:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_5;
            REG_PORT_RX_FRAME_CNT_5:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_5;
            REG_PORT_DIAG_STATE_5:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_5};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_5; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_5; 
            //REG_PORT_RX_CRCERR_FRM_CNT_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_5;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_5; 
            REG_PORT_BROADFLOW_DROP_CNT_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_5; 
            REG_PORT_MULTIFLOW_DROP_CNT_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_5; 
            // 端口7
            REG_PORT_RX_BYTE_CNT_6:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_6;
            REG_PORT_RX_FRAME_CNT_6:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_6;
            REG_PORT_DIAG_STATE_6:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_port_diag_state_6};
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_6; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_6; 
            //REG_PORT_RX_CRCERR_FRM_CNT_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_6;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_6; 
            REG_PORT_BROADFLOW_DROP_CNT_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_6; 
            REG_PORT_MULTIFLOW_DROP_CNT_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_6; 
            // 端口8
            REG_PORT_RX_BYTE_CNT_7:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_byte_cnt_7;
            REG_PORT_RX_FRAME_CNT_7:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_7;
            //REG_PORT_RX_FRAME_CNT_7:    r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_frame_cnt_7;
            //REG_PORT_RX_ULTRASHORT_FRM_CNT_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_ultrashort_frm_cnt_7; 
            //REG_PORT_RX_OVERLENGTH_FRM_CNT_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_overlength_frm_cnt_7; 
            //REG_PORT_RX_CRCERR_FRM_CNT_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_crcerr_frm_cnt_7;     
            //REG_PORT_RX_LOOKBACK_FRM_CNT_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_rx_lookback_frm_cnt_7; 
            //REG_PORT_BROADFLOW_DROP_CNT_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_broadflow_drop_cnt_7; 
            REG_PORT_MULTIFLOW_DROP_CNT_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_multiflow_drop_cnt_7; 
            // qbu_rx
            REG_QBU_RESET_0:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_0};
            REG_RX_FRAGMENT_CNT_0:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_0;
            REG_RX_FRAGMENT_MISMATCH_0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_0};
            REG_ERR_RX_CRC_CNT_0:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_0;
            REG_ERR_RX_FRAME_CNT_0:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_0;
            REG_ERR_FRAGMENT_CNT_0:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_0;
            //REG_ERR_VERIFI_CNT_0:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_0;
            REG_RX_FRAMES_CNT_0:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_0;
            REG_FRAG_NEXT_RX_0:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_0};
            REG_FRAME_SEQ_0:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_0};
            
            REG_QBU_RESET_1:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_1};
            REG_RX_FRAGMENT_CNT_1:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_1;
            REG_RX_FRAGMENT_MISMATCH_1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_1};
            REG_ERR_RX_CRC_CNT_1:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_1;
            REG_ERR_RX_FRAME_CNT_1:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_1;
            REG_ERR_FRAGMENT_CNT_1:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_1;
            //REG_ERR_VERIFI_CNT_1:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_1;
            REG_RX_FRAMES_CNT_1:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_1;
            REG_FRAG_NEXT_RX_1:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_1};
            REG_FRAME_SEQ_1:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_1};
            
            REG_QBU_RESET_2:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_2};
            REG_RX_FRAGMENT_CNT_2:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_2;
            REG_RX_FRAGMENT_MISMATCH_2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_2};
            REG_ERR_RX_CRC_CNT_2:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_2;
            REG_ERR_RX_FRAME_CNT_2:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_2;
            REG_ERR_FRAGMENT_CNT_2:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_2;
            //REG_ERR_VERIFI_CNT_2:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_2;
            REG_RX_FRAMES_CNT_2:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_2;
            REG_FRAG_NEXT_RX_2:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_2};
            REG_FRAME_SEQ_2:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_2};
            
            REG_QBU_RESET_3:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_3};
            REG_RX_FRAGMENT_CNT_3:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_3;
            REG_RX_FRAGMENT_MISMATCH_3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_3};
            REG_ERR_RX_CRC_CNT_3:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_3;
            REG_ERR_RX_FRAME_CNT_3:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_3;
            REG_ERR_FRAGMENT_CNT_3:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_3;
            //REG_ERR_VERIFI_CNT_3:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_3;
            REG_RX_FRAMES_CNT_3:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_3;
            REG_FRAG_NEXT_RX_3:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_3};
            REG_FRAME_SEQ_3:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_3};
            
            REG_QBU_RESET_4:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_4};
            REG_RX_FRAGMENT_CNT_4:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_4;
            REG_RX_FRAGMENT_MISMATCH_4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_4};
            REG_ERR_RX_CRC_CNT_4:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_4;
            REG_ERR_RX_FRAME_CNT_4:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_4;
            REG_ERR_FRAGMENT_CNT_4:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_4;
            //REG_ERR_VERIFI_CNT_4:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_4;
            REG_RX_FRAMES_CNT_4:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_4;
            REG_FRAG_NEXT_RX_4:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_4};
            REG_FRAME_SEQ_4:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_4};
            
            REG_QBU_RESET_5:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_5};
            REG_RX_FRAGMENT_CNT_5:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_5;
            REG_RX_FRAGMENT_MISMATCH_5: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_5};
            REG_ERR_RX_CRC_CNT_5:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_5;
            REG_ERR_RX_FRAME_CNT_5:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_5;
            REG_ERR_FRAGMENT_CNT_5:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_5;
            //REG_ERR_VERIFI_CNT_5:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_5;
            REG_RX_FRAMES_CNT_5:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_5;
            REG_FRAG_NEXT_RX_5:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_5};
            REG_FRAME_SEQ_5:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_5};
            
            REG_QBU_RESET_6:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_6};
            REG_RX_FRAGMENT_CNT_6:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_6;
            REG_RX_FRAGMENT_MISMATCH_6: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_6};
            REG_ERR_RX_CRC_CNT_6:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_6;
            REG_ERR_RX_FRAME_CNT_6:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_6;
            REG_ERR_FRAGMENT_CNT_6:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_6;
            //REG_ERR_VERIFI_CNT_6:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_6;
            REG_RX_FRAMES_CNT_6:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_6;
            REG_FRAG_NEXT_RX_6:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_6};
            REG_FRAME_SEQ_6:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_6};
            
            REG_QBU_RESET_7:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, r_reset_7};
            REG_RX_FRAGMENT_CNT_7:      r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_fragment_cnt_7;
            REG_RX_FRAGMENT_MISMATCH_7: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {15'd0, i_rx_fragment_mismatch_7};
            REG_ERR_RX_CRC_CNT_7:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_crc_cnt_7;
            REG_ERR_RX_FRAME_CNT_7:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_rx_frame_cnt_7;
            REG_ERR_FRAGMENT_CNT_7:     r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_fragment_cnt_7;
            //REG_ERR_VERIFI_CNT_7:       r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_err_verifi_cnt_7;
            REG_RX_FRAMES_CNT_7:        r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_rx_frames_cnt_7;
            REG_FRAG_NEXT_RX_7:         r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frag_next_rx_7};
            REG_FRAME_SEQ_7:            r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | {8'd0, i_frame_seq_7};
            
            default: begin
                r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
            end
        endcase
    end else begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end
end

// 寄存器读数据有效标志
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata_vld <= 1'b0;
    end else begin
        r_reg_bus_rdata_vld <= r_reg_bus_re;
    end
end

assign o_switch_reg_bus_rd_dout  = r_reg_bus_rdata;
assign o_switch_reg_bus_rd_dout_v= r_reg_bus_rdata_vld;


endmodule