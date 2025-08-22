`include "synth_cmd_define.vh"

module cam_bram_mng #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽 
    parameter                       CAM_MODEL               =      1        ,  // 1 - CAM 表,0 - TCAM 表
    parameter                       CAM_NUM                 =      1024     

)(
    input               wire                                            i_clk                               ,
    input               wire                                            i_rst                               ,                                
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 查表 - look_up
    input               wire    [PORT_MNG_DATA_WIDTH-1:0]               i_look_up_data                      ,
    input               wire                                            i_look_up_data_vld                  ,
    input               wire    [clog2(LOOK_UP_DATA_WIDTH/8-1)]         i_look_up_data_cnt                  ,
    output              wire    [CAM_NUM-1:0]                           o_acl_addr                          , 
    // 写表 - config
    input               wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    i_config_data                       ,
    input               wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        i_config_data_cnt                   ,
    input               wire                                            i_config_data_vld                   ,
    // 改表 - change
    input               wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    i_change_data                       ,
    input               wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        i_change_data_cnt                   ,
    input               wire                                            i_change_data_vld                   ,  
    // 删除表 - delete
    input               wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    i_delete_data                       ,
    input               wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        i_delete_data_cnt                   ,
    input               wire                                            i_delete_data_vld                   ,
    // 将写，改，删除的动作同步写到 action 表
    output              wire   [clog2(CAM_NUM)-1:0]                     o_action_addra                      ,
    output              wire   [23:0]                                   o_action_din                        , //[23:8] - acl_fetchinfo, [7:0] - acl_frmtype   
);

// 循环例化 LOOK_UP_DATA_WIDTH/(PORT_MNG_DATA_WIDTH/2) 个
ram_simple2port #(
        .RAM_WIDTH          ( CAM_NUM               ),                  // Specify RAM data width
        .RAM_DEPTH          ( PORT_MNG_DATA_WIDTH/2 ),                  // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE    ("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE          ()                  // Specify name/location of RAM initialization file if using one (leave blank if not)
)cam_bram (
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