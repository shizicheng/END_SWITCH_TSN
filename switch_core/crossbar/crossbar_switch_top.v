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
    
    input               wire   [METADATA_WIDTH-1:0]             i_tsn_as_cross_metadata             , // 总线 metadata 数据
    input               wire                                    i_tsn_as_cross_metadata_valid       , // 总线 metadata 数据有效信号
    input               wire                                    i_tsn_as_cross_metadata_last        , // 信息流结束标识
    output              wire                                    o_tsn_as_cross_metadata_ready       , // 下游模块反压流水线 
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
    
    input               wire  [METADATA_WIDTH-1:0]              i_lldp_cross_metadata               , // 总线 metadata 数据
    input               wire                                    i_lldp_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input               wire                                    i_lldp_cross_metadata_last          , // 信息流结束标识
    output              wire                                    o_lldp_cross_metadata_ready         , // 下游模块反压流水线 
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

/*--------------------- wire ----------------*/
`ifdef CPU_MAC
    wire                                    w_mac0_cross_port_link              ;
    wire   [1:0]                            w_mac0_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac0_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac0_cross_axi_data_keep          ;
    wire                                    w_mac0_cross_axi_data_valid         ;
    wire                                    w_mac0_cross_axi_data_ready         ;
    wire                                    w_mac0_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac0_cross_metadata               ;
    wire                                    w_mac0_cross_metadata_valid         ;
    wire                                    w_mac0_cross_metadata_last          ;
    wire                                    w_mac0_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac0_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac0_scheduing_rst                ;
    wire                                    w_mac0_scheduing_rst_vld            ;
`endif

`ifdef MAC1
    wire                                    w_mac1_cross_port_link              ;
    wire   [1:0]                            w_mac1_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac1_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac1_cross_axi_data_keep          ;
    wire                                    w_mac1_cross_axi_data_valid         ;
    wire                                    w_mac1_cross_axi_data_ready         ;
    wire                                    w_mac1_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac1_cross_metadata               ;
    wire                                    w_mac1_cross_metadata_valid         ;
    wire                                    w_mac1_cross_metadata_last          ;
    wire                                    w_mac1_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac1_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac1_scheduing_rst                ;
    wire                                    w_mac1_scheduing_rst_vld            ;
`endif

`ifdef MAC2
    wire                                    w_mac2_cross_port_link              ;
    wire   [1:0]                            w_mac2_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac2_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac2_cross_axi_data_keep          ;
    wire                                    w_mac2_cross_axi_data_valid         ;
    wire                                    w_mac2_cross_axi_data_ready         ;
    wire                                    w_mac2_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac2_cross_metadata               ;
    wire                                    w_mac2_cross_metadata_valid         ;
    wire                                    w_mac2_cross_metadata_last          ;
    wire                                    w_mac2_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac2_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac2_scheduing_rst                ;
    wire                                    w_mac2_scheduing_rst_vld            ;
`endif

`ifdef MAC3
    wire                                    w_mac3_cross_port_link              ;
    wire   [1:0]                            w_mac3_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac3_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac3_cross_axi_data_keep          ;
    wire                                    w_mac3_cross_axi_data_valid         ;
    wire                                    w_mac3_cross_axi_data_ready         ;
    wire                                    w_mac3_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac3_cross_metadata               ;
    wire                                    w_mac3_cross_metadata_valid         ;
    wire                                    w_mac3_cross_metadata_last          ;
    wire                                    w_mac3_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac3_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac3_scheduing_rst                ;
    wire                                    w_mac3_scheduing_rst_vld            ;
`endif

`ifdef MAC4
    wire                                    w_mac4_cross_port_link              ;
    wire   [1:0]                            w_mac4_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac4_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac4_cross_axi_data_keep          ;
    wire                                    w_mac4_cross_axi_data_valid         ;
    wire                                    w_mac4_cross_axi_data_ready         ;
    wire                                    w_mac4_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac4_cross_metadata               ;
    wire                                    w_mac4_cross_metadata_valid         ;
    wire                                    w_mac4_cross_metadata_last          ;
    wire                                    w_mac4_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac4_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac4_scheduing_rst                ;
    wire                                    w_mac4_scheduing_rst_vld            ;
`endif

