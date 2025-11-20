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
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac0_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac0_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_mac0_cross_axi_data_user          ,    
    input               wire                                    i_mac0_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac0_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac0_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac0_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac0_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac0_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac0_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx0_req                           , // RXMAC的请求信号

    output             wire                                     o_mac0_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac0_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac0_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac0_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac0_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac0_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac0_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac0_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac0_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac1_cross_axi_data_user               ,    
    input               wire                                    i_mac1_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac1_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac1_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac1_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac1_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac1_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac1_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx1_req                           ,

    output             wire                                     o_mac1_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac1_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac1_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac1_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac1_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac1_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac1_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac1_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac1_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac2_cross_axi_data_user               ,    
    input               wire                                    i_mac2_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac2_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac2_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac2_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac2_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac2_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac2_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx2_req                           ,

    output             wire                                     o_mac2_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac2_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac2_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac2_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac2_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac2_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac2_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac2_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac2_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac3_cross_axi_data_user               ,    
    input               wire                                    i_mac3_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac3_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac3_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac3_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac3_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac3_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac3_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx3_req                           ,

    output             wire                                     o_mac3_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac3_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac3_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac3_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac3_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac3_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac3_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac3_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac3_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac4_cross_axi_data_user               ,    
    input               wire                                    i_mac4_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac4_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac4_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac4_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac4_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac4_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac4_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx4_req                           ,

    output             wire                                     o_mac4_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac4_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac4_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac4_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac4_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac4_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac4_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac4_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac4_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac5_cross_axi_data_user               ,    
    input               wire                                    i_mac5_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac5_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac5_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac5_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac5_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac5_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac5_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx5_req                           ,

    output             wire                                     o_mac5_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac5_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac5_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac5_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac5_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac5_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac5_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac5_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac5_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac6_cross_axi_data_user               ,    
    input               wire                                    i_mac6_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac6_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac6_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac6_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac6_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac6_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac6_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx6_req                           ,

    output             wire                                     o_mac6_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac6_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac6_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac6_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac6_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac6_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac6_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac6_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac6_tx7_ack_rst                  , // 端口的优先级向量结果

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
    input               wire   [15:0]                           i_mac7_cross_axi_data_user               ,    
    input               wire                                    i_mac7_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac7_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac7_cross_axi_data_last          , // 数据流结束标识
    
    input              wire   [METADATA_WIDTH-1:0]              i_mac7_cross_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac7_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac7_cross_metadata_last          , // 信息流结束标识
    output             wire                                     o_mac7_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_tx7_req                           ,
    
    output             wire                                     o_mac7_tx0_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx0_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac7_tx1_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx1_ack_rst                  , // 端口的优先级向量结果  
    output             wire                                     o_mac7_tx2_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx2_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac7_tx3_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx3_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac7_tx4_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx4_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac7_tx5_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx5_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac7_tx6_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx6_ack_rst                  , // 端口的优先级向量结果
    output             wire                                     o_mac7_tx7_ack                      , // 响应使能信号
    output             wire   [PORT_FIFO_PRI_NUM-1:0]           o_mac7_tx7_ack_rst                  , // 端口的优先级向量结果

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
`ifdef TSN_AS
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_tsn_as_cross_port_axi_data        , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_tsn_as_cross_axi_data_keep        , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_tsn_as_cross_axi_data_user        ,
    input               wire                                    i_tsn_as_cross_axi_data_valid       , // 端口数据有效
    output              wire                                    o_tsn_as_cross_axi_data_ready       , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_tsn_as_cross_axi_data_last        , // 数据流结束标识
    
    input               wire   [METADATA_WIDTH-1:0]             i_tsn_as_cross_metadata             , // 总线 metadata 数据
    input               wire                                    i_tsn_as_cross_metadata_valid       , // 总线 metadata 数据有效信号
    input               wire                                    i_tsn_as_cross_metadata_last        , // 信息流结束标识
    output              wire                                    o_tsn_as_cross_metadata_ready       , // 下游模块反压流水线 

    input              wire                                     i_tsn_as_tx_req                     ,
    output             wire                                     o_tsn_as_tx_ack                     ,
`endif 
`ifdef LLDP
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire   [CROSS_DATA_WIDTH:0]             i_lldp_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_lldp_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire   [15:0]                           i_lldp_cross_axi_data_user          ,
    input               wire                                    i_lldp_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_lldp_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_lldp_cross_axi_data_last          , // 数据流结束标识
    
    input               wire  [METADATA_WIDTH-1:0]              i_lldp_cross_metadata               , // 总线 metadata 数据
    input               wire                                    i_lldp_cross_metadata_valid         , // 总线 metadata 数据有效信号
    input               wire                                    i_lldp_cross_metadata_last          , // 信息流结束标识
    output              wire                                    o_lldp_cross_metadata_ready         , // 下游模块反压流水线 

    input              wire                                     i_lldp_tx_req                       ,
    output             wire                                     o_lldp_tx_ack                       ,
`endif 
    /*-------------------- TXMAC 输出数据流 -----------------------*/
`ifdef CPU_MAC
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac0_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac0_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac0_tx_axis_keep                , 
    output          wire                                        o_pmac0_tx_axis_last                , 
    output          wire                                        o_pmac0_tx_axis_valid               , 
    input           wire                                        i_pmac0_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac0_tx_axis_data                , 
    output          wire    [15:0]                              o_emac0_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac0_tx_axis_keep                , 
    output          wire                                        o_emac0_tx_axis_last                , 
    output          wire                                        o_emac0_tx_axis_valid               , 
    input           wire                                        i_emac0_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac0_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac0_scheduing_rst                ,
    input           wire                                        i_mac0_scheduing_rst_vld            ,  
`endif
`ifdef MAC1
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac1_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac1_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac1_tx_axis_keep                , 
    output          wire                                        o_pmac1_tx_axis_last                , 
    output          wire                                        o_pmac1_tx_axis_valid               , 
    input           wire                                        i_pmac1_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac1_tx_axis_data                , 
    output          wire    [15:0]                              o_emac1_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac1_tx_axis_keep                , 
    output          wire                                        o_emac1_tx_axis_last                , 
    output          wire                                        o_emac1_tx_axis_valid               , 
    input           wire                                        i_emac1_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac1_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac1_scheduing_rst                ,
    input           wire                                        i_mac1_scheduing_rst_vld            ,  
`endif
`ifdef MAC2
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac2_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac2_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac2_tx_axis_keep                , 
    output          wire                                        o_pmac2_tx_axis_last                , 
    output          wire                                        o_pmac2_tx_axis_valid               , 
    input           wire                                        i_pmac2_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac2_tx_axis_data                , 
    output          wire    [15:0]                              o_emac2_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac2_tx_axis_keep                , 
    output          wire                                        o_emac2_tx_axis_last                , 
    output          wire                                        o_emac2_tx_axis_valid               , 
    input           wire                                        i_emac2_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac2_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac2_scheduing_rst                ,
    input           wire                                        i_mac2_scheduing_rst_vld            ,  
`endif
`ifdef MAC3
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac3_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac3_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac3_tx_axis_keep                , 
    output          wire                                        o_pmac3_tx_axis_last                , 
    output          wire                                        o_pmac3_tx_axis_valid               , 
    input           wire                                        i_pmac3_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac3_tx_axis_data                , 
    output          wire    [15:0]                              o_emac3_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac3_tx_axis_keep                , 
    output          wire                                        o_emac3_tx_axis_last                , 
    output          wire                                        o_emac3_tx_axis_valid               , 
    input           wire                                        i_emac3_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac3_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac3_scheduing_rst                ,
    input           wire                                        i_mac3_scheduing_rst_vld            ,  
`endif
`ifdef MAC4
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac4_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac4_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac4_tx_axis_keep                , 
    output          wire                                        o_pmac4_tx_axis_last                , 
    output          wire                                        o_pmac4_tx_axis_valid               ,  
    input           wire                                        i_pmac4_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac4_tx_axis_data                , 
    output          wire    [15:0]                              o_emac4_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac4_tx_axis_keep                , 
    output          wire                                        o_emac4_tx_axis_last                , 
    output          wire                                        o_emac4_tx_axis_valid               , 
    input           wire                                        i_emac4_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac4_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac4_scheduing_rst                ,
    input           wire                                        i_mac4_scheduing_rst_vld            ,  
`endif
`ifdef MAC5
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac5_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac5_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac5_tx_axis_keep                , 
    output          wire                                        o_pmac5_tx_axis_last                , 
    output          wire                                        o_pmac5_tx_axis_valid               ,  
    input           wire                                        i_pmac5_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac5_tx_axis_data                , 
    output          wire    [15:0]                              o_emac5_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac5_tx_axis_keep                , 
    output          wire                                        o_emac5_tx_axis_last                , 
    output          wire                                        o_emac5_tx_axis_valid               , 
    input           wire                                        i_emac5_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac5_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac5_scheduing_rst                ,
    input           wire                                        i_mac5_scheduing_rst_vld            ,  
`endif
`ifdef MAC6
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac6_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac6_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac6_tx_axis_keep                , 
    output          wire                                        o_pmac6_tx_axis_last                , 
    output          wire                                        o_pmac6_tx_axis_valid               , 
    input           wire                                        i_pmac6_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac6_tx_axis_data                , 
    output          wire    [15:0]                              o_emac6_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac6_tx_axis_keep                , 
    output          wire                                        o_emac6_tx_axis_last                , 
    output          wire                                        o_emac6_tx_axis_valid               , 
    input           wire                                        i_emac6_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac6_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac6_scheduing_rst                ,
    input           wire                                        i_mac6_scheduing_rst_vld            ,  
`endif
`ifdef MAC7
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_pmac7_tx_axis_data                , 
    output          wire    [15:0]                              o_pmac7_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_pmac7_tx_axis_keep                , 
    output          wire                                        o_pmac7_tx_axis_last                , 
    output          wire                                        o_pmac7_tx_axis_valid               ,  
    input           wire                                        i_pmac7_tx_axis_ready               ,
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac7_tx_axis_data                , 
    output          wire    [15:0]                              o_emac7_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac7_tx_axis_keep                , 
    output          wire                                        o_emac7_tx_axis_last                , 
    output          wire                                        o_emac7_tx_axis_valid               , 
    input           wire                                        i_emac7_tx_axis_ready               ,
    // 调度流水线调度信息交互
    output          wire   [PORT_FIFO_PRI_NUM-1:0]              o_mac7_fifoc_empty                  ,    
    input           wire   [PORT_FIFO_PRI_NUM-1:0]              i_mac7_scheduing_rst                ,
    input           wire                                        i_mac7_scheduing_rst_vld            ,  
`endif
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               
);

