`include "synth_cmd_define.vh"

module  Scheduling_top #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8      // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                               , // 250MHz
    input               wire                                    i_rst                               ,
    /*------------------------------ 与CROSSBAR交换平面交互的调度信息 ------------------------------*/
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_fifoc_empty                       , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息 
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_scheduing_rst                     , // 该端口调度流水线产生的调度结果
    output              wire                                    o_scheduing_rst_vld                 , // 该端口调度流水线产生的调度结果有效位
    // QBU 模块返回的信号
    input               wire                                    i_pmac_tx_axis_valid                , // 用于管理每个优先级队列的信用值
    input               wire                                    i_pmac_tx_axis_last                   // 数据流 last 信号，用于使能调度流水线计算  
);

tsn_qav_mng #(
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM     )      // 支持端口优先级 FIFO 的数量
)tsn_qav_mng_inst (
    .i_clk                   ( i_clk                ) , // 250MHz
    .i_rst                   ( i_rst                ) ,
    /*------------------------------ 寄存器配置接口 ----------------------------*/
    
    /*------------------------------ 调度信息输入 ------------------------------*/
    .i_fifoc_empty           ( i_fifoc_empty        ) , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息
    .i_pmac_tx_axis_last     ( ) , // 
    .i_scheduing_rst         ( ) , // 该端口调度流水线产生的调度结果
    .i_scheduing_rst_vld     ( ) , // 该端口调度流水线产生的调度结果有效位
    .i_pmac_tx_axis_valid    ( ) , // 用于管理每个优先级队列的信用值
    /*---------------- 将信用值满足调度需求的优先级队列信息输出 ------------------*/
    .o_queque                () , // 输出满足信用值的队列结果向量
    .o_queque_vld            () 
);

tsn_qbv_mng #(
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM     )      // 支持端口优先级 FIFO 的数量
)tsn_qbv_mng_inst (
    .i_clk                   ( i_clk                ) , // 250MHz
    .i_rst                   ( i_rst                ) ,
    /*---------------------------------------- 寄存器配置接口 --------------------------------------*/

    /*---------------------------------- Qav 输入满足信用条件的队列向量结果 -------------------------*/ 
    .i_queque                () , // 输出满足信用值的队列结果向量
    .i_queque_vld            () ,
    /*---------------------------------- 输出门控状态至 QOS 调度模块 ------------------------------*/ 
    .o_ControlList_state     ()              // 门控列表的状态
);

tx_qos_mng #(
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM    )                       // 支持端口优先级 FIFO 的数量
)(
    .i_clk                   ( i_clk                ) ,   // 250MHz
    .i_rst                   ( i_rst                ) ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    
    .i_ControlList_state     ()            ,  // 门控列表的状态
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    .o_qos_scheduing_rst     () ,
    .o_qos_scheduing_rst_vld ()                 
);


endmodule