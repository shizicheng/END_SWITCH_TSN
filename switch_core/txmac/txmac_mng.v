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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac0_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac0_scheduing_rst                ,
    output              wire                                    o_mac0_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac1_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac1_scheduing_rst                ,
    output              wire                                    o_mac1_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac2_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac2_scheduing_rst                ,
    output              wire                                    o_mac2_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac3_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac3_scheduing_rst                ,
    output              wire                                    o_mac3_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac4_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac4_scheduing_rst                ,
    output              wire                                    o_mac4_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac5_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac5_scheduing_rst                ,
    output              wire                                    o_mac5_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac6_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac6_scheduing_rst                ,
    output              wire                                    o_mac6_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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
    input               wire  [PORT_FIFO_PRI_NUM:0]             i_mac7_fifoc_empty                  ,    
    output              wire  [PORT_FIFO_PRI_NUM:0]             o_mac7_scheduing_rst                ,
    output              wire                                    o_mac7_scheduing_rst_vld            ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
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

`ifdef CPU_MAC
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac0_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC1
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac1_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC2
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac2_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC3
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac3_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC4
   tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac4_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC5
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac5_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC6
   tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac6_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );
`endif

`ifdef MAC7
   tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )tx_mac7_port_mng_inst(
        .i_clk                              (),   // 250MHz
        .i_rst                              (),
        // 调度流水线调度信息交互
        .i_fifoc_empty                      (),    
        .o_scheduing_rst                    (),
        .o_scheduing_rst_vld                (),                 
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 数据流信息 
        //pmac通道数据
        .i_pmac_tx_axis_data                (), 
        .i_pmac_tx_axis_user                (), 
        .i_pmac_tx_axis_keep                (), 
        .i_pmac_tx_axis_last                (), 
        .i_pmac_tx_axis_valid               (), 
        .i_pmac_ethertype                   (), 
        .o_pmac_tx_axis_ready               (),
        //emac通道数据              
        .i_emac_tx_axis_data                () , 
        .i_emac_tx_axis_user                () , 
        .i_emac_tx_axis_keep                () , 
        .i_emac_tx_axis_last                () , 
        .i_emac_tx_axis_valid               () , 
        .i_emac_ethertype                   () ,
        .o_emac_tx_axis_ready               () ,
        /*------------------------------------------ TXMAC寄存器 -------------------------------------------*/
        // 控制寄存器
        .i_port_txmac_down_regs             ()  ,  // 端口发送方向MAC关闭使能
        .i_store_forward_enable_regs        ()  ,  // 端口强制存储转发功能使能
        .i_port_1g_interval_num_regs        ()  ,  // 端口千兆模式发送帧间隔字节数配置值
        .i_port_100m_interval_num_regs      ()  ,  // 端口0百兆模式发送帧间隔字节数配置值
        // 状态寄存器
        .o_port_tx_byte_cnt                 () ,  // 端口发送字节数
        .o_port_tx_frame_cnt                () ,  // 端口发送帧计数器
        // 诊断状态寄存器
        .o_port_diag_state                  () ,  // 诊断状态

        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        //输出给接口层axi数据流
        .o_mac_axi_data                     () ,
        .o_mac_axi_data_keep                () ,
        .o_mac_axi_data_valid               () ,
        .o_mac_axi_data_user                () ,
        .i_mac_axi_data_ready               () ,
        .o_mac_axi_data_last                () ,
        // 报文时间打时间戳 
        .o_mac_time_irq                     () , // 打时间戳中断信号
        .o_mac_frame_seq                    () , // 帧序列号
        .o_timestamp_addr                   ()   // 打时间戳存储的 RAM 地址
    );

`endif



endmodule