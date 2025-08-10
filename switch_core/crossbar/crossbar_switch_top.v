`include "synth_cmd_define.vh"

module crossbar_switch_top#(

    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    /*-------------------- RXMAC 输入数据流 -----------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac0_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac0_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac0_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac0_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac0_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac0_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac0_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac0_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac0_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac0_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac0_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac1_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac1_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac1_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac1_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac1_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac1_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac1_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac1_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac1_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac1_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac1_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac2_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac2_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac2_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac2_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac2_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac2_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac2_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac2_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac2_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac2_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac2_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac3_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac3_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac3_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac3_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac3_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac3_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac3_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac3_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac3_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac3_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac3_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac4_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac4_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac4_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac4_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac4_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac4_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac4_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac4_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac4_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac4_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac4_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac5_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac5_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac5_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac5_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac5_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac5_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac5_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac5_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac5_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac5_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac5_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac6_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac6_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac6_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac6_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac6_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac6_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac6_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac6_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac6_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac6_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac6_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac7_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac7_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac7_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac7_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac7_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac7_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac7_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac7_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac7_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac7_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac7_cross_metadata_ready         , // 下游模块反压流水线 
`endif
`ifdef TSN_AS
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_tsn_as_cross_port_link            , // 端口的连接状态
    input               wire   [1:0]                            i_tsn_as_cross_port_speed           , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_tsn_as_cross_port_axi_data        , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_tsn_as_cross_axi_data_keep        , // 端口数据流掩码，有效字节指示
    input               wire                                    i_tsn_as_cross_axi_data_valid       , // 端口数据有效
    output              wire                                    o_tsn_as_cross_axi_data_ready       , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_tsn_as_cross_axi_data_last        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_tsn_as_cross_metadata             , // 总线 metadata 数据
    input              wire                                     i_tsn_as_cross_metadata_valid       , // 总线 metadata 数据有效信号
    input              wire                                     i_tsn_as_cross_metadata_last        , // 信息流结束标识
    output             wire                                     o_tsn_as_cross_metadata_ready       , // 下游模块反压流水线 
`endif 
`ifdef LLDP
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_lldp_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_lldp_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_lldp_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_lldp_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_lldp_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_lldp_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_lldp_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_lldp_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_lldp_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_lldp_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_lldp_cross_metadata_ready         , // 下游模块反压流水线 
`endif 
    /*-------------------- TXMAC 输出数据流 -----------------------*/
