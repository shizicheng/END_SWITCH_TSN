module tsn_cb_top#(
    parameter                                                  RECOVERY_MODE                =      0        , // 0:向量恢复算法 1：匹配恢复算法
    parameter                                                  PORT_NUM                     =      8        , // 交换机的端口数
    parameter                                                  REG_ADDR_BUS_WIDTH           =      8        , // 寄存器地址位宽
    parameter                                                  REG_DATA_BUS_WIDTH           =      16         // 寄存器数据位宽
)( 
    input               wire                                   i_clk                              , // 250MHz
    input               wire                                   i_rst                              ,  
`ifdef CPU_MAC
    input               wire                                   i_rtag_flag0                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence0                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle0                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC1
    input               wire                                   i_rtag_flag1                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence1                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle1                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC2
    input               wire                                   i_rtag_flag2                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence2                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle2                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC3
    input               wire                                   i_rtag_flag3                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence3                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle3                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC4
    input               wire                                   i_rtag_flag4                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence4                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle4                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC5
    input               wire                                   i_rtag_flag5                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence5                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle5                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC6
    input               wire                                   i_rtag_flag6                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence6                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle6                   , // 区分流,每个流单独维护自己的 
`endif
`ifdef MAC7
    input               wire                                   i_rtag_flag7                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence7                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle7                   , // 区分流,每个流单独维护自己的 
`endif
 
    output              wire   [PORT_NUM-1:0]                  o_pass_en                          , // 判断结果,可以接收该帧
    output              wire   [PORT_NUM-1:0]                  o_discard_en                       , // 判断结果,可以丢弃该帧
    output              wire   [PORT_NUM-1:0]                  o_judge_finish                     ,  // 判断结果,表示本次报文的判断完成
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
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
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_rd_dout            , // 读出寄存器数据
    output              wire                                    o_switch_reg_bus_rd_dout_v            // 读数据有效使能

);
 
wire                                   w_0_rtag_flag0           ;
wire   [15:0]                          w_0_rtag_squence0        ;
wire   [7:0]                           w_0_stream_handle0       ;
wire                                   w_0_rtag_flag1           ;
wire   [15:0]                          w_0_rtag_squence1        ;
wire   [7:0]                           w_0_stream_handle1       ;
wire                                   w_0_rtag_flag2           ;
wire   [15:0]                          w_0_rtag_squence2        ;
wire   [7:0]                           w_0_stream_handle2       ;
wire                                   w_0_rtag_flag3           ;
wire   [15:0]                          w_0_rtag_squence3        ;
wire   [7:0]                           w_0_stream_handle3       ;
wire                                   w_0_rtag_flag4           ;
wire   [15:0]                          w_0_rtag_squence4        ;
wire   [7:0]                           w_0_stream_handle4       ;
wire                                   w_0_rtag_flag5           ;
wire   [15:0]                          w_0_rtag_squence5        ;
wire   [7:0]                           w_0_stream_handle5       ;
wire                                   w_0_rtag_flag6           ;
wire   [15:0]                          w_0_rtag_squence6        ;
wire   [7:0]                           w_0_stream_handle6       ;
wire                                   w_0_rtag_flag7           ;
wire   [15:0]                          w_0_rtag_squence7        ;
wire   [7:0]                           w_0_stream_handle7       ;
wire   [PORT_NUM-1:0]                  w_0_pass_en              ;
wire   [PORT_NUM-1:0]                  w_0_discard_en           ;
wire   [PORT_NUM-1:0]                  w_0_judge_finish         ;

wire                                   w_1_rtag_flag0           ;
wire   [15:0]                          w_1_rtag_squence0        ;
wire   [7:0]                           w_1_stream_handle0       ;
wire                                   w_1_rtag_flag1           ;
wire   [15:0]                          w_1_rtag_squence1        ;
wire   [7:0]                           w_1_stream_handle1       ;
wire                                   w_1_rtag_flag2           ;
wire   [15:0]                          w_1_rtag_squence2        ;
wire   [7:0]                           w_1_stream_handle2       ;
wire                                   w_1_rtag_flag3           ;
wire   [15:0]                          w_1_rtag_squence3        ;
wire   [7:0]                           w_1_stream_handle3       ;
wire                                   w_1_rtag_flag4           ;
wire   [15:0]                          w_1_rtag_squence4        ;
wire   [7:0]                           w_1_stream_handle4       ;
wire                                   w_1_rtag_flag5           ;
wire   [15:0]                          w_1_rtag_squence5        ;
wire   [7:0]                           w_1_stream_handle5       ;
wire                                   w_1_rtag_flag6           ;
wire   [15:0]                          w_1_rtag_squence6        ;
wire   [7:0]                           w_1_stream_handle6       ;
wire                                   w_1_rtag_flag7           ;
wire   [15:0]                          w_1_rtag_squence7        ;
wire   [7:0]                           w_1_stream_handle7       ;
wire   [PORT_NUM-1:0]                  w_1_pass_en              ;
wire   [PORT_NUM-1:0]                  w_1_discard_en           ;
wire   [PORT_NUM-1:0]                  w_1_judge_finish         ;
wire   [15:0]                          w_1_stream_recov_seq_num ;
wire   [15:0]                          w_1_stream_take_any      ;
wire   [7:0]                           w_1_cr_stream_handle     ;
wire   [31:0]                          w_1_passed_packets_cnt   ;
wire   [31:0]                          w_1_discarded_packets_cnt;

