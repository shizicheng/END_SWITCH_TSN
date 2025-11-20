module ptp_fsm#(
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

    /*---------------------------------------- -->ptp-fsm输出的状态   -------------------------------------*/
    output              wire   [2:0]                            o_ptp_bcm_state                     , // 00: master 01 : slave 11: reserved
    output              wire                                    o_ptp_bcm_state_valid               ,
    
    output              wire                                    o_ptp_sync_busy                     , // sync期间不允许进行时间同步
    output              wire                                    o_ptp_sync_end                      ,
    output              wire                                    o_ptp_pdelay_busy                   , // pedelay期间不允许进行时间同步     
    output              wire                                    o_ptp_pdelay_end                    ,    
    /*---------------------------------------- ptp—fsm模块子状态输出<-- ---------------------------*/
    output              wire   [7:0]                            o_bcm_state                         ,
    output              wire   [7:0]                            o_portrole_state                    ,
    output              wire   [7:0]                            o_sync_state                        ,
    output              wire   [7:0]                            o_pdelay_state                      ,
    output              wire   [7:0]                            o_pdelay_resp_state                 ,

    /*---------------------------------------- ptp—fsm模块子状态机跳转信号<-- ---------------------------*/
    input               wire                                    i_general_event_twostepflag         , // 一步法还是两步法
    // BMCA
    input               wire                                    i_bcm_event_start                   , // 开始bcma
    input               wire                                    i_bcm_event_monitor_end             , // 结束监听状态 
    input               wire                                    i_bcm_event_forced_gm               , // 强制最佳主时钟
    input               wire                                    i_bcm_event_forced_slave            , // 强制从时钟
    input               wire                                    i_bcm_event_rec_announce            , // 收到announce报文事件
    input               wire                                    i_bcm_event_rec_better_ann          , // 收到更优时钟参数事件    8个端口任意一个收到
    input               wire                                    i_bcm_event_rec_nobetter_ann        , // 收到非更优时钟参数事件     
    input               wire                                    i_bcm_event_master_timeout          , // 超时未收到annoucne事件
    input               wire                                    i_bcm_event_master_linkdown         , // 从端口断开连接事件
    
    // SYNC 
    input               wire                                    i_sync_event_start                  , // 开始相位同步
    input               wire                                    i_sync_event_send_sync_end          , // gm发送sync报文结束事件
    input               wire                                    i_sync_event_send_followup_end      , // follow up报文发送结束事件
    input               wire                                    i_sync_event_end                    , // sync状态执行结束
    // Pdelay测量
    input               wire                                    i_pdelay_event_start                , // 开始路径延迟测量    
    input               wire                                    i_pdelay_event_req_send_end         , // pdelay_req报文发送结束事件  
    input               wire                                    i_pdelay_event_resp_rec_end         , // pdelay_resp报文接收成功事件 
    input               wire                                    i_pdelay_event_respfw_rec_end       , // pdelay_resp_follow_up报文接收成功事件  
    input               wire                                    i_pdelay_event_end                  , // 路径延迟测量结束
    // Pdelay_resp回复
    input               wire                                    i_pdelay_event_resp_start           , // 开始回复路径延迟测量请求  
    input               wire                                    i_pdelay_event_resp_send_end        , // 路径延迟测量resp 发送完成  
    input               wire                                    i_pdelay_event_respfw_sned_end      , // 路径延迟测量resp follow up发送完成 
    input               wire                                    i_pdelay_event_resp_end               // 回复结束事件


);


endmodule 