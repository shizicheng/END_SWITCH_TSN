`include "synth_cmd_define.vh"

module tcam_top #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽 
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                       CAM_MODEL               =      1        ,  // 1 - CAM 表,0 - TCAM 表
    parameter                       CAM_NUM                 =      1024     
)(
    input               wire                                    i_clk                               ,
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 匹配数据输入 ------------------------------------------*/
    input               wire    [PORT_MNG_DATA_WIDTH-1:0]       i_look_up_data                      ,
    input               wire                                    i_look_up_data_vld                  ,
    input               wire    [clog2(LOOK_UP_DATA_WIDTH/8-1)] i_look_up_data_cnt                  ,
    /*---------------------------------------- 匹配 ACTION 输出 --------------------------------------*/
    output              wire    [7:0]                           o_acl_frmtype                       ,
    output              wire    [15:0]                          o_acl_fetchinfo                     ,
    output              wire                                    o_acl_vld                           ,
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    // 寄存器控制信号                     
    input               wire                                    i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                    i_switch_err_cnt_clr                , // 刷新错误计数器
    input               wire                                    i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    input               wire                                    i_switch_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din             , // 寄存器写数据
    input               wire                                    i_switch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口     
    input               wire                                    i_switch_reg_bus_rd                 , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr            , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_we_dout            , // 读出寄存器数据
    output              wire                                    o_switch_reg_bus_we_dout_v           // 读数据有效使能
);

wr_ack_mng #(
    .LOOK_UP_DATA_WIDTH             ( LOOK_UP_DATA_WIDTH    ),   // 需要查询的数据总位宽
    .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH   ),   // Mac_port_mng 数据位宽 
    .CAM_MODEL                      ( CAM_MODEL             ),  // 1 - CAM 表,0 - TCAM 表
    .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH    ),  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH    ),  // 接收 MAC 层的配置寄存器数据位宽
    .CAM_NUM                        ( CAM_NUM               )

)wr_ack_mng_inst (
    .i_clk                          ( )    ,
    .i_rst                          ( )    ,
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 写表 - config
    .o_config_data                  ( )     ,
    .o_config_data_cnt              ( )     ,
    .o_config_data_vld              ( )     ,
    // 改表 - change
    .o_change_data                  ( )     ,
    .o_change_data_cnt              ( )     ,
    .o_change_data_vld              ( )     ,  
    // 删除表 - delete
    .o_delete_data                  ( )     ,
    .o_delete_data_cnt              ( )     ,
    .o_delete_data_vld              ( )     ,  
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse           ( )     , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr           ( )     , // 刷新错误计数器
    .i_switch_err_cnt_stat          ( )     , // 刷新错误状态寄存器
    // 寄存器写控制接口              
    .i_switch_reg_bus_we            ( )    , // 寄存器写使能
    .i_switch_reg_bus_we_addr       ( )    , // 寄存器写地址
    .i_switch_reg_bus_we_din        ( )    , // 寄存器写数据
    .i_switch_reg_bus_we_din_v      ( )      // 寄存器写数据使能
);

cam_bram_mng #(
    .LOOK_UP_DATA_WIDTH             ( )     ,   // 需要查询的数据总位宽
    .PORT_MNG_DATA_WIDTH            ( )     ,   // Mac_port_mng 数据位宽 
    .CAM_MODEL                      ( )     ,  // 1 - CAM 表,0 - TCAM 表
    .CAM_NUM                        ( )     

)(
    .i_clk                          ( )     ,
    .i_rst                          ( )     ,                                
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 查表 - look_up
    .i_look_up_data                 ( )     ,
    .i_look_up_data_vld             ( )     ,
    .i_look_up_data_cnt             ( )     ,
    .o_acl_addr                     ( )     ,
    // 写表 - config
    .i_config_data                  ( )     ,
    .i_config_data_cnt              ( )     ,
    .i_config_data_vld              ( )     ,
    // 改表 - change
    .i_change_data                  ( )     ,
    .i_change_data_cnt              ( )     ,
    .i_change_data_vld              ( )     ,  
    // 删除表 - delete
    .i_delete_data                  ( )     ,
    .i_delete_data_cnt              ( )     ,
    .i_delete_data_vld              ( )     ,
    // 将写，改，删除的动作同步写到 action 表
    .o_action_addra                 ( )     ,
    .o_action_din                   ( )  
);

ram_simple2port #(
        .RAM_WIDTH          ( CAM_NUM               ),                  // Specify RAM data width
        .RAM_DEPTH          ( PORT_MNG_DATA_WIDTH/2 ),                  // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE    ("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE          ()                  // Specify name/location of RAM initialization file if using one (leave blank if not)
)action_bram (
        .addra              ( ),    // Write address bus, width determined from RAM_DEPTH
        .addrb              ( ),    // Read address bus, width determined from RAM_DEPTH
        .dina               ( ),    // RAM input data
        .clka               ( i_clk ),    // Write clock
        .clkb               ( i_clk ),    // Read clock
        .wea                ( ),    // Write enable
        .enb                ( ),    // Read Enable, for additional power savings, disable when not in use
        .rstb               ( ),    // Output reset (does not affect memory contents)
        .regceb             ( ),    // Output register enable
        .doutb              ( )     // RAM output data
);


endmodule