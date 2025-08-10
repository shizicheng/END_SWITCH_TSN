module rx_port_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽 
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
    input               wire                                    i_mac_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac_axi_data_last                , // 数据流结束标识
    /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
    output              wire                                    o_mac_time_irq                      , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac_frame_seq                     , // 帧序列号
    output              wire  [7:0]                             o_timestamp_addr                    , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac                             , // 目的 mac 的值
    output              wire                                    o_dmac_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac                             , // 源 mac 的值
    output              wire                                    o_smac_vld                         , // smac_vld
    /*---------------------------------------- 查找的转发端口号 ---------------------------------------*/
    input               wire   [PORT_NUM-1:0]                   i_swlist_tx_port                   , // 交换发送端口信息
    input               wire                                    i_swlist_vld                       , // 发送端口信号有效信号
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_cross_metadata                   , // 总线 metadata 数据
    output             wire                                     o_cross_metadata_valid             , // 总线 metadata 数据有效信号
    output             wire                                     o_cross_metadata_last              , // 信息流结束标识
    input              wire                                     i_cross_metadata_ready             , // 下游模块反压流水线 

    //qbu验证信号
    output             wire                                     o_qbu_verify_valid                 ,
    output             wire                                     o_qbu_response_valid               ,
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
            [10:4](7bit) ：time_stamp_addr，报文时间戳的地址信息
    */
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
    input              wire   [5:0]                             i_acl_item_waddr_regs              , // 每个条目最大支持比对 64 字节
    input              wire   [7:0]                             i_acl_item_din_regs                , // 需要比较的字节数据
    input              wire                                     i_acl_item_we_regs                 , // 配置使能信号
    input              wire   [15:0]                            i_acl_item_rslt_regs               , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    input              wire                                     i_acl_item_complete_regs           , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    output             wire   [15:0]                            o_port_diag_state                  , // 端口状态寄存器，详情见寄存器表说明定义 
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
wire                                    w_qbu_mac_axi_data_valid            ;        
wire                                    w_qbu_mac_axi_data_ready            ;             
wire                                    w_qbu_mac_axi_data_last             ; 


// 限流后输出的数据流
wire                                    w_stream_port_link                  ; // 端口的连接状态
wire   [1:0]                            w_stream_port_speed                 ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
wire   [CROSS_DATA_WIDTH:0]             w_stream_port_axi_data              ; // 端口数据流，最高位表示crcerr
wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_stream_axi_data_keep              ; // 端口数据流掩码，有效字节指示
wire                                    w_stream_axi_data_valid             ; // 端口数据有效  
 wire                                   w_stream_axi_data_last              ;            

wire                                    w_mac_time_irq                      ; // 打时间戳中断信号
wire  [7:0]                             w_mac_frame_seq                     ; // 帧序列号
wire  [7:0]                             w_timestamp_addr                    ; // 打时间戳存储的 RAM 地址

wire  [15:0]                            w_port_rx_byte_cnt                  ; // 端口0接收字节个数计数器值
wire  [15:0]                            w_port_rx_frame_cnt                 ; // 端口0接收帧个数计数器值 

wire                                    w_mac_cross_port_link               ;
wire   [1:0]                            w_mac_cross_port_speed              ;
wire   [CROSS_DATA_WIDTH:0]             w_mac_cross_port_axi_data           ;
wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac_cross_axi_data_keep           ;
wire                                    w_mac_cross_axi_data_valid          ;
wire                                    w_mac_cross_axi_data_ready          ;
wire                                    w_mac_cross_axi_data_last           ;

