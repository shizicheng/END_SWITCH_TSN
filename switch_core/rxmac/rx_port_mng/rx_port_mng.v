module rx_port_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   HASH_DATA_WIDTH         =      15       ,  // 哈希计算的值的位宽 
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      94       ,  // 信息流位宽
    parameter                                                   LOOK_UP_DATA_WIDTH      =      144      ,  // 二层头信息 MAC + VLAN + Eth_type
    parameter                                                   CAM_NUM                 =      256      ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH, // 聚合总线输出
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,  // 优先级FIFO数量
    parameter   [31:0]                                          PORT_INDEX              =      32'd0       // 端口索引参数
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    
    // 寄存器控制信号
    //input               wire                                    i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    //input               wire                                    i_switch_err_cnt_clr                , // 刷新错误计数器
    //input               wire                                    i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口
    //input               wire                                    i_switch_reg_bus_we                , // 寄存器写使能
    //input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr           , // 寄存器写地址
    //input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din            , // 寄存器写数据
    //input               wire                                    i_switch_reg_bus_we_din_v          , // 寄存器写数据使能
    // 寄存器读控制接口
    //input               wire                                    i_switch_reg_bus_rd                , // 寄存器读使能
    //input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr           , // 寄存器读地址
    //output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_we_dout           , // 读出寄存器数据
    //output              wire                                    o_switch_reg_bus_we_dout_v         , // 读数据有效使能
    
    /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
    input               wire                                    i_mac_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac_axi_data_last                , // 数据流结束标识
    //时间戳信号
	output              wire                                    o_mac_time_irq                     , // 打时间戳中断信号
    output              wire   [7:0]                            o_mac_frame_seq                    , // 帧序列号
    output              wire   [6:0]                            o_timestamp_addr                   ,  // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/ 
    output              wire   [11:0]                           o_vlan_id                          ,
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac                             , // 目的 mac 的值
    output              wire                                    o_dmac_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac                             , // 源 mac 的值
    output              wire                                    o_smac_vld                         , // smac_vld
    /*---------------------------------------- 查找的转发端口号 ---------------------------------------*/
    input               wire   [PORT_NUM-1:0]                   i_swlist_tx_port                   , // 交换发送端口信息
    input               wire                                    i_swlist_vld                       , // 发送端口信号有效信号 
    input               wire   [1:0]                            i_swlist_port_broadcast            , // 01:组播 10：广播 11:泛洪
    // 缓存交互逻辑
    output             wire                                     o_rtag_flag                        , // 是否携带rtag标签,是CB业务帧,需要先过CB模块觉定是否丢弃后,再送入crossbar
    output             wire   [15:0]                            o_rtag_squence                     , // rtag_squencenum
    output             wire   [7:0]                             o_stream_handle                    , // ACL流识别,区分流，每个流单独维护自己的

    input              wire                                     i_pass_en                          , // 判断结果，可以接收该帧
    input              wire                                     i_discard_en                       , // 判断结果，可以丢弃该帧
    input              wire                                     i_judge_finish                     , // 判断结果，表示本次报文的判断完成  

    output             wire                                     o_tx_req                           ,
    input              wire                                     i_mac_tx0_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx0_ack_rst                  , // 端口的优先级向量结果
    input              wire                                     i_mac_tx1_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx1_ack_rst                  , // 端口的优先级向量结果  
    input              wire                                     i_mac_tx2_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx2_ack_rst                  , // 端口的优先级向量结果
    input              wire                                     i_mac_tx3_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx3_ack_rst                  , // 端口的优先级向量结果
    input              wire                                     i_mac_tx4_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx4_ack_rst                  , // 端口的优先级向量结果
    input              wire                                     i_mac_tx5_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx5_ack_rst                  , // 端口的优先级向量结果
    input              wire                                     i_mac_tx6_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx6_ack_rst                  , // 端口的优先级向量结果
    input              wire                                     i_mac_tx7_ack                      , // 响应使能信号
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac_tx7_ack_rst                  , // 端口的优先级向量结果


    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [15:0]                           o_mac_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_cross_metadata                   , // 总线 metadata 数据
    output             wire                                     o_cross_metadata_valid             , // 总线 metadata 数据有效信号
    output             wire                                     o_cross_metadata_last              , // 信息流结束标识
    input              wire                                     i_cross_metadata_ready             , // 下游模块反压流水线 
    /*---------------------------------------- 单 PORT 关键帧输出数据流 -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac_port_axi_data               , // 端口数据流，最高位表示crcerr
    output              wire   [15:0]                           o_emac_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac_axi_data_keep               , // 端口数据流掩码，有效字节指示
    output              wire                                    o_emac_axi_data_valid              , // 端口数据有效
    input               wire                                    i_emac_axi_data_ready              , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_emac_axi_data_last               , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac_metadata                    , // 总线 metadata 数据
    output              wire                                    o_emac_metadata_valid              , // 总线 metadata 数据有效信号
    output              wire                                    o_emac_metadata_last               , // 信息流结束标识
    input               wire                                    i_emac_metadata_ready              , // 下游模块反压流水线 
/*
        metadata 数据组成
            
            [80:65] : CB协议 R-TAG字段 ok
            [64:63](2bit) : port_speed ok
            [62:60](3bit) : vlan_pri ok
            [59:52](8bit) : tx_prot ok 
            [51:44](8bit) : acl_frmtype ok
            [43:28](16bit): acl_fetchinfo ok
            [27](1bit) : frm_vlan_flag ok
            [26:19](8bit) : 输入端口，bitmap表示 ok
            [18:15](4bit) : 保留
            [14:13](2bit) : 流识别匹配，[0]:1表示CB业务帧，[0]:0表示非CB业务帧  [1]：1 有 rtag 标签 [1]：0 无 rtag 标签 ok 
            [12](1bit) : 丢弃位 ok
            [11](1bit) : 是否为关键帧(Qbu)  ok
            [10:4](7bit) ：time_stamp_addr，报文时间戳的地址信息  ok
            [3:0](3bit): 保留
    */
    //qbu验证信号
    output             wire                                     o_qbu_verify_valid                 ,
    output             wire                                     o_qbu_response_valid               ,

    /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
    input              wire   [15:0]                            i_hash_ploy_regs                   , // 哈希多项式
    input              wire   [15:0]                            i_hash_init_val_regs               , // 哈希多项式初始值
    input              wire                                     i_hash_regs_vld                    ,
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
    // ACL 寄存器
    input              wire   [PORT_NUM-1:0]                    i_acl_port_sel                     , // 选择要配置的端口
    input              wire                                     i_acl_clr_list_regs                , // 清空寄存器列表
    output             wire                                     o_acl_list_rdy_regs                , // 配置寄存器操作空闲
    input              wire   [4:0]                             i_acl_item_sel_regs                , // 配置条目选择
    //input              wire   [5:0]                             i_acl_item_waddr_regs              , // 每个条目最大支持比对 64 字节
    //input              wire   [7:0]                             i_acl_item_din_regs                , // 需要比较的字节数据
    //input              wire                                     i_acl_item_we_regs                 , // 配置使能信号
    //input              wire   [15:0]                            i_acl_item_rslt_regs               , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    //input              wire                                     i_acl_item_complete_regs           , // 端口 ACL 参数配置完成使能信号
    input              wire   [95:0]                           i_acl_item_dmac_code                ,
    input              wire   [95:0]                           i_acl_item_smac_code                ,
    input              wire   [63:0]                           i_acl_item_vlan_code                ,
    input              wire   [31:0]                           i_acl_item_ethtype_code             ,
    input              wire   [5:0]                            i_acl_item_action_pass_state        ,
    input              wire   [15:0]                           i_acl_item_action_cb_streamhandle   ,
    input              wire   [5:0]                            i_acl_item_action_flowctrl          ,
    input              wire   [15:0]                           i_acl_item_action_txport            ,
    // 状态寄存器
    output             wire   [15:0]                            o_port_diag_state                  , // 端口状态寄存器，详情见寄存器表说明定义 
    output             wire                                     o_tcam_config_busy                 , // TCAM 配置忙
    output             wire                                     o_tcam_fsm_state                   , // TCAM 当前状态
    // 诊断寄存器
    output             wire                                     o_port_rx_ultrashort_frm           , // 端口接收超短帧(小于64字节)
    output             wire                                     o_port_rx_overlength_frm           , // 端口接收超长帧(大于MTU字节)
    output             wire                                     o_port_rx_crcerr_frm               , // 端口接收CRC错误帧
    output             wire  [15:0]                             o_port_rx_loopback_frm_cnt         , // 端口接收环回帧计数器值
    output             wire  [15:0]                             o_port_broadflow_drop_cnt          , // 端口接收到广播限流而丢弃的帧计数器值
    output             wire  [15:0]                             o_port_multiflow_drop_cnt          , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    output             wire  [15:0]                             o_port_rx_byte_cnt                 , // 端口0接收字节个数计数器值
    output             wire  [15:0]                             o_port_rx_frame_cnt                  // 端口0接收帧个数计数器值  
);