/*----------------- localparam ----------*/
localparam      CPU_MAC_ATTRIBUTE       =   0 ;
localparam      MAC1_ATTRIBUTE          =   1 ;
localparam      MAC2_ATTRIBUTE          =   2 ;
localparam      MAC3_ATTRIBUTE          =   3 ;
localparam      MAC4_ATTRIBUTE          =   4 ;
localparam      MAC5_ATTRIBUTE          =   5 ;
localparam      MAC6_ATTRIBUTE          =   6 ;
localparam      MAC7_ATTRIBUTE          =   7 ;

/*--------------------- wire ----------------*/
`ifdef CPU_MAC
    wire   [CROSS_DATA_WIDTH:0]             w_mac0_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac0_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac0_cross_axi_data_user          ;
    wire                                    w_mac0_cross_axi_data_valid         ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac0_cross_axi_data_ready         ;
    reg                                     ro_mac0_cross_axi_data_ready        ;
    wire                                    w_mac0_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac0_cross_metadata               ;
    wire                                    w_mac0_cross_metadata_valid         ;
    wire                                    w_mac0_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac0_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]          w_mac0_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac0_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac0_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;


`endif

`ifdef MAC1
    wire   [CROSS_DATA_WIDTH:0]             w_mac1_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac1_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac1_cross_axi_data_user          ;
    wire                                    w_mac1_cross_axi_data_valid         ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac1_cross_axi_data_ready         ;
    reg                                     ro_mac1_cross_axi_data_ready        ;
    wire                                    w_mac1_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac1_cross_metadata               ;
    wire                                    w_mac1_cross_metadata_valid         ;
    wire                                    w_mac1_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac1_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]          w_mac1_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac1_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac1_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;



`endif

`ifdef MAC2
    wire   [CROSS_DATA_WIDTH:0]             w_mac2_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac2_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac2_cross_axi_data_user          ;
    wire                                    w_mac2_cross_axi_data_valid         ;
    reg                                     ro_mac2_cross_axi_data_ready        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac2_cross_axi_data_ready         ;
    wire                                    w_mac2_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac2_cross_metadata               ;
    wire                                    w_mac2_cross_metadata_valid         ;
    wire                                    w_mac2_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac2_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]          w_mac2_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac2_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac2_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;


`endif

`ifdef MAC3
    wire   [CROSS_DATA_WIDTH:0]             w_mac3_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac3_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac3_cross_axi_data_user          ;
    wire                                    w_mac3_cross_axi_data_valid         ;
    reg                                     ro_mac3_cross_axi_data_ready        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac3_cross_axi_data_ready         ;
    wire                                    w_mac3_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac3_cross_metadata               ;
    wire                                    w_mac3_cross_metadata_valid         ;
    wire                                    w_mac3_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac3_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]          w_mac3_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac3_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac3_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;

`endif

`ifdef MAC4
    wire   [CROSS_DATA_WIDTH:0]             w_mac4_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac4_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac4_cross_axi_data_user          ;
    wire                                    w_mac4_cross_axi_data_valid         ;
    reg                                     ro_mac4_cross_axi_data_ready        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac4_cross_axi_data_ready         ;
    wire                                    w_mac4_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac4_cross_metadata               ;
    wire                                    w_mac4_cross_metadata_valid         ;
    wire                                    w_mac4_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac4_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]            w_mac4_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac4_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac4_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;

`endif

`ifdef MAC5

    wire   [CROSS_DATA_WIDTH:0]             w_mac5_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac5_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac5_cross_axi_data_user          ;
    wire                                    w_mac5_cross_axi_data_valid         ;
    reg                                     ro_mac5_cross_axi_data_ready        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac5_cross_axi_data_ready         ;
    wire                                    w_mac5_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac5_cross_metadata               ;
    wire                                    w_mac5_cross_metadata_valid         ;
    wire                                    w_mac5_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac5_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]            w_mac5_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac5_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac5_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;


`endif

`ifdef MAC6
    wire   [CROSS_DATA_WIDTH:0]             w_mac6_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac6_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac6_cross_axi_data_user          ;
    wire                                    w_mac6_cross_axi_data_valid         ;
    reg                                     ro_mac6_cross_axi_data_ready        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac6_cross_axi_data_ready         ;
    wire                                    w_mac6_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac6_cross_metadata               ;
    wire                                    w_mac6_cross_metadata_valid         ;
    wire                                    w_mac6_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac6_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]            w_mac6_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac6_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac6_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;

`endif

`ifdef MAC7
    wire   [CROSS_DATA_WIDTH:0]             w_mac7_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac7_cross_axi_data_keep          ;
    wire   [15:0]                           w_mac7_cross_axi_data_user          ;
    wire                                    w_mac7_cross_axi_data_valid         ;
    reg                                     ro_mac7_cross_axi_data_ready        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac7_cross_axi_data_ready         ;
    wire                                    w_mac7_cross_axi_data_last          ;
    wire   [METADATA_WIDTH-1:0]             w_mac7_cross_metadata               ;
    wire                                    w_mac7_cross_metadata_valid         ;
    wire                                    w_mac7_cross_metadata_last          ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac7_cross_metadata_ready         ;

    wire   [PORT_FIFO_PRI_NUM-1:0]          w_mac7_fifoc_empty                  ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2rxmac7_ack       ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_txmac_2rxmac7_ack_rst[PORT_MNG_DATA_WIDTH-1:0]   ;
`endif

`ifdef TSN_AS
    wire   [CROSS_DATA_WIDTH:0]             w_tsn_as_cross_port_axi_data        ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_tsn_as_cross_axi_data_keep        ;
    wire                                    w_tsn_as_cross_axi_data_valid       ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_tsn_as_cross_axi_data_ready       ;
    wire                                    w_tsn_as_cross_axi_data_last        ;

    wire   [METADATA_WIDTH-1:0]             w_tsn_as_cross_metadata             ;
    wire                                    w_tsn_as_cross_metadata_valid       ;
    wire                                    w_tsn_as_cross_metadata_last        ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_tsn_as_cross_metadata_ready       ;

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2tsn_as_ack       ;

    // wire                                    w_mac0_as_ack                       ;
    // wire                                    w_mac1_as_ack                       ;
    // wire                                    w_mac2_as_ack                       ;
    // wire                                    w_mac3_as_ack                       ;
    // wire                                    w_mac4_as_ack                       ;
    // wire                                    w_mac5_as_ack                       ;
    // wire                                    w_mac6_as_ack                       ;
    // wire                                    w_mac7_as_ack                       ;
`endif

`ifdef LLDP
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    wire   [CROSS_DATA_WIDTH:0]             w_lldp_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_lldp_cross_axi_data_keep          ; // 端口数据流掩码，有效字节指示
    wire                                    w_lldp_cross_axi_data_valid         ; // 端口数据有效
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_lldp_cross_axi_data_ready         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_lldp_cross_axi_data_last          ; // 数据流结束标识

    wire  [METADATA_WIDTH-1:0]              w_lldp_cross_metadata               ; // 总线 metadata 数据
    wire                                    w_lldp_cross_metadata_valid         ; // 总线 metadata 数据有效信号
    wire                                    w_lldp_cross_metadata_last          ; // 信息流结束标识
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_lldp_cross_metadata_ready         ; // 下游模块反压流水线 

    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_txmac_2lldp_ack       ;

    // wire                                    w_mac0_lldp_ack                     ;
    // wire                                    w_mac1_lldp_ack                     ;
    // wire                                    w_mac2_lldp_ack                     ;
    // wire                                    w_mac3_lldp_ack                     ;
    // wire                                    w_mac4_lldp_ack                     ;
    // wire                                    w_mac5_lldp_ack                     ;
    // wire                                    w_mac6_lldp_ack                     ;
    // wire                                    w_mac7_lldp_ack                     ;
`endif 