assign o_pass_en      = RECOVERY_MODE == 32'd0 ? w_0_pass_en      : w_1_pass_en      ;
assign o_discard_en   = RECOVERY_MODE == 32'd0 ? w_0_discard_en   : w_1_discard_en   ;
assign o_judge_finish = RECOVERY_MODE == 32'd0 ? w_0_judge_finish : w_1_judge_finish ;
 

// 例化CB判断和匹配恢复模块
vectory_recovery #(
    .RECOVERY_MODE     (0                  ),
    .PORT_NUM          (PORT_NUM           )       
) u_vectory_recovery_0 (
    .i_clk             (i_clk              ),
    .i_rst             (i_rst              ),
`ifdef CPU_MAC
    .i_rtag_flag0      ( i_rtag_flag0      ),
    .i_rtag_squence0   ( i_rtag_squence0   ),
    .i_stream_handle0  ( i_stream_handle0  ),
`endif
`ifdef MAC1
    .i_rtag_flag1      ( i_rtag_flag1      ),
    .i_rtag_squence1   ( i_rtag_squence1   ),
    .i_stream_handle1  ( i_stream_handle1  ),
`endif
`ifdef MAC2
    .i_rtag_flag2      ( i_rtag_flag2      ),
    .i_rtag_squence2   ( i_rtag_squence2   ),
    .i_stream_handle2  ( i_stream_handle2  ),
`endif
`ifdef MAC3
    .i_rtag_flag3      ( i_rtag_flag3      ),
    .i_rtag_squence3   ( i_rtag_squence3   ),
    .i_stream_handle3  ( i_stream_handle3  ),
`endif
`ifdef MAC4
    .i_rtag_flag4      ( i_rtag_flag4      ),
    .i_rtag_squence4   ( i_rtag_squence4   ),
    .i_stream_handle4  ( i_stream_handle4  ),
`endif
`ifdef MAC5
    .i_rtag_flag5      ( i_rtag_flag5      ),
    .i_rtag_squence5   ( i_rtag_squence5   ),
    .i_stream_handle5  ( i_stream_handle5  ),
`endif
`ifdef MAC6
    .i_rtag_flag6      ( i_rtag_flag6      ),
    .i_rtag_squence6   ( i_rtag_squence6   ),
    .i_stream_handle6  ( i_stream_handle6  ),
`endif
`ifdef MAC7
    .i_rtag_flag7      ( i_rtag_flag7      ),
    .i_rtag_squence7   ( i_rtag_squence7   ),
    .i_stream_handle7  ( i_stream_handle7  ),
`endif

    .o_pass_en         ( w_0_pass_en        ),
    .o_discard_en      ( w_0_discard_en     ),
    .o_judge_finish    ( w_0_judge_finish   )
);

match_recovery #(
    .RECOVERY_MODE     (1                  ),
    .PORT_NUM          (PORT_NUM           )       
) u_match_recovery_0 (
    .i_clk             (i_clk              ),
    .i_rst             (i_rst              ),
`ifdef CPU_MAC
    .i_rtag_flag0      ( i_rtag_flag0      ),
    .i_rtag_squence0   ( i_rtag_squence0   ),
    .i_stream_handle0  ( i_stream_handle0  ),
`endif
`ifdef MAC1
    .i_rtag_flag1      ( i_rtag_flag1      ),
    .i_rtag_squence1   ( i_rtag_squence1   ),
    .i_stream_handle1  ( i_stream_handle1  ),
`endif
`ifdef MAC2
    .i_rtag_flag2      ( i_rtag_flag2      ),
    .i_rtag_squence2   ( i_rtag_squence2   ),
    .i_stream_handle2  ( i_stream_handle2  ),
`endif
`ifdef MAC3
    .i_rtag_flag3      ( i_rtag_flag3      ),
    .i_rtag_squence3   ( i_rtag_squence3   ),
    .i_stream_handle3  ( i_stream_handle3  ),
`endif
`ifdef MAC4
    .i_rtag_flag4      ( i_rtag_flag4      ),
    .i_rtag_squence4   ( i_rtag_squence4   ),
    .i_stream_handle4  ( i_stream_handle4  ),
`endif
`ifdef MAC5
    .i_rtag_flag5      ( i_rtag_flag5      ),
    .i_rtag_squence5   ( i_rtag_squence5   ),
    .i_stream_handle5  ( i_stream_handle5  ),
`endif
`ifdef MAC6
    .i_rtag_flag6      ( i_rtag_flag6      ),
    .i_rtag_squence6   ( i_rtag_squence6   ),
    .i_stream_handle6  ( i_stream_handle6  ),
`endif
`ifdef MAC7
    .i_rtag_flag7      ( i_rtag_flag7      ),
    .i_rtag_squence7   ( i_rtag_squence7   ),
    .i_stream_handle7  ( i_stream_handle7  ),
`endif

    .o_pass_en         ( w_1_pass_en        ),
    .o_discard_en      ( w_1_discard_en     ),
    .o_judge_finish    ( w_1_judge_finish   )
    
);