// rx_frm_info_mng 的输出信息
wire                                    w_mac_frm_info_cross_axi_data_ready ;
wire                                    w_port_speed                        ;
wire   [2:0]                            w_vlan_pri                          ;
wire                                    w_frm_vlan_flag                     ;
wire   [PORT_NUM-1:0]                   w_rx_port                           ;
wire   [1:0]                            w_frm_cb_op                         ;
wire                                    w_frm_qbu                           ;
wire   [7:0]                            w_dmac_data                         ;
wire                                    w_damac_data_vld                    ;
wire                                    w_dmac_soc                          ;
wire                                    w_dmac_eoc                          ;
wire   [7:0]                            w_smac_data                         ;
wire                                    w_samac_data_vld                    ;
wire                                    w_smac_soc                          ;
wire                                    w_smac_eoc                          ;
wire                                    w_frm_info_vld                      ;
wire                                    w_broadcast_frm_en                  ;
wire                                    w_multicast_frm_en                  ;
wire                                    w_lookback_frm_en                   ;

// rx_frm_acl_mng 的输出信息
wire                                    w_mac_frm_acl_axi_data_ready        ;
wire                                    w_acl_vld                           ; 
wire                                    w_acl_find_match                    ; 
wire   [7:0]                            w_acl_frmtype                       ; 
wire   [15:0]                           w_acl_fetch_info                    ;
wire                                    w_acl_list_rdy_regs                 ;


wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_hash_key                    ; // 目的 mac 的哈希值
wire   [47 : 0]                         w_dmac                             ; // 目的 mac 的值
wire                                    w_dmac_vld                         ; // dmac_vld
wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_hash_key                    ; // 源 mac 的值有效标识
wire   [47 : 0]                         w_smac                             ; // 源 mac 的值
wire                                    w_smac_vld                         ; // smac_vld

wire   [METADATA_WIDTH-1:0]             w_cross_metadata                   ; // 聚合总线 metadata 数据
wire                                    w_cross_metadata_valid             ; // 聚合总线 metadata 数据有效
wire                                    w_cross_metadata_last              ; // 信息流结束标识
wire                                    w_cross_metadata_ready             ; // 下游模块反压流水线 

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
wire   [15:0]                           w_verify_timer                     ;
wire                                    w_verify_timer_vld                 ;
wire   [15:0]                           w_err_verify_cnt                   ;
wire                                    w_preempt_enable                   ;

/* ------------------------------ 内部数据流链接 ------------------------------- */
assign              w_mac_cross_port_link               =      o_mac_cross_port_link        ;
assign              w_mac_cross_port_speed              =      o_mac_cross_port_speed       ;
assign              w_mac_cross_port_axi_data           =      o_mac_cross_port_axi_data    ;
assign              w_mac_cross_axi_data_keep           =      o_mac_cross_axi_data_keep    ;
assign              w_mac_cross_axi_data_valid          =      o_mac_cross_axi_data_valid   ;
assign              i_mac_cross_axi_data_ready          =      w_mac_cross_axi_data_ready   ;
assign              w_mac_cross_axi_data_last           =      o_mac_cross_axi_data_last    ;

/* ------------------------------ 顶层模块数据流链接 ------------------------------- */
// input
assign              w_mac_port_link                     =      i_mac_port_link              ;
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
assign              w_acl_item_waddr_regs               =      i_acl_item_waddr_regs        ;   
assign              w_acl_item_din_regs                 =      i_acl_item_din_regs          ;   
assign              w_acl_item_we_regs                  =      i_acl_item_we_regs           ;   
assign              w_acl_item_rslt_regs                =      i_acl_item_rslt_regs         ;   
assign              w_acl_item_complete_regs            =      i_acl_item_complete_regs     ;   

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

assign              o_dmac_hash_key                     =      w_dmac_hash_key              ;
assign              o_dmac                              =      w_dmac                       ;
assign              o_dmac_vld                          =      w_dmac_vld                   ;
assign              o_smac_hash_key                     =      w_smac_hash_key              ;
assign              o_smac                              =      w_smac                       ;
assign              o_smac_vld                          =      w_smac_vld                   ;

assign              o_cross_metadata                    =      w_cross_metadata             ;
assign              o_cross_metadata_valid              =      w_cross_metadata_valid       ;
assign              o_cross_metadata_last               =      w_cross_metadata_last        ;
assign              i_cross_metadata_ready              =      w_cross_metadata_ready       ;

