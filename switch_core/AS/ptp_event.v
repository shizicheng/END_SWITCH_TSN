/*
    上电后，首先接收ptp-reg-list模块中的寄存器数据初始化，有通道link后，�?始触发bcma事件
    ptp-rx-pkt模块将解析的announce数据输入进来后，对报文解析数据的valid判断，首先进入ptp-event-reg模块将需要更新的参数更新进ptp-reg-list
    同时根据valid信号，将接收的stpv和本地的stpv比较，得到本端口的角色�?�向并缓存起来（M/S/P/D，真正的角色�?要等�?有link的�?�道接收到announce后一起比较）�?
    比较完一个�?�道的stpv后，等待�?下个通道的输入进来，同时�?启超时计�?
    全部通道接收完成后，或�?�超时后，开始接收到ann报文的�?�道的内部最终比较，确定端口角色

*/
module ptp_event#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地�?位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位�?
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                                                   PORT_NUM                =      8        , 
    parameter                                                   TIMESTAMP_WIDTH         =      80       ,
    parameter                                                   PORT_NUM_WIDTH          =     clog2(PORT_NUM) ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 

)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器�?�线读写 更新参数�? ---------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_ptp_reg_bus_we                    , // 寄存器写使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_ptp_reg_bus_we_addr               , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_ptp_reg_bus_we_din                , // 寄存器写数据
    output              wire                                    o_ptp_reg_bus_we_din_v              , // 寄存器写数据使能
    // 寄存器读控制接口         
    output              wire                                    o_ptp_reg_bus_rd                    , // 寄存器读使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_ptp_reg_bus_rd_addr               , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_ptp_reg_bus_rd_dout               , // 读出寄存器数�?
    input               wire                                    i_ptp_reg_bus_rd_dout_v             , // 读数据有效使�?
     
    /*---------------------------------------- 报文解析数据输入   -------------------------------------*/ 
    input               wire                                    i_twostepflag                       , // 标识使用两步时钟还是�?步时�?
    input               wire   [63:0]                           i_correctionfield                   , // 修正域字段，存储路径延长和驻留延�? 表示方法查看--11.4.2.6小节   
    input               wire   [7:0]                            i_logmessageinterval                , // 各报文消息间隔，详情查看 -- 11.4.2.9 小节
    
    input               wire   [PORT_NUM_WIDTH-1:0]             i_ptp_port                          , // 接收报文的端�?

    // Announce报文 时钟同步生成树优先级向量 time-synchronization spanning tree priority vectors  -- 10.3.4小节标识各变量含�? 
    input               wire   [7:0]                            i_stpv_priority1                    , // systemIdentity priority1  
    input               wire   [7:0]                            i_stpv_clkclass                     ,  
    input               wire   [7:0]                            i_stpv_clkaccuracy                  ,  
    input               wire   [15:0]                           i_stpv_variance                     ,
    input               wire   [7:0]                            i_stpv_priority2                    ,
    input               wire   [63:0]                           i_stpv_clkidentity                  ,
    input               wire   [15:0]                           i_stpv_stepsremoved                 , // stepsRemoved     
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_stpv_sourceportid                 , // sourcePortIdentity ，来自header字段
    input               wire   [15:0]                           i_stpv_portnumrecofport             , // 端口接收 PTP 报文的编�? �? 来自metadata
    input               wire                                    i_stpv_valid                        ,

    input               wire                                    i_port_link                         ,
    input               wire   [15:0]                           i_ann_sequenceid                    , // Announce报文的报文序号，独立维护

    // sync报文  
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_sync_origintimestamp              , // 如果两步法，则sync报文只有header+reserved
    input               wire   [15:0]                           i_sync_sequenceid                   , // sync报文的报文序号，独立维护
    input               wire                                    i_sync_valid                        , // sync报文有效信号
    // follow up 报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_follow_up_origintimestamp         , // 两步法对应sync报文的时间戳，如果是�?步法，没有follow up报文
    input               wire                                    i_follow_up_valid                   , // follow up报文有效信号    
    input               wire   [15:0]                           i_follow_up_sequenceid              , // follow up报文的报文序号，关联sync
    input               wire   [31:0]                           i_follow_up_rateratio               , // 主频�? --表示方法�?11.4.4.3.6小节

    // Pdelay_req报文只有header
    input               wire   [15:0]                           i_pdelay_req_sequenceid             , // pdelay_req报文的报文序号，独立维护
    input               wire                                    i_pdelay_req_valid                  , // pdelay_req报文有效信号

    // Pdelay_resp报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_resprectimestamp_t1        , // 报文携带的对端接收到pdelay_req报文时的时间�? t1
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_respportid                 , // 关联 Pdelay_Req 消息�? sourcePortIdentity 字段的�??
    input               wire   [15:0]                           i_pdelay_resp_sequenceid            , // pdelay_req报文的报文序号，独立维护     
    input               wire                                    i_pdelay_resp_valid                 , // pdelay_resp报文有效信号 
    
    // Pdelay_Resp_Follow_Up报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_resporigntimestamp_t2      , // 报文携带的对端发出pdelay_resp报文时的时间�? t2  
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_respfwportid               , // 关联 Pdelay_Resp 消息�? sourcePortIdentity 字段的�??
    input               wire   [15:0]                           i_pdelay_respfw_sequenceid          , // pdelay_resp_floow_up报文的报文序号，独立维护    
    input               wire                                    i_pdelay_respfw_valid               , // pdelay_resp_floow_up报文有效信号     

    /*---------------------------------------- -->给ptp—rx-pkt模块的�?�帧请求   -------------------------------------*/
    output              wire   [1:0]                            o_announce_req                      , // 请求转发/造帧annoucne报文  [0] : 主动发帧 �?1�? �? 转发�? 
    output              wire   [1:0]                            o_sync_req                          , // 请求转发/造帧sync报文
    output              wire   [1:0]                            o_follow_up_req                     , // 请求转发/造帧follow_up报文   
    output              wire   [1:0]                            o_pdelayreq_req                     , // 请求转发/造帧pdelayreq报文   
    output              wire   [1:0]                            o_pdelayresp_req                    , // 请求转发/造帧pdelayresp报文   
    output              wire   [1:0]                            o_pdelayresp_fw_req                 , // 请求转发/造帧pdelayreq_follow_up报文
    
    input               wire                                    i_announce_ack                      , 
    input               wire                                    i_sync_ack                          , 
    input               wire                                    i_follow_up_ack                     , 
    input               wire                                    i_pdelayreq_ack                     , 
    input               wire                                    i_pdelayresp_ack                    , 
    input               wire                                    i_pdelayresp_fw_ack                 , 
 
    output              wire   [7:0]                            o_announce_send_port                , // announce报文的转发端口向�?
    output              wire   [7:0]                            o_sync_send_port                    , // sync报文的转发端口向�? 
    output              wire   [7:0]                            o_follow_up_send_port               , // follow_up报文的转发端口向�?     
    output              wire   [7:0]                            o_pdelay_req_send_port              , // pdelay_req报文的转发端口向�?     
    output              wire   [7:0]                            o_pdelay_resp_send_port             , // pdelay_resp报文的转发端口向�?         
    output              wire   [7:0]                            o_pdelay_resp_followup_send_port    , // pdelay_resp_followup报文的转发端口向�?

    /*---------------------------------------- <--ptp-fsm输入的状�?   -------------------------------------*/
    input               wire   [2:0]                            i_ptp_bcm_state                     , // 00: master 01 : slave 11: reserved
    input               wire                                    i_ptp_bcm_state_valid               ,
    
    input               wire                                    i_ptp_sync_busy                     , // sync期间不允许进行时间同�?
    input               wire                                    i_ptp_sync_end                      ,
    input               wire                                    i_ptp_pdelay_busy                   , // pedelay期间不允许进行时间同�?     
    input               wire                                    i_ptp_pdelay_end                    ,    
    /*---------------------------------------- ptp—fsm模块子状态输�?<-- ---------------------------*/
    input               wire   [7:0]                            i_bcm_state                         ,
    input               wire   [7:0]                            i_portrole_state                    ,
    input               wire   [7:0]                            i_sync_state                        ,
    input               wire   [7:0]                            i_pdelay_state                      ,
    input               wire   [7:0]                            i_pdelay_resp_state                 ,   

    /*---------------------------------------- -->给ptp—fsm模块子状态机跳转信号   -------------------------------------*/
    output              wire                                    o_general_event_twostepflag         , // �?步法还是两步�?
    // BMCA
    output              wire                                    o_bcm_event_start                   , // �?始bcma
    output              wire                                    o_bcm_event_monitor_end             , // 结束监听状�?? 
    output              wire                                    o_bcm_event_forced_gm               , // 强制�?佳主时钟
    output              wire                                    o_bcm_event_forced_slave            , // 强制从时�?
    output              wire                                    o_bcm_event_rec_announce            , // 收到announce报文事件
    output              wire                                    o_bcm_event_rec_better_ann          , // 收到更优时钟参数事件    8个端口任意一个收�?
    output              wire                                    o_bcm_event_rec_nobetter_ann        , // 收到非更优时钟参数事�?     
    output              wire                                    o_bcm_event_master_timeout          , // 超时未收到annoucne事件
    output              wire                                    o_bcm_event_master_linkdown         , // 从端口断�?连接事件

    // SYNC 
    output              wire                                    o_sync_event_start                  , // �?始相位同�?
    output              wire                                    o_sync_event_send_sync_end          , // gm发�?�sync报文结束事件
    output              wire                                    o_sync_event_send_followup_end      , // follow up报文发�?�结束事�?
    output              wire                                    o_sync_event_end                    , // sync状�?�执行结�?
    // Pdelay测量
    output              wire                                    o_pdelay_event_start                , // �?始路径延迟测�?    
    output              wire                                    o_pdelay_event_req_send_end         , // pdelay_req报文发�?�结束事�?  
    output              wire                                    o_pdelay_event_resp_rec_end         , // pdelay_resp报文接收成功事件 
    output              wire                                    o_pdelay_event_respfw_rec_end       , // pdelay_resp_follow_up报文接收成功事件  
    output              wire                                    o_pdelay_event_end                  , // 路径延迟测量结束
    // Pdelay_resp回复
    output              wire                                    o_pdelay_event_resp_start           , // �?始回复路径延迟测量请�?  
    output              wire                                    o_pdelay_event_resp_send_end        , // 路径延迟测量resp 发�?�完�?  
    output              wire                                    o_pdelay_event_respfw_sned_end      , // 路径延迟测量resp follow up发�?�完�? 
    output              wire                                    o_pdelay_event_resp_end             , // 回复结束事件

    // 计算模块的计算结果，相位偏差，路径延迟，转发延迟，频率比 更新参数�?
    // 相位偏差计算结果
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_slave_clockoffset                 , // 计算出的主从时间戳的偏差
    input               wire                                    i_slave_clockoffset_sign            , // 时钟偏差的标志位�?0：从时钟小于主时�? 1：相�?
    input               wire                                    i_slave_clockoffset_valid           , 
    // 路径延迟计算结果
    input               wire   [31:0]                           i_pdelay_time                       , // 路径延迟 
    input               wire                                    i_pdelay_time_valid                 , // 路径延迟     
    // 转发延迟计算结果
    input               wire   [31:0]                           i_forward_time                      , // sync报文的驻留时�? 
    input               wire                                    i_forward_time_valid                , // sync报文的驻留时�? 
    // 频率校准计算结果
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_clock_add_gap                     , // 频率补偿�?
    input               wire                                    i_clock_add_gap_sign                , // gap用来加还是减    
    input               wire                                    i_clock_add_gap_valid               

    );


