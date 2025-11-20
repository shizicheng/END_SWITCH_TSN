// `include "synth_cmd_define.vh"

module tcam_top #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,   // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                       ACTION_WIDTH            =      24       ,   // ACTION
    parameter                       CAM_NUM                 =      64         // 表项数量
  )(
    input               wire                                    i_clk                               ,
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 匹配数据输入 ------------------------------------------*/
    input               wire    [LOOK_UP_DATA_WIDTH-1:0]        i_look_up_data                      ,
    input               wire                                    i_look_up_data_vld                  ,
    /*---------------------------------------- 匹配 ACTION 输出 --------------------------------------*/
    // output              wire    [7:0]                           o_acl_frmtype                       ,
    // output              wire    [15:0]                          o_acl_fetchinfo                     ,
    output              wire    [2:0]                           o_acl_action                        ,
    output              wire                                    o_acl_cb_frm                        ,
    output              wire    [7:0]                           o_acl_cb_streamhandle               ,
    output              wire    [2:0]                           o_acl_flow_ctrl                     ,
    output              wire    [7:0]                           o_acl_forwardport                   ,  
    output              wire                                    o_acl_vld                           ,

    // test

    output w_action_wea,
    //
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    output             wire                                     o_tcam_busy                         , // 输出给上层表明现在tcam正busy

    // 调试和状态监控接口
    // output             wire    [3:0]                            o_fsm_state                         , // CAM管理模块状态机状态
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
    output              wire                                    o_switch_reg_bus_we_dout_v            // 读数据有效使能
  );
  /*---------------------------------------- clog2计算函数 ---------------------------------------------*/
  function integer clog2;
    input integer value;
    integer temp;
    begin
      temp = value - 1;
      for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
        temp = temp >> 1;
    end
  endfunction

  // wr_ack_mng 到 cam_bram_mng 的连接信号
  wire   [(PORT_MNG_DATA_WIDTH-1):0]              w_config_data           ;
  wire   [(PORT_MNG_DATA_WIDTH-1):0]              w_config_data_mask      ;
  wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        w_config_data_cnt       ;
  wire                                            w_config_data_vld       ;

  wire   [(PORT_MNG_DATA_WIDTH-1):0]              w_change_data           ;
  wire   [(PORT_MNG_DATA_WIDTH-1):0]              w_change_data_mask      ;
  wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        w_change_data_cnt       ;
  wire                                            w_change_data_vld       ;

  wire   [(PORT_MNG_DATA_WIDTH-1):0]              w_delete_data           ;
  wire   [(PORT_MNG_DATA_WIDTH-1):0]              w_delete_data_mask      ;
  wire   [clog2(LOOK_UP_DATA_WIDTH/8)-1:0]        w_delete_data_cnt       ;
  wire                                            w_delete_data_vld       ;

  // cam_bram_mng 输出信号
  wire   [clog2(CAM_NUM)-1:0]                     w_acl_addr              ;
  wire                                            w_acl_addr_vld          ;
  wire   [clog2(CAM_NUM)-1:0]                     w_action_addra          ;
  wire   [ACTION_WIDTH-1:0]                       w_action_din            ;
  // wire                                            w_action_wea            ;
  wire                                            w_cam_busy              ;
  wire   [3:0]                                    w_fsm_state             ;  // CAM管理模块状态机状态
  wire   [ACTION_WIDTH-1:0]                       w_action_out            ;

  assign o_acl_action = w_action_out[2:0] ;
  assign o_acl_cb_frm = w_action_out[3]   ;
  assign o_acl_cb_streamhandle = w_action_out[11:4]   ; 
  assign o_acl_flow_ctrl = w_action_out[14:12]   ;
  assign o_acl_forwardport = w_action_out[22:15]   ; 
  wr_ack_mng #(
               .LOOK_UP_DATA_WIDTH             ( LOOK_UP_DATA_WIDTH    ),   // 需要查询的数据总位宽
               .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH   ),   // Mac_port_mng 数据位宽
               .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH    ),   // 接收 MAC 层的配置寄存器地址位宽
               .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH    ),   // 接收 MAC 层的配置寄存器数据位宽
               .CAM_NUM                        ( CAM_NUM               ),
               .CMD_WIDTH                      ( 2                     )    // 命令位宽（写表/改表/删除表）

             )wr_ack_mng_inst (
               .i_clk                          ( i_clk                 ),
               .i_rst                          ( i_rst                 ),
               /*----------------------- 下级模块接口 -----------------------------------------------*/
               .i_cam_busy                     ( w_cam_busy            ), // 下级模块忙信号
               /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
               // 写表 - config
               .o_config_data                  ( w_config_data         ),
               .o_config_mask                  ( w_config_data_mask    ),
               .o_config_data_cnt              ( w_config_data_cnt     ),
               .o_config_data_vld              ( w_config_data_vld     ),
               // 改表 - change
               .o_change_data                  ( w_change_data         ),
               .o_change_mask                  ( w_change_data_mask    ),
               .o_change_data_cnt              ( w_change_data_cnt     ),
               .o_change_data_vld              ( w_change_data_vld     ),
               // 删除表 - delete
               .o_delete_data                  ( w_delete_data         ),
               .o_delete_mask                  ( w_delete_data_mask    ),
               .o_delete_data_cnt              ( w_delete_data_cnt     ),
               .o_delete_data_vld              ( w_delete_data_vld     ),
               // 状态输出
               .o_wr_ack_busy                  ( o_tcam_busy           ), // 当前模块忙信号
               /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
               // 寄存器控制信号
               .i_refresh_list_pulse           ( i_refresh_list_pulse  ), // 刷新寄存器列表（状态寄存器和控制寄存器）
               .i_switch_err_cnt_clr           ( i_switch_err_cnt_clr  ), // 刷新错误计数器
               .i_switch_err_cnt_stat          ( i_switch_err_cnt_stat ), // 刷新错误状态寄存器
               // 寄存器写控制接口
               .i_switch_reg_bus_we            ( i_switch_reg_bus_we      ), // 寄存器写使能
               .i_switch_reg_bus_we_addr       ( i_switch_reg_bus_we_addr ), // 寄存器写地址
               .i_switch_reg_bus_we_din        ( i_switch_reg_bus_we_din  ), // 寄存器写数据
               .i_switch_reg_bus_we_din_v      ( i_switch_reg_bus_we_din_v) // 寄存器写数据使能
               // // 寄存器读控制接口
               // .i_switch_reg_bus_rd            ( i_switch_reg_bus_rd      ), // 寄存器读使能
               // .i_switch_reg_bus_rd_addr       ( i_switch_reg_bus_rd_addr ), // 寄存器读地址
               // .o_switch_reg_bus_we_dout       ( o_switch_reg_bus_we_dout ), // 读出寄存器数据
               // .o_switch_reg_bus_we_dout_v     ( o_switch_reg_bus_we_dout_v)  // 读数据有效使能
             );

  cam_bram_mng #(
                 .LOOK_UP_DATA_WIDTH             ( LOOK_UP_DATA_WIDTH    ),   // 需要查询的数据总位宽
                 .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH   ),   // Mac_port_mng 数据位宽
                 .ACTION_WIDTH                   ( ACTION_WIDTH          ),
                 .CAM_NUM                        ( CAM_NUM               )   // CAM表项数量
               )cam_bram_mng_inst (
                 .i_clk                          ( i_clk                 ),
                 .i_rst                          ( i_rst                 ),
                 /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
                 // 查表 - look_up
                 .i_look_up_data                 ( i_look_up_data        ),
                 .i_look_up_data_vld             ( i_look_up_data_vld    ),
                 .o_acl_addr                     ( w_acl_addr            ),
                 .o_acl_addr_vld                 ( w_acl_addr_vld        ),
                 // 写表 - config
                 .i_config_data                  ( w_config_data         ),
                 .i_config_data_mask             ( w_config_data_mask    ),
                 .i_config_data_cnt              ( w_config_data_cnt     ),
                 .i_config_data_vld              ( w_config_data_vld     ),

                 // 改表 - change
                 .i_change_data                  ( w_change_data         ),
                 .i_change_data_mask             ( w_change_data_mask    ),
                 .i_change_data_cnt              ( w_change_data_cnt     ),
                 .i_change_data_vld              ( w_change_data_vld     ),

                 // 删除表 - delete
                 .i_delete_data                  ( w_delete_data         ),
                 .i_delete_data_mask             ( w_delete_data_mask    ),
                 .i_delete_data_cnt              ( w_delete_data_cnt     ),
                 .i_delete_data_vld              ( w_delete_data_vld     ),

                 // 将写，改，删除的动作同步写到 action 表
                 .o_action_addra                 ( w_action_addra        ),
                 .o_action_din                   ( w_action_din          ),   //[23:8] - acl_fetchinfo, [7:0] - acl_frmtype
                 .o_action_wea                   ( w_action_wea          ),

                 // 反压控制信号
                 .o_busy                         ( w_cam_busy            )  // 模块忙信号，高电平表示正在处理数据

                 // 状态机状态输出
                //  .o_fsm_state                    ( w_fsm_state           )   // 当前状态机状态
               );

  ram_simple2port #(
                    .RAM_WIDTH          ( ACTION_WIDTH          ),
                    .RAM_DEPTH          ( CAM_NUM               ),
                    .RAM_PERFORMANCE    ( "LOW_LATENCY"         ),
                    .INIT_FILE          ()
                  )action_bram (
                    .addra              ( w_action_addra    ),
                    .addrb              ( w_acl_addr        ),
                    .dina               ( w_action_din      ),
                    .clka               ( i_clk             ),
                    .clkb               ( i_clk             ),
                    .wea                ( w_action_wea      ),
                    .enb                ( w_acl_addr_vld    ), // cam_mng输出的查表信息有效
                    .rstb               ( i_rst             ),
                    .regceb             ( 1'b1              ),
                    .doutb              ( w_action_out      )
                  );
 

  // 输出有效信号延迟一个时钟周期以匹配BRAM读出延迟
  reg r_acl_vld;
  always @(posedge i_clk)
  begin
    if (i_rst)
    begin
      r_acl_vld <= 1'b0;
    end
    else
    begin
      r_acl_vld <= w_acl_addr_vld;
    end
  end

  assign o_acl_vld = r_acl_vld;
  // assign o_fsm_state = w_fsm_state;

endmodule
