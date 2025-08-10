module switch_core_top#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽
    parameter                                                   ADDR_WIDTH              =      6        ,  // 地址表的深度     
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,  // 出端口优先级个数
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
`ifdef CPU_MAC
    // RXMAC 输入接口
    input               wire                                    i_cpu_mac0_port_link                , // 端口的连接状态
    input               wire   [1:0]                            i_cpu_mac0_port_speed               , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_cpu_mac0_port_filter_preamble_v   , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_cpu_mac0_axi_data                 , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_cpu_mac0_axi_data_keep            , // 端口数据流掩码，有效字节指示
    input               wire                                    i_cpu_mac0_axi_data_valid           , // 端口数据有效
    output              wire                                    o_cpu_mac0_axi_data_ready           , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_cpu_mac0_axi_data_last            , // 数据流结束标识
    output              wire                                    o_rxcpu_mac0_time_irq               , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxcpu_mac0_frame_seq              , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp0_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC 输入接口
    output              wire                                    o_cpu_mac0_port_link                , // 端口的连接状态
    output              wire   [1:0]                            o_cpu_mac0_port_speed               , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_cpu_mac0_port_filter_preamble_v   , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_cpu_mac0_axi_data                 , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_cpu_mac0_axi_data_keep            , // 端口数据流掩码，有效字节指示
    output              wire                                    o_cpu_mac0_axi_data_valid           , // 端口数据有效
    input               wire                                    i_cpu_mac0_axi_data_ready           , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_cpu_mac0_axi_data_last            , // 数据流结束标识
    output              wire                                    o_txcpu_mac0_time_irq               , // 打时间戳中断信号
    output              wire  [7:0]                             o_txcpu_mac0_frame_seq              , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp0_addr                 , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC1
    // RXMAC
    input               wire                                    i_mac1_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac1_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac1_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac1_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac1_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac1_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac1_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac1_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac1_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac1_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp1_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac1_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac1_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac1_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac1_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac1_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_txmac1_axi_data_valid             , // 端口数据有效
    input               wire                                    i_txmac1_axi_data_ready             , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_txmac1_axi_data_last              , // 数据流结束标识
    output              wire                                    o_mac1_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac1_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp1_addr                   , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC2
    // RXMAC 
    input               wire                                    i_mac2_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac2_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac2_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac2_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac2_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac2_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac2_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac2_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac2_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac2_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp2_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac2_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac2_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac2_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac2_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac2_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac2_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac2_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac2_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac2_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac2_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp2_addr                 , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC3
    // RXMAC
    input               wire                                    i_mac3_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac3_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac3_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac3_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac3_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac3_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac3_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac3_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac3_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac3_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp3_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac3_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac3_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac3_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac3_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac3_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac3_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac3_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac3_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac3_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac3_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp3_addr                 , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC4
    // RXMAC
    input               wire                                    i_mac4_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac4_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac4_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac4_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac4_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac4_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac4_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac4_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac4_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac4_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp4_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac4_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac4_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac4_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac4_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac4_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac4_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac4_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac4_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac4_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac4_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp4_addr                 , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC5
    // RXMAC
    input               wire                                    i_mac5_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac5_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac5_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac5_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac5_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac5_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac5_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac5_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac5_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac5_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp5_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac5_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac5_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac5_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac5_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac5_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac5_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac5_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac5_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac5_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac5_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp5_addr                 , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC6
    // RXMAC
    input               wire                                    i_mac6_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac6_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac6_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac6_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac6_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac6_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac6_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac6_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac6_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac6_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp6_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac6_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac6_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac6_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac6_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac6_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac6_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac6_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac6_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac6_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac6_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp6_addr                 , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC7
    // RXMAC
    input               wire                                    i_mac7_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac7_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac7_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac7_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac7_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac7_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac7_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac7_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac7_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac7_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp7_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC
    output              wire                                    o_mac7_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac7_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac7_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac7_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac7_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac7_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac7_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac7_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac7_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac7_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp7_addr                 , // 打时间戳存储的 RAM 地址
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

/*----------------------------- 数据流接口 --------------------*/
`ifdef CPU_MAC 
    // RXMAC TO CROSSBAR
    wire                                    w_mac0_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac0_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac0_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac0_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac0_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac0_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac0_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac0_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac0_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac0_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac0_cross_metadata_ready         ; // 下游模块反压流水线 
    // CROSSBAR TO TXMAC
        //pmac通道数据
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac0_tx_axis_data            ; 
    wire    [15:0]                              w_pmac0_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac0_tx_axis_keep            ; 
    wire                                        w_pmac0_tx_axis_last            ; 
    wire                                        w_pmac0_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac0_ethertype               ; 
    wire                                        w_pmac0_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac0_tx_axis_data            ;
    wire    [15:0]                              w_emac0_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac0_tx_axis_keep            ;
    wire                                        w_emac0_tx_axis_last            ;
    wire                                        w_emac0_tx_axis_valid           ;
    wire    [15:0]                              w_emac0_ethertype               ;
    wire                                        w_emac0_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac0_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac0_scheduing_rst            ;
    wire                                        w_mac0_scheduing_rst_vld        ; 
`endif
`ifdef MAC1 
    wire                                    w_mac1_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac1_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac1_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac1_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac1_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac1_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac1_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac1_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac1_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac1_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac1_cross_metadata_ready         ; // 下游模块反压流水线 

    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac1_tx_axis_data            ; 
    wire    [15:0]                              w_pmac1_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac1_tx_axis_keep            ; 
    wire                                        w_pmac1_tx_axis_last            ; 
    wire                                        w_pmac1_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac1_ethertype               ; 
    wire                                        w_pmac1_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac1_tx_axis_data            ;
    wire    [15:0]                              w_emac1_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac1_tx_axis_keep            ;
    wire                                        w_emac1_tx_axis_last            ;
    wire                                        w_emac1_tx_axis_valid           ;
    wire    [15:0]                              w_emac1_ethertype               ;
    wire                                        w_emac1_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac1_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac1_scheduing_rst            ;
    wire                                        w_mac1_scheduing_rst_vld        ; 
`endif
`ifdef MAC2 
    wire                                    w_mac2_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac2_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac2_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac2_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac2_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac2_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac2_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac2_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac2_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac2_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac2_cross_metadata_ready         ; // 下游模块反压流水线 
        // CROSSBAR TO TXMAC
        //pmac通道数据
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac2_tx_axis_data            ; 
    wire    [15:0]                              w_pmac2_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac2_tx_axis_keep            ; 
    wire                                        w_pmac2_tx_axis_last            ; 
    wire                                        w_pmac2_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac2_ethertype               ; 
    wire                                        w_pmac2_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac2_tx_axis_data            ;
    wire    [15:0]                              w_emac2_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac2_tx_axis_keep            ;
    wire                                        w_emac2_tx_axis_last            ;
    wire                                        w_emac2_tx_axis_valid           ;
    wire    [15:0]                              w_emac2_ethertype               ;
    wire                                        w_emac2_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac2_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac2_scheduing_rst            ;
    wire                                        w_mac2_scheduing_rst_vld        ; 
`endif
`ifdef MAC3 
    wire                                    w_mac3_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac3_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac3_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac3_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac3_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac3_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac3_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac3_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac3_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac3_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac3_cross_metadata_ready         ; // 下游模块反压流水线 
    
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac3_tx_axis_data            ; 
    wire    [15:0]                              w_pmac3_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac3_tx_axis_keep            ; 
    wire                                        w_pmac3_tx_axis_last            ; 
    wire                                        w_pmac3_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac3_ethertype               ; 
    wire                                        w_pmac3_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac3_tx_axis_data            ;
    wire    [15:0]                              w_emac3_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac3_tx_axis_keep            ;
    wire                                        w_emac3_tx_axis_last            ;
    wire                                        w_emac3_tx_axis_valid           ;
    wire    [15:0]                              w_emac3_ethertype               ;
    wire                                        w_emac3_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac3_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac3_scheduing_rst            ;
    wire                                        w_mac3_scheduing_rst_vld        ; 
`endif
`ifdef MAC4 
    wire                                    w_mac4_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac4_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac4_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac4_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac4_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac4_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac4_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac4_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac4_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac4_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac4_cross_metadata_ready         ; // 下游模块反压流水线 

    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac4_tx_axis_data            ; 
    wire    [15:0]                              w_pmac4_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac4_tx_axis_keep            ; 
    wire                                        w_pmac4_tx_axis_last            ; 
    wire                                        w_pmac4_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac4_ethertype               ; 
    wire                                        w_pmac4_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac4_tx_axis_data            ;
    wire    [15:0]                              w_emac4_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac4_tx_axis_keep            ;
    wire                                        w_emac4_tx_axis_last            ;
    wire                                        w_emac4_tx_axis_valid           ;
    wire    [15:0]                              w_emac4_ethertype               ;
    wire                                        w_emac4_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac4_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac4_scheduing_rst            ;
    wire                                        w_mac4_scheduing_rst_vld        ; 
`endif
`ifdef MAC5 
    wire                                    w_mac5_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac5_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac5_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac5_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac5_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac5_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac5_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac5_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac5_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac5_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac5_cross_metadata_ready         ; // 下游模块反压流水线 
    
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac5_tx_axis_data            ; 
    wire    [15:0]                              w_pmac5_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac5_tx_axis_keep            ; 
    wire                                        w_pmac5_tx_axis_last            ; 
    wire                                        w_pmac5_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac5_ethertype               ; 
    wire                                        w_pmac5_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac5_tx_axis_data            ;
    wire    [15:0]                              w_emac5_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac5_tx_axis_keep            ;
    wire                                        w_emac5_tx_axis_last            ;
    wire                                        w_emac5_tx_axis_valid           ;
    wire    [15:0]                              w_emac5_ethertype               ;
    wire                                        w_emac5_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac5_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac5_scheduing_rst            ;
    wire                                        w_mac5_scheduing_rst_vld        ; 
`endif
`ifdef MAC6 
    wire                                    w_mac6_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac6_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac6_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac6_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac6_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac6_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac6_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac6_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac6_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac6_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac6_cross_metadata_ready         ; // 下游模块反压流水线 

    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac6_tx_axis_data            ; 
    wire    [15:0]                              w_pmac6_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac6_tx_axis_keep            ; 
    wire                                        w_pmac6_tx_axis_last            ; 
    wire                                        w_pmac6_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac6_ethertype               ; 
    wire                                        w_pmac6_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac6_tx_axis_data            ;
    wire    [15:0]                              w_emac6_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac6_tx_axis_keep            ;
    wire                                        w_emac6_tx_axis_last            ;
    wire                                        w_emac6_tx_axis_valid           ;
    wire    [15:0]                              w_emac6_ethertype               ;
    wire                                        w_emac6_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac6_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac6_scheduing_rst            ;
    wire                                        w_mac6_scheduing_rst_vld        ; 
`endif
`ifdef MAC7 
    wire                                    w_mac7_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac7_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac7_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac7_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac7_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac7_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac7_cross_axi_data_last          ; // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_mac7_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_mac7_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_mac7_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_mac7_cross_metadata_ready         ; // 下游模块反压流水线 

    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac7_tx_axis_data            ; 
    wire    [15:0]                              w_pmac7_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac7_tx_axis_keep            ; 
    wire                                        w_pmac7_tx_axis_last            ; 
    wire                                        w_pmac7_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac7_ethertype               ; 
    wire                                        w_pmac7_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac7_tx_axis_data            ;
    wire    [15:0]                              w_emac7_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac7_tx_axis_keep            ;
    wire                                        w_emac7_tx_axis_last            ;
    wire                                        w_emac7_tx_axis_valid           ;
    wire    [15:0]                              w_emac7_ethertype               ;
    wire                                        w_emac7_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac7_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM:0]                w_mac7_scheduing_rst            ;
    wire                                        w_mac7_scheduing_rst_vld        ; 
`endif

`ifdef TSN_AS
    wire                                    w_tsn_as_cross_port_link            , // 端口的连接状态
    wire   [1:0]                            w_tsn_as_cross_port_speed           , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_tsn_as_cross_port_axi_data        , // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_tsn_as_cross_axi_data_keep        , // 端口数据流掩码，有效字节指示
    wire                                    w_tsn_as_cross_axi_data_valid       , // 端口数据有效
    wire                                    w_tsn_as_cross_axi_data_ready       , // 交叉总线聚合架构反压流水线信号
    wire                                    w_tsn_as_cross_axi_data_last        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]             w_tsn_as_cross_metadata             , // 总线 metadata 数据
    wire                                    w_tsn_as_cross_metadata_valid       , // 总线 metadata 数据有效信号
    wire                                    w_tsn_as_cross_metadata_last        , // 信息流结束标识
    wire                                    w_tsn_as_cross_metadata_ready         // 下游模块反压流水线 
`endif

`ifdef LLDP
    wire                                     w_lldp_cross_port_link              , // 端口的连接状态
    wire   [1:0]                             w_lldp_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]              w_lldp_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]        w_lldp_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    wire                                     w_lldp_cross_axi_data_valid         , // 端口数据有效
    wire                                     w_lldp_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    wire                                     w_lldp_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    wire   [METADATA_WIDTH-1:0]              w_lldp_cross_metadata               , // 总线 metadata 数据
    wire                                     w_lldp_cross_metadata_valid         , // 总线 metadata 数据有效信号
    wire                                     w_lldp_cross_metadata_last          , // 信息流结束标识
    wire                                     w_lldp_cross_metadata_ready           // 下游模块反压流水线 
`endif
/*----------------------------- 交换表接口 --------------------*/
`ifdef CPU_MAC 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_cpu_hash_key                 ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac_cpu                          ; // 目的 mac 的值
    wire                                    w_dmac_cpu_vld                      ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_cpu_hash_key                 ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac_cpu                          ; // 源 mac 的值
    wire                                    w_smac_cpu_vld                      ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_cpu_port                       ;
    wire                                    w_tx_cpu_port_vld                   ;