assign              o_port_rx_ultrashort_frm            =      w_port_rx_ultrashort_frm     ;
assign              o_port_rx_overlength_frm            =      w_port_rx_overlength_frm     ;   
assign              o_port_rx_crcerr_frm                =      w_port_rx_crcerr_frm         ;       
assign              o_port_rx_loopback_frm_cnt          =      w_port_rx_loopback_frm_cnt   ;   
assign              o_port_broadflow_drop_cnt           =      w_port_broadflow_drop_cnt    ;   
assign              o_port_multiflow_drop_cnt           =      w_port_multiflow_drop_cnt    ;   
assign              o_port_diag_state                   =      w_port_diag_state            ;


/* ------------------------------ 帧抢占接收通路 ------------------------------- */
/* ------------------------------ 帧抢占接收通路 ------------------------------- */
qbu_rec #(
    .DWIDTH                           (PORT_MNG_DATA_WIDTH          )
) qbu_rec_inst (          
    .i_clk                            (i_clk                        ),
    .i_rst                            (i_rst                        ),
    //接口层输入数据流
    .i_mac_axi_data                   (w_mac_axi_data               ), 
    .i_mac_axi_data_keep              (w_mac_axi_data_keep          ), 
    .i_mac_axi_data_valid             (w_mac_axi_data_valid         ), 
    .o_mac_axi_data_ready             (w_mac_axi_data_ready         ), 
    .i_mac_axi_data_last              (w_mac_axi_data_last          ), 
    //输出给tx_mac，验证qbu功能
    .o_qbu_verify_valid               (i_qbu_verify_valid           ),
    .o_qbu_response_valid             (i_qbu_response_valid         ),
    //输出qbu emac和pmac通道数据，emac通道数据中断输出
    .o_qbu_rx_axis_data               (w_qbu_mac_axi_data           ),
    .o_qbu_rx_axis_user               (                             ),
    .o_qbu_rx_axis_keep               (w_qbu_mac_axi_data_keep      ),
    .o_qbu_rx_axis_last               (w_qbu_mac_axi_data_last      ),
    .o_qbu_rx_axis_valid              (w_qbu_mac_axi_data_valid     ),
    .i_qbu_rx_axis_ready              (w_qbu_mac_axi_data_ready     ),  
    // 打时间戳信号
    .o_mac_time_irq                   (w_mac_time_irq               ),  
    .o_mac_frame_seq                  (w_mac_frame_seq              ),  
    .o_timestamp_addr                 (w_timestamp_addr             ),    
    //qbu寄存器管理
    .o_rx_busy                        (w_rx_busy             	    ), 
    .o_rx_fragment_cnt                (w_rx_fragment_cnt     	    ), 
    .o_rx_fragment_mismatch           (w_rx_fragment_mismatch	    ), 
    .o_err_rx_crc_cnt                 (w_err_rx_crc_cnt      	    ), 
    .o_err_rx_frame_cnt               (w_err_rx_frame_cnt    	    ), 
    .o_err_fragment_cnt               (w_err_fragment_cnt    	    ), 
    .o_rx_frames_cnt                  (w_rx_frames_cnt       	    ), 
    .o_frag_next_rx                   (w_frag_next_rx        	    ), 
    .o_frame_seq                      (w_frame_seq           	    )  
);

