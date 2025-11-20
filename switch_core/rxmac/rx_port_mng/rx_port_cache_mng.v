/*
 * 功能：
 *  
 */

 
`timescale 1ns / 1ns
module rx_port_cache_mng#(
    parameter                                                           PORT_NUM                    = 8                         , // 交换机的端口数
    parameter                                                           PORT_MNG_DATA_WIDTH         = 8                         , // Mac_port_mng 数据位宽
    parameter                                                           METADATA_WIDTH              = 81                        , // 信息流位宽
    parameter                                                           CROSS_DATA_WIDTH            = 8                         , // 聚合总线输出
    parameter                                                           PORT_FIFO_PRI_NUM           = 8                         , // 优先级FIFO数量
    parameter                                                           RAM_DEPTH                   = 1024                      , // RAM深度
    parameter                                                           RAM_ADDR_WIDTH              = 10                        , // RAM地址宽度
    parameter                                                           FIFO_DEPTH                  = 512                      , // FIFO深度
    parameter                                                           REQ_TIMEOUT_CNT             = 1250                      , // req超时计数值(5us @ 250MHz)
    parameter                                                           TIMEOUT_CNT_WIDTH           = 11                         // 超时计数器位宽
)(
    /*---------------------------------------- 时钟和复位 -------------------------------------------*/
    input               wire                                            i_clk                               , // 250MHz
    input               wire                                            i_rst                               ,
    
    /*---------------------------------------- 输入的MAC数据流 -------------------------------------------*/
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]                i_mac_axi_data                     , // 端口数据流  
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]            i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                            i_mac_axi_data_valid               , // 端口数据有效
    output              wire                                            o_mac_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                            i_mac_axi_data_last                , // 数据流结束标识
    input               wire   [15:0]                                   i_mac_axi_data_user                , // 是否关键帧 + 报文长度
    
    /*---------------------------------------- 输入的metadata流 -------------------------------------------*/
    input               wire   [METADATA_WIDTH-1:0]                     i_cross_metadata                   , // 输入metadata数据
    input               wire                                            i_cross_metadata_valid             , // 输入metadata数据有效信号
    input               wire                                            i_cross_metadata_last              , // 输入metadata结束标识
    output              wire                                            o_cross_metadata_ready             , // metadata反压流水线

    /*---------------------------------------- 输出到交叉总线的数据流 -------------------------------------------*/ 

    output              wire   [15:0]                                   o_mac_cross_port_axi_user          , // 是否关键帧 + 报文长度
    output              wire   [CROSS_DATA_WIDTH-1:0]                   o_mac_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]               o_mac_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                            o_mac_cross_axi_data_valid         , // 端口数据有效
    input               wire                                            i_mac_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                            o_mac_cross_axi_data_last          , // 数据流结束标识
    
    /*---------------------------------------- 输出到交叉总线的metadata流 -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]                     o_cross_metadata                   , // 聚合总线metadata数据
    output              wire                                            o_cross_metadata_valid             , // 聚合总线metadata数据有效信号
    output              wire                                            o_cross_metadata_last              , // 信息流结束标识
    input               wire                                            i_cross_metadata_ready             , // 下游模块反压流水线
    
    /*---------------------------------------- 单 PORT 关键帧输出数据流 -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]                   o_emac_port_axi_data               , // 端口数据流，最高位表示crcerr
    output              wire   [15:0]                                   o_emac_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]               o_emac_axi_data_keep               , // 端口数据流掩码，有效字节指示
    output              wire                                            o_emac_axi_data_valid              , // 端口数据有效
    input               wire                                            i_emac_axi_data_ready              , // 交叉总线聚合架构反压流水线信号
    output              wire                                            o_emac_axi_data_last               , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]                     o_emac_metadata                    , // 总线 metadata 数据
    output              wire                                            o_emac_metadata_valid              , // 总线 metadata 数据有效信号
    output              wire                                            o_emac_metadata_last               , // 信息流结束标识
    input               wire                                            i_emac_metadata_ready              , // 下游模块反压流水线 
    
    /*---------------------------------------- 与发送端的req-ack交互 -------------------------------------------*/
    output              wire                                            o_rtag_flag                        , // 是否携带rtag标签,是CB业务帧,需要先过CB模块觉定是否丢弃后,再送入crossbar
    output              wire   [15:0]                                   o_rtag_squence                     , // rtag_squencenum
    output              wire   [7:0]                                    o_stream_handle                    , // ACL流识别,区分流，每个流单独维护自己的

    input               wire                                            i_pass_en                          , // 判断结果，可以接收该帧
    input               wire                                            i_discard_en                       , // 判断结果，可以丢弃该帧
    input               wire                                            i_judge_finish                     , // 判断结果，表示本次报文的判断完成

    output              wire                                            o_tx_req                           , // 向发送端的req信号
    input               wire                                            i_mac_tx0_ack                      , // 端口0响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx0_ack_rst                  , // 端口0优先级向量结果
    input               wire                                            i_mac_tx1_ack                      , // 端口1响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx1_ack_rst                  , // 端口1优先级向量结果  
    input               wire                                            i_mac_tx2_ack                      , // 端口2响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx2_ack_rst                  , // 端口2优先级向量结果
    input               wire                                            i_mac_tx3_ack                      , // 端口3响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx3_ack_rst                  , // 端口3优先级向量结果
    input               wire                                            i_mac_tx4_ack                      , // 端口4响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx4_ack_rst                  , // 端口4优先级向量结果
    input               wire                                            i_mac_tx5_ack                      , // 端口5响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx5_ack_rst                  , // 端口5优先级向量结果
    input               wire                                            i_mac_tx6_ack                      , // 端口6响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx6_ack_rst                  , // 端口6优先级向量结果
    input               wire                                            i_mac_tx7_ack                      , // 端口7响应使能信号
    input               wire   [PORT_FIFO_PRI_NUM-1:0]                  i_mac_tx7_ack_rst                  , // 端口7优先级向量结果
    
    /*---------------------------------------- 平台寄存器输入 -------------------------------------------*/
    input               wire                                            i_port_rxmac_down_regs             , // 端口接收方向MAC关闭使能
    input               wire                                            i_port_broadcast_drop_regs         , // 端口广播帧丢弃使能
    input               wire                                            i_port_multicast_drop_regs         , // 端口组播帧丢弃使能
    input               wire                                            i_port_loopback_drop_regs          , // 端口环回帧丢弃使能
    input               wire   [47:0]                                   i_port_mac_regs                    , // 端口的MAC地址
    input               wire                                            i_port_mac_vld_regs                , // 使能端口MAC地址有效
    input               wire   [15:0]                                   i_port_mtu_regs                    , // MTU配置值
    input               wire   [PORT_NUM-1:0]                           i_port_mirror_frwd_regs            , // 镜像转发寄存器
    input               wire   [31:0]                                   i_port_flowctrl_cfg_regs           , // 限流管理配置
    input               wire   [15:0]                                   i_port_rx_ultrashortinterval_num   , // 帧间隔
    
    /*---------------------------------------- ACL寄存器 -------------------------------------------*/
    input               wire   [2:0]                                    i_acl_port_sel                     , // 选择要配置的端口
    input               wire                                            i_acl_clr_list_regs                , // 清空寄存器列表
    output              wire                                            o_acl_list_rdy_regs                , // 配置寄存器操作空闲
    input               wire   [9:0]                                    i_acl_item_sel_regs                , // 配置条目选择
    input               wire   [5:0]                                    i_acl_item_waddr_regs              , // 每个条目最大支持比对64字节
    input               wire   [7:0]                                    i_acl_item_din_regs                , // 需要比较的字节数据
    input               wire                                            i_acl_item_we_regs                 , // 配置使能信号
    input               wire   [15:0]                                   i_acl_item_rslt_regs               , // 匹配的结果值
    input               wire                                            i_acl_item_complete_regs           , // 端口ACL参数配置完成使能信号
    
    /*---------------------------------------- 状态和诊断寄存器 -------------------------------------------*/
    output              wire   [31:0]                                   o_port_diag_state                  , // 端口状态寄存器
    output              wire   [31:0]                                   o_port_rx_ultrashort_frm           , // 端口接收超短帧
    output              wire   [31:0]                                   o_port_rx_overlength_frm           , // 端口接收超长帧
    output              wire   [31:0]                                   o_port_rx_crcerr_frm               , // 端口接收CRC错误帧
    output              wire   [31:0]                                   o_port_rx_loopback_frm_cnt         , // 端口接收环回帧计数器值
    output              wire   [31:0]                                   o_port_broadflow_drop_cnt          , // 端口广播限流丢弃帧计数器值
    output              wire   [31:0]                                   o_port_multiflow_drop_cnt          , // 端口组播限流丢弃帧计数器值
    output              wire   [63:0]                                   o_port_rx_byte_cnt                 , // 端口接收字节个数计数器值
    output              wire   [31:0]                                   o_port_rx_frame_cnt                  // 端口接收帧个数计数器值
);

/*---------------------------------------- 内部参数定义 -------------------------------------------*/
localparam                  QUEUE_SIZE              = 32                                                    ; // 队列最大容量
localparam                  QUEUE_ADDR_WIDTH        = 5                                                     ; // 队列地址位宽
localparam                  FRAME_INFO_WIDTH        = METADATA_WIDTH + 16                                   ; // 帧信息位宽(metadata + user)
localparam                  TIMEOUT_CNT_MAX         = REQ_TIMEOUT_CNT - 1                                   ; // 超时计数最大值

/*---------------------------------------- 内部寄存器和线网声明 -------------------------------------------*/

// 输入打拍信号
reg                                     ri_mac_axi_data_valid          ;
reg    [PORT_MNG_DATA_WIDTH-1:0]        ri_mac_axi_data                ;
reg    [(PORT_MNG_DATA_WIDTH/8)-1:0]    ri_mac_axi_data_keep           ;
reg                                     ri_mac_axi_data_last           ;
reg    [15:0]                           ri_mac_axi_data_user           ;
reg                                     ri_cross_metadata_valid        ; 
reg                                     ri_cross_metadata_valid_1d     ;
reg    [METADATA_WIDTH-1:0]             ri_cross_metadata              ;
reg                                     ri_cross_metadata_last         ;
reg                                     ri_pass_en                     ;
reg                                     ri_discard_en                  ;
reg                                     ri_judge_finish                ;
reg                                     ri_mac_tx0_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx0_ack_rst             ;
reg                                     ri_mac_tx1_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx1_ack_rst             ;
reg                                     ri_mac_tx2_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx2_ack_rst             ;
reg                                     ri_mac_tx3_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx3_ack_rst             ;
reg                                     ri_mac_tx4_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx4_ack_rst             ;
reg                                     ri_mac_tx5_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx5_ack_rst             ;
reg                                     ri_mac_tx6_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx6_ack_rst             ;
reg                                     ri_mac_tx7_ack                 ;
reg    [PORT_FIFO_PRI_NUM-1:0]          ri_mac_tx7_ack_rst             ;

// 输出寄存器
reg                                     ro_mac_axi_data_ready          ;
reg                                     ro_cross_metadata_ready        ;
reg    [15:0]                           ro_mac_cross_port_axi_user     ;
reg    [CROSS_DATA_WIDTH-1:0]           ro_mac_cross_port_axi_data     ;
reg    [(CROSS_DATA_WIDTH/8)-1:0]       ro_mac_cross_axi_data_keep     ;
reg                                     ro_mac_cross_axi_data_valid    ;
reg                                     ro_mac_cross_axi_data_valid_d1 ;
reg                                     ro_mac_cross_axi_data_last     ;
reg    [METADATA_WIDTH-1:0]             ro_cross_metadata              ;
reg                                     ro_cross_metadata_valid        ;
reg                                     ro_cross_metadata_last         ;
reg                                     ro_rtag_flag                   ;
reg    [15:0]                           ro_rtag_squence                ;
reg    [7:0]                            ro_stream_handle               ;
reg                                     ro_tx_req                      ;
reg                                     ro_tx_req_d1                   ;

// 队列管理相关寄存器
reg    [QUEUE_ADDR_WIDTH-1:0]           r_wr_addr                      ; // 写地址
reg    [QUEUE_ADDR_WIDTH-1:0]           r_rd_addr                      ; // 读地址
reg    [QUEUE_ADDR_WIDTH:0]             r_ram_data_cnt                 ; // FIFO计数
reg                                     r_queue_full                   ; // 队列满标志
reg                                     r_queue_empty                  ; // 队列空标志

// 数据RAM相关信号
wire   [RAM_ADDR_WIDTH-1:0]             w_data_ram_wr_addr             ;
wire   [RAM_ADDR_WIDTH-1:0]             w_data_ram_rd_addr             ;
wire   [PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8)-1:0] w_data_ram_wr_data ;
wire   [PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8)-1:0] w_data_ram_rd_data ;
wire                                    w_data_ram_we                  ;
wire                                    w_data_ram_re                  ;

// 信息RAM相关信号
wire   [QUEUE_ADDR_WIDTH-1:0]           w_info_ram_wr_addr             ;
wire   [QUEUE_ADDR_WIDTH-1:0]           w_info_ram_rd_addr             ;
wire   [FRAME_INFO_WIDTH-1:0]           w_info_ram_wr_data             ;
wire   [FRAME_INFO_WIDTH-1:0]           w_info_ram_rd_data             ;
wire                                    w_info_ram_we                  ;
reg                                     r_info_ram_we                  ; 
reg                                     r_info_ram_re                  ;

// 帧处理相关寄存器
wire                                    w_frame_read_end               ;
reg                                     r_frame_writing                ; // 帧写入标志
reg                                     r_frame_reading                ; // 帧读取标志
reg    [RAM_ADDR_WIDTH-1:0]             r_current_frame_start_addr     ; // 当前帧起始地址
reg    [RAM_ADDR_WIDTH-1:0]             r_current_frame_end_addr       ; // 当前帧结束地址
reg    [RAM_ADDR_WIDTH-1:0]             r_frame_start_addrs [QUEUE_SIZE-1:0] ; // 每个队列项对应的帧起始地址
reg    [RAM_ADDR_WIDTH-1:0]             r_frame_end_addrs   [QUEUE_SIZE-1:0] ; // 每个队列项对应的帧结束地址
reg    [RAM_ADDR_WIDTH-1:0]             r_data_wr_ptr                  ; // 数据RAM写指针
reg    [RAM_ADDR_WIDTH-1:0]             r_data_ram_rd_ptr              ; // 数据RAM读指针

// metadata解析相关寄存器
reg                                     r_rtag_flag                    ; // rtag标志位
reg    [15:0]                           r_rtag_squence                 ; // rtag序列号
reg    [7:0]                            r_stream_handle                ; // 流句柄
reg    [2:0]                            r_vlan_pri                     ; // VLAN优先级

// 当前处理帧是否为关键帧
reg                                     r_current_is_critical          ;

// CB处理相关寄存器
reg                                     r_cb_processing                ; // CB处理中标志
reg                                     r_cb_req_sent                  ; // CB请求已发送标志
reg                                     r_cb_result_rcvd               ; // CB结果已接收标志
reg                                     r_pass_result                  ; // 通过结果

// req-ack处理相关寄存器
reg                                     r_req_sent                     ; // req已发送标志
reg    [TIMEOUT_CNT_WIDTH-1:0]          r_timeout_cnt                  ; // 超时计数器
reg                                     r_timeout_flag                 ; // 超时标志
reg    [PORT_NUM-1:0]                   r_ack_received                 ; // ACK接收标志
reg    [PORT_NUM-1:0]                   r_ack_expected                 ; // 期望的ACK

// 优先级管理相关寄存器
reg    [QUEUE_ADDR_WIDTH-1:0]           r_current_process_addr         ; // 当前处理地址
reg                                     r_process_complete             ; // 处理完成标志
reg    [2:0]                            r_frame_pri         [QUEUE_SIZE-1:0] ; // 每个队列项的优先级（3位VLAN优先级）
reg                                     r_frame_valid       [QUEUE_SIZE-1:0] ; // 每个队列项的有效标志
reg                                     r_frame_end_addr_valid [QUEUE_SIZE-1:0] ; // 每个队列项的结束地址有效标志
// two-stage register for r_info_ram_re
reg                                     r_info_ram_re_d1               ;
reg                                     r_info_ram_re_d2               ;
reg                                     r_process_complete_d1          ;
// 优先级选择信号
wire   [2:0]                            r_max_pri                      ; // 最高优先级值
wire   [QUEUE_ADDR_WIDTH-1:0]           r_next_addr                    ; // 下一个处理地址

wire                                    w_tx_req                       ;
wire                                    w_recivedall_ack               ;

reg    [15:0]                           r_data_out_cnt                 ;
reg    [15:0]                           r_data_out_len                 ;

wire   [METADATA_WIDTH-1:0]             w_current_metadata             ;
// 状态标志
// reg                         r_input_ready                                                          ; // 输入就绪标志
// reg                         r_output_valid                                                         ; // 输出有效标志


assign w_recivedall_ack = ((r_ack_received & r_ack_expected) == r_ack_expected) && (r_ack_expected != {PORT_NUM{1'b0}}) ? 1'd1 : 1'd0;

assign w_frame_read_end = (o_mac_cross_axi_data_valid == 1'b1) && (o_mac_cross_axi_data_last == 1'b1) ? 1'd1 : 1'd0 ;

// 关键帧判断：user信号最高位或metadata[11]
wire   w_is_critical_frame;
assign w_is_critical_frame = (((w_current_metadata[11] == 1'b1) || (w_info_ram_rd_data[15] == 1'b1)) && (w_current_metadata[13] == 1'b1))? 1'd1 : 1'd0 ;

 

/*---------------------------------------- 输入信号打拍 -------------------------------------------*/
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ri_mac_axi_data_valid      <= 1'b0;
        ri_mac_axi_data            <= {PORT_MNG_DATA_WIDTH{1'b0}};
        ri_mac_axi_data_keep       <= {(PORT_MNG_DATA_WIDTH/8){1'b0}};
        ri_mac_axi_data_last       <= 1'b0;
        ri_mac_axi_data_user       <= 16'b0;
        ri_cross_metadata_valid    <= 1'b0;
        ri_cross_metadata_valid_1d <= 1'b0;
        ri_cross_metadata          <= {METADATA_WIDTH{1'b0}};
        ri_cross_metadata_last     <= 1'b0;
        ri_pass_en                 <= 1'b0;
        ri_discard_en              <= 1'b0;
        ri_judge_finish            <= 1'b0;
        ri_mac_tx0_ack             <= 1'b0;
        ri_mac_tx0_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx1_ack             <= 1'b0;
        ri_mac_tx1_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx2_ack             <= 1'b0;
        ri_mac_tx2_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx3_ack             <= 1'b0;
        ri_mac_tx3_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx4_ack             <= 1'b0;
        ri_mac_tx4_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx5_ack             <= 1'b0;
        ri_mac_tx5_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx6_ack             <= 1'b0;
        ri_mac_tx6_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
        ri_mac_tx7_ack             <= 1'b0;
        ri_mac_tx7_ack_rst         <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else begin
        ri_mac_axi_data_valid      <= i_mac_axi_data_valid;
        ri_mac_axi_data            <= i_mac_axi_data;
        ri_mac_axi_data_keep       <= i_mac_axi_data_keep;
        ri_mac_axi_data_last       <= i_mac_axi_data_last;
        ri_mac_axi_data_user       <= i_mac_axi_data_user;
        ri_cross_metadata_valid    <= i_cross_metadata_valid;
        ri_cross_metadata_valid_1d <= ri_cross_metadata_valid;
        ri_cross_metadata          <= i_cross_metadata;
        ri_cross_metadata_last     <= i_cross_metadata_last;
        ri_pass_en                 <= i_pass_en;
        ri_discard_en              <= i_discard_en;
        ri_judge_finish            <= i_judge_finish;
        ri_mac_tx0_ack             <= i_mac_tx0_ack;
        ri_mac_tx0_ack_rst         <= i_mac_tx0_ack_rst;
        ri_mac_tx1_ack             <= i_mac_tx1_ack;
        ri_mac_tx1_ack_rst         <= i_mac_tx1_ack_rst;
        ri_mac_tx2_ack             <= i_mac_tx2_ack;
        ri_mac_tx2_ack_rst         <= i_mac_tx2_ack_rst;
        ri_mac_tx3_ack             <= i_mac_tx3_ack;
        ri_mac_tx3_ack_rst         <= i_mac_tx3_ack_rst;
        ri_mac_tx4_ack             <= i_mac_tx4_ack;
        ri_mac_tx4_ack_rst         <= i_mac_tx4_ack_rst;
        ri_mac_tx5_ack             <= i_mac_tx5_ack;
        ri_mac_tx5_ack_rst         <= i_mac_tx5_ack_rst;
        ri_mac_tx6_ack             <= i_mac_tx6_ack;
        ri_mac_tx6_ack_rst         <= i_mac_tx6_ack_rst;
        ri_mac_tx7_ack             <= i_mac_tx7_ack;
        ri_mac_tx7_ack_rst         <= i_mac_tx7_ack_rst;
    end
end

/*---------------------------------------- 队列管理逻辑 -------------------------------------------*/
// 缓存中帧计数器
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_ram_data_cnt <= {(QUEUE_ADDR_WIDTH+1){1'b0}};
    end else begin
        r_ram_data_cnt <= ((ri_cross_metadata_valid == 1'b1) && (r_queue_full == 1'b0) && !((r_process_complete == 1'b1) && (r_queue_empty == 1'b0))) ? 
                        (r_ram_data_cnt + {{QUEUE_ADDR_WIDTH{1'b0}}, 1'b1}) :
                      ((r_process_complete == 1'b1) && (r_queue_empty == 1'b0) && !((ri_cross_metadata_valid == 1'b1) && (r_queue_full == 1'b0))) ? 
                        (r_ram_data_cnt - {{QUEUE_ADDR_WIDTH{1'b0}}, 1'b1}) :
                      r_ram_data_cnt;
    end
end

// 队列满/空标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_queue_full <= 1'b0;
    end else begin
        r_queue_full <= (r_ram_data_cnt[QUEUE_ADDR_WIDTH] == 1'b1) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_queue_empty <= 1'b1;
    end else begin
        r_queue_empty <= (r_ram_data_cnt == {(QUEUE_ADDR_WIDTH+1){1'b0}}) ? 1'b1 : 1'b0;
    end
end

// 写地址管理
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_wr_addr <= {QUEUE_ADDR_WIDTH{1'b0}};
    end else begin
        r_wr_addr <= ri_mac_axi_data_last == 1'd1 && ri_mac_axi_data_valid == 1'b1 && r_queue_full == 1'b0 && (r_wr_addr == (QUEUE_SIZE - {{(QUEUE_ADDR_WIDTH-1){1'b0}},1'b1})) ? {QUEUE_ADDR_WIDTH{1'b0}} : 
                     ri_mac_axi_data_last == 1'd1 && ri_mac_axi_data_valid == 1'b1 && r_queue_full == 1'b0 ? (r_wr_addr + {{(QUEUE_ADDR_WIDTH-1){1'b0}}, 1'b1}) :
                     r_wr_addr;
    end
end

// 读地址管理 - 跟随优先级选择结果更新
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_rd_addr <= {QUEUE_ADDR_WIDTH{1'b0}};
    end else begin
        r_rd_addr <= r_info_ram_we == 1'b1 ? r_next_addr : r_rd_addr;
    end
end

/*---------------------------------------- 数据RAM写入控制 -------------------------------------------*/
// 数据RAM写指针
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_wr_ptr <= {RAM_ADDR_WIDTH{1'b0}};
    end else begin
        r_data_wr_ptr <= ((ri_mac_axi_data_valid == 1'b1) && (ro_mac_axi_data_ready == 1'b1)) ?
                         ((r_data_wr_ptr == (RAM_DEPTH - 1)) ? {RAM_ADDR_WIDTH{1'b0}} : (r_data_wr_ptr + {{(RAM_ADDR_WIDTH-1){1'b0}}, 1'b1})) :
                         r_data_wr_ptr;
    end
end

// 帧写入标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_frame_writing <= 1'b0;
    end else begin
        r_frame_writing <= ((ri_mac_axi_data_valid == 1'b1) && (ro_mac_axi_data_ready == 1'b1) && (r_frame_writing == 1'b0)) ? 1'b1 :
                          (((ri_mac_axi_data_valid == 1'b1) && (ri_mac_axi_data_last == 1'b1) && (ro_mac_axi_data_ready == 1'b1)) ? 1'b0 : r_frame_writing);
    end
end

// 当前帧起始地址
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_frame_start_addr <= {RAM_ADDR_WIDTH{1'b0}};
    end else begin
        r_current_frame_start_addr <= ((ri_mac_axi_data_valid == 1'b1) && (ro_mac_axi_data_ready == 1'b1) && (r_frame_writing == 1'b0)) ?
                                      r_data_wr_ptr : r_current_frame_start_addr;
    end
end

// 当前帧结束地址
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_frame_end_addr <= {RAM_ADDR_WIDTH{1'b0}};
    end else begin
        r_current_frame_end_addr <= ((i_mac_axi_data_valid == 1'b1) && (i_mac_axi_data_last == 1'b1) && (ro_mac_axi_data_ready == 1'b1)) ?
                                    r_data_wr_ptr + 1'd1 : r_current_frame_end_addr;
    end
end

// 存储每个队列项的帧地址信息、优先级和有效标志
genvar gi;
generate
    for (gi = 0; gi < QUEUE_SIZE; gi = gi + 1) begin: g_queue_item
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_frame_valid[gi]           <= 1'b0;
                r_frame_pri[gi]             <= 3'b0;
                r_frame_start_addrs[gi]     <= {RAM_ADDR_WIDTH{1'b0}};
            end else begin
                // 新写入帧时，记录地址、优先级和设置有效标志
                r_frame_start_addrs[gi]     <= ((ri_cross_metadata_valid == 1'b1) && (r_queue_full == 1'b0) && (r_wr_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? r_data_wr_ptr : r_frame_start_addrs[gi];
                r_frame_pri[gi]             <= ((ri_cross_metadata_valid == 1'b1) && (r_queue_full == 1'b0) && (r_wr_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? ri_cross_metadata[62:60] : r_frame_pri[gi]; // VLAN优先级位
                r_frame_valid[gi]           <= ((r_process_complete == 1'b1) && (r_queue_empty == 1'b0) && (r_current_process_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? 1'b0 :
                                               ((ri_cross_metadata_valid == 1'b1) && (r_queue_full == 1'b0) && (r_wr_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? 1'b1 :  r_frame_valid[gi];
            end
        end
        
        // 单独管理帧结束地址和有效标志
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_frame_end_addrs[gi]       <= {RAM_ADDR_WIDTH{1'b0}};
                r_frame_end_addr_valid[gi]  <= 1'b0;
            end else begin
                // 帧数据接收完成时，记录结束地址并设置有效标志
                r_frame_end_addrs[gi]       <= ((ri_mac_axi_data_valid == 1'd1) && (ri_mac_axi_data_last == 1'd1) && (r_queue_full == 1'b0) && (r_wr_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? r_current_frame_end_addr : r_frame_end_addrs[gi];
                r_frame_end_addr_valid[gi]  <= ((ri_mac_axi_data_valid == 1'd1) && (ri_mac_axi_data_last == 1'd1) && (r_queue_full == 1'b0) && (r_wr_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? 1'b1 :
                                               ((r_process_complete == 1'b1) && (r_queue_empty == 1'b0) && (r_current_process_addr == gi[QUEUE_ADDR_WIDTH-1:0])) ? 1'b0 : r_frame_end_addr_valid[gi];
            end
        end
    end
endgenerate

/*---------------------------------------- metadata解析 -------------------------------------------*/
// 定义metadata在RAM中的位置 (metadata位于高位，user位于低15位)
assign w_current_metadata = w_info_ram_rd_data[FRAME_INFO_WIDTH-1:16];

// rtag标志解析 - 从当前队列读取的metadata解析
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_rtag_flag <= 1'b0;
    end else begin
        r_rtag_flag <= (r_info_ram_re_d1 == 1'd1) ? w_current_metadata[14] : (r_process_complete == 1'b1) ? 1'b0 :r_rtag_flag;
    end
end

// 当前处理帧是否为关键帧
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_is_critical <= 1'b0;
    end else begin
        r_current_is_critical <=  (r_process_complete == 1'b1) ? 1'b0 :
                                  (r_info_ram_re_d1 == 1'd1) ? w_is_critical_frame : 
                                  r_current_is_critical;
    end
end

// rtag序列号解析 - 从当前队列读取的metadata解析
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_rtag_squence <= 16'b0;
    end else begin
        r_rtag_squence <= (r_info_ram_re_d1 == 1'd1) ? w_current_metadata[80:65] : (r_process_complete == 1'b1) ? 1'b0 :r_rtag_squence;
    end
end

// 流句柄解析 - 从当前队列读取的metadata解析
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_stream_handle <= 8'b0;
    end else begin
        r_stream_handle <= (r_info_ram_re_d1 == 1'd1) ? w_current_metadata[43:36] : (r_process_complete == 1'b1) ? 1'b0 :r_stream_handle;
    end
end

// VLAN优先级解析 - 从当前队列读取的metadata解析  
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_vlan_pri <= 3'b0;
    end else begin
        r_vlan_pri <= (r_info_ram_re_d1 == 1'd1) ? w_current_metadata[62:60] : (r_process_complete == 1'b1) ? 1'b0 :r_vlan_pri;
    end
end

/*---------------------------------------- CB处理逻辑 -------------------------------------------*/
// CB处理中标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_cb_processing <= 1'b0;
    end else begin
        r_cb_processing <= (r_rtag_flag == 1'b1 && r_queue_empty == 1'b0 && r_cb_processing == 1'd0 && r_cb_result_rcvd == 1'd0) ? 1'b1 :
                          ((ri_judge_finish == 1'b1) ? 1'b0 : r_cb_processing);
    end
end

// CB请求已发送标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_cb_req_sent <= 1'b0;
    end else begin
        r_cb_req_sent <= (r_cb_processing == 1'b1 && r_cb_req_sent == 1'b0 && r_cb_result_rcvd == 1'd0) ? 1'b1 : (ri_judge_finish == 1'b1) ? 1'b0 : r_cb_req_sent;
    end
end

// CB结果已接收标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_cb_result_rcvd <= 1'b0;
    end else begin
        r_cb_result_rcvd <= (r_cb_req_sent == 1'd1 && r_cb_result_rcvd == 1'b0) ? 1'b1 :
                           ((r_process_complete == 1'b1) ? 1'b0 : r_cb_result_rcvd);
    end
end

// 通过结果
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_pass_result <= 1'b0;
    end else begin
        r_pass_result <= ((ri_judge_finish == 1'b1) && (ri_pass_en == 1'b1)) ? 1'b1 :
                        (((ri_judge_finish == 1'b1) && (ri_discard_en == 1'b1)) || r_process_complete == 1'd1 ? 1'b0 : r_pass_result);
    end
end

/*---------------------------------------- req-ack处理逻辑 -------------------------------------------*/
// req已发送标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_req_sent <= 1'b0;
    end else begin
        r_req_sent <= (r_current_is_critical == 1'b0) && (ro_mac_cross_axi_data_valid_d1== 1'b1 || r_timeout_flag == 1'd1) ? 1'b0 :
                      ((r_current_is_critical == 1'b0) && (((r_info_ram_re_d2 == 1'd1) && (r_rtag_flag == 1'b0) && (r_queue_empty == 1'b0) && (r_req_sent == 1'b0)) ||
                      ((r_rtag_flag == 1'b1) && (r_cb_result_rcvd == 1'b1) && (r_pass_result == 1'b1) && (r_req_sent == 1'b0))))  ? 1'b1 :
                      r_req_sent;
    end
end

// 超时计数器
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_timeout_cnt <= {TIMEOUT_CNT_WIDTH{1'b0}};
    end else begin
        r_timeout_cnt <=   (r_current_is_critical == 1'b0) && r_frame_reading == 1'd0 && r_req_sent == 1'b1  ?
                         ((r_timeout_cnt == TIMEOUT_CNT_MAX ) ? {TIMEOUT_CNT_WIDTH{1'b0}} : (r_timeout_cnt + {{(TIMEOUT_CNT_WIDTH-1){1'b0}}, 1'b1})) :
                         ((w_recivedall_ack == 1'b1) ? {TIMEOUT_CNT_WIDTH{1'b0}} : {TIMEOUT_CNT_WIDTH{1'b0}});
    end
end

// 超时标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_timeout_flag <= 1'b0;
    end else begin
        r_timeout_flag <= (r_timeout_cnt == TIMEOUT_CNT_MAX) ? 1'b1 :  1'b0;
    end
end

/*---------------------------------------- 输入就绪信号 -------------------------------------------*/
// 输入就绪：关键帧旁路时由下游emac反压控制，否则由队列是否满决定
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_mac_axi_data_ready <= 1'b0;
    end else begin
        ro_mac_axi_data_ready <= (r_queue_full == 1'b0) ? 1'b1 : 1'b0;
    end
end

// metadata就绪：关键帧旁路时由下游emac反压控制，否则由队列是否满决定
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_cross_metadata_ready <= 1'b0;
    end else begin
        ro_cross_metadata_ready <= (r_queue_full == 1'b0) ? 1'b1 : 1'b0;
    end
end

/*---------------------------------------- CB输出信号 -------------------------------------------*/
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_rtag_flag <= 1'b0;
    end else begin
        ro_rtag_flag <= ((r_cb_processing == 1'b1) && (r_cb_req_sent == 1'b0)) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_rtag_squence <= 16'b0;
    end else begin
        ro_rtag_squence <= ((r_cb_processing == 1'b1) && (r_cb_req_sent == 1'b0)) ? 
                           w_current_metadata[80:65] : 16'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_stream_handle <= 8'b0;
    end else begin
        ro_stream_handle <= ((r_cb_processing == 1'b1) && (r_cb_req_sent == 1'b0)) ? 
                            w_current_metadata[43:36] : 8'b0;
    end
end

/*---------------------------------------- 优先级选择逻辑 -------------------------------------------*/
// 优先级选择组合逻辑：使用二叉树比较结构，选出优先级最高的有效队列项
// 若有多个同优先级帧，选择最早入队的（索引最小的）

// 第一级比较（两两比较）
wire   [2:0]                pri_cmp_l1      [15:0]                                              ; // 第一级优先级比较结果
wire   [QUEUE_ADDR_WIDTH-1:0]           addr_cmp_l1     [15:0]                                  ; // 第一级地址比较结果
wire                        valid_cmp_l1    [15:0]                                              ; // 第一级有效标志比较结果

genvar gj;
generate
    for (gj = 0; gj < 16; gj = gj + 1) begin: g_pri_cmp_l1
        assign valid_cmp_l1[gj] = r_frame_valid[gj*2] | r_frame_valid[gj*2+1];
        assign pri_cmp_l1[gj]   = (!r_frame_valid[gj*2] && r_frame_valid[gj*2+1]) ? r_frame_pri[gj*2+1] :
                                  (r_frame_valid[gj*2] && !r_frame_valid[gj*2+1]) ? r_frame_pri[gj*2] :
                                  (r_frame_valid[gj*2] && r_frame_valid[gj*2+1]) ? 
                                  ((r_frame_pri[gj*2] > r_frame_pri[gj*2+1]) ? r_frame_pri[gj*2] : r_frame_pri[gj*2+1]) :
                                  3'b000;
        assign addr_cmp_l1[gj]  = (!r_frame_valid[gj*2] && r_frame_valid[gj*2+1]) ? (gj*2+1) :
                                  (r_frame_valid[gj*2] && !r_frame_valid[gj*2+1]) ? (gj*2) :
                                  (r_frame_valid[gj*2] && r_frame_valid[gj*2+1]) ? 
                                  ((r_frame_pri[gj*2] > r_frame_pri[gj*2+1]) ? (gj*2) : 
                                   (r_frame_pri[gj*2] < r_frame_pri[gj*2+1]) ? (gj*2+1) : (gj*2)) :
                                  {QUEUE_ADDR_WIDTH{1'b0}};
    end
endgenerate

// 第二级比较（8个比较器）
wire   [2:0]                pri_cmp_l2      [7:0]                                                          ; // 第二级优先级比较结果
wire   [QUEUE_ADDR_WIDTH-1:0]           addr_cmp_l2     [7:0]                                   ; // 第二级地址比较结果
wire                        valid_cmp_l2    [7:0]                                                          ; // 第二级有效标志比较结果

generate
    for (gj = 0; gj < 8; gj = gj + 1) begin: g_pri_cmp_l2
        assign valid_cmp_l2[gj] = valid_cmp_l1[gj*2] | valid_cmp_l1[gj*2+1];
        assign pri_cmp_l2[gj]   = (!valid_cmp_l1[gj*2] && valid_cmp_l1[gj*2+1]) ? pri_cmp_l1[gj*2+1] :
                                  (valid_cmp_l1[gj*2] && !valid_cmp_l1[gj*2+1]) ? pri_cmp_l1[gj*2] :
                                  (valid_cmp_l1[gj*2] && valid_cmp_l1[gj*2+1]) ? 
                                  ((pri_cmp_l1[gj*2] > pri_cmp_l1[gj*2+1]) ? pri_cmp_l1[gj*2] : pri_cmp_l1[gj*2+1]) :
                                  3'b000;
        assign addr_cmp_l2[gj]  = (!valid_cmp_l1[gj*2] && valid_cmp_l1[gj*2+1]) ? addr_cmp_l1[gj*2+1] :
                                  (valid_cmp_l1[gj*2] && !valid_cmp_l1[gj*2+1]) ? addr_cmp_l1[gj*2] :
                                  (valid_cmp_l1[gj*2] && valid_cmp_l1[gj*2+1]) ? 
                                  ((pri_cmp_l1[gj*2] > pri_cmp_l1[gj*2+1]) ? addr_cmp_l1[gj*2] : 
                                   (pri_cmp_l1[gj*2] < pri_cmp_l1[gj*2+1]) ? addr_cmp_l1[gj*2+1] : addr_cmp_l1[gj*2]) :
                                  {QUEUE_ADDR_WIDTH{1'b0}};
    end
endgenerate

// 第三级比较（4个比较器）
wire   [2:0]                pri_cmp_l3      [3:0]                                                          ; // 第三级优先级比较结果
wire   [QUEUE_ADDR_WIDTH-1:0]           addr_cmp_l3     [3:0]                                   ; // 第三级地址比较结果
wire                        valid_cmp_l3    [3:0]                                                          ; // 第三级有效标志比较结果

generate
    for (gj = 0; gj < 4; gj = gj + 1) begin: g_pri_cmp_l3
        assign valid_cmp_l3[gj] = valid_cmp_l2[gj*2] | valid_cmp_l2[gj*2+1];
        assign pri_cmp_l3[gj]   = (!valid_cmp_l2[gj*2] && valid_cmp_l2[gj*2+1]) ? pri_cmp_l2[gj*2+1] :
                                  (valid_cmp_l2[gj*2] && !valid_cmp_l2[gj*2+1]) ? pri_cmp_l2[gj*2] :
                                  (valid_cmp_l2[gj*2] && valid_cmp_l2[gj*2+1]) ? 
                                  ((pri_cmp_l2[gj*2] > pri_cmp_l2[gj*2+1]) ? pri_cmp_l2[gj*2] : pri_cmp_l2[gj*2+1]) :
                                  3'b000;
        assign addr_cmp_l3[gj]  = (!valid_cmp_l2[gj*2] && valid_cmp_l2[gj*2+1]) ? addr_cmp_l2[gj*2+1] :
                                  (valid_cmp_l2[gj*2] && !valid_cmp_l2[gj*2+1]) ? addr_cmp_l2[gj*2] :
                                  (valid_cmp_l2[gj*2] && valid_cmp_l2[gj*2+1]) ? 
                                  ((pri_cmp_l2[gj*2] > pri_cmp_l2[gj*2+1]) ? addr_cmp_l2[gj*2] : 
                                   (pri_cmp_l2[gj*2] < pri_cmp_l2[gj*2+1]) ? addr_cmp_l2[gj*2+1] : addr_cmp_l2[gj*2]) :
                                  {QUEUE_ADDR_WIDTH{1'b0}};
    end
endgenerate

// 第四级比较（2个比较器）
wire   [2:0]                pri_cmp_l4      [1:0]                                                          ; // 第四级优先级比较结果
wire   [QUEUE_ADDR_WIDTH-1:0]           addr_cmp_l4     [1:0]                                   ; // 第四级地址比较结果
wire                        valid_cmp_l4    [1:0]                                                          ; // 第四级有效标志比较结果

generate
    for (gj = 0; gj < 2; gj = gj + 1) begin: g_pri_cmp_l4
        assign valid_cmp_l4[gj] = valid_cmp_l3[gj*2] | valid_cmp_l3[gj*2+1];
        assign pri_cmp_l4[gj]   = (!valid_cmp_l3[gj*2] && valid_cmp_l3[gj*2+1]) ? pri_cmp_l3[gj*2+1] :
                                  (valid_cmp_l3[gj*2] && !valid_cmp_l3[gj*2+1]) ? pri_cmp_l3[gj*2] :
                                  (valid_cmp_l3[gj*2] && valid_cmp_l3[gj*2+1]) ? 
                                  ((pri_cmp_l3[gj*2] > pri_cmp_l3[gj*2+1]) ? pri_cmp_l3[gj*2] : pri_cmp_l3[gj*2+1]) :
                                  3'b000;
        assign addr_cmp_l4[gj]  = (!valid_cmp_l3[gj*2] && valid_cmp_l3[gj*2+1]) ? addr_cmp_l3[gj*2+1] :
                                  (valid_cmp_l3[gj*2] && !valid_cmp_l3[gj*2+1]) ? addr_cmp_l3[gj*2] :
                                  (valid_cmp_l3[gj*2] && valid_cmp_l3[gj*2+1]) ? 
                                  ((pri_cmp_l3[gj*2] > pri_cmp_l3[gj*2+1]) ? addr_cmp_l3[gj*2] : 
                                   (pri_cmp_l3[gj*2] < pri_cmp_l3[gj*2+1]) ? addr_cmp_l3[gj*2+1] : addr_cmp_l3[gj*2]) :
                                  {QUEUE_ADDR_WIDTH{1'b0}};
    end
endgenerate

// 第五级比较（最终比较器）
assign r_max_pri   = (!valid_cmp_l4[0] && valid_cmp_l4[1]) ? pri_cmp_l4[1] :
                   (valid_cmp_l4[0] && !valid_cmp_l4[1]) ? pri_cmp_l4[0] :
                   (valid_cmp_l4[0] && valid_cmp_l4[1]) ? 
                   ((pri_cmp_l4[0] > pri_cmp_l4[1]) ? pri_cmp_l4[0] : pri_cmp_l4[1]) :
                   3'b000;

assign r_next_addr = (!valid_cmp_l4[0] && valid_cmp_l4[1]) ? addr_cmp_l4[1] :
                   (valid_cmp_l4[0] && !valid_cmp_l4[1]) ? addr_cmp_l4[0] :
                   (valid_cmp_l4[0] && valid_cmp_l4[1]) ? 
                   ((pri_cmp_l4[0] > pri_cmp_l4[1]) ? addr_cmp_l4[0] : 
                    (pri_cmp_l4[0] < pri_cmp_l4[1]) ? addr_cmp_l4[1] : addr_cmp_l4[0]) :
                   {QUEUE_ADDR_WIDTH{1'b0}};

// 当前处理地址选择(严格基于优先级)
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_process_addr <= {QUEUE_ADDR_WIDTH{1'b0}};
    end else begin
        r_current_process_addr <= ri_cross_metadata_valid_1d == 1'b1 ? r_next_addr : r_current_process_addr;
    end
end

always @(posedge i_clk) begin
    r_process_complete_d1 <= r_process_complete;
end

// 处理完成标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_process_complete <= 1'b0;
    end else begin
        r_process_complete <=   w_is_critical_frame == 1'b1 && o_emac_axi_data_last == 1'd1 ||
                                (w_is_critical_frame == 1'b0) && (((r_timeout_flag == 1'b1) ||
                                ((r_rtag_flag == 1'b1) && (ri_judge_finish == 1'b1) && (ri_discard_en == 1'b1)) ||
                                (w_frame_read_end == 1'd1  && ((r_ack_received & r_ack_expected) == r_ack_expected) && (r_ack_expected != {PORT_NUM{1'b0}}))))
                               ? 1'b1 : 1'b0;
    end
end

/*---------------------------------------- ACK处理逻辑 -------------------------------------------*/
// ACK接收标志处理
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_ack_received <= {PORT_NUM{1'b0}};
    end else begin
        r_ack_received <= (ro_mac_cross_axi_data_last == 1'b1) ? {PORT_NUM{1'b0}} :
                          (r_ack_received | ({i_mac_tx7_ack, i_mac_tx6_ack, i_mac_tx5_ack, i_mac_tx4_ack,
                                           i_mac_tx3_ack, i_mac_tx2_ack, i_mac_tx1_ack, i_mac_tx0_ack} & r_ack_expected));
    end
end

// 期望ACK通道解析（metadata[59:52]）
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_ack_expected <= {PORT_NUM{1'b0}};
    end else if (ro_tx_req == 1'b1) begin
        r_ack_expected <= w_current_metadata[59:52];
    end
end

/*---------------------------------------- 数据输出控制 -------------------------------------------*/
// 数据RAM读指针
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_ram_rd_ptr <= {RAM_ADDR_WIDTH{1'b0}};
    end else begin
        r_data_ram_rd_ptr <=  (w_is_critical_frame == 1'b1 && ri_pass_en == 1'b0 && i_pass_en == 1'b1) || (ro_tx_req == 1'b1) ? r_frame_start_addrs[r_current_process_addr] : 
                              (((r_frame_reading == 1'b1) && (i_mac_cross_axi_data_ready == 1'b1) && 
                               r_frame_end_addr_valid[r_current_process_addr] == 1'b1 && (r_data_ram_rd_ptr == r_frame_end_addrs[r_current_process_addr])) ? r_data_ram_rd_ptr :
                              ((r_frame_reading == 1'b1) && ((i_mac_cross_axi_data_ready == 1'b1) || w_is_critical_frame == 1'b1)) ? (r_data_ram_rd_ptr + {{(RAM_ADDR_WIDTH-1){1'b0}}, 1'b1}) :
                              r_data_ram_rd_ptr);
    end
end

// 帧读取标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_frame_reading <= 1'b0;
    end else begin
        r_frame_reading <= (r_current_is_critical == 1'b0 && ro_mac_cross_axi_data_valid == 1'b1 && (r_data_out_cnt >= r_data_out_len - 16'd2) && (i_mac_cross_axi_data_ready == 1'b1)) ? 1'b0 :
                           (r_current_is_critical == 1'b1 && o_emac_axi_data_valid == 1'b1 && (r_data_out_cnt >= r_data_out_len - 16'd1) && (i_emac_axi_data_ready == 1'b1)) ? 1'b0 :
                           (r_current_is_critical == 1'b0 && (r_req_sent == 1'b1) && ((r_ack_received & r_ack_expected) == r_ack_expected) && (r_ack_expected != {PORT_NUM{1'b0}})) ? 1'b1 :
                           (r_current_is_critical == 1'b1 && i_judge_finish == 1'b1 && i_pass_en == 1'd1) ? 1'b1 :
                           r_frame_reading  ;
    end
end

/*---------------------------------------- 输出数据流 -------------------------------------------*/
// 计数器用于判断last信号
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_out_cnt <= 16'd0;
    end else begin
        r_data_out_cnt <= (r_current_is_critical == 1'b0 && ro_tx_req == 1'b1) ? 16'd0 :
                          (r_current_is_critical == 1'b1 && r_info_ram_re_d2 == 1'b1) ? 16'd0 :
                          ((ro_mac_cross_axi_data_valid == 1'b1) && (i_mac_cross_axi_data_ready == 1'b1) && r_data_out_cnt <= r_data_out_len) ? (r_data_out_cnt + 16'd1) :
                          ((o_emac_axi_data_valid == 1'b1) && (i_emac_axi_data_ready == 1'b1) && r_data_out_cnt <= r_data_out_len) ? (r_data_out_cnt + 16'd1) :
                          r_data_out_cnt;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_out_len <= 16'd0;
    end else begin
        r_data_out_len <= (r_current_is_critical == 1'b0 && ro_tx_req == 1'b1) ? w_info_ram_rd_data[14:0] : 
                          (r_current_is_critical == 1'b1 && r_info_ram_re_d2 == 1'b1) ? w_info_ram_rd_data[14:0] :
                          r_data_out_len;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_mac_cross_axi_data_valid <= 1'b0;
    end else begin
        ro_mac_cross_axi_data_valid <= (r_current_is_critical == 1'b0) && (ro_mac_cross_axi_data_valid == 1'd1 && r_data_out_cnt >= r_data_out_len - 1'd1)  ? 1'd0 :
                                     (r_current_is_critical == 1'b0) && ((r_frame_reading == 1'b1) && (r_ack_received != {PORT_NUM{1'b0}})) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk) begin
    // ro_mac_cross_axi_data_valid_d1 <= ro_mac_cross_axi_data_valid == 1'd1 && r_data_out_len == r_data_out_cnt ? 1'd0 : ro_mac_cross_axi_data_valid == 1'd1 && r_frame_reading == 1'd1  ? 1'd1 :  1'd0;  
     ro_mac_cross_axi_data_valid_d1 <= ro_mac_cross_axi_data_valid;
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_mac_cross_port_axi_data <= {CROSS_DATA_WIDTH{1'b0}};
    end else begin
        ro_mac_cross_port_axi_data <= (ro_mac_cross_axi_data_valid == 1'b1) ? 
                                      w_data_ram_rd_data[PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8)-1:(PORT_MNG_DATA_WIDTH/8)] : 
                                      {CROSS_DATA_WIDTH{1'b0}};
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_mac_cross_axi_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
    end else begin
        ro_mac_cross_axi_data_keep <= (ro_mac_cross_axi_data_valid == 1'b1) ? 
                                      w_data_ram_rd_data[(PORT_MNG_DATA_WIDTH/8)-1:0] : 
                                      {(CROSS_DATA_WIDTH/8){1'b0}};
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_mac_cross_axi_data_last <= 1'b0;
    end else begin
        ro_mac_cross_axi_data_last <= (ro_mac_cross_axi_data_valid == 1'b1 && (r_data_out_cnt == r_data_out_len - 16'd1)) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_mac_cross_port_axi_user <= 16'b0;
    end else begin
        ro_mac_cross_port_axi_user <= (ro_mac_cross_axi_data_valid == 1'b1) ? w_info_ram_rd_data[15:0] : 16'b0;
    end
end

/*---------------------------------------- 输出metadata流 -------------------------------------------*/
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_cross_metadata_valid <= 1'b0;
    end else begin
        ro_cross_metadata_valid <= (r_current_is_critical == 1'b0) && ((ro_tx_req == 1'b1) || (ro_mac_cross_axi_data_valid == 1'd1 && ro_mac_cross_axi_data_valid_d1 == 1'd0))  ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_cross_metadata <= {METADATA_WIDTH{1'b0}};
    end else begin
        ro_cross_metadata <= (r_current_is_critical == 1'b0) && (ro_tx_req == 1'b1) ? w_info_ram_rd_data[FRAME_INFO_WIDTH-1:16] : ro_cross_metadata;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_cross_metadata_last <= 1'b0;
    end else begin
        ro_cross_metadata_last <= (r_current_is_critical == 1'b0) && ((ro_tx_req == 1'b1) || (ro_mac_cross_axi_data_valid == 1'd1 && ro_mac_cross_axi_data_valid_d1 == 1'd0)) ? 1'b1 : 1'b0;
    end
end

/*---------------------------------------- req输出信号 -------------------------------------------*/
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_tx_req <= 1'b0;
    end else begin
        ro_tx_req <= (r_current_is_critical == 1'b0) && (((r_info_ram_re_d2 == 1'd1) && (r_rtag_flag == 1'b0) && (r_queue_empty == 1'b0) && (r_req_sent == 1'b0)) ||
                      ((r_rtag_flag == 1'b1) && (r_cb_result_rcvd == 1'b1) && (r_pass_result == 1'b1) && (r_req_sent == 1'b0))) ? 1'b1 : 1'b0;
    end
end
 

always @(posedge i_clk) begin
    ro_tx_req_d1 <= ro_tx_req;
end 
 
assign w_tx_req = (r_current_is_critical == 1'b0) && ((((r_info_ram_re_d2 == 1'd1) && (r_rtag_flag == 1'b0) && (r_queue_empty == 1'b0) && (r_req_sent == 1'b0)) ||
                  ((r_rtag_flag == 1'b1) && (r_cb_result_rcvd == 1'b1) && (r_pass_result == 1'b1) && (r_req_sent == 1'b0)))) ? 1'b1 : 1'b0;
/*---------------------------------------- 输出赋值 -------------------------------------------*/
assign o_mac_axi_data_ready             = ro_mac_axi_data_ready                                            ;
assign o_cross_metadata_ready           = ro_cross_metadata_ready                                          ;
assign o_mac_cross_port_axi_user        = ro_mac_cross_port_axi_user                                       ;
assign o_mac_cross_port_axi_data        = ro_mac_cross_port_axi_data                                       ;
assign o_mac_cross_axi_data_keep        = ro_mac_cross_axi_data_keep                                       ;
// 关键帧旁路时屏蔽普通交叉总线输出有效
assign o_mac_cross_axi_data_valid       = (r_current_is_critical == 1'b1) ? 1'b0 : ro_mac_cross_axi_data_valid_d1 ;
assign o_mac_cross_axi_data_last        = ro_mac_cross_axi_data_last                                       ;
assign o_cross_metadata                 = ro_cross_metadata                                                ;
assign o_cross_metadata_valid           = (r_current_is_critical == 1'b1) ? 1'b0 : ro_cross_metadata_valid      ;
assign o_cross_metadata_last            = ro_cross_metadata_last                                           ;
assign o_rtag_flag                      = ro_rtag_flag                                                     ;
assign o_rtag_squence                   = ro_rtag_squence                                                  ;
assign o_stream_handle                  = ro_stream_handle                                                 ;
assign o_tx_req                         = (r_current_is_critical == 1'b1) ? 1'b0 : ro_tx_req_d1             ;

/*---------------------------------------- 单 PORT 关键帧旁路输出 -------------------------------------------*/   
assign o_emac_port_axi_data    = (r_current_is_critical == 1'b1 && r_frame_reading == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && r_pass_result == 1'b1))) ? w_data_ram_rd_data[PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8)-1:(PORT_MNG_DATA_WIDTH/8)] : {CROSS_DATA_WIDTH{1'b0}};
assign o_emac_port_axi_user    = (r_current_is_critical == 1'b1 && r_frame_reading == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && r_pass_result == 1'b1))) ? w_info_ram_rd_data[15:0] : 16'b0;
assign o_emac_axi_data_keep    = (r_current_is_critical == 1'b1 && r_frame_reading == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && r_pass_result == 1'b1))) ? w_data_ram_rd_data[(PORT_MNG_DATA_WIDTH/8)-1:0] : {(CROSS_DATA_WIDTH/8){1'b0}};
assign o_emac_axi_data_valid   = (r_current_is_critical == 1'b1 && r_frame_reading == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && r_pass_result == 1'b1))) ? 1'b1 : 1'b0;
assign o_emac_axi_data_last    = (r_current_is_critical == 1'b1 && r_frame_reading == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && r_pass_result == 1'b1)) && (r_data_out_cnt == r_data_out_len - 16'd1)) ? 1'b1 : 1'b0;

assign o_emac_metadata         = (r_current_is_critical == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && ri_pass_en == 1'b1 && r_pass_result == 1'b1))) ? w_info_ram_rd_data[FRAME_INFO_WIDTH-1:16] : {METADATA_WIDTH{1'b0}};
assign o_emac_metadata_valid   = (r_current_is_critical == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && ri_pass_en == 1'b1 && r_pass_result == 1'b1))) ? 1'b1 : 1'b0;
assign o_emac_metadata_last    = (r_current_is_critical == 1'b1 && ((r_rtag_flag == 1'b0) || (r_rtag_flag == 1'b1 && ri_pass_en == 1'b1 && r_pass_result == 1'b1))) ? 1'b1 : 1'b0;

/*---------------------------------------- RAM例化 -------------------------------------------*/
// 数据RAM - 存储帧数据
assign w_data_ram_wr_addr = r_data_wr_ptr;
assign w_data_ram_rd_addr = r_data_ram_rd_ptr;
assign w_data_ram_wr_data = {ri_mac_axi_data, ri_mac_axi_data_keep};
assign w_data_ram_we      = (ri_mac_axi_data_valid == 1'b1) && (ro_mac_axi_data_ready == 1'b1);
assign w_data_ram_re      = (r_frame_reading == 1'b1);

ram_simple2port #(
    .RAM_WIDTH               (PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8)),
    .RAM_DEPTH               (RAM_DEPTH),
    .RAM_PERFORMANCE         ("LOW_LATENCY"),
    .INIT_FILE               ()
) u_data_ram (
    .addra                   (w_data_ram_wr_addr),
    .addrb                   (w_data_ram_rd_addr),
    .dina                    (w_data_ram_wr_data),
    .clka                    (i_clk),
    .clkb                    (i_clk),
    .wea                     (w_data_ram_we),
    .enb                     (w_data_ram_re),
    .rstb                    (i_rst),
    .regceb                  (1'b1),
    .doutb                   (w_data_ram_rd_data)
);

// 信息RAM - 存储帧信息
assign w_info_ram_wr_addr = r_wr_addr                                                                     ;
assign w_info_ram_rd_addr = r_rd_addr                                                                     ;
assign w_info_ram_wr_data = {ri_cross_metadata, ri_mac_axi_data_user}                                     ;
assign w_info_ram_we      = (ri_cross_metadata_valid == 1'b1) && (ri_cross_metadata_last == 1'b1) && (r_queue_full == 1'b0);

// 信息RAM读使能：每次仅拉高一个时钟周期
// 触发条件：
// 1) r_rd_addr发生变化（切换到新的队列项）
// 2) 队列由空变非空（首次有效项就绪时）
reg [QUEUE_ADDR_WIDTH-1:0] r_rd_addr_d1;
reg                        r_queue_empty_d1;
// 打拍地址切换信号
always @(posedge i_clk) begin  
    r_info_ram_we <= w_info_ram_we;
    r_rd_addr_d1 <= r_rd_addr; 
end

// 打拍队列空信号
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_queue_empty_d1 <= 1'b1;
    end else begin
        r_queue_empty_d1 <= r_queue_empty;
    end
end

// 控制信息RAM读使能信号
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_info_ram_re <= 1'b0;
    end else begin
        r_info_ram_re <= ((r_rd_addr != r_rd_addr_d1) && r_queue_empty == 1'd0) ? 1'b1 :
                         ((r_queue_empty_d1 == 1'b1) && (r_queue_empty == 1'b0)) ? 1'b1 : 1'b0;
    end
end


always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_info_ram_re_d1 <= 1'b0;
        r_info_ram_re_d2 <= 1'b0;
    end else begin
        r_info_ram_re_d1 <= r_info_ram_re;
        r_info_ram_re_d2 <= r_info_ram_re_d1;
    end
end


ram_simple2port #(
    .RAM_WIDTH               (FRAME_INFO_WIDTH      ),
    .RAM_DEPTH               (QUEUE_SIZE            ),
    .RAM_PERFORMANCE         ("LOW_LATENCY"         ),
    .INIT_FILE               (                      )
) u_info_ram (
    .addra                   (w_info_ram_wr_addr    ),
    .addrb                   (w_info_ram_rd_addr    ),
    .dina                    (w_info_ram_wr_data    ),
    .clka                    (i_clk                 ),
    .clkb                    (i_clk                 ),
    .wea                     (w_info_ram_we         ),
    .enb                     (r_info_ram_re         ),
    .rstb                    (i_rst                 ),
    .regceb                  (1'b1                  ),
    .doutb                   (w_info_ram_rd_data    )
);

// 临时将状态寄存器输出赋值为0
assign o_port_diag_state                = 32'b0;
assign o_port_rx_ultrashort_frm         = 32'b0;
assign o_port_rx_overlength_frm         = 32'b0;
assign o_port_rx_crcerr_frm             = 32'b0;
assign o_port_rx_loopback_frm_cnt       = 32'b0;
assign o_port_broadflow_drop_cnt        = 32'b0;
assign o_port_multiflow_drop_cnt        = 32'b0;
assign o_port_rx_byte_cnt               = 64'b0;
assign o_port_rx_frame_cnt              = 32'b0;
assign o_acl_list_rdy_regs              = 1'b1;

endmodule