`ifdef CPU_MAC
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac0_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac0_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac0_tx_axis_keep                , 
    output          wire                                        o_pmac0_tx_axis_last                , 
    output          wire                                        o_pmac0_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac0_ethertype                   , 
    input           wire                                        i_pmac0_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac0_tx_axis_data                , 
    output          wire    [15:0]                              o_emac0_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac0_tx_axis_keep                , 
    output          wire                                        o_emac0_tx_axis_last                , 
    output          wire                                        o_emac0_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac0_ethertype                   ,
    input           wire                                        i_emac0_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac0_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac0_scheduing_rst                ,
    input           wire                                        i_mac0_scheduing_rst_vld            ,  
`endif
`ifdef MAC1
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac1_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac1_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac1_tx_axis_keep                , 
    output          wire                                        o_pmac1_tx_axis_last                , 
    output          wire                                        o_pmac1_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac1_ethertype                   , 
    input           wire                                        i_pmac1_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac1_tx_axis_data                , 
    output          wire    [15:0]                              o_emac1_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac1_tx_axis_keep                , 
    output          wire                                        o_emac1_tx_axis_last                , 
    output          wire                                        o_emac1_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac1_ethertype                   ,
    input           wire                                        i_emac1_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac1_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac1_scheduing_rst                ,
    input           wire                                        i_mac1_scheduing_rst_vld            ,  
`endif
`ifdef MAC2
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac2_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac2_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac2_tx_axis_keep                , 
    output          wire                                        o_pmac2_tx_axis_last                , 
    output          wire                                        o_pmac2_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac2_ethertype                   , 
    input           wire                                        i_pmac2_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac2_tx_axis_data                , 
    output          wire    [15:0]                              o_emac2_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac2_tx_axis_keep                , 
    output          wire                                        o_emac2_tx_axis_last                , 
    output          wire                                        o_emac2_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac2_ethertype                   ,
    input           wire                                        i_emac2_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac2_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac2_scheduing_rst                ,
    input           wire                                        i_mac2_scheduing_rst_vld            ,  
`endif
`ifdef MAC3
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac3_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac3_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac3_tx_axis_keep                , 
    output          wire                                        o_pmac3_tx_axis_last                , 
    output          wire                                        o_pmac3_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac3_ethertype                   , 
    input           wire                                        i_pmac3_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac3_tx_axis_data                , 
    output          wire    [15:0]                              o_emac3_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac3_tx_axis_keep                , 
    output          wire                                        o_emac3_tx_axis_last                , 
    output          wire                                        o_emac3_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac3_ethertype                   ,
    input           wire                                        i_emac3_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac3_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac3_scheduing_rst                ,
    input           wire                                        i_mac3_scheduing_rst_vld            ,  
`endif
`ifdef MAC4
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac4_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac4_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac4_tx_axis_keep                , 
    output          wire                                        o_pmac4_tx_axis_last                , 
    output          wire                                        o_pmac4_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac4_ethertype                   , 
    input           wire                                        i_pmac4_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac4_tx_axis_data                , 
    output          wire    [15:0]                              o_emac4_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac4_tx_axis_keep                , 
    output          wire                                        o_emac4_tx_axis_last                , 
    output          wire                                        o_emac4_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac4_ethertype                   ,
    input           wire                                        i_emac4_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac4_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac4_scheduing_rst                ,
    input           wire                                        i_mac4_scheduing_rst_vld            ,  
`endif
`ifdef MAC5
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac5_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac5_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac5_tx_axis_keep                , 
    output          wire                                        o_pmac5_tx_axis_last                , 
    output          wire                                        o_pmac5_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac5_ethertype                   , 
    input           wire                                        i_pmac5_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac5_tx_axis_data                , 
    output          wire    [15:0]                              o_emac5_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac5_tx_axis_keep                , 
    output          wire                                        o_emac5_tx_axis_last                , 
    output          wire                                        o_emac5_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac5_ethertype                   ,
    input           wire                                        i_emac5_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac5_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac5_scheduing_rst                ,
    input           wire                                        i_mac5_scheduing_rst_vld            ,  
`endif
`ifdef MAC6
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac6_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac6_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac6_tx_axis_keep                , 
    output          wire                                        o_pmac6_tx_axis_last                , 
    output          wire                                        o_pmac6_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac6_ethertype                   , 
    input           wire                                        i_pmac6_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac6_tx_axis_data                , 
    output          wire    [15:0]                              o_emac6_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac6_tx_axis_keep                , 
    output          wire                                        o_emac6_tx_axis_last                , 
    output          wire                                        o_emac6_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac6_ethertype                   ,
    input           wire                                        i_emac6_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac6_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac6_scheduing_rst                ,
    input           wire                                        i_mac6_scheduing_rst_vld            ,  
`endif
`ifdef MAC7
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac7_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac7_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac7_tx_axis_keep                , 
    output          wire                                        o_pmac7_tx_axis_last                , 
    output          wire                                        o_pmac7_tx_axis_valid               , 
    output          wire    [15:0]                              o_pmac7_ethertype                   , 
    input           wire                                        i_pmac7_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac7_tx_axis_data                , 
    output          wire    [15:0]                              o_emac7_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac7_tx_axis_keep                , 
    output          wire                                        o_emac7_tx_axis_last                , 
    output          wire                                        o_emac7_tx_axis_valid               , 
    output          wire    [15:0]                              o_emac7_ethertype                   ,
    input           wire                                        i_emac7_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac7_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac7_scheduing_rst                ,
    input           wire                                        i_mac7_scheduing_rst_vld            ,  
`endif
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               
);

