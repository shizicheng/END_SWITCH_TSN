`include "synth_cmd_define.vh"

module  Scheduling_top #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8    ,  // 支持端口优先级 FIFO 的数量
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8    ,
    parameter                                                   REG_DATA_BUS_WIDTH      =      16     
)(
    input               wire                                    i_clk                               , // 250MHz
    input               wire                                    i_rst                               ,
    /*----------- 寄存器配置接口 ------------*/
    // 寄存器控制信号                     
    input               wire                                    i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                    i_switch_err_cnt_clr                , // 刷新错误计数器
    input               wire                                    i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    input               wire                                    i_Sch_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_Sch_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_Sch_reg_bus_we_din             , // 寄存器写数据
    input               wire                                    i_Sch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口     
    input               wire                                    i_Sch_reg_bus_rd                 , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_Sch_reg_bus_rd_addr            , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_Sch_reg_bus_we_dout            , // 读出寄存器数据
    output              wire                                    o_Sch_reg_bus_we_dout_v          , // 读数据有效使能
    /*------------------------------ 与CROSSBAR交换平面交互的调度信息 ------------------------------*/
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_fifoc_empty                       , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息 
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_scheduing_rst                     , // 该端口调度流水线产生的调度结果
    output              wire                                    o_scheduing_rst_vld                 , // 该端口调度流水线产生的调度结果有效位
    // QBU 模块返回的信号
    input               wire                                    i_pmac_tx_axis_valid                , // 用于管理每个优先级队列的信用值
    input               wire                                    i_pmac_tx_axis_last                   // 数据流 last 信号，用于使能调度流水线计算  
);

/*------------ wire -----------*/
wire   [PORT_FIFO_PRI_NUM:0]            w_queque                ;
wire                                    w_queque_vld            ;

wire   [PORT_FIFO_PRI_NUM-1:0]          w_ControlList_state     ;

wire   [PORT_FIFO_PRI_NUM-1:0]          w_qos_scheduing_res     ;
wire                                    w_qos_scheduing_rst_vld ;

wire   [7:0]                            w_idleSlope              ;
wire   [7:0]                            w_sendslope              ;
wire                                    w_qav_en                 ;
wire   [PORT_FIFO_PRI_NUM:0]            w_ControlList            ;
wire   [7:0]                            w_ControlList_len        ;
wire   [15:0]                           w_cycle_time             ;
wire   [79:0]                           w_cycle_time_extension   ;
wire                                    w_qbv_en                 ;  
wire   [3:0]                            w_qos_sch                ;
wire                                    w_qos_en                 ;                         



tsn_qav_mng #(
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM     )      // 支持端口优先级 FIFO 的数量
)tsn_qav_mng_inst (
    .i_clk                   ( i_clk                ) , // 250MHz
    .i_rst                   ( i_rst                ) ,
    /*------------------------------ 寄存器配置接口 ----------------------------*/
    .i_idleSlope             ( w_idleSlope          ) ,
    .i_sendslope             ( w_sendslope          ) ,
    .i_qav_en                ( w_qav_en             ) ,
    /*------------------------------ 调度信息输入 ------------------------------*/
    .i_fifoc_empty           ( i_fifoc_empty        ) , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息
    .i_pmac_tx_axis_last     ( i_pmac_tx_axis_last  ) , // 
    .i_scheduing_rst         ( ) , // 该端口调度流水线产生的调度结果
    .i_scheduing_rst_vld     ( ) , // 该端口调度流水线产生的调度结果有效位
    .i_pmac_tx_axis_valid    ( i_pmac_tx_axis_valid ) , // 用于管理每个优先级队列的信用值
    /*---------------- 将信用值满足调度需求的优先级队列信息输出 ------------------*/
    .o_queque                ( w_queque             ) , // 输出满足信用值的队列结果向量
    .o_queque_vld            ( w_queque_vld         ) 
);

tsn_qbv_mng #(
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM     )      // 支持端口优先级 FIFO 的数量
)tsn_qbv_mng_inst (
    .i_clk                   ( i_clk                ) , // 250MHz
    .i_rst                   ( i_rst                ) ,
    /*---------------------------------------- 寄存器配置接口 --------------------------------------*/
    .i_ControlList           ( w_ControlList          ),
    .i_ControlList_len       ( w_ControlList_len      ),
    .i_cycle_time            ( w_cycle_time           ),
    .i_cycle_time_extension  ( w_cycle_time_extension ),
    .i_qbv_en                ( w_qbv_en               ),
    /*---------------------------------- Qav 输入满足信用条件的队列向量结果 -------------------------*/ 
    .i_queque                ( w_queque             ) , // 输出满足信用值的队列结果向量
    .i_queque_vld            ( w_queque_vld         ) ,
    /*---------------------------------- 输出门控状态至 QOS 调度模块 ------------------------------*/ 
    .o_ControlList_state     ( w_ControlList_state  )              // 门控列表的状态
);

tx_qos_mng #(
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM       )                       // 支持端口优先级 FIFO 的数量
)(   
    .i_clk                   ( i_clk                   ) ,   // 250MHz
    .i_rst                   ( i_rst                   ) ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    .i_qos_sch               ( w_qos_sch               ) ,
    .i_qos_en                ( w_qos_en                ) ,
    .i_ControlList_state     ( w_ControlList_state     ) ,  // 门控列表的状态
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    .o_qos_scheduing_res     ( w_qos_scheduing_res     ) ,
    .o_qos_scheduing_rst_vld ( w_qos_scheduing_rst_vld )                 
);

Schduling_regs #(
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM  )  ,  // 支持端口优先级 FIFO 的数量
    .REG_ADDR_BUS_WIDTH      ( REG_ADDR_BUS_WIDTH )  ,
    .REG_DATA_BUS_WIDTH      ( REG_DATA_BUS_WIDTH )    
)
(
    .i_clk                   ( i_clk )        ,
    .i_rst                   ( i_rst )        ,
    /*------------------- 寄存器配置接口 -----------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse    ( i_refresh_list_pulse   )        , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr    ( i_switch_err_cnt_clr   )        , // 刷新错误计数器
    .i_switch_err_cnt_stat   ( i_switch_err_cnt_stat  )        , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_Sch_reg_bus_we        ( i_Sch_reg_bus_we        )        , // 寄存器写使能
    .i_Sch_reg_bus_we_addr   ( i_Sch_reg_bus_we_addr   )        , // 寄存器写地址
    .i_Sch_reg_bus_we_din    ( i_Sch_reg_bus_we_din    )        , // 寄存器写数据
    .i_Sch_reg_bus_we_din_v  ( i_Sch_reg_bus_we_din_v  )        , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_Sch_reg_bus_rd        ( i_Sch_reg_bus_rd        )         , // 寄存器读使能
    .i_Sch_reg_bus_rd_addr   ( i_Sch_reg_bus_rd_addr   )         , // 寄存器读地址
    .o_Sch_reg_bus_we_dout   ( o_Sch_reg_bus_we_dout   )         , // 读出寄存器数据
    .o_Sch_reg_bus_we_dout_v ( o_Sch_reg_bus_we_dout_v )         , // 读数据有效使能
    /*------------------- IP核相关配置信息 -----------------*/
    // qav
    .o_idleSlope             ( w_idleSlope            )         ,
    .o_sendslope             ( w_sendslope            )         ,
    .o_qav_en                ( w_qav_en               )         ,
    // qbv
    .o_ControlList           ( w_ControlList          )         ,
    .o_ControlList_len       ( w_ControlList_len      )         ,
    .o_cycle_time            ( w_cycle_time           )         ,
    .o_cycle_time_extension  ( w_cycle_time_extension )         ,
    .o_qbv_en                ( w_qbv_en               )         ,  
    // qos 
    .o_qos_sch               ( w_qos_sch              )         ,
    .o_qos_en                ( w_qos_en               )                                  
);

endmodule