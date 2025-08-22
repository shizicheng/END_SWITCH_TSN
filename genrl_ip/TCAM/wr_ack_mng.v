`include "synth_cmd_define.vh"

module wr_ack_mng #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽 
    parameter                       CAM_MODEL               =      1        ,  // 1 - CAM 表,0 - TCAM 表
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                       CAM_NUM                 =      1024     

)(
    input               wire                                            i_clk                               ,
    input               wire                                            i_rst                               ,
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 写表 - config
    output              wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    o_config_data                       ,
    output              wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        o_config_data_cnt                   ,
    output              wire                                            o_config_data_vld                   ,
    // 改表 - change
    output              wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    o_change_data                       ,
    output              wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        o_change_data_cnt                   ,
    output              wire                                            o_change_data_vld                   ,  
    // 删除表 - delete
    output              wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    o_delete_data                       ,
    output              wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        o_delete_data_cnt                   ,
    output              wire                                            o_delete_data_vld                   ,  
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    // 寄存器控制信号                     
    input               wire                                            i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                            i_switch_err_cnt_clr                , // 刷新错误计数器
    input               wire                                            i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口             
    input               wire                                            i_switch_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]                 i_switch_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]                 i_switch_reg_bus_we_din             , // 寄存器写数据
    input               wire                                            i_switch_reg_bus_we_din_v             // 寄存器写数据使能
);


endmodule