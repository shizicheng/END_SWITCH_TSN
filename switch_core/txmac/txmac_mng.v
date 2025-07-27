`include "synth_cmd_define.vh"

module  tx_mac_mng #(
    parameter                                                   PORT_NUM                =      4        ,                   // 交换机的端口数
    parameter                                                   METADATA_WIDTH          =      64       ,                   // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,                   // Mac_port_mng 数据位宽
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,                   // 支持端口优先级 FIFO 的数量
    parameter                                                   REG_ADDR_BUS_WIDTH      =      6        ,
    parameter                                                   REG_DATA_BUS_WIDTH      =      32       ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM  // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
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
    output              wire                                    o_switch_reg_bus_rd_dout_v          , // 读数据有效使能
    /*---------------------------------------- 业务接口数据输出 -------------------------------------------*/
`ifdef CPU_MAC
    // 数据流信息 
    output              wire                                    o_cpu_mac0_port_link                , // 端口的连接状态
    output              wire   [1:0]                            o_cpu_mac0_port_speed               , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_cpu_mac0_port_filter_preamble_v   , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_cpu_mac0_axi_data                 , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_cpu_mac0_axi_data_keep            , // 端口数据流掩码，有效字节指示
    output              wire                                    o_cpu_mac0_axi_data_valid           , // 端口数据有效
    input               wire                                    i_cpu_mac0_axi_data_ready           , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_cpu_mac0_axi_data_last            , // 数据流结束标识
    // 报文时间打时间戳
    output              wire                                    o_cpu_mac0_time_irq                 , // 打时间戳中断信号
    output              wire  [7:0]                             o_cpu_mac0_frame_seq                , // 帧序列号
    output              wire  [7:0]                             o_timestamp0_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC1
    // 数据流信息 
    output              wire                                    o_mac1_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac1_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac1_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac1_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac1_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac1_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac1_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac1_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac1_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac1_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp1_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC2
    // 数据流信息 
    output              wire                                    o_mac2_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac2_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac2_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac2_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac2_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac2_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac2_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac2_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac2_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac2_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp2_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC3
    // 数据流信息 
    output              wire                                    o_mac3_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac3_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac3_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac3_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac3_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac3_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac3_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac3_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac3_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac3_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp3_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC4
    // 数据流信息 
    output              wire                                    o_mac4_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac4_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac4_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac4_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac4_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac4_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac4_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac4_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac4_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac4_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp4_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC5
    // 数据流信息 
    output              wire                                    o_mac5_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac5_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac5_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac5_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac5_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac5_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac5_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac5_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac5_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac5_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp5_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC6
    // 数据流信息 
    output              wire                                    o_mac6_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac6_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac6_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac6_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac6_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac6_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac6_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac6_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac6_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac6_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp6_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC7
    // 数据流信息 
    output              wire                                    o_mac7_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac7_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac7_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac7_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac7_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac7_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac7_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac7_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac7_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac7_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp7_addr                   , // 打时间戳存储的 RAM 地址
`endif
    /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
`ifdef TSN_AS
    // 数据流信息 
    input               wire                                    i_as_port_link                      , // 端口的连接状态
    input               wire   [1:0]                            i_as_port_speed                     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_as_port_filter_preamble_v         , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_as_axi_data                       , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_as_axi_data_keep                  , // 端口数据流掩码，有效字节指示
    input               wire                                    i_as_axi_data_valid                 , // 端口数据有效
    input               wire   [63:0]                           i_as_axi_data_user                  , // AS 协议信息流
    output              wire                                    o_as_axi_data_ready                 , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_as_axi_data_last                  , // 数据流结束标识