/* -------------- 数据流控模块（用户可配置限流寄存器，使能端口限流） ------------------ */
rx_byte_stream_ctrl #(
    .PORT_NUM                        (PORT_NUM                      )   ,  // 交换机的端口数
    .PORT_MNG_DATA_WIDTH             (PORT_MNG_DATA_WIDTH           )   ,  // Mac_port_mng 数据位宽
    .CROSS_DATA_WIDTH                (CROSS_DATA_WIDTH              )      // 聚合总线输出
)rx_byte_stream_ctrl_inst(
    .i_clk                           (i_clk                         )   ,  // 250MHz
    .i_rst                           (i_rst                         )   ,
    /*---------------------------------------- 限流配置的寄存器接口 -------------------------------------------*/
    .i_port_flowctrl_cfg_regs        (w_port_flowctrl_cfg_regs      )   , // 限流管理配置
    /*---------------------------------------- 统计寄存器输出 -------------------------------------------*/
    .o_port_rx_byte_cnt              ( w_port_rx_byte_cnt           )   , // 端口接收字节个数计数器值 
    .o_port_rx_frame_cnt             ( w_port_rx_frame_cnt          )   , // 接收帧个数计数器值
    /*---------------------------------------- 经过qbu重组之后的数据流 -------------------------------------------*/
    .i_mac_cross_port_link           ( w_qbu_mac_port_link          )  , // 端口的连接状态
    .i_mac_cross_port_speed          ( w_qbu_mac_port_speed         )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac_cross_port_axi_data       ( w_qbu_mac_axi_data           )  , // 端口数据流，最高位表示crcerr
    .i_mac_cross_axi_data_keep       ( w_qbu_mac_axi_data_keep      )  , // 端口数据流掩码，有效字节指示
    .i_mac_cross_axi_data_valid      ( w_qbu_mac_axi_data_valid     )  , // 端口数据有效
    .o_mac_cross_axi_data_ready      ( w_qbu_mac_axi_data_ready     )  , // 交叉总线聚合架构反压流水线信号
    .i_mac_cross_axi_data_last       ( w_qbu_mac_axi_data_last      )  , // 数据流结束标识 
    /*---------------------------------------- 限流后的数据流输出 -------------------------------------------*/
    .o_stream_port_link              ( w_stream_port_link           )   , // 端口的连接状态
    .o_stream_port_speed             ( w_stream_port_speed          )   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_stream_port_axi_data          ( w_stream_port_axi_data       )   , // 端口数据流，最高位表示crcerr
    .o_stream_axi_data_keep          ( w_stream_axi_data_keep       )   , // 端口数据流掩码，有效字节指示
    .o_stream_axi_data_valid         ( w_stream_axi_data_valid      )   , // 端口数据有效
    .o_stream_axi_data_last          ( w_stream_axi_data_last       )              
);

/* ----------------------------- 数据流基本信息提取（流水线操作） -------------------------------- */
rx_frm_info_mng#(
    .PORT_NUM                       (PORT_NUM                               )   ,
    .PORT_MNG_DATA_WIDTH            (PORT_MNG_DATA_WIDTH                    )   ,
    .CROSS_DATA_WIDTH               (CROSS_DATA_WIDTH                       )   
)rx_frm_info_mng_inst (     
    .i_clk                          (i_clk                                  )   , 
    .i_rst                          (i_rst                                  )   ,
    /*---------------------------------------- 单 PORT 聚合数据流 ----------------------------------*/
    .i_mac_port_link                (w_stream_port_link                     )   , 
    .i_mac_port_speed               (w_stream_port_speed                    )   , 
    .i_mac_port_axi_data            (w_stream_port_axi_data                 )   , 
    .i_mac_axi_data_keep            (w_stream_axi_data_keep                 )   , 
    .i_mac_axi_data_valid           (w_stream_axi_data_valid                )   , 
    .o_mac_axi_data_ready           (w_mac_frm_info_cross_axi_data_ready    )   , 
    .i_mac_axi_data_last            (w_stream_axi_data_last                 )   , 
    /* 单 PORT 部分信息流（此模块无法解析出所有的信息，[26:19](8bit) : 输入端口，bitmap表示，[51:44](8bit) : acl_frmtype，[43:28](16bit): acl_fetchinfo）*/
    .o_port_speed                   (w_port_speed                   )   , 
    .o_vlan_pri                     (w_vlan_pri                     )   , 
    .o_frm_vlan_flag                (w_frm_vlan_flag                )   , 
    .o_rx_port                      (w_rx_port                      )   , 
    .o_frm_cb_op                    (w_frm_cb_op                    )   , 
    .o_frm_qbu                      (w_frm_qbu                      )   ,
    /*-------------------------- 内部处理所需的信息流，不作为 metadata 的信息流 ----------------------------*/ 
    // 提取哈希计算需要的输入值
    .o_dmac_data                    (w_dmac_data                    )   ,
    .o_damac_data_vld               (w_damac_data_vld               )   ,
    .o_dmac_soc                     (w_dmac_soc                     )   ,
    .o_dmac_eoc                     (w_dmac_eoc                     )   ,
    .o_smac_data                    (w_smac_data                    )   ,
    .o_samac_data_vld               (w_samac_data_vld               )   ,
    .o_smac_soc                     (w_smac_soc                     )   ,
    .o_smac_eoc                     (w_smac_eoc                     )   ,
    // 提取转发控制模块需要的信息
    .o_frm_info_vld                 (w_frm_info_vld                 )   ,
    .o_broadcast_frm_en             (w_broadcast_frm_en             )   ,
    .o_multicast_frm_en             (w_multicast_frm_en             )   ,
    .o_lookback_frm_en              (w_lookback_frm_en              )   
);

