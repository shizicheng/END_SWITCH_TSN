`include "synth_cmd_define.vh"

module cross_bar_txport_mnt#(

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
    /*-------------------- 特定端口转发输入数据流 -----------------------*/
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
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM:0]                o_mac0_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM:0]                i_mac0_scheduing_rst                ,
    input           wire                                        i_mac0_scheduing_rst_vld            ,
    /*-------------------- TXMAC 输出数据流 -----------------------*/
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac_tx_axis_data                 , 
    output          wire    [15:0]                              o_pmac_tx_axis_user                 , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac_tx_axis_keep                 , 
    output          wire                                        o_pmac_tx_axis_last                 , 
    output          wire                                        o_pmac_tx_axis_valid                , 
    output          wire    [15:0]                              o_pmac_ethertype                    , 
    input           wire                                        i_pmac_tx_axis_ready                ,
    //emac通道数据               
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac_tx_axis_data                 , 
    output          wire    [15:0]                              o_emac_tx_axis_user                 , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac_tx_axis_keep                 , 
    output          wire                                        o_emac_tx_axis_last                 , 
    output          wire                                        o_emac_tx_axis_valid                , 
    output          wire    [15:0]                              o_emac_ethertype                    ,
    input           wire                                        i_emac_tx_axis_ready                ,

    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               
);

endmodule