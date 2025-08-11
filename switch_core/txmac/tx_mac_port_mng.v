`include "synth_cmd_define.vh"

module  tx_mac_port_mng #(
    parameter                                                   PORT_NUM                =      4        ,                   // 交换机的端口数
    parameter                                                   SEHEDUDATA_WIDTH        =      64       ,                   // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,                   // Mac_port_mng 数据位宽
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,                   // 支持端口优先级 FIFO 的数量
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_fifoc_empty                       ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_scheduing_rst                     ,
    output              wire                                    o_scheduing_rst_vld                 ,                 
    /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
    // 数据流信息 
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac_tx_axis_data                 , 
    input           wire    [15:0]                              i_pmac_tx_axis_user                 , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac_tx_axis_keep                 , 
    input           wire                                        i_pmac_tx_axis_last                 , 
    input           wire                                        i_pmac_tx_axis_valid                , 
    input           wire    [15:0]                              i_pmac_ethertype                    , 
    output          wire                                        o_pmac_tx_axis_ready                ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac_tx_axis_data                 , 
    input           wire    [15:0]                              i_emac_tx_axis_user                 , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac_tx_axis_keep                 , 
    input           wire                                        i_emac_tx_axis_last                 , 
    input           wire                                        i_emac_tx_axis_valid                , 
    input           wire    [15:0]                              i_emac_ethertype                    ,
    output          wire                                        o_emac_tx_axis_ready                ,
    /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
    // 控制寄存器
    input              wire    [PORT_NUM-1:0]                   i_port_txmac_down_regs              ,  // 端口发送方向MAC关闭使能
    input              wire    [PORT_NUM-17:0]                  i_store_forward_enable_regs         ,  // 端口强制存储转发功能使能
    input              wire    [3:0]                            i_port_1g_interval_num_regs         ,  // 端口千兆模式发送帧间隔字节数配置值
    input              wire    [3:0]                            i_port_100m_interval_num_regs       ,  // 端口0百兆模式发送帧间隔字节数配置值
    // 状态寄存器
    output             wire    [15:0]                           o_port_tx_byte_cnt                  ,  // 端口发送字节数
    output             wire    [15:0]                           o_port_tx_frame_cnt                 ,  // 端口发送帧计数器
    // 诊断状态寄存器
    output             wire    [15:0]                           o_port_diag_state                   ,  // 诊断状态

    /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac_axi_data                      ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac_axi_data_keep                 ,
    output          wire                                        o_mac_axi_data_valid                ,
    output          wire    [15:0]                              o_mac_axi_data_user                 ,
    input           wire                                        i_mac_axi_data_ready                ,
    output          wire                                        o_mac_axi_data_last                 
//     // 报文时间打时间戳 
//    input            wire                                        i_mac_time_irq                      , // 打时间戳中断信号
//    input            wire  [7:0]                                 i_mac_frame_seq                     , // 帧序列号
//    input            wire  [7:0]                                 i_timestamp_addr                      // 打时间戳存储的 RAM 地址
);

/*---------------- 调度层流水线 ------------------------*/
Scheduling_top #(
    .PORT_FIFO_PRI_NUM       (  )     // 支持端口优先级 FIFO 的数量
)(  
    .i_clk                   (  )            , // 250MHz
    .i_rst                   (  )            ,
    /*------------------------------ 与CROSSBAR交换平面交互的调度信息 ------------------------------*/
    // 调度流水线调度信息交互
    .i_fifoc_empty           (  )            , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息 
    .o_scheduing_rst         (  )            , // 该端口调度流水线产生的调度结果
    .o_scheduing_rst_vld     (  )            , // 该端口调度流水线产生的调度结果有效位
    // QBU 模块返回的信号  
    .i_pmac_tx_axis_valid    (  )            , // 用于管理每个优先级队列的信用值
    .i_pmac_tx_axis_last     (  )              // 数据流 last 信号，用于使能调度流水线计算  
);

/*---------------- TXMAC_PORT_MNG 数据面 ------------------------*/
qbu_send #(
    .AXIS_DATA_WIDTH                                ( CROSS_DATA_WIDTH               ),
    .QUEUE_NUM                                      ( 8                              )
) u_qbu_send ( 
    .i_clk                                          ( i_clk                          ),
    .i_rst                                          ( i_rst                          ),
    //pmac通道数据 
    .i_pmac_tx_axis_data                            ( w_pmac_axi_data                ), 
    .i_pmac_tx_axis_user                            ( w_pmac_axi_data_user           ), 
    .i_pmac_tx_axis_keep                            ( w_pmac_axi_data_keep           ), 
    .i_pmac_tx_axis_last                            ( w_pmac_axi_data_last           ), 
    .i_pmac_tx_axis_valid                           ( w_pmac_axi_data_valid          ), 
    .i_pmac_ethertype                               ( w_pmac_ethertype               ),
    .o_pmac_tx_axis_ready                           ( i_pmac_axi_data_ready          ),
    //emac通道数据   
    .i_emac_tx_axis_data                            ( w_emac_axi_data                ), 
    .i_emac_tx_axis_user                            ( w_emac_axi_data_user           ), 
    .i_emac_tx_axis_keep                            ( w_emac_axi_data_keep           ), 
    .i_emac_tx_axis_last                            ( w_emac_axi_data_last           ), 
    .i_emac_tx_axis_valid                           ( w_emac_axi_data_valid          ), 
    .i_emac_ethertype                               ( w_emac_ethertype               ),
    .o_emac_tx_axis_ready                           ( i_emac_axi_data_ready          ),

    // .i_emac_channel_cfg         (8'b0010_1100               ),
    // .i_tx_mac_forward_info      (i_tx_mac_forward_info      ),
    // .i_tx_mac_forward_info_vld  (i_tx_mac_forward_info_vld  ),
 
    .i_qbu_verify_valid                             ( i_qbu_verify_valid             ),
    .i_qbu_response_valid                           ( i_qbu_response_valid           ),
    // qbu的AXI接口输出到PHY平台接口                         
    .o_mac_axi_data                                 ( w_mac_axi_data                 ),
    .o_mac_axi_data_keep                            ( w_mac_axi_data_keep            ),
    .o_mac_axi_data_valid                           ( w_mac_axi_data_valid           ),
    .o_mac_axi_data_user                            ( w_mac_axi_data_user            ),
    .i_mac_axi_data_ready                           ( w_mac_axi_data_ready           ),
    .o_mac_axi_data_last                            ( w_mac_axi_data_last            ),
    //qbu寄存器信号                      
    .o_frag_next_tx                                 ( o_frag_next_tx                 ),
    .o_tx_timeout                                   ( o_tx_timeout                   ),
    .o_preempt_success_cnt                          ( o_preempt_success_cnt          ),
    .o_preempt_active                               ( o_preempt_active               ),
    .o_preemptable_frame                            ( o_preemptable_frame            ),
    .o_tx_frames_cnt                                ( o_tx_frames_cnt                ),
    .o_tx_fragment_cnt                              ( o_tx_fragment_cnt              ),
    .o_tx_busy                                      ( o_tx_busy                      ),
    .i_watchdog_timer                               ( i_watchdog_timer               ),
    .i_watchdog_timer_vld                           ( i_watchdog_timer_vld           ),
    .i_min_frag_size                                ( i_min_frag_size                ),
    .i_min_frag_size_vld                            ( i_min_frag_size_vld            ),
    .i_ipg_timer                                    ( i_ipg_timer                    ),
    .i_ipg_timer_vld                                ( i_ipg_timer_vld                ),
                         
    .i_verify_enabled                               ( i_verify_enabled               ),
    .i_start_verify                                 ( i_start_verify                 ),
    .i_clear_verify                                 ( i_clear_verify                 ),
    .o_verify_succ                                  ( o_verify_succ                  ),
    .o_verify_succ_val                              ( o_verify_succ_val              ),
    .i_verify_timer                                 ( i_verify_timer                 ),
    .i_verify_timer_vld                             ( i_verify_timer_vld             ),
    .o_err_verify_cnt                               ( o_err_verify_cnt               ),
    .o_preempt_enable                               ( o_preempt_enable               ) 
);

tx_mac_reg #(
    .PORT_NUM                                        ()      ,   // 交换机的端口数
    .REG_ADDR_BUS_WIDTH                              ()      ,
    .REG_DATA_BUS_WIDTH                              ()      
)tx_mac_reg_inst (                       
    .i_clk                                           ()      ,   // 250MHz
    .i_rst                                           ()      ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
`ifdef CPU_MAC
    .o_port_txmac_down_regs_0                        ()   ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_0                   ()   ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_0                   ()   ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_0                 ()   ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_0                            ()   ,  // 端口发送字节数
    .i_port_tx_frame_cnt_0                           ()   ,  // 端口发送帧计数器
    .i_port_diag_state_0                             ()   ,  // 诊断状态
