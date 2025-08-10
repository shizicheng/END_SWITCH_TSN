`include "synth_cmd_define.vh"

module  tsn_qav_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8      // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                   , // 250MHz
    input               wire                                    i_rst                   ,
    /*------------------------------ 寄存器配置接口 ----------------------------*/

    /*------------------------------ 调度信息输入 ------------------------------*/
    input               wire   [PORT_FIFO_PRI_NUM:0]            i_fifoc_empty           , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息
    input               wire                                    i_pmac_tx_axis_last     ,
    input               wire   [PORT_FIFO_PRI_NUM:0]            i_scheduing_rst         , // 该端口调度流水线产生的调度结果
    input               wire                                    i_scheduing_rst_vld     , // 该端口调度流水线产生的调度结果有效位
    input               wire                                    i_pmac_tx_axis_valid    , // 用于管理每个优先级队列的信用值
    /*---------------- 将信用值满足调度需求的优先级队列信息输出 ------------------*/
    output              wire   [PORT_FIFO_PRI_NUM:0]            o_queque                , // 输出满足信用值的队列结果向量
    output              wire                                    o_queque_vld            
);



endmodule