/*
    本模块需要将输入的数据流进行解析，并输出出去。同时根据时间戳地址，将从外部存时间戳的ram中将对应帧类型的时间戳读入并锁存（根据帧类型来确定t0,t1,t2,t3 ， 时间戳一般保证和报文的squence ID匹配）
    需要的参数要输出给ptp_reg_list模块、ptp_event模块
    一帧解析的数据输出并锁存，其他模块处理完成之后，给本模块发起造帧请求，接收到后，往ptp_tx_pkt发起发帧请求，并输出需要的参数，发帧完成后，返回end信号

*/

module ptp_rx_pkt#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        , 
    parameter                                                   TIMESTAMP_WIDTH         =      80       ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 

)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    // /*---------------------------------------- 寄存器总线读写  ---------------------------------------*/
    // // 寄存器写控制接口     
    // output             wire                                     o_ptp_reg_bus_we                 , // 寄存器写使能
    // output             wire   [REG_ADDR_BUS_WIDTH-1:0]          o_ptp_reg_bus_we_addr            , // 寄存器写地址
    // output             wire   [REG_DATA_BUS_WIDTH-1:0]          o_ptp_reg_bus_we_din             , // 寄存器写数据
    // output             wire                                     o_ptp_reg_bus_we_din_v           , // 寄存器写数据使能
    // // 寄存器读控制接口     
    // output             wire                                     o_ptp_reg_bus_rd                 , // 寄存器读使能
    // output             wire   [REG_ADDR_BUS_WIDTH-1:0]          o_ptp_reg_bus_rd_addr            , // 寄存器读地址
    // input              wire   [REG_DATA_BUS_WIDTH-1:0]          i_ptp_reg_bus_rd_dout            , // 读出寄存器数据
    // input              wire                                     i_ptp_reg_bus_rd_dout_v          , // 读数据有效使能
    /*---------------------------------------- as数据输入  -------------------------------------------*/
    input               wire                                    i_tsn_as_port_link                  , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH-1:0]           i_tsn_as_port_axi_data              , // 端口数据流 
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_tsn_as_axi_data_keep              , // 端口数据流掩码，有效字节指示
    input               wire                                    i_tsn_as_axi_data_valid             , // 端口数据有效
    output              wire                                    o_tsn_as_axi_data_ready             , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_tsn_as_axi_data_last              , // 数据流结束标识 
    
    input               wire   [METADATA_WIDTH-1:0]             i_tsn_as_metadata                   , // 总线 metadata 数据  
    input               wire                                    i_tsn_as_metadata_valid             , // 总线 metadata 数据有效信号

    /*---------------------------------------- 报文解析数据输出   -------------------------------------*/
    // 输出给ptp_event模块进行相关时钟同步动作，输出给ptp_tx_pkt模块作为造帧需要的Header数据
    // 报文头信息 Header字段 -- 10.6.2小节 
    // flag 字段
    // output              wire   [3:0]                            o_messagetype                       , // 标识ptp报文类型 
    // output              wire   [15:0]                           o_messagelength                     , // 报文长度 从header开始
    output              wire                                    o_twostepflag                       , // 标识使用两步时钟还是一步时钟
    output              wire   [63:0]                           o_correctionfield                   , // 修正域字段，存储路径延长和驻留延迟 表示方法查看--11.4.2.6小节   
    output              wire   [7:0]                            o_logmessageinterval                , // 各报文消息间隔，详情查看 -- 11.4.2.9 小节

    // Announce报文 时钟同步生成树优先级向量 time-synchronization spanning tree priority vectors  -- 10.3.4小节标识各变量含义 
    output              wire   [7:0]                            o_stpv_priority1                    , // systemIdentity priority1  
    output              wire   [7:0]                            o_stpv_clkclass                     ,  
    output              wire   [7:0]                            o_stpv_clkaccuracy                  ,  
    output              wire   [15:0]                           o_stpv_variance                     ,
    output              wire   [7:0]                            o_stpv_priority2                    ,
    output              wire   [63:0]                           o_stpv_clkidentity                  ,
    output              wire   [15:0]                           o_stpv_stepsremoved                 , // stepsRemoved     
    output              wire   [79:0]                           o_stpv_sourceportid                 , // sourcePortIdentity ，来自header字段
    output              wire   [15:0]                           o_stpv_portnumrecofport             , // 端口接收 PTP 报文的编号 ， 来自metadata
    output              wire                                    o_stpv_valid                        ,

    output              wire                                    o_port_link                         ,
    output              wire   [15:0]                           o_ann_sequenceid                    , // Announce报文的报文序号，独立维护

    // sync报文  
    output              wire   [79:0]                           o_sync_origintimestamp              , // 如果两步法，则sync报文只有header+reserved
    output              wire   [15:0]                           o_sync_sequenceid                   , // sync报文的报文序号，独立维护
    output              wire                                    o_sync_valid                        , // sync报文有效信号
    // follow up 报文
    output              wire   [79:0]                           o_follow_up_origintimestamp         , // 两步法对应sync报文的时间戳，如果是一步法，没有follow up报文
    output              wire                                    o_follow_up_valid                   , // follow up报文有效信号    
    output              wire   [15:0]                           o_follow_up_sequenceid              , // follow up报文的报文序号，关联sync
    output              wire   [31:0]                           o_follow_up_rateratio               , // 主频比 --表示方法见11.4.4.3.6小节

    // Pdelay_req报文只有header
    output              wire   [15:0]                           o_pdelay_req_sequenceid             , // pdelay_req报文的报文序号，独立维护
    output              wire                                    o_pdelay_req_valid                  , // pdelay_req报文有效信号

    // Pdelay_resp报文
    output              wire   [79:0]                           o_pdelay_resprectimestamp_t1        , // 报文携带的对端接收到pdelay_req报文时的时间戳 t1
    output              wire   [79:0]                           o_pdelay_respportid                 , // 关联 Pdelay_Req 消息的 sourcePortIdentity 字段的值
    output              wire   [15:0]                           o_pdelay_resp_sequenceid            , // pdelay_req报文的报文序号，独立维护     
    output              wire                                    o_pdelay_resp_valid                 , // pdelay_resp报文有效信号 
    
    // Pdelay_Resp_Follow_Up报文
    output              wire   [79:0]                           o_pdelay_resporigntimestamp_t2      , // 报文携带的对端发出pdelay_resp报文时的时间戳 t2  
    output              wire   [79:0]                           o_pdelay_respfwportid               , // 关联 Pdelay_Resp 消息的 sourcePortIdentity 字段的值
    output              wire   [15:0]                           o_pdelay_respfw_sequenceid          , // pdelay_resp_floow_up报文的报文序号，独立维护    
    output              wire                                    o_pdelay_respfw_valid               , // pdelay_resp_floow_up报文有效信号 

    /*---------------------------------------- 造帧请求输入 <-> ptp_event  -------------------------------------*/    

    input               wire                                    i_announce_req                      , // 请求转发/造帧annoucne报文  
    input               wire                                    i_sync_req                          , // 请求转发/造帧sync报文
    input               wire                                    i_follow_up_req                     , // 请求转发/造帧follow_up报文   
    input               wire                                    i_pdelayreq_req                     , // 请求转发/造帧pdelayreq报文   
    input               wire                                    i_pdelayresp_req                    , // 请求转发/造帧pdelayresp报文   
    input               wire                                    i_pdelayresp_fw_req                 , // 请求转发/造帧pdelayreq_follow_up报文
    
    output              wire                                    o_announce_ack                      , 
    output              wire                                    o_sync_ack                          , 
    output              wire                                    o_follow_up_ack                     , 
    output              wire                                    o_pdelayreq_ack                     , 
    output              wire                                    o_pdelayresp_ack                    , 
    output              wire                                    o_pdelayresp_fw_ack                 , 

    input               wire   [7:0]                            i_announce_send_port                , // announce报文的转发端口向量 Master 
    input               wire   [7:0]                            i_sync_send_port                    , // sync报文的转发端口向量 
    input               wire   [7:0]                            i_follow_up_send_port               , // follow_up报文的转发端口向量     
    input               wire   [7:0]                            i_pdelay_req_send_port              , // pdelay_req报文的转发端口向量     
    input               wire   [7:0]                            i_pdelay_resp_send_port             , // pdelay_resp报文的转发端口向量         
    input               wire   [7:0]                            i_pdelay_resp_followup_send_port    , // pdelay_resp_followup报文的转发端口向量    

    /*---------------------------------------- 造帧请求输出 <-> ptp_tx_pkt  -------------------------------------*/    
    output              wire                                    o_announce_req                      , // 请求转发/造帧annoucne报文
    output              wire                                    o_sync_req                          , // 请求转发/造帧sync报文
    output              wire                                    o_follow_up_req                     , // 请求转发/造帧follow_up报文   
    output              wire                                    o_pdelayreq_req                     , // 请求转发/造帧pdelayreq报文   
    output              wire                                    o_pdelayresp_req                    , // 请求转发/造帧pdelayresp报文   
    output              wire                                    o_pdelayresp_fw_req                 , // 请求转发/造帧pdelayreq_follow_up报文

    input               wire                                    i_announce_ack                      ,  
    input               wire                                    i_sync_ack                          ,  
    input               wire                                    i_follow_up_ack                     ,  
    input               wire                                    i_pdelayreq_ack                     ,  
    input               wire                                    i_pdelayresp_ack                    ,  
    input               wire                                    i_pdelayresp_fw_ack                 ,  

    input               wire                                    i_send_frame_end                    , // 发帧结束信号

    output              wire   [15:0]                           o_ptpmessagetype                    , // ptp报文消息类型           
    output              wire   [7:0]                            o_ptp_port                          , // 报文来自哪个端口          
    output              wire   [6:0]                            o_timestamp_addr                    , // 存储时间戳的地址
    output              wire                                    o_timestamp_rd                      , // 解析出来后，就开始读，读完送入ptp-tx-pkt

    output              wire   [7:0]                            o_announce_send_port                , // announce报文的转发端口向量
    output              wire   [7:0]                            o_sync_send_port                    , // sync报文的转发端口向量 
    output              wire   [7:0]                            o_follow_up_send_port               , // follow_up报文的转发端口向量     
    output              wire   [7:0]                            o_pdelay_req_send_port              , // pdelay_req报文的转发端口向量     
    output              wire   [7:0]                            o_pdelay_resp_send_port             , // pdelay_resp报文的转发端口向量         
    output              wire   [7:0]                            o_pdelay_resp_followup_send_port      // pdelay_resp_followup报文的转发端口向量
);

reg  [15:0]             r_ptpmessagetype                        ;  // ptp报文消息类型
reg  [7:0]              r_ptp_port                              ;  // 报文来自哪个端口
reg  [6:0]              r_timestamp_addr                        ;  // 存储时间戳的地址


endmodule 