/*----------- locaparameter -------*/

wire    [PORT_NUM-1:0]                  w_swlist_tx_port                    ; // 发送端口信息
wire                                    w_swlist_vld                        ; // 有效使能信号  

// rx_data_stream_cross 的输入数据流
wire                                    w_mac_port_link                     ;   
wire   [1:0]                            w_mac_port_speed                    ;         
wire                                    w_mac_port_filter_preamble_v        ;   
wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac_axi_data                      ;       
wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac_axi_data_keep                 ;        
wire                                    w_mac_axi_data_valid                ;        
wire                                    w_mac_axi_data_ready                ;             
wire                                    w_mac_axi_data_last                 ; 

// qbu 输出重组之后的数据流
wire                                    w_qbu_mac_port_link                 ;   
wire   [1:0]                            w_qbu_mac_port_speed                ;         
wire                                    w_qbu_mac_port_filter_preamble_v    ;   
wire   [PORT_MNG_DATA_WIDTH-1:0]        w_qbu_mac_axi_data                  ;       
wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_qbu_mac_axi_data_keep             ;  
wire   [15:0]                           w_qbu_mac_axi_data_user             ;      
wire                                    w_qbu_mac_axi_data_valid            ;        
wire                                    w_qbu_mac_axi_data_ready            ;             
wire                                    w_qbu_mac_axi_data_last             ; 

// 限流后输出的数据流

wire                                    w_mac_time_irq                      ; // 打时间戳中断信号
wire  [7:0]                             w_mac_frame_seq                     ; // 帧序列号
wire  [6:0]                             w_timestamp_addr                    ; // 打时间戳存储的 RAM 地址

wire  [15:0]                            w_port_rx_byte_cnt                  ; // 端口0接收字节个数计数器值
wire  [15:0]                            w_port_rx_frame_cnt                 ; // 端口0接收帧个数计数器值 

// wire                                    w_mac_cross_port_link               ;
wire   [1:0]                            w_mac_cross_port_speed              ;
wire   [CROSS_DATA_WIDTH-1:0]           w_mac_cross_axi_data                ;
wire   [15:0]                           w_mac_cross_axi_data_user           ;
wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac_cross_axi_data_keep           ;
wire                                    w_mac_cross_axi_data_valid          ;
wire                                    w_mac_cross_axi_data_ready          ;
wire                                    w_mac_cross_axi_data_last           ;

wire   [CROSS_DATA_WIDTH-1:0]           w_mac_cross_port_axi_data           ; // 接到外部信号
wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac_cross_port_axi_keep           ; // 接到外部信号
wire   [15:0]                           w_mac_cross_port_axi_user           ; // 接到外部信号
wire                                    w_mac_cross_port_axi_valid          ; // 接到外部信号
wire                                    w_mac_cross_port_axi_ready          ; // 接到外部信号
wire                                    w_mac_cross_port_axi_last           ; // 接到外部信号

// rx_frm_info_mng 的输出信息
wire                                    w_mac_frm_info_cross_axi_data_ready ;
wire   [1:0]                            w_port_speed                        ;
wire   [2:0]                            w_vlan_pri                          ;
wire                                    w_frm_vlan_flag                     ;
wire   [PORT_NUM-1:0]                   w_rx_port                           ;
wire   [1:0]                            w_frm_cb_op                         ;
wire                                    w_frm_qbu                           ;
wire   [47:0]                           w_dmac_data                         ;
wire                                    w_damac_data_vld                    ;
wire                                    w_dmac_soc                          ;
wire                                    w_dmac_eoc                          ;
wire   [47:0]                           w_smac_data                         ;
wire                                    w_samac_data_vld                    ;
wire                                    w_smac_soc                          ;
wire                                    w_smac_eoc                          ;
wire                                    w_info_valid                        ;
wire   [11:0]                           w_vlan_id                           ;    
wire   [15:0]                           w_rtag_sequence                     ;
wire   [15:0]                           w_ethertyper                        ;

// rx_data_width output
wire   [LOOK_UP_DATA_WIDTH-1:0]         w_mac_width_port_axi_data           ;
wire                                    w_mac_width_axi_data_valid          ;

