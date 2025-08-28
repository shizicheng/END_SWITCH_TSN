`include "synth_cmd_define.vh"

/* 关注的信息流 : 
    [62:60](3bit) : vlan_pri; 
    [59:52](8bit) : tx_prot;
    [51:44](8bit) : acl_frmtype
    [11](1bit) : 是否为关键帧(Qbu) 
    [10:0] ：data_len，数据长度信息 
*/
module cross_bar_txport_mnt#(
    parameter                      REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                      REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                      METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                      PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                      PORT_FIFO_PRI_NUM       =      8        , 
    parameter                      CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
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

/*------------ wire -------------*/

/*------------- reg -------------*/

/*------------ assign -----------*/

/*------------ always -----------*/


/*------------ inst -------------*/
cross_data_cache #(
    .PORT_MNG_DATA_WIDTH    (PORT_MNG_DATA_WIDTH) ,
    .PORT_FIFO_PRI_NUM      (PORT_FIFO_PRI_NUM) ,
    .CROSS_DATA_WIDTH       (CROSS_DATA_WIDTH)  // 聚合总线输出 
)cross_data_cache_inst (
    // sys interface
    .i_clk                  (  ) ,
    .i_rst                  (  ) ,
    // data stream pri interface   
    .i_data_pri0            (  ) ,
    .i_data_pri0_vld        (  ) ,
    .i_meta_data_pri0       (  ) ,
    .i_meta_data_pri0_vld   (  ) ,
    .o_data_pri0_ready      (  ) ,
    .i_data0_qbu_flag       (  ) ,
  
    .i_data_pri1            (  ) ,     
    .i_data_pri1_vld        (  ) ,
    .i_meta_data_pri1       (  ) ,
    .i_meta_data_pri1_vld   (  ) ,
    .o_data_pri1_ready      (  ) ,
    .i_data1_qbu_flag       (  ) ,
  
    .i_data_pri2            (  ) ,
    .i_data_pri2_vld        (  ) ,
    .i_meta_data_pri2       (  ) ,
    .i_meta_data_pri2_vld   (  ) ,
    .o_data_pri2_ready      (  ) ,
    .i_data2_qbu_flag       (  ) ,
  
    .i_data_pri3            (  ) ,
    .i_data_pri3_vld        (  ) ,
    .i_meta_data_pri3       (  ) ,
    .i_meta_data_pri3_vld   (  ) ,
    .o_data_pri3_ready      (  ) ,
    .i_data3_qbu_flag       (  ) ,
  
    .i_data_pri4            (  ) ,
    .i_data_pri4_vld        (  ) ,
    .i_meta_data_pri4       (  ) ,
    .i_meta_data_pri4_vld   (  ) ,
    .o_data_pri4_ready      (  ) ,
    .i_data4_qbu_flag       (  ) ,
  
    .i_data_pri5            (  ) ,
    .i_data_pri5_vld        (  ) ,
    .i_meta_data_pri5       (  ) ,
    .i_meta_data_pri5_vld   (  ) ,
    .o_data_pri5_ready      (  ) ,
    .i_data5_qbu_flag       (  ) ,
  
    .i_data_pri6            (  ) ,
    .i_data_pri6_vld        (  ) ,
    .i_meta_data_pri6       (  ) ,
    .i_meta_data_pri6_vld   (  ) ,
    .o_data_pri6_ready      (  ) ,
    .i_data6_qbu_flag       (  ) ,
  
    .i_data_pri7            (  ) ,
    .i_data_pri7_vld        (  ) ,
    .i_meta_data_pri7       (  ) ,
    .i_meta_data_pri7_vld   (  ) ,
    .o_data_pri7_ready      (  ) ,
    .i_data7_qbu_flag       (  ) ,
    // 与调度流水线交互接口  
    .o_mac_fifoc_empty      (  ) ,   
    .i_mac_scheduing_rst    (  ) ,
    .i_mac_scheduing_rst_vld(  ) ,
    /*-------------------- TXMAC 输出数据流 -----------------------*/
    //pmac通道数据
    .o_pmac_tx_axis_data   (  ), 
    .o_pmac_tx_axis_user   (  ), 
    .o_pmac_tx_axis_keep   (  ), 
    .o_pmac_tx_axis_last   (  ), 
    .o_pmac_tx_axis_valid  (  ), 
    .o_pmac_ethertype      (  ), 
    .i_pmac_tx_axis_ready  (  ),
    //emac通道数据                 
    .o_emac_tx_axis_data   (  ), 
    .o_emac_tx_axis_user   (  ), 
    .o_emac_tx_axis_keep   (  ), 
    .o_emac_tx_axis_last   (  ), 
    .o_emac_tx_axis_valid  (  ), 
    .o_emac_ethertype      (  ),
    .i_emac_tx_axis_ready  (  )
);


endmodule