`endif
`ifdef LLDP
    // 数据流信息 
    input               wire                                    i_lldp_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_lldp_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_lldp_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_lldp_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_lldp_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_lldp_axi_data_valid               , // 端口数据有效
    input               wire   [63:0]                           i_lldp_axi_data_user                , // LLDP 协议信息流
    output              wire                                    o_lldp_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_lldp_axi_data_last                , // 数据流结束标识
`endif
`ifdef TSN_CB
    // 数据流信息 
    input               wire                                    i_cb_port_link                      , // 端口的连接状态
    input               wire   [1:0]                            i_cb_port_speed                     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_cb_port_filter_preamble_v         , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_cb_axi_data                       , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_cb_axi_data_keep                  , // 端口数据流掩码，有效字节指示
    input               wire                                    i_cb_axi_data_valid                 , // 端口数据有效
    input               wire   [63:0]                           i_cb_axi_data_user                  , // CB 协议信息流
    output              wire                                    o_cb_axi_data_ready                 , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_cb_axi_data_last                  , // 数据流结束标识
`endif
    /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
    // 聚合总线输入数据流
    input              wire   [CROSS_DATA_WIDTH:0]              i_cross_rx_data                     , // 聚合总线数据流，最高位表示crcerr
    input              wire                                     i_cross_rx_data_valid               , // 聚合总线数据流有效信号
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_cross_rx_data_keep                , // 端口数据流掩码，有效字节指示
    output             wire   [PORT_NUM - 1:0]                  o_cross_rx_data_ready               , // 下游模块反压流水线
    input              wire                                     i_mac_axi_data_last                 , // 数据流结束标识
    //聚合总线输入信息流
    input              wire   [METADATA_WIDTH-1:0]              i_cross_metadata                    , // 聚合总线 metadata 数据
    input              wire                                     i_cross_metadata_valid              , // 聚合总线 metadata 数据有效信号
    input              wire                                     i_cross_metadata_last               , // 信息流结束标识
    output             wire                                     o_cross_metadata_ready                // 下游模块反压流水线  
);

`ifdef CPU_MAC
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_cpu_mac0_port_link              ) , // 端口的连接状态
        .o_mac_port_speed                   (o_cpu_mac0_port_speed             ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_cpu_mac0_port_filter_preamble_v ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_cpu_mac0_axi_data               ) , // 端口数据流
        .o_mac_axi_data_keep                (o_cpu_mac0_axi_data_keep          ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_cpu_mac0_axi_data_valid         ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_cpu_mac0_axi_data_ready         ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_cpu_mac0_axi_data_last          ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_cpu_mac0_time_irq               ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_cpu_mac0_frame_seq              ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp0_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC1
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac1_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac1_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac1_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac1_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac1_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac1_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac1_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac1_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac1_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac1_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp1_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC2
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac1_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac1_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac1_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac1_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac1_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac1_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac1_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac1_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac1_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac1_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp1_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC3
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac1_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac1_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac1_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac1_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac1_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac1_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac1_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac1_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac1_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac1_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp1_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC4
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac1_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac1_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac1_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac1_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac1_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac1_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac1_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac1_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac1_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac1_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp1_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC5
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac2_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac2_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac2_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac2_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac2_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac2_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac2_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac2_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac2_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac2_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp2_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC6
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac3_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac3_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac3_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac3_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac3_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac3_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac3_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac3_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac3_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac3_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp3_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif

`ifdef MAC7
    tx_mac_port_mng #(
        .PORT_NUM                           (PORT_NUM                  ) ,                   // 交换机的端口数
        .METADATA_WIDTH                     (METADATA_WIDTH            ) ,                   // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH       ) ,                   // Mac_port_mng 数据位宽
        .PORT_FIFO_PRI_NUM                  (PORT_FIFO_PRI_NUM         ) ,                   // 支持端口优先级 FIFO 的数量
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH          )  // 聚合总线输出 
    )(
        .i_clk                              (i_clk                     ) ,   // 250MHz
        .i_rst                              (i_rst                     ) ,
            /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
    `ifdef TSN_AS
        // 数据流信息 
        .i_as_port_link                     () , // 端口的连接状态
        .i_as_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_as_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_as_axi_data                      () , // 端口数据流
        .i_as_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_as_axi_data_valid                () , // 端口数据有效
        .i_as_axi_data_user                 () , // AS 协议信息流
        .o_as_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_as_axi_data_last                 () , // 数据流结束标识
    `endif
    `ifdef LLDP
        // 数据流信息 
        .i_lldp_port_link                   () , // 端口的连接状态
        .i_lldp_port_speed                  () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_lldp_port_filter_preamble_v      () , // 端口是否过滤前导码信息
        .i_lldp_axi_data                    () , // 端口数据流
        .i_lldp_axi_data_keep               () , // 端口数据流掩码，有效字节指示
        .i_lldp_axi_data_valid              () , // 端口数据有效
        .i_lldp_axi_data_user               () , // LLDP 协议信息流
        .o_lldp_axi_data_ready              () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_lldp_axi_data_last               () , // 数据流结束标识
    `endif
    `ifdef TSN_CB
        // 数据流信息 
        .i_cb_port_link                     () , // 端口的连接状态
        .i_cb_port_speed                    () , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cb_port_filter_preamble_v        () , // 端口是否过滤前导码信息
        .i_cb_axi_data                      () , // 端口数据流
        .i_cb_axi_data_keep                 () , // 端口数据流掩码，有效字节指示
        .i_cb_axi_data_valid                () , // 端口数据有效
        .i_cb_axi_data_user                 () , // CB 协议信息流
        .o_cb_axi_data_ready                () , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cb_axi_data_last                 () , // 数据流结束标识
    `endif
        .i_port_txmac_down_regs             () ,
        .i_store_forward_enable_regs        () ,
        .i_port_1g_interval_num_regs        () ,
        .i_port_100m_interval_num_regs      () ,
        .o_port_tx_byte_cnt                 () ,
        .o_port_tx_frame_cnt                () ,
        .o_port_diag_state                  () ,
        /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
        // 聚合总线输入数据流
        .i_cross_rx_data                    () , // 聚合总线数据流，最高位表示crcerr
        .i_cross_rx_data_valid              () , // 聚合总线数据流有效信号
        .i_cross_rx_data_keep               () , // 端口数据流掩码，有效字节指示
        .o_cross_rx_data_ready              () , // 下游模块反压流水线
        .i_mac_axi_data_last                () , // 数据流结束标识
        //聚合总线输入信息流
        .i_cross_metadata                   () , // 聚合总线 metadata 数据
        .i_cross_metadata_valid             () , // 聚合总线 metadata 数据有效信号
        .i_cross_metadata_last              () , // 信息流结束标识
        .o_cross_metadata_ready             () ,  // 下游模块反压流水线  
        /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
        // 数据流信息 
        .o_mac_port_link                    (o_mac4_port_link                  ) , // 端口的连接状态
        .o_mac_port_speed                   (o_mac4_port_speed                 ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .o_mac_port_filter_preamble_v       (o_mac4_port_filter_preamble_v     ) , // 端口是否过滤前导码信息
        .o_mac_axi_data                     (o_mac4_axi_data                   ) , // 端口数据流
        .o_mac_axi_data_keep                (o_mac4_axi_data_keep              ) , // 端口数据流掩码，有效字节指示
        .o_mac_axi_data_valid               (o_mac4_axi_data_valid             ) , // 端口数据有效
        .i_mac_axi_data_ready               (i_mac4_axi_data_ready             ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac_axi_data_last                (o_mac4_axi_data_last              ) , // 数据流结束标识
        // 报文时间打时间戳                      
        .o_mac_time_irq                     (o_mac4_time_irq                   ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (o_mac4_frame_seq                  ) , // 帧序列号
        .o_timestamp_addr                   (o_timestamp4_addr                 )   // 打时间戳存储的 RAM 地址
    );

`endif



endmodule