// rx_frm_acl_mng 的输出信息
wire                                    w_mac_frm_acl_axi_data_ready        ;
wire                                    w_acl_vld                           ; 
wire    [2:0]                           w_acl_action                        ;
wire                                    w_acl_cb_frm                        ;
wire    [7:0]                           w_acl_cb_streamhandle               ;
wire    [2:0]                           w_acl_flow_ctrl                     ;
wire    [7:0]                           w_acl_forwardport                   ;
// wire                                    w_acl_find_match                    ; 
// wire   [7:0]                            w_acl_frmtype                       ; 
// wire   [15:0]                           w_acl_fetch_info                    ;
wire                                    w_acl_list_rdy_regs                 ;
 

wire   [11:0]                           w_vlanid                           ;
wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_hash_key                    ; // 目的 mac 的哈希值
wire   [47 : 0]                         w_dmac                             ; // 目的 mac 的值
wire                                    w_dmac_hash_vld                    ; // dmac_vld
wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_hash_key                    ; // 源 mac 的值有效标识
wire   [47 : 0]                         w_smac                             ; // 源 mac 的值
wire                                    w_smac_hash_vld                    ; // smac_vld

wire   [METADATA_WIDTH-1:0]             w_cross_metadata                   ; // 聚合总线 metadata 数据
wire                                    w_cross_metadata_valid             ; // 聚合总线 metadata 数据有效
wire                                    w_cross_metadata_last              ; // 信息流结束标识
wire                                    w_cross_metadata_ready             ; // 下游模块反压流水线 

wire   [METADATA_WIDTH-1:0]             w_cross_port_metadata              ;
wire                                    w_cross_port_metadata_valid        ;
wire                                    w_cross_port_metadata_last         ;
wire                                    w_cross_port_metadata_ready        ;

// rx_forward_mng 的信号
wire                                    w_port_rx_ultrashort_frm           ; // 端口接收超短帧(小于64字节)
wire                                    w_port_rx_overlength_frm           ; // 端口接收超长帧(大于MTU字节)
wire                                    w_port_rx_crcerr_frm               ; // 端口接收CRC错误帧
wire  [15:0]                            w_port_rx_loopback_frm_cnt         ; // 端口接收环回帧计数器值
wire  [15:0]                            w_port_broadflow_drop_cnt          ; // 端口接收到广播限流而丢弃的帧计数器值
wire  [15:0]                            w_port_multiflow_drop_cnt          ; // 端口接收到组播限流而丢弃的帧计数器值
wire  [15:0]                            w_port_diag_state                  ;  // 端口状态寄存器，详情见寄存器表说明定义 

wire                                    w_port_rxmac_down_regs             ; // 端口接收方向MAC关闭使能
wire                                    w_port_broadcast_drop_regs         ; // 端口广播帧丢弃使能
wire                                    w_port_multicast_drop_regs         ; // 端口组播帧丢弃使能
wire                                    w_port_loopback_drop_regs          ; // 端口环回帧丢弃使能
wire   [47:0]                           w_port_mac_regs                    ; // 端口的 MAC 地址
wire                                    w_port_mac_vld_regs                ; // 使能端口 MAC 地址有效
wire   [7:0]                            w_port_mtu_regs                    ; // MTU配置值
wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs            ; // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
wire   [15:0]                           w_port_flowctrl_cfg_regs           ; // 限流管理配置                                                                        
wire   [4:0]                            w_port_rx_ultrashortinterval_num   ; // 帧间隔    

//qbu的寄存器信号
wire                                    w_rx_busy                          ;
wire   [15:0]                           w_rx_fragment_cnt                  ;
wire                                    w_rx_fragment_mismatch             ;
wire   [15:0]                           w_err_rx_crc_cnt                   ;
wire   [15:0]                           w_err_rx_frame_cnt                 ;
wire   [15:0]                           w_err_fragment_cnt                 ;
wire   [15:0]                           w_rx_frames_cnt                    ;
wire   [7:0]                            w_frag_next_rx                     ; 
wire   [7:0]                            w_frame_seq                        ;

wire                                    w_verify_enabled                   ;
wire                                    w_start_verify                     ;
wire                                    w_clear_verify                     ;
wire                                    w_verify_succ                      ;
wire                                    w_verify_succ_val                  ;
wire   [7:0]                            w_verify_timer                     ;
wire                                    w_verify_timer_vld                 ;
wire   [15:0]                           w_err_verify_cnt                   ;
wire                                    w_preempt_enable                   ;

wire                                    w_dmac_vld                         ;
wire                                    w_smac_vld                         ;
wire                                    w_rtag_flag                        ; 

/* ------------------------------ 内部数据流链接 ------------------------------- */
// assign              o_mac_cross_port_link               =      w_mac_cross_port_link        ;
assign              o_mac_cross_port_speed              =      w_mac_cross_port_speed       ;
assign              o_mac_cross_port_axi_data           =      w_mac_cross_port_axi_data    ;
assign              o_mac_cross_port_axi_user           =      w_mac_cross_port_axi_user    ;
assign              o_mac_cross_axi_data_keep           =      w_mac_cross_port_axi_keep    ;
assign              o_mac_cross_axi_data_valid          =      w_mac_cross_port_axi_valid   ;
assign              w_mac_cross_port_axi_ready          =      i_mac_cross_axi_data_ready   ;
assign              o_mac_cross_axi_data_last           =      w_mac_cross_port_axi_last    ;
  

/* ------------------------------ 顶层模块数据流链接 ------------------------------- */
// input
// assign              w_mac_port_link                     =      i_mac_port_link              ;
assign              w_mac_port_speed                    =      i_mac_port_speed             ;
assign              w_mac_port_filter_preamble_v        =      i_mac_port_filter_preamble_v ;
assign              w_mac_axi_data                      =      i_mac_axi_data               ;
assign              w_mac_axi_data_keep                 =      i_mac_axi_data_keep          ;
assign              w_mac_axi_data_valid                =      i_mac_axi_data_valid         ;
assign              o_mac_axi_data_ready                =      w_mac_axi_data_ready         ;
assign              w_mac_axi_data_last                 =      i_mac_axi_data_last          ;

assign              w_acl_port_sel                      =      i_acl_port_sel               ;   
assign              w_acl_clr_list_regs                 =      i_acl_clr_list_regs          ;   
assign              o_acl_list_rdy_regs                 =      w_acl_list_rdy_regs          ;   
assign              w_acl_item_sel_regs                 =      i_acl_item_sel_regs          ;   
//assign              w_acl_item_waddr_regs               =      i_acl_item_waddr_regs        ;   
//assign              w_acl_item_din_regs                 =      i_acl_item_din_regs          ;   
//assign              w_acl_item_we_regs                  =      i_acl_item_we_regs           ;   
//assign              w_acl_item_rslt_regs                =      i_acl_item_rslt_regs         ;   
//assign              w_acl_item_complete_regs            =      i_acl_item_complete_regs     ;   

