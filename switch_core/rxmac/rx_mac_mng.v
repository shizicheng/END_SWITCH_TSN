`include "synth_cmd_define.vh"

module rx_mac_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- CPU_MAC数据流 -------------------------------------------*/
`ifdef CPU_MAC
    // 输入的数据流
    input               wire                                    i_cpu_mac0_port_link                , // 端口的连接状态
    input               wire   [1:0]                            i_cpu_mac0_port_speed               , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_cpu_mac0_port_filter_preamble_v   , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_cpu_mac0_axi_data                 , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_cpu_mac0_axi_data_keep            , // 端口数据流掩码，有效字节指示
    input               wire                                    i_cpu_mac0_axi_data_valid           , // 端口数据有效
    output              wire                                    o_cpu_mac0_axi_data_ready           , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_cpu_mac0_axi_data_last            , // 数据流结束标识
    // 报文时间打时间戳
    output              wire                                    o_cpu_mac0_time_irq                 , // 打时间戳中断信号
    output              wire  [7:0]                             o_cpu_mac0_frame_seq                , // 帧序列号
    output              wire  [7:0]                             o_timestamp0_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac_cpu_hash_key                 , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac_cpu                          , // 目的 mac 的值
    output              wire                                    o_dmac_cpu_vld                      , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac_cpu_hash_key                 , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac_cpu                          , // 源 mac 的值
    output              wire                                    o_smac_cpu_vld                      , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_cpu_port                       , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_cpu_port_vld                   ,
    // CPU_MAC 输出的数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac0_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac0_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac0_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac0_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac0_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac0_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac0_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac0_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac0_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac0_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac0_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC1 数据流 -------------------------------------------*/
`ifdef MAC1
    // 数据流信息 
    input               wire                                    i_mac1_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac1_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac1_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac1_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac1_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac1_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac1_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac1_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac1_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac1_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp1_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac1_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac1                             , // 目的 mac 的值
    output              wire                                    o_dmac1_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac1_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac1                             , // 源 mac 的值
    output              wire                                    o_smac1_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_1_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_1_port_vld                     ,
    // MAC1 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac1_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac1_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac1_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac1_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac1_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac1_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac1_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac1_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac1_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac1_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac1_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC2 数据流 -------------------------------------------*/
`ifdef MAC2
    // 数据流信息 
    input               wire                                    i_mac2_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac2_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac2_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac2_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac2_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac2_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac2_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac2_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac2_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac2_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp2_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac2_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac2                             , // 目的 mac 的值
    output              wire                                    o_dmac2_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac2_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac2                             , // 源 mac 的值
    output              wire                                    o_smac2_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_2_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_2_port_vld                     ,
    // MAC2 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac2_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac2_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac2_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac2_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac2_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac2_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac2_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac2_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac2_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac2_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac2_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC3 数据流 -------------------------------------------*/
`ifdef MAC3
    // 数据流信息 
    input               wire                                    i_mac3_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac3_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac3_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac3_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac3_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac3_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac3_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac3_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac3_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac3_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp3_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac3_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac3                             , // 目的 mac 的值
    output              wire                                    o_dmac3_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac3_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac3                             , // 源 mac 的值
    output              wire                                    o_smac3_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_3_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_3_port_vld                     ,
    // MAC3 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac3_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac3_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac3_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac3_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac3_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac3_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac3_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac3_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac3_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac3_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac3_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC4 数据流 -------------------------------------------*/
`ifdef MAC4
    // 数据流信息 
    input               wire                                    i_mac4_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac4_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac4_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac4_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac4_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac4_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac4_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac4_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac4_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac4_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp4_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac4_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac4                             , // 目的 mac 的值
    output              wire                                    o_dmac4_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac4_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac4                             , // 源 mac 的值
    output              wire                                    o_smac4_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_4_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_4_port_vld                     ,
    // MAC4 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac4_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac4_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac4_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac4_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac4_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac4_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac4_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac4_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac4_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac4_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac4_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC5 数据流 -------------------------------------------*/
`ifdef MAC5
    // 数据流信息 
    input               wire                                    i_mac5_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac5_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac5_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac5_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac5_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac5_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac5_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac5_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac5_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac5_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp5_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac5_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac5                             , // 目的 mac 的值
    output              wire                                    o_dmac5_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac5_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac5                             , // 源 mac 的值
    output              wire                                    o_smac5_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_5_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_5_port_vld                     ,
    // MAC5 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac5_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac5_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac5_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac5_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac5_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac5_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac5_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac5_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac5_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac5_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac5_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC6 数据流 -------------------------------------------*/
`ifdef MAC6
    // 数据流信息 
    input               wire                                    i_mac6_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac6_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac6_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac6_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac6_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac6_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac6_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac6_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac6_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac6_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp6_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac6_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac6                             , // 目的 mac 的值
    output              wire                                    o_dmac6_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac6_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac6                             , // 源 mac 的值
    output              wire                                    o_smac6_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_6_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_6_port_vld                     ,
    // MAC6 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac6_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac6_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac6_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac6_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac6_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac6_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac6_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac6_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac6_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac6_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac6_cross_metadata_ready         , // 下游模块反压流水线 
`endif
    /*---------------------------------------- MAC7 数据流 -------------------------------------------*/
`ifdef MAC7
    // 数据流信息 
    input               wire                                    i_mac7_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac7_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac7_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac7_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac7_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac7_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac7_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac7_axi_data_last                , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac7_time_irq                     , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac7_frame_seq                    , // 帧序列号
    output              wire  [7:0]                             o_timestamp7_addr                   , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac7_hash_key                    , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac7                             , // 目的 mac 的值
    output              wire                                    o_dmac7_vld                         , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac7_hash_key                    , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac7                             , // 源 mac 的值
    output              wire                                    o_smac7_vld                         , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_7_port                         , // 交换表模块返回的查表端口信息
    input               wire                                    i_tx_7_port_vld                     ,
    // MAC7 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_mac7_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac7_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac7_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac7_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac7_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac7_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac7_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac7_cross_metadata               , // 总线 metadata 数据
    output             wire                                     o_mac7_cross_metadata_valid         , // 总线 metadata 数据有效信号
    output             wire                                     o_mac7_cross_metadata_last          , // 信息流结束标识
    input              wire                                     i_mac7_cross_metadata_ready         , // 下游模块反压流水线 
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
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_we_dout            , // 读出寄存器数据
    output              wire                                    o_switch_reg_bus_we_dout_v           // 读数据有效使能
    /*
        metadata 数据组成
        [63](1bit) : port_speed 
        [62:60](3bit) : vlan_pri 
        [59:52](8bit) : tx_prot
        [51:44](8bit) :  acl_frmtype LLDP AS CB
        [43:28](16bit): acl_fetchinfo
        [27](1bit) : frm_vlan_flag
        [26:19](8bit) : rx_port
        [18:15](4bit) : Qos策略
        [14:13](2bit) : 冗余复制与消除(cb)，01表示复制，10表示消除，00表示非CB业务帧
        [12](1bit) : 丢弃位
        [11](1bit) : 是否为关键帧(Qbu)
        [10:0] ：报文长度
    */
);