/*--------------------- reg ----------------*/
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ro_mac0_cross_axi_data_ready <= 1'b0;
            ro_mac1_cross_axi_data_ready <= 1'b0;
            ro_mac2_cross_axi_data_ready <= 1'b0;
            ro_mac3_cross_axi_data_ready <= 1'b0;
            ro_mac4_cross_axi_data_ready <= 1'b0;
            ro_mac5_cross_axi_data_ready <= 1'b0;
            ro_mac6_cross_axi_data_ready <= 1'b0;
            ro_mac7_cross_axi_data_ready <= 1'b0;
        end else begin
            ro_mac0_cross_axi_data_ready <= (w_txmac_2rxmac0_ack[0] == 1'b1 && w_txmac_2rxmac0_ack_rst[0] != 8'd0) ? w_mac0_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac0_ack[1] == 1'b1 && w_txmac_2rxmac0_ack_rst[1] != 8'd0) ? w_mac0_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac0_ack[2] == 1'b1 && w_txmac_2rxmac0_ack_rst[2] != 8'd0) ? w_mac0_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac0_ack[3] == 1'b1 && w_txmac_2rxmac0_ack_rst[3] != 8'd0) ? w_mac0_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac0_ack[4] == 1'b1 && w_txmac_2rxmac0_ack_rst[4] != 8'd0) ? w_mac0_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac0_ack[5] == 1'b1 && w_txmac_2rxmac0_ack_rst[5] != 8'd0) ? w_mac0_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac0_ack[6] == 1'b1 && w_txmac_2rxmac0_ack_rst[6] != 8'd0) ? w_mac0_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac0_ack[7] == 1'b1 && w_txmac_2rxmac0_ack_rst[7] != 8'd0) ? w_mac0_cross_axi_data_ready[7] : ro_mac0_cross_axi_data_ready;

            ro_mac1_cross_axi_data_ready <= (w_txmac_2rxmac1_ack[0] == 1'b1 && w_txmac_2rxmac1_ack_rst[0] != 8'd0) ? w_mac1_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac1_ack[1] == 1'b1 && w_txmac_2rxmac1_ack_rst[1] != 8'd0) ? w_mac1_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac1_ack[2] == 1'b1 && w_txmac_2rxmac1_ack_rst[2] != 8'd0) ? w_mac1_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac1_ack[3] == 1'b1 && w_txmac_2rxmac1_ack_rst[3] != 8'd0) ? w_mac1_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac1_ack[4] == 1'b1 && w_txmac_2rxmac1_ack_rst[4] != 8'd0) ? w_mac1_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac1_ack[5] == 1'b1 && w_txmac_2rxmac1_ack_rst[5] != 8'd0) ? w_mac1_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac1_ack[6] == 1'b1 && w_txmac_2rxmac1_ack_rst[6] != 8'd0) ? w_mac1_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac1_ack[7] == 1'b1 && w_txmac_2rxmac1_ack_rst[7] != 8'd0) ? w_mac1_cross_axi_data_ready[7] : ro_mac1_cross_axi_data_ready;

            ro_mac2_cross_axi_data_ready <= (w_txmac_2rxmac2_ack[0] == 1'b1 && w_txmac_2rxmac2_ack_rst[0] != 8'd0) ? w_mac2_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac2_ack[1] == 1'b1 && w_txmac_2rxmac2_ack_rst[1] != 8'd0) ? w_mac2_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac2_ack[2] == 1'b1 && w_txmac_2rxmac2_ack_rst[2] != 8'd0) ? w_mac2_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac2_ack[3] == 1'b1 && w_txmac_2rxmac2_ack_rst[3] != 8'd0) ? w_mac2_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac2_ack[4] == 1'b1 && w_txmac_2rxmac2_ack_rst[4] != 8'd0) ? w_mac2_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac2_ack[5] == 1'b1 && w_txmac_2rxmac2_ack_rst[5] != 8'd0) ? w_mac2_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac2_ack[6] == 1'b1 && w_txmac_2rxmac2_ack_rst[6] != 8'd0) ? w_mac2_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac2_ack[7] == 1'b1 && w_txmac_2rxmac2_ack_rst[7] != 8'd0) ? w_mac2_cross_axi_data_ready[7] : ro_mac2_cross_axi_data_ready;

            ro_mac3_cross_axi_data_ready <= (w_txmac_2rxmac3_ack[0] == 1'b1 && w_txmac_2rxmac3_ack_rst[0] != 8'd0) ? w_mac3_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac3_ack[1] == 1'b1 && w_txmac_2rxmac3_ack_rst[1] != 8'd0) ? w_mac3_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac3_ack[2] == 1'b1 && w_txmac_2rxmac3_ack_rst[2] != 8'd0) ? w_mac3_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac3_ack[3] == 1'b1 && w_txmac_2rxmac3_ack_rst[3] != 8'd0) ? w_mac3_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac3_ack[4] == 1'b1 && w_txmac_2rxmac3_ack_rst[4] != 8'd0) ? w_mac3_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac3_ack[5] == 1'b1 && w_txmac_2rxmac3_ack_rst[5] != 8'd0) ? w_mac3_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac3_ack[6] == 1'b1 && w_txmac_2rxmac3_ack_rst[6] != 8'd0) ? w_mac3_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac3_ack[7] == 1'b1 && w_txmac_2rxmac3_ack_rst[7] != 8'd0) ? w_mac3_cross_axi_data_ready[7] : ro_mac3_cross_axi_data_ready;

            ro_mac4_cross_axi_data_ready <= (w_txmac_2rxmac4_ack[0] == 1'b1 && w_txmac_2rxmac4_ack_rst[0] != 8'd0) ? w_mac4_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac4_ack[1] == 1'b1 && w_txmac_2rxmac4_ack_rst[1] != 8'd0) ? w_mac4_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac4_ack[2] == 1'b1 && w_txmac_2rxmac4_ack_rst[2] != 8'd0) ? w_mac4_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac4_ack[3] == 1'b1 && w_txmac_2rxmac4_ack_rst[3] != 8'd0) ? w_mac4_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac4_ack[4] == 1'b1 && w_txmac_2rxmac4_ack_rst[4] != 8'd0) ? w_mac4_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac4_ack[5] == 1'b1 && w_txmac_2rxmac4_ack_rst[5] != 8'd0) ? w_mac4_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac4_ack[6] == 1'b1 && w_txmac_2rxmac4_ack_rst[6] != 8'd0) ? w_mac4_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac4_ack[7] == 1'b1 && w_txmac_2rxmac4_ack_rst[7] != 8'd0) ? w_mac4_cross_axi_data_ready[7] : ro_mac4_cross_axi_data_ready;

            ro_mac5_cross_axi_data_ready <= (w_txmac_2rxmac5_ack[0] == 1'b1 && w_txmac_2rxmac5_ack_rst[0] != 8'd0) ? w_mac5_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac5_ack[1] == 1'b1 && w_txmac_2rxmac5_ack_rst[1] != 8'd0) ? w_mac5_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac5_ack[2] == 1'b1 && w_txmac_2rxmac5_ack_rst[2] != 8'd0) ? w_mac5_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac5_ack[3] == 1'b1 && w_txmac_2rxmac5_ack_rst[3] != 8'd0) ? w_mac5_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac5_ack[4] == 1'b1 && w_txmac_2rxmac5_ack_rst[4] != 8'd0) ? w_mac5_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac5_ack[5] == 1'b1 && w_txmac_2rxmac5_ack_rst[5] != 8'd0) ? w_mac5_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac5_ack[6] == 1'b1 && w_txmac_2rxmac5_ack_rst[6] != 8'd0) ? w_mac5_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac5_ack[7] == 1'b1 && w_txmac_2rxmac5_ack_rst[7] != 8'd0) ? w_mac5_cross_axi_data_ready[7] : ro_mac5_cross_axi_data_ready;

            ro_mac6_cross_axi_data_ready <= (w_txmac_2rxmac6_ack[0] == 1'b1 && w_txmac_2rxmac6_ack_rst[0] != 8'd0) ? w_mac6_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac6_ack[1] == 1'b1 && w_txmac_2rxmac6_ack_rst[1] != 8'd0) ? w_mac6_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac6_ack[2] == 1'b1 && w_txmac_2rxmac6_ack_rst[2] != 8'd0) ? w_mac6_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac6_ack[3] == 1'b1 && w_txmac_2rxmac6_ack_rst[3] != 8'd0) ? w_mac6_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac6_ack[4] == 1'b1 && w_txmac_2rxmac6_ack_rst[4] != 8'd0) ? w_mac6_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac6_ack[5] == 1'b1 && w_txmac_2rxmac6_ack_rst[5] != 8'd0) ? w_mac6_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac6_ack[6] == 1'b1 && w_txmac_2rxmac6_ack_rst[6] != 8'd0) ? w_mac6_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac6_ack[7] == 1'b1 && w_txmac_2rxmac6_ack_rst[7] != 8'd0) ? w_mac6_cross_axi_data_ready[7] : ro_mac6_cross_axi_data_ready;

            ro_mac7_cross_axi_data_ready <= (w_txmac_2rxmac7_ack[0] == 1'b1 && w_txmac_2rxmac7_ack_rst[0] != 8'd0) ? w_mac7_cross_axi_data_ready[0] :   
                                            (w_txmac_2rxmac7_ack[1] == 1'b1 && w_txmac_2rxmac7_ack_rst[1] != 8'd0) ? w_mac7_cross_axi_data_ready[1] : 
                                            (w_txmac_2rxmac7_ack[2] == 1'b1 && w_txmac_2rxmac7_ack_rst[2] != 8'd0) ? w_mac7_cross_axi_data_ready[2] :   
                                            (w_txmac_2rxmac7_ack[3] == 1'b1 && w_txmac_2rxmac7_ack_rst[3] != 8'd0) ? w_mac7_cross_axi_data_ready[3] : 
                                            (w_txmac_2rxmac7_ack[4] == 1'b1 && w_txmac_2rxmac7_ack_rst[4] != 8'd0) ? w_mac7_cross_axi_data_ready[4] :   
                                            (w_txmac_2rxmac7_ack[5] == 1'b1 && w_txmac_2rxmac7_ack_rst[5] != 8'd0) ? w_mac7_cross_axi_data_ready[5] : 
                                            (w_txmac_2rxmac7_ack[6] == 1'b1 && w_txmac_2rxmac7_ack_rst[6] != 8'd0) ? w_mac7_cross_axi_data_ready[6] :   
                                            (w_txmac_2rxmac7_ack[7] == 1'b1 && w_txmac_2rxmac7_ack_rst[7] != 8'd0) ? w_mac7_cross_axi_data_ready[7] : ro_mac7_cross_axi_data_ready;                                                                                                                                                                                                                            
        end
    end