assign              w_swlist_tx_port                    =      i_swlist_tx_port             ;
assign              w_swlist_vld                        =      i_swlist_vld                 ;

assign              w_port_rxmac_down_regs              =      i_port_rxmac_down_regs       ;   
assign              w_port_broadcast_drop_regs          =      i_port_broadcast_drop_regs   ;   
assign              w_port_multicast_drop_regs          =      i_port_multicast_drop_regs   ;   
assign              w_port_loopback_drop_regs           =      i_port_loopback_drop_regs    ;   
assign              w_port_mac_regs                     =      i_port_mac_regs              ;   
assign              w_port_mac_vld_regs                 =      i_port_mac_vld_regs          ;   
assign              w_port_mtu_regs                     =      i_port_mtu_regs              ;   
assign              w_port_mirror_frwd_regs             =      i_port_mirror_frwd_regs      ;   
assign              w_port_flowctrl_cfg_regs            =      i_port_flowctrl_cfg_regs     ;   
assign              w_port_rx_ultrashortinterval_num    =      i_port_rx_ultrashortinterval_num;

// output
assign              o_mac_time_irq                      =      w_mac_time_irq               ;
assign              o_mac_frame_seq                     =      w_mac_frame_seq              ;
assign              o_timestamp_addr                    =      w_timestamp_addr             ;

assign              o_port_rx_byte_cnt                  =      w_port_rx_byte_cnt           ;
assign              o_port_rx_frame_cnt                 =      w_port_rx_frame_cnt          ;

assign              o_vlan_id                           =      w_vlanid                     ;
assign              o_dmac_hash_key                     =      w_dmac_hash_key              ;
assign              o_dmac                              =      w_dmac                       ;
assign              o_dmac_vld                          =      w_dmac_vld                   ;
assign              o_smac_hash_key                     =      w_smac_hash_key              ;
assign              o_smac                              =      w_smac                       ;
assign              o_smac_vld                          =      w_smac_vld                   ;

// assign              o_rtag_flag                         =      w_rtag_flag                  ;
// assign              o_rtag_squence                      =      w_rtag_sequence              ;
// assign              o_stream_handle                     =      w_acl_cb_streamhandle        ;

assign              o_cross_metadata                    =      w_cross_port_metadata        ;
assign              o_cross_metadata_valid              =      w_cross_port_metadata_valid  ;
assign              o_cross_metadata_last               =      w_cross_port_metadata_last   ;
assign              w_cross_port_metadata_ready         =      i_cross_metadata_ready       ;

assign              o_port_rx_ultrashort_frm            =      w_port_rx_ultrashort_frm     ;
assign              o_port_rx_overlength_frm            =      w_port_rx_overlength_frm     ;   
assign              o_port_rx_crcerr_frm                =      w_port_rx_crcerr_frm         ;       
assign              o_port_rx_loopback_frm_cnt          =      w_port_rx_loopback_frm_cnt   ;   
assign              o_port_broadflow_drop_cnt           =      w_port_broadflow_drop_cnt    ;   
assign              o_port_multiflow_drop_cnt           =      w_port_multiflow_drop_cnt    ;   
assign              o_port_diag_state                   =      w_port_diag_state            ;

/* ------------------------------ 帧抢占接收通路 ------------------------------- */