/*---------------------------------------- cb_regs_list 模块例化 -------------------------------------------*/
cb_regs_list #(
    .REG_ADDR_BUS_WIDTH                     (REG_ADDR_BUS_WIDTH                     ),  // 寄存器地址位宽
    .REG_DATA_BUS_WIDTH                     (REG_DATA_BUS_WIDTH                     ),  // 寄存器数据位宽
    .PORT_NUM                               (PORT_NUM                               )   // 端口数
) u_cb_regs_list (
    .i_clk                                  (i_clk                                  ),  // 250MHz时钟
    .i_rst                                  (i_rst                                  ),  // 复位信号
    // 寄存器写控制接口
    .i_switch_reg_bus_we                    (i_switch_reg_bus_we                    ),  // 寄存器写使能
    .i_switch_reg_bus_we_addr               (i_switch_reg_bus_we_addr               ),  // 寄存器写地址
    .i_switch_reg_bus_we_din                (i_switch_reg_bus_we_din                ),  // 寄存器写数据
    .i_switch_reg_bus_we_din_v              (i_switch_reg_bus_we_din_v              ),  // 寄存器写数据使能
    // 寄存器读控制接口
    .i_switch_reg_bus_rd                    (i_switch_reg_bus_rd                    ),  // 寄存器读使能
    .i_switch_reg_bus_rd_addr               (i_switch_reg_bus_rd_addr               ),  // 寄存器读地址
    .o_switch_reg_bus_rd_dout               (o_switch_reg_bus_rd_dout               ),  // 读出寄存器数据
    .o_switch_reg_bus_rd_dout_v             (o_switch_reg_bus_rd_dout_v             ),  // 读数据有效使能
    // CB状态信号输入
    .i_recovsequm                           (w_1_stream_recov_seq_num               ),  // 恢复序列号
    .i_takeany                              (w_1_stream_take_any                    ),  // 任意接收
    .i_frercpsseprcvypassed_low16           (w_1_passed_packets_cnt[15:0]           ),  // 恢复通过计数低16位
    .i_frercpsseprcvypassed_mid16_1         (w_1_passed_packets_cnt[31:16]          ),  // 恢复通过计数中16位1
    .i_frercpsseprcvypassed_mid16_2         (16'h0000                               ),  // 恢复通过计数中16位2
    .i_frercpsseprcvypassed_high16          (16'h0000                               ),  // 恢复通过计数高16位
    .i_frercpsseprcvydiscarded_low16        (w_1_discarded_packets_cnt[15:0]        ),  // 恢复丢弃计数低16位
    .i_frercpsseprcvydiscarded_mid16_1      (w_1_discarded_packets_cnt[31:16]       ),  // 恢复丢弃计数中16位1
    .i_frercpsseprcvydiscarded_mid16_2      (16'h0000                               ),  // 恢复丢弃计数中16位2
    .i_frercpsseprcvydiscarded_high16       (16'h0000                               ),  // 恢复丢弃计数高16位
    .i_frercpsseprcvyresets_low16           (16'h0                                  ),  // 恢复复位计数低16位
    .i_frercpsseprcvyresets_high16          (16'h0                                  ),  // 恢复复位计数高16位
    .i_stream_valid                         (8'h0                                   ),  // 流有效信号
    // CB配置信号输出
    .o_max_stream_count                     (                                       ),  // 最大流数量
    .o_frerseqrcvyalgorithm_identification  (                                       ),  // FRER序列恢复算法标识
    .o_frerseqrcvyhistorylength             (                                       ),  // FRER序列恢复历史长度
    .o_frerseqrcvyresetmsec                 (                                       ),  // FRER序列恢复复位时间(毫秒)
    .o_current_stream_handle                (w_1_cr_stream_handle                   )   // 当前流句柄
);




endmodule