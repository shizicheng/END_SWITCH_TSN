`include "synth_cmd_define.vh"

module  tx_qos_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8                        // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    output              wire   [3:0]                            i_qos_sch                           ,
    output              wire                                    i_qos_en                            ,

    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_ControlList_state                 ,  // 门控列表的状态
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_qos_scheduing_res                 ,
    output             wire                                     o_qos_scheduing_rst_vld                                
);


endmodule