qbu_rec #(
    .DWIDTH                           (PORT_MNG_DATA_WIDTH          ),
	.PORT_INDEX 					  (PORT_INDEX  		            )
) qbu_rec_inst (          
    .i_clk                            (i_clk                        ),
    .i_rst                            (i_rst                        ),
    //接口层输入数据流
    .i_mac_port_speed                 (w_mac_port_speed             ),
    .i_mac_axi_data                   (w_mac_axi_data               ), 
    .i_mac_axi_data_keep              (w_mac_axi_data_keep          ), 
    .i_mac_axi_data_valid             (w_mac_axi_data_valid         ), 
    .o_mac_axi_data_ready             (w_mac_axi_data_ready         ), 
    .i_mac_axi_data_last              (w_mac_axi_data_last          ), 
    //输出给tx_mac，验证qbu功能
    .o_qbu_verify_valid               (i_qbu_verify_valid           ),
    .o_qbu_response_valid             (i_qbu_response_valid         ),
    //输出qbu emac和pmac通道数据，emac通道数据中断输出
    .o_qbu_rx_axis_portspeed          (w_qbu_mac_port_speed         ),
    .o_qbu_rx_axis_data               (w_qbu_mac_axi_data           ),
    .o_qbu_rx_axis_user               (w_qbu_mac_axi_data_user      ),
    .o_qbu_rx_axis_keep               (w_qbu_mac_axi_data_keep      ),
    .o_qbu_rx_axis_last               (w_qbu_mac_axi_data_last      ),
    .o_qbu_rx_axis_valid              (w_qbu_mac_axi_data_valid     ),
    .i_qbu_rx_axis_ready              (w_qbu_mac_axi_data_ready     ),  

    .o_dmac			                  (w_dmac_data                  ),      
    .o_smac 			              (w_smac_data                  ),          
    // .o_port_speed                     (w_port_speed                 ),      
    .o_vlan_pri                       (w_vlan_pri                   ),      
    .o_vlan_id                        (w_vlan_id                    ),      
    .o_frm_vlan_flag                  (w_frm_vlan_flag              ),      
    .o_frm_qbu                        (w_frm_qbu                    ),      
    .o_frm_discard                    (w_frm_discard                ),      
    .o_rtag_sequence                  (w_rtag_sequence              ),      
    .o_rtag_flag                      (w_rtag_flag                  ),      
    .o_ethertype 	                  (w_ethertyper                 ),      
    .o_info_valid                     (w_info_valid                 ),      
    // // 打时间戳信号
    .o_mac_time_irq                   (w_mac_time_irq               ),  
    .o_mac_frame_seq                  (w_mac_frame_seq              ),  
    .o_timestamp_addr                 (w_timestamp_addr             ),     
    //qbu寄存器管理
    .i_default_vlan_id                (12'd0 ), // 等待添加逻辑
    .i_default_vlan_pri               (3'd0  ), // 等待添加逻辑
    .i_default_vlan_valid             (1'd0  ), // 等待添加逻辑

    .i_verify_enabled	              (w_verify_enabled	            ),
    .i_verify_timer		              (w_verify_timer		        ),
    .i_verify_timer_valid             (w_verify_timer_valid         ),
    .i_reset 			              (w_reset 			            ),
    .i_start_verify     	          (w_start_verify               ),
    .i_clear_verify     	          (w_clear_verify               ),
    
    .o_rx_busy                        (w_rx_busy             	    ), 
    .o_rx_fragment_cnt                (w_rx_fragment_cnt     	    ), 
    .o_rx_fragment_mismatch           (w_rx_fragment_mismatch	    ), 
    .o_err_rx_crc_cnt                 (w_err_rx_crc_cnt      	    ), 
    .o_err_rx_frame_cnt               (w_err_rx_frame_cnt    	    ), 
    .o_err_fragment_cnt               (w_err_fragment_cnt    	    ), 
    .o_rx_frames_cnt                  (w_rx_frames_cnt       	    ), 
    .o_frag_next_rx                   (w_frag_next_rx        	    ), 
    .o_err_verify_cnt                 (w_err_verify_cnt             ),
    .o_preempt_enable                 (w_preempt_enable             ),
    .o_frame_seq                      (w_frame_seq           	    )  
);

/* ----------------------------- 数据流基本信息提取（流水线操作） -------------------------------- */

// rx_frm_info_mng#(
//     .PORT_NUM                       ( PORT_NUM                       )   ,
//     .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH            )   ,
//     .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH               )   ,
//     .PORT_INDEX                     ( PORT_INDEX                     )
// )rx_frm_info_mng_inst (
//     .i_clk                          ( i_clk                          )   ,
//     .i_rst                          ( i_rst                          )   ,
//     /*---------------------------------------- 单 PORT 聚合数据流 ----------------------------------*/
//     // .i_mac_port_link                ( w_qbu_mac_port_link            )   ,
//     .i_mac_port_speed               ( w_qbu_mac_port_speed           )   ,
//     .i_mac_port_axi_data            ( w_qbu_mac_axi_data             )   ,
//     .i_mac_axi_data_keep            ( w_qbu_mac_axi_data_keep        )   ,
//     .i_mac_axi_data_user            ( w_qbu_mac_axi_data_user        )   ,  
//     .i_mac_axi_data_valid           ( w_qbu_mac_axi_data_valid       )   ,
//     .o_mac_axi_data_ready           ( w_qbu_mac_axi_data_ready       )   ,
//     .i_mac_axi_data_last            ( w_qbu_mac_axi_data_last        )   ,
//     // 寄存器配置输入
//     .i_default_vlan_id              (12'd0 ), // 等待添加逻辑
//     .i_default_vlan_pri             (3'd0  ), // 等待添加逻辑
//     .i_default_vlan_valid           (1'd0  ), // 等待添加逻辑

//     /* 单 PORT 部分信息流 */
//     .o_port_speed                   ( w_port_speed                   )   ,
//     .o_vlan_pri                     ( w_vlan_pri                     )   ,
//     .o_frm_vlan_flag                ( w_frm_vlan_flag                )   ,
//     .o_rx_port                      ( w_rx_port                      )   ,
//     .o_frm_qbu                      ( w_frm_qbu                      )   ,
//     .o_frm_discard                  ( w_frm_discard                  )   ,  
//     .o_vlan_id                      ( w_vlan_id                      )   ,  
//     .o_rtag_sequence                ( w_rtag_sequence                )   ,  
//     .o_ethertyper                   ( w_ethertyper                   )   ,  
//     /*-------------------------- 内部处理所需的信息流 ----------------------------*/
//     .o_dmac_data                    ( w_dmac_data                    )   ,
//     .o_damac_data_vld               ( w_damac_data_vld               )   ,
//     .o_dmac_soc                     ( w_dmac_soc                     )   ,
//     .o_dmac_eoc                     ( w_dmac_eoc                     )   ,
//     .o_smac_data                    ( w_smac_data                    )   ,
//     .o_samac_data_vld               ( w_samac_data_vld               )   ,
//     .o_smac_soc                     ( w_smac_soc                     )   ,
//     .o_smac_eoc                     ( w_smac_eoc                     )   ,
//     .o_frm_info_vld                 ( w_frm_info_vld                 )   ,
//     .o_broadcast_frm_en             ( w_broadcast_frm_en             )   ,
//     .o_multicast_frm_en             ( w_multicast_frm_en             )   ,
//     .o_flood_frm_en                 ( w_flood_frm_en                 )
// );

// --------------- 查表需要的数据 144bit
// rx_data_width #(
//     .INPUT_WIDTH                    ( PORT_MNG_DATA_WIDTH           ),
//     .OUTPUT_WIDTH                   ( LOOK_UP_DATA_WIDTH            )
// ) rx_data_width_inst (
//     .i_clk                          ( i_clk                         ),
//     .i_rst                          ( i_rst                         ),
//     .i_mac_port_filter_preamble_v   ( i_mac_port_filter_preamble_v  ),
//     .i_mac_axi_data                 ( w_qbu_mac_axi_data            ),
//     .i_mac_axi_data_keep            ( w_qbu_mac_axi_data_keep       ),
//     .i_mac_axi_data_valid           ( w_qbu_mac_axi_data_valid      ),
//     .o_mac_axi_data_ready           (                               ),
//     .i_mac_axi_data_last            ( w_qbu_mac_axi_data_last       ),

//     .o_mac_cross_port_axi_data      ( w_mac_width_port_axi_data     ),
//     .o_mac_cross_axi_data_valid     ( w_mac_width_axi_data_valid    )
// );

rx_acllookup_data rx_acllookup_data_inst (
    .i_clk                          ( i_clk                         ),
    .i_rst                          ( i_rst                         ),

    .i_dmac_data                    ( w_dmac_data                   ), 
    .i_smac_data                    ( w_smac_data                   ), 

    .i_vlan_id                      ( w_vlan_id                     ),
    .i_vlan_pri                     ( w_vlan_pri                    ),
    .i_ethertyper                   ( w_ethertyper                  ),
    .i_info_vld                     ( w_info_valid                  ),

    .o_mac_cross_port_axi_data      ( w_mac_width_port_axi_data     ),
    .o_mac_cross_axi_data_valid     ( w_mac_width_axi_data_valid    )
);

// --------------
tcam_top #(
    .LOOK_UP_DATA_WIDTH             ( LOOK_UP_DATA_WIDTH          ),   // 需要查询的数据总位宽
    .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH          ),   // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH          ),   // 接收 MAC 层的配置寄存器数据位宽
    .ACTION_WIDTH                   ( 24                          ),   // ACTION
    .CAM_NUM                        ( 256                         )    // 表项数量
) tcam_top_inst (           
    .i_clk                          ( i_clk                       ),
    .i_rst                          ( i_rst                       ),
    /*---------------------------------------- 匹配数据输入 ------------------------------------------*/
    .i_look_up_data                 ( w_mac_width_port_axi_data   ),
    .i_look_up_data_vld             ( w_mac_width_axi_data_valid  ),
    /*---------------------------------------- 匹配 ACTION 输出 --------------------------------------*/
    // .o_acl_frmtype                  ( w_acl_frmtype               ),
    // .o_acl_fetchinfo                ( w_acl_fetch_info            ),
    .o_acl_action                   ( w_acl_action                ),
    .o_acl_cb_frm                   ( w_acl_cb_frm                ),
    .o_acl_cb_streamhandle          ( w_acl_cb_streamhandle       ),
    .o_acl_flow_ctrl                ( w_acl_flow_ctrl             ),
    .o_acl_forwardport              ( w_acl_forwardport           ),  
    .o_acl_vld                      ( w_acl_vld                   ),
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    .o_tcam_busy                    ( o_tcam_config_busy          ) // 输出给上层表明现在tcam正busy
    // 寄存器控制信号       
    //.i_refresh_list_pulse           ( i_refresh_list_pulse        ), // 刷新寄存器列表（状态寄存器和控制寄存器）
    //.i_switch_err_cnt_clr           ( i_switch_err_cnt_clr        ), // 刷新错误计数器
    //.i_switch_err_cnt_stat          ( i_switch_err_cnt_stat       ), // 刷新错误状态寄存器
    // 寄存器写控制接口       
    //.i_switch_reg_bus_we            ( i_switch_reg_bus_we         ), // 寄存器写使能
    //.i_switch_reg_bus_we_addr       ( i_switch_reg_bus_we_addr    ), // 寄存器写地址
    //.i_switch_reg_bus_we_din        ( i_switch_reg_bus_we_din     ), // 寄存器写数据
    //.i_switch_reg_bus_we_din_v      ( i_switch_reg_bus_we_din_v   ), // 寄存器写数据使能
    // 寄存器读控制接口       
    //.i_switch_reg_bus_rd            ( i_switch_reg_bus_rd         ), // 寄存器读使能
    //.i_switch_reg_bus_rd_addr       ( i_switch_reg_bus_rd_addr    ), // 寄存器读地址
    //.o_switch_reg_bus_we_dout       ( o_switch_reg_bus_we_dout    ), // 读出寄存器数据
    //.o_switch_reg_bus_we_dout_v     ( o_switch_reg_bus_we_dout_v  )  // 读数据有效使能
  );

rx_mac_hash_calc#(
    .CWIDTH                         ( HASH_DATA_WIDTH                )
)rx_mac_hash_calc_inst (           
    .i_clk                          ( i_clk                          )    ,   // 250MHz
    .i_rst                          ( i_rst                          )    ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    .i_hash_poly_regs               ( i_hash_ploy_regs               )    ,
    .i_hash_init_val_regs           ( i_hash_init_val_regs           )    ,
    .i_hash_regs_vld                ( i_hash_regs_vld                )    ,
    /*--------------------------------- 信息提取模块输入的 MAC 信息 -------------------------------------*/
    .i_vlan_id                      ( w_vlan_id                      )    ,
    .i_dmac_data                    ( w_dmac_data                    )    , // 目的 MAC 地址的值
    .i_dmac_data_vld                ( w_info_valid                   )    , // 数据有效值 
    .i_smac_data                    ( w_smac_data                    )    , // 源 MAC 地址的值
    .i_smac_data_vld                ( w_info_valid                   )    , // 数据有效值 
    /*--------------------------------- 输出 hash 的计算结果 -------------------------------------*/     
    .o_vlan_id                      ( w_vlanid                       )    ,
    .o_dmac_hash_key                ( w_dmac_hash_key                )    ,
    .o_dmac                         ( w_dmac                         )    ,
    .o_dmac_hash_vld                ( w_dmac_vld                     )    ,
    .o_smac_hash_key                ( w_smac_hash_key                )    ,
    .o_smac                         ( w_smac                         )    ,
    .o_smac_hash_vld                ( w_smac_vld                     )            
);