/* ----------------------------- ACL信息提取（流水线操作） -------------------------------- */
rx_frm_acl_mng #(
    .PORT_NUM                       (PORT_NUM                       )    ,
    .PORT_MNG_DATA_WIDTH            (PORT_MNG_DATA_WIDTH            )    ,
    .CROSS_DATA_WIDTH               (CROSS_DATA_WIDTH               )     
)rx_frm_acl_mng_inst (   
    .i_clk                          (i_clk                          )    ,   // 250MHz
    .i_rst                          (i_rst                          )    ,
    /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
    .i_mac_port_link                (w_mac_cross_port_link          )    , // 端口的连接状态
    .i_mac_port_speed               (w_mac_cross_port_speed         )    , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac_port_axi_data            (w_mac_cross_port_axi_data      )    , // 端口数据流，最高位表示crcerr
    .i_mac_axi_data_keep            (w_mac_cross_axi_data_keep      )    , // 端口数据流掩码，有效字节指示
    .i_mac_axi_data_valid           (w_mac_cross_axi_data_valid     )    , // 端口数据有效
    .o_mac_axi_data_ready           (w_mac_frm_acl_axi_data_ready   )    , // 交叉总线聚合架构反压流水线信号
    .i_mac_axi_data_last            (w_mac_cross_axi_data_last      )    , // 数据流结束标识
    /*---------------------------------------- ACL 寄存器 -------------------------------------------*/
    .i_acl_port_sel                 (w_acl_port_sel                 )    , // 选择要配置的端口
    .i_acl_clr_list_regs            (w_acl_clr_list_regs            )    , // 清空寄存器列表
    .o_acl_list_rdy_regs            (w_acl_list_rdy_regs            )    , // 配置寄存器操作空闲
    .i_acl_item_sel_regs            (w_acl_item_sel_regs            )    , // 配置条目选择
    .i_acl_item_waddr_regs          (w_acl_item_waddr_regs          )    , // 每个条目最大支持比对 64 字节
    .i_acl_item_din_regs            (w_acl_item_din_regs            )    , // 需要比较的字节数据
    .i_acl_item_we_regs             (w_acl_item_we_regs             )    , // 配置使能信号
    .i_acl_item_rslt_regs           (w_acl_item_rslt_regs           )    , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .i_acl_item_complete_regs       (w_acl_item_complete_regs       )    , // 端口 ACL 参数配置完成使能信号      
    /*---------------------------------------- ACL 匹配后输出的字段 -------------------------------------------*/ 
    .o_acl_vld                      (w_acl_vld                      )    , // acl匹配表的有效输出信号
    .o_acl_find_match               (w_acl_find_match               )    , // 是否匹配到正确的条目
    .o_acl_frmtype                  (w_acl_frmtype                  )    , // 匹配出来的帧类型
    .o_acl_fetch_info               (w_acl_fetch_info               )      // 待定保留
);

