// 门控调度

`include "synth_cmd_define.vh"

module  tsn_qbv_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8                        // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/

    /*---------------------------------- 输出门控状态至 QOS 调度模块 ------------------------------*/ 
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_ControlList_state                   // 门控列表的状态
);


endmodule