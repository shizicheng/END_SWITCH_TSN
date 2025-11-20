module ptp_event_reg#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   PORT_NUM                =      8        , 
    parameter                                                   TIMESTAMP_WIDTH         =      80       
    )(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器总线读写 更新参数集 ---------------------------------------*/
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

    // 内部参数输入
    input               wire   [PORT_NUM*2-1:0]                 i_bcm_port_role                     , // 8个端口的角色分配
    input               wire                                    i_bcm_port_valid                    ,  
    input               wire   [2:0]                            i_ptp_bcm_state                     , // 00: master 01 : slave 11: reserved
    input               wire                                    i_ptp_bcm_state_valid               ,
    // 相位偏差计算结果
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_slave_clockoffset                 , // 计算出的主从时间戳的偏差
    input               wire                                    i_slave_clockoffset_sign            , // 时钟偏差的标志位，0：从时钟小于主时钟 1：相反
    input               wire                                    i_slave_clockoffset_valid           , 
    // 路径延迟计算结果
    input               wire   [31:0]                           i_pdelay_time                       , // 路径延迟 
    input               wire                                    i_pdelay_time_valid                 , // 路径延迟     
    // 转发延迟计算结果
    input               wire   [31:0]                           i_forward_time                      , // sync报文的驻留时间 
    input               wire                                    i_forward_time_valid                , // sync报文的驻留时间 
    // 频率校准计算结果
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_clock_add_gap                     , // 频率补偿值
    input               wire                                    i_clock_add_gap_sign                , // gap用来加还是减    
    input               wire                                    i_clock_add_gap_valid               ,
    /*---------------------------------------- 报文解析数据输入   -------------------------------------*/ 
    input               wire                                    i_twostepflag                       , // 标识使用两步时钟还是一步时钟
    input               wire   [63:0]                           i_correctionfield                   , // 修正域字段，存储路径延长和驻留延迟 表示方法查看--11.4.2.6小节   
    input               wire   [7:0]                            i_logmessageinterval                , // 各报文消息间隔，详情查看 -- 11.4.2.9 小节

    // Announce报文 时钟同步生成树优先级向量 time-synchronization spanning tree priority vectors  -- 10.3.4小节标识各变量含义 
    input               wire   [7:0]                            i_stpv_priority1                    , // systemIdentity priority1  
    input               wire   [7:0]                            i_stpv_clkclass                     ,  
    input               wire   [7:0]                            i_stpv_clkaccuracy                  ,  
    input               wire   [15:0]                           i_stpv_variance                     ,
    input               wire   [7:0]                            i_stpv_priority2                    ,
    input               wire   [63:0]                           i_stpv_clkidentity                  ,
    input               wire   [15:0]                           i_stpv_stepsremoved                 , // stepsRemoved     
    input               wire   [79:0]                           i_stpv_sourceportid                 , // sourcePortIdentity ，来自header字段
    input               wire   [15:0]                           i_stpv_portnumrecofport             , // 端口接收 PTP 报文的编号 ， 来自metadata

    input               wire                                    i_stpv_valid                        ,
    input               wire                                    i_port_link                         ,
    input               wire   [15:0]                           i_ann_sequenceid                    , // Announce报文的报文序号，独立维护

    // sync报文  
    input               wire   [79:0]                           i_sync_origintimestamp              , // 如果两步法，则sync报文只有header+reserved
    input               wire   [15:0]                           i_sync_sequenceid                   , // sync报文的报文序号，独立维护
    input               wire                                    i_sync_valid                        , // sync报文有效信号
    // follow up 报文
    input               wire   [79:0]                           i_follow_up_origintimestamp         , // 两步法对应sync报文的时间戳，如果是一步法，没有follow up报文
    input               wire                                    i_follow_up_valid                   , // follow up报文有效信号    
    input               wire   [15:0]                           i_follow_up_sequenceid              , // follow up报文的报文序号，关联sync
    input               wire   [31:0]                           i_follow_up_rateratio               , // 主频比 --表示方法见11.4.4.3.6小节

    // Pdelay_req报文只有header
    input               wire   [15:0]                           i_pdelay_req_sequenceid             , // pdelay_req报文的报文序号，独立维护
    input               wire                                    i_pdelay_req_valid                  , // pdelay_req报文有效信号

    // Pdelay_resp报文
    input               wire   [79:0]                           i_pdelay_resprectimestamp_t1        , // 报文携带的对端接收到pdelay_req报文时的时间戳 t1
    input               wire   [79:0]                           i_pdelay_respportid                 , // 关联 Pdelay_Req 消息的 sourcePortIdentity 字段的值
    input               wire   [15:0]                           i_pdelay_resp_sequenceid            , // pdelay_req报文的报文序号，独立维护     
    input               wire                                    i_pdelay_resp_valid                 , // pdelay_resp报文有效信号 
    
    // Pdelay_Resp_Follow_Up报文
    input               wire   [79:0]                           i_pdelay_resporigntimestamp_t2      , // 报文携带的对端发出pdelay_resp报文时的时间戳 t2  
    input               wire   [79:0]                           i_pdelay_respfwportid               , // 关联 Pdelay_Resp 消息的 sourcePortIdentity 字段的值
    input               wire   [15:0]                           i_pdelay_respfw_sequenceid          , // pdelay_resp_floow_up报文的报文序号，独立维护    
    input               wire                                    i_pdelay_respfw_valid               ,  // pdelay_resp_floow_up报文有效信号 
    // /*---------------------------------------- --> ptp_fsm   -------------------------------------*/     
    // SYNC 
    output              wire                                    o_sync_event_start                  , // 开始相位同步
    output              wire                                    o_sync_event_send_sync_end          , // gm发送sync报文结束事件
    output              wire                                    o_sync_event_send_followup_end      , // follow up报文发送结束事件
    output              wire                                    o_sync_event_end                    , // sync状态执行结束
    // Pdelay测量
    output              wire                                    o_pdelay_event_start                , // 开始路径延迟测量    
    output              wire                                    o_pdelay_event_req_send_end         , // pdelay_req报文发送结束事件  
    output              wire                                    o_pdelay_event_resp_rec_end         , // pdelay_resp报文接收成功事件 
    output              wire                                    o_pdelay_event_respfw_rec_end       , // pdelay_resp_follow_up报文接收成功事件  
    output              wire                                    o_pdelay_event_end                  , // 路径延迟测量结束
    // Pdelay_resp回复
    output              wire                                    o_pdelay_event_resp_start           , // 开始回复路径延迟测量请求  
    output              wire                                    o_pdelay_event_resp_send_end        , // 路径延迟测量resp 发送完成  
    output              wire                                    o_pdelay_event_respfw_sned_end      , // 路径延迟测量resp follow up发送完成 
    output              wire                                    o_pdelay_event_resp_end              // 回复结束事件

);

endmodule 