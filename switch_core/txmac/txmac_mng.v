`include "synth_cmd_define.vh"

module  tx_mac_mng #(
    parameter                                                   PORT_NUM                =      4        ,                   // 交换机的端口数
    parameter                                                   METADATA_WIDTH          =      64       ,                   // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,                   // Mac_port_mng 数据位宽
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,                   // 支持端口优先级 FIFO 的数量
    parameter                                                   REG_ADDR_BUS_WIDTH      =      6        ,
    parameter                                                   REG_DATA_BUS_WIDTH      =      32       ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*----------------------- 业务接口数据输出 ---------------------------*/
`ifdef CPU_MAC
    /* ------------------ CROSSBAR交换平面数据流输入 -------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac0_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac0_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac0_tx_axis_keep                , 
    input           wire                                        i_pmac0_tx_axis_last                , 
    input           wire                                        i_pmac0_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac0_ethertype                   , 
    output          wire                                        o_pmac0_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac0_tx_axis_data                , 
    input           wire    [15:0]                              i_emac0_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac0_tx_axis_keep                , 
    input           wire                                        i_emac0_tx_axis_last                , 
    input           wire                                        i_emac0_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac0_ethertype                   ,
    output          wire                                        o_emac0_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac0_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac0_scheduing_rst                ,
    output              wire                                    o_mac0_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac0_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac0_axi_data_keep                ,
    output          wire                                        o_mac0_axi_data_valid               ,
    output          wire    [15:0]                              o_mac0_axi_data_user                ,
    input           wire                                        i_mac0_axi_data_ready               ,
    output          wire                                        o_mac0_axi_data_last                ,
    // 报文时间打时间戳
    output              wire                                    o_mac0_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac0_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac0_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC1
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac1_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac1_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac1_tx_axis_keep                , 
    input           wire                                        i_pmac1_tx_axis_last                , 
    input           wire                                        i_pmac1_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac1_ethertype                   , 
    output          wire                                        o_pmac1_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac1_tx_axis_data                , 
    input           wire    [15:0]                              i_emac1_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac1_tx_axis_keep                , 
    input           wire                                        i_emac1_tx_axis_last                , 
    input           wire                                        i_emac1_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac1_ethertype                   ,
    output          wire                                        o_emac1_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac1_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac1_scheduing_rst                ,
    output              wire                                    o_mac1_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac1_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac1_axi_data_keep                ,
    output          wire                                        o_mac1_axi_data_valid               ,
    output          wire    [15:0]                              o_mac1_axi_data_user                ,
    input           wire                                        i_mac1_axi_data_ready               ,
    output          wire                                        o_mac1_axi_data_last                ,
    // 报文时间打时间戳
    output              wire                                    o_mac1_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac1_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac1_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC2
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac2_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac2_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac2_tx_axis_keep                , 
    input           wire                                        i_pmac2_tx_axis_last                , 
    input           wire                                        i_pmac2_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac2_ethertype                   , 
    output          wire                                        o_pmac2_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac2_tx_axis_data                , 
    input           wire    [15:0]                              i_emac2_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac2_tx_axis_keep                , 
    input           wire                                        i_emac2_tx_axis_last                , 
    input           wire                                        i_emac2_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac2_ethertype                   ,
    output          wire                                        o_emac2_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac2_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac2_scheduing_rst                ,
    output              wire                                    o_mac2_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac2_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac2_axi_data_keep                ,
    output          wire                                        o_mac2_axi_data_valid               ,
    output          wire    [15:0]                              o_mac2_axi_data_user                ,
    input           wire                                        i_mac2_axi_data_ready               ,
    output          wire                                        o_mac2_axi_data_last                ,
    // 报文时间打时间戳
    output              wire                                    o_mac2_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac2_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac2_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC3
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac3_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac3_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac3_tx_axis_keep                , 
    input           wire                                        i_pmac3_tx_axis_last                , 
    input           wire                                        i_pmac3_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac3_ethertype                   , 
    output          wire                                        o_pmac3_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac3_tx_axis_data                , 
    input           wire    [15:0]                              i_emac3_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac3_tx_axis_keep                , 
    input           wire                                        i_emac3_tx_axis_last                , 
    input           wire                                        i_emac3_tx_axis_valid               ,    
    input           wire    [15:0]                              i_emac3_ethertype                   ,   
    output          wire                                        o_emac3_tx_axis_ready               ,   
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac3_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac3_scheduing_rst                ,
    output              wire                                    o_mac3_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac3_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac3_axi_data_keep                ,
    output          wire                                        o_mac3_axi_data_valid               ,
    output          wire    [15:0]                              o_mac3_axi_data_user                ,
    input           wire                                        i_mac3_axi_data_ready               ,
    output          wire                                        o_mac3_axi_data_last                ,
    // 报文时间打时间戳
    output              wire                                    o_mac3_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac3_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac3_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC4
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac4_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac4_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac4_tx_axis_keep                , 
    input           wire                                        i_pmac4_tx_axis_last                , 
    input           wire                                        i_pmac4_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac4_ethertype                   , 
    output          wire                                        o_pmac4_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac4_tx_axis_data                , 
    input           wire    [15:0]                              i_emac4_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac4_tx_axis_keep                , 
    input           wire                                        i_emac4_tx_axis_last                , 
    input           wire                                        i_emac4_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac4_ethertype                   ,
    output          wire                                        o_emac4_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac4_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac4_scheduing_rst                ,
    output              wire                                    o_mac4_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac4_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac4_axi_data_keep                ,
    output          wire                                        o_mac4_axi_data_valid               ,
    output          wire    [15:0]                              o_mac4_axi_data_user                ,
    input           wire                                        i_mac4_axi_data_ready               ,
    output          wire                                        o_mac4_axi_data_last                ,
    // 报文时间打时间戳
    output              wire                                    o_mac4_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac4_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac4_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC5
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac5_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac5_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac5_tx_axis_keep                , 
    input           wire                                        i_pmac5_tx_axis_last                , 
    input           wire                                        i_pmac5_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac5_ethertype                   , 
    output          wire                                        o_pmac5_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac5_tx_axis_data                , 
    input           wire    [15:0]                              i_emac5_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac5_tx_axis_keep                , 
    input           wire                                        i_emac5_tx_axis_last                , 
    input           wire                                        i_emac5_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac5_ethertype                   ,
    output          wire                                        o_emac5_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac5_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac5_scheduing_rst                ,
    output              wire                                    o_mac5_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac5_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac5_axi_data_keep                ,
    output          wire                                        o_mac5_axi_data_valid               ,
    output          wire    [15:0]                              o_mac5_axi_data_user                ,
    input           wire                                        i_mac5_axi_data_ready               ,
    output          wire                                        o_mac5_axi_data_last                ,
    // 报文时间打时间
    output              wire                                    o_mac5_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac5_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac5_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC6
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac6_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac6_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac6_tx_axis_keep                , 
    input           wire                                        i_pmac6_tx_axis_last                , 
    input           wire                                        i_pmac6_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac6_ethertype                   , 
    output          wire                                        o_pmac6_tx_axis_ready               ,
    //emac通道数据              
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac6_tx_axis_data                , 
    input           wire    [15:0]                              i_emac6_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac6_tx_axis_keep                , 
    input           wire                                        i_emac6_tx_axis_last                , 
    input           wire                                        i_emac6_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac6_ethertype                   ,
    output          wire                                        o_emac6_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac6_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac6_scheduing_rst                ,
    output              wire                                    o_mac6_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac6_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac6_axi_data_keep                ,
    output          wire                                        o_mac6_axi_data_valid               ,
    output          wire    [15:0]                              o_mac6_axi_data_user                ,
    input           wire                                        i_mac6_axi_data_ready               ,
    output          wire                                        o_mac6_axi_data_last                ,
    // 报文时间打时间6
    output              wire                                    o_mac6_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac6_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac6_timestamp_addr               , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC7
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_pmac7_tx_axis_data                , 
    input           wire    [15:0]                              i_pmac7_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_pmac7_tx_axis_keep                , 
    input           wire                                        i_pmac7_tx_axis_last                , 
    input           wire                                        i_pmac7_tx_axis_valid               , 
    input           wire    [15:0]                              i_pmac7_ethertype                   , 
    output          wire                                        o_pmac7_tx_axis_ready               ,
    //emac通道数据             
    input           wire    [CROSS_DATA_WIDTH - 1:0]            i_emac7_tx_axis_data                , 
    input           wire    [15:0]                              i_emac7_tx_axis_user                , 
    input           wire    [(CROSS_DATA_WIDTH/8)-1:0]          i_emac7_tx_axis_keep                , 
    input           wire                                        i_emac7_tx_axis_last                , 
    input           wire                                        i_emac7_tx_axis_valid               , 
    input           wire    [15:0]                              i_emac7_ethertype                   ,
    output          wire                                        o_emac7_tx_axis_ready               ,
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_mac7_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_mac7_scheduing_rst                ,
    output              wire                                    o_mac7_scheduing_rst_vld            ,   
    /* ---------------------- TXMAC 数据流输出 ------------------------- */
    //输出给接口层axi数据流
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_mac7_axi_data                     ,
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_mac7_axi_data_keep                ,
    output          wire                                        o_mac7_axi_data_valid               ,
    output          wire    [15:0]                              o_mac7_axi_data_user                ,
    input           wire                                        i_mac7_axi_data_ready               ,
    output          wire                                        o_mac7_axi_data_last                ,
    // 报文时间打时间6
    output              wire                                    o_mac7_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac7_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_mac7_timestamp_addr               , // 打时间戳存储的 RAM 地址
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
    output              wire                                    o_switch_reg_bus_rd_dout_v            // 读数据有效使能
);