`ifdef CPU_MAC

    wire                                    w_cpu_mac0_port_link                ; // 端口的连接状态
    wire   [1:0]                            w_cpu_mac0_port_speed               ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_cpu_mac0_port_filter_preamble_v   ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_cpu_mac0_axi_data                 ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_cpu_mac0_axi_data_keep            ; // 端口数据流掩码，有效字节指示
    wire                                    w_cpu_mac0_axi_data_valid           ; // 端口数据有效
    wire                                    w_cpu_mac0_axi_data_ready           ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_cpu_mac0_axi_data_last            ; // 数据流结束标识

    wire                                    w_cpu_mac0_time_irq                 ; // 打时间戳中断信号
    wire  [7:0]                             w_cpu_mac0_frame_seq                ; // 帧序列号
    wire  [7:0]                             w_timestamp0_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac0_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac0_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac0_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac0_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac0_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac0_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac0_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross0_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross0_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross0_metadata_last              ; // 信息流结束标识
    wire                                    w_cross0_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_cpu_hash_key                    ; 
    wire   [47 : 0]                         w_dmac_cpu                             ; 
    wire                                    w_dmac_cpu_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_cpu_hash_key                    ; 
    wire   [47 : 0]                         w_smac_cpu                             ; 
    wire                                    w_smac_cpu_vld                         ; 

    assign              o_dmac_cpu_hash_key                     =   w_dmac_cpu_hash_key                 ;
    assign              o_dmac_cpu                              =   w_dmac_cpu                          ;
    assign              o_dmac_cpu_vld                          =   w_dmac_cpu_vld                      ;
    assign              o_smac_cpu_hash_key                     =   w_smac_cpu_hash_key                 ;
    assign              o_smac_cpu                              =   w_smac_cpu                          ;
    assign              o_smac_cpu_vld                          =   w_smac_cpu_vld                      ;

    assign              w_cpu_mac0_port_link                    =   i_cpu_mac0_port_link             ;       
    assign              w_cpu_mac0_port_speed                   =   i_cpu_mac0_port_speed            ;       
    assign              w_cpu_mac0_port_filter_preamble_v       =   i_cpu_mac0_port_filter_preamble_v;       
    assign              w_cpu_mac0_axi_data                     =   i_cpu_mac0_axi_data              ;       
    assign              w_cpu_mac0_axi_data_keep                =   i_cpu_mac0_axi_data_keep         ;       
    assign              w_cpu_mac0_axi_data_valid               =   i_cpu_mac0_axi_data_valid        ;    
    assign              w_cpu_mac0_axi_data_last                =   i_cpu_mac0_axi_data_last         ;
    assign              o_cpu_mac0_axi_data_ready               =   w_cpu_mac0_axi_data_ready        ;   

    assign              o_cpu_mac0_time_irq                     =   w_cpu_mac0_time_irq              ;
    assign              o_cpu_mac0_frame_seq                    =   w_cpu_mac0_frame_seq             ;
    assign              o_timestamp0_addr                       =   w_timestamp0_addr                ;

    assign              o_mac0_cross_port_link                  =  w_mac0_cross_port_link            ;
    assign              o_mac0_cross_port_speed                 =  w_mac0_cross_port_speed           ;
    assign              o_mac0_cross_port_axi_data              =  w_mac0_cross_port_axi_data        ;
    assign              o_mac0_cross_axi_data_keep              =  w_mac0_cross_axi_data_keep        ;
    assign              o_mac0_cross_axi_data_valid             =  w_mac0_cross_axi_data_valid       ;
    assign              w_mac0_cross_axi_data_ready             =  i_mac0_cross_axi_data_ready       ; 
    assign              o_mac0_cross_axi_data_last              =  w_mac0_cross_axi_data_last        ;
    assign              o_mac0_cross_metadata                   =  w_mac0_cross_metadata             ; 
    assign              o_mac0_cross_metadata_valid             =  w_mac0_cross_metadata_valid       ; 
    assign              o_mac0_cross_metadata_last              =  w_mac0_cross_metadata_last        ; 
    assign              w_mac0_cross_metadata_ready             =  i_mac0_cross_metadata_ready       ;  

`endif

`ifdef MAC1
    wire                                    w_mac1_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac1_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac1_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac1_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac1_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac1_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac1_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac1_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac1_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac1_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp1_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac1_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac1_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac1_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac1_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac1_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac1_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac1_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross1_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross1_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross1_metadata_last              ; // 信息流结束标识
    wire                                    w_cross1_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac1_hash_key                    ; 
    wire   [47 : 0]                         w_dmac1                             ; 
    wire                                    w_dmac1_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac1_hash_key                    ; 
    wire   [47 : 0]                         w_smac1                             ; 
    wire                                    w_smac1_vld                         ; 

    assign              o_dmac1_hash_key                     =   w_dmac1_hash_key                 ;
    assign              o_dmac1                              =   w_dmac1                          ;
    assign              o_dmac1_vld                          =   w_dmac1_vld                      ;
    assign              o_smac1_hash_key                     =   w_smac1_hash_key                 ;
    assign              o_smac1                              =   w_smac1                          ;
    assign              o_smac1_vld                          =   w_smac1_vld                      ;


        
    assign      w_mac1_port_link                    =        i_mac1_port_link             ;                            
    assign      w_mac1_port_speed                   =        i_mac1_port_speed            ;                            
    assign      w_mac1_port_filter_preamble_v       =        i_mac1_port_filter_preamble_v;                            
    assign      w_mac1_axi_data                     =        i_mac1_axi_data              ;                            
    assign      w_mac1_axi_data_keep                =        i_mac1_axi_data_keep         ;                            
    assign      w_mac1_axi_data_valid               =        i_mac1_axi_data_valid        ;                            
    assign      o_mac1_axi_data_ready               =        w_mac1_axi_data_ready        ;              
    assign      w_mac1_axi_data_last                =        i_mac1_axi_data_last         ;
                                                
    assign      o_mac1_time_irq                     =        w_mac1_time_irq              ;                                
    assign      o_mac1_frame_seq                    =        w_mac1_frame_seq             ;                                
    assign      o_timestamp1_addr                   =        w_timestamp1_addr            ;     

    assign     o_mac1_cross_port_link               =  w_mac1_cross_port_link            ;
    assign     o_mac1_cross_port_speed              =  w_mac1_cross_port_speed           ;
    assign     o_mac1_cross_port_axi_data           =  w_mac1_cross_port_axi_data        ;
    assign     o_mac1_cross_axi_data_keep           =  w_mac1_cross_axi_data_keep        ;
    assign     o_mac1_cross_axi_data_valid          =  w_mac1_cross_axi_data_valid       ;
    assign     w_mac1_cross_axi_data_ready          =  i_mac1_cross_axi_data_ready       ; 
    assign     o_mac1_cross_axi_data_last           =  w_mac1_cross_axi_data_last        ;
    assign     o_mac1_cross_metadata                =  w_mac1_cross_metadata             ; 
    assign     o_mac1_cross_metadata_valid          =  w_mac1_cross_metadata_valid       ; 
    assign     o_mac1_cross_metadata_last           =  w_mac1_cross_metadata_last        ; 
    assign     w_mac1_cross_metadata_ready          =  i_mac1_cross_metadata_ready       ;   
                         
`endif