`endif       
`ifdef MAC1      
    .o_port_txmac_down_regs_1                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_1                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_1                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_1                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_1                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_1                           () ,  // 端口发送帧计数器
    .i_port_diag_state_1                             () ,  // 诊断状态
`endif       
`ifdef MAC2      
    .o_port_txmac_down_regs_2                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_2                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_2                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_2                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_2                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_2                           () ,  // 端口发送帧计数器
    .i_port_diag_state_2                             () ,  // 诊断状态
`endif       
`ifdef MAC3      
    .o_port_txmac_down_regs_3                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_3                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_3                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_3                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_3                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_3                           () ,  // 端口发送帧计数器
    .i_port_diag_state_3                             () ,  // 诊断状态
`endif       
`ifdef MAC4      
    .o_port_txmac_down_regs_4                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_4                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_4                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_4                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_4                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_4                           () ,  // 端口发送帧计数器
    .i_port_diag_state_4                             () ,  // 诊断状态
`endif       
`ifdef MAC5      
    .o_port_txmac_down_regs_5                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_5                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_5                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_5                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_5                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_5                           () ,  // 端口发送帧计数器
    .i_port_diag_state_5                             () ,  // 诊断状态
`endif       
`ifdef MAC6      
    .o_port_txmac_down_regs_6                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_6                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_6                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_6                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_6                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_6                           () ,  // 端口发送帧计数器
    .i_port_diag_state_6                             () ,  // 诊断状态