rx_forward_mng#(
    .PORT_NUM                           ( PORT_NUM                       ) ,
    .PORT_MNG_DATA_WIDTH                ( PORT_MNG_DATA_WIDTH            ) ,
    .METADATA_WIDTH                     ( METADATA_WIDTH                 ) ,
    .PORT_INDEX                         ( PORT_INDEX                     ) ,
    .CROSS_DATA_WIDTH                   ( CROSS_DATA_WIDTH               )
)rx_forward_mng_inst (
    .i_clk                              ( i_clk                          ) ,
    .i_rst                              ( i_rst                          ) ,
    /* 控制转发相关的寄存器 */
    .i_port_rxmac_down_regs             ( w_port_rxmac_down_regs         ) ,
    .i_port_broadcast_drop_regs         ( w_port_broadcast_drop_regs     ) ,
    .i_port_multicast_drop_regs         ( w_port_multicast_drop_regs     ) ,
    .i_port_loopback_drop_regs          ( w_port_loopback_drop_regs      ) ,
    .i_port_mac_regs                    ( w_port_mac_regs                ) ,
    .i_port_mac_vld_regs                ( w_port_mac_vld_regs            ) ,
    .i_port_mtu_regs                    ( w_port_mtu_regs                ) ,
    .i_port_mirror_frwd_regs            ( w_port_mirror_frwd_regs        ) ,
    .i_port_flowctrl_cfg_regs           (16'h00),//( w_port_flowctrl_cfg_regs       ) ,
    .i_port_rx_ultrashortinterval_num   ( w_port_rx_ultrashortinterval_num) ,
    /* rx_frm_info_mng input 的信息流 */
    .i_rtag_flag                        ( w_rtag_flag                    ) ,
    .i_ethertype                        ( w_ethertyper                   ) ,
    .i_rtag_sequence                    ( w_rtag_sequence                ) ,  
    .i_port_speed                       ( w_qbu_mac_port_speed           ) ,
    .i_vlan_pri                         ( w_vlan_pri                     ) ,
    .i_frm_vlan_flag                    ( w_frm_vlan_flag                ) ,
    // .i_rx_port                          ( w_rx_port                      ) ,
    .i_frm_discard                      ( w_frm_discard                  ) ,  
    .i_frm_qbu                          ( w_frm_qbu                      ) ,
    .i_timestamp_addr                   ( w_timestamp_addr               ) ,
    .i_info_valid                       ( w_info_valid                   ) ,
    /* 查表模块根据哈希值返回的计算结果 */
    .i_swlist_port_broadcast            (i_swlist_port_broadcast         ) ,
    .i_swlist_tx_port                   ( w_swlist_tx_port               ) ,
    .i_swlist_vld                       ( w_swlist_vld                   ) ,
    /* ACL 匹配后输出的字段 */
    .i_acl_vld                          ( w_acl_vld                      ) ,
    .i_acl_action                       ( w_acl_action                   ) ,
    .i_acl_cb_frm                       ( w_acl_cb_frm                   ) ,
    .i_acl_cb_streamhandle              ( w_acl_cb_streamhandle          ) ,
    .i_acl_flow_ctrl                    ( w_acl_flow_ctrl                ) ,
    .i_acl_forwardport                  ( w_acl_forwardport              ) ,  
    // .i_acl_find_match                   ( w_acl_find_match               ) ,
    // .i_acl_frmtype                      ( w_acl_frmtype                  ) ,
    // .i_acl_fetch_info                   ( w_acl_fetch_info               ) ,
    // .i_frm_cb_op                        ( w_frm_cb_op                    ) ,
    /* 单 PORT 聚合数据流输入 */
    .i_mac_port_axi_data                ( w_qbu_mac_axi_data             ) ,
    .i_mac_axi_data_user                ( w_qbu_mac_axi_data_user        ) ,
    .i_mac_axi_data_keep                ( w_qbu_mac_axi_data_keep        ) ,
    .i_mac_axi_data_valid               ( w_qbu_mac_axi_data_valid       ) ,
    .o_mac_axi_data_ready               ( w_qbu_mac_axi_data_ready       ) ,  
    .i_mac_axi_data_last                ( w_qbu_mac_axi_data_last        ) ,
    /* 单 PORT 聚合数据流输出 */
    .o_mac_port_axi_data                ( w_mac_cross_axi_data           ) ,
    .o_mac_axi_data_user                ( w_mac_cross_axi_data_user      ) ,
    .o_mac_axi_data_keep                ( w_mac_cross_axi_data_keep      ) ,
    .o_mac_axi_data_valid               ( w_mac_cross_axi_data_valid     ) ,
    .i_mac_axi_data_ready               ( w_mac_cross_axi_data_ready     ) ,
    .o_mac_axi_data_last                ( w_mac_cross_axi_data_last      ) ,
    /* 单 PORT 聚合信息流 */
    .o_cross_metadata                   ( w_cross_metadata               ) ,
    .o_cross_metadata_valid             ( w_cross_metadata_valid         ) ,
    .o_cross_metadata_last              ( w_cross_metadata_last          ) ,
    .i_cross_metadata_ready             ( w_cross_metadata_ready         ) ,
    /* 诊断寄存器 */
    .o_port_rx_ultrashort_frm           ( w_port_rx_ultrashort_frm       ) ,
    .o_port_rx_overlength_frm           ( w_port_rx_overlength_frm       ) ,
    .o_port_rx_crcerr_frm               ( w_port_rx_crcerr_frm           ) ,
    .o_port_rx_loopback_frm_cnt         ( w_port_rx_loopback_frm_cnt     ) ,
    .o_port_broadflow_drop_cnt          ( w_port_broadflow_drop_cnt      ) ,
    .o_port_multiflow_drop_cnt          ( w_port_multiflow_drop_cnt      ) ,
    .o_port_diag_state                  ( w_port_diag_state              )
);


rx_port_cache_mng#(
    .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
    .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
    .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
    .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),        // 聚合总线输出
    .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM                      ),        // 优先级FIFO数量
    .RAM_DEPTH                          (1024                                   ),        // RAM深度
    .RAM_ADDR_WIDTH                     (10                                     ),        // RAM地址宽度
    .FIFO_DEPTH                         (512                                    ),        // FIFO深度
    .REQ_TIMEOUT_CNT                    (1250                                   ),        // req超时计数值(5us @ 250MHz)
    .TIMEOUT_CNT_WIDTH                  (11                                     )         // 超时计数器位宽
)rx_port_cache_mng_inst0 (
    .i_clk                              (i_clk                                  ),        // 250MHz
    .i_rst                              (i_rst                                  ),
    /*---------------------------------------- 输入的MAC数据流 -------------------------------------------*/
    .i_mac_axi_data                     ( w_mac_cross_axi_data                  ),        // 端口数据流
    .i_mac_axi_data_keep                ( w_mac_cross_axi_data_keep             ),        // 端口数据流掩码，有效字节指示
    .i_mac_axi_data_valid               ( w_mac_cross_axi_data_valid            ),        // 端口数据有效
    .o_mac_axi_data_ready               ( w_mac_cross_axi_data_ready            ),        // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac_axi_data_last                ( w_mac_cross_axi_data_last             ),        // 数据流结束标识
    .i_mac_axi_data_user                ( w_mac_cross_axi_data_user             ),        // 帧长度信息
    /*---------------------------------------- 输入的metadata流 -------------------------------------------*/
    .i_cross_metadata                   ( w_cross_metadata                      ),        // 输入metadata数据
    .i_cross_metadata_valid             ( w_cross_metadata_valid                ),        // 输入metadata数据有效信号
    .i_cross_metadata_last              ( w_cross_metadata_last                 ),        // 输入metadata结束标识
    .o_cross_metadata_ready             ( w_cross_metadata_ready                ),        // metadata反压流水线
    /*---------------------------------------- 输出到交叉总线的数据流 -------------------------------------------*/
    .o_mac_cross_port_axi_data          (w_mac_cross_port_axi_data              ),        // 端口数据流，最高位表示crcerr
    .o_mac_cross_port_axi_user          (w_mac_cross_port_axi_user              ),
    .o_mac_cross_axi_data_keep          (w_mac_cross_port_axi_keep              ),        // 端口数据流掩码，有效字节指示
    .o_mac_cross_axi_data_valid         (w_mac_cross_port_axi_valid             ),        // 端口数据有效
    .i_mac_cross_axi_data_ready         (w_mac_cross_port_axi_ready             ),        // 交叉总线聚合架构反压流水线信号
    .o_mac_cross_axi_data_last          (w_mac_cross_port_axi_last              ),        // 数据流结束标识
    /*---------------------------------------- 输出到交叉总线的metadata流 -------------------------------------------*/
    .o_cross_metadata                   (w_cross_port_metadata                  ),        // 聚合总线metadata数据
    .o_cross_metadata_valid             (w_cross_port_metadata_valid            ),        // 聚合总线metadata数据有效信号
    .o_cross_metadata_last              (w_cross_port_metadata_last             ),        // 信息流结束标识
    .i_cross_metadata_ready             (w_cross_port_metadata_ready            ),        // 下游模块反压流水线
     
    /*---------------------------------------- 单 PORT 关键帧聚合信息流 -------------------------------------------*/
    .o_emac_port_axi_data               (o_emac_port_axi_data                   ) , // 端口数据流，最高位表示crcerr
    .o_emac_port_axi_user               (o_emac_port_axi_user                   ) ,
    .o_emac_axi_data_keep               (o_emac_axi_data_keep                   ) , // 端口数据流掩码，有效字节指示
    .o_emac_axi_data_valid              (o_emac_axi_data_valid                  ) , // 端口数据有效
    .i_emac_axi_data_ready              (i_emac_axi_data_ready                  ) , // 交叉总线聚合架构反压流水线信号
    .o_emac_axi_data_last               (o_emac_axi_data_last                   ) , // 数据流结束标识 
    .o_emac_metadata                    (o_emac_metadata                        ) , // 总线 metadata 数据
    .o_emac_metadata_valid              (o_emac_metadata_valid                  ) , // 总线 metadata 数据有效信号
    .o_emac_metadata_last               (o_emac_metadata_last                   ) , // 信息流结束标识
    .i_emac_metadata_ready              (i_emac_metadata_ready                  ) , // 下游模块反压流水线 
    /*---------------------------------------- 与发送端的req-ack交互 / CB -------------------------------------------*/
    .i_pass_en                          (i_pass_en                              ),        // 判断结果，可以接收该帧
    .i_discard_en                       (i_discard_en                           ),        // 判断结果，可以丢弃该帧
    .i_judge_finish                     (i_judge_finish                         ),        // 判断结果，表示本次报文的判断完成
                     
    .o_rtag_flag                        (o_rtag_flag                            ),        // 输出rtag flag给发送端
    .o_rtag_squence                     (o_rtag_squence                         ),        // 输出rtag flag给发送端
    .o_stream_handle                    (o_stream_handle                        ),        // 输出rtag flag给发送端

    .o_tx_req                           (o_tx_req                               ),        // 向发送端的req信号
    .i_mac_tx0_ack                      (i_mac_tx0_ack                          ),        // 端口0响应使能信号
    .i_mac_tx0_ack_rst                  (i_mac_tx0_ack_rst                      ),        // 端口0优先级向量结果
    .i_mac_tx1_ack                      (i_mac_tx1_ack                          ),        // 端口1响应使能信号
    .i_mac_tx1_ack_rst                  (i_mac_tx1_ack_rst                      ),        // 端口1优先级向量结果
    .i_mac_tx2_ack                      (i_mac_tx2_ack                          ),        // 端口2响应使能信号
    .i_mac_tx2_ack_rst                  (i_mac_tx2_ack_rst                      ),        // 端口2优先级向量结果
    .i_mac_tx3_ack                      (i_mac_tx3_ack                          ),        // 端口3响应使能信号
    .i_mac_tx3_ack_rst                  (i_mac_tx3_ack_rst                      ),        // 端口3优先级向量结果
    .i_mac_tx4_ack                      (i_mac_tx4_ack                          ),        // 端口4响应使能信号
    .i_mac_tx4_ack_rst                  (i_mac_tx4_ack_rst                      ),        // 端口4优先级向量结果
    .i_mac_tx5_ack                      (i_mac_tx5_ack                          ),        // 端口5响应使能信号
    .i_mac_tx5_ack_rst                  (i_mac_tx5_ack_rst                      ),        // 端口5优先级向量结果
    .i_mac_tx6_ack                      (i_mac_tx6_ack                          ),        // 端口6响应使能信号
    .i_mac_tx6_ack_rst                  (i_mac_tx6_ack_rst                      ),        // 端口6优先级向量结果
    .i_mac_tx7_ack                      (i_mac_tx7_ack                          ),        // 端口7响应使能信号
    .i_mac_tx7_ack_rst                  (i_mac_tx7_ack_rst                      ),        // 端口7优先级向量结果
    /*---------------------------------------- 平台寄存器输入 -------------------------------------------*/
    .i_port_rxmac_down_regs             (1'b0                                   ),        // 端口接收方向MAC关闭使能
    .i_port_broadcast_drop_regs         (1'b0                                   ),        // 端口广播帧丢弃使能
    .i_port_multicast_drop_regs         (1'b0                                   ),        // 端口组播帧丢弃使能
    .i_port_loopback_drop_regs          (1'b0                                   ),        // 端口环回帧丢弃使能
    .i_port_mac_regs                    (48'h0                                  ),        // 端口的MAC地址
    .i_port_mac_vld_regs                (1'b0                                   ),        // 使能端口MAC地址有效
    .i_port_mtu_regs                    (16'd1518                               ),        // MTU配置值
    .i_port_mirror_frwd_regs            ({PORT_NUM{1'b0}}                       ),        // 镜像转发寄存器
    .i_port_flowctrl_cfg_regs           (32'h0                                  ),        // 限流管理配置
    .i_port_rx_ultrashortinterval_num   (16'd64                                 ),        // 帧间隔
    /*---------------------------------------- ACL寄存器 -------------------------------------------*/
    .i_acl_port_sel                     (3'b0                                   ),        // 选择要配置的端口
    .i_acl_clr_list_regs                (1'b0                                   ),        // 清空寄存器列表
    .o_acl_list_rdy_regs                (                                       ),        // 配置寄存器操作空闲
    .i_acl_item_sel_regs                (10'b0                                  ),        // 配置条目选择
    .i_acl_item_waddr_regs              (6'b0                                   ),        // 每个条目最大支持比对64字节
    .i_acl_item_din_regs                (8'h0                                   ),        // 需要比较的字节数据
    .i_acl_item_we_regs                 (1'b0                                   ),        // 配置使能信号
    .i_acl_item_rslt_regs               (16'h0                                  ),        // 匹配的结果值
    .i_acl_item_complete_regs           (1'b0                                   ),        // 端口ACL参数配置完成使能信号
    /*---------------------------------------- 状态和诊断寄存器 -------------------------------------------*/
    .o_port_diag_state                  (                                       ),        // 端口状态寄存器
    .o_port_rx_ultrashort_frm           (                                       ),        // 端口接收超短帧
    .o_port_rx_overlength_frm           (                                       ),        // 端口接收超长帧
    .o_port_rx_crcerr_frm               (                                       ),        // 端口接收CRC错误帧
    .o_port_rx_loopback_frm_cnt         (                                       ),        // 端口接收环回帧计数器值
    .o_port_broadflow_drop_cnt          (                                       ),        // 端口广播限流丢弃帧计数器值
    .o_port_multiflow_drop_cnt          (                                       ),        // 端口组播限流丢弃帧计数器值
    .o_port_rx_byte_cnt                 (                                       ),        // 端口接收字节个数计数器值
    .o_port_rx_frame_cnt                (                                       )         // 端口接收帧个数计数器值
);

endmodule