/*---------------------------------------- 定义平台的架构 -------------------------------------------*/
`define END_POINTER_SWITCH_CORE
//`define END_POINTER
//`define SWITCH_CORE
/*---------------------------------------- 定义CPU与FPGA交互的接口 -----------------------------------*/
`ifdef END_POINTER_SWITCH_CORE
    `define CPU_MAC
    `define MAC1
    `define MAC2
    `define MAC3
    `define MAC4
    `define MAC5
    `define MAC6
    `define MAC7
    `define LLDP
    `define TSN_AS
`elsif END_POINTER
    `define CPU_MAC
    `define MAC1
    `define MAC2
    `define LLDP
    `define TSN_AS
`endif
/*---------------------------------------- 定义平台有多少个 Mac_port_mng ----------------------------*/