// wire defination
// CPU_MAC
// CPU_MAC 寄存器信号定义
`ifdef CPU_MAC
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_0;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_0;
    wire [3:0]                                          w_port_1g_interval_num_regs_0;
    wire [3:0]                                          w_port_100m_interval_num_regs_0;
    wire [15:0]                                         w_port_tx_byte_cnt_0;
    wire [15:0]                                         w_port_tx_frame_cnt_0;
    wire [15:0]                                         w_port_diag_state_0;
    wire [7:0]                                          w_idleSlope_p0q0;
    wire [7:0]                                          w_sendslope_p0q0;
    wire [15:0]                                         w_hithreshold_p0q0;
    wire [15:0]                                         w_lothreshold_p0q0;
    wire [7:0]                                          w_idleSlope_p0q1;
    wire [7:0]                                          w_sendslope_p0q1;
    wire [15:0]                                         w_hithreshold_p0q1;
    wire [15:0]                                         w_lothreshold_p0q1;
    wire [7:0]                                          w_idleSlope_p0q2;
    wire [7:0]                                          w_sendslope_p0q2;
    wire [15:0]                                         w_hithreshold_p0q2;
    wire [15:0]                                         w_lothreshold_p0q2;
    wire [7:0]                                          w_idleSlope_p0q3;
    wire [7:0]                                          w_sendslope_p0q3;
    wire [15:0]                                         w_hithreshold_p0q3;
    wire [15:0]                                         w_lothreshold_p0q3;
    wire [7:0]                                          w_idleSlope_p0q4;
    wire [7:0]                                          w_sendslope_p0q4;
    wire [15:0]                                         w_hithreshold_p0q4;
    wire [15:0]                                         w_lothreshold_p0q4;
    wire [7:0]                                          w_idleSlope_p0q5;
    wire [7:0]                                          w_sendslope_p0q5;
    wire [15:0]                                         w_hithreshold_p0q5;
    wire [15:0]                                         w_lothreshold_p0q5;
    wire [7:0]                                          w_idleSlope_p0q6;
    wire [7:0]                                          w_sendslope_p0q6;
    wire [15:0]                                         w_hithreshold_p0q6;
    wire [15:0]                                         w_lothreshold_p0q6;
    wire [7:0]                                          w_idleSlope_p0q7;
    wire [7:0]                                          w_sendslope_p0q7;
    wire [15:0]                                         w_hithreshold_p0q7;
    wire [15:0]                                         w_lothreshold_p0q7;
    wire                                                w_qav_en_0;
    wire                                                w_config_vld_0;
    wire [79:0]                                         w_Base_time_0;
	wire												w_Base_time_vld_0;
    wire                                                w_ConfigChange_0;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_0;
    wire [7:0]                                          w_ControlList_len_0;
    wire                                                w_ControlList_vld_0;
    wire [15:0]                                         w_cycle_time_0;
    wire [79:0]                                         w_cycle_time_extension_0;
    wire                                                w_qbv_en_0;
    wire [3:0]                                          w_qos_sch_0;
    wire                                                w_qos_en_0;
    wire [7:0]                                          w_frag_next_tx_0;
    wire                                                w_tx_timeout_0;    
    wire [15:0]                                         w_preempt_success_cnt_0;
    wire                                                w_preempt_active_0;
    wire                                                w_preemptable_frame_0;
    wire [15:0]                                         w_tx_frames_cnt_0;
    wire [15:0]                                         w_tx_fragment_cnt_0;
    wire                                                w_tx_busy_0;
    wire [19:0]                                         w_watchdog_timer_0;
    wire                                                w_watchdog_timer_vld_0;
    wire [7:0]                                          w_min_frag_size_0;
    wire                                                w_min_frag_size_vld_0;
    wire [7:0]                                          w_ipg_timer_0;
    wire                                                w_ipg_timer_vld_0;
    wire                                                w_verify_enabled_0;
    wire                                                w_start_verify_0;
    wire                                                w_clear_verify_0;
    wire [15:0]                                         w_verify_timer_0;
    wire                                                w_verify_timer_vld_0;
    wire [15:0]                                         w_err_verify_cnt_0;
    wire                                                w_preempt_enable_0;
`endif
// MAC1
// MAC1 寄存器信号定义
`ifdef MAC1
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_1;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_1;
    wire [3:0]                                          w_port_1g_interval_num_regs_1;
    wire [3:0]                                          w_port_100m_interval_num_regs_1;
    wire [15:0]                                         w_port_tx_byte_cnt_1;
    wire [15:0]                                         w_port_tx_frame_cnt_1;
    wire [15:0]                                         w_port_diag_state_1;
    wire [7:0]                                          w_idleSlope_p1q0;
    wire [7:0]                                          w_sendslope_p1q0;
    wire [15:0]                                         w_hithreshold_p1q0;
    wire [15:0]                                         w_lothreshold_p1q0;
    wire [7:0]                                          w_idleSlope_p1q1;
    wire [7:0]                                          w_sendslope_p1q1;
    wire [15:0]                                         w_hithreshold_p1q1;
    wire [15:0]                                         w_lothreshold_p1q1;
    wire [7:0]                                          w_idleSlope_p1q2;
    wire [7:0]                                          w_sendslope_p1q2;
    wire [15:0]                                         w_hithreshold_p1q2;
    wire [15:0]                                         w_lothreshold_p1q2;
    wire [7:0]                                          w_idleSlope_p1q3;
    wire [7:0]                                          w_sendslope_p1q3;
    wire [15:0]                                         w_hithreshold_p1q3;
    wire [15:0]                                         w_lothreshold_p1q3;
    wire [7:0]                                          w_idleSlope_p1q4;
    wire [7:0]                                          w_sendslope_p1q4;
    wire [15:0]                                         w_hithreshold_p1q4;
    wire [15:0]                                         w_lothreshold_p1q4;
    wire [7:0]                                          w_idleSlope_p1q5;
    wire [7:0]                                          w_sendslope_p1q5;
    wire [15:0]                                         w_hithreshold_p1q5;
    wire [15:0]                                         w_lothreshold_p1q5;
    wire [7:0]                                          w_idleSlope_p1q6;
    wire [7:0]                                          w_sendslope_p1q6;
    wire [15:0]                                         w_hithreshold_p1q6;
    wire [15:0]                                         w_lothreshold_p1q6;
    wire [7:0]                                          w_idleSlope_p1q7;
    wire [7:0]                                          w_sendslope_p1q7;
    wire [15:0]                                         w_hithreshold_p1q7;
    wire [15:0]                                         w_lothreshold_p1q7;
    wire                                                w_qav_en_1;
    wire                                                w_config_vld_1;
    wire [79:0]                                         w_Base_time_1;
	wire												w_Base_time_vld_1;
    wire                                                w_ConfigChange_1;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_1;
    wire [7:0]                                          w_ControlList_len_1;
    wire                                                w_ControlList_vld_1;
    wire [15:0]                                         w_cycle_time_1;
    wire [79:0]                                         w_cycle_time_extension_1;
    wire                                                w_qbv_en_1;
    wire [3:0]                                          w_qos_sch_1;
    wire                                                w_qos_en_1;
    wire [7:0]                                          w_frag_next_tx_1;
    wire                                                w_tx_timeout_1;    
    wire [15:0]                                         w_preempt_success_cnt_1;
    wire                                                w_preempt_active_1;
    wire                                                w_preemptable_frame_1;
    wire [15:0]                                         w_tx_frames_cnt_1;
    wire [15:0]                                         w_tx_fragment_cnt_1;
    wire                                                w_tx_busy_1;
    wire [19:0]                                         w_watchdog_timer_1;
    wire                                                w_watchdog_timer_vld_1;
    wire [7:0]                                          w_min_frag_size_1;
    wire                                                w_min_frag_size_vld_1;
    wire [7:0]                                          w_ipg_timer_1;
    wire                                                w_ipg_timer_vld_1;
    wire                                                w_verify_enabled_1;
    wire                                                w_start_verify_1;
    wire                                                w_clear_verify_1;
    wire [15:0]                                         w_verify_timer_1;
    wire                                                w_verify_timer_vld_1;
    wire [15:0]                                         w_err_verify_cnt_1;
    wire                                                w_preempt_enable_1;
`endif
// MAC2
// MAC2 寄存器信号定义
`ifdef MAC2
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_2;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_2;
    wire [3:0]                                          w_port_1g_interval_num_regs_2;
    wire [3:0]                                          w_port_100m_interval_num_regs_2;
    wire [15:0]                                         w_port_tx_byte_cnt_2;
    wire [15:0]                                         w_port_tx_frame_cnt_2;
    wire [15:0]                                         w_port_diag_state_2;
    wire [7:0]                                          w_idleSlope_p2q0;
    wire [7:0]                                          w_sendslope_p2q0;
    wire [15:0]                                         w_hithreshold_p2q0;
    wire [15:0]                                         w_lothreshold_p2q0;
    wire [7:0]                                          w_idleSlope_p2q1;
    wire [7:0]                                          w_sendslope_p2q1;
    wire [15:0]                                         w_hithreshold_p2q1;
    wire [15:0]                                         w_lothreshold_p2q1;
    wire [7:0]                                          w_idleSlope_p2q2;
    wire [7:0]                                          w_sendslope_p2q2;
    wire [15:0]                                         w_hithreshold_p2q2;
    wire [15:0]                                         w_lothreshold_p2q2;
    wire [7:0]                                          w_idleSlope_p2q3;
    wire [7:0]                                          w_sendslope_p2q3;
    wire [15:0]                                         w_hithreshold_p2q3;
    wire [15:0]                                         w_lothreshold_p2q3;
    wire [7:0]                                          w_idleSlope_p2q4;
    wire [7:0]                                          w_sendslope_p2q4;
    wire [15:0]                                         w_hithreshold_p2q4;
    wire [15:0]                                         w_lothreshold_p2q4;
    wire [7:0]                                          w_idleSlope_p2q5;
    wire [7:0]                                          w_sendslope_p2q5;
    wire [15:0]                                         w_hithreshold_p2q5;
    wire [15:0]                                         w_lothreshold_p2q5;
    wire [7:0]                                          w_idleSlope_p2q6;
    wire [7:0]                                          w_sendslope_p2q6;
    wire [15:0]                                         w_hithreshold_p2q6;
    wire [15:0]                                         w_lothreshold_p2q6;
    wire [7:0]                                          w_idleSlope_p2q7;
    wire [7:0]                                          w_sendslope_p2q7;
    wire [15:0]                                         w_hithreshold_p2q7;
    wire [15:0]                                         w_lothreshold_p2q7;
    wire                                                w_qav_en_2;
    wire                                                w_config_vld_2;
    wire [79:0]                                         w_Base_time_2;
	wire												w_Base_time_vld_2;	
    wire                                                w_ConfigChange_2;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_2;
    wire [7:0]                                          w_ControlList_len_2;
    wire                                                w_ControlList_vld_2;
    wire [15:0]                                         w_cycle_time_2;
    wire [79:0]                                         w_cycle_time_extension_2;
    wire                                                w_qbv_en_2;
    wire [3:0]                                          w_qos_sch_2;
    wire                                                w_qos_en_2;
    wire [7:0]                                          w_frag_next_tx_2;
    wire                                                w_tx_timeout_2;    
    wire [15:0]                                         w_preempt_success_cnt_2;
    wire                                                w_preempt_active_2;
    wire                                                w_preemptable_frame_2;
    wire [15:0]                                         w_tx_frames_cnt_2;
    wire [15:0]                                         w_tx_fragment_cnt_2;
    wire                                                w_tx_busy_2;
    wire [19:0]                                         w_watchdog_timer_2;
    wire                                                w_watchdog_timer_vld_2;
    wire [7:0]                                          w_min_frag_size_2;
    wire                                                w_min_frag_size_vld_2;
    wire [7:0]                                          w_ipg_timer_2;
    wire                                                w_ipg_timer_vld_2;
    wire                                                w_verify_enabled_2;
    wire                                                w_start_verify_2;
    wire                                                w_clear_verify_2;
    wire [15:0]                                         w_verify_timer_2;
    wire                                                w_verify_timer_vld_2;
    wire [15:0]                                         w_err_verify_cnt_2;
    wire                                                w_preempt_enable_2;
`endif
// MAC3
// MAC3 寄存器信号定义
`ifdef MAC3
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_3;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_3;
    wire [3:0]                                          w_port_1g_interval_num_regs_3;
    wire [3:0]                                          w_port_100m_interval_num_regs_3;
    wire [15:0]                                         w_port_tx_byte_cnt_3;
    wire [15:0]                                         w_port_tx_frame_cnt_3;
    wire [15:0]                                         w_port_diag_state_3;
    wire [7:0]                                          w_idleSlope_p3q0;
    wire [7:0]                                          w_sendslope_p3q0;
    wire [15:0]                                         w_hithreshold_p3q0;
    wire [15:0]                                         w_lothreshold_p3q0;
    wire [7:0]                                          w_idleSlope_p3q1;
    wire [7:0]                                          w_sendslope_p3q1;
    wire [15:0]                                         w_hithreshold_p3q1;
    wire [15:0]                                         w_lothreshold_p3q1;
    wire [7:0]                                          w_idleSlope_p3q2;
    wire [7:0]                                          w_sendslope_p3q2;
    wire [15:0]                                         w_hithreshold_p3q2;
    wire [15:0]                                         w_lothreshold_p3q2;
    wire [7:0]                                          w_idleSlope_p3q3;
    wire [7:0]                                          w_sendslope_p3q3;
    wire [15:0]                                         w_hithreshold_p3q3;
    wire [15:0]                                         w_lothreshold_p3q3;
    wire [7:0]                                          w_idleSlope_p3q4;
    wire [7:0]                                          w_sendslope_p3q4;
    wire [15:0]                                         w_hithreshold_p3q4;
    wire [15:0]                                         w_lothreshold_p3q4;
    wire [7:0]                                          w_idleSlope_p3q5;
    wire [7:0]                                          w_sendslope_p3q5;
    wire [15:0]                                         w_hithreshold_p3q5;
    wire [15:0]                                         w_lothreshold_p3q5;
    wire [7:0]                                          w_idleSlope_p3q6;
    wire [7:0]                                          w_sendslope_p3q6;
    wire [15:0]                                         w_hithreshold_p3q6;
    wire [15:0]                                         w_lothreshold_p3q6;
    wire [7:0]                                          w_idleSlope_p3q7;
    wire [7:0]                                          w_sendslope_p3q7;
    wire [15:0]                                         w_hithreshold_p3q7;
    wire [15:0]                                         w_lothreshold_p3q7;
    wire                                                w_qav_en_3;
    wire                                                w_config_vld_3;
    wire [79:0]                                         w_Base_time_3;
	wire												w_Base_time_vld_3;
    wire                                                w_ConfigChange_3;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_3;
    wire [7:0]                                          w_ControlList_len_3;
    wire                                                w_ControlList_vld_3;
    wire [15:0]                                         w_cycle_time_3;
    wire [79:0]                                         w_cycle_time_extension_3;
    wire                                                w_qbv_en_3;
    wire [3:0]                                          w_qos_sch_3;
    wire                                                w_qos_en_3;
    wire [7:0]                                          w_frag_next_tx_3;
    wire                                                w_tx_timeout_3;    
    wire [15:0]                                         w_preempt_success_cnt_3;
    wire                                                w_preempt_active_3;
    wire                                                w_preemptable_frame_3;
    wire [15:0]                                         w_tx_frames_cnt_3;
    wire [15:0]                                         w_tx_fragment_cnt_3;
    wire                                                w_tx_busy_3;
    wire [19:0]                                         w_watchdog_timer_3;
    wire                                                w_watchdog_timer_vld_3;
    wire [7:0]                                          w_min_frag_size_3;
    wire                                                w_min_frag_size_vld_3;
    wire [7:0]                                          w_ipg_timer_3;
    wire                                                w_ipg_timer_vld_3;
    wire                                                w_verify_enabled_3;
    wire                                                w_start_verify_3;
    wire                                                w_clear_verify_3;
    wire [15:0]                                         w_verify_timer_3;
    wire                                                w_verify_timer_vld_3;
    wire [15:0]                                         w_err_verify_cnt_3;
    wire                                                w_preempt_enable_3;
`endif
// MAC4
// MAC4 寄存器信号定义
`ifdef MAC4
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_4;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_4;
    wire [3:0]                                          w_port_1g_interval_num_regs_4;
    wire [3:0]                                          w_port_100m_interval_num_regs_4;
    wire [15:0]                                         w_port_tx_byte_cnt_4;
    wire [15:0]                                         w_port_tx_frame_cnt_4;
    wire [15:0]                                         w_port_diag_state_4;
    wire [7:0]                                          w_idleSlope_p4q0;
    wire [7:0]                                          w_sendslope_p4q0;
    wire [15:0]                                         w_hithreshold_p4q0;
    wire [15:0]                                         w_lothreshold_p4q0;
    wire [7:0]                                          w_idleSlope_p4q1;
    wire [7:0]                                          w_sendslope_p4q1;
    wire [15:0]                                         w_hithreshold_p4q1;
    wire [15:0]                                         w_lothreshold_p4q1;
    wire [7:0]                                          w_idleSlope_p4q2;
    wire [7:0]                                          w_sendslope_p4q2;
    wire [15:0]                                         w_hithreshold_p4q2;
    wire [15:0]                                         w_lothreshold_p4q2;
    wire [7:0]                                          w_idleSlope_p4q3;
    wire [7:0]                                          w_sendslope_p4q3;
    wire [15:0]                                         w_hithreshold_p4q3;
    wire [15:0]                                         w_lothreshold_p4q3;
    wire [7:0]                                          w_idleSlope_p4q4;
    wire [7:0]                                          w_sendslope_p4q4;
    wire [15:0]                                         w_hithreshold_p4q4;
    wire [15:0]                                         w_lothreshold_p4q4;
    wire [7:0]                                          w_idleSlope_p4q5;
    wire [7:0]                                          w_sendslope_p4q5;
    wire [15:0]                                         w_hithreshold_p4q5;
    wire [15:0]                                         w_lothreshold_p4q5;
    wire [7:0]                                          w_idleSlope_p4q6;
    wire [7:0]                                          w_sendslope_p4q6;
    wire [15:0]                                         w_hithreshold_p4q6;
    wire [15:0]                                         w_lothreshold_p4q6;
    wire [7:0]                                          w_idleSlope_p4q7;
    wire [7:0]                                          w_sendslope_p4q7;
    wire [15:0]                                         w_hithreshold_p4q7;
    wire [15:0]                                         w_lothreshold_p4q7;
    wire                                                w_qav_en_4;
    wire                                                w_config_vld_4;
    wire [79:0]                                         w_Base_time_4;
	wire												w_Base_time_vld_4;
    wire                                                w_ConfigChange_4;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_4;
    wire [7:0]                                          w_ControlList_len_4;
    wire                                                w_ControlList_vld_4;
    wire [15:0]                                         w_cycle_time_4;
    wire [79:0]                                         w_cycle_time_extension_4;
    wire                                                w_qbv_en_4;
    wire [3:0]                                          w_qos_sch_4;
    wire                                                w_qos_en_4;
    wire [7:0]                                          w_frag_next_tx_4;
    wire                                                w_tx_timeout_4;    
    wire [15:0]                                         w_preempt_success_cnt_4;
    wire                                                w_preempt_active_4;
    wire                                                w_preemptable_frame_4;
    wire [15:0]                                         w_tx_frames_cnt_4;
    wire [15:0]                                         w_tx_fragment_cnt_4;
    wire                                                w_tx_busy_4;
    wire [19:0]                                         w_watchdog_timer_4;
    wire                                                w_watchdog_timer_vld_4;
    wire [7:0]                                          w_min_frag_size_4;
    wire                                                w_min_frag_size_vld_4;
    wire [7:0]                                          w_ipg_timer_4;
    wire                                                w_ipg_timer_vld_4;
    wire                                                w_verify_enabled_4;
    wire                                                w_start_verify_4;
    wire                                                w_clear_verify_4;
    wire [15:0]                                         w_verify_timer_4;
    wire                                                w_verify_timer_vld_4;
    wire [15:0]                                         w_err_verify_cnt_4;
    wire                                                w_preempt_enable_4;
`endif
// MAC5
// MAC5 寄存器信号定义
`ifdef MAC5
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_5;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_5;
    wire [3:0]                                          w_port_1g_interval_num_regs_5;
    wire [3:0]                                          w_port_100m_interval_num_regs_5;
    wire [15:0]                                         w_port_tx_byte_cnt_5;
    wire [15:0]                                         w_port_tx_frame_cnt_5;
    wire [15:0]                                         w_port_diag_state_5;
    wire [7:0]                                          w_idleSlope_p5q0;
    wire [7:0]                                          w_sendslope_p5q0;
    wire [15:0]                                         w_hithreshold_p5q0;
    wire [15:0]                                         w_lothreshold_p5q0;
    wire [7:0]                                          w_idleSlope_p5q1;
    wire [7:0]                                          w_sendslope_p5q1;
    wire [15:0]                                         w_hithreshold_p5q1;
    wire [15:0]                                         w_lothreshold_p5q1;
    wire [7:0]                                          w_idleSlope_p5q2;
    wire [7:0]                                          w_sendslope_p5q2;
    wire [15:0]                                         w_hithreshold_p5q2;
    wire [15:0]                                         w_lothreshold_p5q2;
    wire [7:0]                                          w_idleSlope_p5q3;
    wire [7:0]                                          w_sendslope_p5q3;
    wire [15:0]                                         w_hithreshold_p5q3;
    wire [15:0]                                         w_lothreshold_p5q3;
    wire [7:0]                                          w_idleSlope_p5q4;
    wire [7:0]                                          w_sendslope_p5q4;
    wire [15:0]                                         w_hithreshold_p5q4;
    wire [15:0]                                         w_lothreshold_p5q4;
    wire [7:0]                                          w_idleSlope_p5q5;
    wire [7:0]                                          w_sendslope_p5q5;
    wire [15:0]                                         w_hithreshold_p5q5;
    wire [15:0]                                         w_lothreshold_p5q5;
    wire [7:0]                                          w_idleSlope_p5q6;
    wire [7:0]                                          w_sendslope_p5q6;
    wire [15:0]                                         w_hithreshold_p5q6;
    wire [15:0]                                         w_lothreshold_p5q6;
    wire [7:0]                                          w_idleSlope_p5q7;
    wire [7:0]                                          w_sendslope_p5q7;
    wire [15:0]                                         w_hithreshold_p5q7;
    wire [15:0]                                         w_lothreshold_p5q7;
    wire                                                w_qav_en_5;
    wire                                                w_config_vld_5;
    wire [79:0]                                         w_Base_time_5;
	wire												w_Base_time_vld_5;
    wire                                                w_ConfigChange_5;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_5;
    wire [7:0]                                          w_ControlList_len_5;
    wire                                                w_ControlList_vld_5;
    wire [15:0]                                         w_cycle_time_5;
    wire [79:0]                                         w_cycle_time_extension_5;
    wire                                                w_qbv_en_5;
    wire [3:0]                                          w_qos_sch_5;
    wire                                                w_qos_en_5;
    wire [7:0]                                          w_frag_next_tx_5;
    wire                                                w_tx_timeout_5;    
    wire [15:0]                                         w_preempt_success_cnt_5;
    wire                                                w_preempt_active_5;
    wire                                                w_preemptable_frame_5;
    wire [15:0]                                         w_tx_frames_cnt_5;
    wire [15:0]                                         w_tx_fragment_cnt_5;
    wire                                                w_tx_busy_5;
    wire [19:0]                                         w_watchdog_timer_5;
    wire                                                w_watchdog_timer_vld_5;
    wire [7:0]                                          w_min_frag_size_5;
    wire                                                w_min_frag_size_vld_5;
    wire [7:0]                                          w_ipg_timer_5;
    wire                                                w_ipg_timer_vld_5;
    wire                                                w_verify_enabled_5;
    wire                                                w_start_verify_5;
    wire                                                w_clear_verify_5;
    wire [15:0]                                         w_verify_timer_5;
    wire                                                w_verify_timer_vld_5;
    wire [15:0]                                         w_err_verify_cnt_5;
    wire                                                w_preempt_enable_5;
`endif
// MAC6
// MAC6 寄存器信号定义
`ifdef MAC6
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_6;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_6;
    wire [3:0]                                          w_port_1g_interval_num_regs_6;
    wire [3:0]                                          w_port_100m_interval_num_regs_6;
    wire [15:0]                                         w_port_tx_byte_cnt_6;
    wire [15:0]                                         w_port_tx_frame_cnt_6;
    wire [15:0]                                         w_port_diag_state_6;
    wire [7:0]                                          w_idleSlope_p6q0;
    wire [7:0]                                          w_sendslope_p6q0;
    wire [15:0]                                         w_hithreshold_p6q0;
    wire [15:0]                                         w_lothreshold_p6q0;
    wire [7:0]                                          w_idleSlope_p6q1;
    wire [7:0]                                          w_sendslope_p6q1;
    wire [15:0]                                         w_hithreshold_p6q1;
    wire [15:0]                                         w_lothreshold_p6q1;
    wire [7:0]                                          w_idleSlope_p6q2;
    wire [7:0]                                          w_sendslope_p6q2;
    wire [15:0]                                         w_hithreshold_p6q2;
    wire [15:0]                                         w_lothreshold_p6q2;
    wire [7:0]                                          w_idleSlope_p6q3;
    wire [7:0]                                          w_sendslope_p6q3;
    wire [15:0]                                         w_hithreshold_p6q3;
    wire [15:0]                                         w_lothreshold_p6q3;
    wire [7:0]                                          w_idleSlope_p6q4;
    wire [7:0]                                          w_sendslope_p6q4;
    wire [15:0]                                         w_hithreshold_p6q4;
    wire [15:0]                                         w_lothreshold_p6q4;
    wire [7:0]                                          w_idleSlope_p6q5;
    wire [7:0]                                          w_sendslope_p6q5;
    wire [15:0]                                         w_hithreshold_p6q5;
    wire [15:0]                                         w_lothreshold_p6q5;
    wire [7:0]                                          w_idleSlope_p6q6;
    wire [7:0]                                          w_sendslope_p6q6;
    wire [15:0]                                         w_hithreshold_p6q6;
    wire [15:0]                                         w_lothreshold_p6q6;
    wire [7:0]                                          w_idleSlope_p6q7;
    wire [7:0]                                          w_sendslope_p6q7;
    wire [15:0]                                         w_hithreshold_p6q7;
    wire [15:0]                                         w_lothreshold_p6q7;
    wire                                                w_qav_en_6;
    wire                                                w_config_vld_6;
    wire [79:0]                                         w_Base_time_6;
	wire												w_Base_time_vld_6;
    wire                                                w_ConfigChange_6;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_6;
    wire [7:0]                                          w_ControlList_len_6;
    wire                                                w_ControlList_vld_6;
    wire [15:0]                                         w_cycle_time_6;
    wire [79:0]                                         w_cycle_time_extension_6;
    wire                                                w_qbv_en_6;
    wire [3:0]                                          w_qos_sch_6;
    wire                                                w_qos_en_6;
    wire [7:0]                                          w_frag_next_tx_6;
    wire                                                w_tx_timeout_6;    
    wire [15:0]                                         w_preempt_success_cnt_6;
    wire                                                w_preempt_active_6;
    wire                                                w_preemptable_frame_6;
    wire [15:0]                                         w_tx_frames_cnt_6;
    wire [15:0]                                         w_tx_fragment_cnt_6;
    wire                                                w_tx_busy_6;
    wire [19:0]                                         w_watchdog_timer_6;
    wire                                                w_watchdog_timer_vld_6;
    wire [7:0]                                          w_min_frag_size_6;
    wire                                                w_min_frag_size_vld_6;
    wire [7:0]                                          w_ipg_timer_6;
    wire                                                w_ipg_timer_vld_6;
    wire                                                w_verify_enabled_6;
    wire                                                w_start_verify_6;
    wire                                                w_clear_verify_6;
    wire [15:0]                                         w_verify_timer_6;
    wire                                                w_verify_timer_vld_6;
    wire [15:0]                                         w_err_verify_cnt_6;
    wire                                                w_preempt_enable_6;
`endif
// MAC7
// MAC7 寄存器信号定义
`ifdef MAC7
    wire [PORT_NUM-1:0]                                 w_port_txmac_down_regs_7;
    wire [PORT_NUM-1:0]                                 w_store_forward_enable_regs_7;
    wire [3:0]                                          w_port_1g_interval_num_regs_7;
    wire [3:0]                                          w_port_100m_interval_num_regs_7;
    wire [15:0]                                         w_port_tx_byte_cnt_7;
    wire [15:0]                                         w_port_tx_frame_cnt_7;
    wire [15:0]                                         w_port_diag_state_7;
    wire [7:0]                                          w_idleSlope_p7q0;
    wire [7:0]                                          w_sendslope_p7q0;
    wire [15:0]                                         w_hithreshold_p7q0;
    wire [15:0]                                         w_lothreshold_p7q0;
    wire [7:0]                                          w_idleSlope_p7q1;
    wire [7:0]                                          w_sendslope_p7q1;
    wire [15:0]                                         w_hithreshold_p7q1;
    wire [15:0]                                         w_lothreshold_p7q1;
    wire [7:0]                                          w_idleSlope_p7q2;
    wire [7:0]                                          w_sendslope_p7q2;
    wire [15:0]                                         w_hithreshold_p7q2;
    wire [15:0]                                         w_lothreshold_p7q2;
    wire [7:0]                                          w_idleSlope_p7q3;
    wire [7:0]                                          w_sendslope_p7q3;
    wire [15:0]                                         w_hithreshold_p7q3;
    wire [15:0]                                         w_lothreshold_p7q3;
    wire [7:0]                                          w_idleSlope_p7q4;
    wire [7:0]                                          w_sendslope_p7q4;
    wire [15:0]                                         w_hithreshold_p7q4;
    wire [15:0]                                         w_lothreshold_p7q4;
    wire [7:0]                                          w_idleSlope_p7q5;
    wire [7:0]                                          w_sendslope_p7q5;
    wire [15:0]                                         w_hithreshold_p7q5;
    wire [15:0]                                         w_lothreshold_p7q5;
    wire [7:0]                                          w_idleSlope_p7q6;
    wire [7:0]                                          w_sendslope_p7q6;
    wire [15:0]                                         w_hithreshold_p7q6;
    wire [15:0]                                         w_lothreshold_p7q6;
    wire [7:0]                                          w_idleSlope_p7q7;
    wire [7:0]                                          w_sendslope_p7q7;
    wire [15:0]                                         w_hithreshold_p7q7;
    wire [15:0]                                         w_lothreshold_p7q7;
    wire                                                w_qav_en_7;
    wire                                                w_config_vld_7;
    wire [79:0]                                         w_Base_time_7;
	wire												w_Base_time_vld_7;
    wire                                                w_ConfigChange_7;
    wire [PORT_FIFO_PRI_NUM:0]                          w_ControlList_7;
    wire [7:0]                                          w_ControlList_len_7;
    wire                                                w_ControlList_vld_7;
    wire [15:0]                                         w_cycle_time_7;
    wire [79:0]                                         w_cycle_time_extension_7;
    wire                                                w_qbv_en_7;
    wire [3:0]                                          w_qos_sch_7;
    wire                                                w_qos_en_7;
    wire [7:0]                                          w_frag_next_tx_7;
    wire                                                w_tx_timeout_7;    
    wire [15:0]                                         w_preempt_success_cnt_7;
    wire                                                w_preempt_active_7;
    wire                                                w_preemptable_frame_7;
    wire [15:0]                                         w_tx_frames_cnt_7;
    wire [15:0]                                         w_tx_fragment_cnt_7;
    wire                                                w_tx_busy_7;
    wire [19:0]                                         w_watchdog_timer_7;
    wire                                                w_watchdog_timer_vld_7;
    wire [7:0]                                          w_min_frag_size_7;
    wire                                                w_min_frag_size_vld_7;
    wire [7:0]                                          w_ipg_timer_7;
    wire                                                w_ipg_timer_vld_7;
    wire                                                w_verify_enabled_7;
    wire                                                w_start_verify_7;
    wire                                                w_clear_verify_7;
    wire [15:0]                                         w_verify_timer_7;
    wire                                                w_verify_timer_vld_7;
    wire [15:0]                                         w_err_verify_cnt_7;
    wire                                                w_preempt_enable_7;
`endif