/*---------------------------------------- clog2计算函数 -------------------------------------------*/
function integer clog2;
    input integer value;
    integer temp;
    begin
        temp = value - 1;
        for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
            temp = temp >> 1;
    end
endfunction 


wire   [PORT_NUM*2-1:0]                 w_bcm_port_role                  ;
wire                                    w_bcm_port_valid                 ;

ptp_event_bcma_portrole #(
    .PORT_NUM                           (PORT_NUM                       ),
    .TIMESTAMP_WIDTH                    (TIMESTAMP_WIDTH                ),
    .PORT_NUM_WIDTH                     (PORT_NUM_WIDTH                 )
) ptp_event_bcma_portrole_inst(                 
    .i_clk                              (i_clk                          ),
    .i_rst                              (i_rst                          ),

    // 接收的announce报文信息
    .i_messagerec_port                  (i_ptp_port                     ),
    .i_port_link                        ({PORT_NUM{i_port_link}}        ), // 若i_port_link为单bit，需扩展为向�?
    .i_stpv_priority1                   (i_stpv_priority1               ),
    .i_stpv_clkclass                    (i_stpv_clkclass                ),
    .i_stpv_clkaccuracy                 (i_stpv_clkaccuracy             ),
    .i_stpv_variance                    (i_stpv_variance                ),
    .i_stpv_priority2                   (i_stpv_priority2               ),
    .i_stpv_clkidentity                 (i_stpv_clkidentity             ),
    .i_stpv_stepsremoved                (i_stpv_stepsremoved            ),
    .i_stpv_sourceportid                (i_stpv_sourceportid            ),
    .i_stpv_portnumrecofport            (i_stpv_portnumrecofport        ),
    .i_stpv_valid                       (i_stpv_valid                   ),
    .i_ann_sequenceid                   (i_ann_sequenceid               ),

    // 输出控制bcma状�?�跳转的标志
    .i_ptp_bcm_state                    (i_ptp_bcm_state                ),
    .i_ptp_bcm_state_valid              (i_ptp_bcm_state_valid          ),
    .o_bcm_event_start                  (o_bcm_event_start              ),
    .o_bcm_event_monitor_end            (o_bcm_event_monitor_end        ),
    .o_bcm_event_forced_gm              (o_bcm_event_forced_gm          ),
    .o_bcm_event_forced_slave           (o_bcm_event_forced_slave       ),
    .o_bcm_event_rec_better_ann         (o_bcm_event_rec_better_ann     ),
    .o_bcm_event_rec_nobetter_ann       (o_bcm_event_rec_nobetter_ann   ),
    .o_bcm_event_master_timeout         (o_bcm_event_master_timeout     ),
    .o_bcm_event_master_linkdown        (o_bcm_event_master_linkdown    ),
    .o_bcm_event_lisence_master         (o_bcm_event_lisence_master     ),
    .o_bcm_event_lisence_slave          (o_bcm_event_lisence_slave      ),

    // 输出端口角色
    .o_bcm_port_role                    (w_bcm_port_role                ),
    .o_bcm_port_valid                   (w_bcm_port_valid               )
);