`ifdef MAC5
    wire                                    w_mac5_cross_port_link              ;
    wire   [1:0]                            w_mac5_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac5_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac5_cross_axi_data_keep          ;
    wire                                    w_mac5_cross_axi_data_valid         ;
    wire                                    w_mac5_cross_axi_data_ready         ;
    wire                                    w_mac5_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac5_cross_metadata               ;
    wire                                    w_mac5_cross_metadata_valid         ;
    wire                                    w_mac5_cross_metadata_last          ;
    wire                                    w_mac5_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac5_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac5_scheduing_rst                ;
    wire                                    w_mac5_scheduing_rst_vld            ;
`endif

`ifdef MAC6
    wire                                    w_mac6_cross_port_link              ;
    wire   [1:0]                            w_mac6_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac6_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac6_cross_axi_data_keep          ;
    wire                                    w_mac6_cross_axi_data_valid         ;
    wire                                    w_mac6_cross_axi_data_ready         ;
    wire                                    w_mac6_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac6_cross_metadata               ;
    wire                                    w_mac6_cross_metadata_valid         ;
    wire                                    w_mac6_cross_metadata_last          ;
    wire                                    w_mac6_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac6_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac6_scheduing_rst                ;
    wire                                    w_mac6_scheduing_rst_vld            ;
`endif

`ifdef MAC7
    wire                                    w_mac7_cross_port_link              ;
    wire   [1:0]                            w_mac7_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]             w_mac7_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac7_cross_axi_data_keep          ;
    wire                                    w_mac7_cross_axi_data_valid         ;
    wire                                    w_mac7_cross_axi_data_ready         ;
    wire                                    w_mac7_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac7_cross_metadata               ;
    wire                                    w_mac7_cross_metadata_valid         ;
    wire                                    w_mac7_cross_metadata_last          ;
    wire                                    w_mac7_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM:0]            w_mac7_fifoc_empty                  ;
    wire   [PORT_FIFO_PRI_NUM:0]            w_mac7_scheduing_rst                ;
    wire                                    w_mac7_scheduing_rst_vld            ;
`endif

`ifdef TSN_AS
    wire                                    w_tsn_as_cross_port_link            ;
    wire   [1:0]                            w_tsn_as_cross_port_speed           ;
    wire   [CROSS_DATA_WIDTH:0]             w_tsn_as_cross_port_axi_data        ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_tsn_as_cross_axi_data_keep        ;
    wire                                    w_tsn_as_cross_axi_data_valid       ;
    wire                                    w_tsn_as_cross_axi_data_ready       ;
    wire                                    w_tsn_as_cross_axi_data_last        ;

    wire   [METADATA_WIDTH-1:0]             w_tsn_as_cross_metadata             ;
    wire                                    w_tsn_as_cross_metadata_valid       ;
    wire                                    w_tsn_as_cross_metadata_last        ;
    wire                                    w_tsn_as_cross_metadata_ready       ;
`endif

`ifdef LLDP
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    wire                                    w_lldp_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_lldp_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_lldp_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_lldp_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_lldp_cross_axi_data_valid         ; // 端口数据有效
    wire                                    w_lldp_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_lldp_cross_axi_data_last          ; // 数据流结束标识

    wire  [METADATA_WIDTH-1:0]              w_lldp_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_lldp_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_lldp_cross_metadata_last          ; // 信息流结束标识
    wire                                    w_lldp_cross_metadata_ready         ; // 下游模块反压流水线 
`endif 
/*--------------------- reg ----------------*/



/*--------------------- assign ----------------*/
`ifdef CPU_MAC
    assign     w_mac0_cross_port_link          =   i_mac0_cross_port_link      ;  
    assign     w_mac0_cross_port_speed         =   i_mac0_cross_port_speed     ;  
    assign     w_mac0_cross_port_axi_data      =   i_mac0_cross_port_axi_data  ;  
    assign     w_mac0_cross_axi_data_keep      =   i_mac0_cross_axi_data_keep  ;  
    assign     w_mac0_cross_axi_data_valid     =   i_mac0_cross_axi_data_valid ;  
    assign     o_mac0_cross_axi_data_ready     =   w_mac0_cross_axi_data_ready ;  
    assign     w_mac0_cross_axi_data_last      =   i_mac0_cross_axi_data_last  ; 

    assign     w_mac0_cross_metadata           =   i_mac0_cross_metadata       ;
    assign     w_mac0_cross_metadata_valid     =   i_mac0_cross_metadata_valid ;
    assign     w_mac0_cross_metadata_last      =   i_mac0_cross_metadata_last  ;
    assign     o_mac0_cross_metadata_ready     =   w_mac0_cross_metadata_ready ;
`endif

