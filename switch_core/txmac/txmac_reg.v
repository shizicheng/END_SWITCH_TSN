module  tx_mac_reg #(
    parameter                                                   PORT_NUM                =      4        ,                   // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      6        ,
    parameter                                                   REG_DATA_BUS_WIDTH      =      32       
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
`ifdef CPU_MAC
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_0            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_0       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_0       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_0     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_0                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_0               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_0                 ,  // 诊断状态
`endif
`ifdef MAC1
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_1            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_1       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_1       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_1     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_1                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_1               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_1                 ,  // 诊断状态
`endif
`ifdef MAC2
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_2            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_2       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_2       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_2     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_2                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_2               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_2                 ,  // 诊断状态
`endif
`ifdef MAC3
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_3            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_3       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_3       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_3     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_3                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_3               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_3                 ,  // 诊断状态
`endif
`ifdef MAC4
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_4            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_4       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_4       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_4     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_4                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_4               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_4                 ,  // 诊断状态
`endif
`ifdef MAC5
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_5            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_5       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_5       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_5     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_5                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_5               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_5                 ,  // 诊断状态
`endif
`ifdef MAC6
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_6            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_6       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_6       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_6     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_6                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_6               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_6                 ,  // 诊断状态
`endif
`ifdef MAC7
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_7            ,  // 端口发送方向MAC关闭使能
    output             wire    [PORT_NUM-17:0]                  o_store_forward_enable_regs_7       ,  // 端口强制存储转发功能使能
    output             wire    [3:0]                            o_port_1g_interval_num_regs_7       ,  // 端口千兆模式发送帧间隔字节数配置值
    output             wire    [3:0]                            o_port_100m_interval_num_regs_7     ,  // 端口0百兆模式发送帧间隔字节数配置值
    input              wire    [15:0]                           i_port_tx_byte_cnt_7                ,  // 端口发送字节数
    input              wire    [15:0]                           i_port_tx_frame_cnt_7               ,  // 端口发送帧计数器
    input              wire    [15:0]                           i_port_diag_state_7                 ,   // 诊断状态
`endif
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
    output              wire                                    o_switch_reg_bus_rd_dout_v           // 读数据有效使能
);

endmodule