`include "synth_cmd_define.vh"

module  tx_qos_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8                        // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    
    /*------------------------------------ 输入调度信息 --------------------------------*/ 
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_tx_mac_forward_info               ,  // 调度相关帧信息 0:7 - 8个优先级 FIFO 的空信号    
    input              wire                                     i_tx_mac_forward_info_vld           ,
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_ControlList_state                 ,  // 门控列表的状态
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_fifo_pri_rd_en                    
);


endmodule