`endif       
`ifdef MAC7      
    .o_port_txmac_down_regs_7                        () ,  // 端口发送方向MAC关闭使能
    .o_store_forward_enable_regs_7                   () ,  // 端口强制存储转发功能使能
    .o_port_1g_interval_num_regs_7                   () ,  // 端口千兆模式发送帧间隔字节数配置值
    .o_port_100m_interval_num_regs_7                 () ,  // 端口0百兆模式发送帧间隔字节数配置值
    .i_port_tx_byte_cnt_7                            () ,  // 端口发送字节数
    .i_port_tx_frame_cnt_7                           () ,  // 端口发送帧计数器
    .i_port_diag_state_7                             () ,  // 诊断状态
`endif
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse                            () , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr                            () , // 刷新错误计数器
    .i_switch_err_cnt_stat                           () , // 刷新错误状态寄存器
    // 寄存器写控制接口              
    .i_switch_reg_bus_we                             () , // 寄存器写使能
    .i_switch_reg_bus_we_addr                        () , // 寄存器写地址
    .i_switch_reg_bus_we_din                         () , // 寄存器写数据
    .i_switch_reg_bus_we_din_v                       () , // 寄存器写数据使能
    // 寄存器读控制接口              
    .i_switch_reg_bus_rd                             () , // 寄存器读使能
    .i_switch_reg_bus_rd_addr                        () , // 寄存器读地址
    .o_switch_reg_bus_rd_dout                        () , // 读出寄存器数据
    .o_switch_reg_bus_rd_dout_v                      ()  // 读数据有效使能
);

endmodule