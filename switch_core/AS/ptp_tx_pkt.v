module ptp_tx_pkt#(
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
    /*---------------------------------------- 输出接口 ----------------------------------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac0_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac0_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac0_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac0_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac0_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac0_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx0_req                     , // 通道输入请求
    input              wire                                     i_tx0_ack                     , // 通道请求应答
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac1_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac1_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac1_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac1_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac1_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac1_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx1_req                     , // 通道输入请求
    input              wire                                     i_tx1_ack                     , // 通道请求应答
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac2_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac2_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac2_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac2_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac2_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac2_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx2_req                     , // 通道输入请求
    input              wire                                     i_tx2_ack                     , // 通道请求应答
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac3_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac3_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac3_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac3_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac3_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac3_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx3_req                     , // 通道输入请求
    input              wire                                     i_tx3_ack                     , // 通道请求应答
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac4_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac4_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac4_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac4_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac4_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac4_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx4_req                     , // 通道输入请求
    input              wire                                     i_tx4_ack                     , // 通道请求应答
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac5_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac5_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac5_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac5_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac5_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac5_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx5_req                     , // 通道输入请求
    input              wire                                     i_tx5_ack                     , // 通道请求应答
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac6_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac6_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac6_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac6_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac6_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac6_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx6_req                     , // 通道输入请求
    input              wire                                     i_tx6_ack                     , // 通道请求应答
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac7_port_link              , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac7_port_axi_data          , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac7_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac7_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac7_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac7_axi_data_last          , // 数据流结束标识
    output             wire                                     o_tx7_req                     , // 通道输入请求
    input              wire                                     i_tx7_ack                     , // 通道请求应答
`endif
    /*---------------------------------------- 寄存器总线读写 读取属性参数集 ---------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_ptp_reg_bus_we                    , // 寄存器写使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_ptp_reg_bus_we_addr               , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_ptp_reg_bus_we_din                , // 寄存器写数据
    output              wire                                    o_ptp_reg_bus_we_din_v              , // 寄存器写数据使能
    // 寄存器读控制接口         
    output              wire                                    o_ptp_reg_bus_rd                    , // 寄存器读使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_ptp_reg_bus_rd_addr               , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_ptp_reg_bus_rd_dout               , // 读出寄存器数据
    input               wire                                    i_ptp_reg_bus_rd_dout_v             , // 读数据有效使能
    /*---------------------------------------- pkt-rx-pkt --> 造帧/转发请求  ---------------------------------------*/

    input               wire                                    i_ptp_bcm_state                     , // 当前系统的 主从状态 
    input               wire                                    i_ptp_bcm_state_valid               , // 由主从状态来判断当前收转发还是主动发帧 获取报文参数的来源不同

    input               wire                                    i_announce_req                      , // 请求转发/造帧annoucne报文  
    input               wire                                    i_sync_req                          , // 请求转发/造帧sync报文
    input               wire                                    i_follow_up_req                     , // 请求转发/造帧follow_up报文   
    input               wire                                    i_pdelayreq_req                     , // 请求转发/造帧pdelayreq报文   
    input               wire                                    i_pdelayresp_req                    , // 请求转发/造帧pdelayresp报文   
    input               wire                                    i_pdelayresp_fw_req                 , // 请求转发/造帧pdelayreq_follow_up报文

    input               wire   [7:0]                            i_announce_send_port                , // announce报文的转发端口向量
    input               wire   [7:0]                            i_sync_send_port                    , // sync报文的转发端口向量 
    input               wire   [7:0]                            i_follow_up_send_port               , // follow_up报文的转发端口向量     
    input               wire   [7:0]                            i_pdelay_req_send_port              , // pdelay_req报文的转发端口向量     
    input               wire   [7:0]                            i_pdelay_resp_send_port             , // pdelay_resp报文的转发端口向量         
    input               wire   [7:0]                            i_pdelay_resp_followup_send_port    , // pdelay_resp_followup报文的转发端口向量

    output              wire                                    o_announce_ack                      ,  
    output              wire                                    o_sync_ack                          ,  
    output              wire                                    o_follow_up_ack                     ,  
    output              wire                                    o_pdelayreq_ack                     ,  
    output              wire                                    o_pdelayresp_ack                    ,  
    output              wire                                    o_pdelayresp_fw_ack                 ,  

    output              wire                                    o_send_frame_end                    , // 发帧结束信号

    /*---------------------------------------- pkt-rx-pkt --> 转发帧数据输入  ---------------------------------------*/
    
    // sync报文 
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_sync_origintimestamp              , // 如果两步法，则sync报文只有header+reserved
    input               wire   [15:0]                           i_sync_sequenceid                   , // sync报文的报文序号，独立维护
    input               wire                                    i_sync_valid                        , // sync报文有效信号
    // follow up 报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_follow_up_origintimestamp         , // 两步法对应sync报文的时间戳，如果是一步法，没有follow up报文
    input               wire                                    i_follow_up_valid                   , // follow up报文有效信号    
    input               wire   [15:0]                           i_follow_up_sequenceid              , // follow up报文的报文序号，关联sync
    input               wire   [31:0]                           i_follow_up_rateratio               , // 主频比 --表示方法见11.4.4.3.6小节
 
    // Pdelay_req报文只有header
    input               wire   [15:0]                           i_pdelay_req_sequenceid             , // pdelay_req报文的报文序号，独立维护
    input               wire                                    i_pdelay_req_valid                  , // pdelay_req报文有效信号

    // Pdelay_resp报文
    // input               wire   [TIMESTAMP_WIDTH-1:0]                           i_pdelay_resprectimestamp_t1        , // 报文携带的对端接收到pdelay_req报文时的时间戳 t1
    // input               wire   [TIMESTAMP_WIDTH-1:0]                           i_pdelay_respportid                 , // 关联 Pdelay_Req 消息的 sourcePortIdentity 字段的值
    input               wire   [15:0]                           i_pdelay_resp_sequenceid            , // pdelay_req报文的报文序号，独立维护     
    input               wire                                    i_pdelay_resp_valid                 , // pdelay_resp报文有效信号 
    
    // Pdelay_Resp_Follow_Up报文
    // input               wire   [TIMESTAMP_WIDTH-1:0]                           i_pdelay_resporigntimestamp_t2      , // 报文携带的对端发出pdelay_resp报文时的时间戳 t2  
    // input               wire   [TIMESTAMP_WIDTH-1:0]                           i_pdelay_respfwportid               , // 关联 Pdelay_Resp 消息的 sourcePortIdentity 字段的值
    input               wire   [15:0]                           i_pdelay_respfw_sequenceid          , // pdelay_resp_floow_up报文的报文序号，独立维护    
    input               wire                                    i_pdelay_respfw_valid               , // pdelay_resp_floow_up报文有效信号 

    /*---------------------------------------- time-reg-list --> 需要的时间戳输入  -------------------*/
    // input               wire   [TIMESTAMP_WIDTH-1:0]            i_current_timestamp                 ,
    // input               wire                                    i_current_timestamp_valid             // 从缓存多个通道的时间戳缓存ram中读取的当前需要的报文时间戳
    input              wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_req_in_timestamp           , // 
    input              wire                                    i_pdelay_req_in_timestamp_valid     , // 
     
    input              wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_resp_out_timestamp         , //
    input              wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_resp_out_timestamp_valid   , //
 
    input              wire   [TIMESTAMP_WIDTH-1:0]            i_sync_out_timestamp                , // 主时钟 sync出站的时间戳
    input              wire   [TIMESTAMP_WIDTH-1:0]            i_sync_out_timestamp_valid            // 主时钟 sync出站的时间戳

    // output              wire                                    o_timereglist_rd                    , // 2 : pdelay_resp报文出时间戳 -> pdelay_resp-followup报文携带
    // output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_timereglist_addr                  , // 1 : pdelay_req 报文入时间戳 -> pdelay_resp报文携带
    // output              wire   [1:0]                            o_rd_timestamp_req                  , // 0 : sync报文的出时间戳 M只有出时间戳 S只有入时间戳 
);