`ifdef CPU_MAC
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac0_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC1
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac1_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC2
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac2_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC3
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac3_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC4
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac4_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC5
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac5_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC6
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac6_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

`ifdef MAC7
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH   )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH       )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH  )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM    )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH     )          // 聚合总线输出 
    )crossbar_mac7_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             (  ) , // 端口的连接状态
        .i_mac0_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac0_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             (  ) , // 端口的连接状态
        .i_mac1_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac1_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             (  ) , // 端口的连接状态
        .i_mac2_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac2_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             (  ) , // 端口的连接状态
        .i_mac3_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac3_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             (  ) , // 端口的连接状态
        .i_mac4_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac4_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             (  ) , // 端口的连接状态
        .i_mac5_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac5_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             (  ) , // 端口的连接状态
        .i_mac6_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac6_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             (  ) , // 端口的连接状态
        .i_mac7_cross_port_speed            (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         (  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         (  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        (  ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        (  ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_mac7_cross_metadata              (  ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         (  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           (  ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          (  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       (  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       (  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      (  ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      (  ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       (  ) , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_tsn_as_cross_metadata            (  ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      (  ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       (  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      (  ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             (  )  , // 端口的连接状态
        .i_lldp_cross_port_speed            (  )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         (  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         (  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        (  )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        (  )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         (  )  , // 数据流结束标识
        /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 (  ) ,    
        .i_mac0_scheduing_rst               (  ) ,
        .i_mac0_scheduing_rst_vld           (  ) ,
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                (  ) , 
        .o_pmac_tx_axis_user                (  ) , 
        .o_pmac_tx_axis_keep                (  ) , 
        .o_pmac_tx_axis_last                (  ) , 
        .o_pmac_tx_axis_valid               (  ) , 
        .o_pmac_ethertype                   (  ) , 
        .i_pmac_tx_axis_ready               (  ) ,
        //emac通道数据               
        .o_emac_tx_axis_data                (  ) , 
        .o_emac_tx_axis_user                (  ) , 
        .o_emac_tx_axis_keep                (  ) , 
        .o_emac_tx_axis_last                (  ) , 
        .o_emac_tx_axis_valid               (  ) , 
        .o_emac_ethertype                   (  ) ,
        .i_emac_tx_axis_ready               (  ) ,

        .i_clk                              (  ) ,   // 250MHz
        .i_rst                              (  ) 
    );
`endif

tsn_cb_top#(
    .PORT_MNG_DATA_WIDTH     ( PORT_MNG_DATA_WIDTH  )   ,  // Mac_port_mng 数据位宽 
    .CROSS_DATA_WIDTH        ( CROSS_DATA_WIDTH     )   ,  // 聚合总线输出
    .REG_ADDR_BUS_WIDTH      ( REG_ADDR_BUS_WIDTH   )   ,  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH      ( REG_DATA_BUS_WIDTH   )         //      
)tsn_cb_top_inst (
    .i_clk                   (  )           ,
    .i_rst                   (  )           ,
    /*---------------------- 接收 MAC 数据流 ------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac0_cross_port_link      ()        , // 端口的连接状态
    .i_mac0_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac0_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac0_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac0_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac0_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac0_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac0_cross_metadata       ()       , // 总线 metadata 数据
    .i_mac0_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .i_mac0_cross_metadata_last  ()       , // 信息流结束标识
    .o_mac0_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac1_cross_port_link      ()       , // 端口的连接状态
    .i_mac1_cross_port_speed     ()       , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac1_cross_port_axi_data  ()       , // 端口数据流，最高位表示crcerr
    .i_mac1_cross_axi_data_keep  ()       , // 端口数据流掩码，有效字节指示
    .i_mac1_cross_axi_data_valid ()       , // 端口数据有效
    .o_mac1_cross_axi_data_ready ()       , // 交叉总线聚合架构反压流水线信号
    .i_mac1_cross_axi_data_last  ()       , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac1_cross_metadata       ()       , // 总线 metadata 数据
    .i_mac1_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .i_mac1_cross_metadata_last  ()       , // 信息流结束标识
    .o_mac1_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac2_cross_port_link      ()        , // 端口的连接状态
    .i_mac2_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac2_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac2_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac2_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac2_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac2_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac2_cross_metadata       ()       , // 总线 metadata 数据
    .i_mac2_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .i_mac2_cross_metadata_last  ()       , // 信息流结束标识
    .o_mac2_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac3_cross_port_link      ()        , // 端口的连接状态
    .i_mac3_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac3_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac3_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac3_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac3_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac3_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac3_cross_metadata       ()       , // 总线 metadata 数据
    .i_mac3_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .i_mac3_cross_metadata_last  ()       , // 信息流结束标识
    .o_mac3_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac4_cross_port_link      ()        , // 端口的连接状态
    .i_mac4_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac4_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac4_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac4_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac4_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac4_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac4_cross_metadata       ()        , // 总线 metadata 数据
    .i_mac4_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .i_mac4_cross_metadata_last  ()        , // 信息流结束标识
    .o_mac4_cross_metadata_ready ()        , // 下游模块反压流水线 
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac5_cross_port_link      ()        , // 端口的连接状态
    .i_mac5_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac5_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac5_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac5_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac5_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac5_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac5_cross_metadata       ()        , // 总线 metadata 数据
    .i_mac5_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .i_mac5_cross_metadata_last  ()        , // 信息流结束标识
    .o_mac5_cross_metadata_ready ()        , // 下游模块反压流水线 
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac6_cross_port_link      ()        , // 端口的连接状态
    .i_mac6_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac6_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac6_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac6_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac6_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac6_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac6_cross_metadata       ()        , // 总线 metadata 数据
    .i_mac6_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .i_mac6_cross_metadata_last  ()        , // 信息流结束标识
    .o_mac6_cross_metadata_ready ()        , // 下游模块反压流水线 
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac7_cross_port_link      ()        , // 端口的连接状态
    .i_mac7_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .i_mac7_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .i_mac7_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .i_mac7_cross_axi_data_valid ()        , // 端口数据有效
    .o_mac7_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .i_mac7_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .i_mac7_cross_metadata       ()       , // 总线 metadata 数据
    .i_mac7_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .i_mac7_cross_metadata_last  ()       , // 信息流结束标识
    .o_mac7_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
    /*---------------------- 发送 MAC 数据流 ------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac0_cross_port_link      ()       , // 端口的连接状态
    .o_mac0_cross_port_speed     ()       , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac0_cross_port_axi_data  ()       , // 端口数据流，最高位表示crcerr
    .o_mac0_cross_axi_data_keep  ()       , // 端口数据流掩码，有效字节指示
    .o_mac0_cross_axi_data_valid ()       , // 端口数据有效
    .i_mac0_cross_axi_data_ready ()       , // 交叉总线聚合架构反压流水线信号
    .o_mac0_cross_axi_data_last  ()       , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac0_cross_metadata       ()       , // 总线 metadata 数据
    .o_mac0_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .o_mac0_cross_metadata_last  ()       , // 信息流结束标识
    .i_mac0_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac1_cross_port_link      ()        , // 端口的连接状态
    .o_mac1_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac1_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac1_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac1_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac1_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac1_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac1_cross_metadata       ()       , // 总线 metadata 数据
    .o_mac1_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .o_mac1_cross_metadata_last  ()       , // 信息流结束标识
    .i_mac1_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac2_cross_port_link      ()        , // 端口的连接状态
    .o_mac2_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac2_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac2_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac2_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac2_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac2_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac2_cross_metadata       ()       , // 总线 metadata 数据
    .o_mac2_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .o_mac2_cross_metadata_last  ()       , // 信息流结束标识
    .i_mac2_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac3_cross_port_link      ()        , // 端口的连接状态
    .o_mac3_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac3_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac3_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac3_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac3_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac3_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac3_cross_metadata       ()        , // 总线 metadata 数据
    .o_mac3_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .o_mac3_cross_metadata_last  ()        , // 信息流结束标识
    .i_mac3_cross_metadata_ready ()        , // 下游模块反压流水线  
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac4_cross_port_link      ()        , // 端口的连接状态
    .o_mac4_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac4_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac4_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac4_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac4_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac4_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac4_cross_metadata       ()        , // 总线 metadata 数据
    .o_mac4_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .o_mac4_cross_metadata_last  ()        , // 信息流结束标识
    .i_mac4_cross_metadata_ready ()        , // 下游模块反压流水线 
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac5_cross_port_link      ()        , // 端口的连接状态
    .o_mac5_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac5_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac5_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac5_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac5_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac5_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac5_cross_metadata       ()       , // 总线 metadata 数据
    .o_mac5_cross_metadata_valid ()       , // 总线 metadata 数据有效信号
    .o_mac5_cross_metadata_last  ()       , // 信息流结束标识
    .i_mac5_cross_metadata_ready ()       , // 下游模块反压流水线 
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac6_cross_port_link      ()        , // 端口的连接状态
    .o_mac6_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac6_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac6_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac6_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac6_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac6_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac6_cross_metadata       ()        , // 总线 metadata 数据
    .o_mac6_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .o_mac6_cross_metadata_last  ()        , // 信息流结束标识
    .i_mac6_cross_metadata_ready ()        , // 下游模块反压流水线 
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac7_cross_port_link      ()        , // 端口的连接状态
    .o_mac7_cross_port_speed     ()        , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac7_cross_port_axi_data  ()        , // 端口数据流，最高位表示crcerr
    .o_mac7_cross_axi_data_keep  ()        , // 端口数据流掩码，有效字节指示
    .o_mac7_cross_axi_data_valid ()        , // 端口数据有效
    .i_mac7_cross_axi_data_ready ()        , // 交叉总线聚合架构反压流水线信号
    .o_mac7_cross_axi_data_last  ()        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac7_cross_metadata       ()        , // 总线 metadata 数据
    .o_mac7_cross_metadata_valid ()        , // 总线 metadata 数据有效信号
    .o_mac7_cross_metadata_last  ()        , // 信息流结束标识
    .i_mac7_cross_metadata_ready ()        , // 下游模块反压流水线 
`endif
    /*---------------------- 寄存器配置 ------------------*/
        // 寄存器控制信号                     
    .i_refresh_list_pulse        ()        , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr        ()        , // 刷新错误计数器
    .i_switch_err_cnt_stat       ()        , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_switch_reg_bus_we         ()       , // 寄存器写使能
    .i_switch_reg_bus_we_addr    ()       , // 寄存器写地址
    .i_switch_reg_bus_we_din     ()       , // 寄存器写数据
    .i_switch_reg_bus_we_din_v   ()       , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_switch_reg_bus_rd         ()       , // 寄存器读使能
    .i_switch_reg_bus_rd_addr    ()       , // 寄存器读地址
    .o_switch_reg_bus_we_dout    ()       , // 读出寄存器数据
    .o_switch_reg_bus_we_dout_v  ()        // 读数据有效使能
);

endmodule