/*--------------------- assign ----------------*/
`ifdef CPU_MAC
    assign     w_mac0_cross_port_axi_data      =   i_mac0_cross_port_axi_data  ;  
    assign     w_mac0_cross_axi_data_keep      =   i_mac0_cross_axi_data_keep  ; 
    assign     w_mac0_cross_axi_data_user      =   i_mac0_cross_axi_data_user  ;   
    assign     w_mac0_cross_axi_data_valid     =   i_mac0_cross_axi_data_valid ;  
    assign     o_mac0_cross_axi_data_ready     =   ro_mac0_cross_axi_data_ready;                                          
    assign     w_mac0_cross_axi_data_last      =   i_mac0_cross_axi_data_last  ; 

    assign     w_mac0_cross_metadata           =   i_mac0_cross_metadata       ;
    assign     w_mac0_cross_metadata_valid     =   i_mac0_cross_metadata_valid ;
    assign     w_mac0_cross_metadata_last      =   i_mac0_cross_metadata_last  ;
    assign     o_mac0_cross_metadata_ready     =   w_mac0_cross_metadata_ready[0];

    assign     o_mac0_tx0_ack                  =   w_txmac_2rxmac0_ack      [0]   ;
    assign     o_mac0_tx0_ack_rst              =   w_txmac_2rxmac0_ack_rst  [0]   ;
    assign     o_mac0_tx1_ack                  =   w_txmac_2rxmac0_ack      [1]   ;
    assign     o_mac0_tx1_ack_rst              =   w_txmac_2rxmac0_ack_rst  [1]   ;
    assign     o_mac0_tx2_ack                  =   w_txmac_2rxmac0_ack      [2]   ;
    assign     o_mac0_tx2_ack_rst              =   w_txmac_2rxmac0_ack_rst  [2]   ;
    assign     o_mac0_tx3_ack                  =   w_txmac_2rxmac0_ack      [3]   ;
    assign     o_mac0_tx3_ack_rst              =   w_txmac_2rxmac0_ack_rst  [3]   ;
    assign     o_mac0_tx4_ack                  =   w_txmac_2rxmac0_ack      [4]   ;
    assign     o_mac0_tx4_ack_rst              =   w_txmac_2rxmac0_ack_rst  [4]   ;
    assign     o_mac0_tx5_ack                  =   w_txmac_2rxmac0_ack      [5]   ;
    assign     o_mac0_tx5_ack_rst              =   w_txmac_2rxmac0_ack_rst  [5]   ;
    assign     o_mac0_tx6_ack                  =   w_txmac_2rxmac0_ack      [6]   ;
    assign     o_mac0_tx6_ack_rst              =   w_txmac_2rxmac0_ack_rst  [6]   ;
    assign     o_mac0_tx7_ack                  =   w_txmac_2rxmac0_ack      [7]   ;
    assign     o_mac0_tx7_ack_rst              =   w_txmac_2rxmac0_ack_rst  [7]   ;

`endif

`ifdef MAC1
    assign     w_mac1_cross_port_axi_data      =   i_mac1_cross_port_axi_data  ;  
    assign     w_mac1_cross_axi_data_keep      =   i_mac1_cross_axi_data_keep  ; 
    assign     w_mac1_cross_axi_data_user      =   i_mac1_cross_axi_data_user  ; 
    assign     w_mac1_cross_axi_data_valid     =   i_mac1_cross_axi_data_valid ;  
    assign     o_mac1_cross_axi_data_ready     =   ro_mac1_cross_axi_data_ready;  
    assign     w_mac1_cross_axi_data_last      =   i_mac1_cross_axi_data_last  ; 

    assign     w_mac1_cross_metadata           =   i_mac1_cross_metadata       ;
    assign     w_mac1_cross_metadata_valid     =   i_mac1_cross_metadata_valid ;
    assign     w_mac1_cross_metadata_last      =   i_mac1_cross_metadata_last  ;
    assign     o_mac1_cross_metadata_ready     =   w_mac1_cross_metadata_ready[0];

    assign     o_mac1_tx0_ack                  =   w_txmac_2rxmac1_ack      [0]   ;
    assign     o_mac1_tx0_ack_rst              =   w_txmac_2rxmac1_ack_rst  [0]   ;
    assign     o_mac1_tx1_ack                  =   w_txmac_2rxmac1_ack      [1]   ;
    assign     o_mac1_tx1_ack_rst              =   w_txmac_2rxmac1_ack_rst  [1]   ;
    assign     o_mac1_tx2_ack                  =   w_txmac_2rxmac1_ack      [2]   ;
    assign     o_mac1_tx2_ack_rst              =   w_txmac_2rxmac1_ack_rst  [2]   ;
    assign     o_mac1_tx3_ack                  =   w_txmac_2rxmac1_ack      [3]   ;
    assign     o_mac1_tx3_ack_rst              =   w_txmac_2rxmac1_ack_rst  [3]   ;
    assign     o_mac1_tx4_ack                  =   w_txmac_2rxmac1_ack      [4]   ;
    assign     o_mac1_tx4_ack_rst              =   w_txmac_2rxmac1_ack_rst  [4]   ;
    assign     o_mac1_tx5_ack                  =   w_txmac_2rxmac1_ack      [5]   ;
    assign     o_mac1_tx5_ack_rst              =   w_txmac_2rxmac1_ack_rst  [5]   ;
    assign     o_mac1_tx6_ack                  =   w_txmac_2rxmac1_ack      [6]   ;
    assign     o_mac1_tx6_ack_rst              =   w_txmac_2rxmac1_ack_rst  [6]   ;
    assign     o_mac1_tx7_ack                  =   w_txmac_2rxmac1_ack      [7]   ;
    assign     o_mac1_tx7_ack_rst              =   w_txmac_2rxmac1_ack_rst  [7]   ;
`endif

`ifdef MAC2
    assign     w_mac2_cross_port_axi_data      =   i_mac2_cross_port_axi_data  ;  
    assign     w_mac2_cross_axi_data_keep      =   i_mac2_cross_axi_data_keep  ;  
    assign     w_mac2_cross_axi_data_user      =   i_mac2_cross_axi_data_user  ; 
    assign     w_mac2_cross_axi_data_valid     =   i_mac2_cross_axi_data_valid ;  
    assign     o_mac2_cross_axi_data_ready     =   ro_mac2_cross_axi_data_ready ;  
    assign     w_mac2_cross_axi_data_last      =   i_mac2_cross_axi_data_last  ; 

    assign     w_mac2_cross_metadata           =   i_mac2_cross_metadata       ;
    assign     w_mac2_cross_metadata_valid     =   i_mac2_cross_metadata_valid ;
    assign     w_mac2_cross_metadata_last      =   i_mac2_cross_metadata_last  ;
    assign     o_mac2_cross_metadata_ready     =   w_mac2_cross_metadata_ready[0] ;

    assign     o_mac2_tx0_ack                  =   w_txmac_2rxmac2_ack      [0]   ;
    assign     o_mac2_tx0_ack_rst              =   w_txmac_2rxmac2_ack_rst  [0]   ;
    assign     o_mac2_tx1_ack                  =   w_txmac_2rxmac2_ack      [1]   ;
    assign     o_mac2_tx1_ack_rst              =   w_txmac_2rxmac2_ack_rst  [1]   ;
    assign     o_mac2_tx2_ack                  =   w_txmac_2rxmac2_ack      [2]   ;
    assign     o_mac2_tx2_ack_rst              =   w_txmac_2rxmac2_ack_rst  [2]   ;
    assign     o_mac2_tx3_ack                  =   w_txmac_2rxmac2_ack      [3]   ;
    assign     o_mac2_tx3_ack_rst              =   w_txmac_2rxmac2_ack_rst  [3]   ;
    assign     o_mac2_tx4_ack                  =   w_txmac_2rxmac2_ack      [4]   ;
    assign     o_mac2_tx4_ack_rst              =   w_txmac_2rxmac2_ack_rst  [4]   ;
    assign     o_mac2_tx5_ack                  =   w_txmac_2rxmac2_ack      [5]   ;
    assign     o_mac2_tx5_ack_rst              =   w_txmac_2rxmac2_ack_rst  [5]   ;
    assign     o_mac2_tx6_ack                  =   w_txmac_2rxmac2_ack      [6]   ;
    assign     o_mac2_tx6_ack_rst              =   w_txmac_2rxmac2_ack_rst  [6]   ;
    assign     o_mac2_tx7_ack                  =   w_txmac_2rxmac2_ack      [7]   ;
    assign     o_mac2_tx7_ack_rst              =   w_txmac_2rxmac2_ack_rst  [7]   ;

`endif

`ifdef MAC3
    assign     w_mac3_cross_port_axi_data      =   i_mac3_cross_port_axi_data  ;  
    assign     w_mac3_cross_axi_data_keep      =   i_mac3_cross_axi_data_keep  ; 
    assign     w_mac3_cross_axi_data_user      =   i_mac3_cross_axi_data_user  ;  
    assign     w_mac3_cross_axi_data_valid     =   i_mac3_cross_axi_data_valid ;  
    assign     o_mac3_cross_axi_data_ready     =   ro_mac3_cross_axi_data_ready ;  
    assign     w_mac3_cross_axi_data_last      =   i_mac3_cross_axi_data_last  ; 

    assign     w_mac3_cross_metadata           =   i_mac3_cross_metadata       ;
    assign     w_mac3_cross_metadata_valid     =   i_mac3_cross_metadata_valid ;
    assign     w_mac3_cross_metadata_last      =   i_mac3_cross_metadata_last  ;
    assign     o_mac3_cross_metadata_ready     =   w_mac3_cross_metadata_ready[0] ;

    assign     o_mac3_tx0_ack                  =   w_txmac_2rxmac3_ack      [0]   ;
    assign     o_mac3_tx0_ack_rst              =   w_txmac_2rxmac3_ack_rst  [0]   ;
    assign     o_mac3_tx1_ack                  =   w_txmac_2rxmac3_ack      [1]   ;
    assign     o_mac3_tx1_ack_rst              =   w_txmac_2rxmac3_ack_rst  [1]   ;
    assign     o_mac3_tx2_ack                  =   w_txmac_2rxmac3_ack      [2]   ;
    assign     o_mac3_tx2_ack_rst              =   w_txmac_2rxmac3_ack_rst  [2]   ;
    assign     o_mac3_tx3_ack                  =   w_txmac_2rxmac3_ack      [3]   ;
    assign     o_mac3_tx3_ack_rst              =   w_txmac_2rxmac3_ack_rst  [3]   ;
    assign     o_mac3_tx4_ack                  =   w_txmac_2rxmac3_ack      [4]   ;
    assign     o_mac3_tx4_ack_rst              =   w_txmac_2rxmac3_ack_rst  [4]   ;
    assign     o_mac3_tx5_ack                  =   w_txmac_2rxmac3_ack      [5]   ;
    assign     o_mac3_tx5_ack_rst              =   w_txmac_2rxmac3_ack_rst  [5]   ;
    assign     o_mac3_tx6_ack                  =   w_txmac_2rxmac3_ack      [6]   ;
    assign     o_mac3_tx6_ack_rst              =   w_txmac_2rxmac3_ack_rst  [6]   ;
    assign     o_mac3_tx7_ack                  =   w_txmac_2rxmac3_ack      [7]   ;
    assign     o_mac3_tx7_ack_rst              =   w_txmac_2rxmac3_ack_rst  [7]   ;
`endif