`endif
`ifdef MAC1
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac1_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac1                             ; // 目的 mac 的值
    wire                                    w_dmac1_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac1_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac1                             ; // 源 mac 的值
    wire                                    w_smac1_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_1_port                         ;
    wire                                    w_tx_1_port_vld                     ;
`endif
`ifdef MAC2
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac2_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac2                             ; // 目的 mac 的值
    wire                                    w_dmac2_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac2_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac2                             ; // 源 mac 的值
    wire                                    w_smac2_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_2_port                         ;
    wire                                    w_tx_2_port_vld                     ;
`endif
`ifdef MAC3
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac3_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac3                             ; // 目的 mac 的值
    wire                                    w_dmac3_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac3_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac3                             ; // 源 mac 的值
    wire                                    w_smac3_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_3_port                         ;
    wire                                    w_tx_3_port_vld                     ;
`endif
`ifdef MAC4
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac4_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac4                             ; // 目的 mac 的值
    wire                                    w_dmac4_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac4_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac4                             ; // 源 mac 的值
    wire                                    w_smac4_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_4_port                         ;
    wire                                    w_tx_4_port_vld                     ;
`endif
`ifdef MAC5
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac5_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac5                             ; // 目的 mac 的值
    wire                                    w_dmac5_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac5_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac5                             ; // 源 mac 的值
    wire                                    w_smac5_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_5_port                         ;
    wire                                    w_tx_5_port_vld                     ;
`endif
`ifdef MAC6
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac6_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac6                             ; // 目的 mac 的值
    wire                                    w_dmac6_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac6_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac6                             ; // 源 mac 的值
    wire                                    w_smac6_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_6_port                         ;
    wire                                    w_tx_6_port_vld                     ;
`endif
`ifdef MAC7
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac7_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac7                             ; // 目的 mac 的值
    wire                                    w_dmac7_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac7_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac7                             ; // 源 mac 的值
    wire                                    w_smac7_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_7_port                         ;
    wire                                    w_tx_7_port_vld                     ;