`ifdef MAC2
    wire                                    w_mac2_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac2_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac2_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac2_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac2_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac2_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac2_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac2_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac2_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac2_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp2_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac2_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac2_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac2_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac2_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac2_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac2_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac2_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross2_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross2_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross2_metadata_last              ; // 信息流结束标识
    wire                                    w_cross2_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac2_hash_key                    ; 
    wire   [47 : 0]                         w_dmac2                             ; 
    wire                                    w_dmac2_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac2_hash_key                    ; 
    wire   [47 : 0]                         w_smac2                             ; 
    wire                                    w_smac2_vld                         ; 

    assign              o_dmac2_hash_key                     =   w_dmac2_hash_key                 ;
    assign              o_dmac2                              =   w_dmac2                          ;
    assign              o_dmac2_vld                          =   w_dmac2_vld                      ;
    assign              o_smac2_hash_key                     =   w_smac2_hash_key                 ;
    assign              o_smac2                              =   w_smac2                          ;
    assign              o_smac2_vld                          =   w_smac2_vld                      ;

    assign      w_mac2_port_link                =       i_mac2_port_link             ;  
    assign      w_mac2_port_speed               =       i_mac2_port_speed            ;  
    assign      w_mac2_port_filter_preamble_v   =       i_mac2_port_filter_preamble_v;  
    assign      w_mac2_axi_data                 =       i_mac2_axi_data              ;  
    assign      w_mac2_axi_data_keep            =       i_mac2_axi_data_keep         ;  
    assign      w_mac2_axi_data_valid           =       i_mac2_axi_data_valid        ;            
    assign      o_mac2_axi_data_ready           =       w_mac2_axi_data_ready        ;
    assign      w_mac2_axi_data_last            =       i_mac2_axi_data_last         ;              
              
    assign      o_mac2_time_irq                 =       w_mac2_time_irq              ;                   
    assign      o_mac2_frame_seq                =       w_mac2_frame_seq             ;                     
    assign      o_timestamp2_addr               =       w_timestamp2_addr            ;      

    assign     o_mac2_cross_port_link               =  w_mac2_cross_port_link            ;
    assign     o_mac2_cross_port_speed              =  w_mac2_cross_port_speed           ;
    assign     o_mac2_cross_port_axi_data           =  w_mac2_cross_port_axi_data        ;
    assign     o_mac2_cross_axi_data_keep           =  w_mac2_cross_axi_data_keep        ;
    assign     o_mac2_cross_axi_data_valid          =  w_mac2_cross_axi_data_valid       ;
    assign     w_mac2_cross_axi_data_ready          =  i_mac2_cross_axi_data_ready       ; 
    assign     o_mac2_cross_axi_data_last           =  w_mac2_cross_axi_data_last        ;
    assign     o_mac2_cross_metadata                =  w_mac2_cross_metadata             ; 
    assign     o_mac2_cross_metadata_valid          =  w_mac2_cross_metadata_valid       ; 
    assign     o_mac2_cross_metadata_last           =  w_mac2_cross_metadata_last        ; 
    assign     w_mac2_cross_metadata_ready          =  i_mac2_cross_metadata_ready       ;                  

`endif

`ifdef MAC3
    wire                                    w_mac3_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac3_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac3_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac3_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac3_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac3_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac3_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac3_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac3_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac3_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp3_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac3_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac3_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac3_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac3_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac3_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac3_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac3_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross3_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross3_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross3_metadata_last              ; // 信息流结束标识
    wire                                    w_cross3_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac3_hash_key                    ; 
    wire   [47 : 0]                         w_dmac3                             ; 
    wire                                    w_dmac3_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac3_hash_key                    ; 
    wire   [47 : 0]                         w_smac3                             ; 
    wire                                    w_smac3_vld                         ; 

    assign              o_dmac3_hash_key                     =   w_dmac3_hash_key                 ;
    assign              o_dmac3                              =   w_dmac3                          ;
    assign              o_dmac3_vld                          =   w_dmac3_vld                      ;
    assign              o_smac3_hash_key                     =   w_smac3_hash_key                 ;
    assign              o_smac3                              =   w_smac3                          ;
    assign              o_smac3_vld                          =   w_smac3_vld                      ;

    assign      w_mac3_port_link                =       i_mac3_port_link             ;  
    assign      w_mac3_port_speed               =       i_mac3_port_speed            ;  
    assign      w_mac3_port_filter_preamble_v   =       i_mac3_port_filter_preamble_v;  
    assign      w_mac3_axi_data                 =       i_mac3_axi_data              ;  
    assign      w_mac3_axi_data_keep            =       i_mac3_axi_data_keep         ;  
    assign      w_mac3_axi_data_valid           =       i_mac3_axi_data_valid        ;            
    assign      o_mac3_axi_data_ready           =       w_mac3_axi_data_ready        ;
    assign      w_mac3_axi_data_last            =       i_mac3_axi_data_last         ;              
              
    assign      o_mac3_time_irq                 =       w_mac3_time_irq              ;                   
    assign      o_mac3_frame_seq                =       w_mac3_frame_seq             ;                     
    assign      o_timestamp3_addr               =       w_timestamp3_addr            ;   

    assign     o_mac3_cross_port_link               =  w_mac3_cross_port_link            ;
    assign     o_mac3_cross_port_speed              =  w_mac3_cross_port_speed           ;
    assign     o_mac3_cross_port_axi_data           =  w_mac3_cross_port_axi_data        ;
    assign     o_mac3_cross_axi_data_keep           =  w_mac3_cross_axi_data_keep        ;
    assign     o_mac3_cross_axi_data_valid          =  w_mac3_cross_axi_data_valid       ;
    assign     w_mac3_cross_axi_data_ready          =  i_mac3_cross_axi_data_ready       ; 
    assign     o_mac3_cross_axi_data_last           =  w_mac3_cross_axi_data_last        ;
    assign     o_mac3_cross_metadata                =  w_mac3_cross_metadata             ; 
    assign     o_mac3_cross_metadata_valid          =  w_mac3_cross_metadata_valid       ; 
    assign     o_mac3_cross_metadata_last           =  w_mac3_cross_metadata_last        ; 
    assign     w_mac3_cross_metadata_ready          =  i_mac3_cross_metadata_ready       ;  
`endif