`ifdef MAC4
    assign     w_mac4_cross_port_axi_data      =   i_mac4_cross_port_axi_data  ;  
    assign     w_mac4_cross_axi_data_keep      =   i_mac4_cross_axi_data_keep  ;  
    assign     w_mac4_cross_axi_data_user      =   i_mac4_cross_axi_data_user  ; 
    assign     w_mac4_cross_axi_data_valid     =   i_mac4_cross_axi_data_valid ;  
    assign     o_mac4_cross_axi_data_ready     =   ro_mac4_cross_axi_data_ready ;  
    assign     w_mac4_cross_axi_data_last      =   i_mac4_cross_axi_data_last  ; 

    assign     w_mac4_cross_metadata           =   i_mac4_cross_metadata       ;
    assign     w_mac4_cross_metadata_valid     =   i_mac4_cross_metadata_valid ;
    assign     w_mac4_cross_metadata_last      =   i_mac4_cross_metadata_last  ;
    assign     o_mac4_cross_metadata_ready     =   w_mac4_cross_metadata_ready[0] ;

    assign     o_mac4_tx0_ack                  =   w_txmac_2rxmac4_ack      [0]   ;
    assign     o_mac4_tx0_ack_rst              =   w_txmac_2rxmac4_ack_rst  [0]   ;
    assign     o_mac4_tx1_ack                  =   w_txmac_2rxmac4_ack      [1]   ;
    assign     o_mac4_tx1_ack_rst              =   w_txmac_2rxmac4_ack_rst  [1]   ;
    assign     o_mac4_tx2_ack                  =   w_txmac_2rxmac4_ack      [2]   ;
    assign     o_mac4_tx2_ack_rst              =   w_txmac_2rxmac4_ack_rst  [2]   ;
    assign     o_mac4_tx3_ack                  =   w_txmac_2rxmac4_ack      [3]   ;
    assign     o_mac4_tx3_ack_rst              =   w_txmac_2rxmac4_ack_rst  [3]   ;
    assign     o_mac4_tx4_ack                  =   w_txmac_2rxmac4_ack      [4]   ;
    assign     o_mac4_tx4_ack_rst              =   w_txmac_2rxmac4_ack_rst  [4]   ;
    assign     o_mac4_tx5_ack                  =   w_txmac_2rxmac4_ack      [5]   ;
    assign     o_mac4_tx5_ack_rst              =   w_txmac_2rxmac4_ack_rst  [5]   ;
    assign     o_mac4_tx6_ack                  =   w_txmac_2rxmac4_ack      [6]   ;
    assign     o_mac4_tx6_ack_rst              =   w_txmac_2rxmac4_ack_rst  [6]   ;
    assign     o_mac4_tx7_ack                  =   w_txmac_2rxmac4_ack      [7]   ;
    assign     o_mac4_tx7_ack_rst              =   w_txmac_2rxmac4_ack_rst  [7]   ;
`endif

`ifdef MAC5
    assign     w_mac5_cross_port_axi_data      =   i_mac5_cross_port_axi_data  ;  
    assign     w_mac5_cross_axi_data_keep      =   i_mac5_cross_axi_data_keep  ;  
    assign     w_mac5_cross_axi_data_user      =   i_mac5_cross_axi_data_user  ; 
    assign     w_mac5_cross_axi_data_valid     =   i_mac5_cross_axi_data_valid ;  
    assign     o_mac5_cross_axi_data_ready     =   ro_mac5_cross_axi_data_ready;  
    assign     w_mac5_cross_axi_data_last      =   i_mac5_cross_axi_data_last  ; 

    assign     w_mac5_cross_metadata           =   i_mac5_cross_metadata       ;
    assign     w_mac5_cross_metadata_valid     =   i_mac5_cross_metadata_valid ;
    assign     w_mac5_cross_metadata_last      =   i_mac5_cross_metadata_last  ;
    assign     o_mac5_cross_metadata_ready     =   w_mac5_cross_metadata_ready[0] ;

    assign     o_mac5_tx0_ack                  =   w_txmac_2rxmac5_ack      [0]   ;
    assign     o_mac5_tx0_ack_rst              =   w_txmac_2rxmac5_ack_rst  [0]   ;
    assign     o_mac5_tx1_ack                  =   w_txmac_2rxmac5_ack      [1]   ;
    assign     o_mac5_tx1_ack_rst              =   w_txmac_2rxmac5_ack_rst  [1]   ;
    assign     o_mac5_tx2_ack                  =   w_txmac_2rxmac5_ack      [2]   ;
    assign     o_mac5_tx2_ack_rst              =   w_txmac_2rxmac5_ack_rst  [2]   ;
    assign     o_mac5_tx3_ack                  =   w_txmac_2rxmac5_ack      [3]   ;
    assign     o_mac5_tx3_ack_rst              =   w_txmac_2rxmac5_ack_rst  [3]   ;
    assign     o_mac5_tx4_ack                  =   w_txmac_2rxmac5_ack      [4]   ;
    assign     o_mac5_tx4_ack_rst              =   w_txmac_2rxmac5_ack_rst  [4]   ;
    assign     o_mac5_tx5_ack                  =   w_txmac_2rxmac5_ack      [5]   ;
    assign     o_mac5_tx5_ack_rst              =   w_txmac_2rxmac5_ack_rst  [5]   ;
    assign     o_mac5_tx6_ack                  =   w_txmac_2rxmac5_ack      [6]   ;
    assign     o_mac5_tx6_ack_rst              =   w_txmac_2rxmac5_ack_rst  [6]   ;
    assign     o_mac5_tx7_ack                  =   w_txmac_2rxmac5_ack      [7]   ;
    assign     o_mac5_tx7_ack_rst              =   w_txmac_2rxmac5_ack_rst  [7]   ;
`endif

`ifdef MAC6
    assign     w_mac6_cross_port_axi_data      =   i_mac6_cross_port_axi_data  ;  
    assign     w_mac6_cross_axi_data_keep      =   i_mac6_cross_axi_data_keep  ;  
    assign     w_mac6_cross_axi_data_user      =   i_mac6_cross_axi_data_user  ; 
    assign     w_mac6_cross_axi_data_valid     =   i_mac6_cross_axi_data_valid ;  
    assign     o_mac6_cross_axi_data_ready     =   ro_mac6_cross_axi_data_ready;  
    assign     w_mac6_cross_axi_data_last      =   i_mac6_cross_axi_data_last  ; 

    assign     w_mac6_cross_metadata           =   i_mac6_cross_metadata       ;
    assign     w_mac6_cross_metadata_valid     =   i_mac6_cross_metadata_valid ;
    assign     w_mac6_cross_metadata_last      =   i_mac6_cross_metadata_last  ;
    assign     o_mac6_cross_metadata_ready     =   w_mac6_cross_metadata_ready[0] ;

    assign     o_mac6_tx0_ack                  =   w_txmac_2rxmac6_ack      [0]   ;
    assign     o_mac6_tx0_ack_rst              =   w_txmac_2rxmac6_ack_rst  [0]   ;
    assign     o_mac6_tx1_ack                  =   w_txmac_2rxmac6_ack      [1]   ;
    assign     o_mac6_tx1_ack_rst              =   w_txmac_2rxmac6_ack_rst  [1]   ;
    assign     o_mac6_tx2_ack                  =   w_txmac_2rxmac6_ack      [2]   ;
    assign     o_mac6_tx2_ack_rst              =   w_txmac_2rxmac6_ack_rst  [2]   ;
    assign     o_mac6_tx3_ack                  =   w_txmac_2rxmac6_ack      [3]   ;
    assign     o_mac6_tx3_ack_rst              =   w_txmac_2rxmac6_ack_rst  [3]   ;
    assign     o_mac6_tx4_ack                  =   w_txmac_2rxmac6_ack      [4]   ;
    assign     o_mac6_tx4_ack_rst              =   w_txmac_2rxmac6_ack_rst  [4]   ;
    assign     o_mac6_tx5_ack                  =   w_txmac_2rxmac6_ack      [5]   ;
    assign     o_mac6_tx5_ack_rst              =   w_txmac_2rxmac6_ack_rst  [5]   ;
    assign     o_mac6_tx6_ack                  =   w_txmac_2rxmac6_ack      [6]   ;
    assign     o_mac6_tx6_ack_rst              =   w_txmac_2rxmac6_ack_rst  [6]   ;
    assign     o_mac6_tx7_ack                  =   w_txmac_2rxmac6_ack      [7]   ;
    assign     o_mac6_tx7_ack_rst              =   w_txmac_2rxmac6_ack_rst  [7]   ;
`endif