`ifdef CPU_MAC
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac0_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互

        .i_fifoc_empty                      (i_mac0_fifoc_empty),    
        .o_scheduing_rst                    (o_mac0_scheduing_rst),
        .o_scheduing_rst_vld                (o_mac0_scheduing_rst_vld),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据

        .i_pmac_tx_axis_data                (i_pmac0_tx_axis_data), 
        .i_pmac_tx_axis_user                (i_pmac0_tx_axis_user), 
        .i_pmac_tx_axis_keep                (i_pmac0_tx_axis_keep), 
        .i_pmac_tx_axis_last                (i_pmac0_tx_axis_last), 
        .i_pmac_tx_axis_valid               (i_pmac0_tx_axis_valid), 
        .i_pmac_ethertype                   (i_pmac0_ethertype), 
        .o_pmac_tx_axis_ready               (o_pmac0_tx_axis_ready),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac0_tx_axis_data), 
        .i_emac_tx_axis_user                (i_emac0_tx_axis_user), 
        .i_emac_tx_axis_keep                (i_emac0_tx_axis_keep), 
        .i_emac_tx_axis_last                (i_emac0_tx_axis_last), 
        .i_emac_tx_axis_valid               (i_emac0_tx_axis_valid), 
        .i_emac_ethertype                   (i_emac0_ethertype),
        .o_emac_tx_axis_ready               (o_emac0_tx_axis_ready),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_0)  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_0)  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_0)  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_0)  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_0) ,  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_0) ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_0) ,  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/

        .o_frag_next_tx                                 (w_frag_next_tx_0),
        .o_tx_timeout                                   (w_tx_timeout_0),
        .o_preempt_success_cnt                          (w_preempt_success_cnt_0),
        .o_preempt_active                               (w_preempt_active_0),
        .o_preemptable_frame                            (w_preemptable_frame_0),
        .o_tx_frames_cnt                                (w_tx_frames_cnt_0),
        .o_tx_fragment_cnt                              (w_tx_fragment_cnt_0),
        .o_tx_busy                                      (w_tx_busy_0),
        
        .i_watchdog_timer                               (w_watchdog_timer_0),
        .i_watchdog_timer_vld                           (w_watchdog_timer_vld_0),
        .i_min_frag_size                                (w_min_frag_size_0),
        .i_min_frag_size_vld                            (w_min_frag_size_vld_0),
        .i_ipg_timer                                    (w_ipg_timer_0),
        .i_ipg_timer_vld                                (w_ipg_timer_vld_0),
                            
        .i_verify_enabled                               (w_verify_enabled_0),
        .i_start_verify                                 (w_start_verify_0),
        .i_clear_verify                                 (w_clear_verify_0),
        .o_verify_succ                                  (),
        .o_verify_succ_val                              (),
        .i_verify_timer                                 (w_verify_timer_0),
        .i_verify_timer_vld                             (w_verify_timer_vld_0),
        .o_err_verify_cnt                               (w_err_verify_cnt_0),
        .o_preempt_enable                               (w_preempt_enable_0),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/

        .i_idleSlope_q0         (w_idleSlope_p0q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p0q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p0q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p0q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p0q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p0q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p0q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p0q7)				 			,
        .i_sendslope_q0         (w_sendslope_p0q0)				 			,
        .i_sendslope_q1         (w_sendslope_p0q1)				 			,
        .i_sendslope_q2         (w_sendslope_p0q2)				 			,
        .i_sendslope_q3         (w_sendslope_p0q3)				 			,
        .i_sendslope_q4         (w_sendslope_p0q4)				 			,
        .i_sendslope_q5         (w_sendslope_p0q5)				 			,
        .i_sendslope_q6         (w_sendslope_p0q6)				 			,
        .i_sendslope_q7         (w_sendslope_p0q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p0q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p0q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p0q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p0q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p0q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p0q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p0q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p0q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p0q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p0q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p0q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p0q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p0q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p0q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p0q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p0q7)				 			,

        .i_qav_en               (w_qav_en_0)				 			        ,
        .i_config_vld           (w_config_vld_0)            ,
                                                
        .i_Base_time            (w_Base_time_0)             , 
		.i_Base_time_vld		(w_Base_time_vld_0	)		,
        .i_ConfigChange         (w_ConfigChange_0)          ,
        .i_ControlList          (w_ControlList_0)           ,  
        .i_ControlList_len      (w_ControlList_len_0)       ,  
        .i_ControlList_vld      (w_ControlList_vld_0)       ,  
        .i_cycle_time           (w_cycle_time_0)            ,  
        .i_cycle_time_extension (w_cycle_time_extension_0)  , 
        .i_qbv_en               (w_qbv_en_0)                ,  
                                                
        .i_qos_sch              (w_qos_sch_0)               ,
        .i_qos_en               (w_qos_en_0)                , 

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac0_axi_data) ,
        .o_mac_axi_data_keep                (o_mac0_axi_data_keep) ,
        .o_mac_axi_data_valid               (o_mac0_axi_data_valid) ,
        .o_mac_axi_data_user                (o_mac0_axi_data_user) ,
        .i_mac_axi_data_ready               (i_mac0_axi_data_ready) ,
        .o_mac_axi_data_last                (o_mac0_axi_data_last) ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac0_time_irq) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac0_frame_seq) , // 帧序列号
        .o_timestamp_addr                   (o_mac0_timestamp_addr)   // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC1
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac1_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac1_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac1_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac1_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac1_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac1_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac1_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac1_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac1_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac1_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac1_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac1_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac1_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac1_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac1_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac1_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac1_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac1_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_1           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_1      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_1      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_1    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_1               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_1              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_1                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_1                   ),
        .o_tx_timeout                       (w_tx_timeout_1                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_1            ),
        .o_preempt_active                   (w_preempt_active_1                 ),
        .o_preemptable_frame                (w_preemptable_frame_1              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_1                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_1                ),
        .o_tx_busy                          (w_tx_busy_1                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_1                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_1             ),
        .i_min_frag_size                    (w_min_frag_size_1                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_1              ),
        .i_ipg_timer                        (w_ipg_timer_1                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_1                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_1                 ),
        .i_start_verify                     (w_start_verify_1                   ),
        .i_clear_verify                     (w_clear_verify_1                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_1                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_1               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_1                 ),
        .o_preempt_enable                   (w_preempt_enable_1                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p1q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p1q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p1q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p1q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p1q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p1q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p1q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p1q7)				 			,
        .i_sendslope_q0         (w_sendslope_p1q0)				 			,
        .i_sendslope_q1         (w_sendslope_p1q1)				 			,
        .i_sendslope_q2         (w_sendslope_p1q2)				 			,
        .i_sendslope_q3         (w_sendslope_p1q3)				 			,
        .i_sendslope_q4         (w_sendslope_p1q4)				 			,
        .i_sendslope_q5         (w_sendslope_p1q5)				 			,
        .i_sendslope_q6         (w_sendslope_p1q6)				 			,
        .i_sendslope_q7         (w_sendslope_p1q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p1q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p1q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p1q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p1q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p1q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p1q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p1q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p1q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p1q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p1q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p1q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p1q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p1q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p1q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p1q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p1q7)				 			,
        .i_qav_en                           (w_qav_en_1                         ),
        .i_config_vld                       (w_config_vld_1                     ),
                                                
        .i_Base_time                        (w_Base_time_1                      ), 
		.i_Base_time_vld					(w_Base_time_vld_1					),
        .i_ConfigChange                     (w_ConfigChange_1                   ),
        .i_ControlList                      (w_ControlList_1                    ),  
        .i_ControlList_len                  (w_ControlList_len_1                ),  
        .i_ControlList_vld                  (w_ControlList_vld_1                ),  
        .i_cycle_time                       (w_cycle_time_1                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_1           ), 
        .i_qbv_en                           (w_qbv_en_1                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_1                        ),
        .i_qos_en                           (w_qos_en_1                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac1_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac1_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac1_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac1_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac1_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac1_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac1_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac1_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac1_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC2
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac2_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac2_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac2_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac2_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac2_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac2_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac2_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac2_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac2_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac2_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac2_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac2_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac2_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac2_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac2_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac2_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac2_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac2_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_2           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_2      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_2      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_2    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_2               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_2              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_2                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_2                   ),
        .o_tx_timeout                       (w_tx_timeout_2                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_2            ),
        .o_preempt_active                   (w_preempt_active_2                 ),
        .o_preemptable_frame                (w_preemptable_frame_2              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_2                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_2                ),
        .o_tx_busy                          (w_tx_busy_2                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_2                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_2             ),
        .i_min_frag_size                    (w_min_frag_size_2                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_2              ),
        .i_ipg_timer                        (w_ipg_timer_2                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_2                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_2                 ),
        .i_start_verify                     (w_start_verify_2                   ),
        .i_clear_verify                     (w_clear_verify_2                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_2                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_2               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_2                 ),
        .o_preempt_enable                   (w_preempt_enable_2                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p2q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p2q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p2q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p2q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p2q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p2q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p2q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p2q7)				 			,
        .i_sendslope_q0         (w_sendslope_p2q0)				 			,
        .i_sendslope_q1         (w_sendslope_p2q1)				 			,
        .i_sendslope_q2         (w_sendslope_p2q2)				 			,
        .i_sendslope_q3         (w_sendslope_p2q3)				 			,
        .i_sendslope_q4         (w_sendslope_p2q4)				 			,
        .i_sendslope_q5         (w_sendslope_p2q5)				 			,
        .i_sendslope_q6         (w_sendslope_p2q6)				 			,
        .i_sendslope_q7         (w_sendslope_p2q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p2q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p2q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p2q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p2q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p2q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p2q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p2q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p2q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p2q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p2q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p2q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p2q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p2q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p2q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p2q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p2q7)				 			,
        .i_qav_en                           (w_qav_en_2                         ),
        .i_config_vld                       (w_config_vld_2                     ),
                                                
        .i_Base_time                        (w_Base_time_2                      ), 
		.i_Base_time_vld					(w_Base_time_vld_2	)		,
        .i_ConfigChange                     (w_ConfigChange_2                   ),
        .i_ControlList                      (w_ControlList_2                    ),  
        .i_ControlList_len                  (w_ControlList_len_2                ),  
        .i_ControlList_vld                  (w_ControlList_vld_2                ),  
        .i_cycle_time                       (w_cycle_time_2                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_2           ), 
        .i_qbv_en                           (w_qbv_en_2                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_2                        ),
        .i_qos_en                           (w_qos_en_2                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac2_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac2_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac2_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac2_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac2_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac2_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac2_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac2_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac2_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC3
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac3_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac3_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac3_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac3_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac3_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac3_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac3_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac3_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac3_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac3_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac3_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac3_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac3_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac3_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac3_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac3_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac3_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac3_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_3           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_3      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_3      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_3    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_3               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_3              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_3                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_3                   ),
        .o_tx_timeout                       (w_tx_timeout_3                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_3            ),
        .o_preempt_active                   (w_preempt_active_3                 ),
        .o_preemptable_frame                (w_preemptable_frame_3              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_3                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_3                ),
        .o_tx_busy                          (w_tx_busy_3                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_3                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_3             ),
        .i_min_frag_size                    (w_min_frag_size_3                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_3              ),
        .i_ipg_timer                        (w_ipg_timer_3                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_3                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_3                 ),
        .i_start_verify                     (w_start_verify_3                   ),
        .i_clear_verify                     (w_clear_verify_3                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_3                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_3               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_3                 ),
        .o_preempt_enable                   (w_preempt_enable_3                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p3q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p3q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p3q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p3q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p3q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p3q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p3q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p3q7)				 			,
        .i_sendslope_q0         (w_sendslope_p3q0)				 			,
        .i_sendslope_q1         (w_sendslope_p3q1)				 			,
        .i_sendslope_q2         (w_sendslope_p3q2)				 			,
        .i_sendslope_q3         (w_sendslope_p3q3)				 			,
        .i_sendslope_q4         (w_sendslope_p3q4)				 			,
        .i_sendslope_q5         (w_sendslope_p3q5)				 			,
        .i_sendslope_q6         (w_sendslope_p3q6)				 			,
        .i_sendslope_q7         (w_sendslope_p3q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p3q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p3q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p3q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p3q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p3q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p3q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p3q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p3q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p3q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p3q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p3q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p3q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p3q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p3q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p3q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p3q7)				 			,
        .i_qav_en                           (w_qav_en_3                         ),
        .i_config_vld                       (w_config_vld_3                     ),
                                                
        .i_Base_time                        (w_Base_time_3                      ), 
		.i_Base_time_vld					(w_Base_time_vld_3	)		,
        .i_ConfigChange                     (w_ConfigChange_3                   ),
        .i_ControlList                      (w_ControlList_3                    ),  
        .i_ControlList_len                  (w_ControlList_len_3                ),  
        .i_ControlList_vld                  (w_ControlList_vld_3                ),  
        .i_cycle_time                       (w_cycle_time_3                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_3           ), 
        .i_qbv_en                           (w_qbv_en_3                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_3                        ),
        .i_qos_en                           (w_qos_en_3                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac3_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac3_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac3_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac3_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac3_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac3_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac3_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac3_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac3_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC4
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac4_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac4_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac4_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac4_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac4_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac4_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac4_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac4_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac4_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac4_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac4_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac4_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac4_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac4_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac4_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac4_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac4_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac4_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_4           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_4      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_4      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_4    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_4               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_4              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_4                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_4                   ),
        .o_tx_timeout                       (w_tx_timeout_4                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_4            ),
        .o_preempt_active                   (w_preempt_active_4                 ),
        .o_preemptable_frame                (w_preemptable_frame_4              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_4                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_4                ),
        .o_tx_busy                          (w_tx_busy_4                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_4                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_4             ),
        .i_min_frag_size                    (w_min_frag_size_4                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_4              ),
        .i_ipg_timer                        (w_ipg_timer_4                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_4                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_4                 ),
        .i_start_verify                     (w_start_verify_4                   ),
        .i_clear_verify                     (w_clear_verify_4                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_4                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_4               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_4                 ),
        .o_preempt_enable                   (w_preempt_enable_4                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p4q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p4q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p4q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p4q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p4q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p4q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p4q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p4q7)				 			,
        .i_sendslope_q0         (w_sendslope_p4q0)				 			,
        .i_sendslope_q1         (w_sendslope_p4q1)				 			,
        .i_sendslope_q2         (w_sendslope_p4q2)				 			,
        .i_sendslope_q3         (w_sendslope_p4q3)				 			,
        .i_sendslope_q4         (w_sendslope_p4q4)				 			,
        .i_sendslope_q5         (w_sendslope_p4q5)				 			,
        .i_sendslope_q6         (w_sendslope_p4q6)				 			,
        .i_sendslope_q7         (w_sendslope_p4q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p4q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p4q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p4q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p4q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p4q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p4q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p4q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p4q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p4q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p4q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p4q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p4q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p4q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p4q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p4q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p4q7)				 			,
        .i_qav_en                           (w_qav_en_4                         ),
        .i_config_vld                       (w_config_vld_4                     ),
                                                
        .i_Base_time                        (w_Base_time_4                      ),
		.i_Base_time_vld					(w_Base_time_vld_4	)		,		
        .i_ConfigChange                     (w_ConfigChange_4                   ),
        .i_ControlList                      (w_ControlList_4                    ),  
        .i_ControlList_len                  (w_ControlList_len_4                ),  
        .i_ControlList_vld                  (w_ControlList_vld_4                ),  
        .i_cycle_time                       (w_cycle_time_4                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_4           ), 
        .i_qbv_en                           (w_qbv_en_4                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_4                        ),
        .i_qos_en                           (w_qos_en_4                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac4_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac4_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac4_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac4_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac4_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac4_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac4_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac4_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac4_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC5
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac5_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac5_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac5_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac5_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac5_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac5_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac5_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac5_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac5_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac5_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac5_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac5_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac5_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac5_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac5_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac5_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac5_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac5_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_5           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_5      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_5      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_5    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_5               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_5              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_5                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_5                   ),
        .o_tx_timeout                       (w_tx_timeout_5                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_5            ),
        .o_preempt_active                   (w_preempt_active_5                 ),
        .o_preemptable_frame                (w_preemptable_frame_5              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_5                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_5                ),
        .o_tx_busy                          (w_tx_busy_5                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_5                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_5             ),
        .i_min_frag_size                    (w_min_frag_size_5                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_5              ),
        .i_ipg_timer                        (w_ipg_timer_5                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_5                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_5                 ),
        .i_start_verify                     (w_start_verify_5                   ),
        .i_clear_verify                     (w_clear_verify_5                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_5                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_5               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_5                 ),
        .o_preempt_enable                   (w_preempt_enable_5                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p5q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p5q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p5q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p5q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p5q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p5q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p5q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p5q7)				 			,
        .i_sendslope_q0         (w_sendslope_p5q0)				 			,
        .i_sendslope_q1         (w_sendslope_p5q1)				 			,
        .i_sendslope_q2         (w_sendslope_p5q2)				 			,
        .i_sendslope_q3         (w_sendslope_p5q3)				 			,
        .i_sendslope_q4         (w_sendslope_p5q4)				 			,
        .i_sendslope_q5         (w_sendslope_p5q5)				 			,
        .i_sendslope_q6         (w_sendslope_p5q6)				 			,
        .i_sendslope_q7         (w_sendslope_p5q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p5q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p5q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p5q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p5q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p5q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p5q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p5q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p5q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p5q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p5q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p5q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p5q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p5q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p5q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p5q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p5q7)				 			,
        .i_qav_en                           (w_qav_en_5                         ),
        .i_config_vld                       (w_config_vld_5                     ),
                                                
        .i_Base_time                        (w_Base_time_5                      ), 
		.i_Base_time_vld					(w_Base_time_vld_5	)		,
        .i_ConfigChange                     (w_ConfigChange_5                   ),
        .i_ControlList                      (w_ControlList_5                    ),  
        .i_ControlList_len                  (w_ControlList_len_5                ),  
        .i_ControlList_vld                  (w_ControlList_vld_5                ),  
        .i_cycle_time                       (w_cycle_time_5                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_5           ), 
        .i_qbv_en                           (w_qbv_en_5                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_5                        ),
        .i_qos_en                           (w_qos_en_5                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac5_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac5_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac5_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac5_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac5_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac5_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac5_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac5_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac5_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC6
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac6_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac6_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac6_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac6_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac6_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac6_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac6_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac6_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac6_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac6_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac6_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac6_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac6_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac6_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac6_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac6_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac6_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac6_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_6           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_6      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_6      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_6    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_6               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_6              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_6                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_6                   ),
        .o_tx_timeout                       (w_tx_timeout_6                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_6            ),
        .o_preempt_active                   (w_preempt_active_6                 ),
        .o_preemptable_frame                (w_preemptable_frame_6              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_6                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_6                ),
        .o_tx_busy                          (w_tx_busy_6                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_6                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_6             ),
        .i_min_frag_size                    (w_min_frag_size_6                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_6              ),
        .i_ipg_timer                        (w_ipg_timer_6                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_6                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_6                 ),
        .i_start_verify                     (w_start_verify_6                   ),
        .i_clear_verify                     (w_clear_verify_6                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_6                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_6               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_6                 ),
        .o_preempt_enable                   (w_preempt_enable_6                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p6q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p6q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p6q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p6q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p6q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p6q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p6q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p6q7)				 			,
        .i_sendslope_q0         (w_sendslope_p6q0)				 			,
        .i_sendslope_q1         (w_sendslope_p6q1)				 			,
        .i_sendslope_q2         (w_sendslope_p6q2)				 			,
        .i_sendslope_q3         (w_sendslope_p6q3)				 			,
        .i_sendslope_q4         (w_sendslope_p6q4)				 			,
        .i_sendslope_q5         (w_sendslope_p6q5)				 			,
        .i_sendslope_q6         (w_sendslope_p6q6)				 			,
        .i_sendslope_q7         (w_sendslope_p6q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p6q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p6q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p6q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p6q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p6q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p6q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p6q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p6q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p6q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p6q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p6q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p6q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p6q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p6q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p6q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p6q7)				 			,
        .i_qav_en                           (w_qav_en_6                         ),
        .i_config_vld                       (w_config_vld_6                     ),
                                                
        .i_Base_time                        (w_Base_time_6                      ), 
		.i_Base_time_vld					(w_Base_time_vld_6	)		,
        .i_ConfigChange                     (w_ConfigChange_6                   ),
        .i_ControlList                      (w_ControlList_6                    ),  
        .i_ControlList_len                  (w_ControlList_len_6                ),  
        .i_ControlList_vld                  (w_ControlList_vld_6                ),  
        .i_cycle_time                       (w_cycle_time_6                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_6           ), 
        .i_qbv_en                           (w_qbv_en_6                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_6                        ),
        .i_qos_en                           (w_qos_en_6                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac6_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac6_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac6_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac6_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac6_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac6_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac6_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac6_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac6_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC7
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流(METADATA)的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac7_port_mng_inst(
        .i_clk                              (i_clk                     ),   // 250MHz
        .i_rst                              (i_rst                     ),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (i_mac7_fifoc_empty        ),    
        .o_scheduing_rst                    (o_mac7_scheduing_rst      ),
        .o_scheduing_rst_vld                (o_mac7_scheduing_rst_vld  ),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (i_pmac7_tx_axis_data      ), 
        .i_pmac_tx_axis_user                (i_pmac7_tx_axis_user      ), 
        .i_pmac_tx_axis_keep                (i_pmac7_tx_axis_keep      ), 
        .i_pmac_tx_axis_last                (i_pmac7_tx_axis_last      ), 
        .i_pmac_tx_axis_valid               (i_pmac7_tx_axis_valid     ), 
        .i_pmac_ethertype                   (i_pmac7_ethertype         ), 
        .o_pmac_tx_axis_ready               (o_pmac7_tx_axis_ready     ),
        //emac通道数据              
        .i_emac_tx_axis_data                (i_emac7_tx_axis_data      ), 
        .i_emac_tx_axis_user                (i_emac7_tx_axis_user      ), 
        .i_emac_tx_axis_keep                (i_emac7_tx_axis_keep      ), 
        .i_emac_tx_axis_last                (i_emac7_tx_axis_last      ), 
        .i_emac_tx_axis_valid               (i_emac7_tx_axis_valid     ), 
        .i_emac_ethertype                   (i_emac7_ethertype         ),
        .o_emac_tx_axis_ready               (o_emac7_tx_axis_ready     ),
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             (w_port_txmac_down_regs_7           ),  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        (w_store_forward_enable_regs_7      ),  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        (w_port_1g_interval_num_regs_7      ),  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      (w_port_100m_interval_num_regs_7    ),  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 (w_port_tx_byte_cnt_7               ),  // 端口发送字节数
        .o_port_tx_frame_cnt                (w_port_tx_frame_cnt_7              ),  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  (w_port_diag_state_7                ),  // 诊断状态
        /*------------------------------------------ QBU_TX寄存器 -------------------------------------------*/
        .o_frag_next_tx                     (w_frag_next_tx_7                   ),
        .o_tx_timeout                       (w_tx_timeout_7                     ),
        .o_preempt_success_cnt              (w_preempt_success_cnt_7            ),
        .o_preempt_active                   (w_preempt_active_7                 ),
        .o_preemptable_frame                (w_preemptable_frame_7              ),
        .o_tx_frames_cnt                    (w_tx_frames_cnt_7                  ),
        .o_tx_fragment_cnt                  (w_tx_fragment_cnt_7                ),
        .o_tx_busy                          (w_tx_busy_7                        ),
        
        .i_watchdog_timer                   (w_watchdog_timer_7                 ),
        .i_watchdog_timer_vld               (w_watchdog_timer_vld_7             ),
        .i_min_frag_size                    (w_min_frag_size_7                  ),
        .i_min_frag_size_vld                (w_min_frag_size_vld_7              ),
        .i_ipg_timer                        (w_ipg_timer_7                      ),
        .i_ipg_timer_vld                    (w_ipg_timer_vld_7                  ),
                            
        .i_verify_enabled                   (w_verify_enabled_7                 ),
        .i_start_verify                     (w_start_verify_7                   ),
        .i_clear_verify                     (w_clear_verify_7                   ),
        .o_verify_succ                      (                                   ),
        .o_verify_succ_val                  (                                   ),
        .i_verify_timer                     (w_verify_timer_7                   ),
        .i_verify_timer_vld                 (w_verify_timer_vld_7               ),
        .o_err_verify_cnt                   (w_err_verify_cnt_7                 ),
        .o_preempt_enable                   (w_preempt_enable_7                 ),
        /*----------------------------------------- Schedule寄存器 ------------------------------------------*/
        .i_idleSlope_q0         (w_idleSlope_p7q0)				 			,
        .i_idleSlope_q1         (w_idleSlope_p7q1)				 			,
        .i_idleSlope_q2         (w_idleSlope_p7q2)				 			,
        .i_idleSlope_q3         (w_idleSlope_p7q3)				 			,
        .i_idleSlope_q4         (w_idleSlope_p7q4)				 			,
        .i_idleSlope_q5         (w_idleSlope_p7q5)				 			,
        .i_idleSlope_q6         (w_idleSlope_p7q6)				 			,
        .i_idleSlope_q7         (w_idleSlope_p7q7)				 			,
        .i_sendslope_q0         (w_sendslope_p7q0)				 			,
        .i_sendslope_q1         (w_sendslope_p7q1)				 			,
        .i_sendslope_q2         (w_sendslope_p7q2)				 			,
        .i_sendslope_q3         (w_sendslope_p7q3)				 			,
        .i_sendslope_q4         (w_sendslope_p7q4)				 			,
        .i_sendslope_q5         (w_sendslope_p7q5)				 			,
        .i_sendslope_q6         (w_sendslope_p7q6)				 			,
        .i_sendslope_q7         (w_sendslope_p7q7)				 			,
        .i_hithreshold_q0       (w_hithreshold_p7q0)				 			,
        .i_hithreshold_q1       (w_hithreshold_p7q1)				 			,
        .i_hithreshold_q2       (w_hithreshold_p7q2)				 			,
        .i_hithreshold_q3       (w_hithreshold_p7q3)				 			,
        .i_hithreshold_q4       (w_hithreshold_p7q4)				 			,
        .i_hithreshold_q5       (w_hithreshold_p7q5)				 			,
        .i_hithreshold_q6       (w_hithreshold_p7q6)				 			,
        .i_hithreshold_q7       (w_hithreshold_p7q7)				 			,
        .i_lothreshold_q0       (w_lothreshold_p7q0)				 			,
        .i_lothreshold_q1       (w_lothreshold_p7q1)				 			,
        .i_lothreshold_q2       (w_lothreshold_p7q2)				 			,
        .i_lothreshold_q3       (w_lothreshold_p7q3)				 			,
        .i_lothreshold_q4       (w_lothreshold_p7q4)				 			,
        .i_lothreshold_q5       (w_lothreshold_p7q5)				 			,
        .i_lothreshold_q6       (w_lothreshold_p7q6)				 			,
        .i_lothreshold_q7       (w_lothreshold_p7q7)				 			,
        .i_qav_en                           (w_qav_en_7                         ),
        .i_config_vld                       (w_config_vld_7                     ),
                                                
        .i_Base_time                        (w_Base_time_7                      ), 
		.i_Base_time_vld					(w_Base_time_vld_7	)		,
        .i_ConfigChange                     (w_ConfigChange_7                   ),
        .i_ControlList                      (w_ControlList_7                    ),  
        .i_ControlList_len                  (w_ControlList_len_7                ),  
        .i_ControlList_vld                  (w_ControlList_vld_7                ),  
        .i_cycle_time                       (w_cycle_time_7                     ),  
        .i_cycle_time_extension             (w_cycle_time_extension_7           ), 
        .i_qbv_en                           (w_qbv_en_7                         ),  
                                                
        .i_qos_sch                          (w_qos_sch_7                        ),
        .i_qos_en                           (w_qos_en_7                         ), 
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     (o_mac7_axi_data                    ),
        .o_mac_axi_data_keep                (o_mac7_axi_data_keep               ),
        .o_mac_axi_data_valid               (o_mac7_axi_data_valid              ),
        .o_mac_axi_data_user                (o_mac7_axi_data_user               ),
        .i_mac_axi_data_ready               (i_mac7_axi_data_ready              ),
        .o_mac_axi_data_last                (o_mac7_axi_data_last               ),
        // 报文时间打时间戳 
        .o_mac_time_irq                     (o_mac7_time_irq                    ), // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac7_frame_seq                   ), // 帧序列号
        .o_timestamp_addr                   (o_mac7_timestamp_addr              )  // 打时间戳存储的 RAM 地址
    );
`endif