`ifdef MAC4
    wire                                    w_mac4_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac4_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac4_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac4_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac4_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac4_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac4_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac4_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac4_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac4_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp4_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac4_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac4_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac4_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac4_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac4_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac4_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac4_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross4_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross4_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross4_metadata_last              ; // 信息流结束标识
    wire                                    w_cross4_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac4_hash_key                    ; 
    wire   [47 : 0]                         w_dmac4                             ; 
    wire                                    w_dmac4_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac4_hash_key                    ; 
    wire   [47 : 0]                         w_smac4                             ; 
    wire                                    w_smac4_vld                         ; 

    assign              o_dmac4_hash_key                     =   w_dmac4_hash_key                 ;
    assign              o_dmac4                              =   w_dmac4                          ;
    assign              o_dmac4_vld                          =   w_dmac4_vld                      ;
    assign              o_smac4_hash_key                     =   w_smac4_hash_key                 ;
    assign              o_smac4                              =   w_smac4                          ;
    assign              o_smac4_vld                          =   w_smac4_vld                      ;

    assign      w_mac4_port_link                =       i_mac4_port_link             ;  
    assign      w_mac4_port_speed               =       i_mac4_port_speed            ;  
    assign      w_mac4_port_filter_preamble_v   =       i_mac4_port_filter_preamble_v;  
    assign      w_mac4_axi_data                 =       i_mac4_axi_data              ;  
    assign      w_mac4_axi_data_keep            =       i_mac4_axi_data_keep         ;  
    assign      w_mac4_axi_data_valid           =       i_mac4_axi_data_valid        ;            
    assign      o_mac4_axi_data_ready           =       w_mac4_axi_data_ready        ;
    assign      w_mac4_axi_data_last            =       i_mac4_axi_data_last         ;              
              
    assign      o_mac4_time_irq                 =       w_mac4_time_irq              ;                   
    assign      o_mac4_frame_seq                =       w_mac4_frame_seq             ;                     
    assign      o_timestamp4_addr               =       w_timestamp4_addr            ;  

    assign     o_mac4_cross_port_link               =  w_mac4_cross_port_link            ;
    assign     o_mac4_cross_port_speed              =  w_mac4_cross_port_speed           ;
    assign     o_mac4_cross_port_axi_data           =  w_mac4_cross_port_axi_data        ;
    assign     o_mac4_cross_axi_data_keep           =  w_mac4_cross_axi_data_keep        ;
    assign     o_mac4_cross_axi_data_valid          =  w_mac4_cross_axi_data_valid       ;
    assign     w_mac4_cross_axi_data_ready          =  i_mac4_cross_axi_data_ready       ; 
    assign     o_mac4_cross_axi_data_last           =  w_mac4_cross_axi_data_last        ;
    assign     o_mac4_cross_metadata                =  w_mac4_cross_metadata             ; 
    assign     o_mac4_cross_metadata_valid          =  w_mac4_cross_metadata_valid       ; 
    assign     o_mac4_cross_metadata_last           =  w_mac4_cross_metadata_last        ; 
    assign     w_mac4_cross_metadata_ready          =  i_mac4_cross_metadata_ready       ;  
`endif

`ifdef MAC5
    wire                                    w_mac5_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac5_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac5_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac5_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac5_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac5_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac5_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac5_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac5_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac5_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp5_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac5_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac5_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac5_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac5_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac5_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac5_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac5_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross5_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross5_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross5_metadata_last              ; // 信息流结束标识
    wire                                    w_cross5_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac5_hash_key                    ; 
    wire   [47 : 0]                         w_dmac5                             ; 
    wire                                    w_dmac5_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac5_hash_key                    ; 
    wire   [47 : 0]                         w_smac5                             ; 
    wire                                    w_smac5_vld                         ; 

    assign              o_dmac5_hash_key                     =   w_dmac5_hash_key                 ;
    assign              o_dmac5                              =   w_dmac5                          ;
    assign              o_dmac5_vld                          =   w_dmac5_vld                      ;
    assign              o_smac5_hash_key                     =   w_smac5_hash_key                 ;
    assign              o_smac5                              =   w_smac5                          ;
    assign              o_smac5_vld                          =   w_smac5_vld                      ;

    assign      w_mac5_port_link                =       i_mac5_port_link             ;  
    assign      w_mac5_port_speed               =       i_mac5_port_speed            ;  
    assign      w_mac5_port_filter_preamble_v   =       i_mac5_port_filter_preamble_v;  
    assign      w_mac5_axi_data                 =       i_mac5_axi_data              ;  
    assign      w_mac5_axi_data_keep            =       i_mac5_axi_data_keep         ;  
    assign      w_mac5_axi_data_valid           =       i_mac5_axi_data_valid        ;            
    assign      o_mac5_axi_data_ready           =       w_mac5_axi_data_ready        ;
    assign      w_mac5_axi_data_last            =       i_mac5_axi_data_last         ;              
             
    assign      o_mac5_time_irq                 =       w_mac5_time_irq              ;                   
    assign      o_mac5_frame_seq                =       w_mac5_frame_seq             ;                     
    assign      o_timestamp5_addr               =       w_timestamp5_addr            ;  

    assign     o_mac5_cross_port_link               =  w_mac5_cross_port_link            ;
    assign     o_mac5_cross_port_speed              =  w_mac5_cross_port_speed           ;
    assign     o_mac5_cross_port_axi_data           =  w_mac5_cross_port_axi_data        ;
    assign     o_mac5_cross_axi_data_keep           =  w_mac5_cross_axi_data_keep        ;
    assign     o_mac5_cross_axi_data_valid          =  w_mac5_cross_axi_data_valid       ;
    assign     w_mac5_cross_axi_data_ready          =  i_mac5_cross_axi_data_ready       ; 
    assign     o_mac5_cross_axi_data_last           =  w_mac5_cross_axi_data_last        ;
    assign     o_mac5_cross_metadata                =  w_mac5_cross_metadata             ; 
    assign     o_mac5_cross_metadata_valid          =  w_mac5_cross_metadata_valid       ; 
    assign     o_mac5_cross_metadata_last           =  w_mac5_cross_metadata_last        ; 
    assign     w_mac5_cross_metadata_ready          =  i_mac5_cross_metadata_ready       ;  
`endif