`include "synth_cmd_define.vh"
// 转发announce报文需要的参数 ，从ptp_reg_list读取
reg  [7:0]                            r_stpv_best_priority1                    ; //比较得到的最优的stpv
reg  [7:0]                            r_stpv_best_clkclass                     ; //比较得到的最优的stpv
reg  [7:0]                            r_stpv_best_clkaccuracy                  ; //比较得到的最优的stpv
reg  [15:0]                           r_stpv_best_variance                     ; //比较得到的最优的stpv
reg  [7:0]                            r_stpv_best_priority2                    ; //比较得到的最优的stpv
reg  [63:0]                           r_stpv_best_clkidentity                  ; //比较得到的最优的stpv
reg  [15:0]                           r_stpv_stepsremoved                      ; //比较得到的最优的stpv
// reg  [TIMESTAMP_WIDTH-1:0]                           r_stpv_best_sourceportid                 ,
// reg  [15:0]                           r_stpv_best_portnumrecofport             ,

// sync报文需要的参数
reg                                   r_twostepflag                            ; // 表明几步法         
reg   [63:0]                          r_correctionfield                        ; // 修正域字段，存储路径延长和驻留延迟 表示方法查看--11.4.2.6小节   
reg   [7:0]                           r_logmessageinterval                     ; // 各报文消息间隔，详情查看 -- 11.4.2.9 小节

// 转发则直接从收到的sync取，否则读存时间戳的地址
reg   [TIMESTAMP_WIDTH-1:0]           r_sync_origintimestamp                   ; // 如果两步法，则sync报文只有header+reserved
reg   [15:0]                          r_sync_sequenceid                        ; // sync报文的报文序号，独立维护
reg                                   r_sync_valid                             ; // sync报文有效信号

// follow up 
reg   [TIMESTAMP_WIDTH-1:0]                          r_follow_up_origintimestamp              ; // 两步法对应sync报文的时间戳，如果是一步法，没有follow up报文  
reg   [15:0]                          r_follow_up_sequenceid                   ; // follow up报文的报文序号，关联sync
reg   [31:0]                          r_follow_up_rateratio                    ; // 主频比 --表示方法见11.4.4.3.6小节
 
// 需要自己本地打的时间戳都通过 寄存器总线读取 需要的时间戳

endmodule 