`ifdef MAC1
    assign     w_mac1_cross_port_link          =   i_mac1_cross_port_link      ;  
    assign     w_mac1_cross_port_speed         =   i_mac1_cross_port_speed     ;  
    assign     w_mac1_cross_port_axi_data      =   i_mac1_cross_port_axi_data  ;  
    assign     w_mac1_cross_axi_data_keep      =   i_mac1_cross_axi_data_keep  ;  
    assign     w_mac1_cross_axi_data_valid     =   i_mac1_cross_axi_data_valid ;  
    assign     o_mac1_cross_axi_data_ready     =   w_mac1_cross_axi_data_ready ;  
    assign     w_mac1_cross_axi_data_last      =   i_mac1_cross_axi_data_last  ; 

    assign     w_mac1_cross_metadata           =   i_mac1_cross_metadata       ;
    assign     w_mac1_cross_metadata_valid     =   i_mac1_cross_metadata_valid ;
    assign     w_mac1_cross_metadata_last      =   i_mac1_cross_metadata_last  ;
    assign     o_mac1_cross_metadata_ready     =   w_mac1_cross_metadata_ready ;
`endif

`ifdef MAC2
    assign     w_mac2_cross_port_link          =   i_mac2_cross_port_link      ;  
    assign     w_mac2_cross_port_speed         =   i_mac2_cross_port_speed     ;  
    assign     w_mac2_cross_port_axi_data      =   i_mac2_cross_port_axi_data  ;  
    assign     w_mac2_cross_axi_data_keep      =   i_mac2_cross_axi_data_keep  ;  
    assign     w_mac2_cross_axi_data_valid     =   i_mac2_cross_axi_data_valid ;  
    assign     o_mac2_cross_axi_data_ready     =   w_mac2_cross_axi_data_ready ;  
    assign     w_mac2_cross_axi_data_last      =   i_mac2_cross_axi_data_last  ; 

    assign     w_mac2_cross_metadata           =   i_mac2_cross_metadata       ;
    assign     w_mac2_cross_metadata_valid     =   i_mac2_cross_metadata_valid ;
    assign     w_mac2_cross_metadata_last      =   i_mac2_cross_metadata_last  ;
    assign     o_mac2_cross_metadata_ready     =   w_mac2_cross_metadata_ready ;
`endif

`ifdef MAC3
    assign     w_mac3_cross_port_link          =   i_mac3_cross_port_link      ;  
    assign     w_mac3_cross_port_speed         =   i_mac3_cross_port_speed     ;  
    assign     w_mac3_cross_port_axi_data      =   i_mac3_cross_port_axi_data  ;  
    assign     w_mac3_cross_axi_data_keep      =   i_mac3_cross_axi_data_keep  ;  
    assign     w_mac3_cross_axi_data_valid     =   i_mac3_cross_axi_data_valid ;  
    assign     o_mac3_cross_axi_data_ready     =   w_mac3_cross_axi_data_ready ;  
    assign     w_mac3_cross_axi_data_last      =   i_mac3_cross_axi_data_last  ; 

    assign     w_mac3_cross_metadata           =   i_mac3_cross_metadata       ;
    assign     w_mac3_cross_metadata_valid     =   i_mac3_cross_metadata_valid ;
    assign     w_mac3_cross_metadata_last      =   i_mac3_cross_metadata_last  ;
    assign     o_mac3_cross_metadata_ready     =   w_mac3_cross_metadata_ready ;
`endif

`ifdef MAC4
    assign     w_mac4_cross_port_link          =   i_mac4_cross_port_link      ;  
    assign     w_mac4_cross_port_speed         =   i_mac4_cross_port_speed     ;  
    assign     w_mac4_cross_port_axi_data      =   i_mac4_cross_port_axi_data  ;  
    assign     w_mac4_cross_axi_data_keep      =   i_mac4_cross_axi_data_keep  ;  
    assign     w_mac4_cross_axi_data_valid     =   i_mac4_cross_axi_data_valid ;  
    assign     o_mac4_cross_axi_data_ready     =   w_mac4_cross_axi_data_ready ;  
    assign     w_mac4_cross_axi_data_last      =   i_mac4_cross_axi_data_last  ; 

    assign     w_mac4_cross_metadata           =   i_mac4_cross_metadata       ;
    assign     w_mac4_cross_metadata_valid     =   i_mac4_cross_metadata_valid ;
    assign     w_mac4_cross_metadata_last      =   i_mac4_cross_metadata_last  ;
    assign     o_mac4_cross_metadata_ready     =   w_mac4_cross_metadata_ready ;
`endif