ptp_event_reg #(
    .REG_ADDR_BUS_WIDTH                 (REG_ADDR_BUS_WIDTH             ),
    .REG_DATA_BUS_WIDTH                 (REG_DATA_BUS_WIDTH             )
)ptp_event_reg_inst(
    .i_clk                              (i_clk                          ),
    .i_rst                              (i_rst                          ),
    // 进行参数集更�?
    .o_ptp_reg_bus_we                   (o_ptp_reg_bus_we               ),
    .o_ptp_reg_bus_we_addr              (o_ptp_reg_bus_we_addr          ),
    .o_ptp_reg_bus_we_din               (o_ptp_reg_bus_we_din           ),
    .o_ptp_reg_bus_we_din_v             (o_ptp_reg_bus_we_din_v         ),
    .o_ptp_reg_bus_rd                   (o_ptp_reg_bus_rd               ),
    .o_ptp_reg_bus_rd_addr              (o_ptp_reg_bus_rd_addr          ),
    .i_ptp_reg_bus_rd_dout              (i_ptp_reg_bus_rd_dout          ),
    .i_ptp_reg_bus_rd_dout_v            (i_ptp_reg_bus_rd_dout_v        ),
    // 内部参数信息输入，也�?要更�?
    .i_bcm_port_role                    (w_bcm_port_role                ),
    .i_bcm_port_valid                   (w_bcm_port_valid               ),
    .i_ptp_bcm_state                    (i_ptp_bcm_state                ),
    .i_ptp_bcm_state_valid              (i_ptp_bcm_state_valid          ),

    .i_slave_clockoffset                (i_slave_clockoffset            ), 
    .i_slave_clockoffset_sign           (i_slave_clockoffset_sign       ), 
    .i_slave_clockoffset_valid          (i_slave_clockoffset_valid      ), 
    .i_pdelay_time                      (i_pdelay_time                  ), 
    .i_pdelay_time_valid                (i_pdelay_time_valid            ), 
    .i_forward_time                     (i_forward_time                 ), 
    .i_forward_time_valid               (i_forward_time_valid           ), 
    .i_clock_add_gap                    (i_clock_add_gap                ), 
    .i_clock_add_gap_sign               (i_clock_add_gap_sign           ), 
    .i_clock_add_gap_valid              (i_clock_add_gap_valid          ), 
    // 报文解析出来的信�?
    .i_twostepflag                      (i_twostepflag                  ),
    .i_correctionfield                  (i_correctionfield              ),
    .i_logmessageinterval               (i_logmessageinterval           ),
    .i_stpv_priority1                   (i_stpv_priority1               ),
    .i_stpv_clkclass                    (i_stpv_clkclass                ),
    .i_stpv_clkaccuracy                 (i_stpv_clkaccuracy             ),
    .i_stpv_variance                    (i_stpv_variance                ),
    .i_stpv_priority2                   (i_stpv_priority2               ),
    .i_stpv_clkidentity                 (i_stpv_clkidentity             ),
    .i_stpv_stepsremoved                (i_stpv_stepsremoved            ),
    .i_stpv_sourceportid                (i_stpv_sourceportid            ),
    .i_stpv_portnumrecofport            (i_stpv_portnumrecofport        ),
    .i_stpv_valid                       (i_stpv_valid                   ),
    .i_port_link                        (i_port_link                    ),
    .i_ann_sequenceid                   (i_ann_sequenceid               ),

    .i_sync_origintimestamp             (i_sync_origintimestamp         ),
    .i_sync_sequenceid                  (i_sync_sequenceid              ),
    .i_sync_valid                       (i_sync_valid                   ),
    .i_follow_up_origintimestamp        (i_follow_up_origintimestamp    ),
    .i_follow_up_valid                  (i_follow_up_valid              ),
    .i_follow_up_sequenceid             (i_follow_up_sequenceid         ),
    .i_follow_up_rateratio              (i_follow_up_rateratio          ),
    .i_pdelay_req_sequenceid            (i_pdelay_req_sequenceid        ),
    .i_pdelay_req_valid                 (i_pdelay_req_valid             ),
    .i_pdelay_resprectimestamp_t1       (i_pdelay_resprectimestamp_t1   ),
    .i_pdelay_respportid                (i_pdelay_respportid            ),
    .i_pdelay_resp_sequenceid           (i_pdelay_resp_sequenceid       ),
    .i_pdelay_resp_valid                (i_pdelay_resp_valid            ),
    .i_pdelay_resporigntimestamp_t2     (i_pdelay_resporigntimestamp_t2 ),
    .i_pdelay_respfwportid              (i_pdelay_respfwportid          ),
    .i_pdelay_respfw_sequenceid         (i_pdelay_respfw_sequenceid     ),
    .i_pdelay_respfw_valid              (i_pdelay_respfw_valid          ),

    // 除了bcma外的其他子状态机跳转标志
    .o_sync_event_start                 (o_sync_event_start             ),
    .o_sync_event_send_sync_end         (o_sync_event_send_sync_end     ),
    .o_sync_event_send_followup_end     (o_sync_event_send_followup_end ),
    .o_sync_event_end                   (o_sync_event_end               ),

    .o_pdelay_event_start               (o_pdelay_event_start           ),
    .o_pdelay_event_req_send_end        (o_pdelay_event_req_send_end    ),
    .o_pdelay_event_resp_rec_end        (o_pdelay_event_resp_rec_end    ),
    .o_pdelay_event_respfw_rec_end      (o_pdelay_event_respfw_rec_end  ),
    .o_pdelay_event_end                 (o_pdelay_event_end             ),

    .o_pdelay_event_resp_start          (o_pdelay_event_resp_start      ),
    .o_pdelay_event_resp_send_end       (o_pdelay_event_resp_send_end   ),
    .o_pdelay_event_respfw_sned_end     (o_pdelay_event_respfw_sned_end ),
    .o_pdelay_event_resp_end            (o_pdelay_event_resp_end        ) 
);

