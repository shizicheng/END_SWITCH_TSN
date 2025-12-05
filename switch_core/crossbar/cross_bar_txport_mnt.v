`include "synth_cmd_define.vh"

module cross_bar_txport_mnt #(
    parameter                      PORT_ATTRIBUTE          =      0        ,
    parameter                      REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                      REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                      METADATA_WIDTH          =      94       ,  // 信息流（METADATA）的位宽
    parameter                      PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                      PORT_FIFO_PRI_NUM       =      8        , 
    parameter                      CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    // RXMAC 输入数据流
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac0_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac0_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac0_cross_axi_data_user          ,        
    input               wire                                    i_mac0_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac0_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac0_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac0_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac0_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac0_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac0_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx0_req                           ,
    output             wire                                     o_tx0_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx0_ack_rst                       ,

    //rxmac0通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac0_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac0_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac0_qbu_axis_user              , 
    input          wire                                         i_rxmac0_qbu_axis_valid             , 
    output         wire                                         o_rxmac0_qbu_axis_ready             ,
    input          wire                                         i_rxmac0_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac0_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac0_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac0_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac0_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac1_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac1_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac1_cross_axi_data_user          ,  
    input               wire                                    i_mac1_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac1_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac1_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac1_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac1_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac1_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac1_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx1_req                           ,
    output             wire                                     o_tx1_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx1_ack_rst                       ,

    //rxmac1通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac1_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac1_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac1_qbu_axis_user              , 
    input          wire                                         i_rxmac1_qbu_axis_valid             , 
    output         wire                                         o_rxmac1_qbu_axis_ready             ,
    input          wire                                         i_rxmac1_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac1_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac1_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac1_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac1_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac2_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac2_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac2_cross_axi_data_user          ,  
    input               wire                                    i_mac2_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac2_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac2_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac2_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac2_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac2_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac2_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx2_req                           ,
    output             wire                                     o_tx2_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx2_ack_rst                       ,

    //rxmac2通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac2_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac2_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac2_qbu_axis_user              , 
    input          wire                                         i_rxmac2_qbu_axis_valid             , 
    output         wire                                         o_rxmac2_qbu_axis_ready             ,
    input          wire                                         i_rxmac2_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac2_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac2_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac2_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac2_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac3_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac3_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac3_cross_axi_data_user          ,  
    input               wire                                    i_mac3_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac3_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac3_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac3_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac3_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac3_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac3_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx3_req                           ,
    output             wire                                     o_tx3_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx3_ack_rst                       ,

    //rxmac3通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac3_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac3_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac3_qbu_axis_user              , 
    input          wire                                         i_rxmac3_qbu_axis_valid             , 
    output         wire                                         o_rxmac3_qbu_axis_ready             ,
    input          wire                                         i_rxmac3_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac3_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac3_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac3_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac3_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac4_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac4_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac4_cross_axi_data_user          ,  
    input               wire                                    i_mac4_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac4_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac4_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac4_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac4_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac4_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac4_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx4_req                           ,
    output             wire                                     o_tx4_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx4_ack_rst                       ,

    //rxmac4通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac4_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac4_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac4_qbu_axis_user              , 
    input          wire                                         i_rxmac4_qbu_axis_valid             , 
    output         wire                                         o_rxmac4_qbu_axis_ready             ,
    input          wire                                         i_rxmac4_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac4_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac4_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac4_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac4_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac5_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac5_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac5_cross_axi_data_user          ,  
    input               wire                                    i_mac5_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac5_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac5_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac5_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac5_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac5_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac5_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx5_req                           ,
    output             wire                                     o_tx5_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx5_ack_rst                       ,

    //rxmac5通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac5_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac5_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac5_qbu_axis_user              , 
    input          wire                                         i_rxmac5_qbu_axis_valid             , 
    output         wire                                         o_rxmac5_qbu_axis_ready             ,
    input          wire                                         i_rxmac5_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac5_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac5_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac5_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac5_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac6_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac6_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac6_cross_axi_data_user          ,  
    input               wire                                    i_mac6_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac6_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac6_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac6_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac6_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac6_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac6_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx6_req                           ,
    output             wire                                     o_tx6_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx6_ack_rst                       ,

    //rxmac6通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac6_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac6_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac6_qbu_axis_user              , 
    input          wire                                         i_rxmac6_qbu_axis_valid             , 
    output         wire                                         o_rxmac6_qbu_axis_ready             ,
    input          wire                                         i_rxmac6_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac6_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac6_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac6_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac6_qbu_metadata_ready         , // 下游模块反压流水线

`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac7_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac7_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac7_cross_axi_data_user          ,  
    input               wire                                    i_mac7_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac7_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac7_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac7_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac7_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac7_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac7_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx7_req                           ,
    output             wire                                     o_tx7_ack                           ,
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_tx7_ack_rst                       ,

    //rxmac7通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac7_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac7_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac7_qbu_axis_user              , 
    input          wire                                         i_rxmac7_qbu_axis_valid             , 
    output         wire                                         o_rxmac7_qbu_axis_ready             ,
    input          wire                                         i_rxmac7_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac7_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac7_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac7_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac7_qbu_metadata_ready         , // 下游模块反压流水线

`endif
    /*-------------------- 特定端口转发输入数据流 -----------------------*/
`ifdef TSN_AS
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_tsn_as_cross_port_axi_data        , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_tsn_as_cross_axi_data_keep        , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_tsn_as_cross_axi_data_user        ,  
    input               wire                                    i_tsn_as_cross_axi_data_valid       , // 端口数据有效
    output              wire                                    o_tsn_as_cross_axi_data_ready       , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_tsn_as_cross_axi_data_last        , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_tsn_as_cross_metadata             , // 总线 metadata 数据
    input              wire                                     i_tsn_as_cross_metadata_valid       , // 总线 metadata 数据有效信号
    input              wire                                     i_tsn_as_cross_metadata_last        , // 信息流结束标识
    output             wire                                     o_tsn_as_cross_metadata_ready       , // 下游模块反压流水线 

    input              wire                                     i_tsn_as_tx_req                     ,
    output             wire                                     o_tsn_as_tx_ack                     ,
