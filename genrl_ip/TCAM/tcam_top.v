// `include "synth_cmd_define.vh"

module tcam_top #(
    parameter                       LOOK_UP_DATA_WIDTH      =      16       ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,   // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                       ACTION_WIDTH            =      24       ,   // ACTION
    parameter                       PORT_ID                 =      0        ,   // 端口号
    parameter                       CAM_NUM                 =      512             // 表项数量
  )(
    input               wire                                    i_clk                               ,
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 匹配数据输入 ------------------------------------------*/
    input               wire    [LOOK_UP_DATA_WIDTH-1:0]        i_look_up_data                      ,
    input               wire                                    i_look_up_data_vld                  ,
    /*---------------------------------------- 匹配 ACTION 输出 --------------------------------------*/
    output              wire    [2:0]                           o_acl_action                        ,
    output              wire                                    o_acl_cb_frm                        ,
    output              wire    [7:0]                           o_acl_cb_streamhandle               ,
    output              wire    [2:0]                           o_acl_flow_ctrl                     ,
    output              wire    [7:0]                           o_acl_forwardport                   ,  
    output              wire                                    o_acl_vld                           , 
    output              wire                                    o_acl_no                            ,

    // test

    output w_action_wea,
    //
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    output             wire                   o_tcam_busy                           , // 输出给上层表明现在tcam正busy

    // 端口选择配置
    input    wire [5:0]                       i_cfg_acl_port_sel                    , // 端口ACL参数-配置端口选择
    input    wire                             i_cfg_acl_port_sel_valid              , // 写入有效信号 

    // ACL列表清除控制
    input    wire                             i_cfg_acl_clr_list_regs               , // 端口ACL参数-条目全部清除使能
    // input    wire                             i_cfg_acl_clr_list_regs_valid         , // 写入有效信号 

    // ACL配置状态指示
    output   wire                             o_cfg_acl_list_rdy_regs               , // 端口ACL参数-写入就绪指示：任一FIFO为空时为1 
    output   wire                             o_cfg_acl_clr_busy_regs               , // 端口ACL参数-清除忙指示：正在清除时为1
    // // 条目选择配置
    // input    wire [4:0]                       i_cfg_acl_item_sel_regs               , // 端口ACL参数-配置条目选择
    // input    wire                             i_cfg_acl_item_sel_regs_valid         , // 写入有效信号
    // output   wire [4:0]                       o_cfg_acl_item_sel_regs               , // 读取条目选择配置
    // output   wire                             o_cfg_acl_item_sel_regs_valid         , // 读取有效信号

    // DMAC编码值配置（6个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_dmac_code_1            , // 端口ACL表项-写入dmac值[15:0]
    input    wire                             i_cfg_acl_item_dmac_code_1_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_2            , // 端口ACL表项-写入dmac值[31:16]
    input    wire                             i_cfg_acl_item_dmac_code_2_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_3            , // 端口ACL表项-写入dmac值[47:32]
    input    wire                             i_cfg_acl_item_dmac_code_3_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_4            , // 端口ACL表项-写入dmac值[63:48]
    input    wire                             i_cfg_acl_item_dmac_code_4_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_5            , // 端口ACL表项-写入dmac值[79:64]
    input    wire                             i_cfg_acl_item_dmac_code_5_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_6            , // 端口ACL表项-写入dmac值[95:80]
    input    wire                             i_cfg_acl_item_dmac_code_6_valid      , // 写入有效信号

    // SMAC编码值配置（6个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_smac_code_1            , // 端口ACL表项-写入smac值[15:0]
    input    wire                             i_cfg_acl_item_smac_code_1_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_2            , // 端口ACL表项-写入smac值[31:16]
    input    wire                             i_cfg_acl_item_smac_code_2_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_3            , // 端口ACL表项-写入smac值[47:32]
    input    wire                             i_cfg_acl_item_smac_code_3_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_4            , // 端口ACL表项-写入smac值[63:48]
    input    wire                             i_cfg_acl_item_smac_code_4_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_5            , // 端口ACL表项-写入smac值[79:64]
    input    wire                             i_cfg_acl_item_smac_code_5_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_6            , // 端口ACL表项-写入smac值[95:80]
    input    wire                             i_cfg_acl_item_smac_code_6_valid      , // 写入有效信号

    // VLAN编码值配置（4个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_vlan_code_1            , // 端口ACL表项-写入vlan值[15:0]
    input    wire                             i_cfg_acl_item_vlan_code_1_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_vlan_code_2            , // 端口ACL表项-写入vlan值[31:16]
    input    wire                             i_cfg_acl_item_vlan_code_2_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_vlan_code_3            , // 端口ACL表项-写入vlan值[47:32]
    input    wire                             i_cfg_acl_item_vlan_code_3_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_vlan_code_4            , // 端口ACL表项-写入vlan值[63:48]
    input    wire                             i_cfg_acl_item_vlan_code_4_valid      , // 写入有效信号

    // Ethertype编码值配置（2个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_ethertype_code_1       , // 端口ACL表项-写入ethertype值[15:0]
    input    wire                             i_cfg_acl_item_ethertype_code_1_valid , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_ethertype_code_2       , // 端口ACL表项-写入ethertype值[31:16]
    input    wire                             i_cfg_acl_item_ethertype_code_2_valid , // 写入有效信号

    // ACL动作配置
    input    wire [7:0]                       i_cfg_acl_item_action_pass_state      , // 端口ACL动作-报文状态
    input    wire                             i_cfg_acl_item_action_pass_state_valid, // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_action_cb_streamhandle , // 端口ACL动作-stream_handle值
    input    wire                             i_cfg_acl_item_action_cb_streamhandle_valid, // 写入有效信号

    input    wire [5:0]                       i_cfg_acl_item_action_flowctrl        , // 端口ACL动作-报文流控选择
    input    wire                             i_cfg_acl_item_action_flowctrl_valid  , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_action_txport          , // 端口ACL动作-报文发送端口映射
    input    wire                             i_cfg_acl_item_action_txport_valid      // 写入有效信号
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
  // wire   [3:0]                                    w_fsm_state             ;  // CAM管理模块状态机状态
  wire   [ACTION_WIDTH-1:0]                       w_action_out            ;
  wire                                            w_acl_no                ;

  //assign o_acl_action          = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[2:0]   : 3'd0    ;
  //assign o_acl_cb_frm          = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[3]     : 1'd0    ;
  //assign o_acl_cb_streamhandle = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[11:4]  : 8'd0    ; 
  //assign o_acl_flow_ctrl       = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[14:12] : 3'd0    ;
  //assign o_acl_forwardport     = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[22:15] : 8'd0    ;
 assign o_acl_cb_frm          = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[23]     	: 1'd0    ;  
 assign o_acl_action          = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[22:20]   	: 3'd0    ;
 assign o_acl_cb_streamhandle = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[19:12]  	: 8'd0    ; 
 assign o_acl_flow_ctrl       = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[11:9] 	: 3'd0    ;
 assign o_acl_forwardport     = o_acl_vld == 1'd1 && o_acl_no == 1'd0  ? w_action_out[8:1] 		: 8'd0    ; 
     

  wr_ack_mng #(
               .LOOK_UP_DATA_WIDTH             ( LOOK_UP_DATA_WIDTH    ),   // 需要查询的数据总位宽
               .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH   ),   // Mac_port_mng 数据位宽
               .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH    ),   // 接收 MAC 层的配置寄存器地址位宽
               .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH    ),   // 接收 MAC 层的配置寄存器数据位宽
               .CAM_NUM                        ( CAM_NUM               ),
               .PORT_ID                        (PORT_ID                ),   // 端口号 
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
               .i_cfg_acl_port_sel                         (i_cfg_acl_port_sel                          ),
               .i_cfg_acl_port_sel_valid                   (i_cfg_acl_port_sel_valid                    ), 
              //  .i_cfg_acl_clr_list_regs_valid              (i_cfg_acl_clr_list_regs_valid               ),
               .o_cfg_acl_list_rdy_regs                    (o_cfg_acl_list_rdy_regs                     ),
              //  .o_cfg_acl_list_rdy_regs_valid              (o_cfg_acl_list_rdy_regs_valid               ), 
               .i_cfg_acl_item_dmac_code_1                 (i_cfg_acl_item_dmac_code_1                  ),
               .i_cfg_acl_item_dmac_code_1_valid           (i_cfg_acl_item_dmac_code_1_valid            ),
               .i_cfg_acl_item_dmac_code_2                 (i_cfg_acl_item_dmac_code_2                  ),
               .i_cfg_acl_item_dmac_code_2_valid           (i_cfg_acl_item_dmac_code_2_valid            ),
               .i_cfg_acl_item_dmac_code_3                 (i_cfg_acl_item_dmac_code_3                  ),
               .i_cfg_acl_item_dmac_code_3_valid           (i_cfg_acl_item_dmac_code_3_valid            ),
               .i_cfg_acl_item_dmac_code_4                 (i_cfg_acl_item_dmac_code_4                  ),
               .i_cfg_acl_item_dmac_code_4_valid           (i_cfg_acl_item_dmac_code_4_valid            ),
               .i_cfg_acl_item_dmac_code_5                 (i_cfg_acl_item_dmac_code_5                  ),
               .i_cfg_acl_item_dmac_code_5_valid           (i_cfg_acl_item_dmac_code_5_valid            ),
               .i_cfg_acl_item_dmac_code_6                 (i_cfg_acl_item_dmac_code_6                  ),
               .i_cfg_acl_item_dmac_code_6_valid           (i_cfg_acl_item_dmac_code_6_valid            ),
               .i_cfg_acl_item_smac_code_1                 (i_cfg_acl_item_smac_code_1                  ),
               .i_cfg_acl_item_smac_code_1_valid           (i_cfg_acl_item_smac_code_1_valid            ),
               .i_cfg_acl_item_smac_code_2                 (i_cfg_acl_item_smac_code_2                  ),
               .i_cfg_acl_item_smac_code_2_valid           (i_cfg_acl_item_smac_code_2_valid            ),
               .i_cfg_acl_item_smac_code_3                 (i_cfg_acl_item_smac_code_3                  ),
               .i_cfg_acl_item_smac_code_3_valid           (i_cfg_acl_item_smac_code_3_valid            ),
               .i_cfg_acl_item_smac_code_4                 (i_cfg_acl_item_smac_code_4                  ),
               .i_cfg_acl_item_smac_code_4_valid           (i_cfg_acl_item_smac_code_4_valid            ),
               .i_cfg_acl_item_smac_code_5                 (i_cfg_acl_item_smac_code_5                  ),
               .i_cfg_acl_item_smac_code_5_valid           (i_cfg_acl_item_smac_code_5_valid            ),
               .i_cfg_acl_item_smac_code_6                 (i_cfg_acl_item_smac_code_6                  ),
               .i_cfg_acl_item_smac_code_6_valid           (i_cfg_acl_item_smac_code_6_valid            ),
               .i_cfg_acl_item_vlan_code_1                 (i_cfg_acl_item_vlan_code_1                  ),
               .i_cfg_acl_item_vlan_code_1_valid           (i_cfg_acl_item_vlan_code_1_valid            ),
               .i_cfg_acl_item_vlan_code_2                 (i_cfg_acl_item_vlan_code_2                  ),
               .i_cfg_acl_item_vlan_code_2_valid           (i_cfg_acl_item_vlan_code_2_valid            ),
               .i_cfg_acl_item_vlan_code_3                 (i_cfg_acl_item_vlan_code_3                  ),
               .i_cfg_acl_item_vlan_code_3_valid           (i_cfg_acl_item_vlan_code_3_valid            ),
               .i_cfg_acl_item_vlan_code_4                 (i_cfg_acl_item_vlan_code_4                  ),
               .i_cfg_acl_item_vlan_code_4_valid           (i_cfg_acl_item_vlan_code_4_valid            ),
               .i_cfg_acl_item_ethertype_code_1            (i_cfg_acl_item_ethertype_code_1             ),
               .i_cfg_acl_item_ethertype_code_1_valid      (i_cfg_acl_item_ethertype_code_1_valid       ),
               .i_cfg_acl_item_ethertype_code_2            (i_cfg_acl_item_ethertype_code_2             ),
               .i_cfg_acl_item_ethertype_code_2_valid      (i_cfg_acl_item_ethertype_code_2_valid       ),
               .i_cfg_acl_item_action_pass_state           (i_cfg_acl_item_action_pass_state            ),
               .i_cfg_acl_item_action_pass_state_valid     (i_cfg_acl_item_action_pass_state_valid      ),
               .i_cfg_acl_item_action_cb_streamhandle      (i_cfg_acl_item_action_cb_streamhandle       ),
               .i_cfg_acl_item_action_cb_streamhandle_valid(i_cfg_acl_item_action_cb_streamhandle_valid ),
               .i_cfg_acl_item_action_flowctrl             (i_cfg_acl_item_action_flowctrl              ),
               .i_cfg_acl_item_action_flowctrl_valid       (i_cfg_acl_item_action_flowctrl_valid        ),
               .i_cfg_acl_item_action_txport               (i_cfg_acl_item_action_txport                ),
               .i_cfg_acl_item_action_txport_valid         (i_cfg_acl_item_action_txport_valid          ) 
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
                 .o_acl_no                       ( w_acl_no              ), // 未查到指示  
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
                 .o_busy                         ( w_cam_busy            ),  // 模块忙信号，高电平表示正在处理数据
                 // 配置接口 
                 .i_cfg_acl_clr_list_regs        ( i_cfg_acl_clr_list_regs ),
                 .o_cfg_acl_clr_busy_regs        ( o_cfg_acl_clr_busy_regs ) 
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
  reg r_acl_no ;
  always @(posedge i_clk)
  begin
    if (i_rst)
    begin
      r_acl_vld <= 1'b0;
      r_acl_no  <= 1'b0;
    end
    else
    begin
      r_acl_vld <= w_acl_addr_vld;
      r_acl_no  <= w_acl_no ;
    end
  end

  // assign o_cfg_acl_list_rdy_regs = w_cfg_acl_list_rdy_regs == 1'd1 || w_cfg_acl_clr_busy_regs == 1'd0 ? 1'd1 : 1'd0;
  assign o_acl_vld = r_acl_vld == 1'd1 && w_action_wea == 1'd0 ? 1'd1 : 1'd0;
  assign o_acl_no  = r_acl_vld == 1'd1 && w_action_wea == 1'd0 ? r_acl_no  : 1'd0;
  // assign o_fsm_state = w_fsm_state;
endmodule