`ifdef MAC6
    wire                                    w_mac6_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac6_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac6_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac6_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac6_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac6_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac6_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac6_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac6_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac6_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp6_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac6_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac6_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac6_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac6_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac6_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac6_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac6_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross6_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross6_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross6_metadata_last              ; // 信息流结束标识
    wire                                    w_cross6_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac6_hash_key                    ; 
    wire   [47 : 0]                         w_dmac6                             ; 
    wire                                    w_dmac6_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac6_hash_key                    ; 
    wire   [47 : 0]                         w_smac6                             ; 
    wire                                    w_smac6_vld                         ; 
    

    assign              o_dmac6_hash_key                     =   w_dmac6_hash_key                 ;
    assign              o_dmac6                              =   w_dmac6                          ;
    assign              o_dmac6_vld                          =   w_dmac6_vld                      ;
    assign              o_smac6_hash_key                     =   w_smac6_hash_key                 ;
    assign              o_smac6                              =   w_smac6                          ;
    assign              o_smac6_vld                          =   w_smac6_vld                      ;

    assign      w_mac6_port_link                =       i_mac6_port_link             ;  
    assign      w_mac6_port_speed               =       i_mac6_port_speed            ;  
    assign      w_mac6_port_filter_preamble_v   =       i_mac6_port_filter_preamble_v;  
    assign      w_mac6_axi_data                 =       i_mac6_axi_data              ;  
    assign      w_mac6_axi_data_keep            =       i_mac6_axi_data_keep         ;  
    assign      w_mac6_axi_data_valid           =       i_mac6_axi_data_valid        ;            
    assign      o_mac6_axi_data_ready           =       w_mac6_axi_data_ready        ;
    assign      w_mac6_axi_data_last            =       i_mac6_axi_data_last         ;              

    assign      o_mac6_time_irq                 =       w_mac6_time_irq              ;                   
    assign      o_mac6_frame_seq                =       w_mac6_frame_seq             ;                     
    assign      o_timestamp6_addr               =       w_timestamp6_addr            ;  

    assign     o_mac6_cross_port_link               =  w_mac6_cross_port_link            ;
    assign     o_mac6_cross_port_speed              =  w_mac6_cross_port_speed           ;
    assign     o_mac6_cross_port_axi_data           =  w_mac6_cross_port_axi_data        ;
    assign     o_mac6_cross_axi_data_keep           =  w_mac6_cross_axi_data_keep        ;
    assign     o_mac6_cross_axi_data_valid          =  w_mac6_cross_axi_data_valid       ;
    assign     w_mac6_cross_axi_data_ready          =  i_mac6_cross_axi_data_ready       ; 
    assign     o_mac6_cross_axi_data_last           =  w_mac6_cross_axi_data_last        ;
    assign     o_mac6_cross_metadata                =  w_mac6_cross_metadata             ; 
    assign     o_mac6_cross_metadata_valid          =  w_mac6_cross_metadata_valid       ; 
    assign     o_mac6_cross_metadata_last           =  w_mac6_cross_metadata_last        ; 
    assign     w_mac6_cross_metadata_ready          =  i_mac6_cross_metadata_ready       ; 
`endif

`ifdef MAC7
    wire                                    w_mac7_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_mac7_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac7_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac7_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac7_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac7_axi_data_valid               ; // 端口数据有效
    wire                                    w_mac7_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac7_axi_data_last                ; // 数据流结束标识

    wire                                    w_mac7_time_irq                     ; // 打时间戳中断信号
    wire  [7:0]                             w_mac7_frame_seq                    ; // 帧序列号
    wire  [7:0]                             w_timestamp7_addr                   ; // 打时间戳存储的 RAM 地址

    wire                                    w_mac7_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac7_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac7_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac7_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac7_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_mac7_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac7_cross_axi_data_last          ; // 数据流结束标识
    wire   [METADATA_WIDTH-1:0]             w_cross7_metadata                   ; // 聚合总线 metadata 数据
    wire                                    w_cross7_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                    w_cross7_metadata_last              ; // 信息流结束标识
    wire                                    w_cross7_metadata_ready             ; // 下游模块反压流水线 

    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac7_hash_key                    ; 
    wire   [47 : 0]                         w_dmac7                             ; 
    wire                                    w_dmac7_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac7_hash_key                    ; 
    wire   [47 : 0]                         w_smac7                             ; 
    wire                                    w_smac7_vld                         ; 

    assign              o_dmac7_hash_key                     =   w_dmac7_hash_key        ;
    assign              o_dmac7                              =   w_dmac7                 ;
    assign              o_dmac7_vld                          =   w_dmac7_vld             ;
    assign              o_smac7_hash_key                     =   w_smac7_hash_key        ;
    assign              o_smac7                              =   w_smac7                 ;
    assign              o_smac7_vld                          =   w_smac7_vld             ;

    assign      w_mac7_port_link                =       i_mac7_port_link                 ;  
    assign      w_mac7_port_speed               =       i_mac7_port_speed                ;  
    assign      w_mac7_port_filter_preamble_v   =       i_mac7_port_filter_preamble_v    ;  
    assign      w_mac7_axi_data                 =       i_mac7_axi_data                  ;  
    assign      w_mac7_axi_data_keep            =       i_mac7_axi_data_keep             ;  
    assign      w_mac7_axi_data_valid           =       i_mac7_axi_data_valid            ;            
    assign      o_mac7_axi_data_ready           =       w_mac7_axi_data_ready            ;
    assign      w_mac7_axi_data_last            =       i_mac7_axi_data_last             ;              
                     
    assign      o_mac7_time_irq                 =       w_mac7_time_irq                  ;                   
    assign      o_mac7_frame_seq                =       w_mac7_frame_seq                 ;                     
    assign      o_timestamp7_addr               =       w_timestamp7_addr                ;  

    assign     o_mac7_cross_port_link               =  w_mac7_cross_port_link            ;
    assign     o_mac7_cross_port_speed              =  w_mac7_cross_port_speed           ;
    assign     o_mac7_cross_port_axi_data           =  w_mac7_cross_port_axi_data        ;
    assign     o_mac7_cross_axi_data_keep           =  w_mac7_cross_axi_data_keep        ;
    assign     o_mac7_cross_axi_data_valid          =  w_mac7_cross_axi_data_valid       ;
    assign     w_mac7_cross_axi_data_ready          =  i_mac7_cross_axi_data_ready       ; 
    assign     o_mac7_cross_axi_data_last           =  w_mac7_cross_axi_data_last        ;
    assign     o_mac7_cross_metadata                =  w_mac7_cross_metadata             ; 
    assign     o_mac7_cross_metadata_valid          =  w_mac7_cross_metadata_valid       ; 
    assign     o_mac7_cross_metadata_last           =  w_mac7_cross_metadata_last        ; 
    assign     w_mac7_cross_metadata_ready          =  i_mac7_cross_metadata_ready       ; 
`endif