`endif 
`ifdef LLDP
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_lldp_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_lldp_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_lldp_cross_axi_data_user        ,  
    input               wire                                    i_lldp_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_lldp_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_lldp_cross_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_lldp_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_lldp_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_lldp_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_lldp_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_lldp_tx_req                       ,
    output             wire                                     o_lldp_tx_ack                       ,
`endif 
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_fifoc_empty                       ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_scheduing_rst                     ,
    input           wire                                        i_scheduing_rst_vld                 ,
    /*-------------------- TXMAC 输出数据流 -----------------------*/
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac_tx_axis_data                 , 
    output          wire    [15:0]                              o_pmac_tx_axis_user                 , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac_tx_axis_keep                 , 
    output          wire                                        o_pmac_tx_axis_last                 , 
    output          wire                                        o_pmac_tx_axis_valid                , 
    input           wire                                        i_pmac_tx_axis_ready                ,
    //emac通道数据               
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac_tx_axis_data                 , 
    output          wire    [15:0]                              o_emac_tx_axis_user                 , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac_tx_axis_keep                 , 
    output          wire                                        o_emac_tx_axis_last                 , 
    output          wire                                        o_emac_tx_axis_valid                , 
    input           wire                                        i_emac_tx_axis_ready                ,

    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               
);

// -----------
    wire    [PORT_FIFO_PRI_NUM-1:0]        w_fifio_data_busy                                          ;            
    wire    [7:0]                          w_fifo_arb_valid                                      ; // 8 个优先级 FIFO 仲裁的有效位
    wire    [PORT_FIFO_PRI_NUM+1:0]        w_fifo_arb_result [PORT_FIFO_PRI_NUM-1:0]             ; // 一共8个优先级FIFO ，共返回10位仲裁结果
// ----------
    
// ----------
    reg   [CROSS_DATA_WIDTH:0]             ri_mac_cross_port_axi_data  [PORT_FIFO_PRI_NUM+1:0]   ;
    reg   [(CROSS_DATA_WIDTH/8)-1:0]       ri_mac_cross_axi_data_keep  [PORT_FIFO_PRI_NUM+1:0]   ;
    reg   [15:0]                           ri_mac_cross_axi_data_user  [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ri_mac_cross_axi_data_valid [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ro_mac_cross_axi_data_ready [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ri_mac_cross_axi_data_last  [PORT_FIFO_PRI_NUM+1:0]   ;

    reg   [METADATA_WIDTH-1:0]             ri_mac_cross_metadata       [PORT_FIFO_PRI_NUM+1:0]   ;    
    reg                                    ri_mac_cross_metadata_valid [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ri_mac_cross_metadata_last  [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ro_mac_cross_metadata_ready [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ri_tx0_req                  [PORT_FIFO_PRI_NUM+1:0]   ;
    reg                                    ro_tx0_ack                  [PORT_FIFO_PRI_NUM+1:0]   ;
    
    reg                                    r_frame_flag                [PORT_FIFO_PRI_NUM+1:0]   ;
    reg     [7:0]                          r_metadata_tx_port          [PORT_FIFO_PRI_NUM+1:0]   ;
    reg     [2:0]                          r_tx_vlan_pri               [PORT_FIFO_PRI_NUM+1:0]   ; 
    reg     [7:0]                          r_tx_port_cache_req         [PORT_FIFO_PRI_NUM+1:0]   ;   
    reg                                    r_tx_active                 [PORT_FIFO_PRI_NUM+1:0]   ;
    
    reg    [CROSS_DATA_WIDTH-1:0]          r_data0                     [PORT_FIFO_PRI_NUM-1:0]   ;
    reg    [CROSS_DATA_WIDTH/8-1:0]        r_data0_keep                [PORT_FIFO_PRI_NUM-1:0]   ;
    reg                                    r_data0_vld                 [PORT_FIFO_PRI_NUM-1:0]   ;
    reg                                    r_data0_last                [PORT_FIFO_PRI_NUM-1:0]   ;
    reg    [METADATA_WIDTH-1:0]            r_meta_data0_pri            [PORT_FIFO_PRI_NUM-1:0]   ;
    reg                                    r_meta_data0_pri_vld        [PORT_FIFO_PRI_NUM-1:0]   ;
    reg                                    r_data0_qbu_flag            [PORT_FIFO_PRI_NUM+1:0]   ;

    reg    [7:0]                           r_port_ack                                            ; // 8 个优先级 FIFO 仲裁的有效位
    reg    [PORT_FIFO_PRI_NUM+1:0]         r_port_ack_rst [PORT_FIFO_PRI_NUM-1:0]                ; // 8 个端口的仲裁结果向量

    reg                                    r_tsn_as_tx_ack                                       ; // 时钟同步响应信号
    reg                                    r_lldp_tx_ack                                         ; // LLDP 响应信号

    reg    [CROSS_DATA_WIDTH-1:0]          r_pri_data                 [PORT_FIFO_PRI_NUM-1:0]    ;
    reg    [CROSS_DATA_WIDTH/8-1:0]        r_pri_data_keep            [PORT_FIFO_PRI_NUM-1:0]    ;
    reg    [15:0]                          r_pri_data_user            [PORT_FIFO_PRI_NUM-1:0]    ;
    reg                                    r_pri_data_vld             [PORT_FIFO_PRI_NUM-1:0]    ;
    reg                                    r_pri_data_last            [PORT_FIFO_PRI_NUM-1:0]    ;
    reg    [METADATA_WIDTH-1:0]            r_pri_meta_data            [PORT_FIFO_PRI_NUM-1:0]    ;
    reg                                    r_pri_meta_data_vld        [PORT_FIFO_PRI_NUM-1:0]    ;
    wire   [PORT_FIFO_PRI_NUM-1:0]         w_pri_ready                                           ;

    assign                              o_mac0_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac1_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac2_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac3_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac4_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac5_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac6_cross_metadata_ready  = 1'b1                 ;
    assign                              o_mac7_cross_metadata_ready  = 1'b1                 ;
    assign                              o_tsn_as_cross_metadata_ready= 1'b1                 ;
    assign                              o_lldp_cross_metadata_ready  = 1'b1                 ;

    assign                              o_mac0_cross_axi_data_ready = ro_mac_cross_axi_data_ready[0];
    assign                              o_mac1_cross_axi_data_ready = ro_mac_cross_axi_data_ready[1];
    assign                              o_mac2_cross_axi_data_ready = ro_mac_cross_axi_data_ready[2];
    assign                              o_mac3_cross_axi_data_ready = ro_mac_cross_axi_data_ready[3];
    assign                              o_mac4_cross_axi_data_ready = ro_mac_cross_axi_data_ready[4];
    assign                              o_mac5_cross_axi_data_ready = ro_mac_cross_axi_data_ready[5];
    assign                              o_mac6_cross_axi_data_ready = ro_mac_cross_axi_data_ready[6];
    assign                              o_mac7_cross_axi_data_ready = ro_mac_cross_axi_data_ready[7];
    assign                              o_tsn_as_cross_axi_data_ready=ro_mac_cross_axi_data_ready[8];
    assign                              o_lldp_cross_axi_data_ready = ro_mac_cross_axi_data_ready[9];

// ----------  
    assign      o_tx0_ack           =      r_port_ack[0]     ;
    assign      o_tx0_ack_rst       =      r_port_ack_rst[0] ;   

    assign      o_tx1_ack           =      r_port_ack[1]     ;
    assign      o_tx1_ack_rst       =      r_port_ack_rst[1] ;
    
    assign      o_tx2_ack           =      r_port_ack[2]     ;
    assign      o_tx2_ack_rst       =      r_port_ack_rst[2] ;

    assign      o_tx3_ack           =      r_port_ack[3]     ;
    assign      o_tx3_ack_rst       =      r_port_ack_rst[3] ;

    assign      o_tx4_ack           =      r_port_ack[4]     ;
    assign      o_tx4_ack_rst       =      r_port_ack_rst[4] ;

    assign      o_tx5_ack           =      r_port_ack[5]     ;
    assign      o_tx5_ack_rst       =      r_port_ack_rst[5] ;

    assign      o_tx6_ack           =      r_port_ack[6]     ;
    assign      o_tx6_ack_rst       =      r_port_ack_rst[6] ;

    assign      o_tx7_ack           =      r_port_ack[7]     ;
    assign      o_tx7_ack_rst       =      r_port_ack_rst[7] ;

    assign      o_tsn_as_tx_ack     =      r_tsn_as_tx_ack   ;

    assign      o_lldp_tx_ack       =      r_lldp_tx_ack     ;
    
// ----------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tsn_as_tx_ack <= 1'b0;
        end else begin
            r_tsn_as_tx_ack <= ( r_port_ack[0] == 1'b1 && r_port_ack_rst[0][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 : 
                               ( r_port_ack[1] == 1'b1 && r_port_ack_rst[1][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 :   
                               ( r_port_ack[2] == 1'b1 && r_port_ack_rst[2][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 :   
                               ( r_port_ack[3] == 1'b1 && r_port_ack_rst[3][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 :   
                               ( r_port_ack[4] == 1'b1 && r_port_ack_rst[4][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 :   
                               ( r_port_ack[5] == 1'b1 && r_port_ack_rst[5][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 :   
                               ( r_port_ack[6] == 1'b1 && r_port_ack_rst[6][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 :   
                               ( r_port_ack[7] == 1'b1 && r_port_ack_rst[7][PORT_FIFO_PRI_NUM] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_lldp_tx_ack <= 1'b0;
        end else begin
            r_lldp_tx_ack <=  ( r_port_ack[0] == 1'b1 && r_port_ack_rst[0][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 : 
                              ( r_port_ack[1] == 1'b1 && r_port_ack_rst[1][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 :   
                              ( r_port_ack[2] == 1'b1 && r_port_ack_rst[2][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 :   
                              ( r_port_ack[3] == 1'b1 && r_port_ack_rst[3][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 :   
                              ( r_port_ack[4] == 1'b1 && r_port_ack_rst[4][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 :   
                              ( r_port_ack[5] == 1'b1 && r_port_ack_rst[5][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 :   
                              ( r_port_ack[6] == 1'b1 && r_port_ack_rst[6][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 :   
                              ( r_port_ack[7] == 1'b1 && r_port_ack_rst[7][PORT_FIFO_PRI_NUM+1] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    genvar i;
    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
    generate
        // for (i = 0; i < PORT_FIFO_PRI_NUM + 2; i = i +1) begin
        for (i = 0; i < 10; i = i +1) begin
            if (i == 0) begin
                `ifdef CPU_MAC
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac0_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac0_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]      <=  i_mac0_cross_axi_data_user  ;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac0_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac0_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac0_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac0_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac0_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx0_req                   ;
                        end
                    end
                `endif
            end
            else if (i == 1) begin
                `ifdef MAC1
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac1_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac1_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]      <=  i_mac1_cross_axi_data_user  ;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac1_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac1_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac1_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac1_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac1_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx1_req                   ;
                        end
                    end
                `endif
            end
            else if (i == 2) begin
                `ifdef MAC2
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac2_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac2_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]      <=  i_mac2_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac2_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac2_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac2_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac2_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac2_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx2_req                   ;
                        end
                    end
                `endif
            end
            else if (i==3) begin
                `ifdef MAC3
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac3_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac3_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_mac3_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac3_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac3_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac3_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac3_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac3_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx3_req                   ;
                        end
                    end
                `endif
            end
            else if (i==4) begin
                `ifdef MAC4
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac4_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac4_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_mac4_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac4_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac4_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac4_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac4_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac4_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx4_req                   ;
                        end
                    end
                `endif
            end
            else if (i==5) begin
                `ifdef MAC5
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac5_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac5_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_mac5_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac5_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac5_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac5_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac5_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac5_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx5_req                   ;
                        end
                    end
                `endif
            end
            else if (i==6) begin
                `ifdef MAC6
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac6_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac6_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_mac6_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac6_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac6_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac6_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac6_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac6_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx6_req                   ;
                        end
                    end
                `endif
            end
            else if (i==7) begin
                `ifdef MAC7
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;
                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;
                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_mac7_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_mac7_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_mac7_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_mac7_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_mac7_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_mac7_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_mac7_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_mac7_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tx7_req                   ;
                        end
                    end
                `endif
            end
            else if (i==8) begin
                `ifdef TSN_AS
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;

                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;

                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]      <=  i_tsn_as_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]      <=  i_tsn_as_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_tsn_as_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]     <=  i_tsn_as_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]      <=  i_tsn_as_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]           <=  i_tsn_as_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]     <=  i_tsn_as_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]      <=  i_tsn_as_cross_metadata_last  ;

                            ri_tx0_req[i]                      <=  i_tsn_as_tx_req               ;
                        end
                    end
                `endif
            end
            else if (i==9) begin
                `ifdef LLDP
                    // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                    always @(posedge i_clk or posedge i_rst) begin
                        if (i_rst == 1'b1) begin
                            ri_mac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                            ri_mac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                            ri_mac_cross_axi_data_user[i]       <=  {16{1'b0}};
                            ri_mac_cross_axi_data_valid[i]      <=  1'b0;
                            ri_mac_cross_axi_data_last[i]       <=  1'b0;

                            ri_mac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                            ri_mac_cross_metadata_valid[i]      <=  1'b0;
                            ri_mac_cross_metadata_last[i]       <=  1'b0;

                            ri_tx0_req[i]                       <=  1'b0;
                        end else begin
                            ri_mac_cross_port_axi_data[i]       <=  i_lldp_cross_port_axi_data  ;
                            ri_mac_cross_axi_data_keep[i]       <=  i_lldp_cross_axi_data_keep  ;
                            ri_mac_cross_axi_data_user[i]       <=  i_lldp_cross_axi_data_user;
                            ri_mac_cross_axi_data_valid[i]      <=  i_lldp_cross_axi_data_valid ;
                            ri_mac_cross_axi_data_last[i]       <=  i_lldp_cross_axi_data_last  ;

                            ri_mac_cross_metadata[i]            <=  i_lldp_cross_metadata       ;
                            ri_mac_cross_metadata_valid[i]      <=  i_lldp_cross_metadata_valid ;
                            ri_mac_cross_metadata_last[i]       <=  i_lldp_cross_metadata_last  ;

                            ri_tx0_req[i]                       <=  i_lldp_tx_req               ;
                        end
                    end
                `endif
            end
        end
    endgenerate


                                    //   ( ri_mac_cross_axi_data_last[i] == 1'b1 ) ? 1'b0 : 
                                    //   ( r_tx_port_cache_req[i][0] == w_fifo_arb_result[0][i] && w_fifo_arb_valid[0] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][1] == w_fifo_arb_result[1][i] && w_fifo_arb_valid[1] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][2] == w_fifo_arb_result[2][i] && w_fifo_arb_valid[2] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][3] == w_fifo_arb_result[3][i] && w_fifo_arb_valid[3] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][4] == w_fifo_arb_result[4][i] && w_fifo_arb_valid[4] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][5] == w_fifo_arb_result[5][i] && w_fifo_arb_valid[5] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][6] == w_fifo_arb_result[6][i] && w_fifo_arb_valid[6] == 1'b1 ) ? 1'b1 : 
                                    //   ( r_tx_port_cache_req[i][7] == w_fifo_arb_result[7][i] && w_fifo_arb_valid[7] == 1'b1 ) ? 1'b1 :


    generate
        for (i = 0; i < PORT_FIFO_PRI_NUM + 2; i = i + 1) begin
            // 识别端口请求的数据流是否为关键帧
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_data0_qbu_flag[i] <= 1'b0;
                end else begin
                    r_data0_qbu_flag[i] <= 1'b0;//( w_fifo_arb_valid[r_tx_vlan_pri[i]] == 1'b1 ) ? 1'b0 : ( ri_tx0_req[i] == 1'b1 && ri_mac_cross_metadata_valid[i] == 1'b1 && ri_mac_cross_metadata[i][11] == 1'b1 ) ? 1'b1 : r_data0_qbu_flag[i];
                end
            end

            // req 申请信号和 metadata 信号同拍输入，锁存 tx_prot 信息
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_metadata_tx_port[i] <= 8'b0;
                end else begin
                    r_metadata_tx_port[i] <= ( w_fifo_arb_valid[r_tx_vlan_pri[i]] == 1'b1 ) ? 8'b0 : ( ri_tx0_req[i] == 1'b1 && ri_mac_cross_metadata_valid[i] == 1'b1 ) ? ri_mac_cross_metadata[i][59:52] : r_metadata_tx_port[i] ;
                end
            end

            // req 申请信号和 metadata 信号同拍输入，锁存 vlan_pri 信息 ( 先识别该帧是否为 vlan 帧 )
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_vlan_pri[i] <= 3'd0;
                end else begin
                    r_tx_vlan_pri[i] <= ( ri_tx0_req[i] == 1'b1 && ri_mac_cross_metadata_valid[i] == 1'b1 && ri_mac_cross_metadata[i][27] == 1'b1 ) ? ri_mac_cross_metadata[i][62:60] : r_tx_vlan_pri[i];
                end
            end 
			
			// modify at 12.02 and 12.05
            // 从锁存 tx_prot 信息中判断该帧是否是该 cross_bar_tx_port 处理
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_frame_flag[i] <= 1'b0;
                end else begin
                    r_frame_flag[i] <= ( w_fifo_arb_valid[r_tx_vlan_pri[i]] == 1'b1 && r_frame_flag[i] == 1'b1) ? 1'b0 : ( r_metadata_tx_port[i][PORT_ATTRIBUTE] == 1'b1 && ri_mac_cross_metadata[i][12] == 1'b0) ? 1'b1 : r_frame_flag[i];
                end                     //( r_metadata_tx_port[i][PORT_ATTRIBUTE] == 1'b1 ) ? 1'b1 : r_frame_flag[i];
            end

            // // 一个端口可以同时拉高 8 个优先级队列的请求信号
            // always @(posedge i_clk or posedge i_rst) begin
            //     if (i_rst == 1'b1) begin
            //         r_tx_port_cache_req[i][0] <= 1'b1;
            //     end else begin
            //         r_tx_port_cache_req[i][0] <= ( w_fifo_arb_valid[0] == 1'b1 && w_fifo_arb_result[0][i] == 1'b1) ? 1'b0 :   //仲裁结果是当前端口的当前fifo
            //                                      ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd0) ? 1'b1 : r_tx_port_cache_req[i][0];
            //                                     //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd0) ? 1'b1 : r_tx_port_cache_req[i][0];
            //     end
            // end     

            // 一个端口可以同时拉高 8 个优先级队列的请求信号
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][0] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][0] <= ( w_fifo_arb_valid[0] == 1'b1 && w_fifo_arb_result[0][i] == 1'b1) ? 1'b0 :   //仲裁结果是当前端口的当前fifo
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd0) ? 1'b1 : r_tx_port_cache_req[i][0];
                                                //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd0) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end     

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][1] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][1] <= ( w_fifo_arb_valid[1] == 1'b1 && w_fifo_arb_result[1][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd1) ? 1'b1 : r_tx_port_cache_req[i][1];
                                                //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd1) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][2] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][2] <= ( w_fifo_arb_valid[2] == 1'b1 && w_fifo_arb_result[2][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd2) ? 1'b1 : r_tx_port_cache_req[i][2];
                                                 //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd2) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][3] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][3] <= ( w_fifo_arb_valid[3] == 1'b1 && w_fifo_arb_result[3][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd3) ? 1'b1 : r_tx_port_cache_req[i][3];
                                                 //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd3) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][4] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][4] <= ( w_fifo_arb_valid[4] == 1'b1 && w_fifo_arb_result[4][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd4) ? 1'b1 : r_tx_port_cache_req[i][4];
                                                 //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd4) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][5] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][5] <= ( w_fifo_arb_valid[5] == 1'b1 && w_fifo_arb_result[5][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd5) ? 1'b1 : r_tx_port_cache_req[i][5];
                                                 //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd5) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][6] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][6] <= ( w_fifo_arb_valid[6] == 1'b1 && w_fifo_arb_result[6][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd6) ? 1'b1 : r_tx_port_cache_req[i][6];
                                                 //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd6) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_port_cache_req[i][7] <= 1'b0;
                end else begin
                    r_tx_port_cache_req[i][7] <= ( w_fifo_arb_valid[7] == 1'b1 && w_fifo_arb_result[7][i] == 1'b1) ? 1'b0 : 
                                                 ( r_frame_flag[i] == 1'b1 && w_fifio_data_busy[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd7) ? 1'b1 : r_tx_port_cache_req[i][7];
                                                 //( r_frame_flag[i] == 1'b1 && r_tx_vlan_pri[i] == 3'd7) ? 1'b1 : r_tx_port_cache_req[i][0];
                end
            end 
         
            // 数据总线激活信号，等待上游输入数据流
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_tx_active[i] <= 1'b0;
                end else begin
                    r_tx_active[i] <= ( ri_mac_cross_axi_data_last[i] == 1'b1 ) ? 1'b0 : 
                                      ( r_tx_port_cache_req[i][0] == 1'b1 && w_fifo_arb_result[0][i] == 1'b1 && w_fifo_arb_valid[0] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][1] == 1'b1 && w_fifo_arb_result[1][i] == 1'b1 && w_fifo_arb_valid[1] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][2] == 1'b1 && w_fifo_arb_result[2][i] == 1'b1 && w_fifo_arb_valid[2] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][3] == 1'b1 && w_fifo_arb_result[3][i] == 1'b1 && w_fifo_arb_valid[3] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][4] == 1'b1 && w_fifo_arb_result[4][i] == 1'b1 && w_fifo_arb_valid[4] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][5] == 1'b1 && w_fifo_arb_result[5][i] == 1'b1 && w_fifo_arb_valid[5] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][6] == 1'b1 && w_fifo_arb_result[6][i] == 1'b1 && w_fifo_arb_valid[6] == 1'b1 ) ? 1'b1 : 
                                      ( r_tx_port_cache_req[i][7] == 1'b1 && w_fifo_arb_result[7][i] == 1'b1 && w_fifo_arb_valid[7] == 1'b1 ) ? 1'b1 :  r_tx_active[i];
                end
            end

            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    ro_mac_cross_axi_data_ready[i] <= 1'b0;
                end else begin
                    ro_mac_cross_axi_data_ready[i] <=   ( r_tx_port_cache_req[i][0] == 1'b1 && w_fifo_arb_result[0][i] == 1'b1 && w_fifo_arb_valid[0] == 1'b1 ) ? w_pri_ready[0] : 
                                                        ( r_tx_port_cache_req[i][1] == 1'b1 && w_fifo_arb_result[1][i] == 1'b1 && w_fifo_arb_valid[1] == 1'b1 ) ? w_pri_ready[1] : 
                                                        ( r_tx_port_cache_req[i][2] == 1'b1 && w_fifo_arb_result[2][i] == 1'b1 && w_fifo_arb_valid[2] == 1'b1 ) ? w_pri_ready[2] : 
                                                        ( r_tx_port_cache_req[i][3] == 1'b1 && w_fifo_arb_result[3][i] == 1'b1 && w_fifo_arb_valid[3] == 1'b1 ) ? w_pri_ready[3] : 
                                                        ( r_tx_port_cache_req[i][4] == 1'b1 && w_fifo_arb_result[4][i] == 1'b1 && w_fifo_arb_valid[4] == 1'b1 ) ? w_pri_ready[4] : 
                                                        ( r_tx_port_cache_req[i][5] == 1'b1 && w_fifo_arb_result[5][i] == 1'b1 && w_fifo_arb_valid[5] == 1'b1 ) ? w_pri_ready[5] : 
                                                        ( r_tx_port_cache_req[i][6] == 1'b1 && w_fifo_arb_result[6][i] == 1'b1 && w_fifo_arb_valid[6] == 1'b1 ) ? w_pri_ready[6] : 
                                                        ( r_tx_port_cache_req[i][7] == 1'b1 && w_fifo_arb_result[7][i] == 1'b1 && w_fifo_arb_valid[7] == 1'b1 ) ? w_pri_ready[7] : ro_mac_cross_axi_data_ready[i];                                
                end
            end
        end    
    endgenerate

    generate
        for (i = 0; i < PORT_FIFO_PRI_NUM; i = i + 1) begin
            req_arbit req_arbit_port0_u0 (
                .i_clk              ( i_clk                     )
                ,.i_rst             ( i_rst                     )

                ,.i_port0_req       ( r_tx_port_cache_req[0][i] )
                ,.i_data0_qbu_flag  ( r_data0_qbu_flag[0]       )

                ,.i_port1_req       ( r_tx_port_cache_req[1][i] )
                ,.i_data1_qbu_flag  ( r_data0_qbu_flag[1]       )

                ,.i_port2_req       ( r_tx_port_cache_req[2][i] )
                ,.i_data2_qbu_flag  ( r_data0_qbu_flag[2]       )

                ,.i_port3_req       ( r_tx_port_cache_req[3][i] )
                ,.i_data3_qbu_flag  ( r_data0_qbu_flag[3]       )

                ,.i_port4_req       ( r_tx_port_cache_req[4][i] )
                ,.i_data4_qbu_flag  ( r_data0_qbu_flag[4]       )

                ,.i_port5_req       ( r_tx_port_cache_req[5][i] )
                ,.i_data5_qbu_flag  ( r_data0_qbu_flag[5]       )

                ,.i_port6_req       ( r_tx_port_cache_req[6][i] )
                ,.i_data6_qbu_flag  ( r_data0_qbu_flag[6]       )

                ,.i_port7_req       ( r_tx_port_cache_req[7][i] )
                ,.i_data7_qbu_flag  ( r_data0_qbu_flag[7]       )

                ,.i_port8_req       ( r_tx_port_cache_req[8][i] )
                ,.i_data8_qbu_flag  ( r_data0_qbu_flag[8]       )

                ,.i_port9_req       ( r_tx_port_cache_req[9][i] )
                ,.i_data9_qbu_flag  ( r_data0_qbu_flag[9]       )

                ,.i_data_ready      ( w_fifio_data_busy[i]           )  

                ,.o_port_ack        ( w_fifo_arb_result[i]      )
                ,.o_port_vld        ( w_fifo_arb_valid[i]       )
            );
        end
    endgenerate

    generate
        for (i = 0; i < PORT_FIFO_PRI_NUM; i = i + 1) begin
            // 处理 ack 结果的逻辑
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst == 1'b1) begin
                    r_port_ack[i] <= 1'b0;    
                    r_port_ack_rst[i] <= {(PORT_FIFO_PRI_NUM+1){1'b0}};
                end else begin    
                    r_port_ack[i] <= ( w_fifo_arb_valid[0] == 1'b1 && w_fifo_arb_result[0][i] == 1'b1 ) ? 1'b1 : 
                                     ( w_fifo_arb_valid[1] == 1'b1 && w_fifo_arb_result[1][i] == 1'b1 ) ? 1'b1 : 
                                     ( w_fifo_arb_valid[2] == 1'b1 && w_fifo_arb_result[2][i] == 1'b1 ) ? 1'b1 :                     
                                     ( w_fifo_arb_valid[3] == 1'b1 && w_fifo_arb_result[3][i] == 1'b1 ) ? 1'b1 :                     
                                     ( w_fifo_arb_valid[4] == 1'b1 && w_fifo_arb_result[4][i] == 1'b1 ) ? 1'b1 : 
                                     ( w_fifo_arb_valid[5] == 1'b1 && w_fifo_arb_result[5][i] == 1'b1 ) ? 1'b1 :                     
                                     ( w_fifo_arb_valid[6] == 1'b1 && w_fifo_arb_result[6][i] == 1'b1 ) ? 1'b1 :                     
                                     ( w_fifo_arb_valid[7] == 1'b1 && w_fifo_arb_result[7][i] == 1'b1 ) ? 1'b1 : 1'b0;
                   
                    r_port_ack_rst[i] <= ( w_fifo_arb_valid[0] == 1'b1 && w_fifo_arb_result[0][i] == 1'b1) ? 10'b00_0000_0001 : 
                                         ( w_fifo_arb_valid[1] == 1'b1 && w_fifo_arb_result[1][i] == 1'b1) ? 10'b00_0000_0010 : 
                                         ( w_fifo_arb_valid[2] == 1'b1 && w_fifo_arb_result[2][i] == 1'b1) ? 10'b00_0000_0100 : 
                                         ( w_fifo_arb_valid[3] == 1'b1 && w_fifo_arb_result[3][i] == 1'b1) ? 10'b00_0000_1000 :
                                         ( w_fifo_arb_valid[4] == 1'b1 && w_fifo_arb_result[4][i] == 1'b1) ? 10'b00_0001_0000 : 
                                         ( w_fifo_arb_valid[5] == 1'b1 && w_fifo_arb_result[5][i] == 1'b1) ? 10'b00_0010_0000 : 
                                         ( w_fifo_arb_valid[6] == 1'b1 && w_fifo_arb_result[6][i] == 1'b1) ? 10'b00_0100_0000 :
                                         ( w_fifo_arb_valid[7] == 1'b1 && w_fifo_arb_result[7][i] == 1'b1) ? 10'b00_1000_0000 : r_port_ack_rst[i];
                end
            end
        end
    endgenerate

generate
    for (i = 0; i < PORT_FIFO_PRI_NUM; i = i + 1) begin
        // 将激活的端口数据流映射至不同的优先级队列 FIFO 中
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst == 1'b1) begin
                r_pri_data[i]               <=    {(CROSS_DATA_WIDTH + 1){1'b0}}; 
                r_pri_data_keep[i]          <=    {(CROSS_DATA_WIDTH/8){1'b0}};
                r_pri_data_user[i]           <=   {16{1'b0}};
                r_pri_data_vld[i]           <=    1'b0;     
                r_pri_data_last[i]          <=    1'b0; 
                r_pri_meta_data[i]          <=    {(METADATA_WIDTH){1'b0}};
                r_pri_meta_data_vld[i]      <=    1'b0;
            end else begin
                r_pri_data[i]               <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_port_axi_data[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_port_axi_data[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_port_axi_data[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_port_axi_data[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_port_axi_data[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_port_axi_data[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_port_axi_data[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_port_axi_data[7] : 
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_port_axi_data[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_port_axi_data[9] : {(CROSS_DATA_WIDTH + 1){1'b0}}; 

                r_pri_data_keep[i]          <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_axi_data_keep[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_axi_data_keep[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_axi_data_keep[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_axi_data_keep[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_axi_data_keep[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_axi_data_keep[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_axi_data_keep[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_axi_data_keep[7] :
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_axi_data_keep[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_axi_data_keep[9] : {(CROSS_DATA_WIDTH/8){1'b0}}; 

                r_pri_data_user[i]          <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_axi_data_user[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_axi_data_user[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_axi_data_user[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_axi_data_user[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_axi_data_user[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_axi_data_user[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_axi_data_user[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_axi_data_user[7] :
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_axi_data_user[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_axi_data_user[9] : {(CROSS_DATA_WIDTH/8){1'b0}}; 

                r_pri_data_vld[i]           <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_axi_data_valid[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_axi_data_valid[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_axi_data_valid[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_axi_data_valid[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_axi_data_valid[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_axi_data_valid[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_axi_data_valid[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_axi_data_valid[7] :
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_axi_data_valid[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_axi_data_valid[9] : 1'b0; 

                r_pri_data_last[i]          <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_axi_data_last[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_axi_data_last[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_axi_data_last[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_axi_data_last[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_axi_data_last[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_axi_data_last[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_axi_data_last[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_axi_data_last[7] :
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_axi_data_last[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_axi_data_last[9] : 1'b0; 

                r_pri_meta_data[i]          <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_metadata[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_metadata[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_metadata[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_metadata[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_metadata[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_metadata[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_metadata[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_metadata[7] :
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_metadata[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_metadata[9] : {(METADATA_WIDTH){1'b0}}; 

                r_pri_meta_data_vld[i]      <=  ( r_tx_active[0] == 1'b1 && w_fifo_arb_result[i][0] == 1'b1 ) ? ri_mac_cross_metadata_valid[0] : 
                                                ( r_tx_active[1] == 1'b1 && w_fifo_arb_result[i][1] == 1'b1 ) ? ri_mac_cross_metadata_valid[1] : 
                                                ( r_tx_active[2] == 1'b1 && w_fifo_arb_result[i][2] == 1'b1 ) ? ri_mac_cross_metadata_valid[2] : 
                                                ( r_tx_active[3] == 1'b1 && w_fifo_arb_result[i][3] == 1'b1 ) ? ri_mac_cross_metadata_valid[3] : 
                                                ( r_tx_active[4] == 1'b1 && w_fifo_arb_result[i][4] == 1'b1 ) ? ri_mac_cross_metadata_valid[4] : 
                                                ( r_tx_active[5] == 1'b1 && w_fifo_arb_result[i][5] == 1'b1 ) ? ri_mac_cross_metadata_valid[5] : 
                                                ( r_tx_active[6] == 1'b1 && w_fifo_arb_result[i][6] == 1'b1 ) ? ri_mac_cross_metadata_valid[6] : 
                                                ( r_tx_active[7] == 1'b1 && w_fifo_arb_result[i][7] == 1'b1 ) ? ri_mac_cross_metadata_valid[7] :
                                                ( r_tx_active[8] == 1'b1 && w_fifo_arb_result[i][8] == 1'b1 ) ? ri_mac_cross_metadata_valid[8] : 
                                                ( r_tx_active[9] == 1'b1 && w_fifo_arb_result[i][9] == 1'b1 ) ? ri_mac_cross_metadata_valid[9] : 1'b0; 
            end
        end
    end
endgenerate

// -------------

cross_data_cache #(
    .METADATA_WIDTH             ( METADATA_WIDTH                )
    ,.PORT_MNG_DATA_WIDTH       ( PORT_MNG_DATA_WIDTH           )
    ,.PORT_FIFO_PRI_NUM         ( PORT_FIFO_PRI_NUM             )
    ,.CROSS_DATA_WIDTH          ( CROSS_DATA_WIDTH              )  // 聚合总线输出 
) cross_data_cache_inst (                
    // sys interface                
    .i_clk                      ( i_clk                         )
    ,.i_rst                     ( i_rst                         ) 
    // data stream pri interface   

    ,.i_data0                   ( r_pri_data[0]                 )
    ,.i_data0_keep              ( r_pri_data_keep[0]            )
    ,.i_data0_user              ( r_pri_data_user[0]            )
    ,.i_data0_vld               ( r_pri_data_vld[0]             )
    ,.i_data0_last              ( r_pri_data_last[0]            )
    ,.i_meta_data0_pri          ( r_pri_meta_data[0]            )
    ,.i_meta_data0_pri_vld      ( r_pri_meta_data_vld[0]        )
    ,.o_data0_ready             ( w_pri_ready[0]                )
    ,.o_data0_busy              ( w_fifio_data_busy[0]          )

    ,.i_data1                   ( r_pri_data[1]                 )
    ,.i_data1_keep              ( r_pri_data_keep[1]            )
    ,.i_data1_user              ( r_pri_data_user[1]            )
    ,.i_data1_vld               ( r_pri_data_vld[1]             )
    ,.i_data1_last              ( r_pri_data_last[1]            )
    ,.i_meta_data1_pri          ( r_pri_meta_data[1]            )
    ,.i_meta_data1_pri_vld      ( r_pri_meta_data_vld[1]        )
    ,.o_data1_ready             ( w_pri_ready[1]                )
    ,.o_data1_busy              ( w_fifio_data_busy[1]          )

    ,.i_data2                   ( r_pri_data[2]                 )
    ,.i_data2_keep              ( r_pri_data_keep[2]            )
    ,.i_data2_user              ( r_pri_data_user[2]            )
    ,.i_data2_vld               ( r_pri_data_vld[2]             )
    ,.i_data2_last              ( r_pri_data_last[2]            )
    ,.i_meta_data2_pri          ( r_pri_meta_data[2]            )
    ,.i_meta_data2_pri_vld      ( r_pri_meta_data_vld[2]        )
    // ,.i_data2_qbu_flag          ( )
    ,.o_data2_ready             ( w_pri_ready[2]                  )
    ,.o_data2_busy              ( w_fifio_data_busy[2]                )

    ,.i_data3                   ( r_pri_data[3]                 )
    ,.i_data3_keep              ( r_pri_data_keep[3]            )
    ,.i_data3_user              ( r_pri_data_user[3]            )
    ,.i_data3_vld               ( r_pri_data_vld[3]             )
    ,.i_data3_last              ( r_pri_data_last[3]            )
    ,.i_meta_data3_pri          ( r_pri_meta_data[3]            )
    ,.i_meta_data3_pri_vld      ( r_pri_meta_data_vld[3]        )
    ,.o_data3_ready             ( w_pri_ready[3]                  )
    ,.o_data3_busy              ( w_fifio_data_busy[3]                )

    ,.i_data4                   ( r_pri_data[4]                 )
    ,.i_data4_keep              ( r_pri_data_keep[4]            )
    ,.i_data4_user              ( r_pri_data_user[4]            )
    ,.i_data4_vld               ( r_pri_data_vld[4]             )
    ,.i_data4_last              ( r_pri_data_last[4]            )
    ,.i_meta_data4_pri          ( r_pri_meta_data[4]            )
    ,.i_meta_data4_pri_vld      ( r_pri_meta_data_vld[4]        )
    ,.o_data4_ready             ( w_pri_ready[4]                  )
    ,.o_data4_busy              ( w_fifio_data_busy[4]                )

    ,.i_data5                   ( r_pri_data[5]                 )
    ,.i_data5_keep              ( r_pri_data_keep[5]            )
    ,.i_data5_user              ( r_pri_data_user[5]            )
    ,.i_data5_vld               ( r_pri_data_vld[5]             )
    ,.i_data5_last              ( r_pri_data_last[5]            )
    ,.i_meta_data5_pri          ( r_pri_meta_data[5]            )
    ,.i_meta_data5_pri_vld      ( r_pri_meta_data_vld[5]        )
    ,.o_data5_ready             ( w_pri_ready[5]                 )
    ,.o_data5_busy              ( w_fifio_data_busy[5]                )

    ,.i_data6                   ( r_pri_data[6]                 )
    ,.i_data6_keep              ( r_pri_data_keep[6]            )
    ,.i_data6_user              ( r_pri_data_user[6]            )
    ,.i_data6_vld               ( r_pri_data_vld[6]             )
    ,.i_data6_last              ( r_pri_data_last[6]            )
    ,.i_meta_data6_pri          ( r_pri_meta_data[6]            )
    ,.i_meta_data6_pri_vld      ( r_pri_meta_data_vld[6]        )
    ,.o_data6_ready             ( w_pri_ready[6]                  )
    ,.o_data6_busy              ( w_fifio_data_busy[6]                )

    ,.i_data7                   ( r_pri_data[7]                 )
    ,.i_data7_keep              ( r_pri_data_keep[7]            )
    ,.i_data7_user              ( r_pri_data_user[7]            )
    ,.i_data7_vld               ( r_pri_data_vld[7]             )
    ,.i_data7_last              ( r_pri_data_last[7]            )
    ,.i_meta_data7_pri          ( r_pri_meta_data[7]            )
    ,.i_meta_data7_pri_vld      ( r_pri_meta_data_vld[7]        )
    ,.o_data7_ready             ( w_pri_ready[7]                 )
    ,.o_data7_busy              ( w_fifio_data_busy[7]                )

    // 与调度流水线交互接口     
    ,.o_fifoc_empty            ( o_fifoc_empty                 )   
    ,.i_scheduing_rst           ( i_scheduing_rst               )    
    ,.i_scheduing_rst_vld       ( i_scheduing_rst_vld           )    
    /*-------------------- TXMAC 输出数据流 -----------------------*/
    //pmac通道数据
    ,.o_pmac_tx_axis_data       ( o_pmac_tx_axis_data           )    
    ,.o_pmac_tx_axis_user       ( o_pmac_tx_axis_user           )    
    ,.o_pmac_tx_axis_keep       ( o_pmac_tx_axis_keep           )    
    ,.o_pmac_tx_axis_last       ( o_pmac_tx_axis_last           )    
    ,.o_pmac_tx_axis_valid      ( o_pmac_tx_axis_valid          )     
    ,.i_pmac_tx_axis_ready      ( i_pmac_tx_axis_ready          )   
    //emac通道数据                      
	//,.i_emac_tx_axis_user		( o_emac_tx_axis_user			)
    ,.o_emac_tx_axis_data       (           )    
    ,.o_emac_tx_axis_user       (           )    
    ,.o_emac_tx_axis_keep       (           )    
    ,.o_emac_tx_axis_last       (           )    
    ,.o_emac_tx_axis_valid      (           )    
    ,.i_emac_tx_axis_ready      (  1'b0     )    
);

emac_data_handle #(
    // 参数配置
    .PORT_ATTRIBUTE         (PORT_ATTRIBUTE),           // 根据实际需求配置
    .REG_ADDR_BUS_WIDTH     (REG_ADDR_BUS_WIDTH),           // 寄存器地址位宽
    .REG_DATA_BUS_WIDTH     (REG_DATA_BUS_WIDTH),          // 寄存器数据位宽
    .METADATA_WIDTH         (METADATA_WIDTH),          // 信息流位宽
    .PORT_MNG_DATA_WIDTH    (PORT_MNG_DATA_WIDTH),           // 端口管理数据位宽
    .PORT_FIFO_PRI_NUM      (PORT_FIFO_PRI_NUM),           // FIFO优先级数量
    .CROSS_DATA_WIDTH       (CROSS_DATA_WIDTH)            // 聚合总线输出位宽
) u_emac_data_handle (
    // 系统信号
    .i_clk                              (i_clk),
    .i_rst                              (i_rst),
    
    /********************************rx port*********************************************/
    // rxmac0 通道
    .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data),
    .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep),
    .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user),
    .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid),
    .o_rxmac0_qbu_axis_ready            (o_rxmac0_qbu_axis_ready),
    .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last),
    .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata),
    .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid),
    .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last),
    .o_rxmac0_qbu_metadata_ready        (o_rxmac0_qbu_metadata_ready),
    
    // rxmac1 通道
    .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data),
    .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep),
    .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user),
    .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid),
    .o_rxmac1_qbu_axis_ready            (o_rxmac1_qbu_axis_ready),
    .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last),
    .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata),
    .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid),
    .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last),
    .o_rxmac1_qbu_metadata_ready        (o_rxmac1_qbu_metadata_ready),
    
    // rxmac2 通道
    .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data),
    .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep),
    .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user),
    .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid),
    .o_rxmac2_qbu_axis_ready            (o_rxmac2_qbu_axis_ready),
    .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last),
    .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata),
    .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid),
    .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last),
    .o_rxmac2_qbu_metadata_ready        (o_rxmac2_qbu_metadata_ready),
    
    // rxmac3 通道
    .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data),
    .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep),
    .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user),
    .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid),
    .o_rxmac3_qbu_axis_ready            (o_rxmac3_qbu_axis_ready),
    .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last),
    .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata),
    .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid),
    .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last),
    .o_rxmac3_qbu_metadata_ready        (o_rxmac3_qbu_metadata_ready),
    
    // rxmac4 通道
    .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data),
    .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep),
    .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user),
    .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid),
    .o_rxmac4_qbu_axis_ready            (o_rxmac4_qbu_axis_ready),
    .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last),
    .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata),
    .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid),
    .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last),
    .o_rxmac4_qbu_metadata_ready        (o_rxmac4_qbu_metadata_ready),
    
    // rxmac5 通道
    .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data),
    .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep),
    .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user),
    .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid),
    .o_rxmac5_qbu_axis_ready            (o_rxmac5_qbu_axis_ready),
    .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last),
    .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata),
    .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid),
    .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last),
    .o_rxmac5_qbu_metadata_ready        (o_rxmac5_qbu_metadata_ready),
    
    // rxmac6 通道
    .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data),
    .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep),
    .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user),
    .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid),
    .o_rxmac6_qbu_axis_ready            (o_rxmac6_qbu_axis_ready),
    .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last),
    .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata),
    .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid),
    .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last),
    .o_rxmac6_qbu_metadata_ready        (o_rxmac6_qbu_metadata_ready),
    
    // rxmac7 通道
    .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data),
    .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep),
    .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user),
    .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid),
    .o_rxmac7_qbu_axis_ready            (o_rxmac7_qbu_axis_ready),
    .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last),
    .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata),
    .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid),
    .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last),
    .o_rxmac7_qbu_metadata_ready        (o_rxmac7_qbu_metadata_ready),
    
    /********************************tx port*********************************************/
    // emac0 发送通道
    .o_emac0_tx_axis_data               (o_emac_tx_axis_data   ),
    .o_emac0_tx_axis_user               (o_emac_tx_axis_user   ),
    .o_emac0_tx_axis_keep               (o_emac_tx_axis_keep   ),
    .o_emac0_tx_axis_last               (o_emac_tx_axis_last   ),
    .o_emac0_tx_axis_valid              (o_emac_tx_axis_valid  ),
    .i_emac0_tx_axis_ready              (i_emac_tx_axis_ready  )
);




endmodule