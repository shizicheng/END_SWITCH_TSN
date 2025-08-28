module Schduling_regs #(
    parameter             PORT_FIFO_PRI_NUM       =      8    ,  // 支持端口优先级 FIFO 的数量
    parameter             REG_ADDR_BUS_WIDTH      =      8    ,
    parameter             REG_DATA_BUS_WIDTH      =      16     
)
(
    input           wire                                        i_clk                           ,
    input           wire                                        i_rst                           ,
    /*------------------- 寄存器配置接口 -----------------*/
    // 寄存器控制信号                     
    input               wire                                    i_refresh_list_pulse            , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                    i_switch_err_cnt_clr            , // 刷新错误计数器
    input               wire                                    i_switch_err_cnt_stat           , // 刷新错误状态寄存器
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
    /*------------------- IP核相关配置信息 -----------------*/
    // qav
    output              wire   [7:0]                            o_idleSlope                      ,
    output              wire   [7:0]                            o_sendslope                      ,
    output              wire                                    o_qav_en                         ,
    // qbv
    output              wire   [PORT_FIFO_PRI_NUM:0]            o_ControlList                    ,
    output              wire   [7:0]                            o_ControlList_len                ,
    output              wire   [15:0]                           o_cycle_time                     ,
    output              wire   [79:0]                           o_cycle_time_extension           ,
    output              wire                                    o_qbv_en                         ,  
    // qos 
    output              wire   [3:0]                            o_qos_sch                        ,
    output              wire                                    o_qos_en                                                   
);

endmodule