`ifdef CPU_MAC
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst0 (
        .i_clk                              (i_clk                                  ),   // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_cpu_mac0_port_link                   ), // 端口的连接状态
        .i_mac_port_speed                   (w_cpu_mac0_port_speed                  ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_cpu_mac0_port_filter_preamble_v      ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_cpu_mac0_axi_data                    ), // 端口数据流
        .i_mac_axi_data_keep                (w_cpu_mac0_axi_data_keep               ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_cpu_mac0_axi_data_valid              ), // 端口数据有效
        .o_mac_axi_data_ready               (w_cpu_mac0_axi_data_ready              ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_cpu_mac0_axi_data_last               ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_cpu_mac0_time_irq                    ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_cpu_mac0_frame_seq                   ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp0_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac_cpu_hash_key                    ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac_cpu                             ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac_cpu_vld                         ), // dmac_vld
        .o_smac_hash_key                    (w_smac_cpu_hash_key                    ), // 源 mac 的值有效标识
        .o_smac                             (w_smac_cpu                             ), // 源 mac 的值
        .o_smac_vld                         (w_smac_cpu_vld                         ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac0_cross_port_link                 ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac0_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac0_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac0_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac0_cross_axi_data_valid            ), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac0_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac0_cross_axi_data_last             ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross0_metadata                      ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross0_metadata_valid                ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross0_metadata_last                 ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross0_metadata_ready                ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC1
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst1 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac1_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac1_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac1_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac1_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac1_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac1_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac1_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac1_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac1_time_irq                        ), // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac1_frame_seq                       ), // 帧序列号
        .o_timestamp_addr                   (w_timestamp1_addr                      ), // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac1_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac1                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac1_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac1_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac1                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac1_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac1_cross_port_link                 ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac1_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac1_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac1_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac1_cross_axi_data_valid            ), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac1_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac1_cross_axi_data_last             ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross1_metadata                      ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross1_metadata_valid                ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross1_metadata_last                 ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross1_metadata_ready                ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC2
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst2 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac2_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac2_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac2_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac2_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac2_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac2_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac2_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac2_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac2_time_irq                        ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac2_frame_seq                       ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp2_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac2_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac2                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac2_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac2_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac2                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac2_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac2_cross_port_link                 ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac2_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac2_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac2_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac2_cross_axi_data_valid            ), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac2_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac2_cross_axi_data_last             ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross2_metadata                      ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross2_metadata_valid                ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross2_metadata_last                 ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross2_metadata_ready                ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC3
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst3 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac3_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac3_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac3_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac3_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac3_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac3_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac3_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac3_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac3_time_irq                        ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac3_frame_seq                       ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp3_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac3_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac3                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac3_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac3_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac3                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac3_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac3_cross_port_link     ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac3_cross_port_speed    ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac3_cross_port_axi_data ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac3_cross_axi_data_keep ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac3_cross_axi_data_valid), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac3_cross_axi_data_ready), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac3_cross_axi_data_last ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross3_metadata          ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross3_metadata_valid    ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross3_metadata_last     ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross3_metadata_ready    ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC4
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst4 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac4_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac4_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac4_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac4_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac4_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac4_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac4_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac4_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac4_time_irq                        ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac4_frame_seq                       ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp4_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac4_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac4                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac4_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac4_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac4                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac4_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac4_cross_port_link     ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac4_cross_port_speed    ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac4_cross_port_axi_data ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac4_cross_axi_data_keep ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac4_cross_axi_data_valid), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac4_cross_axi_data_ready), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac4_cross_axi_data_last ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross4_metadata          ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross4_metadata_valid    ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross4_metadata_last     ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross4_metadata_ready    ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (), 
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC5
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst5 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac5_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac5_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac5_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac5_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac5_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac5_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac5_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac5_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac5_time_irq                        ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac5_frame_seq                       ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp5_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac5_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac5                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac5_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac5_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac5                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac5_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac5_cross_port_link                ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac5_cross_port_speed               ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac5_cross_port_axi_data            ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac5_cross_axi_data_keep            ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac5_cross_axi_data_valid           ), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac5_cross_axi_data_ready           ), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac5_cross_axi_data_last            ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross5_metadata                     ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross5_metadata_valid               ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross5_metadata_last                ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross5_metadata_ready               ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC6
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst6 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac6_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac6_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac6_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac6_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac6_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac6_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac6_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac6_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac6_time_irq                        ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac6_frame_seq                       ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp6_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac6_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac6                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac6_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac6_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac6                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac6_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac6_cross_port_link                 ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac6_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac6_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac6_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac6_cross_axi_data_valid            ), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac6_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac6_cross_axi_data_last             ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross6_metadata                     ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross6_metadata_valid               ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross6_metadata_last                ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross6_metadata_ready               ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif

`ifdef MAC7
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ),        // 交换机的端口数
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ),        // Mac_port_mng 数据位宽
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ),        // 哈希计算的值的位宽 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ),        // 信息流位宽
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       )         // 聚合总线输出
    )rx_port_mng_inst7 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
        .i_mac_port_link                    (w_mac7_port_link                       ), // 端口的连接状态
        .i_mac_port_speed                   (w_mac7_port_speed                      ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac_port_filter_preamble_v       (w_mac7_port_filter_preamble_v          ), // 端口是否过滤前导码信息
        .i_mac_axi_data                     (w_mac7_axi_data                        ), // 端口数据流
        .i_mac_axi_data_keep                (w_mac7_axi_data_keep                   ), // 端口数据流掩码，有效字节指示
        .i_mac_axi_data_valid               (w_mac7_axi_data_valid                  ), // 端口数据有效
        .o_mac_axi_data_ready               (w_mac7_axi_data_ready                  ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac_axi_data_last                (w_mac7_axi_data_last                   ), // 数据流结束标识
        /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
        .o_mac_time_irq                     (w_mac7_time_irq                        ) , // 打时间戳中断信号
        .o_mac_frame_seq                    (w_mac7_frame_seq                       ) , // 帧序列号
        .o_timestamp_addr                   (w_timestamp7_addr                      ) , // 打时间戳存储的 RAM 地址
        /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
        .o_dmac_hash_key                    (w_dmac7_hash_key                      ), // 目的 mac 的哈希值
        .o_dmac                             (w_dmac7                               ), // 目的 mac 的值
        .o_dmac_vld                         (w_dmac7_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac7_hash_key                      ), // 源 mac 的值有效标识
        .o_smac                             (w_smac7                               ), // 源 mac 的值
        .o_smac_vld                         (w_smac7_vld                           ), // smac_vld
        /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
        .o_mac_cross_port_link              (w_mac7_cross_port_link                 ), // 端口的连接状态
        .o_mac_cross_port_speed             (w_mac7_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac_cross_port_axi_data          (w_mac7_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac_cross_axi_data_keep          (w_mac7_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac_cross_axi_data_valid         (w_mac7_cross_axi_data_valid            ), // 端口数据有效
        .i_mac_cross_axi_data_ready         (w_mac7_cross_axi_data_ready            ), // 交叉总线聚合架构反压流水线信号
        .o_mac_cross_axi_data_last          (w_mac7_cross_axi_data_last             ), // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .o_cross_metadata                   (w_cross7_metadata                      ), // 聚合总线 metadata 数据
        .o_cross_metadata_valid             (w_cross7_metadata_valid                ), // 聚合总线 metadata 数据有效信号
        .o_cross_metadata_last              (w_cross7_metadata_last                 ), // 信息流结束标识
        .i_cross_metadata_ready             (w_cross7_metadata_ready                ), // 下游模块反压流水线 
        /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
        .i_hash_ploy_regs                   (), // 哈希多项式
        .i_hash_init_val_regs               (), // 哈希多项式初始值
        .i_hash_regs_vld                    (),
        .i_port_rxmac_down_regs             (), // 端口接收方向MAC关闭使能
        .i_port_broadcast_drop_regs         (), // 端口广播帧丢弃使能
        .i_port_multicast_drop_regs         (), // 端口组播帧丢弃使能
        .i_port_loopback_drop_regs          (), // 端口环回帧丢弃使能
        .i_port_mac_regs                    (), // 端口的 MAC 地址
        .i_port_mac_vld_regs                (), // 使能端口 MAC 地址有效
        .i_port_mtu_regs                    (), // MTU配置值
        .i_port_mirror_frwd_regs            (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
        .i_port_flowctrl_cfg_regs           (), // 限流管理配置
        .i_port_rx_ultrashortinterval_num   (), // 帧间隔
        // ACL 寄存器
        .i_acl_port_sel                     (), // 选择要配置的端口
        .i_acl_clr_list_regs                (), // 清空寄存器列表
        .o_acl_list_rdy_regs                (), // 配置寄存器操作空闲
        .i_acl_item_sel_regs                (), // 配置条目选择
        .i_acl_item_waddr_regs              (), // 每个条目最大支持比对 64 字节
        .i_acl_item_din_regs                (), // 需要比较的字节数据
        .i_acl_item_we_regs                 (), // 配置使能信号
        .i_acl_item_rslt_regs               (), // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
        .i_acl_item_complete_regs           (), // 端口 ACL 参数配置完成使能信号
        // 状态寄存器
        .o_port_diag_state                  (), // 端口状态寄存器，详情见寄存器表说明定义 
        // 诊断寄存器
        .o_port_rx_ultrashort_frm           (), // 端口接收超短帧(小于64字节)
        .o_port_rx_overlength_frm           (), // 端口接收超长帧(大于MTU字节)
        .o_port_rx_crcerr_frm               (), // 端口接收CRC错误帧
        .o_port_rx_loopback_frm_cnt         (), // 端口接收环回帧计数器值
        .o_port_broadflow_drop_cnt          (), // 端口接收到广播限流而丢弃的帧计数器值
        .o_port_multiflow_drop_cnt          (), // 端口接收到组播限流而丢弃的帧计数器值
        // 流量统计寄存器
        .o_port_rx_byte_cnt                 (), // 端口0接收字节个数计数器值
        .o_port_rx_frame_cnt                ()  // 端口0接收帧个数计数器值  
    );
`endif


rx_port_reg#(
    .REG_ADDR_BUS_WIDTH                         ()       ,  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH                         ()         // 接收 MAC 层的配置寄存器数据位宽
)rx_port_reg_inst (
    .i_clk                                      ()          ,   // 250MHz
    .i_rst                                      ()          ,
    /*---------------------------------------- 平台寄存器输入与 RXMAC 相关的寄存器 -------------------------------------------*/
`ifdef CPU_MAC
    .o_hash_ploy_regs_0                         (), // 哈希多项式
    .o_hash_init_val_regs_0                     (), // 哈希多项式初始值
    .o_hash_regs_vld_0                          (),
    .o_port_rxmac_down_regs_0                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_0               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_0               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_0                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_0                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_0                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_0                          (), // MTU配置值
    .o_port_mirror_frwd_regs_0                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_0                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_0         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_0                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_0                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_0                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_0                      () , // 配置条目选择
    .o_acl_item_waddr_regs_0                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_0                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_0                       () , // 配置使能信号
    .o_acl_item_rslt_regs_0                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_0                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_0                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_0                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_0                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_0                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_0               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_0                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_0                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_0                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_0                      () ,  // 端口0接收帧个数计数器值  
`endif
`ifdef MAC1
    .o_hash_ploy_regs_1                         (), // 哈希多项式
    .o_hash_init_val_regs_1                     (), // 哈希多项式初始值
    .o_hash_regs_vld_1                          (),
    .o_port_rxmac_down_regs_1                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_1               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_1               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_1                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_1                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_1                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_1                          (), // MTU配置值
    .o_port_mirror_frwd_regs_1                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_1                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_1         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_1                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_1                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_1                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_1                      () , // 配置条目选择
    .o_acl_item_waddr_regs_1                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_1                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_1                       () , // 配置使能信号
    .o_acl_item_rslt_regs_1                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_1                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_1                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_1                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_1                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_1                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_1               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_1                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_1                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_1                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_1                      () ,  // 端口0接收帧个数计数器值  
`endif
`ifdef MAC2
    .o_hash_ploy_regs_2                         (), // 哈希多项式
    .o_hash_init_val_regs_2                     (), // 哈希多项式初始值
    .o_hash_regs_vld_2                          (),
    .o_port_rxmac_down_regs_2                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_2               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_2               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_2                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_2                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_2                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_2                          (), // MTU配置值
    .o_port_mirror_frwd_regs_2                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_2                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_2         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_2                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_2                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_2                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_2                      () , // 配置条目选择
    .o_acl_item_waddr_regs_2                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_2                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_2                       () , // 配置使能信号
    .o_acl_item_rslt_regs_2                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_2                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_2                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_2                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_2                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_2                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_2               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_2                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_2                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_2                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_2                      () ,  // 端口0接收帧个数计数器值  
`endif
`ifdef MAC3
    .o_hash_ploy_regs_3                         () , // 哈希多项式
    .o_hash_init_val_regs_3                     () , // 哈希多项式初始值
    .o_hash_regs_vld_3                          () ,
    .o_port_rxmac_down_regs_3                   () , // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_3               () , // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_3               () , // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_3                () , // 端口环回帧丢弃使能
    .o_port_mac_regs_3                          () , // 端口的 MAC 地址
    .o_port_mac_vld_regs_3                      () , // 使能端口 MAC 地址有效
    .o_port_mtu_regs_3                          () , // MTU配置值
    .o_port_mirror_frwd_regs_3                  () , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_3                 () , // 限流管理配置
    .o_port_rx_ultrashortinterval_num_3         () , // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_3                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_3                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_3                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_3                      () , // 配置条目选择
    .o_acl_item_waddr_regs_3                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_3                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_3                       () , // 配置使能信号
    .o_acl_item_rslt_regs_3                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_3                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_3                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_3                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_3                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_3                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_3               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_3                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_3                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_3                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_3                      () ,  // 端口0接收帧个数计数器值  
`endif
`ifdef MAC4
    .o_hash_ploy_regs_4                         (), // 哈希多项式
    .o_hash_init_val_regs_4                     (), // 哈希多项式初始值
    .o_hash_regs_vld_4                          (),
    .o_port_rxmac_down_regs_4                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_4               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_4               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_4                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_4                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_4                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_4                          (), // MTU配置值
    .o_port_mirror_frwd_regs_4                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_4                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_4         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_4                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_4                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_4                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_4                      () , // 配置条目选择
    .o_acl_item_waddr_regs_4                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_4                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_4                       () , // 配置使能信号
    .o_acl_item_rslt_regs_4                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_4                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_4                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_4                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_4                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_4                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_4               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_4                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_4                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_4                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_4                      () ,  // 端口0接收帧个数计数器值   
`endif
`ifdef MAC5
    .o_hash_ploy_regs_5                         (), // 哈希多项式
    .o_hash_init_val_regs_5                     (), // 哈希多项式初始值
    .o_hash_regs_vld_5                          (),
    .o_port_rxmac_down_regs_5                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_5               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_5               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_5                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_5                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_5                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_5                          (), // MTU配置值
    .o_port_mirror_frwd_regs_5                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_5                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_5         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_5                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_5                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_5                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_5                      () , // 配置条目选择
    .o_acl_item_waddr_regs_5                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_5                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_5                       () , // 配置使能信号
    .o_acl_item_rslt_regs_5                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_5                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_5                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_5                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_5                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_5                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_5               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_5                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_5                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_5                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_5                      () ,  // 端口0接收帧个数计数器值  
`endif
`ifdef MAC6
    .o_hash_ploy_regs_6                         (), // 哈希多项式
    .o_hash_init_val_regs_6                     (), // 哈希多项式初始值
    .o_hash_regs_vld_6                          (),
    .o_port_rxmac_down_regs_6                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_6               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_6               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_6                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_6                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_6                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_6                          (), // MTU配置值
    .o_port_mirror_frwd_regs_6                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_6                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_6         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_6                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_6                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_6                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_6                      () , // 配置条目选择
    .o_acl_item_waddr_regs_6                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_6                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_6                       () , // 配置使能信号
    .o_acl_item_rslt_regs_6                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_6                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_6                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_6                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_6                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_6                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_6               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_6                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_6                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_6                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_6                      () ,  // 端口0接收帧个数计数器值  
`endif
`ifdef MAC7
    .o_hash_ploy_regs_7                         (), // 哈希多项式
    .o_hash_init_val_regs_7                     (), // 哈希多项式初始值
    .o_hash_regs_vld_7                          (),
    .o_port_rxmac_down_regs_7                   (), // 端口接收方向MAC关闭使能
    .o_port_broadcast_drop_regs_7               (), // 端口广播帧丢弃使能
    .o_port_multicast_drop_regs_7               (), // 端口组播帧丢弃使能
    .o_port_loopback_drop_regs_7                (), // 端口环回帧丢弃使能
    .o_port_mac_regs_7                          (), // 端口的 MAC 地址
    .o_port_mac_vld_regs_7                      (), // 使能端口 MAC 地址有效
    .o_port_mtu_regs_7                          (), // MTU配置值
    .o_port_mirror_frwd_regs_7                  (), // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    .o_port_flowctrl_cfg_regs_7                 (), // 限流管理配置
    .o_port_rx_ultrashortinterval_num_7         (), // 帧间隔
    // ACL 寄存
    .o_acl_port_sel_7                           () , // 选择要配置的端口
    .o_acl_clr_list_regs_7                      () , // 清空寄存器列表
    .i_acl_list_rdy_regs_7                      () , // 配置寄存器操作空闲
    .o_acl_item_sel_regs_7                      () , // 配置条目选择
    .o_acl_item_waddr_regs_7                    () , // 每个条目最大支持比对 64 字节
    .o_acl_item_din_regs_7                      () , // 需要比较的字节数据
    .o_acl_item_we_regs_7                       () , // 配置使能信号
    .o_acl_item_rslt_regs_7                     () , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    .o_acl_item_complete_regs_7                 () , // 端口 ACL 参数配置完成使能信号
    // 状态寄存器
    .i_port_diag_state_7                        () , // 端口状态寄存器，详情见寄存器表说明定义 
    // 诊断寄存器
    .i_port_rx_ultrashort_frm_7                 () , // 端口接收超短帧(小于64字节)
    .i_port_rx_overlength_frm_7                 () , // 端口接收超长帧(大于MTU字节)
    .i_port_rx_crcerr_frm_7                     () , // 端口接收CRC错误帧
    .i_port_rx_loopback_frm_cnt_7               () , // 端口接收环回帧计数器值
    .i_port_broadflow_drop_cnt_7                () , // 端口接收到广播限流而丢弃的帧计数器值
    .i_port_multiflow_drop_cnt_7                () , // 端口接收到组播限流而丢弃的帧计数器值
    // 流量统计寄存器
    .i_port_rx_byte_cnt_7                       () , // 端口0接收字节个数计数器值
    .i_port_rx_frame_cnt_7                      () ,  // 端口0接收帧个数计数器值  
`endif
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    .o_refresh_list_pulse                       () , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .o_switch_err_cnt_clr                       () , // 刷新错误计数器
    .o_switch_err_cnt_stat                      () , // 刷新错误状态寄存器
    // 寄存器写控制接口         
    .o_switch_reg_bus_we                        () , // 寄存器写使能
    .o_switch_reg_bus_we_addr                   () , // 寄存器写地址
    .o_switch_reg_bus_we_din                    () , // 寄存器写数据
    .o_switch_reg_bus_we_din_v                  () , // 寄存器写数据使能
    // 寄存器读控制接口         
    .o_switch_reg_bus_rd                        () , // 寄存器读使能
    .o_switch_reg_bus_rd_addr                   () , // 寄存器读地址
    .i_switch_reg_bus_rd_dout                   () , // 读出寄存器数据
    .i_switch_reg_bus_rd_dout_v                 ()  // 读数据有效使能
);


endmodule