ptp_event_fram #(
    .PORT_NUM                           (PORT_NUM                       ),
    .PORT_NUM_WIDTH                     (PORT_NUM_WIDTH                 )
)ptp_event_fram_inst (
    .i_clk                              (i_clk                          ),
    .i_rst                              (i_rst                          ),

    // 各个子状态机的当前状�?
    .i_bcm_state                        (i_bcm_state                    ),
    .i_portrole_state                   (i_portrole_state               ),
    .i_sync_state                       (i_sync_state                   ),
    .i_pdelay_state                     (i_pdelay_state                 ),
    .i_pdelay_resp_state                (i_pdelay_resp_state            ),

    // 发帧请求交互
    .o_announce_req                     (o_announce_req                 ),
    .o_sync_req                         (o_sync_req                     ),
    .o_follow_up_req                    (o_follow_up_req                ),
    .o_pdelayreq_req                    (o_pdelayreq_req                ),
    .o_pdelayresp_req                   (o_pdelayresp_req               ),
    .o_pdelayresp_fw_req                (o_pdelayresp_fw_req            ),

    .i_announce_ack                     (i_announce_ack                 ),
    .i_sync_ack                         (i_sync_ack                     ),
    .i_follow_up_ack                    (i_follow_up_ack                ),
    .i_pdelayreq_ack                    (i_pdelayreq_ack                ),
    .i_pdelayresp_ack                   (i_pdelayresp_ack               ),
    .i_pdelayresp_fw_ack                (i_pdelayresp_fw_ack            ),

    .o_announce_send_port               (o_announce_send_port           ),
    .o_sync_send_port                   (o_sync_send_port               ),
    .o_follow_up_send_port              (o_follow_up_send_port          ),
    .o_pdelay_req_send_port             (o_pdelay_req_send_port         ),
    .o_pdelay_resp_send_port            (o_pdelay_resp_send_port        ),
    .o_pdelay_resp_followup_send_port   (o_pdelay_resp_followup_send_port),

    // 端口角色 
    .i_bcm_port_role                    (w_bcm_port_role                ),
    .i_bcm_port_valid                   (w_bcm_port_valid               )
);

endmodule