`ifdef MAC5
    assign     w_mac5_cross_port_link          =   i_mac5_cross_port_link      ;  
    assign     w_mac5_cross_port_speed         =   i_mac5_cross_port_speed     ;  
    assign     w_mac5_cross_port_axi_data      =   i_mac5_cross_port_axi_data  ;  
    assign     w_mac5_cross_axi_data_keep      =   i_mac5_cross_axi_data_keep  ;  
    assign     w_mac5_cross_axi_data_valid     =   i_mac5_cross_axi_data_valid ;  
    assign     o_mac5_cross_axi_data_ready     =   w_mac5_cross_axi_data_ready ;  
    assign     w_mac5_cross_axi_data_last      =   i_mac5_cross_axi_data_last  ; 

    assign     w_mac5_cross_metadata           =   i_mac5_cross_metadata       ;
    assign     w_mac5_cross_metadata_valid     =   i_mac5_cross_metadata_valid ;
    assign     w_mac5_cross_metadata_last      =   i_mac5_cross_metadata_last  ;
    assign     o_mac5_cross_metadata_ready     =   w_mac5_cross_metadata_ready ;
`endif

`ifdef MAC6
    assign     w_mac6_cross_port_link          =   i_mac6_cross_port_link      ;  
    assign     w_mac6_cross_port_speed         =   i_mac6_cross_port_speed     ;  
    assign     w_mac6_cross_port_axi_data      =   i_mac6_cross_port_axi_data  ;  
    assign     w_mac6_cross_axi_data_keep      =   i_mac6_cross_axi_data_keep  ;  
    assign     w_mac6_cross_axi_data_valid     =   i_mac6_cross_axi_data_valid ;  
    assign     o_mac6_cross_axi_data_ready     =   w_mac6_cross_axi_data_ready ;  
    assign     w_mac6_cross_axi_data_last      =   i_mac6_cross_axi_data_last  ; 

    assign     w_mac6_cross_metadata           =   i_mac6_cross_metadata       ;
    assign     w_mac6_cross_metadata_valid     =   i_mac6_cross_metadata_valid ;
    assign     w_mac6_cross_metadata_last      =   i_mac6_cross_metadata_last  ;
    assign     o_mac6_cross_metadata_ready     =   w_mac6_cross_metadata_ready ;
`endif