txmac_reg #(
    .PORT_NUM                           (PORT_NUM                  ),
    .REG_ADDR_BUS_WIDTH                 (REG_ADDR_BUS_WIDTH        ),
    .REG_DATA_BUS_WIDTH                 (REG_DATA_BUS_WIDTH        )
) txmac_reg_inst (
    .i_clk                              (i_clk                     ),
    .i_rst                              (i_rst                     ),
    `ifdef CPU_MAC   
        // MAC0 寄存器信号
        .o_port_txmac_down_regs_0           (w_port_txmac_down_regs_0           ),
        .o_store_forward_enable_regs_0      (w_store_forward_enable_regs_0      ),
        .o_port_1g_interval_num_regs_0      (w_port_1g_interval_num_regs_0      ),
        .o_port_100m_interval_num_regs_0    (w_port_100m_interval_num_regs_0    ),
        .i_port_tx_byte_cnt_0               (w_port_tx_byte_cnt_0               ),
        .i_port_tx_frame_cnt_0              (w_port_tx_frame_cnt_0              ),
        .i_port_diag_state_0                (w_port_diag_state_0                ),
        
        .o_idleSlope_p0q0                   (w_idleSlope_p0q0                   ),
        .o_sendslope_p0q0                   (w_sendslope_p0q0                   ),
        .o_hithreshold_p0q0                 (w_hithreshold_p0q0                   ),
        .o_lothreshold_p0q0                 (w_lothreshold_p0q0                   ),

        .o_idleSlope_p0q1                   (w_idleSlope_p0q1                   ),
        .o_sendslope_p0q1                   (w_sendslope_p0q1                   ),
        .o_hithreshold_p0q1                 (w_hithreshold_p0q1                   ),
        .o_lothreshold_p0q1                 (w_lothreshold_p0q1                   ),

        .o_idleSlope_p0q2                   (w_idleSlope_p0q2                   ),
        .o_sendslope_p0q2                   (w_sendslope_p0q2                   ),
        .o_hithreshold_p0q2                 (w_hithreshold_p0q2                   ),
        .o_lothreshold_p0q2                 (w_lothreshold_p0q2                   ),

        .o_idleSlope_p0q3                   (w_idleSlope_p0q3                   ),
        .o_sendslope_p0q3                   (w_sendslope_p0q3                   ),
        .o_hithreshold_p0q3                 (w_hithreshold_p0q3                   ),
        .o_lothreshold_p0q3                 (w_lothreshold_p0q3                   ),

        .o_idleSlope_p0q4                   (w_idleSlope_p0q4                   ),
        .o_sendslope_p0q4                   (w_sendslope_p0q4                   ),
        .o_hithreshold_p0q4                 (w_hithreshold_p0q4                   ),
        .o_lothreshold_p0q4                 (w_lothreshold_p0q4                   ),

        .o_idleSlope_p0q5                   (w_idleSlope_p0q5                   ),
        .o_sendslope_p0q5                   (w_sendslope_p0q5                   ),
        .o_hithreshold_p0q5                 (w_hithreshold_p0q5                   ),
        .o_lothreshold_p0q5                 (w_lothreshold_p0q5                   ),

        .o_idleSlope_p0q6                   (w_idleSlope_p0q6                   ),
        .o_sendslope_p0q6                   (w_sendslope_p0q6                   ),
        .o_hithreshold_p0q6                 (w_hithreshold_p0q6                   ),
        .o_lothreshold_p0q6                 (w_lothreshold_p0q6                   ),

        .o_idleSlope_p0q7                   (w_idleSlope_p0q7                   ),
        .o_sendslope_p0q7                   (w_sendslope_p0q7                   ),
        .o_hithreshold_p0q7                 (w_hithreshold_p0q7                   ),
        .o_lothreshold_p0q7                 (w_lothreshold_p0q7                   ),

        .o_qav_en_0                         (w_qav_en_0                         ),
        .o_config_vld_0                     (w_config_vld_0                     ),
        .o_Base_time_0                      (w_Base_time_0                      ),
		.o_Base_time_vld_0					(w_Base_time_vld_0					),
        .o_ConfigChange_0                   (w_ConfigChange_0                   ),
        .o_ControlList_0                    (w_ControlList_0                    ),
        .o_ControlList_len_0                (w_ControlList_len_0                ),
        .o_ControlList_vld_0                (w_ControlList_vld_0                ),
        .o_cycle_time_0                     (w_cycle_time_0                     ),
        .o_cycle_time_extension_0           (w_cycle_time_extension_0           ),
        .o_qbv_en_0                         (w_qbv_en_0                         ),
        .o_qos_sch_0                        (w_qos_sch_0                        ),
        .o_qos_en_0                         (w_qos_en_0                         ),
        .i_frag_next_tx_0                   (w_frag_next_tx_0                   ),
        .i_tx_timeout_0                     (w_tx_timeout_0                     ),
        .i_preempt_success_cnt_0            (w_preempt_success_cnt_0            ),
        .i_preempt_active_0                 (w_preempt_active_0                 ),
        .i_preemptable_frame_0              (w_preemptable_frame_0              ),
        .i_tx_frames_cnt_0                  (w_tx_frames_cnt_0                  ),
        .i_tx_fragment_cnt_0                (w_tx_fragment_cnt_0                ),
        .i_tx_busy_0                        (w_tx_busy_0                        ),
        .o_watchdog_timer_0                 (w_watchdog_timer_0                 ),
        .o_watchdog_timer_vld_0             (w_watchdog_timer_vld_0             ),
        .o_min_frag_size_0                  (w_min_frag_size_0                  ),
        .o_min_frag_size_vld_0              (w_min_frag_size_vld_0              ),
        .o_ipg_timer_0                      (w_ipg_timer_0                      ),
        .o_ipg_timer_vld_0                  (w_ipg_timer_vld_0                  ),
        .o_verify_enabled_0                 (w_verify_enabled_0                 ),
        .o_start_verify_0                   (w_start_verify_0                   ),
        .o_clear_verify_0                   (w_clear_verify_0                   ),
        .o_verify_timer_0                   (w_verify_timer_0                   ),
        .o_verify_timer_vld_0               (w_verify_timer_vld_0               ),
        .i_err_verify_cnt_0                 (w_err_verify_cnt_0                 ),
        .i_preempt_enable_0                 (w_preempt_enable_0                 ),
    `endif
    `ifdef MAC1   
        // MAC1 寄存器信号
        .o_port_txmac_down_regs_1           (w_port_txmac_down_regs_1           ),
        .o_store_forward_enable_regs_1      (w_store_forward_enable_regs_1      ),
        .o_port_1g_interval_num_regs_1      (w_port_1g_interval_num_regs_1      ),
        .o_port_100m_interval_num_regs_1    (w_port_100m_interval_num_regs_1    ),
        .i_port_tx_byte_cnt_1               (w_port_tx_byte_cnt_1               ),
        .i_port_tx_frame_cnt_1              (w_port_tx_frame_cnt_1              ),
        .i_port_diag_state_1                (w_port_diag_state_1                ),

        .o_idleSlope_p1q0                   (w_idleSlope_p1q0                   ),
        .o_sendslope_p1q0                   (w_sendslope_p1q0                   ),
        .o_hithreshold_p1q0                 (w_hithreshold_p1q0                   ),
        .o_lothreshold_p1q0                 (w_lothreshold_p1q0                   ),

        .o_idleSlope_p1q1                   (w_idleSlope_p1q1                   ),
        .o_sendslope_p1q1                   (w_sendslope_p1q1                   ),
        .o_hithreshold_p1q1                 (w_hithreshold_p1q1                   ),
        .o_lothreshold_p1q1                 (w_lothreshold_p1q1                   ),

        .o_idleSlope_p1q2                   (w_idleSlope_p1q2                   ),
        .o_sendslope_p1q2                   (w_sendslope_p1q2                   ),
        .o_hithreshold_p1q2                 (w_hithreshold_p1q2                   ),
        .o_lothreshold_p1q2                 (w_lothreshold_p1q2                   ),

        .o_idleSlope_p1q3                   (w_idleSlope_p1q3                   ),
        .o_sendslope_p1q3                   (w_sendslope_p1q3                   ),
        .o_hithreshold_p1q3                 (w_hithreshold_p1q3                   ),
        .o_lothreshold_p1q3                 (w_lothreshold_p1q3                   ),

        .o_idleSlope_p1q4                   (w_idleSlope_p1q4                   ),
        .o_sendslope_p1q4                   (w_sendslope_p1q4                   ),
        .o_hithreshold_p1q4                 (w_hithreshold_p1q4                   ),
        .o_lothreshold_p1q4                 (w_lothreshold_p1q4                   ),

        .o_idleSlope_p1q5                   (w_idleSlope_p1q5                   ),
        .o_sendslope_p1q5                   (w_sendslope_p1q5                   ),
        .o_hithreshold_p1q5                 (w_hithreshold_p1q5                   ),
        .o_lothreshold_p1q5                 (w_lothreshold_p1q5                   ),

        .o_idleSlope_p1q6                   (w_idleSlope_p1q6                   ),
        .o_sendslope_p1q6                   (w_sendslope_p1q6                   ),
        .o_hithreshold_p1q6                 (w_hithreshold_p1q6                   ),
        .o_lothreshold_p1q6                 (w_lothreshold_p1q6                   ),

        .o_idleSlope_p1q7                   (w_idleSlope_p1q7                   ),
        .o_sendslope_p1q7                   (w_sendslope_p1q7                   ),
        .o_hithreshold_p1q7                 (w_hithreshold_p1q7                   ),
        .o_lothreshold_p1q7                 (w_lothreshold_p1q7                   ),


        .o_qav_en_1                         (w_qav_en_1                         ),
        .o_config_vld_1                     (w_config_vld_1                     ),
        .o_Base_time_1                      (w_Base_time_1                      ),
		.o_Base_time_vld_1					(w_Base_time_vld_1					),
        .o_ConfigChange_1                   (w_ConfigChange_1                   ),
        .o_ControlList_1                    (w_ControlList_1                    ),
        .o_ControlList_len_1                (w_ControlList_len_1                ),
        .o_ControlList_vld_1                (w_ControlList_vld_1                ),
        .o_cycle_time_1                     (w_cycle_time_1                     ),
        .o_cycle_time_extension_1           (w_cycle_time_extension_1           ),
        .o_qbv_en_1                         (w_qbv_en_1                         ),
        .o_qos_sch_1                        (w_qos_sch_1                        ),
        .o_qos_en_1                         (w_qos_en_1                         ),
        .i_frag_next_tx_1                   (w_frag_next_tx_1                   ),
        .i_tx_timeout_1                     (w_tx_timeout_1                     ),
        .i_preempt_success_cnt_1            (w_preempt_success_cnt_1            ),
        .i_preempt_active_1                 (w_preempt_active_1                 ),
        .i_preemptable_frame_1              (w_preemptable_frame_1              ),
        .i_tx_frames_cnt_1                  (w_tx_frames_cnt_1                  ),
        .i_tx_fragment_cnt_1                (w_tx_fragment_cnt_1                ),
        .i_tx_busy_1                        (w_tx_busy_1                        ),
        .o_watchdog_timer_1                 (w_watchdog_timer_1                 ),
        .o_watchdog_timer_vld_1             (w_watchdog_timer_vld_1             ),
        .o_min_frag_size_1                  (w_min_frag_size_1                  ),
        .o_min_frag_size_vld_1              (w_min_frag_size_vld_1              ),
        .o_ipg_timer_1                      (w_ipg_timer_1                      ),
        .o_ipg_timer_vld_1                  (w_ipg_timer_vld_1                  ),
        .o_verify_enabled_1                 (w_verify_enabled_1                 ),
        .o_start_verify_1                   (w_start_verify_1                   ),
        .o_clear_verify_1                   (w_clear_verify_1                   ),
        .o_verify_timer_1                   (w_verify_timer_1                   ),
        .o_verify_timer_vld_1               (w_verify_timer_vld_1               ),
        .i_err_verify_cnt_1                 (w_err_verify_cnt_1                 ),
        .i_preempt_enable_1                 (w_preempt_enable_1                 ),
    `endif
    `ifdef MAC2   
        // MAC2 寄存器信号
        .o_port_txmac_down_regs_2           (w_port_txmac_down_regs_2           ),
        .o_store_forward_enable_regs_2      (w_store_forward_enable_regs_2      ),
        .o_port_1g_interval_num_regs_2      (w_port_1g_interval_num_regs_2      ),
        .o_port_100m_interval_num_regs_2    (w_port_100m_interval_num_regs_2    ),
        .i_port_tx_byte_cnt_2               (w_port_tx_byte_cnt_2               ),
        .i_port_tx_frame_cnt_2              (w_port_tx_frame_cnt_2              ),
        .i_port_diag_state_2                (w_port_diag_state_2                ),
        
        .o_idleSlope_p2q0                   (w_idleSlope_p2q0                   ),
        .o_sendslope_p2q0                   (w_sendslope_p2q0                   ),
        .o_hithreshold_p2q0                 (w_hithreshold_p2q0                   ),
        .o_lothreshold_p2q0                 (w_lothreshold_p2q0                   ),

        .o_idleSlope_p2q1                   (w_idleSlope_p2q1                   ),
        .o_sendslope_p2q1                   (w_sendslope_p2q1                   ),
        .o_hithreshold_p2q1                 (w_hithreshold_p2q1                   ),
        .o_lothreshold_p2q1                 (w_lothreshold_p2q1                   ),

        .o_idleSlope_p2q2                   (w_idleSlope_p2q2                   ),
        .o_sendslope_p2q2                   (w_sendslope_p2q2                   ),
        .o_hithreshold_p2q2                 (w_hithreshold_p2q2                   ),
        .o_lothreshold_p2q2                 (w_lothreshold_p2q2                   ),

        .o_idleSlope_p2q3                   (w_idleSlope_p2q3                   ),
        .o_sendslope_p2q3                   (w_sendslope_p2q3                   ),
        .o_hithreshold_p2q3                 (w_hithreshold_p2q3                   ),
        .o_lothreshold_p2q3                 (w_lothreshold_p2q3                   ),

        .o_idleSlope_p2q4                   (w_idleSlope_p2q4                   ),
        .o_sendslope_p2q4                   (w_sendslope_p2q4                   ),
        .o_hithreshold_p2q4                 (w_hithreshold_p2q4                   ),
        .o_lothreshold_p2q4                 (w_lothreshold_p2q4                   ),

        .o_idleSlope_p2q5                   (w_idleSlope_p2q5                   ),
        .o_sendslope_p2q5                   (w_sendslope_p2q5                   ),
        .o_hithreshold_p2q5                 (w_hithreshold_p2q5                   ),
        .o_lothreshold_p2q5                 (w_lothreshold_p2q5                   ),

        .o_idleSlope_p2q6                   (w_idleSlope_p2q6                   ),
        .o_sendslope_p2q6                   (w_sendslope_p2q6                   ),
        .o_hithreshold_p2q6                 (w_hithreshold_p2q6                   ),
        .o_lothreshold_p2q6                 (w_lothreshold_p2q6                   ),

        .o_idleSlope_p2q7                   (w_idleSlope_p2q7                   ),
        .o_sendslope_p2q7                   (w_sendslope_p2q7                   ),
        .o_hithreshold_p2q7                 (w_hithreshold_p2q7                   ),
        .o_lothreshold_p2q7                 (w_lothreshold_p2q7                   ),

        .o_qav_en_2                         (w_qav_en_2                         ),
        .o_config_vld_2                     (w_config_vld_2                     ),
        .o_Base_time_2                      (w_Base_time_2                      ),
		.o_Base_time_vld_2					(w_Base_time_vld_2					),
        .o_ConfigChange_2                   (w_ConfigChange_2                   ),
        .o_ControlList_2                    (w_ControlList_2                    ),
        .o_ControlList_len_2                (w_ControlList_len_2                ),
        .o_ControlList_vld_2                (w_ControlList_vld_2                ),
        .o_cycle_time_2                     (w_cycle_time_2                     ),
        .o_cycle_time_extension_2           (w_cycle_time_extension_2           ),
        .o_qbv_en_2                         (w_qbv_en_2                         ),
        .o_qos_sch_2                        (w_qos_sch_2                        ),
        .o_qos_en_2                         (w_qos_en_2                         ),
        .i_frag_next_tx_2                   (w_frag_next_tx_2                   ),
        .i_tx_timeout_2                     (w_tx_timeout_2                     ),
        .i_preempt_success_cnt_2            (w_preempt_success_cnt_2            ),
        .i_preempt_active_2                 (w_preempt_active_2                 ),
        .i_preemptable_frame_2              (w_preemptable_frame_2              ),
        .i_tx_frames_cnt_2                  (w_tx_frames_cnt_2                  ),
        .i_tx_fragment_cnt_2                (w_tx_fragment_cnt_2                ),
        .i_tx_busy_2                        (w_tx_busy_2                        ),
        .o_watchdog_timer_2                 (w_watchdog_timer_2                 ),
        .o_watchdog_timer_vld_2             (w_watchdog_timer_vld_2             ),
        .o_min_frag_size_2                  (w_min_frag_size_2                  ),
        .o_min_frag_size_vld_2              (w_min_frag_size_vld_2              ),
        .o_ipg_timer_2                      (w_ipg_timer_2                      ),
        .o_ipg_timer_vld_2                  (w_ipg_timer_vld_2                  ),
        .o_verify_enabled_2                 (w_verify_enabled_2                 ),
        .o_start_verify_2                   (w_start_verify_2                   ),
        .o_clear_verify_2                   (w_clear_verify_2                   ),
        .o_verify_timer_2                   (w_verify_timer_2                   ),
        .o_verify_timer_vld_2               (w_verify_timer_vld_2               ),
        .i_err_verify_cnt_2                 (w_err_verify_cnt_2                 ),
        .i_preempt_enable_2                 (w_preempt_enable_2                 ),
    `endif
    `ifdef MAC3   
        // MAC3 寄存器信号
        .o_port_txmac_down_regs_3           (w_port_txmac_down_regs_3           ),
        .o_store_forward_enable_regs_3      (w_store_forward_enable_regs_3      ),
        .o_port_1g_interval_num_regs_3      (w_port_1g_interval_num_regs_3      ),
        .o_port_100m_interval_num_regs_3    (w_port_100m_interval_num_regs_3    ),
        .i_port_tx_byte_cnt_3               (w_port_tx_byte_cnt_3               ),
        .i_port_tx_frame_cnt_3              (w_port_tx_frame_cnt_3              ),
        .i_port_diag_state_3                (w_port_diag_state_3                ),

        .o_idleSlope_p3q0                   (w_idleSlope_p3q0                   ),
        .o_sendslope_p3q0                   (w_sendslope_p3q0                   ),
        .o_hithreshold_p3q0                 (w_hithreshold_p3q0                   ),
        .o_lothreshold_p3q0                 (w_lothreshold_p3q0                   ),

        .o_idleSlope_p3q1                   (w_idleSlope_p3q1                   ),
        .o_sendslope_p3q1                   (w_sendslope_p3q1                   ),
        .o_hithreshold_p3q1                 (w_hithreshold_p3q1                   ),
        .o_lothreshold_p3q1                 (w_lothreshold_p3q1                   ),

        .o_idleSlope_p3q2                   (w_idleSlope_p3q2                   ),
        .o_sendslope_p3q2                   (w_sendslope_p3q2                   ),
        .o_hithreshold_p3q2                 (w_hithreshold_p3q2                   ),
        .o_lothreshold_p3q2                 (w_lothreshold_p3q2                   ),

        .o_idleSlope_p3q3                   (w_idleSlope_p3q3                   ),
        .o_sendslope_p3q3                   (w_sendslope_p3q3                   ),
        .o_hithreshold_p3q3                 (w_hithreshold_p3q3                   ),
        .o_lothreshold_p3q3                 (w_lothreshold_p3q3                   ),

        .o_idleSlope_p3q4                   (w_idleSlope_p3q4                   ),
        .o_sendslope_p3q4                   (w_sendslope_p3q4                   ),
        .o_hithreshold_p3q4                 (w_hithreshold_p3q4                   ),
        .o_lothreshold_p3q4                 (w_lothreshold_p3q4                   ),

        .o_idleSlope_p3q5                   (w_idleSlope_p3q5                   ),
        .o_sendslope_p3q5                   (w_sendslope_p3q5                   ),
        .o_hithreshold_p3q5                 (w_hithreshold_p3q5                   ),
        .o_lothreshold_p3q5                 (w_lothreshold_p3q5                   ),

        .o_idleSlope_p3q6                   (w_idleSlope_p3q6                   ),
        .o_sendslope_p3q6                   (w_sendslope_p3q6                   ),
        .o_hithreshold_p3q6                 (w_hithreshold_p3q6                   ),
        .o_lothreshold_p3q6                 (w_lothreshold_p3q6                   ),

        .o_idleSlope_p3q7                   (w_idleSlope_p3q7                   ),
        .o_sendslope_p3q7                   (w_sendslope_p3q7                   ),
        .o_hithreshold_p3q7                 (w_hithreshold_p3q7                   ),
        .o_lothreshold_p3q7                 (w_lothreshold_p3q7                   ),
        

        .o_qav_en_3                         (w_qav_en_3                         ),
        .o_config_vld_3                     (w_config_vld_3                     ),
        .o_Base_time_3                      (w_Base_time_3                      ),
		.o_Base_time_vld_3					(w_Base_time_vld_3					),
        .o_ConfigChange_3                   (w_ConfigChange_3                   ),
        .o_ControlList_3                    (w_ControlList_3                    ),
        .o_ControlList_len_3                (w_ControlList_len_3                ),
        .o_ControlList_vld_3                (w_ControlList_vld_3                ),
        .o_cycle_time_3                     (w_cycle_time_3                     ),
        .o_cycle_time_extension_3           (w_cycle_time_extension_3           ),
        .o_qbv_en_3                         (w_qbv_en_3                         ),
        .o_qos_sch_3                        (w_qos_sch_3                        ),
        .o_qos_en_3                         (w_qos_en_3                         ),
        .i_frag_next_tx_3                   (w_frag_next_tx_3                   ),
        .i_tx_timeout_3                     (w_tx_timeout_3                     ),
        .i_preempt_success_cnt_3            (w_preempt_success_cnt_3            ),
        .i_preempt_active_3                 (w_preempt_active_3                 ),
        .i_preemptable_frame_3              (w_preemptable_frame_3              ),
        .i_tx_frames_cnt_3                  (w_tx_frames_cnt_3                  ),
        .i_tx_fragment_cnt_3                (w_tx_fragment_cnt_3                ),
        .i_tx_busy_3                        (w_tx_busy_3                        ),
        .o_watchdog_timer_3                 (w_watchdog_timer_3                 ),
        .o_watchdog_timer_vld_3             (w_watchdog_timer_vld_3             ),
        .o_min_frag_size_3                  (w_min_frag_size_3                  ),
        .o_min_frag_size_vld_3              (w_min_frag_size_vld_3              ),
        .o_ipg_timer_3                      (w_ipg_timer_3                      ),
        .o_ipg_timer_vld_3                  (w_ipg_timer_vld_3                  ),
        .o_verify_enabled_3                 (w_verify_enabled_3                 ),
        .o_start_verify_3                   (w_start_verify_3                   ),
        .o_clear_verify_3                   (w_clear_verify_3                   ),
        .o_verify_timer_3                   (w_verify_timer_3                   ),
        .o_verify_timer_vld_3               (w_verify_timer_vld_3               ),
        .i_err_verify_cnt_3                 (w_err_verify_cnt_3                 ),
        .i_preempt_enable_3                 (w_preempt_enable_3                 ),
    `endif
    `ifdef MAC4   
        // MAC4 寄存器信号
        .o_port_txmac_down_regs_4           (w_port_txmac_down_regs_4           ),
        .o_store_forward_enable_regs_4      (w_store_forward_enable_regs_4      ),
        .o_port_1g_interval_num_regs_4      (w_port_1g_interval_num_regs_4      ),
        .o_port_100m_interval_num_regs_4    (w_port_100m_interval_num_regs_4    ),
        .i_port_tx_byte_cnt_4               (w_port_tx_byte_cnt_4               ),
        .i_port_tx_frame_cnt_4              (w_port_tx_frame_cnt_4              ),
        .i_port_diag_state_4                (w_port_diag_state_4                ),

        .o_idleSlope_p4q0                   (w_idleSlope_p4q0                   ),
        .o_sendslope_p4q0                   (w_sendslope_p4q0                   ),
        .o_hithreshold_p4q0                 (w_hithreshold_p4q0                   ),
        .o_lothreshold_p4q0                 (w_lothreshold_p4q0                   ),

        .o_idleSlope_p4q1                   (w_idleSlope_p4q1                   ),
        .o_sendslope_p4q1                   (w_sendslope_p4q1                   ),
        .o_hithreshold_p4q1                 (w_hithreshold_p4q1                   ),
        .o_lothreshold_p4q1                 (w_lothreshold_p4q1                   ),

        .o_idleSlope_p4q2                   (w_idleSlope_p4q2                   ),
        .o_sendslope_p4q2                   (w_sendslope_p4q2                   ),
        .o_hithreshold_p4q2                 (w_hithreshold_p4q2                   ),
        .o_lothreshold_p4q2                 (w_lothreshold_p4q2                   ),

        .o_idleSlope_p4q3                   (w_idleSlope_p4q3                   ),
        .o_sendslope_p4q3                   (w_sendslope_p4q3                   ),
        .o_hithreshold_p4q3                 (w_hithreshold_p4q3                   ),
        .o_lothreshold_p4q3                 (w_lothreshold_p4q3                   ),

        .o_idleSlope_p4q4                   (w_idleSlope_p4q4                   ),
        .o_sendslope_p4q4                   (w_sendslope_p4q4                   ),
        .o_hithreshold_p4q4                 (w_hithreshold_p4q4                   ),
        .o_lothreshold_p4q4                 (w_lothreshold_p4q4                   ),

        .o_idleSlope_p4q5                   (w_idleSlope_p4q5                   ),
        .o_sendslope_p4q5                   (w_sendslope_p4q5                   ),
        .o_hithreshold_p4q5                 (w_hithreshold_p4q5                   ),
        .o_lothreshold_p4q5                 (w_lothreshold_p4q5                   ),

        .o_idleSlope_p4q6                   (w_idleSlope_p4q6                   ),
        .o_sendslope_p4q6                   (w_sendslope_p4q6                   ),
        .o_hithreshold_p4q6                 (w_hithreshold_p4q6                   ),
        .o_lothreshold_p4q6                 (w_lothreshold_p4q6                   ),

        .o_idleSlope_p4q7                   (w_idleSlope_p4q7                   ),
        .o_sendslope_p4q7                   (w_sendslope_p4q7                   ),
        .o_hithreshold_p4q7                 (w_hithreshold_p4q7                   ),
        .o_lothreshold_p4q7                 (w_lothreshold_p4q7                   ),


        .o_qav_en_4                         (w_qav_en_4                         ),
        .o_config_vld_4                     (w_config_vld_4                     ),
        .o_Base_time_4                      (w_Base_time_4                      ),
		.o_Base_time_vld_4					(w_Base_time_vld_4					),
        .o_ConfigChange_4                   (w_ConfigChange_4                   ),
        .o_ControlList_4                    (w_ControlList_4                    ),
        .o_ControlList_len_4                (w_ControlList_len_4                ),
        .o_ControlList_vld_4                (w_ControlList_vld_4                ),
        .o_cycle_time_4                     (w_cycle_time_4                     ),
        .o_cycle_time_extension_4           (w_cycle_time_extension_4           ),
        .o_qbv_en_4                         (w_qbv_en_4                         ),
        .o_qos_sch_4                        (w_qos_sch_4                        ),
        .o_qos_en_4                         (w_qos_en_4                         ),
        .i_frag_next_tx_4                   (w_frag_next_tx_4                   ),
        .i_tx_timeout_4                     (w_tx_timeout_4                     ),
        .i_preempt_success_cnt_4            (w_preempt_success_cnt_4            ),
        .i_preempt_active_4                 (w_preempt_active_4                 ),
        .i_preemptable_frame_4              (w_preemptable_frame_4              ),
        .i_tx_frames_cnt_4                  (w_tx_frames_cnt_4                  ),
        .i_tx_fragment_cnt_4                (w_tx_fragment_cnt_4                ),
        .i_tx_busy_4                        (w_tx_busy_4                        ),
        .o_watchdog_timer_4                 (w_watchdog_timer_4                 ),
        .o_watchdog_timer_vld_4             (w_watchdog_timer_vld_4             ),
        .o_min_frag_size_4                  (w_min_frag_size_4                  ),
        .o_min_frag_size_vld_4              (w_min_frag_size_vld_4              ),
        .o_ipg_timer_4                      (w_ipg_timer_4                      ),
        .o_ipg_timer_vld_4                  (w_ipg_timer_vld_4                  ),
        .o_verify_enabled_4                 (w_verify_enabled_4                 ),
        .o_start_verify_4                   (w_start_verify_4                   ),
        .o_clear_verify_4                   (w_clear_verify_4                   ),
        .o_verify_timer_4                   (w_verify_timer_4                   ),
        .o_verify_timer_vld_4               (w_verify_timer_vld_4               ),
        .i_err_verify_cnt_4                 (w_err_verify_cnt_4                 ),
        .i_preempt_enable_4                 (w_preempt_enable_4                 ),
    `endif
    `ifdef MAC5   
        // MAC5 寄存器信号
        .o_port_txmac_down_regs_5           (w_port_txmac_down_regs_5           ),
        .o_store_forward_enable_regs_5      (w_store_forward_enable_regs_5      ),
        .o_port_1g_interval_num_regs_5      (w_port_1g_interval_num_regs_5      ),
        .o_port_100m_interval_num_regs_5    (w_port_100m_interval_num_regs_5    ),
        .i_port_tx_byte_cnt_5               (w_port_tx_byte_cnt_5               ),
        .i_port_tx_frame_cnt_5              (w_port_tx_frame_cnt_5              ),
        .i_port_diag_state_5                (w_port_diag_state_5                ),
        

        .o_idleSlope_p5q0                   (w_idleSlope_p5q0                   ),
        .o_sendslope_p5q0                   (w_sendslope_p5q0                   ),
        .o_hithreshold_p5q0                 (w_hithreshold_p5q0                   ),
        .o_lothreshold_p5q0                 (w_lothreshold_p5q0                   ),

        .o_idleSlope_p5q1                   (w_idleSlope_p5q1                   ),
        .o_sendslope_p5q1                   (w_sendslope_p5q1                   ),
        .o_hithreshold_p5q1                 (w_hithreshold_p5q1                   ),
        .o_lothreshold_p5q1                 (w_lothreshold_p5q1                   ),

        .o_idleSlope_p5q2                   (w_idleSlope_p5q2                   ),
        .o_sendslope_p5q2                   (w_sendslope_p5q2                   ),
        .o_hithreshold_p5q2                 (w_hithreshold_p5q2                   ),
        .o_lothreshold_p5q2                 (w_lothreshold_p5q2                   ),

        .o_idleSlope_p5q3                   (w_idleSlope_p5q3                   ),
        .o_sendslope_p5q3                   (w_sendslope_p5q3                   ),
        .o_hithreshold_p5q3                 (w_hithreshold_p5q3                   ),
        .o_lothreshold_p5q3                 (w_lothreshold_p5q3                   ),

        .o_idleSlope_p5q4                   (w_idleSlope_p5q4                   ),
        .o_sendslope_p5q4                   (w_sendslope_p5q4                   ),
        .o_hithreshold_p5q4                 (w_hithreshold_p5q4                   ),
        .o_lothreshold_p5q4                 (w_lothreshold_p5q4                   ),

        .o_idleSlope_p5q5                   (w_idleSlope_p5q5                   ),
        .o_sendslope_p5q5                   (w_sendslope_p5q5                   ),
        .o_hithreshold_p5q5                 (w_hithreshold_p5q5                   ),
        .o_lothreshold_p5q5                 (w_lothreshold_p5q5                   ),

        .o_idleSlope_p5q6                   (w_idleSlope_p5q6                   ),
        .o_sendslope_p5q6                   (w_sendslope_p5q6                   ),
        .o_hithreshold_p5q6                 (w_hithreshold_p5q6                   ),
        .o_lothreshold_p5q6                 (w_lothreshold_p5q6                   ),

        .o_idleSlope_p5q7                   (w_idleSlope_p5q7                   ),
        .o_sendslope_p5q7                   (w_sendslope_p5q7                   ),
        .o_hithreshold_p5q7                 (w_hithreshold_p5q7                   ),
        .o_lothreshold_p5q7                 (w_lothreshold_p5q7                   ),

        .o_qav_en_5                         (w_qav_en_5                         ),
        .o_config_vld_5                     (w_config_vld_5                     ),
        .o_Base_time_5                      (w_Base_time_5                      ),
		.o_Base_time_vld_5					(w_Base_time_vld_5					),
        .o_ConfigChange_5                   (w_ConfigChange_5                   ),
        .o_ControlList_5                    (w_ControlList_5                    ),
        .o_ControlList_len_5                (w_ControlList_len_5                ),
        .o_ControlList_vld_5                (w_ControlList_vld_5                ),
        .o_cycle_time_5                     (w_cycle_time_5                     ),
        .o_cycle_time_extension_5           (w_cycle_time_extension_5           ),
        .o_qbv_en_5                         (w_qbv_en_5                         ),
        .o_qos_sch_5                        (w_qos_sch_5                        ),
        .o_qos_en_5                         (w_qos_en_5                         ),
        .i_frag_next_tx_5                   (w_frag_next_tx_5                   ),
        .i_tx_timeout_5                     (w_tx_timeout_5                     ),
        .i_preempt_success_cnt_5            (w_preempt_success_cnt_5            ),
        .i_preempt_active_5                 (w_preempt_active_5                 ),
        .i_preemptable_frame_5              (w_preemptable_frame_5              ),
        .i_tx_frames_cnt_5                  (w_tx_frames_cnt_5                  ),
        .i_tx_fragment_cnt_5                (w_tx_fragment_cnt_5                ),
        .i_tx_busy_5                        (w_tx_busy_5                        ),
        .o_watchdog_timer_5                 (w_watchdog_timer_5                 ),
        .o_watchdog_timer_vld_5             (w_watchdog_timer_vld_5             ),
        .o_min_frag_size_5                  (w_min_frag_size_5                  ),
        .o_min_frag_size_vld_5              (w_min_frag_size_vld_5              ),
        .o_ipg_timer_5                      (w_ipg_timer_5                      ),
        .o_ipg_timer_vld_5                  (w_ipg_timer_vld_5                  ),
        .o_verify_enabled_5                 (w_verify_enabled_5                 ),
        .o_start_verify_5                   (w_start_verify_5                   ),
        .o_clear_verify_5                   (w_clear_verify_5                   ),
        .o_verify_timer_5                   (w_verify_timer_5                   ),
        .o_verify_timer_vld_5               (w_verify_timer_vld_5               ),
        .i_err_verify_cnt_5                 (w_err_verify_cnt_5                 ),
        .i_preempt_enable_5                 (w_preempt_enable_5                 ),
    `endif
    `ifdef MAC6     
        // MAC6 寄存器信号
        .o_port_txmac_down_regs_6           (w_port_txmac_down_regs_6           ),
        .o_store_forward_enable_regs_6      (w_store_forward_enable_regs_6      ),
        .o_port_1g_interval_num_regs_6      (w_port_1g_interval_num_regs_6      ),
        .o_port_100m_interval_num_regs_6    (w_port_100m_interval_num_regs_6    ),
        .i_port_tx_byte_cnt_6               (w_port_tx_byte_cnt_6               ),
        .i_port_tx_frame_cnt_6              (w_port_tx_frame_cnt_6              ),
        .i_port_diag_state_6                (w_port_diag_state_6                ),

        .o_idleSlope_p6q0                   (w_idleSlope_p6q0                   ),
        .o_sendslope_p6q0                   (w_sendslope_p6q0                   ),
        .o_hithreshold_p6q0                 (w_hithreshold_p6q0                   ),
        .o_lothreshold_p6q0                 (w_lothreshold_p6q0                   ),

        .o_idleSlope_p6q1                   (w_idleSlope_p6q1                   ),
        .o_sendslope_p6q1                   (w_sendslope_p6q1                   ),
        .o_hithreshold_p6q1                 (w_hithreshold_p6q1                   ),
        .o_lothreshold_p6q1                 (w_lothreshold_p6q1                   ),

        .o_idleSlope_p6q2                   (w_idleSlope_p6q2                   ),
        .o_sendslope_p6q2                   (w_sendslope_p6q2                   ),
        .o_hithreshold_p6q2                 (w_hithreshold_p6q2                   ),
        .o_lothreshold_p6q2                 (w_lothreshold_p6q2                   ),

        .o_idleSlope_p6q3                   (w_idleSlope_p6q3                   ),
        .o_sendslope_p6q3                   (w_sendslope_p6q3                   ),
        .o_hithreshold_p6q3                 (w_hithreshold_p6q3                   ),
        .o_lothreshold_p6q3                 (w_lothreshold_p6q3                   ),

        .o_idleSlope_p6q4                   (w_idleSlope_p6q4                   ),
        .o_sendslope_p6q4                   (w_sendslope_p6q4                   ),
        .o_hithreshold_p6q4                 (w_hithreshold_p6q4                   ),
        .o_lothreshold_p6q4                 (w_lothreshold_p6q4                   ),

        .o_idleSlope_p6q5                   (w_idleSlope_p6q5                   ),
        .o_sendslope_p6q5                   (w_sendslope_p6q5                   ),
        .o_hithreshold_p6q5                 (w_hithreshold_p6q5                   ),
        .o_lothreshold_p6q5                 (w_lothreshold_p6q5                   ),

        .o_idleSlope_p6q6                   (w_idleSlope_p6q6                   ),
        .o_sendslope_p6q6                   (w_sendslope_p6q6                   ),
        .o_hithreshold_p6q6                 (w_hithreshold_p6q6                   ),
        .o_lothreshold_p6q6                 (w_lothreshold_p6q6                   ),

        .o_idleSlope_p6q7                   (w_idleSlope_p6q7                   ),
        .o_sendslope_p6q7                   (w_sendslope_p6q7                   ),
        .o_hithreshold_p6q7                 (w_hithreshold_p6q7                   ),
        .o_lothreshold_p6q7                 (w_lothreshold_p6q7                   ),

        .o_qav_en_6                         (w_qav_en_6                         ),
        .o_config_vld_6                     (w_config_vld_6                     ),
        .o_Base_time_6                      (w_Base_time_6                      ),
		.o_Base_time_vld_6					(w_Base_time_vld_6					),
        .o_ConfigChange_6                   (w_ConfigChange_6                   ),
        .o_ControlList_6                    (w_ControlList_6                    ),
        .o_ControlList_len_6                (w_ControlList_len_6                ),
        .o_ControlList_vld_6                (w_ControlList_vld_6                ),
        .o_cycle_time_6                     (w_cycle_time_6                     ),
        .o_cycle_time_extension_6           (w_cycle_time_extension_6           ),
        .o_qbv_en_6                         (w_qbv_en_6                         ),
        .o_qos_sch_6                        (w_qos_sch_6                        ),
        .o_qos_en_6                         (w_qos_en_6                         ),
        .i_frag_next_tx_6                   (w_frag_next_tx_6                   ),
        .i_tx_timeout_6                     (w_tx_timeout_6                     ),
        .i_preempt_success_cnt_6            (w_preempt_success_cnt_6            ),
        .i_preempt_active_6                 (w_preempt_active_6                 ),
        .i_preemptable_frame_6              (w_preemptable_frame_6              ),
        .i_tx_frames_cnt_6                  (w_tx_frames_cnt_6                  ),
        .i_tx_fragment_cnt_6                (w_tx_fragment_cnt_6                ),
        .i_tx_busy_6                        (w_tx_busy_6                        ),
        .o_watchdog_timer_6                 (w_watchdog_timer_6                 ),
        .o_watchdog_timer_vld_6             (w_watchdog_timer_vld_6             ),
        .o_min_frag_size_6                  (w_min_frag_size_6                  ),
        .o_min_frag_size_vld_6              (w_min_frag_size_vld_6              ),
        .o_ipg_timer_6                      (w_ipg_timer_6                      ),
        .o_ipg_timer_vld_6                  (w_ipg_timer_vld_6                  ),
        .o_verify_enabled_6                 (w_verify_enabled_6                 ),
        .o_start_verify_6                   (w_start_verify_6                   ),
        .o_clear_verify_6                   (w_clear_verify_6                   ),
        .o_verify_timer_6                   (w_verify_timer_6                   ),
        .o_verify_timer_vld_6               (w_verify_timer_vld_6               ),
        .i_err_verify_cnt_6                 (w_err_verify_cnt_6                 ),
        .i_preempt_enable_6                 (w_preempt_enable_6                 ),
    `endif
    `ifdef MAC7   
        // MAC7 寄存器信号
        .o_port_txmac_down_regs_7           (w_port_txmac_down_regs_7           ),
        .o_store_forward_enable_regs_7      (w_store_forward_enable_regs_7      ),
        .o_port_1g_interval_num_regs_7      (w_port_1g_interval_num_regs_7      ),
        .o_port_100m_interval_num_regs_7    (w_port_100m_interval_num_regs_7    ),
        .i_port_tx_byte_cnt_7               (w_port_tx_byte_cnt_7               ),
        .i_port_tx_frame_cnt_7              (w_port_tx_frame_cnt_7              ),
        .i_port_diag_state_7                (w_port_diag_state_7                ),

        .o_idleSlope_p7q0                   (w_idleSlope_p7q0                   ),
        .o_sendslope_p7q0                   (w_sendslope_p7q0                   ),
        .o_hithreshold_p7q0                 (w_hithreshold_p7q0                   ),
        .o_lothreshold_p7q0                 (w_lothreshold_p7q0                   ),

        .o_idleSlope_p7q1                   (w_idleSlope_p7q1                   ),
        .o_sendslope_p7q1                   (w_sendslope_p7q1                   ),
        .o_hithreshold_p7q1                 (w_hithreshold_p7q1                   ),
        .o_lothreshold_p7q1                 (w_lothreshold_p7q1                   ),

        .o_idleSlope_p7q2                   (w_idleSlope_p7q2                   ),
        .o_sendslope_p7q2                   (w_sendslope_p7q2                   ),
        .o_hithreshold_p7q2                 (w_hithreshold_p7q2                   ),
        .o_lothreshold_p7q2                 (w_lothreshold_p7q2                   ),

        .o_idleSlope_p7q3                   (w_idleSlope_p7q3                   ),
        .o_sendslope_p7q3                   (w_sendslope_p7q3                   ),
        .o_hithreshold_p7q3                 (w_hithreshold_p7q3                   ),
        .o_lothreshold_p7q3                 (w_lothreshold_p7q3                   ),

        .o_idleSlope_p7q4                   (w_idleSlope_p7q4                   ),
        .o_sendslope_p7q4                   (w_sendslope_p7q4                   ),
        .o_hithreshold_p7q4                 (w_hithreshold_p7q4                   ),
        .o_lothreshold_p7q4                 (w_lothreshold_p7q4                   ),

        .o_idleSlope_p7q5                   (w_idleSlope_p7q5                   ),
        .o_sendslope_p7q5                   (w_sendslope_p7q5                   ),
        .o_hithreshold_p7q5                 (w_hithreshold_p7q5                   ),
        .o_lothreshold_p7q5                 (w_lothreshold_p7q5                   ),

        .o_idleSlope_p7q6                   (w_idleSlope_p7q6                   ),
        .o_sendslope_p7q6                   (w_sendslope_p7q6                   ),
        .o_hithreshold_p7q6                 (w_hithreshold_p7q6                   ),
        .o_lothreshold_p7q6                 (w_lothreshold_p7q6                   ),

        .o_idleSlope_p7q7                   (w_idleSlope_p7q7                   ),
        .o_sendslope_p7q7                   (w_sendslope_p7q7                   ),
        .o_hithreshold_p7q7                 (w_hithreshold_p7q7                   ),
        .o_lothreshold_p7q7                 (w_lothreshold_p7q7                   ),

        .o_qav_en_7                         (w_qav_en_7                         ),
        .o_config_vld_7                     (w_config_vld_7                     ),
        .o_Base_time_7                      (w_Base_time_7                      ),
		.o_Base_time_vld_7					(w_Base_time_vld_7					),
        .o_ConfigChange_7                   (w_ConfigChange_7                   ),
        .o_ControlList_7                    (w_ControlList_7                    ),
        .o_ControlList_len_7                (w_ControlList_len_7                ),
        .o_ControlList_vld_7                (w_ControlList_vld_7                ),
        .o_cycle_time_7                     (w_cycle_time_7                     ),
        .o_cycle_time_extension_7           (w_cycle_time_extension_7           ),
        .o_qbv_en_7                         (w_qbv_en_7                         ),
        .o_qos_sch_7                        (w_qos_sch_7                        ),
        .o_qos_en_7                         (w_qos_en_7                         ),
        .i_frag_next_tx_7                   (w_frag_next_tx_7                   ),
        .i_tx_timeout_7                     (w_tx_timeout_7                     ),
        .i_preempt_success_cnt_7            (w_preempt_success_cnt_7            ),
        .i_preempt_active_7                 (w_preempt_active_7                 ),
        .i_preemptable_frame_7              (w_preemptable_frame_7              ),
        .i_tx_frames_cnt_7                  (w_tx_frames_cnt_7                  ),
        .i_tx_fragment_cnt_7                (w_tx_fragment_cnt_7                ),
        .i_tx_busy_7                        (w_tx_busy_7                        ),
        .o_watchdog_timer_7                 (w_watchdog_timer_7                 ),
        .o_watchdog_timer_vld_7             (w_watchdog_timer_vld_7             ),
        .o_min_frag_size_7                  (w_min_frag_size_7                  ),
        .o_min_frag_size_vld_7              (w_min_frag_size_vld_7              ),
        .o_ipg_timer_7                      (w_ipg_timer_7                      ),
        .o_ipg_timer_vld_7                  (w_ipg_timer_vld_7                  ),
        .o_verify_enabled_7                 (w_verify_enabled_7                 ),
        .o_start_verify_7                   (w_start_verify_7                   ),
        .o_clear_verify_7                   (w_clear_verify_7                   ),
        .o_verify_timer_7                   (w_verify_timer_7                   ),
        .o_verify_timer_vld_7               (w_verify_timer_vld_7               ),
        .i_err_verify_cnt_7                 (w_err_verify_cnt_7                 ),
        .i_preempt_enable_7                 (w_preempt_enable_7                 ),
    `endif
    // 寄存器控制信号
    .i_refresh_list_pulse               (i_refresh_list_pulse      ),
    .i_switch_err_cnt_clr               (i_switch_err_cnt_clr      ),
    .i_switch_err_cnt_stat              (i_switch_err_cnt_stat     ),
    
    // 寄存器写控制接口
    .i_switch_reg_bus_we                (i_switch_reg_bus_we       ),
    .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr  ),
    .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din   ),
    .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v ),
    
    // 寄存器读控制接口
    .i_switch_reg_bus_rd                (i_switch_reg_bus_rd       ),
    .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr  ),
    .o_switch_reg_bus_rd_dout           (o_switch_reg_bus_rd_dout  ),
    .o_switch_reg_bus_rd_dout_v         (o_switch_reg_bus_rd_dout_v)
    );

endmodule