rx_mac_hash_calc#(
    .CWIDTH                         (HASH_DATA_WIDTH                )
)rx_mac_hash_calc_inst (          
    .i_clk                          (i_clk                          )    ,   // 250MHz
    .i_rst                          (i_rst                          )    ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    .i_hash_poly_regs               (i_hash_ploy_regs               )    ,
    .i_hash_init_val_regs           (i_hash_init_val_regs           )    ,
    .i_hash_regs_vld                (i_hash_regs_vld                )    ,
    /*--------------------------------- 信息提取模块输入的 MAC 信息 -------------------------------------*/
    .i_dmac_data                    (w_dmac_data                    )    , // 目的 MAC 地址的值
    .i_damac_data_vld               (w_damac_data_vld               )    , // 数据有效值
    .i_dmac_soc                     (w_dmac_soc                     )    ,
    .i_dmac_eoc                     (w_dmac_eoc                     )    ,
    .i_smac_data                    (w_smac_data                    )    , // 源 MAC 地址的值
    .i_samac_data_vld               (w_samac_data_vld               )    , // 数据有效值
    .i_smac_soc                     (w_smac_soc                     )    ,
    .i_smac_eoc                     (w_smac_eoc                     )    ,    
    /*--------------------------------- 输出 hash 的计算结果 -------------------------------------*/     
    .o_dmac_hash_key                (w_dmac_hash_key                )    ,
    .o_dmac                         (w_dmac                         )    ,
    .o_dmac_vld                     (w_dmac_vld                     )    , 
    .s_dmac_hash_key                (w_smac_hash_key                )    ,
    .s_dmac                         (w_smac                         )    ,
    .s_dmac_vld                     (w_smac_vld                     )               
);