`ifdef MAC7
    assign     w_mac7_cross_port_link          =   i_mac7_cross_port_link      ;  
    assign     w_mac7_cross_port_speed         =   i_mac7_cross_port_speed     ;  
    assign     w_mac7_cross_port_axi_data      =   i_mac7_cross_port_axi_data  ;  
    assign     w_mac7_cross_axi_data_keep      =   i_mac7_cross_axi_data_keep  ;  
    assign     w_mac7_cross_axi_data_valid     =   i_mac7_cross_axi_data_valid ;  
    assign     o_mac7_cross_axi_data_ready     =   w_mac7_cross_axi_data_ready ;  
    assign     w_mac7_cross_axi_data_last      =   i_mac7_cross_axi_data_last  ; 

    assign     w_mac7_cross_metadata           =   i_mac7_cross_metadata       ;
    assign     w_mac7_cross_metadata_valid     =   i_mac7_cross_metadata_valid ;
    assign     w_mac7_cross_metadata_last      =   i_mac7_cross_metadata_last  ;
    assign     o_mac7_cross_metadata_ready     =   w_mac7_cross_metadata_ready ;
`endif
`ifdef TSN_AS
    assign     w_tsn_as_cross_port_link         =   i_tsn_as_cross_port_link      ;
    assign     w_tsn_as_cross_port_speed        =   i_tsn_as_cross_port_speed     ;
    assign     w_tsn_as_cross_port_axi_data     =   i_tsn_as_cross_port_axi_data  ;
    assign     w_tsn_as_cross_axi_data_keep     =   i_tsn_as_cross_axi_data_keep  ;
    assign     w_tsn_as_cross_axi_data_valid    =   i_tsn_as_cross_axi_data_valid ;
    assign     o_tsn_as_cross_axi_data_ready    =   w_tsn_as_cross_axi_data_ready ;
    assign     w_tsn_as_cross_axi_data_last     =   i_tsn_as_cross_axi_data_last  ;
    assign     w_tsn_as_cross_metadata          =   i_tsn_as_cross_metadata       ;
    assign     w_tsn_as_cross_metadata_valid    =   i_tsn_as_cross_metadata_valid ;
    assign     w_tsn_as_cross_metadata_last     =   i_tsn_as_cross_metadata_last  ;
    assign     o_tsn_as_cross_metadata_ready    =   w_tsn_as_cross_metadata_ready ;
`endif
`ifdef LLDP
    assign     w_lldp_cross_port_link          =    i_lldp_cross_port_link        ;
    assign     w_lldp_cross_port_speed         =    i_lldp_cross_port_speed       ;
    assign     w_lldp_cross_port_axi_data      =    i_lldp_cross_port_axi_data    ;
    assign     w_lldp_cross_axi_data_keep      =    i_lldp_cross_axi_data_keep    ;
    assign     w_lldp_cross_axi_data_valid     =    i_lldp_cross_axi_data_valid   ;
    assign     o_lldp_cross_axi_data_ready     =    w_lldp_cross_axi_data_ready   ;
    assign     w_lldp_cross_axi_data_last      =    i_lldp_cross_axi_data_last    ;  
    assign     w_lldp_cross_metadata           =    i_lldp_cross_metadata         ;  
    assign     w_lldp_cross_metadata_valid     =    i_lldp_cross_metadata_valid   ;  
    assign     w_lldp_cross_metadata_last      =    i_lldp_cross_metadata_last    ;  
    assign     o_lldp_cross_metadata_ready     =    w_lldp_cross_metadata_ready   ;
`endif
/*--------------------- inst ----------------*/
`ifdef CPU_MAC
    cross_bar_txport_mnt #(
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac0_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_link             ( w_mac0_cross_port_link        ) , // 端口的连接状态
        .i_mac0_cross_port_speed            ( w_mac0_cross_port_speed       ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready   ) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready   ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_link             ( w_mac1_cross_port_link      ) , // 端口的连接状态
        .i_mac1_cross_port_speed            ( w_mac1_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_link             ( w_mac2_cross_port_link      ) , // 端口的连接状态
        .i_mac2_cross_port_speed            ( w_mac2_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_link             ( w_mac3_cross_port_link      ) , // 端口的连接状态
        .i_mac3_cross_port_speed            ( w_mac3_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_link             ( w_mac4_cross_port_link      ) , // 端口的连接状态
        .i_mac4_cross_port_speed            ( w_mac4_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_link             ( w_mac5_cross_port_link      ) , // 端口的连接状态
        .i_mac5_cross_port_speed            ( w_mac5_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_link             ( w_mac6_cross_port_link      ) , // 端口的连接状态
        .i_mac6_cross_port_speed            ( w_mac6_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_link             ( w_mac7_cross_port_link      ) , // 端口的连接状态
        .i_mac7_cross_port_speed            ( w_mac7_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_link           ( w_tsn_as_cross_port_link      ) , // 端口的连接状态
        .i_tsn_as_cross_port_speed          ( w_tsn_as_cross_port_speed     ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready ) , // 下游模块反压流水线 
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_link             ( w_lldp_cross_port_link      )  , // 端口的连接状态
        .i_lldp_cross_port_speed            ( w_lldp_cross_port_speed     )  , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready ) ,  // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac0_fifoc_empty          ) ,    
        .i_mac0_scheduing_rst               ( w_mac0_scheduing_rst        ) , 
        .i_mac0_scheduing_rst_vld           ( w_mac0_scheduing_rst_vld    ) , 
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

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac1_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac1_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac1_scheduing_rst_vld ) ,
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac2_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac2_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac2_scheduing_rst_vld ) ,
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac3_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac3_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac3_scheduing_rst_vld ) ,
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac4_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac4_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac4_scheduing_rst_vld ) ,
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac5_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac5_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac5_scheduing_rst_vld ) ,
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac6_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac6_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac6_scheduing_rst_vld ) ,
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
        
        .i_lldp_cross_metadata              (  ) , // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        (  ) , // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         (  ) , // 信息流结束标识
        .o_lldp_cross_metadata_ready        (  ) , // 下游模块反压流水线 
    `endif 
        // 调度流水线调度信息交互
        .o_mac0_fifoc_empty                 ( w_mac7_fifoc_empty       ) ,    
        .i_mac0_scheduing_rst               ( w_mac7_scheduing_rst     ) ,
        .i_mac0_scheduing_rst_vld           ( w_mac7_scheduing_rst_vld ) ,
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


endmodule