`endif

/*----------------------------- 寄存器平台接口  --------------------*/
wire                                        w_refresh_list_pulse                ; // 刷新寄存器列表（状态寄存器和控制寄存器
wire                                        w_switch_err_cnt_clr                ; // 刷新错误计数器
wire                                        w_switch_err_cnt_stat               ; // 刷新错误状态寄存器

wire                                        w_rxmac_reg_bus_we                  ;
wire   [REG_ADDR_BUS_WIDTH-1:0]             w_rxmac_reg_bus_we_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_rxmac_reg_bus_we_din              ;
wire                                        w_rxmac_reg_bus_we_din_v            ;
wire                                        w_rxmac_reg_bus_rd                  ;
wire   [REG_ADDR_BUS_WIDTH-1:0]             w_rxmac_reg_bus_rd_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_rxmac_reg_bus_rd_dout             ;
wire                                        w_rxmac_reg_bus_rd_dout_v           ;

wire                                        w_txmac_reg_bus_we                  ;
wire   [REG_ADDR_BUS_WIDTH-1:0]             w_txmac_reg_bus_we_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_txmac_reg_bus_we_din              ;
wire                                        w_txmac_reg_bus_we_din_v            ;
wire                                        w_txmac_reg_bus_rd                  ;
wire   [REG_ADDR_BUS_WIDTH-1:0]             w_txmac_reg_bus_rd_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_txmac_reg_bus_rd_dout             ;
wire                                        w_txmac_reg_bus_rd_dout_v           ;

wire                                        w_swlist_reg_bus_we                 ;
wire   [REG_ADDR_BUS_WIDTH-1:0]             w_swlist_reg_bus_we_addr            ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_swlist_reg_bus_we_din             ;
wire                                        w_swlist_reg_bus_we_din_v           ;
wire                                        w_swlist_reg_bus_rd                 ;
wire   [REG_ADDR_BUS_WIDTH-1:0]             w_swlist_reg_bus_rd_addr            ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_swlist_reg_bus_rd_dout            ;
wire                                        w_swlist_reg_bus_rd_dout_v          ;
/*---------------------------- RXMAC ---------------------------*/
rx_mac_mng #(
            .PORT_NUM                (  PORT_NUM                      ) ,  // 交换机的端口数
            .REG_ADDR_BUS_WIDTH      (  REG_ADDR_BUS_WIDTH            ) ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH      (  REG_DATA_BUS_WIDTH            ) ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH          (  METADATA_WIDTH                ) ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH     (  PORT_MNG_DATA_WIDTH           ) ,  // Mac_port_mng 数据位宽 
            .HASH_DATA_WIDTH         (  HASH_DATA_WIDTH               ) ,  // 哈希计算的值的位宽
            .CROSS_DATA_WIDTH        (  CROSS_DATA_WIDTH              )  // 聚合总线输出 
)rx_mac_mng_inst (
    .i_clk                               (i_clk                       ) ,   // 250MHz
    .i_rst                               (i_rst                       ) ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse                ( w_refresh_list_pulse      ), // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr                ( w_switch_err_cnt_clr      ), // 刷新错误计数器
    .i_switch_err_cnt_stat               ( w_switch_err_cnt_stat     ), // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_switch_reg_bus_we                 ( w_rxmac_reg_bus_we        ), // 寄存器写使能
    .i_switch_reg_bus_we_addr            ( w_rxmac_reg_bus_we_addr   ), // 寄存器写地址
    .i_switch_reg_bus_we_din             ( w_rxmac_reg_bus_we_din    ), // 寄存器写数据
    .i_switch_reg_bus_we_din_v           ( w_rxmac_reg_bus_we_din_v  ), // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_switch_reg_bus_rd                 ( w_rxmac_reg_bus_rd        ), // 寄存器读使能
    .i_switch_reg_bus_rd_addr            ( w_rxmac_reg_bus_rd_addr   ), // 寄存器读地址
    .o_switch_reg_bus_we_dout            ( w_rxmac_reg_bus_rd_dout   ), // 读出寄存器数据
    .o_switch_reg_bus_we_dout_v          ( w_rxmac_reg_bus_rd_dout_v ), // 读数据有效使能
    /*---------------------------------------- CPU_MAC数据流 -------------------------------------------*/
`ifdef CPU_MAC
    // 数据流信息 
    .i_cpu_mac0_port_link                ( i_cpu_mac0_port_link                   ), // 端口的连接状态
    .i_cpu_mac0_port_speed               ( i_cpu_mac0_port_speed                  ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_cpu_mac0_port_filter_preamble_v   ( i_cpu_mac0_port_filter_preamble_v      ), // 端口是否过滤前导码信息
    .i_cpu_mac0_axi_data                 ( i_cpu_mac0_axi_data                    ), // 端口数据流
    .i_cpu_mac0_axi_data_keep            ( i_cpu_mac0_axi_data_keep               ), // 端口数据流掩码，有效字节指示
    .i_cpu_mac0_axi_data_valid           ( i_cpu_mac0_axi_data_valid              ), // 端口数据有效
    .o_cpu_mac0_axi_data_ready           ( o_cpu_mac0_axi_data_ready              ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_cpu_mac0_axi_data_last            ( i_cpu_mac0_axi_data_last               ), // 数据流结束标识
    // 报文时间打时间戳
    .o_cpu_mac0_time_irq                 ( o_rxcpu_mac0_time_irq                  ), // 打时间戳中断信号
    .o_cpu_mac0_frame_seq                ( o_rxcpu_mac0_frame_seq                 ), // 帧序列号
    .o_timestamp0_addr                   ( o_rxtimestamp0_addr                    ), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac_cpu_hash_key                 ( w_dmac_cpu_hash_key                    ), // 目的 mac 的哈希值
    .o_dmac_cpu                          ( w_dmac_cpu                             ), // 目的 mac 的值
    .o_dmac_cpu_vld                      ( w_dmac_cpu_vld                         ), // dmac_vld
    .o_smac_cpu_hash_key                 ( w_smac_cpu_hash_key                    ), // 源 mac 的值有效标识
    .o_smac_cpu                          ( w_smac_cpu                             ), // 源 mac 的值
    .o_smac_cpu_vld                      ( w_smac_cpu_vld                         ), // smac_vld
              
    .i_tx_cpu_port                       ( w_tx_cpu_port                          ), // 交换表模块返回的查表端口信息
    .i_tx_cpu_port_vld                   ( w_tx_cpu_port_vld                      ),
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac0_cross_port_link              ( w_mac0_cross_port_link                 ), // 端口的连接状态
    .o_mac0_cross_port_speed             ( w_mac0_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac0_cross_port_axi_data          ( w_mac0_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac0_cross_axi_data_keep          ( w_mac0_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac0_cross_axi_data_valid         ( w_mac0_cross_axi_data_valid            ), // 端口数据有效
    .i_mac0_cross_axi_data_ready         ( w_mac0_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac0_cross_axi_data_last          ( w_mac0_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac0_cross_metadata               ( w_mac0_cross_metadata                 ), // 总线 metadata 数据
    .o_mac0_cross_metadata_valid         ( w_mac0_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac0_cross_metadata_last          ( w_mac0_cross_metadata_last            ), // 信息流结束标识
    .i_mac0_cross_metadata_ready         ( w_mac0_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC1 数据流 -------------------------------------------*/
`ifdef MAC1
    // 数据流信息 
    .i_mac1_port_link                    ( i_mac1_port_link                      ), // 端口的连接状态
    .i_mac1_port_speed                   ( i_mac1_port_speed                     ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac1_port_filter_preamble_v       ( i_mac1_port_filter_preamble_v         ), // 端口是否过滤前导码信息
    .i_mac1_axi_data                     ( i_mac1_axi_data                       ), // 端口数据流
    .i_mac1_axi_data_keep                ( i_mac1_axi_data_keep                  ), // 端口数据流掩码，有效字节指示
    .i_mac1_axi_data_valid               ( i_mac1_axi_data_valid                 ), // 端口数据有效
    .o_mac1_axi_data_ready               ( o_mac1_axi_data_ready                 ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac1_axi_data_last                ( i_mac1_axi_data_last                  ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac1_time_irq                     ( o_rxmac1_time_irq                     ), // 打时间戳中断信号
    .o_mac1_frame_seq                    ( o_rxmac1_frame_seq                    ), // 帧序列号
    .o_timestamp1_addr                   ( o_rxtimestamp1_addr                   ), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac1_hash_key                    ( w_dmac1_hash_key                 ), // 目的 mac 的哈希值
    .o_dmac1                             ( w_dmac1                          ), // 目的 mac 的值
    .o_dmac1_vld                         ( w_dmac1_vld                      ), // dmac_vld
    .o_smac1_hash_key                    ( w_smac1_hash_key                 ), // 源 mac 的值有效标识
    .o_smac1                             ( w_smac1                          ), // 源 mac 的值
    .o_smac1_vld                         ( w_smac1_vld                      ), // smac_vld

    .i_tx_1_port                         ( w_tx_1_port                      ), // 交换表模块返回的查表端口信息
    .i_tx_1_port_vld                     ( w_tx_1_port_vld                  ),
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac1_cross_port_link              ( w_mac1_cross_port_link                 ), // 端口的连接状态
    .o_mac1_cross_port_speed             ( w_mac1_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac1_cross_port_axi_data          ( w_mac1_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac1_cross_axi_data_keep          ( w_mac1_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac1_cross_axi_data_valid         ( w_mac1_cross_axi_data_valid            ), // 端口数据有效
    .i_mac1_cross_axi_data_ready         ( w_mac1_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac1_cross_axi_data_last          ( w_mac1_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac1_cross_metadata               ( w_mac1_cross_metadata                 ), // 总线 metadata 数据
    .o_mac1_cross_metadata_valid         ( w_mac1_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac1_cross_metadata_last          ( w_mac1_cross_metadata_last            ), // 信息流结束标识
    .i_mac1_cross_metadata_ready         ( w_mac1_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC2 数据流 -------------------------------------------*/
`ifdef MAC2
    // 数据流信息 
    .i_mac2_port_link                   ( i_mac2_port_link                   ) , // 端口的连接状态
    .i_mac2_port_speed                  ( i_mac2_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac2_port_filter_preamble_v      ( i_mac2_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
    .i_mac2_axi_data                    ( i_mac2_axi_data                    ) , // 端口数据流
    .i_mac2_axi_data_keep               ( i_mac2_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
    .i_mac2_axi_data_valid              ( i_mac2_axi_data_valid              ) , // 端口数据有效
    .o_mac2_axi_data_ready              ( o_mac2_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac2_axi_data_last               ( i_mac2_axi_data_last               ) , // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac2_time_irq                    ( o_rxmac2_time_irq                    ) , // 打时间戳中断信号
    .o_mac2_frame_seq                   ( o_rxmac2_frame_seq                   ) , // 帧序列号
    .o_timestamp2_addr                  ( o_rxtimestamp2_addr                  ) , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac2_hash_key                   ( w_dmac2_hash_key      ) , // 目的 mac 的哈希值
    .o_dmac2                            ( w_dmac2               ) , // 目的 mac 的值
    .o_dmac2_vld                        ( w_dmac2_vld           ) , // dmac_vld
    .o_smac2_hash_key                   ( w_smac2_hash_key      ) , // 源 mac 的值有效标识
    .o_smac2                            ( w_smac2               ) , // 源 mac 的值
    .o_smac2_vld                        ( w_smac2_vld           ) , // smac_vld
 
    .i_tx_2_port                        ( w_tx_2_port           ) , // 交换表模块返回的查表端口信息
    .i_tx_2_port_vld                    ( w_tx_2_port_vld       ) ,
/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac2_cross_port_link              ( w_mac2_cross_port_link                 ), // 端口的连接状态
    .o_mac2_cross_port_speed             ( w_mac2_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac2_cross_port_axi_data          ( w_mac2_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac2_cross_axi_data_keep          ( w_mac2_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac2_cross_axi_data_valid         ( w_mac2_cross_axi_data_valid            ), // 端口数据有效
    .i_mac2_cross_axi_data_ready         ( w_mac2_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac2_cross_axi_data_last          ( w_mac2_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac2_cross_metadata               ( w_mac2_cross_metadata                 ), // 总线 metadata 数据
    .o_mac2_cross_metadata_valid         ( w_mac2_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac2_cross_metadata_last          ( w_mac2_cross_metadata_last            ), // 信息流结束标识
    .i_mac2_cross_metadata_ready         ( w_mac2_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC3 数据流 -------------------------------------------*/
`ifdef MAC3
    // 数据流信息 
    .i_mac3_port_link                   ( i_mac3_port_link                   ) , // 端口的连接状态
    .i_mac3_port_speed                  ( i_mac3_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac3_port_filter_preamble_v      ( i_mac3_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
    .i_mac3_axi_data                    ( i_mac3_axi_data                    ) , // 端口数据流
    .i_mac3_axi_data_keep               ( i_mac3_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
    .i_mac3_axi_data_valid              ( i_mac3_axi_data_valid              ) , // 端口数据有效
    .o_mac3_axi_data_ready              ( o_mac3_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac3_axi_data_last               ( i_mac3_axi_data_last               ) , // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac3_time_irq                    ( o_rxmac3_time_irq        ) , // 打时间戳中断信号
    .o_mac3_frame_seq                   ( o_rxmac3_frame_seq       ) , // 帧序列号
    .o_timestamp3_addr                  ( o_rxtimestamp3_addr      ) , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac3_hash_key                   ( w_dmac3_hash_key      ) , // 目的 mac 的哈希值
    .o_dmac3                            ( w_dmac3               ) , // 目的 mac 的值
    .o_dmac3_vld                        ( w_dmac3_vld           ) , // dmac_vld
    .o_smac3_hash_key                   ( w_smac3_hash_key      ) , // 源 mac 的值有效标识
    .o_smac3                            ( w_smac3               ) , // 源 mac 的值
    .o_smac3_vld                        ( w_smac3_vld           ) , // smac_vld
 
    .i_tx_3_port                        ( w_tx_3_port           ) , // 交换表模块返回的查表端口信息
    .i_tx_3_port_vld                    ( w_tx_3_port_vld       ) ,
/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac3_cross_port_link              ( w_mac3_cross_port_link                 ), // 端口的连接状态
    .o_mac3_cross_port_speed             ( w_mac3_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac3_cross_port_axi_data          ( w_mac3_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac3_cross_axi_data_keep          ( w_mac3_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac3_cross_axi_data_valid         ( w_mac3_cross_axi_data_valid            ), // 端口数据有效
    .i_mac3_cross_axi_data_ready         ( w_mac3_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac3_cross_axi_data_last          ( w_mac3_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac3_cross_metadata               ( w_mac3_cross_metadata                 ), // 总线 metadata 数据
    .o_mac3_cross_metadata_valid         ( w_mac3_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac3_cross_metadata_last          ( w_mac3_cross_metadata_last            ), // 信息流结束标识
    .i_mac3_cross_metadata_ready         ( w_mac3_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC4 数据流 -------------------------------------------*/
`ifdef MAC4
    // 数据流信息 
    .i_mac4_port_link                   ( i_mac4_port_link                   ) , // 端口的连接状态
    .i_mac4_port_speed                  ( i_mac4_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac4_port_filter_preamble_v      ( i_mac4_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
    .i_mac4_axi_data                    ( i_mac4_axi_data                    ) , // 端口数据流
    .i_mac4_axi_data_keep               ( i_mac4_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
    .i_mac4_axi_data_valid              ( i_mac4_axi_data_valid              ) , // 端口数据有效
    .o_mac4_axi_data_ready              ( o_mac4_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac4_axi_data_last               ( i_mac4_axi_data_last               ) , // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac4_time_irq                    ( o_rxmac4_time_irq        ) , // 打时间戳中断信号
    .o_mac4_frame_seq                   ( o_rxmac4_frame_seq       ) , // 帧序列号
    .o_timestamp4_addr                  ( o_rxtimestamp4_addr      ) , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac4_hash_key                   ( w_dmac4_hash_key      ) , // 目的 mac 的哈希值
    .o_dmac4                            ( w_dmac4               ) , // 目的 mac 的值
    .o_dmac4_vld                        ( w_dmac4_vld           ) , // dmac_vld
    .o_smac4_hash_key                   ( w_smac4_hash_key      ) , // 源 mac 的值有效标识
    .o_smac4                            ( w_smac4               ) , // 源 mac 的值
    .o_smac4_vld                        ( w_smac4_vld           ) , // smac_vld
 
    .i_tx_4_port                        ( w_tx_4_port           ) , // 交换表模块返回的查表端口信息
    .i_tx_4_port_vld                    ( w_tx_4_port_vld       ) ,
/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac4_cross_port_link              ( w_mac4_cross_port_link                 ), // 端口的连接状态
    .o_mac4_cross_port_speed             ( w_mac4_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac4_cross_port_axi_data          ( w_mac4_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac4_cross_axi_data_keep          ( w_mac4_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac4_cross_axi_data_valid         ( w_mac4_cross_axi_data_valid            ), // 端口数据有效
    .i_mac4_cross_axi_data_ready         ( w_mac4_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac4_cross_axi_data_last          ( w_mac4_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac4_cross_metadata               ( w_mac4_cross_metadata                 ), // 总线 metadata 数据
    .o_mac4_cross_metadata_valid         ( w_mac4_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac4_cross_metadata_last          ( w_mac4_cross_metadata_last            ), // 信息流结束标识
    .i_mac4_cross_metadata_ready         ( w_mac4_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC5 数据流 -------------------------------------------*/
`ifdef MAC5
    // 数据流信息 
    .i_mac5_port_link                   ( i_mac5_port_link                   ) , // 端口的连接状态
    .i_mac5_port_speed                  ( i_mac5_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac5_port_filter_preamble_v      ( i_mac5_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
    .i_mac5_axi_data                    ( i_mac5_axi_data                    ) , // 端口数据流
    .i_mac5_axi_data_keep               ( i_mac5_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
    .i_mac5_axi_data_valid              ( i_mac5_axi_data_valid              ) , // 端口数据有效
    .o_mac5_axi_data_ready              ( o_mac5_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac5_axi_data_last               ( i_mac5_axi_data_last               ) , // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac5_time_irq                    ( o_rxmac5_time_irq        ) , // 打时间戳中断信号
    .o_mac5_frame_seq                   ( o_rxmac5_frame_seq       ) , // 帧序列号
    .o_timestamp5_addr                  ( o_rxtimestamp5_addr      ) , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac5_hash_key                   ( w_dmac5_hash_key      ) , // 目的 mac 的哈希值
    .o_dmac5                            ( w_dmac5               ) , // 目的 mac 的值
    .o_dmac5_vld                        ( w_dmac5_vld           ) , // dmac_vld
    .o_smac5_hash_key                   ( w_smac5_hash_key      ) , // 源 mac 的值有效标识
    .o_smac5                            ( w_smac5               ) , // 源 mac 的值
    .o_smac5_vld                        ( w_smac5_vld           ) , // smac_vld

    .i_tx_5_port                        ( w_tx_5_port           ) , // 交换表模块返回的查表端口信息
    .i_tx_5_port_vld                    ( w_tx_5_port_vld       ) ,
/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac5_cross_port_link              ( w_mac5_cross_port_link                 ), // 端口的连接状态
    .o_mac5_cross_port_speed             ( w_mac5_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac5_cross_port_axi_data          ( w_mac5_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac5_cross_axi_data_keep          ( w_mac5_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac5_cross_axi_data_valid         ( w_mac5_cross_axi_data_valid            ), // 端口数据有效
    .i_mac5_cross_axi_data_ready         ( w_mac5_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac5_cross_axi_data_last          ( w_mac5_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac5_cross_metadata               ( w_mac5_cross_metadata                 ), // 总线 metadata 数据
    .o_mac5_cross_metadata_valid         ( w_mac5_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac5_cross_metadata_last          ( w_mac5_cross_metadata_last            ), // 信息流结束标识
    .i_mac5_cross_metadata_ready         ( w_mac5_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC6 数据流 -------------------------------------------*/
`ifdef MAC6
    // 数据流信息 
    .i_mac6_port_link                   ( i_mac6_port_link                   ) , // 端口的连接状态
    .i_mac6_port_speed                  ( i_mac6_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac6_port_filter_preamble_v      ( i_mac6_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
    .i_mac6_axi_data                    ( i_mac6_axi_data                    ) , // 端口数据流
    .i_mac6_axi_data_keep               ( i_mac6_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
    .i_mac6_axi_data_valid              ( i_mac6_axi_data_valid              ) , // 端口数据有效
    .o_mac6_axi_data_ready              ( o_mac6_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac6_axi_data_last               ( i_mac6_axi_data_last               ) , // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac6_time_irq                    ( o_rxmac6_time_irq        ) , // 打时间戳中断信号
    .o_mac6_frame_seq                   ( o_rxmac6_frame_seq       ) , // 帧序列号
    .o_timestamp6_addr                  ( o_rxtimestamp6_addr      ) , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac6_hash_key                   ( w_dmac6_hash_key      ) , // 目的 mac 的哈希值
    .o_dmac6                            ( w_dmac6               ) , // 目的 mac 的值
    .o_dmac6_vld                        ( w_dmac6_vld           ) , // dmac_vld
    .o_smac6_hash_key                   ( w_smac6_hash_key      ) , // 源 mac 的值有效标识
    .o_smac6                            ( w_smac6               ) , // 源 mac 的值
    .o_smac6_vld                        ( w_smac6_vld           ) , // smac_vld
 
    .i_tx_6_port                        ( w_tx_6_port           ) , // 交换表模块返回的查表端口信息
    .i_tx_6_port_vld                    ( w_tx_6_port_vld       ) ,
/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac6_cross_port_link              ( w_mac6_cross_port_link                 ), // 端口的连接状态
    .o_mac6_cross_port_speed             ( w_mac6_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac6_cross_port_axi_data          ( w_mac6_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac6_cross_axi_data_keep          ( w_mac6_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac6_cross_axi_data_valid         ( w_mac6_cross_axi_data_valid            ), // 端口数据有效
    .i_mac6_cross_axi_data_ready         ( w_mac6_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac6_cross_axi_data_last          ( w_mac6_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac6_cross_metadata               ( w_mac6_cross_metadata                 ), // 总线 metadata 数据
    .o_mac6_cross_metadata_valid         ( w_mac6_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac6_cross_metadata_last          ( w_mac6_cross_metadata_last            ), // 信息流结束标识
    .i_mac6_cross_metadata_ready         ( w_mac6_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC7 数据流 -------------------------------------------*/
`ifdef MAC7
    // 数据流信息 
    .i_mac7_port_link                   ( i_mac7_port_link                   ) , // 端口的连接状态
    .i_mac7_port_speed                  ( i_mac7_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac7_port_filter_preamble_v      ( i_mac7_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
    .i_mac7_axi_data                    ( i_mac7_axi_data                    ) , // 端口数据流
    .i_mac7_axi_data_keep               ( i_mac7_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
    .i_mac7_axi_data_valid              ( i_mac7_axi_data_valid              ) , // 端口数据有效
    .o_mac7_axi_data_ready              ( o_mac7_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac7_axi_data_last               ( i_mac7_axi_data_last               ) , // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac7_time_irq                    ( o_rxmac7_time_irq                  ) , // 打时间戳中断信号
    .o_mac7_frame_seq                   ( o_rxmac7_frame_seq                 ) , // 帧序列号
    .o_timestamp7_addr                  ( o_rxtimestamp7_addr                ) , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_dmac7_hash_key                   ( w_dmac7_hash_key                  ) , // 目的 mac 的哈希值
    .o_dmac7                            ( w_dmac7                           ) , // 目的 mac 的值
    .o_dmac7_vld                        ( w_dmac7_vld                       ) , // dmac_vld
    .o_smac7_hash_key                   ( w_smac7_hash_key                  ) , // 源 mac 的值有效标识
    .o_smac7                            ( w_smac7                           ) , // 源 mac 的值
    .o_smac7_vld                        ( w_smac7_vld                       ) , // smac_vld

    .i_tx_7_port                        ( w_tx_7_port                       ) , // 交换表模块返回的查表端口信息
    .i_tx_7_port_vld                    ( w_tx_7_port_vld                   ) ,
/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac7_cross_port_link              ( w_mac7_cross_port_link                 ), // 端口的连接状态
    .o_mac7_cross_port_speed             ( w_mac7_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac7_cross_port_axi_data          ( w_mac7_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
    .o_mac7_cross_axi_data_keep          ( w_mac7_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .o_mac7_cross_axi_data_valid         ( w_mac7_cross_axi_data_valid            ), // 端口数据有效
    .i_mac7_cross_axi_data_ready         ( w_mac7_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
    .o_mac7_cross_axi_data_last          ( w_mac7_cross_axi_data_last             ), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac7_cross_metadata               ( w_mac7_cross_metadata                 ), // 总线 metadata 数据
    .o_mac7_cross_metadata_valid         ( w_mac7_cross_metadata_valid           ), // 总线 metadata 数据有效信号
    .o_mac7_cross_metadata_last          ( w_mac7_cross_metadata_last            ), // 信息流结束标识
    .i_mac7_cross_metadata_ready         ( w_mac7_cross_metadata_ready           ), // 下游模块反压流水线 
`endif
/*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse                ( ) , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr                ( ) , // 刷新错误计数器
    .i_switch_err_cnt_stat               ( ) , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_switch_reg_bus_we                 ( ) , // 寄存器写使能
    .i_switch_reg_bus_we_addr            ( ) , // 寄存器写地址
    .i_switch_reg_bus_we_din             ( ) , // 寄存器写数据
    .i_switch_reg_bus_we_din_v           ( ) , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_switch_reg_bus_rd                 ( ), // 寄存器读使能
    .i_switch_reg_bus_rd_addr            ( ), // 寄存器读地址
    .o_switch_reg_bus_we_dout            ( ), // 读出寄存器数据
    .o_switch_reg_bus_we_dout_v          ( ) // 读数据有效使能 
);

/*---------------------------- swlist ---------------------------*/
swlist#(
    .PORT_NUM                   ( PORT_NUM                  ),  // 交换机的端口数
    .REG_ADDR_BUS_WIDTH         ( REG_ADDR_BUS_WIDTH        ),  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH        ),  // 接收 MAC 层的配置寄存器数据位宽
    .METADATA_WIDTH             ( METADATA_WIDTH            ),  // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH        ( PORT_MNG_DATA_WIDTH       ),  // Mac_port_mng 数据位宽 
    .HASH_DATA_WIDTH            ( HASH_DATA_WIDTH           ),  // 哈希计算的值的位宽
    .ADDR_WIDTH                 ( ADDR_WIDTH                ),  // 地址表的深度 
    .CROSS_DATA_WIDTH           ( CROSS_DATA_WIDTH          )  // 聚合总线输出 
)swlist_inst (  
    .i_clk                      ( i_clk                     ) ,   // 250MHz
    .i_rst                      ( i_rst                     ) ,   
`ifdef CPU_MAC  
    .i_dmac_cpu_hash_key        (w_dmac_cpu_hash_key        ) , // 目的 mac 的哈希值
    .i_dmac_cpu                 (w_dmac_cpu                 ) , // 目的 mac 的值
    .i_dmac_cpu_vld             (w_dmac_cpu_vld             ) , // dmac_vld
    .i_smac_cpu_hash_key        (w_smac_cpu_hash_key        ) , // 源 mac 的值有效标识
    .i_smac_cpu                 (w_smac_cpu                 ) , // 源 mac 的值
    .i_smac_cpu_vld             (w_smac_cpu_vld             ) , // smac_vld

    .o_tx_cpu_port              (w_tx_cpu_port              ) ,
    .o_tx_cpu_port_vld          (w_tx_cpu_port_vld          ) ,
`endif  
`ifdef MAC0 
    .i_dmac0_hash_key           (w_dmac0_hash_key)            , // 目的 mac 的哈希值
    .i_dmac0                    (w_dmac0         )            , // 目的 mac 的值
    .i_dmac0_vld                (w_dmac0_vld     )            , // dmac_vld
    .i_smac0_hash_key           (w_smac0_hash_key)            , // 源 mac 的值有效标识
    .i_smac0                    (w_smac0         )            , // 源 mac 的值
    .i_smac0_vld                (w_smac0_vld     )            , // smac_vld
 
    .o_tx_0_port                (w_tx_0_port     )            ,
    .o_tx_0_port_vld            (w_tx_0_port_vld )            ,
`endif      
`ifdef MAC1 
    .i_dmac1_hash_key           (w_dmac1_hash_key)            , // 目的 mac 的哈希值
    .i_dmac1                    (w_dmac1         )            , // 目的 mac 的值
    .i_dmac1_vld                (w_dmac1_vld     )            , // dmac_vld
    .i_smac1_hash_key           (w_smac1_hash_key)            , // 源 mac 的值有效标识
    .i_smac1                    (w_smac1         )            , // 源 mac 的值
    .i_smac1_vld                (w_smac1_vld     )            , // smac_vld
 
    .o_tx_1_port                (w_tx_1_port     )            ,
    .o_tx_1_port_vld            (w_tx_1_port_vld )            ,
`endif      
`ifdef MAC2 
    .i_dmac2_hash_key           (w_dmac2_hash_key)            , // 目的 mac 的哈希值
    .i_dmac2                    (w_dmac2         )            , // 目的 mac 的值
    .i_dmac2_vld                (w_dmac2_vld     )            , // dmac_vld
    .i_smac2_hash_key           (w_smac2_hash_key)            , // 源 mac 的值有效标识
    .i_smac2                    (w_smac2         )            , // 源 mac 的值
    .i_smac2_vld                (w_smac2_vld     )            , // smac_vld
 
    .o_tx_2_port                (w_tx_2_port     )            ,
    .o_tx_2_port_vld            (w_tx_2_port_vld )            ,
`endif  
`ifdef MAC3 
    .i_dmac3_hash_key           (w_dmac3_hash_key)            , // 目的 mac 的哈希值
    .i_dmac3                    (w_dmac3         )            , // 目的 mac 的值
    .i_dmac3_vld                (w_dmac3_vld     )            , // dmac_vld
    .i_smac3_hash_key           (w_smac3_hash_key)            , // 源 mac 的值有效标识
    .i_smac3                    (w_smac3         )            , // 源 mac 的值
    .i_smac3_vld                (w_smac3_vld     )            , // smac_vld
 
    .o_tx_3_port                (w_tx_3_port     )            ,
    .o_tx_3_port_vld            (w_tx_3_port_vld )            ,
`endif  
`ifdef MAC4 
    .i_dmac4_hash_key           (w_dmac4_hash_key)            , // 目的 mac 的哈希值
    .i_dmac4                    (w_dmac4         )            , // 目的 mac 的值
    .i_dmac4_vld                (w_dmac4_vld     )            , // dmac_vld
    .i_smac4_hash_key           (w_smac4_hash_key)            , // 源 mac 的值有效标识
    .i_smac4                    (w_smac4         )            , // 源 mac 的值
    .i_smac4_vld                (w_smac4_vld     )            , // smac_vld
 
    .o_tx_4_port                (w_tx_4_port     )            ,
    .o_tx_4_port_vld            (w_tx_4_port_vld )            ,
`endif  
`ifdef MAC5 
    .i_dmac5_hash_key           (w_dmac5_hash_key)            , // 目的 mac 的哈希值
    .i_dmac5                    (w_dmac5         )            , // 目的 mac 的值
    .i_dmac5_vld                (w_dmac5_vld     )            , // dmac_vld
    .i_smac5_hash_key           (w_smac5_hash_key)            , // 源 mac 的值有效标识
    .i_smac5                    (w_smac5         )            , // 源 mac 的值
    .i_smac5_vld                (w_smac5_vld     )            , // smac_vld
 
    .o_tx_5_port                (w_tx_5_port     )            ,
    .o_tx_5_port_vld            (w_tx_5_port_vld )            ,
`endif  
`ifdef MAC6 
    .i_dmac6_hash_key           (w_dmac6_hash_key)            , // 目的 mac 的哈希值
    .i_dmac6                    (w_dmac6         )            , // 目的 mac 的值
    .i_dmac6_vld                (w_dmac6_vld     )            , // dmac_vld
    .i_smac6_hash_key           (w_smac6_hash_key)            , // 源 mac 的值有效标识
    .i_smac6                    (w_smac6         )            , // 源 mac 的值
    .i_smac6_vld                (w_smac6_vld     )            , // smac_vld
 
    .o_tx_6_port                (w_tx_6_port     )            ,
    .o_tx_6_port_vld            (w_tx_6_port_vld )            ,
`endif  
`ifdef MAC7 
    .i_dmac7_hash_key           (w_dmac7_hash_key)            , // 目的 mac 的哈希值
    .i_dmac7                    (w_dmac7         )            , // 目的 mac 的值
    .i_dmac7_vld                (w_dmac7_vld     )            , // dmac_vld
    .i_smac7_hash_key           (w_smac7_hash_key)            , // 源 mac 的值有效标识
    .i_smac7                    (w_smac7         )            , // 源 mac 的值
    .i_smac7_vld                (w_smac7_vld     )            , // smac_vld
 
    .o_tx_7_port                (w_tx_7_port     )            ,
    .o_tx_7_port_vld            (w_tx_7_port_vld )            ,
`endif  
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse       (  w_refresh_list_pulse       )         , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr       (  w_switch_err_cnt_clr       )         , // 刷新错误计数器
    .i_switch_err_cnt_stat      (  w_switch_err_cnt_stat      )         , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_switch_reg_bus_we        ( w_swlist_reg_bus_we         )         , // 寄存器写使能
    .i_switch_reg_bus_we_addr   ( w_swlist_reg_bus_we_addr    )         , // 寄存器写地址
    .i_switch_reg_bus_we_din    ( w_swlist_reg_bus_we_din     )         , // 寄存器写数据
    .i_switch_reg_bus_we_din_v  ( w_swlist_reg_bus_we_din_v   )         , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_switch_reg_bus_rd        ( w_swlist_reg_bus_rd         )         , // 寄存器读使能
    .i_switch_reg_bus_rd_addr   ( w_swlist_reg_bus_rd_addr    )         , // 寄存器读地址
    .o_switch_reg_bus_we_dout   ( w_swlist_reg_bus_rd_dout    )         , // 读出寄存器数据
    .o_switch_reg_bus_we_dout_v ( w_swlist_reg_bus_rd_dout_v  )           // 读数据有效使能
);

crossbar_switch_top#(

    .REG_ADDR_BUS_WIDTH         ( REG_ADDR_BUS_WIDTH         )     ,  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH         )     ,  // 接收 MAC 层的配置寄存器数据位宽
    .METADATA_WIDTH             ( METADATA_WIDTH             )     ,  // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH        ( PORT_MNG_DATA_WIDTH        )     ,
    .PORT_FIFO_PRI_NUM          ( PORT_FIFO_PRI_NUM          )     ,
    .CROSS_DATA_WIDTH           ( CROSS_DATA_WIDTH           )      // 聚合总线输出 
)crossbar_switch_top_inst (
    /*-------------------- RXMAC 输入数据流 -----------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac0_cross_port_link      ( w_mac0_cross_port_link      )        , // 端口的连接状态
    .i_mac0_cross_port_speed     ( w_mac0_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac0_cross_port_axi_data  ( w_mac0_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac0_cross_axi_data_keep  ( w_mac0_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac0_cross_axi_data_valid ( w_mac0_cross_axi_data_valid )        , // 端口数据有效
    .o_mac0_cross_axi_data_ready ( w_mac0_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac0_cross_axi_data_last  ( w_mac0_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac0_cross_metadata       ( w_mac0_cross_metadata       )        , // 总线 metadata 数据
    .i_mac0_cross_metadata_valid ( w_mac0_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac0_cross_metadata_last  ( w_mac0_cross_metadata_last  )        , // 信息流结束标识
    .o_mac0_cross_metadata_ready ( w_mac0_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac1_cross_port_link      ( w_mac1_cross_port_link      )        , // 端口的连接状态
    .i_mac1_cross_port_speed     ( w_mac1_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac1_cross_port_axi_data  ( w_mac1_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac1_cross_axi_data_keep  ( w_mac1_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac1_cross_axi_data_valid ( w_mac1_cross_axi_data_valid )        , // 端口数据有效
    .o_mac1_cross_axi_data_ready ( w_mac1_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac1_cross_axi_data_last  ( w_mac1_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac1_cross_metadata       ( w_mac1_cross_metadata       )        , // 总线 metadata 数据
    .i_mac1_cross_metadata_valid ( w_mac1_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac1_cross_metadata_last  ( w_mac1_cross_metadata_last  )        , // 信息流结束标识
    .o_mac1_cross_metadata_ready ( w_mac1_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac2_cross_port_link      ( w_mac2_cross_port_link      )        , // 端口的连接状态
    .i_mac2_cross_port_speed     ( w_mac2_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac2_cross_port_axi_data  ( w_mac2_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac2_cross_axi_data_keep  ( w_mac2_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac2_cross_axi_data_valid ( w_mac2_cross_axi_data_valid )        , // 端口数据有效
    .o_mac2_cross_axi_data_ready ( w_mac2_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac2_cross_axi_data_last  ( w_mac2_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac2_cross_metadata       ( w_mac2_cross_metadata       )        , // 总线 metadata 数据
    .i_mac2_cross_metadata_valid ( w_mac2_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac2_cross_metadata_last  ( w_mac2_cross_metadata_last  )        , // 信息流结束标识
    .o_mac2_cross_metadata_ready ( w_mac2_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac3_cross_port_link      ( w_mac3_cross_port_link      )        , // 端口的连接状态
    .i_mac3_cross_port_speed     ( w_mac3_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac3_cross_port_axi_data  ( w_mac3_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac3_cross_axi_data_keep  ( w_mac3_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac3_cross_axi_data_valid ( w_mac3_cross_axi_data_valid )        , // 端口数据有效
    .o_mac3_cross_axi_data_ready ( w_mac3_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac3_cross_axi_data_last  ( w_mac3_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac3_cross_metadata       ( w_mac3_cross_metadata       )        , // 总线 metadata 数据
    .i_mac3_cross_metadata_valid ( w_mac3_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac3_cross_metadata_last  ( w_mac3_cross_metadata_last  )        , // 信息流结束标识
    .o_mac3_cross_metadata_ready ( w_mac3_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac4_cross_port_link      ( w_mac4_cross_port_link      )        , // 端口的连接状态
    .i_mac4_cross_port_speed     ( w_mac4_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac4_cross_port_axi_data  ( w_mac4_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac4_cross_axi_data_keep  ( w_mac4_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac4_cross_axi_data_valid ( w_mac4_cross_axi_data_valid )        , // 端口数据有效
    .o_mac4_cross_axi_data_ready ( w_mac4_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac4_cross_axi_data_last  ( w_mac4_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac4_cross_metadata       ( w_mac4_cross_metadata       )        , // 总线 metadata 数据
    .i_mac4_cross_metadata_valid ( w_mac4_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac4_cross_metadata_last  ( w_mac4_cross_metadata_last  )        , // 信息流结束标识
    .o_mac4_cross_metadata_ready ( w_mac4_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac5_cross_port_link      ( w_mac5_cross_port_link      )        , // 端口的连接状态
    .i_mac5_cross_port_speed     ( w_mac5_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac5_cross_port_axi_data  ( w_mac5_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac5_cross_axi_data_keep  ( w_mac5_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac5_cross_axi_data_valid ( w_mac5_cross_axi_data_valid )        , // 端口数据有效
    .o_mac5_cross_axi_data_ready ( w_mac5_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac5_cross_axi_data_last  ( w_mac5_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac5_cross_metadata       ( w_mac5_cross_metadata       )        , // 总线 metadata 数据
    .i_mac5_cross_metadata_valid ( w_mac5_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac5_cross_metadata_last  ( w_mac5_cross_metadata_last  )        , // 信息流结束标识
    .o_mac5_cross_metadata_ready ( w_mac5_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac6_cross_port_link      ( w_mac6_cross_port_link      )        , // 端口的连接状态
    .i_mac6_cross_port_speed     ( w_mac6_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac6_cross_port_axi_data  ( w_mac6_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac6_cross_axi_data_keep  ( w_mac6_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac6_cross_axi_data_valid ( w_mac6_cross_axi_data_valid )        , // 端口数据有效
    .o_mac6_cross_axi_data_ready ( w_mac6_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac6_cross_axi_data_last  ( w_mac6_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac6_cross_metadata       ( w_mac6_cross_metadata       )        , // 总线 metadata 数据
    .i_mac6_cross_metadata_valid ( w_mac6_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac6_cross_metadata_last  ( w_mac6_cross_metadata_last  )        , // 信息流结束标识
    .o_mac6_cross_metadata_ready ( w_mac6_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac7_cross_port_link      ( w_mac7_cross_port_link      )        , // 端口的连接状态
    .i_mac7_cross_port_speed     ( w_mac7_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac7_cross_port_axi_data  ( w_mac7_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac7_cross_axi_data_keep  ( w_mac7_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac7_cross_axi_data_valid ( w_mac7_cross_axi_data_valid )        , // 端口数据有效
    .o_mac7_cross_axi_data_ready ( w_mac7_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac7_cross_axi_data_last  ( w_mac7_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac7_cross_metadata       ( w_mac7_cross_metadata       )        , // 总线 metadata 数据
    .i_mac7_cross_metadata_valid ( w_mac7_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac7_cross_metadata_last  ( w_mac7_cross_metadata_last  )        , // 信息流结束标识
    .o_mac7_cross_metadata_ready ( w_mac7_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef TSN_AS
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_tsn_as_cross_port_link       ( w_tsn_as_cross_port_link       )       , // 端口的连接状态
    .i_tsn_as_cross_port_speed      ( w_tsn_as_cross_port_speed      )       , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_tsn_as_cross_port_axi_data   ( w_tsn_as_cross_port_axi_data   )       , // 端口数据流，最高位表示crcerr
    .i_tsn_as_cross_axi_data_keep   ( w_tsn_as_cross_axi_data_keep   )       , // 端口数据流掩码，有效字节指示
    .i_tsn_as_cross_axi_data_valid  ( w_tsn_as_cross_axi_data_valid  )       , // 端口数据有效
    .o_tsn_as_cross_axi_data_ready  ( w_tsn_as_cross_axi_data_ready  )       , // 交叉总线聚合架构反压流水线信号
    .i_tsn_as_cross_axi_data_last   ( w_tsn_as_cross_axi_data_last   )       , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_tsn_as_cross_metadata        ( w_tsn_as_cross_metadata        )     , // 总线 metadata 数据
    .i_tsn_as_cross_metadata_valid  ( w_tsn_as_cross_metadata_valid  )     , // 总线 metadata 数据有效信号
    .i_tsn_as_cross_metadata_last   ( w_tsn_as_cross_metadata_last   )     , // 信息流结束标识
    .o_tsn_as_cross_metadata_ready  ( w_tsn_as_cross_metadata_ready  )     , // 下游模块反压流水线 
`endif 
`ifdef LLDP
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_lldp_cross_port_link        ( w_lldp_cross_port_link         )     , // 端口的连接状态
    .i_lldp_cross_port_speed       ( w_lldp_cross_port_speed        )     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_lldp_cross_port_axi_data    ( w_lldp_cross_port_axi_data     )     , // 端口数据流，最高位表示crcerr
    .i_lldp_cross_axi_data_keep    ( w_lldp_cross_axi_data_keep     )     , // 端口数据流掩码，有效字节指示
    .i_lldp_cross_axi_data_valid   ( w_lldp_cross_axi_data_valid    )     , // 端口数据有效
    .o_lldp_cross_axi_data_ready   ( w_lldp_cross_axi_data_ready    )     , // 交叉总线聚合架构反压流水线信号
    .i_lldp_cross_axi_data_last    ( w_lldp_cross_axi_data_last     )     , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_lldp_cross_metadata         ( w_lldp_cross_metadata         )      , // 总线 metadata 数据
    .i_lldp_cross_metadata_valid   ( w_lldp_cross_metadata_valid   )      , // 总线 metadata 数据有效信号
    .i_lldp_cross_metadata_last    ( w_lldp_cross_metadata_last    )      , // 信息流结束标识
    .o_lldp_cross_metadata_ready   ( w_lldp_cross_metadata_ready   )      , // 下游模块反压流水线 
`endif 
    /*-------------------- TXMAC 输出数据流 -----------------------*/
`ifdef CPU_MAC
    //pmac通道数据
    .o_pmac0_tx_axis_data         ( w_pmac0_tx_axis_data    )      , 
    .o_pmac0_tx_axis_user         ( w_pmac0_tx_axis_user    )      , 
    .o_pmac0_tx_axis_keep         ( w_pmac0_tx_axis_keep    )      , 
    .o_pmac0_tx_axis_last         ( w_pmac0_tx_axis_last    )      , 
    .o_pmac0_tx_axis_valid        ( w_pmac0_tx_axis_valid   )      , 
    .o_pmac0_ethertype            ( w_pmac0_ethertype       )      , 
    .i_pmac0_tx_axis_ready        ( w_pmac0_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac0_tx_axis_data         ( w_emac0_tx_axis_data    )       , 
    .o_emac0_tx_axis_user         ( w_emac0_tx_axis_user    )       , 
    .o_emac0_tx_axis_keep         ( w_emac0_tx_axis_keep    )       , 
    .o_emac0_tx_axis_last         ( w_emac0_tx_axis_last    )       , 
    .o_emac0_tx_axis_valid        ( w_emac0_tx_axis_valid   )       , 
    .o_emac0_ethertype            ( w_emac0_ethertype       )       ,
    .i_emac0_tx_axis_ready        ( w_emac0_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac0_fifoc_empty           (w_mac0_fifoc_empty       )       ,    
    .i_mac0_scheduing_rst         (w_mac0_scheduing_rst     )       ,
    .i_mac0_scheduing_rst_vld     (w_mac0_scheduing_rst_vld )       ,  
`endif
`ifdef MAC1
    //pmac通道数据
    .o_pmac1_tx_axis_data         ( w_pmac1_tx_axis_data    )      , 
    .o_pmac1_tx_axis_user         ( w_pmac1_tx_axis_user    )      , 
    .o_pmac1_tx_axis_keep         ( w_pmac1_tx_axis_keep    )      , 
    .o_pmac1_tx_axis_last         ( w_pmac1_tx_axis_last    )      , 
    .o_pmac1_tx_axis_valid        ( w_pmac1_tx_axis_valid   )      , 
    .o_pmac1_ethertype            ( w_pmac1_ethertype       )      , 
    .i_pmac1_tx_axis_ready        ( w_pmac1_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac1_tx_axis_data         ( w_emac1_tx_axis_data    )       , 
    .o_emac1_tx_axis_user         ( w_emac1_tx_axis_user    )       , 
    .o_emac1_tx_axis_keep         ( w_emac1_tx_axis_keep    )       , 
    .o_emac1_tx_axis_last         ( w_emac1_tx_axis_last    )       , 
    .o_emac1_tx_axis_valid        ( w_emac1_tx_axis_valid   )       , 
    .o_emac1_ethertype            ( w_emac1_ethertype       )       ,
    .i_emac1_tx_axis_ready        ( w_emac1_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac1_fifoc_empty           ( w_mac1_fifoc_empty       )       ,    
    .i_mac1_scheduing_rst         ( w_mac1_scheduing_rst     )       ,
    .i_mac1_scheduing_rst_vld     ( w_mac1_scheduing_rst_vld )       , 
`endif
`ifdef MAC2
    //pmac通道数据
    .o_pmac2_tx_axis_data         ( w_pmac2_tx_axis_data    )      , 
    .o_pmac2_tx_axis_user         ( w_pmac2_tx_axis_user    )      , 
    .o_pmac2_tx_axis_keep         ( w_pmac2_tx_axis_keep    )      , 
    .o_pmac2_tx_axis_last         ( w_pmac2_tx_axis_last    )      , 
    .o_pmac2_tx_axis_valid        ( w_pmac2_tx_axis_valid   )      , 
    .o_pmac2_ethertype            ( w_pmac2_ethertype       )      , 
    .i_pmac2_tx_axis_ready        ( w_pmac2_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac2_tx_axis_data         ( w_emac2_tx_axis_data    )       , 
    .o_emac2_tx_axis_user         ( w_emac2_tx_axis_user    )       , 
    .o_emac2_tx_axis_keep         ( w_emac2_tx_axis_keep    )       , 
    .o_emac2_tx_axis_last         ( w_emac2_tx_axis_last    )       , 
    .o_emac2_tx_axis_valid        ( w_emac2_tx_axis_valid   )       , 
    .o_emac2_ethertype            ( w_emac2_ethertype       )       ,
    .i_emac2_tx_axis_ready        ( w_emac2_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac2_fifoc_empty           (w_mac2_fifoc_empty       )       ,    
    .i_mac2_scheduing_rst         (w_mac2_scheduing_rst     )       ,
    .i_mac2_scheduing_rst_vld     (w_mac2_scheduing_rst_vld )       , 
`endif
`ifdef MAC3
    //pmac通道数据
    .o_pmac3_tx_axis_data         ( w_pmac3_tx_axis_data    )      , 
    .o_pmac3_tx_axis_user         ( w_pmac3_tx_axis_user    )      , 
    .o_pmac3_tx_axis_keep         ( w_pmac3_tx_axis_keep    )      , 
    .o_pmac3_tx_axis_last         ( w_pmac3_tx_axis_last    )      , 
    .o_pmac3_tx_axis_valid        ( w_pmac3_tx_axis_valid   )      , 
    .o_pmac3_ethertype            ( w_pmac3_ethertype       )      , 
    .i_pmac3_tx_axis_ready        ( w_pmac3_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac3_tx_axis_data         ( w_emac3_tx_axis_data    )       , 
    .o_emac3_tx_axis_user         ( w_emac3_tx_axis_user    )       , 
    .o_emac3_tx_axis_keep         ( w_emac3_tx_axis_keep    )       , 
    .o_emac3_tx_axis_last         ( w_emac3_tx_axis_last    )       , 
    .o_emac3_tx_axis_valid        ( w_emac3_tx_axis_valid   )       , 
    .o_emac3_ethertype            ( w_emac3_ethertype       )       ,
    .i_emac3_tx_axis_ready        ( w_emac3_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac3_fifoc_empty           (w_mac3_fifoc_empty       )       ,    
    .i_mac3_scheduing_rst         (w_mac3_scheduing_rst     )       ,
    .i_mac3_scheduing_rst_vld     (w_mac3_scheduing_rst_vld )       ,  
`endif
`ifdef MAC4
    //pmac通道数据
    .o_pmac4_tx_axis_data         ( w_pmac4_tx_axis_data    )      , 
    .o_pmac4_tx_axis_user         ( w_pmac4_tx_axis_user    )      , 
    .o_pmac4_tx_axis_keep         ( w_pmac4_tx_axis_keep    )      , 
    .o_pmac4_tx_axis_last         ( w_pmac4_tx_axis_last    )      , 
    .o_pmac4_tx_axis_valid        ( w_pmac4_tx_axis_valid   )      , 
    .o_pmac4_ethertype            ( w_pmac4_ethertype       )      , 
    .i_pmac4_tx_axis_ready        ( w_pmac4_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac4_tx_axis_data         ( w_emac4_tx_axis_data    )       , 
    .o_emac4_tx_axis_user         ( w_emac4_tx_axis_user    )       , 
    .o_emac4_tx_axis_keep         ( w_emac4_tx_axis_keep    )       , 
    .o_emac4_tx_axis_last         ( w_emac4_tx_axis_last    )       , 
    .o_emac4_tx_axis_valid        ( w_emac4_tx_axis_valid   )       , 
    .o_emac4_ethertype            ( w_emac4_ethertype       )       ,
    .i_emac4_tx_axis_ready        ( w_emac4_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac4_fifoc_empty           (w_mac4_fifoc_empty       )       ,    
    .i_mac4_scheduing_rst         (w_mac4_scheduing_rst     )       ,
    .i_mac4_scheduing_rst_vld     (w_mac4_scheduing_rst_vld )       , 
`endif
`ifdef MAC5
    //pmac通道数据
    .o_pmac5_tx_axis_data         ( w_pmac5_tx_axis_data    )      , 
    .o_pmac5_tx_axis_user         ( w_pmac5_tx_axis_user    )      , 
    .o_pmac5_tx_axis_keep         ( w_pmac5_tx_axis_keep    )      , 
    .o_pmac5_tx_axis_last         ( w_pmac5_tx_axis_last    )      , 
    .o_pmac5_tx_axis_valid        ( w_pmac5_tx_axis_valid   )      , 
    .o_pmac5_ethertype            ( w_pmac5_ethertype       )      , 
    .i_pmac5_tx_axis_ready        ( w_pmac5_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac5_tx_axis_data         ( w_emac5_tx_axis_data    )       , 
    .o_emac5_tx_axis_user         ( w_emac5_tx_axis_user    )       , 
    .o_emac5_tx_axis_keep         ( w_emac5_tx_axis_keep    )       , 
    .o_emac5_tx_axis_last         ( w_emac5_tx_axis_last    )       , 
    .o_emac5_tx_axis_valid        ( w_emac5_tx_axis_valid   )       , 
    .o_emac5_ethertype            ( w_emac5_ethertype       )       ,
    .i_emac5_tx_axis_ready        ( w_emac5_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac5_fifoc_empty           (w_mac5_fifoc_empty       )       ,    
    .i_mac5_scheduing_rst         (w_mac5_scheduing_rst     )       ,
    .i_mac5_scheduing_rst_vld     (w_mac5_scheduing_rst_vld )       , 
`endif
`ifdef MAC6
    //pmac通道数据
    .o_pmac6_tx_axis_data         ( w_pmac6_tx_axis_data    )      , 
    .o_pmac6_tx_axis_user         ( w_pmac6_tx_axis_user    )      , 
    .o_pmac6_tx_axis_keep         ( w_pmac6_tx_axis_keep    )      , 
    .o_pmac6_tx_axis_last         ( w_pmac6_tx_axis_last    )      , 
    .o_pmac6_tx_axis_valid        ( w_pmac6_tx_axis_valid   )      , 
    .o_pmac6_ethertype            ( w_pmac6_ethertype       )      , 
    .i_pmac6_tx_axis_ready        ( w_pmac6_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac6_tx_axis_data         ( w_emac6_tx_axis_data    )       , 
    .o_emac6_tx_axis_user         ( w_emac6_tx_axis_user    )       , 
    .o_emac6_tx_axis_keep         ( w_emac6_tx_axis_keep    )       , 
    .o_emac6_tx_axis_last         ( w_emac6_tx_axis_last    )       , 
    .o_emac6_tx_axis_valid        ( w_emac6_tx_axis_valid   )       , 
    .o_emac6_ethertype            ( w_emac6_ethertype       )       ,
    .i_emac6_tx_axis_ready        ( w_emac6_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac6_fifoc_empty           (w_mac6_fifoc_empty       )       ,    
    .i_mac6_scheduing_rst         (w_mac6_scheduing_rst     )       ,
    .i_mac6_scheduing_rst_vld     (w_mac6_scheduing_rst_vld )       , 
`endif
`ifdef MAC7
    //pmac通道数据
    .o_pmac7_tx_axis_data         ( w_pmac7_tx_axis_data    )      , 
    .o_pmac7_tx_axis_user         ( w_pmac7_tx_axis_user    )      , 
    .o_pmac7_tx_axis_keep         ( w_pmac7_tx_axis_keep    )      , 
    .o_pmac7_tx_axis_last         ( w_pmac7_tx_axis_last    )      , 
    .o_pmac7_tx_axis_valid        ( w_pmac7_tx_axis_valid   )      , 
    .o_pmac7_ethertype            ( w_pmac7_ethertype       )      , 
    .i_pmac7_tx_axis_ready        ( w_pmac7_tx_axis_ready   )      ,
    //emac通道数据                
    .o_emac7_tx_axis_data         ( w_emac7_tx_axis_data    )       , 
    .o_emac7_tx_axis_user         ( w_emac7_tx_axis_user    )       , 
    .o_emac7_tx_axis_keep         ( w_emac7_tx_axis_keep    )       , 
    .o_emac7_tx_axis_last         ( w_emac7_tx_axis_last    )       , 
    .o_emac7_tx_axis_valid        ( w_emac7_tx_axis_valid   )       , 
    .o_emac7_ethertype            ( w_emac7_ethertype       )       ,
    .i_emac7_tx_axis_ready        ( w_emac7_tx_axis_ready   )       ,
    // 调度流水线调度信息交互
    .o_mac7_fifoc_empty           (w_mac7_fifoc_empty       )       ,    
    .i_mac7_scheduing_rst         (w_mac7_scheduing_rst     )       ,
    .i_mac7_scheduing_rst_vld     (w_mac7_scheduing_rst_vld )       ,  
`endif 
    .i_clk                        ( )       ,   // 250MHz
    .i_rst                        ( )       
);

tx_mac_mng #(
    .PORT_NUM                   ( PORT_NUM              )  ,                   // 交换机的端口数
    .METADATA_WIDTH             ( METADATA_WIDTH        )  ,                   // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH        ( PORT_MNG_DATA_WIDTH   )  ,                   // Mac_port_mng 数据位宽
    .PORT_FIFO_PRI_NUM          ( PORT_FIFO_PRI_NUM     )  ,                   // 支持端口优先级 FIFO 的数量
    .REG_ADDR_BUS_WIDTH         ( REG_ADDR_BUS_WIDTH    )  ,
    .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH    )  ,
    .CROSS_DATA_WIDTH           ( CROSS_DATA_WIDTH      )  
)tx_mac_mng_inst (
    .i_clk                      (  )        ,   // 250MHz
    .i_rst                      (  )        ,
    /*---------------------------------------- 业务接口数据输出 -------------------------------------------*/
`ifdef CPU_MAC
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac0_tx_axis_data      ( w_pmac0_tx_axis_data  )         , 
    .i_pmac0_tx_axis_user      ( w_pmac0_tx_axis_user  )         , 
    .i_pmac0_tx_axis_keep      ( w_pmac0_tx_axis_keep  )         , 
    .i_pmac0_tx_axis_last      ( w_pmac0_tx_axis_last  )         , 
    .i_pmac0_tx_axis_valid     ( w_pmac0_tx_axis_valid )         , 
    .i_pmac0_ethertype         ( w_pmac0_ethertype     )         , 
    .o_pmac0_tx_axis_ready     ( w_pmac0_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac0_tx_axis_data      ( w_emac0_tx_axis_data  )         , 
    .i_emac0_tx_axis_user      ( w_emac0_tx_axis_user  )         , 
    .i_emac0_tx_axis_keep      ( w_emac0_tx_axis_keep  )         , 
    .i_emac0_tx_axis_last      ( w_emac0_tx_axis_last  )         , 
    .i_emac0_tx_axis_valid     ( w_emac0_tx_axis_valid )         , 
    .i_emac0_ethertype         ( w_emac0_ethertype     )         ,
    .o_emac0_tx_axis_ready     ( w_emac0_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac0_fifoc_empty        ( w_mac0_fifoc_empty       )         ,    
    .o_mac0_scheduing_rst      ( w_mac0_scheduing_rst     )         ,
    .o_mac0_scheduing_rst_vld  ( w_mac0_scheduing_rst_vld )         ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac0_axi_data           ( )         ,
    .o_mac0_axi_data_keep      ( )         ,
    .o_mac0_axi_data_valid     ( )         ,
    .o_mac0_axi_data_user      ( )         ,
    .i_mac0_axi_data_ready     ( )         ,
    .o_mac0_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac0_time_irq           ( )         , // 打时间戳中断信号
    .o_mac0_frame_seq          ( )         , // 帧序列号
    .o_mac0_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC1
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac1_tx_axis_data      ( w_pmac1_tx_axis_data  )         , 
    .i_pmac1_tx_axis_user      ( w_pmac1_tx_axis_user  )         , 
    .i_pmac1_tx_axis_keep      ( w_pmac1_tx_axis_keep  )         , 
    .i_pmac1_tx_axis_last      ( w_pmac1_tx_axis_last  )         , 
    .i_pmac1_tx_axis_valid     ( w_pmac1_tx_axis_valid )         , 
    .i_pmac1_ethertype         ( w_pmac1_ethertype     )         , 
    .o_pmac1_tx_axis_ready     ( w_pmac1_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac1_tx_axis_data      ( w_emac1_tx_axis_data  )         , 
    .i_emac1_tx_axis_user      ( w_emac1_tx_axis_user  )         , 
    .i_emac1_tx_axis_keep      ( w_emac1_tx_axis_keep  )         , 
    .i_emac1_tx_axis_last      ( w_emac1_tx_axis_last  )         , 
    .i_emac1_tx_axis_valid     ( w_emac1_tx_axis_valid )         , 
    .i_emac1_ethertype         ( w_emac1_ethertype     )         ,
    .o_emac1_tx_axis_ready     ( w_emac1_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac1_fifoc_empty        ( w_mac1_fifoc_empty       )         ,    
    .o_mac1_scheduing_rst      ( w_mac1_scheduing_rst     )         ,
    .o_mac1_scheduing_rst_vld  ( w_mac1_scheduing_rst_vld )         ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac1_axi_data           ( )         ,
    .o_mac1_axi_data_keep      ( )         ,
    .o_mac1_axi_data_valid     ( )         ,
    .o_mac1_axi_data_user      ( )         ,
    .i_mac1_axi_data_ready     ( )         ,
    .o_mac1_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac1_time_irq           ( )         , // 打时间戳中断信号
    .o_mac1_frame_seq          ( )         , // 帧序列号
    .o_mac1_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC2
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac2_tx_axis_data      ( w_pmac2_tx_axis_data  )         , 
    .i_pmac2_tx_axis_user      ( w_pmac2_tx_axis_user  )         , 
    .i_pmac2_tx_axis_keep      ( w_pmac2_tx_axis_keep  )         , 
    .i_pmac2_tx_axis_last      ( w_pmac2_tx_axis_last  )         , 
    .i_pmac2_tx_axis_valid     ( w_pmac2_tx_axis_valid )         , 
    .i_pmac2_ethertype         ( w_pmac2_ethertype     )         , 
    .o_pmac2_tx_axis_ready     ( w_pmac2_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac2_tx_axis_data      ( w_emac2_tx_axis_data  )         , 
    .i_emac2_tx_axis_user      ( w_emac2_tx_axis_user  )         , 
    .i_emac2_tx_axis_keep      ( w_emac2_tx_axis_keep  )         , 
    .i_emac2_tx_axis_last      ( w_emac2_tx_axis_last  )         , 
    .i_emac2_tx_axis_valid     ( w_emac2_tx_axis_valid )         , 
    .i_emac2_ethertype         ( w_emac2_ethertype     )         ,
    .o_emac2_tx_axis_ready     ( w_emac2_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac2_fifoc_empty        ( w_mac2_fifoc_empty       )         ,    
    .o_mac2_scheduing_rst      ( w_mac2_scheduing_rst     )         ,
    .o_mac2_scheduing_rst_vld  ( w_mac2_scheduing_rst_vld )         ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac2_axi_data           ( )         ,
    .o_mac2_axi_data_keep      ( )         ,
    .o_mac2_axi_data_valid     ( )         ,
    .o_mac2_axi_data_user      ( )         ,
    .i_mac2_axi_data_ready     ( )         ,
    .o_mac2_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac2_time_irq           ( )         , // 打时间戳中断信号
    .o_mac2_frame_seq          ( )         , // 帧序列号
    .o_mac2_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC3
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac3_tx_axis_data      ( w_pmac3_tx_axis_data  )         , 
    .i_pmac3_tx_axis_user      ( w_pmac3_tx_axis_user  )         , 
    .i_pmac3_tx_axis_keep      ( w_pmac3_tx_axis_keep  )         , 
    .i_pmac3_tx_axis_last      ( w_pmac3_tx_axis_last  )         , 
    .i_pmac3_tx_axis_valid     ( w_pmac3_tx_axis_valid )         , 
    .i_pmac3_ethertype         ( w_pmac3_ethertype     )         , 
    .o_pmac3_tx_axis_ready     ( w_pmac3_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac3_tx_axis_data      ( w_emac3_tx_axis_data  )         , 
    .i_emac3_tx_axis_user      ( w_emac3_tx_axis_user  )         , 
    .i_emac3_tx_axis_keep      ( w_emac3_tx_axis_keep  )         , 
    .i_emac3_tx_axis_last      ( w_emac3_tx_axis_last  )         , 
    .i_emac3_tx_axis_valid     ( w_emac3_tx_axis_valid )         , 
    .i_emac3_ethertype         ( w_emac3_ethertype     )         ,
    .o_emac3_tx_axis_ready     ( w_emac3_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac3_fifoc_empty        ( w_mac3_fifoc_empty       )         ,    
    .o_mac3_scheduing_rst      ( w_mac3_scheduing_rst     )         ,
    .o_mac3_scheduing_rst_vld  ( w_mac3_scheduing_rst_vld )         ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac3_axi_data           ( )         ,
    .o_mac3_axi_data_keep      ( )         ,
    .o_mac3_axi_data_valid     ( )         ,
    .o_mac3_axi_data_user      ( )         ,
    .i_mac3_axi_data_ready     ( )         ,
    .o_mac3_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac3_time_irq           ( )         , // 打时间戳中断信号
    .o_mac3_frame_seq          ( )         , // 帧序列号
    .o_mac3_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC4
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac4_tx_axis_data      ( w_pmac4_tx_axis_data  )         , 
    .i_pmac4_tx_axis_user      ( w_pmac4_tx_axis_user  )         , 
    .i_pmac4_tx_axis_keep      ( w_pmac4_tx_axis_keep  )         , 
    .i_pmac4_tx_axis_last      ( w_pmac4_tx_axis_last  )         , 
    .i_pmac4_tx_axis_valid     ( w_pmac4_tx_axis_valid )         , 
    .i_pmac4_ethertype         ( w_pmac4_ethertype     )         , 
    .o_pmac4_tx_axis_ready     ( w_pmac4_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac4_tx_axis_data      ( w_emac4_tx_axis_data  )         , 
    .i_emac4_tx_axis_user      ( w_emac4_tx_axis_user  )         , 
    .i_emac4_tx_axis_keep      ( w_emac4_tx_axis_keep  )         , 
    .i_emac4_tx_axis_last      ( w_emac4_tx_axis_last  )         , 
    .i_emac4_tx_axis_valid     ( w_emac4_tx_axis_valid )         , 
    .i_emac4_ethertype         ( w_emac4_ethertype     )         ,
    .o_emac4_tx_axis_ready     ( w_emac4_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac4_fifoc_empty        ( w_mac4_fifoc_empty       )         ,    
    .o_mac4_scheduing_rst      ( w_mac4_scheduing_rst     )         ,
    .o_mac4_scheduing_rst_vld  ( w_mac4_scheduing_rst_vld )         ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac4_axi_data           ( )         ,
    .o_mac4_axi_data_keep      ( )         ,
    .o_mac4_axi_data_valid     ( )         ,
    .o_mac4_axi_data_user      ( )         ,
    .i_mac4_axi_data_ready     ( )         ,
    .o_mac4_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac4_time_irq           ( )         , // 打时间戳中断信号
    .o_mac4_frame_seq          ( )         , // 帧序列号
    .o_mac4_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC5
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac5_tx_axis_data      ( w_pmac5_tx_axis_data  )         , 
    .i_pmac5_tx_axis_user      ( w_pmac5_tx_axis_user  )         , 
    .i_pmac5_tx_axis_keep      ( w_pmac5_tx_axis_keep  )         , 
    .i_pmac5_tx_axis_last      ( w_pmac5_tx_axis_last  )         , 
    .i_pmac5_tx_axis_valid     ( w_pmac5_tx_axis_valid )         , 
    .i_pmac5_ethertype         ( w_pmac5_ethertype     )         , 
    .o_pmac5_tx_axis_ready     ( w_pmac5_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac5_tx_axis_data      ( w_emac5_tx_axis_data  )         , 
    .i_emac5_tx_axis_user      ( w_emac5_tx_axis_user  )         , 
    .i_emac5_tx_axis_keep      ( w_emac5_tx_axis_keep  )         , 
    .i_emac5_tx_axis_last      ( w_emac5_tx_axis_last  )         , 
    .i_emac5_tx_axis_valid     ( w_emac5_tx_axis_valid )         , 
    .i_emac5_ethertype         ( w_emac5_ethertype     )         ,
    .o_emac5_tx_axis_ready     ( w_emac5_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac5_fifoc_empty        ( w_mac5_fifoc_empty       )         ,    
    .o_mac5_scheduing_rst      ( w_mac5_scheduing_rst     )         ,
    .o_mac5_scheduing_rst_vld  ( w_mac5_scheduing_rst_vld )         ,   
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac5_axi_data           ( )         ,
    .o_mac5_axi_data_keep      ( )         ,
    .o_mac5_axi_data_valid     ( )         ,
    .o_mac5_axi_data_user      ( )         ,
    .i_mac5_axi_data_ready     ( )         ,
    .o_mac5_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac5_time_irq           ( )         , // 打时间戳中断信号
    .o_mac5_frame_seq          ( )         , // 帧序列号
    .o_mac5_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC6
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac6_tx_axis_data      ( w_pmac6_tx_axis_data  )         , 
    .i_pmac6_tx_axis_user      ( w_pmac6_tx_axis_user  )         , 
    .i_pmac6_tx_axis_keep      ( w_pmac6_tx_axis_keep  )         , 
    .i_pmac6_tx_axis_last      ( w_pmac6_tx_axis_last  )         , 
    .i_pmac6_tx_axis_valid     ( w_pmac6_tx_axis_valid )         , 
    .i_pmac6_ethertype         ( w_pmac6_ethertype     )         , 
    .o_pmac6_tx_axis_ready     ( w_pmac6_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac6_tx_axis_data      ( w_emac6_tx_axis_data  )         , 
    .i_emac6_tx_axis_user      ( w_emac6_tx_axis_user  )         , 
    .i_emac6_tx_axis_keep      ( w_emac6_tx_axis_keep  )         , 
    .i_emac6_tx_axis_last      ( w_emac6_tx_axis_last  )         , 
    .i_emac6_tx_axis_valid     ( w_emac6_tx_axis_valid )         , 
    .i_emac6_ethertype         ( w_emac6_ethertype     )         ,
    .o_emac6_tx_axis_ready     ( w_emac6_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac6_fifoc_empty        ( w_mac6_fifoc_empty       )         ,    
    .o_mac6_scheduing_rst      ( w_mac6_scheduing_rst     )         ,
    .o_mac6_scheduing_rst_vld  ( w_mac6_scheduing_rst_vld )         ,    
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac6_axi_data           ( )         ,
    .o_mac6_axi_data_keep      ( )         ,
    .o_mac6_axi_data_valid     ( )         ,
    .o_mac6_axi_data_user      ( )         ,
    .i_mac6_axi_data_ready     ( )         ,
    .o_mac6_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac6_time_irq           ( )         , // 打时间戳中断信号
    .o_mac6_frame_seq          ( )         , // 帧序列号
    .o_mac6_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
`ifdef MAC7
    /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
    //pmac通道数据
    .i_pmac7_tx_axis_data      ( w_pmac7_tx_axis_data  )         , 
    .i_pmac7_tx_axis_user      ( w_pmac7_tx_axis_user  )         , 
    .i_pmac7_tx_axis_keep      ( w_pmac7_tx_axis_keep  )         , 
    .i_pmac7_tx_axis_last      ( w_pmac7_tx_axis_last  )         , 
    .i_pmac7_tx_axis_valid     ( w_pmac7_tx_axis_valid )         , 
    .i_pmac7_ethertype         ( w_pmac7_ethertype     )         , 
    .o_pmac7_tx_axis_ready     ( w_pmac7_tx_axis_ready )         ,
    //emac通道数据              
    .i_emac7_tx_axis_data      ( w_emac7_tx_axis_data  )         , 
    .i_emac7_tx_axis_user      ( w_emac7_tx_axis_user  )         , 
    .i_emac7_tx_axis_keep      ( w_emac7_tx_axis_keep  )         , 
    .i_emac7_tx_axis_last      ( w_emac7_tx_axis_last  )         , 
    .i_emac7_tx_axis_valid     ( w_emac7_tx_axis_valid )         , 
    .i_emac7_ethertype         ( w_emac7_ethertype     )         ,
    .o_emac7_tx_axis_ready     ( w_emac7_tx_axis_ready )         ,
    // 调度流水线调度信息交互 
    .i_mac7_fifoc_empty        ( w_mac7_fifoc_empty       )      ,    
    .o_mac7_scheduing_rst      ( w_mac7_scheduing_rst     )      ,
    .o_mac7_scheduing_rst_vld  ( w_mac7_scheduing_rst_vld )      ,    
    /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
    //输出给接口层axi数据流
    .o_mac7_axi_data           ( )         ,
    .o_mac7_axi_data_keep      ( )         ,
    .o_mac7_axi_data_valid     ( )         ,
    .o_mac7_axi_data_user      ( )         ,
    .i_mac7_axi_data_ready     ( )         ,
    .o_mac7_axi_data_last      ( )         ,
    // 报文时间打时间戳
    .o_mac7_time_irq           ( )         , // 打时间戳中断信号
    .o_mac7_frame_seq          ( )         , // 帧序列号
    .o_mac7_timestamp_addr     ( )         , // 打时间戳存储的 RAM 地址
`endif
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse      ( )          , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr      ( )          , // 刷新错误计数器
    .i_switch_err_cnt_stat     ( )          , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_switch_reg_bus_we       ( )          , // 寄存器写使能
    .i_switch_reg_bus_we_addr  ( )          , // 寄存器写地址
    .i_switch_reg_bus_we_din   ( )          , // 寄存器写数据
    .i_switch_reg_bus_we_din_v ( )          , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_switch_reg_bus_rd       ( )         , // 寄存器读使能
    .i_switch_reg_bus_rd_addr  ( )         , // 寄存器读地址
    .o_switch_reg_bus_rd_dout  ( )         , // 读出寄存器数据
    .o_switch_reg_bus_rd_dout_v( )           // 读数据有效使能
);

/*------------------- 特定端口转发的 IP 数据流 over 至 COSSBAR 交换架构中----------------*/
tsn_as_top#(
    .REG_ADDR_BUS_WIDTH      ( REG_ADDR_BUS_WIDTH  ),  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH      ( REG_DATA_BUS_WIDTH  ),  // 接收 MAC 层的配置寄存器数据位宽
    .METADATA_WIDTH          ( METADATA_WIDTH      ),  // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH     ( PORT_MNG_DATA_WIDTH ),
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM   ), 
    .CROSS_DATA_WIDTH        ( CROSS_DATA_WIDTH    ) // 聚合总线输出 
)tsn_as_top_inst (
    .i_clk                          ( )            ,   // 250MHz
    .i_rst                          ( )            ,
    /*------------------------------- --------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                      
    .i_refresh_list_pulse           ( )    , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr           ( )    , // 刷新错误计数器
    .i_switch_err_cnt_stat          ( )    , // 刷新错误状态寄存器
    // 寄存器写控制接口      
    .i_switch_reg_bus_we            ( )    , // 寄存器写使能
    .i_switch_reg_bus_we_addr       ( )    , // 寄存器写地址
    .i_switch_reg_bus_we_din        ( )    , // 寄存器写数据
    .i_switch_reg_bus_we_din_v      ( )    , // 寄存器写数据使能
    // 寄存器读控制接口      
    .i_switch_reg_bus_rd            ( )    , // 寄存器读使能
    .i_switch_reg_bus_rd_addr       ( )    , // 寄存器读地址
    .o_switch_reg_bus_we_dout       ( )    , // 读出寄存器数据
    .o_switch_reg_bus_we_dout_v     ( )    , // 读数据有效使能
    /*-------------------- RXMAC 输入数据流 -----------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac0_cross_port_link      ( w_mac0_cross_port_link      )        , // 端口的连接状态
    .i_mac0_cross_port_speed     ( w_mac0_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac0_cross_port_axi_data  ( w_mac0_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac0_cross_axi_data_keep  ( w_mac0_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac0_cross_axi_data_valid ( w_mac0_cross_axi_data_valid )        , // 端口数据有效
    .o_mac0_cross_axi_data_ready ( w_mac0_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac0_cross_axi_data_last  ( w_mac0_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac0_cross_metadata       ( w_mac0_cross_metadata       )        , // 总线 metadata 数据
    .i_mac0_cross_metadata_valid ( w_mac0_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac0_cross_metadata_last  ( w_mac0_cross_metadata_last  )        , // 信息流结束标识
    .o_mac0_cross_metadata_ready ( w_mac0_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac1_cross_port_link      ( w_mac1_cross_port_link      )        , // 端口的连接状态
    .i_mac1_cross_port_speed     ( w_mac1_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac1_cross_port_axi_data  ( w_mac1_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac1_cross_axi_data_keep  ( w_mac1_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac1_cross_axi_data_valid ( w_mac1_cross_axi_data_valid )        , // 端口数据有效
    .o_mac1_cross_axi_data_ready ( w_mac1_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac1_cross_axi_data_last  ( w_mac1_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac1_cross_metadata       ( w_mac1_cross_metadata       )        , // 总线 metadata 数据
    .i_mac1_cross_metadata_valid ( w_mac1_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac1_cross_metadata_last  ( w_mac1_cross_metadata_last  )        , // 信息流结束标识
    .o_mac1_cross_metadata_ready ( w_mac1_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac2_cross_port_link      ( w_mac2_cross_port_link      )        , // 端口的连接状态
    .i_mac2_cross_port_speed     ( w_mac2_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac2_cross_port_axi_data  ( w_mac2_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac2_cross_axi_data_keep  ( w_mac2_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac2_cross_axi_data_valid ( w_mac2_cross_axi_data_valid )        , // 端口数据有效
    .o_mac2_cross_axi_data_ready ( w_mac2_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac2_cross_axi_data_last  ( w_mac2_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac2_cross_metadata       ( w_mac2_cross_metadata       )        , // 总线 metadata 数据
    .i_mac2_cross_metadata_valid ( w_mac2_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac2_cross_metadata_last  ( w_mac2_cross_metadata_last  )        , // 信息流结束标识
    .o_mac2_cross_metadata_ready ( w_mac2_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac3_cross_port_link      ( w_mac3_cross_port_link      )        , // 端口的连接状态
    .i_mac3_cross_port_speed     ( w_mac3_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac3_cross_port_axi_data  ( w_mac3_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac3_cross_axi_data_keep  ( w_mac3_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac3_cross_axi_data_valid ( w_mac3_cross_axi_data_valid )        , // 端口数据有效
    .o_mac3_cross_axi_data_ready ( w_mac3_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac3_cross_axi_data_last  ( w_mac3_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac3_cross_metadata       ( w_mac3_cross_metadata       )        , // 总线 metadata 数据
    .i_mac3_cross_metadata_valid ( w_mac3_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac3_cross_metadata_last  ( w_mac3_cross_metadata_last  )        , // 信息流结束标识
    .o_mac3_cross_metadata_ready ( w_mac3_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac4_cross_port_link      ( w_mac4_cross_port_link      )        , // 端口的连接状态
    .i_mac4_cross_port_speed     ( w_mac4_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac4_cross_port_axi_data  ( w_mac4_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac4_cross_axi_data_keep  ( w_mac4_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac4_cross_axi_data_valid ( w_mac4_cross_axi_data_valid )        , // 端口数据有效
    .o_mac4_cross_axi_data_ready ( w_mac4_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac4_cross_axi_data_last  ( w_mac4_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac4_cross_metadata       ( w_mac4_cross_metadata       )        , // 总线 metadata 数据
    .i_mac4_cross_metadata_valid ( w_mac4_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac4_cross_metadata_last  ( w_mac4_cross_metadata_last  )        , // 信息流结束标识
    .o_mac4_cross_metadata_ready ( w_mac4_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac5_cross_port_link      ( w_mac5_cross_port_link      )        , // 端口的连接状态
    .i_mac5_cross_port_speed     ( w_mac5_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac5_cross_port_axi_data  ( w_mac5_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac5_cross_axi_data_keep  ( w_mac5_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac5_cross_axi_data_valid ( w_mac5_cross_axi_data_valid )        , // 端口数据有效
    .o_mac5_cross_axi_data_ready ( w_mac5_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac5_cross_axi_data_last  ( w_mac5_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac5_cross_metadata       ( w_mac5_cross_metadata       )        , // 总线 metadata 数据
    .i_mac5_cross_metadata_valid ( w_mac5_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac5_cross_metadata_last  ( w_mac5_cross_metadata_last  )        , // 信息流结束标识
    .o_mac5_cross_metadata_ready ( w_mac5_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac6_cross_port_link      ( w_mac6_cross_port_link      )        , // 端口的连接状态
    .i_mac6_cross_port_speed     ( w_mac6_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac6_cross_port_axi_data  ( w_mac6_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac6_cross_axi_data_keep  ( w_mac6_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac6_cross_axi_data_valid ( w_mac6_cross_axi_data_valid )        , // 端口数据有效
    .o_mac6_cross_axi_data_ready ( w_mac6_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac6_cross_axi_data_last  ( w_mac6_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac6_cross_metadata       ( w_mac6_cross_metadata       )        , // 总线 metadata 数据
    .i_mac6_cross_metadata_valid ( w_mac6_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac6_cross_metadata_last  ( w_mac6_cross_metadata_last  )        , // 信息流结束标识
    .o_mac6_cross_metadata_ready ( w_mac6_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac7_cross_port_link      ( w_mac7_cross_port_link      )        , // 端口的连接状态
    .i_mac7_cross_port_speed     ( w_mac7_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac7_cross_port_axi_data  ( w_mac7_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac7_cross_axi_data_keep  ( w_mac7_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac7_cross_axi_data_valid ( w_mac7_cross_axi_data_valid )        , // 端口数据有效
    .o_mac7_cross_axi_data_ready ( w_mac7_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac7_cross_axi_data_last  ( w_mac7_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac7_cross_metadata       ( w_mac7_cross_metadata       )        , // 总线 metadata 数据
    .i_mac7_cross_metadata_valid ( w_mac7_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac7_cross_metadata_last  ( w_mac7_cross_metadata_last  )        , // 信息流结束标识
    .o_mac7_cross_metadata_ready ( w_mac7_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
    /*-------------------- 输出数据流重新进入CROSSBAR交换平面 -----------------------*/
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_tsn_as_cross_port_link       ( w_tsn_as_cross_port_link       )     , // 端口的连接状态
    .o_tsn_as_cross_port_speed      ( w_tsn_as_cross_port_speed      )     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_tsn_as_cross_port_axi_data   ( w_tsn_as_cross_port_axi_data   )     , // 端口数据流，最高位表示crcerr
    .o_tsn_as_cross_axi_data_keep   ( w_tsn_as_cross_axi_data_keep   )     , // 端口数据流掩码，有效字节指示
    .o_tsn_as_cross_axi_data_valid  ( w_tsn_as_cross_axi_data_valid  )     , // 端口数据有效
    .i_tsn_as_cross_axi_data_ready  ( w_tsn_as_cross_axi_data_ready  )     , // 交叉总线聚合架构反压流水线信号
    .o_tsn_as_cross_axi_data_last   ( w_tsn_as_cross_axi_data_last   )     , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_tsn_as_cross_metadata        ( w_tsn_as_cross_metadata       )     , // 总线 metadata 数据
    .o_tsn_as_cross_metadata_valid  ( w_tsn_as_cross_metadata_valid )     , // 总线 metadata 数据有效信号
    .o_tsn_as_cross_metadata_last   ( w_tsn_as_cross_metadata_last  )     , // 信息流结束标识
    .i_tsn_as_cross_metadata_ready  ( w_tsn_as_cross_metadata_ready )       // 下游模块反压流水线 
);

lldp_top#(
    .REG_ADDR_BUS_WIDTH      ( REG_ADDR_BUS_WIDTH  ),  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH      ( REG_DATA_BUS_WIDTH  ),  // 接收 MAC 层的配置寄存器数据位宽
    .METADATA_WIDTH          ( METADATA_WIDTH      ),  // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH     ( PORT_MNG_DATA_WIDTH ),
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM   ), 
    .CROSS_DATA_WIDTH        ( CROSS_DATA_WIDTH    ) // 聚合总线输出 
)lldp_top_inst (
    .i_clk                          ( )            ,   // 250MHz
    .i_rst                          ( )            ,
    /*------------------------------- --------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                      
    .i_refresh_list_pulse           ( )    , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr           ( )    , // 刷新错误计数器
    .i_switch_err_cnt_stat          ( )    , // 刷新错误状态寄存器
    // 寄存器写控制接口      
    .i_switch_reg_bus_we            ( )    , // 寄存器写使能
    .i_switch_reg_bus_we_addr       ( )    , // 寄存器写地址
    .i_switch_reg_bus_we_din        ( )    , // 寄存器写数据
    .i_switch_reg_bus_we_din_v      ( )    , // 寄存器写数据使能
    // 寄存器读控制接口      
    .i_switch_reg_bus_rd            ( )    , // 寄存器读使能
    .i_switch_reg_bus_rd_addr       ( )    , // 寄存器读地址
    .o_switch_reg_bus_we_dout       ( )    , // 读出寄存器数据
    .o_switch_reg_bus_we_dout_v     ( )    , // 读数据有效使能
    /*-------------------- RXMAC 输入数据流 -----------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac0_cross_port_link      ( w_mac0_cross_port_link      )        , // 端口的连接状态
    .i_mac0_cross_port_speed     ( w_mac0_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac0_cross_port_axi_data  ( w_mac0_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac0_cross_axi_data_keep  ( w_mac0_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac0_cross_axi_data_valid ( w_mac0_cross_axi_data_valid )        , // 端口数据有效
    .o_mac0_cross_axi_data_ready ( w_mac0_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac0_cross_axi_data_last  ( w_mac0_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac0_cross_metadata       ( w_mac0_cross_metadata       )        , // 总线 metadata 数据
    .i_mac0_cross_metadata_valid ( w_mac0_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac0_cross_metadata_last  ( w_mac0_cross_metadata_last  )        , // 信息流结束标识
    .o_mac0_cross_metadata_ready ( w_mac0_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac1_cross_port_link      ( w_mac1_cross_port_link      )        , // 端口的连接状态
    .i_mac1_cross_port_speed     ( w_mac1_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac1_cross_port_axi_data  ( w_mac1_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac1_cross_axi_data_keep  ( w_mac1_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac1_cross_axi_data_valid ( w_mac1_cross_axi_data_valid )        , // 端口数据有效
    .o_mac1_cross_axi_data_ready ( w_mac1_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac1_cross_axi_data_last  ( w_mac1_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac1_cross_metadata       ( w_mac1_cross_metadata       )        , // 总线 metadata 数据
    .i_mac1_cross_metadata_valid ( w_mac1_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac1_cross_metadata_last  ( w_mac1_cross_metadata_last  )        , // 信息流结束标识
    .o_mac1_cross_metadata_ready ( w_mac1_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac2_cross_port_link      ( w_mac2_cross_port_link      )        , // 端口的连接状态
    .i_mac2_cross_port_speed     ( w_mac2_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac2_cross_port_axi_data  ( w_mac2_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac2_cross_axi_data_keep  ( w_mac2_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac2_cross_axi_data_valid ( w_mac2_cross_axi_data_valid )        , // 端口数据有效
    .o_mac2_cross_axi_data_ready ( w_mac2_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac2_cross_axi_data_last  ( w_mac2_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac2_cross_metadata       ( w_mac2_cross_metadata       )        , // 总线 metadata 数据
    .i_mac2_cross_metadata_valid ( w_mac2_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac2_cross_metadata_last  ( w_mac2_cross_metadata_last  )        , // 信息流结束标识
    .o_mac2_cross_metadata_ready ( w_mac2_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac3_cross_port_link      ( w_mac3_cross_port_link      )        , // 端口的连接状态
    .i_mac3_cross_port_speed     ( w_mac3_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac3_cross_port_axi_data  ( w_mac3_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac3_cross_axi_data_keep  ( w_mac3_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac3_cross_axi_data_valid ( w_mac3_cross_axi_data_valid )        , // 端口数据有效
    .o_mac3_cross_axi_data_ready ( w_mac3_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac3_cross_axi_data_last  ( w_mac3_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac3_cross_metadata       ( w_mac3_cross_metadata       )        , // 总线 metadata 数据
    .i_mac3_cross_metadata_valid ( w_mac3_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac3_cross_metadata_last  ( w_mac3_cross_metadata_last  )        , // 信息流结束标识
    .o_mac3_cross_metadata_ready ( w_mac3_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac4_cross_port_link      ( w_mac4_cross_port_link      )        , // 端口的连接状态
    .i_mac4_cross_port_speed     ( w_mac4_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac4_cross_port_axi_data  ( w_mac4_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac4_cross_axi_data_keep  ( w_mac4_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac4_cross_axi_data_valid ( w_mac4_cross_axi_data_valid )        , // 端口数据有效
    .o_mac4_cross_axi_data_ready ( w_mac4_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac4_cross_axi_data_last  ( w_mac4_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac4_cross_metadata       ( w_mac4_cross_metadata       )        , // 总线 metadata 数据
    .i_mac4_cross_metadata_valid ( w_mac4_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac4_cross_metadata_last  ( w_mac4_cross_metadata_last  )        , // 信息流结束标识
    .o_mac4_cross_metadata_ready ( w_mac4_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac5_cross_port_link      ( w_mac5_cross_port_link      )        , // 端口的连接状态
    .i_mac5_cross_port_speed     ( w_mac5_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac5_cross_port_axi_data  ( w_mac5_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac5_cross_axi_data_keep  ( w_mac5_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac5_cross_axi_data_valid ( w_mac5_cross_axi_data_valid )        , // 端口数据有效
    .o_mac5_cross_axi_data_ready ( w_mac5_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac5_cross_axi_data_last  ( w_mac5_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac5_cross_metadata       ( w_mac5_cross_metadata       )        , // 总线 metadata 数据
    .i_mac5_cross_metadata_valid ( w_mac5_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac5_cross_metadata_last  ( w_mac5_cross_metadata_last  )        , // 信息流结束标识
    .o_mac5_cross_metadata_ready ( w_mac5_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac6_cross_port_link      ( w_mac6_cross_port_link      )        , // 端口的连接状态
    .i_mac6_cross_port_speed     ( w_mac6_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac6_cross_port_axi_data  ( w_mac6_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac6_cross_axi_data_keep  ( w_mac6_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac6_cross_axi_data_valid ( w_mac6_cross_axi_data_valid )        , // 端口数据有效
    .o_mac6_cross_axi_data_ready ( w_mac6_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac6_cross_axi_data_last  ( w_mac6_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac6_cross_metadata       ( w_mac6_cross_metadata       )        , // 总线 metadata 数据
    .i_mac6_cross_metadata_valid ( w_mac6_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac6_cross_metadata_last  ( w_mac6_cross_metadata_last  )        , // 信息流结束标识
    .o_mac6_cross_metadata_ready ( w_mac6_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac7_cross_port_link      ( w_mac7_cross_port_link      )        , // 端口的连接状态
    .i_mac7_cross_port_speed     ( w_mac7_cross_port_speed     )        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac7_cross_port_axi_data  ( w_mac7_cross_port_axi_data  )        , // 端口数据流，最高位表示crcerr
    .i_mac7_cross_axi_data_keep  ( w_mac7_cross_axi_data_keep  )        , // 端口数据流掩码，有效字节指示
    .i_mac7_cross_axi_data_valid ( w_mac7_cross_axi_data_valid )        , // 端口数据有效
    .o_mac7_cross_axi_data_ready ( w_mac7_cross_axi_data_ready )        , // 交叉总线聚合架构反压流水线信号
    .i_mac7_cross_axi_data_last  ( w_mac7_cross_axi_data_last  )        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac7_cross_metadata       ( w_mac7_cross_metadata       )        , // 总线 metadata 数据
    .i_mac7_cross_metadata_valid ( w_mac7_cross_metadata_valid )        , // 总线 metadata 数据有效信号
    .i_mac7_cross_metadata_last  ( w_mac7_cross_metadata_last  )        , // 信息流结束标识
    .o_mac7_cross_metadata_ready ( w_mac7_cross_metadata_ready )        , // 下游模块反压流水线 
`endif
    /*-------------------- 输出数据流重新进入CROSSBAR交换平面 -----------------------*/
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_lldp_cross_port_link       ( w_lldp_cross_port_link       )     , // 端口的连接状态
    .o_lldp_cross_port_speed      ( w_lldp_cross_port_speed      )     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_lldp_cross_port_axi_data   ( w_lldp_cross_port_axi_data   )     , // 端口数据流，最高位表示crcerr
    .o_lldp_cross_axi_data_keep   ( w_lldp_cross_axi_data_keep   )     , // 端口数据流掩码，有效字节指示
    .o_lldp_cross_axi_data_valid  ( w_lldp_cross_axi_data_valid  )     , // 端口数据有效
    .i_lldp_cross_axi_data_ready  ( w_lldp_cross_axi_data_ready  )     , // 交叉总线聚合架构反压流水线信号
    .o_lldp_cross_axi_data_last   ( w_lldp_cross_axi_data_last   )     , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_lldp_cross_metadata        ( w_lldp_cross_metadata       )     , // 总线 metadata 数据
    .o_lldp_cross_metadata_valid  ( w_lldp_cross_metadata_valid )     , // 总线 metadata 数据有效信号
    .o_lldp_cross_metadata_last   ( w_lldp_cross_metadata_last  )     , // 信息流结束标识
    .i_lldp_cross_metadata_ready  ( w_lldp_cross_metadata_ready )       // 下游模块反压流水线 
);

switch_core_regs #(
    .REG_ADDR_BUS_WIDTH             ()       ,  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH             ()         // 接收 MAC 层的配置寄存器数据位宽
)switch_core_regs_inst (
    .i_clk                          ( i_clk                         )     ,   // 250MHz
    .i_rst                          ( i_rst                         )     ,
    /*---------------------------------------- 寄存器配置接口与接口平台交互 -------------------------------------------*/
    // 寄存器控制信号                     
    .i_refresh_list_pulse           ( i_refresh_list_pulse          )     , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr           ( i_switch_err_cnt_clr          )     , // 刷新错误计数器
    .i_switch_err_cnt_stat          ( i_switch_err_cnt_stat         )     , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_switch_reg_bus_we            ( i_switch_reg_bus_we           )     , // 寄存器写使能
    .i_switch_reg_bus_we_addr       ( i_switch_reg_bus_we_addr      )     , // 寄存器写地址
    .i_switch_reg_bus_we_din        ( i_switch_reg_bus_we_din       )     , // 寄存器写数据
    .i_switch_reg_bus_we_din_v      ( i_switch_reg_bus_we_din_v     )     , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_switch_reg_bus_rd            ( i_switch_reg_bus_rd           )     , // 寄存器读使能
    .i_switch_reg_bus_rd_addr       ( i_switch_reg_bus_rd_addr      )     , // 寄存器读地址
    .o_switch_reg_bus_rd_dout       ( o_switch_reg_bus_rd_dout      )     , // 读出寄存器数据
    .o_switch_reg_bus_rd_dout_v     ( o_switch_reg_bus_rd_dout_v    )     , // 读数据有效使能
    /*----------------------------------- 通用接口（刷新整个平台的寄存器） -------------------------------------------*/
    .o_refresh_list_pulse           ( w_refresh_list_pulse          )     , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .o_switch_err_cnt_clr           ( w_switch_err_cnt_clr          )     , // 刷新错误计数器
    .o_switch_err_cnt_stat          ( w_switch_err_cnt_stat         )     , // 刷新错误状态寄存器
    /*----------------------------------- RXMAC寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    .o_rxmac_reg_bus_we             ( w_rxmac_reg_bus_we            )     , // 寄存器写使能
    .o_rxmac_reg_bus_we_addr        ( w_rxmac_reg_bus_we_addr       )     , // 寄存器写地址
    .o_rxmac_reg_bus_we_din         ( w_rxmac_reg_bus_we_din        )     , // 寄存器写数据
    .o_rxmac_reg_bus_we_din_v       ( w_rxmac_reg_bus_we_din_v      )     , // 寄存器写数据使能
    // 寄存器读控制接口 
    .o_rxmac_reg_bus_rd             ( w_rxmac_reg_bus_rd            )     , // 寄存器读使能
    .o_rxmac_reg_bus_rd_addr        ( w_rxmac_reg_bus_rd_addr       )     , // 寄存器读地址
    .i_rxmac_reg_bus_rd_dout        ( w_rxmac_reg_bus_rd_dout       )     , // 读出寄存器数据
    .i_rxmac_reg_bus_rd_dout_v      ( w_rxmac_reg_bus_rd_dout_v     )     , // 读数据有效使能
    /*----------------------------------- TXMAC寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    .o_txmac_reg_bus_we             ( w_txmac_reg_bus_we            )     , // 寄存器写使能
    .o_txmac_reg_bus_we_addr        ( w_txmac_reg_bus_we_addr       )     , // 寄存器写地址
    .o_txmac_reg_bus_we_din         ( w_txmac_reg_bus_we_din        )     , // 寄存器写数据
    .o_txmac_reg_bus_we_din_v       ( w_txmac_reg_bus_we_din_v      )     , // 寄存器写数据使能
    // 寄存器读控制接口 
    .o_txmac_reg_bus_rd             ( w_txmac_reg_bus_rd            )     , // 寄存器读使能
    .o_txmac_reg_bus_rd_addr        ( w_txmac_reg_bus_rd_addr       )     , // 寄存器读地址
    .i_txmac_reg_bus_rd_dout        ( w_txmac_reg_bus_rd_dout       )     , // 读出寄存器数据
    .i_txmac_reg_bus_rd_dout_v      ( w_txmac_reg_bus_rd_dout_v     )     , // 读数据有效使能
    /*----------------------------------- Swlist寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    .o_swlist_reg_bus_we            ( w_swlist_reg_bus_we           )     , // 寄存器写使能
    .o_swlist_reg_bus_we_addr       ( w_swlist_reg_bus_we_addr      )     , // 寄存器写地址
    .o_swlist_reg_bus_we_din        ( w_swlist_reg_bus_we_din       )     , // 寄存器写数据
    .o_swlist_reg_bus_we_din_v      ( w_swlist_reg_bus_we_din_v     )     , // 寄存器写数据使能
    // 寄存器读控制接口
    .o_swlist_reg_bus_rd            ( w_swlist_reg_bus_rd           )     , // 寄存器读使能
    .o_swlist_reg_bus_rd_addr       ( w_swlist_reg_bus_rd_addr      )     , // 寄存器读地址
    .i_swlist_reg_bus_rd_dout       ( w_swlist_reg_bus_rd_dout      )     , // 读出寄存器数据
    .i_swlist_reg_bus_rd_dout_v     ( w_swlist_reg_bus_rd_dout_v    )      // 读数据有效使能
);



endmodule