rx_forward_mng#(
    .PORT_NUM                           (PORT_NUM                       ) , // 交换机的端口数
    .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH            ) , // Mac_port_mng 数据位宽
    .METADATA_WIDTH                     (METADATA_WIDTH                 ) , // 信息流位宽
    .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH               )   // 聚合总线输出
)rx_forward_mng_inst (
    .i_clk                              (i_clk                          )    ,   // 250MHz
    .i_rst                              (i_rst                          )    ,
    /*---------------------------------------- 控制转发相关的寄存器 -------------------------------------------*/
    .i_port_rxmac_down_regs             (w_port_rxmac_down_regs          )   , // 端口接收方向MAC关闭使能
    .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs      )   , // 端口广播帧丢弃使能
    .i_port_multicast_drop_regs         (w_port_multicast_drop_regs      )   , // 端口组播帧丢弃使能
    .i_port_loopback_drop_regs          (w_port_loopback_drop_regs       )   , // 端口环回帧丢弃使能
    .i_port_mac_regs                    (w_port_mac_regs                 )   , // 端口的 MAC 地址
    .i_port_mac_vld_regs                (w_port_mac_vld_regs             )   , // 使能端口 MAC 地址有效
    .i_port_mtu_regs                    (w_port_mtu_regs                 )   , // MTU配置值
    .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs         )   , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs        )   , // 限流管理配置                                                                        
    .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num)   , // 帧间隔                                                                          
    /*---------------------------------------- rx_frm_info_mng输出的信息流 -------------------------------------------*/
    .i_port_speed                       (w_port_speed                   )    , // [63](1bit) : port_speed 
    .i_vlan_pri                         (w_vlan_pri                     )    , // [62:60](3bit) : vlan_pri 
    .i_frm_vlan_flag                    (w_frm_vlan_flag                )    , // [27](1bit) : frm_vlan_flag
    .i_rx_port                          (w_rx_port                      )    , // [26:19](8bit) : 输入端口，bitmap表示
    .i_frm_cb_op                        (w_frm_cb_op                    )    , // [14:13](2bit) : 冗余复制与消除(cb)，01表示复制，10表示消除，00表示非CB业务帧  
    .i_frm_qbu                          (w_frm_qbu                      )    , // [11](1bit) : 是否为关键帧(Qbu)
    // 内部信息处理使用，不作为metadata字段
    .i_frm_info_vld                     (w_frm_info_vld                 )   , // 帧信息有效 
    .i_broadcast_frm_en                 (w_broadcast_frm_en             )   , // 广播帧 
    .i_multicast_frm_en                 (w_multicast_frm_en             )   , // 组播帧 
    .i_lookback_frm_en                  (w_lookback_frm_en              )   , // 环回帧  
    /*---------------------------------------- 查表模块根据哈希值返回的计算结果 ----------------------------------*/
    .i_swlist_tx_port                   (w_swlist_tx_port               )   , // 发送端口信息   
    .i_swlist_vld                       (w_swlist_vld                   )   , // 有效使能信号       
    /*---------------------------------------- ACL 匹配后输出的字段 -------------------------------------------*/
    .i_acl_vld                          (w_acl_vld                      )   , // acl匹配表的有效输出信号
    .i_acl_find_match                   (w_acl_find_match               )   , // 是否匹配到正确的条目
    .i_acl_frmtype                      (w_acl_frmtype                  )   , // 匹配出来的帧类型
    .i_acl_fetch_info                   (w_acl_fetch_info               )   ,  // 待定保留 
    /*---------------------------------------- 单 PORT 数据流输入 -------------------------------------------*/
    .i_mac_port_link                    (w_qbu_mac_port_link           )    , // 端口的连接状态
    .i_mac_port_speed                   (w_qbu_mac_port_speed          )    , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac_port_axi_data                (w_qbu_mac_axi_data            )    , // 端口数据流，最高位表示crcerr
    .i_mac_axi_data_keep                (w_qbu_mac_axi_data_keep       )    , // 端口数据流掩码，有效字节指示
    .i_mac_axi_data_valid               (w_qbu_mac_axi_data_valid      )    , // 端口数据有效
    .o_mac_axi_data_ready               (      )    , // 交叉总线聚合架构反压流水线信号
    .i_mac_axi_data_last                (w_qbu_mac_axi_data_last       )    , // 数据流结束标识
    /*---------------------------------------- 单 PORT 数据流输出 -------------------------------------------*/
    .o_mac_port_link                    (w_mac_cross_port_link          )    , // 端口的连接状态
    .o_mac_port_speed                   (w_mac_cross_port_speed         )    , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac_port_axi_data                (w_mac_cross_port_axi_data      )    , // 端口数据流，最高位表示crcerr
    .o_mac_axi_data_keep                (w_mac_cross_axi_data_keep      )    , // 端口数据流掩码，有效字节指示
    .o_mac_axi_data_valid               (w_mac_cross_axi_data_valid     )    , // 端口数据有效
    .i_mac_axi_data_ready               (w_mac_cross_axi_data_ready     )    , // 交叉总线聚合架构反压流水线信号
    .o_mac_axi_data_last                (w_mac_cross_axi_data_last      )    , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_cross_metadata                   (w_cross_metadata               )   , // 聚合总线 metadata 数据
    .o_cross_metadata_valid             (w_cross_metadata_valid         )   , // 聚合总线 metadata 数据有效信号
    .o_cross_metadata_last              (w_cross_metadata_last          )   , // 信息流结束标识
    .i_cross_metadata_ready             (w_cross_metadata_ready         )   , // 下游模块反压流水线 
    /*---------------------------------------- 诊断寄存器 -------------------------------------------*/
    .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm       )   ,  // 端口接收超短帧(小于64字节)
    .o_port_rx_overlength_frm           (w_port_rx_overlength_frm       )   ,  // 端口接收超长帧(大于MTU字节)
    .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm           )   ,  // 端口接收CRC错误帧
    .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt     )   ,  // 端口接收环回帧计数器值
    .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt      )   ,  // 端口接收到广播限流而丢弃的帧计数器值
    .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt      )   ,  // 端口接收到组播限流而丢弃的帧计数器值  
    .o_port_diag_state                  (w_port_diag_state              )   
);



endmodule