`ifdef MAC7
    assign     w_mac7_cross_port_axi_data      =   i_mac7_cross_port_axi_data  ;  
    assign     w_mac7_cross_axi_data_keep      =   i_mac7_cross_axi_data_keep  ;  
    assign     w_mac7_cross_axi_data_user      =   i_mac7_cross_axi_data_user  ; 
    assign     w_mac7_cross_axi_data_valid     =   i_mac7_cross_axi_data_valid ;  
    assign     o_mac7_cross_axi_data_ready     =   ro_mac7_cross_axi_data_ready;  
    assign     w_mac7_cross_axi_data_last      =   i_mac7_cross_axi_data_last  ; 

    assign     w_mac7_cross_metadata           =   i_mac7_cross_metadata       ;
    assign     w_mac7_cross_metadata_valid     =   i_mac7_cross_metadata_valid ;
    assign     w_mac7_cross_metadata_last      =   i_mac7_cross_metadata_last  ;
    assign     o_mac7_cross_metadata_ready     =   w_mac7_cross_metadata_ready[0] ;

    assign     o_mac7_tx0_ack                  =   w_txmac_2rxmac7_ack      [0]   ;
    assign     o_mac7_tx0_ack_rst              =   w_txmac_2rxmac7_ack_rst  [0]   ;
    assign     o_mac7_tx1_ack                  =   w_txmac_2rxmac7_ack      [1]   ;
    assign     o_mac7_tx1_ack_rst              =   w_txmac_2rxmac7_ack_rst  [1]   ;
    assign     o_mac7_tx2_ack                  =   w_txmac_2rxmac7_ack      [2]   ;
    assign     o_mac7_tx2_ack_rst              =   w_txmac_2rxmac7_ack_rst  [2]   ;
    assign     o_mac7_tx3_ack                  =   w_txmac_2rxmac7_ack      [3]   ;
    assign     o_mac7_tx3_ack_rst              =   w_txmac_2rxmac7_ack_rst  [3]   ;
    assign     o_mac7_tx4_ack                  =   w_txmac_2rxmac7_ack      [4]   ;
    assign     o_mac7_tx4_ack_rst              =   w_txmac_2rxmac7_ack_rst  [4]   ;
    assign     o_mac7_tx5_ack                  =   w_txmac_2rxmac7_ack      [5]   ;
    assign     o_mac7_tx5_ack_rst              =   w_txmac_2rxmac7_ack_rst  [5]   ;
    assign     o_mac7_tx6_ack                  =   w_txmac_2rxmac7_ack      [6]   ;
    assign     o_mac7_tx6_ack_rst              =   w_txmac_2rxmac7_ack_rst  [6]   ;
    assign     o_mac7_tx7_ack                  =   w_txmac_2rxmac7_ack      [7]   ;
    assign     o_mac7_tx7_ack_rst              =   w_txmac_2rxmac7_ack_rst  [7]   ;
`endif
`ifdef TSN_AS
    assign     w_tsn_as_cross_port_axi_data     =   i_tsn_as_cross_port_axi_data  ;
    assign     w_tsn_as_cross_axi_data_keep     =   i_tsn_as_cross_axi_data_keep  ;
    assign     w_tsn_as_cross_axi_data_user      =   i_tsn_as_cross_axi_data_user  ; 
    assign     w_tsn_as_cross_axi_data_valid    =   i_tsn_as_cross_axi_data_valid ;
    assign     o_tsn_as_cross_axi_data_ready    =   w_tsn_as_cross_axi_data_ready[0] ;
    assign     w_tsn_as_cross_axi_data_last     =   i_tsn_as_cross_axi_data_last  ;
    assign     w_tsn_as_cross_metadata          =   i_tsn_as_cross_metadata       ;
    assign     w_tsn_as_cross_metadata_valid    =   i_tsn_as_cross_metadata_valid ;
    assign     w_tsn_as_cross_metadata_last     =   i_tsn_as_cross_metadata_last  ;
    assign     o_tsn_as_cross_metadata_ready    =   w_tsn_as_cross_metadata_ready[0] ;

    // assign     o_tsn_as_tx_ack                  =   1'b0;
`endif
`ifdef LLDP
    assign     w_lldp_cross_port_axi_data      =    i_lldp_cross_port_axi_data    ;
    assign     w_lldp_cross_axi_data_keep      =    i_lldp_cross_axi_data_keep    ;
    assign     w_lldp_cross_axi_data_user      =    i_lldp_cross_axi_data_user  ;
    assign     w_lldp_cross_axi_data_valid     =    i_lldp_cross_axi_data_valid   ;
    assign     o_lldp_cross_axi_data_ready     =    w_lldp_cross_axi_data_ready[0];
    assign     w_lldp_cross_axi_data_last      =    i_lldp_cross_axi_data_last    ;  
    assign     w_lldp_cross_metadata           =    i_lldp_cross_metadata         ;  
    assign     w_lldp_cross_metadata_valid     =    i_lldp_cross_metadata_valid   ;  
    assign     w_lldp_cross_metadata_last      =    i_lldp_cross_metadata_last    ;  
    assign     o_lldp_cross_metadata_ready     =    w_lldp_cross_metadata_ready[0];

    // assign     o_lldp_tx_ack                   =    1'b0;

`endif

    assign      o_mac0_fifoc_empty             =    w_mac0_fifoc_empty;
    assign      o_mac1_fifoc_empty             =    w_mac1_fifoc_empty;
    assign      o_mac2_fifoc_empty             =    w_mac2_fifoc_empty;
    assign      o_mac3_fifoc_empty             =    w_mac3_fifoc_empty;
    assign      o_mac4_fifoc_empty             =    w_mac4_fifoc_empty;
    assign      o_mac5_fifoc_empty             =    w_mac5_fifoc_empty;
    assign      o_mac6_fifoc_empty             =    w_mac6_fifoc_empty;
    assign      o_mac7_fifoc_empty             =    w_mac7_fifoc_empty;


    //EMAC0
    assign     o_rxmac0_qbu_axis_ready      =   1'b1;
    assign     o_rxmac0_qbu_metadata_ready  =   1'b1;
    // emac1
    assign     o_rxmac1_qbu_axis_ready      =   1'b1;
    assign     o_rxmac1_qbu_metadata_ready  =   1'b1;
    //
    // emac2//
    assign     o_rxmac2_qbu_axis_ready      =   1'b1;
    assign     o_rxmac2_qbu_metadata_ready  =   1'b1;
    //
    // emac3//
    assign     o_rxmac3_qbu_axis_ready      =   1'b1;
    assign     o_rxmac3_qbu_metadata_ready  =   1'b1;
    //
    // emac4//
    assign     o_rxmac4_qbu_axis_ready      =   1'b1;
    assign     o_rxmac4_qbu_metadata_ready  =   1'b1;
    //
    // emac5//
    assign     o_rxmac5_qbu_axis_ready      =   1'b1;
    assign     o_rxmac5_qbu_metadata_ready  =   1'b1;
    //
    // emac6//
    assign     o_rxmac6_qbu_axis_ready      =   1'b1;
    assign     o_rxmac6_qbu_metadata_ready  =   1'b1;
    //
    // emac7//
    assign     o_rxmac7_qbu_axis_ready      =   1'b1;
    assign     o_rxmac7_qbu_metadata_ready  =   1'b1;

/*---------------------tx0 port inst ----------------*/
`ifdef CPU_MAC
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( CPU_MAC_ATTRIBUTE             )         ,
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
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) ,    
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[0]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[0]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[0]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[0]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[0]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[0]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[0]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[0]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user  ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[0]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[0]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[0]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[0]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[0]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[0]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[0]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[0]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[0]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[0]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user  ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[0]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[0]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[0] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[0] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[0]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user  ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[0] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[0] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[0]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac0_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac0_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac0_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac0_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac0_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac0_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac0_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac0_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac0_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac0_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac0_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac0_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac0_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac0_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac0_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif

/*---------------------tx1 port inst ----------------*/
`ifdef MAC1
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC1_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac1_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[1]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[1]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[1]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[1]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[1]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[1]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[1]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[1]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[1]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[1]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[1]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[1]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[1]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[1]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[1]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[1]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[1]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[1]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[1]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[1]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[1] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[1] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[1]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[1] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[1] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[1]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac1_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac1_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac1_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac1_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac1_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac1_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac1_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac1_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac1_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac1_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac1_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac1_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac1_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac1_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac1_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif


/*---------------------tx2 port inst ----------------*/
`ifdef MAC2
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC2_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac2_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[2]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[2]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[2]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[2]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[2]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[2]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[2]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[2]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[2]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[2]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[2]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[2]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[2]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[2]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[2]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[2]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[2]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[2]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[2]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[2]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[2] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[2] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[2]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[2] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[2] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[2]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac2_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac2_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac2_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac2_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac2_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac2_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac2_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac2_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac2_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac2_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac2_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac2_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac2_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac2_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac2_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif

/*---------------------tx3 port inst ----------------*/
`ifdef MAC3
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC3_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac3_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[3]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[3]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[3]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[3]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[3]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[3]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[3]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[3]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[3]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[3]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[3]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[3]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[3]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[3]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[3]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[3]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[3]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[3]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[3]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[3]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[3] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[3] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[3]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[3] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[3] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[3]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac3_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac3_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac3_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac3_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac3_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac3_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac3_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac3_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac3_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac3_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac3_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac3_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac3_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac3_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac3_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif

/*---------------------tx4 port inst ----------------*/
`ifdef MAC4
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC4_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac4_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[4]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[4]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[4]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[4]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[4]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[4]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[4]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[4]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[4]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[4]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[4]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[4]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[4]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[4]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[4]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[4]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[4]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[4]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[4]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[4]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[4] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[4] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[4]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[4] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[4] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[4]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac4_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac4_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac4_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac4_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac4_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac4_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac4_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac4_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac4_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac4_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac4_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac4_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac4_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac4_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac4_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif


/*---------------------tx5 port inst ----------------*/
`ifdef MAC5
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC5_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac5_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[5]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[5]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[5]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[5]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[5]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[5]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[5]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[5]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[5]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[5]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[5]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[5]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[5]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[5]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[5]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[5]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[5]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[5]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[5]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[5]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[5] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[5] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[5]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[5] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[5] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[5]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac5_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac5_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac5_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac5_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac5_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac5_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac5_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac5_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac5_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac5_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac5_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac5_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac5_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac5_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac5_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif

/*---------------------tx6 port inst ----------------*/
`ifdef MAC6
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC6_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac6_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[6]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[6]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[6]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[6]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[6]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[6]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[6]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[6]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[6]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[6]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[6]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[6]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[6]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[6]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[6]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[6]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[6]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[6]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[6]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[6]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[6] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[6] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[6]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[6] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[6] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[6]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac6_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac6_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac6_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac6_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac6_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac6_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac6_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac6_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac6_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac6_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac6_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac6_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac6_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac6_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac6_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif

/*---------------------tx7 port inst ----------------*/
`ifdef MAC7
    cross_bar_txport_mnt #(
            .PORT_ATTRIBUTE                 ( MAC7_ATTRIBUTE             )         ,
            .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH            )         ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH                 ( METADATA_WIDTH                )         ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH           )         ,
            .PORT_FIFO_PRI_NUM              ( PORT_FIFO_PRI_NUM             )         , 
            .CROSS_DATA_WIDTH               ( CROSS_DATA_WIDTH              )          // 聚合总线输出 
    )crossbar_mac7_txport_mnt (
        /*-------------------- RXMAC 输入数据流 -----------------------*/
    `ifdef CPU_MAC
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac0_cross_port_axi_data         ( w_mac0_cross_port_axi_data    ) , // 端口数据流，最高位表示crcerr
        .i_mac0_cross_axi_data_keep         ( w_mac0_cross_axi_data_keep    ) , // 端口数据流掩码，有效字节指示
        .i_mac0_cross_axi_data_user         ( w_mac0_cross_axi_data_user    ) , 
        .i_mac0_cross_axi_data_valid        ( w_mac0_cross_axi_data_valid   ) , // 端口数据有效
        .o_mac0_cross_axi_data_ready        ( w_mac0_cross_axi_data_ready[7]) , // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_last         ( w_mac0_cross_axi_data_last    ) , // 数据流结束标识
        
        .i_mac0_cross_metadata              ( w_mac0_cross_metadata         ) , // 总线 metadata 数据
        .i_mac0_cross_metadata_valid        ( w_mac0_cross_metadata_valid   ) , // 总线 metadata 数据有效信号
        .i_mac0_cross_metadata_last         ( w_mac0_cross_metadata_last    ) , // 信息流结束标识
        .o_mac0_cross_metadata_ready        ( w_mac0_cross_metadata_ready[7]) , // 下游模块反压流水线 

        .i_tx0_req                          ( i_tx0_req                     ) ,
        .o_tx0_ack                          ( w_txmac_2rxmac0_ack[7]        ) ,
        .o_tx0_ack_rst                      ( w_txmac_2rxmac0_ack_rst[7]    ) ,

        .i_rxmac0_qbu_axis_data             (i_rxmac0_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac0_qbu_axis_keep             (i_rxmac0_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_user             (i_rxmac0_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac0_qbu_axis_valid            (i_rxmac0_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac0_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac0_qbu_axis_last             (i_rxmac0_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac0_qbu_metadata              (i_rxmac0_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac0_qbu_metadata_valid        (i_rxmac0_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac0_qbu_metadata_last         (i_rxmac0_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac0_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC1
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac1_cross_port_axi_data         ( w_mac1_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac1_cross_axi_data_keep         ( w_mac1_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac1_cross_axi_data_user         ( w_mac1_cross_axi_data_user    ) , 
        .i_mac1_cross_axi_data_valid        ( w_mac1_cross_axi_data_valid ) , // 端口数据有效
        .o_mac1_cross_axi_data_ready        ( w_mac1_cross_axi_data_ready[7]) , // 交叉总线聚合架构反压流水线信号
        .i_mac1_cross_axi_data_last         ( w_mac1_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac1_cross_metadata              ( w_mac1_cross_metadata       ) , // 总线 metadata 数据
        .i_mac1_cross_metadata_valid        ( w_mac1_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac1_cross_metadata_last         ( w_mac1_cross_metadata_last  ) , // 信息流结束标识
        .o_mac1_cross_metadata_ready        ( w_mac1_cross_metadata_ready[7]) , // 下游模块反压流水线 

        .i_tx1_req                          ( i_tx1_req                   ) ,
        .o_tx1_ack                          ( w_txmac_2rxmac1_ack[7]      ) ,
        .o_tx1_ack_rst                      ( w_txmac_2rxmac1_ack_rst[7]  ) ,

        .i_rxmac1_qbu_axis_data             (i_rxmac1_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac1_qbu_axis_keep             (i_rxmac1_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_user             (i_rxmac1_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac1_qbu_axis_valid            (i_rxmac1_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac1_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac1_qbu_axis_last             (i_rxmac1_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac1_qbu_metadata              (i_rxmac1_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac1_qbu_metadata_valid        (i_rxmac1_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac1_qbu_metadata_last         (i_rxmac1_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac1_qbu_metadata_ready        ( ) , // 下游模块反压流水线  


    `endif
    `ifdef MAC2
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac2_cross_port_axi_data         ( w_mac2_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac2_cross_axi_data_keep         ( w_mac2_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示       
        .i_mac2_cross_axi_data_user         ( w_mac2_cross_axi_data_user    ) , 
        .i_mac2_cross_axi_data_valid        ( w_mac2_cross_axi_data_valid ) , // 端口数据有效
        .o_mac2_cross_axi_data_ready        ( w_mac2_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac2_cross_axi_data_last         ( w_mac2_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_mac2_cross_metadata              ( w_mac2_cross_metadata       ) , // 总线 metadata 数据
        .i_mac2_cross_metadata_valid        ( w_mac2_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac2_cross_metadata_last         ( w_mac2_cross_metadata_last  ) , // 信息流结束标识
        .o_mac2_cross_metadata_ready        ( w_mac2_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tx2_req                          ( i_tx2_req                   ) ,
        .o_tx2_ack                          ( w_txmac_2rxmac2_ack[7]      ) ,
        .o_tx2_ack_rst                      ( w_txmac_2rxmac2_ack_rst[7]      ) ,

        .i_rxmac2_qbu_axis_data             (i_rxmac2_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac2_qbu_axis_keep             (i_rxmac2_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_user             (i_rxmac2_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac2_qbu_axis_valid            (i_rxmac2_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac2_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac2_qbu_axis_last             (i_rxmac2_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac2_qbu_metadata              (i_rxmac2_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac2_qbu_metadata_valid        (i_rxmac2_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac2_qbu_metadata_last         (i_rxmac2_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac2_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC3
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac3_cross_port_axi_data         ( w_mac3_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac3_cross_axi_data_keep         ( w_mac3_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac3_cross_axi_data_user         ( w_mac3_cross_axi_data_user    ) , 
        .i_mac3_cross_axi_data_valid        ( w_mac3_cross_axi_data_valid ) , // 端口数据有效
        .o_mac3_cross_axi_data_ready        ( w_mac3_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac3_cross_axi_data_last         ( w_mac3_cross_axi_data_last  ) , // 数据流结束标识
          
        .i_mac3_cross_metadata              ( w_mac3_cross_metadata       ) , // 总线 metadata 数据
        .i_mac3_cross_metadata_valid        ( w_mac3_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac3_cross_metadata_last         ( w_mac3_cross_metadata_last  ) , // 信息流结束标识
        .o_mac3_cross_metadata_ready        ( w_mac3_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tx3_req                          ( i_tx3_req                   ) , 
        .o_tx3_ack                          ( w_txmac_2rxmac3_ack[7]      ) ,
        .o_tx3_ack_rst                      ( w_txmac_2rxmac3_ack_rst[7]      ) ,

        .i_rxmac3_qbu_axis_data             (i_rxmac3_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac3_qbu_axis_keep             (i_rxmac3_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_user             (i_rxmac3_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac3_qbu_axis_valid            (i_rxmac3_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac3_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac3_qbu_axis_last             (i_rxmac3_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac3_qbu_metadata              (i_rxmac3_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac3_qbu_metadata_valid        (i_rxmac3_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac3_qbu_metadata_last         (i_rxmac3_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac3_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC4
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac4_cross_port_axi_data         ( w_mac4_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac4_cross_axi_data_keep         ( w_mac4_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac4_cross_axi_data_user         ( w_mac4_cross_axi_data_user    ) , 
        .i_mac4_cross_axi_data_valid        ( w_mac4_cross_axi_data_valid ) , // 端口数据有效
        .o_mac4_cross_axi_data_ready        ( w_mac4_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac4_cross_axi_data_last         ( w_mac4_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac4_cross_metadata              ( w_mac4_cross_metadata       ) , // 总线 metadata 数据
        .i_mac4_cross_metadata_valid        ( w_mac4_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac4_cross_metadata_last         ( w_mac4_cross_metadata_last  ) , // 信息流结束标识
        .o_mac4_cross_metadata_ready        ( w_mac4_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tx4_req                          ( i_tx4_req                   ) ,
        .o_tx4_ack                          ( w_txmac_2rxmac4_ack[7]      ) ,
        .o_tx4_ack_rst                      ( w_txmac_2rxmac4_ack_rst[7]      ) ,

        .i_rxmac4_qbu_axis_data             (i_rxmac4_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac4_qbu_axis_keep             (i_rxmac4_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_user             (i_rxmac4_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac4_qbu_axis_valid            (i_rxmac4_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac4_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac4_qbu_axis_last             (i_rxmac4_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac4_qbu_metadata              (i_rxmac4_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac4_qbu_metadata_valid        (i_rxmac4_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac4_qbu_metadata_last         (i_rxmac4_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac4_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC5
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac5_cross_port_axi_data         ( w_mac5_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac5_cross_axi_data_keep         ( w_mac5_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac5_cross_axi_data_user         ( w_mac5_cross_axi_data_user    ) , 
        .i_mac5_cross_axi_data_valid        ( w_mac5_cross_axi_data_valid ) , // 端口数据有效
        .o_mac5_cross_axi_data_ready        ( w_mac5_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac5_cross_axi_data_last         ( w_mac5_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac5_cross_metadata              ( w_mac5_cross_metadata       ) , // 总线 metadata 数据
        .i_mac5_cross_metadata_valid        ( w_mac5_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac5_cross_metadata_last         ( w_mac5_cross_metadata_last  ) , // 信息流结束标识
        .o_mac5_cross_metadata_ready        ( w_mac5_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tx5_req                          ( i_tx5_req                   ) ,
        .o_tx5_ack                          ( w_txmac_2rxmac5_ack[7]      ) ,
        .o_tx5_ack_rst                      ( w_txmac_2rxmac5_ack_rst[7]      ) ,

        .i_rxmac5_qbu_axis_data             (i_rxmac5_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac5_qbu_axis_keep             (i_rxmac5_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_user             (i_rxmac5_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac5_qbu_axis_valid            (i_rxmac5_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac5_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac5_qbu_axis_last             (i_rxmac5_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac5_qbu_metadata              (i_rxmac5_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac5_qbu_metadata_valid        (i_rxmac5_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac5_qbu_metadata_last         (i_rxmac5_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac5_qbu_metadata_ready        ( ) , // 下游模块反压流水线 
    `endif
    `ifdef MAC6
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac6_cross_port_axi_data         ( w_mac6_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac6_cross_axi_data_keep         ( w_mac6_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac6_cross_axi_data_user         ( w_mac6_cross_axi_data_user    ) , 
        .i_mac6_cross_axi_data_valid        ( w_mac6_cross_axi_data_valid ) , // 端口数据有效
        .o_mac6_cross_axi_data_ready        ( w_mac6_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac6_cross_axi_data_last         ( w_mac6_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac6_cross_metadata              ( w_mac6_cross_metadata       ) , // 总线 metadata 数据
        .i_mac6_cross_metadata_valid        ( w_mac6_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac6_cross_metadata_last         ( w_mac6_cross_metadata_last  ) , // 信息流结束标识
        .o_mac6_cross_metadata_ready        ( w_mac6_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tx6_req                          ( i_tx6_req                   ) ,
        .o_tx6_ack                          ( w_txmac_2rxmac6_ack[7]      ) ,
        .o_tx6_ack_rst                      ( w_txmac_2rxmac6_ack_rst[7]      ) ,

        .i_rxmac6_qbu_axis_data             (i_rxmac6_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac6_qbu_axis_keep             (i_rxmac6_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_user             (i_rxmac6_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac6_qbu_axis_valid            (i_rxmac6_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac6_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac6_qbu_axis_last             (i_rxmac6_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac6_qbu_metadata              (i_rxmac6_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac6_qbu_metadata_valid        (i_rxmac6_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac6_qbu_metadata_last         (i_rxmac6_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac6_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
    `ifdef MAC7
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_mac7_cross_axi_data_user         ( w_mac7_cross_axi_data_user    ) , 
        .i_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid ) , // 端口数据有效
        .o_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last  ) , // 数据流结束标识
         
        .i_mac7_cross_metadata              ( w_mac7_cross_metadata       ) , // 总线 metadata 数据
        .i_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last  ) , // 信息流结束标识
        .o_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tx7_req                          ( i_tx7_req                   ) ,
        .o_tx7_ack                          ( w_txmac_2rxmac7_ack[7]      ) ,
        .o_tx7_ack_rst                      ( w_txmac_2rxmac7_ack_rst[7]      ) ,

        .i_rxmac7_qbu_axis_data             (i_rxmac7_qbu_axis_data      ) , // 端口数据流，最高位表示crcerr
        .i_rxmac7_qbu_axis_keep             (i_rxmac7_qbu_axis_keep      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_user             (i_rxmac7_qbu_axis_user      ) , // 端口数据流掩码，有效字节指示
        .i_rxmac7_qbu_axis_valid            (i_rxmac7_qbu_axis_valid     ) , // 端口数据有效
        .o_rxmac7_qbu_axis_ready            (     ) , // 交叉总线聚合架构反压流水线信号
        .i_rxmac7_qbu_axis_last             (i_rxmac7_qbu_axis_last      ) , // 数据流结束标识
        
        .i_rxmac7_qbu_metadata              (i_rxmac7_qbu_metadata       ) , // 总线 metadata 数据
        .i_rxmac7_qbu_metadata_valid        (i_rxmac7_qbu_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_rxmac7_qbu_metadata_last         (i_rxmac7_qbu_metadata_last  ) , // 信息流结束标识
        .o_rxmac7_qbu_metadata_ready        ( ) , // 下游模块反压流水线 

    `endif
        /*-------------------- 特定端口转发输入数据流 -----------------------*/
    `ifdef TSN_AS
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_tsn_as_cross_port_axi_data       ( w_tsn_as_cross_port_axi_data  ) , // 端口数据流，最高位表示crcerr
        .i_tsn_as_cross_axi_data_keep       ( w_tsn_as_cross_axi_data_keep  ) , // 端口数据流掩码，有效字节指示  
        .i_tsn_as_cross_axi_data_user       ( w_tsn_as_cross_axi_data_user    ) , 
        .i_tsn_as_cross_axi_data_valid      ( w_tsn_as_cross_axi_data_valid ) , // 端口数据有效
        .o_tsn_as_cross_axi_data_ready      ( w_tsn_as_cross_axi_data_ready[7] ) , // 交叉总线聚合架构反压流水线信号
        .i_tsn_as_cross_axi_data_last       ( w_tsn_as_cross_axi_data_last  ) , // 数据流结束标识
        
        .i_tsn_as_cross_metadata            ( w_tsn_as_cross_metadata       ) , // 总线 metadata 数据
        .i_tsn_as_cross_metadata_valid      ( w_tsn_as_cross_metadata_valid ) , // 总线 metadata 数据有效信号
        .i_tsn_as_cross_metadata_last       ( w_tsn_as_cross_metadata_last  ) , // 信息流结束标识
        .o_tsn_as_cross_metadata_ready      ( w_tsn_as_cross_metadata_ready[7] ) , // 下游模块反压流水线 

        .i_tsn_as_tx_req                    ( i_tsn_as_tx_req               ) ,
        .o_tsn_as_tx_ack                    ( w_txmac_2tsn_as_ack[7]           ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .i_lldp_cross_port_axi_data         ( w_lldp_cross_port_axi_data  )  , // 端口数据流，最高位表示crcerr
        .i_lldp_cross_axi_data_keep         ( w_lldp_cross_axi_data_keep  )  , // 端口数据流掩码，有效字节指示  
        .i_lldp_cross_axi_data_user         ( w_lldp_cross_axi_data_user    ) , 
        .i_lldp_cross_axi_data_valid        ( w_lldp_cross_axi_data_valid )  , // 端口数据有效
        .o_lldp_cross_axi_data_ready        ( w_lldp_cross_axi_data_ready[7] )  , // 交叉总线聚合架构反压流水线信号
        .i_lldp_cross_axi_data_last         ( w_lldp_cross_axi_data_last  )  , // 数据流结束标识
        
        .i_lldp_cross_metadata              ( w_lldp_cross_metadata       ) ,  // 总线 metadata 数据
        .i_lldp_cross_metadata_valid        ( w_lldp_cross_metadata_valid ) ,  // 总线 metadata 数据有效信号
        .i_lldp_cross_metadata_last         ( w_lldp_cross_metadata_last  ) ,  // 信息流结束标识
        .o_lldp_cross_metadata_ready        ( w_lldp_cross_metadata_ready[7] ) ,  // 下游模块反压流水线 

        .i_lldp_tx_req                      ( i_lldp_tx_req               ) ,
        .o_lldp_tx_ack                      ( w_txmac_2lldp_ack[7]             ) ,
    `endif 
        // 调度流水线调度信息交互
        .o_fifoc_empty                      ( w_mac7_fifoc_empty          ) ,    
        .i_scheduing_rst                    ( i_mac7_scheduing_rst        ) , 
        .i_scheduing_rst_vld                ( i_mac7_scheduing_rst_vld    ) , 
        /*-------------------- TXMAC 输出数据流 -----------------------*/
        //pmac通道数据
        .o_pmac_tx_axis_data                ( o_pmac7_tx_axis_data        ) , 
        .o_pmac_tx_axis_user                ( o_pmac7_tx_axis_user        ) , 
        .o_pmac_tx_axis_keep                ( o_pmac7_tx_axis_keep        ) , 
        .o_pmac_tx_axis_last                ( o_pmac7_tx_axis_last        ) , 
        .o_pmac_tx_axis_valid               ( o_pmac7_tx_axis_valid       ) ,  
        .i_pmac_tx_axis_ready               ( i_pmac7_tx_axis_ready       ) , 
        //emac通道数据                       
        .o_emac_tx_axis_data                ( o_emac7_tx_axis_data        ) , 
        .o_emac_tx_axis_user                ( o_emac7_tx_axis_user        ) , 
        .o_emac_tx_axis_keep                ( o_emac7_tx_axis_keep        ) , 
        .o_emac_tx_axis_last                ( o_emac7_tx_axis_last        ) , 
        .o_emac_tx_axis_valid               ( o_emac7_tx_axis_valid       ) , 
        .i_emac_tx_axis_ready               ( i_emac7_tx_axis_ready       ) , 

        .i_clk                              ( i_clk ) ,   // 250MHz
        .i_rst                              ( i_rst ) 
    );
`endif


endmodule