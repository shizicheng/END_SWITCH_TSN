module tsn_as_top#(
    parameter                                                   PORT_NUM                =      8        ,
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地�?位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位�?
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        , 
    parameter                                                   TIMESTAMP_WIDTH         =      80       ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(

    /*-------------------- RXMAC 输入数据�? -----------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac0_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac0_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac0_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac0_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac0_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac0_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac0_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac0_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac0_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx0_req                     , // 通道输入请求
    output             wire                                     o_tx0_ack                     , // 通道请求应答
`endif
`ifdef MAC1
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac1_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac1_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac1_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac1_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac1_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac1_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac1_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac1_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac1_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx1_req                     , // 通道输入请求
    output             wire                                     o_tx1_ack                     , // 通道请求应答
`endif
`ifdef MAC2
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac2_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac2_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac2_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac2_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac2_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac2_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac2_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac2_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac2_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx2_req                     , // 通道输入请求
    output             wire                                     o_tx2_ack                     , // 通道请求应答
`endif
`ifdef MAC3
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac3_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac3_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac3_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac3_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac3_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac3_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac3_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac3_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac3_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx3_req                     , // 通道输入请求
    output             wire                                     o_tx3_ack                     , // 通道请求应答
`endif
`ifdef MAC4
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac4_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac4_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac4_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac4_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac4_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac4_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac4_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac4_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac4_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx4_req                     , // 通道输入请求
    output             wire                                     o_tx4_ack                     , // 通道请求应答
`endif
`ifdef MAC5
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac5_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac5_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac5_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac5_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac5_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac5_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac5_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac5_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac5_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx5_req                     , // 通道输入请求
    output             wire                                     o_tx5_ack                     , // 通道请求应答
`endif
`ifdef MAC6
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac6_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac6_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac6_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac6_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac6_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac6_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac6_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac6_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac6_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx6_req                     , // 通道输入请求
    output             wire                                     o_tx6_ack                     , // 通道请求应答
`endif
`ifdef MAC7
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    input               wire                                    i_mac7_port_link              , // 端口的连接状�? 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac7_port_axi_data          , // 端口数据�?
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac7_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac7_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac7_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    input               wire                                    i_mac7_axi_data_last          , // 数据流结束标�?
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac7_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac7_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac7_metadata_last          , // 信息流结束标�? 

    input              wire                                     i_tx7_req                     , // 通道输入请求
    output             wire                                     o_tx7_ack                     , // 通道请求应答
`endif

    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_tsn_as_port_link            , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_tsn_as_port_axi_data        , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_tsn_as_axi_data_keep        , // 端口数据流掩码，有效字节指示
    output              wire                                    o_tsn_as_axi_data_valid       , // 端口数据有效
    input               wire                                    i_tsn_as_axi_data_ready       , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_tsn_as_axi_data_last        , // 数据流结束标�?
    input               wire                                    i_tsn_as_channel_end                , // 该�?�道结束�?轮同步，可以�?始下�?个�?�道的发送了
    /*---------------------------------------- �? PORT 聚合信息�? -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_tsn_as_metadata             , // 总线 metadata 数据  
    output              wire                                    o_tsn_as_metadata_valid       , // 总线 metadata 数据有效信号
    output              wire                                    o_tsn_as_metadata_last        , // 信息流结束标�? 

//TX_MAC输出数据
    `ifdef CPU_MAC
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac0_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac0_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac0_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac0_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac0_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac0_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx0_req                     , // 通道输入请求
    input              wire                                     i_tx0_ack                     , // 通道请求应答
`endif
`ifdef MAC1
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac1_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac1_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac1_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac1_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac1_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac1_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx1_req                     , // 通道输入请求
    input              wire                                     i_tx1_ack                     , // 通道请求应答
`endif
`ifdef MAC2
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac2_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac2_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac2_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac2_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac2_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac2_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx2_req                     , // 通道输入请求
    input              wire                                     i_tx2_ack                     , // 通道请求应答
`endif
`ifdef MAC3
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac3_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac3_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac3_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac3_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac3_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac3_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx3_req                     , // 通道输入请求
    input              wire                                     i_tx3_ack                     , // 通道请求应答
`endif
`ifdef MAC4
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac4_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac4_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac4_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac4_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac4_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac4_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx4_req                     , // 通道输入请求
    input              wire                                     i_tx4_ack                     , // 通道请求应答
`endif
`ifdef MAC5
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac5_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac5_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac5_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac5_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac5_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac5_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx5_req                     , // 通道输入请求
    input              wire                                     i_tx5_ack                     , // 通道请求应答
`endif
`ifdef MAC6
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac6_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac6_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac6_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac6_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac6_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac6_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx6_req                     , // 通道输入请求
    input              wire                                     i_tx6_ack                     , // 通道请求应答
`endif
`ifdef MAC7
    /*---------------------------------------- �? PORT 输出数据�? -------------------------------------------*/
    output              wire                                    o_mac7_port_link              , // 端口的连接状�? 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac7_port_axi_data          , // 端口数据�?
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac7_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac7_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac7_axi_data_ready         , // 交叉总线聚合架构反压流水线信�?
    output              wire                                    o_mac7_axi_data_last          , // 数据流结束标�?
    output             wire                                     o_tx7_req                     , // 通道输入请求
    input              wire                                     i_tx7_ack                     , // 通道请求应答
`endif

    // output             wire                                     o_pps                         
    input               wire                                    i_clk                         ,   // 250MHz
    input               wire                                    i_rst                          
);

`include "synth_cmd_define.vh"

ptp_tx_pkt #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .METADATA_WIDTH          (METADATA_WIDTH          ),
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH     ),
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM       ),
    .TIMESTAMP_WIDTH         (TIMESTAMP_WIDTH         ),
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH        )
) u_ptp_tx_pkt (
    .i_clk                   (i_clk                   ),
    .i_rst                   (i_rst                   ),

    .o_ptp_reg_bus_we        (                        ), // Connect as needed
    .o_ptp_reg_bus_we_addr   (                        ),
    .o_ptp_reg_bus_we_din    (                        ),
    .o_ptp_reg_bus_we_din_v  (                        ),
    .o_ptp_reg_bus_rd        (                        ),
    .o_ptp_reg_bus_rd_addr   (                        ),
    .i_ptp_reg_bus_rd_dout   (                        ),
    .i_ptp_reg_bus_rd_dout_v (                        ),

    .i_ptp_bcm_state         (                        ),
    .i_ptp_bcm_state_valid   (                        ),

    .i_announce_req          (                        ),
    .i_sync_req              (                        ),
    .i_follow_up_req         (                        ),
    .i_pdelayreq_req         (                        ),
    .i_pdelayresp_req        (                        ),
    .i_pdelayresp_fw_req     (                        ),

    .i_announce_send_port            (                ),
    .i_sync_send_port                (                ),
    .i_follow_up_send_port           (                ),
    .i_pdelay_req_send_port          (                ),
    .i_pdelay_resp_send_port         (                ),
    .i_pdelay_resp_followup_send_port(                ),

    .o_announce_ack          (                        ),
    .o_sync_ack              (                        ),
    .o_follow_up_ack         (                        ),
    .o_pdelayreq_ack         (                        ),
    .o_pdelayresp_ack        (                        ),
    .o_pdelayresp_fw_ack     (                        ),

    .o_send_frame_end        (                        ),

    .i_sync_origintimestamp  (                        ),
    .i_sync_sequenceid       (                        ),
    .i_sync_valid            (                        ),
    .i_follow_up_origintimestamp (                    ),
    .i_follow_up_valid       (                        ),
    .i_follow_up_sequenceid  (                        ),
    .i_follow_up_rateratio   (                        ),
    .i_pdelay_req_sequenceid (                        ),
    .i_pdelay_req_valid      (                        ),
    .i_pdelay_resp_sequenceid(                        ),
    .i_pdelay_resp_valid     (                        ),
    .i_pdelay_respfw_sequenceid (                     ),
    .i_pdelay_respfw_valid   (                        ),

    //.i_current_timestamp     (                        ),

    //.o_timereglist_rd        (                        ),
    //.o_timereglist_addr      (                        ),
    //.o_rd_timestamp_req      (                        ),

`ifdef CPU_MAC
    .o_mac0_port_link        (                        ),
    .o_mac0_port_axi_data    (                        ),
    .o_mac0_axi_data_keep    (                        ),
    .o_mac0_axi_data_valid   (                        ),
    .i_mac0_axi_data_ready   (                        ),
    .o_mac0_axi_data_last    (                        ),
    .o_tx0_req               (                        ),
    .i_tx0_ack               (                        ),
`endif
`ifdef MAC1
    .o_mac1_port_link        (                        ),
    .o_mac1_port_axi_data    (                        ),
    .o_mac1_axi_data_keep    (                        ),
    .o_mac1_axi_data_valid   (                        ),
    .i_mac1_axi_data_ready   (                        ),
    .o_mac1_axi_data_last    (                        ),
    .o_tx1_req               (                        ),
    .i_tx1_ack               (                        ),
`endif
`ifdef MAC2
    .o_mac2_port_link        (                        ),
    .o_mac2_port_axi_data    (                        ),
    .o_mac2_axi_data_keep    (                        ),
    .o_mac2_axi_data_valid   (                        ),
    .i_mac2_axi_data_ready   (                        ),
    .o_mac2_axi_data_last    (                        ),
    .o_tx2_req               (                        ),
    .i_tx2_ack               (                        ),
`endif
`ifdef MAC3
    .o_mac3_port_link        (                        ),
    .o_mac3_port_axi_data    (                        ),
    .o_mac3_axi_data_keep    (                        ),
    .o_mac3_axi_data_valid   (                        ),
    .i_mac3_axi_data_ready   (                        ),
    .o_mac3_axi_data_last    (                        ),
    .o_tx3_req               (                        ),
    .i_tx3_ack               (                        ),
`endif
`ifdef MAC4
    .o_mac4_port_link        (                        ),
    .o_mac4_port_axi_data    (                        ),
    .o_mac4_axi_data_keep    (                        ),
    .o_mac4_axi_data_valid   (                        ),
    .i_mac4_axi_data_ready   (                        ),
    .o_mac4_axi_data_last    (                        ),
    .o_tx4_req               (                        ),
    .i_tx4_ack               (                        ),
`endif
`ifdef MAC5
    .o_mac5_port_link        (                        ),
    .o_mac5_port_axi_data    (                        ),
    .o_mac5_axi_data_keep    (                        ),
    .o_mac5_axi_data_valid   (                        ),
    .i_mac5_axi_data_ready   (                        ),
    .o_mac5_axi_data_last    (                        ),
    .o_tx5_req               (                        ),
    .i_tx5_ack               (                        ),
`endif
`ifdef MAC6
    .o_mac6_port_link        (                        ),
    .o_mac6_port_axi_data    (                        ),
    .o_mac6_axi_data_keep    (                        ),
    .o_mac6_axi_data_valid   (                        ),
    .i_mac6_axi_data_ready   (                        ),
    .o_mac6_axi_data_last    (                        ),
    .o_tx6_req               (                        ),
    .i_tx6_ack               (                        ),
`endif
`ifdef MAC7
    .o_mac7_port_link        (                        ),
    .o_mac7_port_axi_data    (                        ),
    .o_mac7_axi_data_keep    (                        ),
    .o_mac7_axi_data_valid   (                        ),
    .i_mac7_axi_data_ready   (                        ),
    .o_mac7_axi_data_last    (                        ),
    .o_tx7_req               (                        ),
    .i_tx7_ack               (                        )
`endif
);

ptp_arbit #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .METADATA_WIDTH          (METADATA_WIDTH          ),
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH     ),
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM       ),
    .TIMESTAMP_WIDTH         (TIMESTAMP_WIDTH         ),
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH        )
) u_ptp_arbit (
    .i_clk                   (i_clk                   ),
    .i_rst                   (i_rst                   ),
`ifdef CPU_MAC
    .i_mac0_port_link        (i_mac0_port_link        ),
    .i_mac0_port_axi_data    (i_mac0_port_axi_data    ),
    .i_mac0_axi_data_keep    (i_mac0_axi_data_keep    ),
    .i_mac0_axi_data_valid   (i_mac0_axi_data_valid   ),
    .o_mac0_axi_data_ready   (o_mac0_axi_data_ready   ),
    .i_mac0_axi_data_last    (i_mac0_axi_data_last    ),
    .i_mac0_metadata         (i_mac0_metadata         ),
    .i_mac0_metadata_valid   (i_mac0_metadata_valid   ),
    .i_mac0_metadata_last    (i_mac0_metadata_last    ),
    .i_tx0_req               (i_tx0_req               ),
    .o_tx0_ack               (o_tx0_ack               ),
`endif
`ifdef MAC1
    .i_mac1_port_link        (i_mac1_port_link        ),
    .i_mac1_port_axi_data    (i_mac1_port_axi_data    ),
    .i_mac1_axi_data_keep    (i_mac1_axi_data_keep    ),
    .i_mac1_axi_data_valid   (i_mac1_axi_data_valid   ),
    .o_mac1_axi_data_ready   (o_mac1_axi_data_ready   ),
    .i_mac1_axi_data_last    (i_mac1_axi_data_last    ),
    .i_mac1_metadata         (i_mac1_metadata         ),
    .i_mac1_metadata_valid   (i_mac1_metadata_valid   ),
    .i_mac1_metadata_last    (i_mac1_metadata_last    ),
    .i_tx1_req               (i_tx1_req               ),
    .o_tx1_ack               (o_tx1_ack               ),
`endif
`ifdef MAC2
    .i_mac2_port_link        (i_mac2_port_link        ),
    .i_mac2_port_axi_data    (i_mac2_port_axi_data    ),
    .i_mac2_axi_data_keep    (i_mac2_axi_data_keep    ),
    .i_mac2_axi_data_valid   (i_mac2_axi_data_valid   ),
    .o_mac2_axi_data_ready   (o_mac2_axi_data_ready   ),
    .i_mac2_axi_data_last    (i_mac2_axi_data_last    ),
    .i_mac2_metadata         (i_mac2_metadata         ),
    .i_mac2_metadata_valid   (i_mac2_metadata_valid   ),
    .i_mac2_metadata_last    (i_mac2_metadata_last    ),
    .i_tx2_req               (i_tx2_req               ),
    .o_tx2_ack               (o_tx2_ack               ),
`endif
`ifdef MAC3
    .i_mac3_port_link        (i_mac3_port_link        ),
    .i_mac3_port_axi_data    (i_mac3_port_axi_data    ),
    .i_mac3_axi_data_keep    (i_mac3_axi_data_keep    ),
    .i_mac3_axi_data_valid   (i_mac3_axi_data_valid   ),
    .o_mac3_axi_data_ready   (o_mac3_axi_data_ready   ),
    .i_mac3_axi_data_last    (i_mac3_axi_data_last    ),
    .i_mac3_metadata         (i_mac3_metadata         ),
    .i_mac3_metadata_valid   (i_mac3_metadata_valid   ),
    .i_mac3_metadata_last    (i_mac3_metadata_last    ),
    .i_tx3_req               (i_tx3_req               ),
    .o_tx3_ack               (o_tx3_ack               ),
`endif
`ifdef MAC4
    .i_mac4_port_link        (i_mac4_port_link        ),
    .i_mac4_port_axi_data    (i_mac4_port_axi_data    ),
    .i_mac4_axi_data_keep    (i_mac4_axi_data_keep    ),
    .i_mac4_axi_data_valid   (i_mac4_axi_data_valid   ),
    .o_mac4_axi_data_ready   (o_mac4_axi_data_ready   ),
    .i_mac4_axi_data_last    (i_mac4_axi_data_last    ),
    .i_mac4_metadata         (i_mac4_metadata         ),
    .i_mac4_metadata_valid   (i_mac4_metadata_valid   ),
    .i_mac4_metadata_last    (i_mac4_metadata_last    ),
    .i_tx4_req               (i_tx4_req               ),
    .o_tx4_ack               (o_tx4_ack               ),
`endif
`ifdef MAC5
    .i_mac5_port_link        (i_mac5_port_link        ),
    .i_mac5_port_axi_data    (i_mac5_port_axi_data    ),
    .i_mac5_axi_data_keep    (i_mac5_axi_data_keep    ),
    .i_mac5_axi_data_valid   (i_mac5_axi_data_valid   ),
    .o_mac5_axi_data_ready   (o_mac5_axi_data_ready   ),
    .i_mac5_axi_data_last    (i_mac5_axi_data_last    ),
    .i_mac5_metadata         (i_mac5_metadata         ),
    .i_mac5_metadata_valid   (i_mac5_metadata_valid   ),
    .i_mac5_metadata_last    (i_mac5_metadata_last    ),
    .i_tx5_req               (i_tx5_req               ),
    .o_tx5_ack               (o_tx5_ack               ),
`endif
`ifdef MAC6
    .i_mac6_port_link        (i_mac6_port_link        ),
    .i_mac6_port_axi_data    (i_mac6_port_axi_data    ),
    .i_mac6_axi_data_keep    (i_mac6_axi_data_keep    ),
    .i_mac6_axi_data_valid   (i_mac6_axi_data_valid   ),
    .o_mac6_axi_data_ready   (o_mac6_axi_data_ready   ),
    .i_mac6_axi_data_last    (i_mac6_axi_data_last    ),
    .i_mac6_metadata         (i_mac6_metadata         ),
    .i_mac6_metadata_valid   (i_mac6_metadata_valid   ),
    .i_mac6_metadata_last    (i_mac6_metadata_last    ),
    .i_tx6_req               (i_tx6_req               ),
    .o_tx6_ack               (o_tx6_ack               ),
`endif
`ifdef MAC7
    .i_mac7_port_link        (i_mac7_port_link        ),
    .i_mac7_port_axi_data    (i_mac7_port_axi_data    ),
    .i_mac7_axi_data_keep    (i_mac7_axi_data_keep    ),
    .i_mac7_axi_data_valid   (i_mac7_axi_data_valid   ),
    .o_mac7_axi_data_ready   (o_mac7_axi_data_ready   ),
    .i_mac7_axi_data_last    (i_mac7_axi_data_last    ),
    .i_mac7_metadata         (i_mac7_metadata         ),
    .i_mac7_metadata_valid   (i_mac7_metadata_valid   ),
    .i_mac7_metadata_last    (i_mac7_metadata_last    ),
    .i_tx7_req               (i_tx7_req               ),
    .o_tx7_ack               (o_tx7_ack               ),
`endif
    .o_tsn_as_port_link      (o_tsn_as_port_link      ),
    .o_tsn_as_port_axi_data  (o_tsn_as_port_axi_data  ),
    .o_tsn_as_axi_data_keep  (o_tsn_as_axi_data_keep  ),
    .o_tsn_as_axi_data_valid (o_tsn_as_axi_data_valid ),
    .i_tsn_as_axi_data_ready (i_tsn_as_axi_data_ready ),
    .o_tsn_as_axi_data_last  (o_tsn_as_axi_data_last  ),
    .i_tsn_as_channel_end    (i_tsn_as_channel_end    ),
    .o_tsn_as_metadata       (o_tsn_as_metadata       ),
    .o_tsn_as_metadata_valid (o_tsn_as_metadata_valid ),
    .o_tsn_as_metadata_last  (o_tsn_as_metadata_last  )
);

ptp_rx_pkt #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .METADATA_WIDTH          (METADATA_WIDTH          ),
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH     ),
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM       ),
    .TIMESTAMP_WIDTH         (TIMESTAMP_WIDTH         ),
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH        )
) u_ptp_rx_pkt (
    .i_clk                               (i_clk                               ),
    .i_rst                               (i_rst                               ),
    .i_tsn_as_port_link                  (i_tsn_as_port_link                  ),
    .i_tsn_as_port_axi_data              (i_tsn_as_port_axi_data              ),
    .i_tsn_as_axi_data_keep              (i_tsn_as_axi_data_keep              ),
    .i_tsn_as_axi_data_valid             (i_tsn_as_axi_data_valid             ),
    .o_tsn_as_axi_data_ready             (o_tsn_as_axi_data_ready             ),
    .i_tsn_as_axi_data_last              (i_tsn_as_axi_data_last              ),
    .i_tsn_as_metadata                   (i_tsn_as_metadata                   ),
    .i_tsn_as_metadata_valid             (i_tsn_as_metadata_valid             ),
    .o_twostepflag                       (                                    ),
    .o_correctionfield                   (                                    ),
    .o_logmessageinterval                (                                    ),
    .o_stpv_priority1                    (                                    ),
    .o_stpv_clkclass                     (                                    ),
    .o_stpv_clkaccuracy                  (                                    ),
    .o_stpv_variance                     (                                    ),
    .o_stpv_priority2                    (                                    ),
    .o_stpv_clkidentity                  (                                    ),
    .o_stpv_stepsremoved                 (                                    ),
    .o_stpv_sourceportid                 (                                    ),
    .o_stpv_portnumrecofport             (                                    ),
    .o_stpv_valid                        (                                    ),
    .o_port_link                         (                                    ),
    .o_ann_sequenceid                    (                                    ),
    .o_sync_origintimestamp              (                                    ),
    .o_sync_sequenceid                   (                                    ),
    .o_sync_valid                        (                                    ),
    .o_follow_up_origintimestamp         (                                    ),
    .o_follow_up_valid                   (                                    ),
    .o_follow_up_sequenceid              (                                    ),
    .o_follow_up_rateratio               (                                    ),
    .o_pdelay_req_sequenceid             (                                    ),
    .o_pdelay_req_valid                  (                                    ),
    .o_pdelay_resprectimestamp_t1        (                                    ),
    .o_pdelay_respportid                 (                                    ),
    .o_pdelay_resp_sequenceid            (                                    ),
    .o_pdelay_resp_valid                 (                                    ),
    .o_pdelay_resporigntimestamp_t2      (                                    ),
    .o_pdelay_respfwportid               (                                    ),
    .o_pdelay_respfw_sequenceid          (                                    ),
    .o_pdelay_respfw_valid               (                                    ),
    .i_announce_req                      (                                    ),
    .i_sync_req                          (                                    ),
    .i_follow_up_req                     (                                    ),
    .i_pdelayreq_req                     (                                    ),
    .i_pdelayresp_req                    (                                    ),
    .i_pdelayresp_fw_req                 (                                    ),
    .o_announce_ack                      (                                    ),
    .o_sync_ack                          (                                    ),
    .o_follow_up_ack                     (                                    ),
    .o_pdelayreq_ack                     (                                    ),
    .o_pdelayresp_ack                    (                                    ),
    .o_pdelayresp_fw_ack                 (                                    ),
    .i_announce_send_port                (                                    ),
    .i_sync_send_port                    (                                    ),
    .i_follow_up_send_port               (                                    ),
    .i_pdelay_req_send_port              (                                    ),
    .i_pdelay_resp_send_port             (                                    ),
    .i_pdelay_resp_followup_send_port    (                                    ),
    .o_announce_req                      (                                    ),
    .o_sync_req                          (                                    ),
    .o_follow_up_req                     (                                    ),
    .o_pdelayreq_req                     (                                    ),
    .o_pdelayresp_req                    (                                    ),
    .o_pdelayresp_fw_req                 (                                    ),
    .i_announce_ack                      (                                    ),
    .i_sync_ack                          (                                    ),
    .i_follow_up_ack                     (                                    ),
    .i_pdelayreq_ack                     (                                    ),
    .i_pdelayresp_ack                    (                                    ),
    .i_pdelayresp_fw_ack                 (                                    ),
    .i_send_frame_end                    (                                    ),
    .o_announce_send_port                (                                    ),
    .o_sync_send_port                    (                                    ),
    .o_follow_up_send_port               (                                    ),
    .o_pdelay_req_send_port              (                                    ),
    .o_pdelay_resp_send_port             (                                    ),
    .o_pdelay_resp_followup_send_port    (                                    )
);
ptp_event #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .METADATA_WIDTH          (METADATA_WIDTH          ),
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH     ),
    .PORT_NUM                (PORT_NUM                ), // 可根据实际端口数修改
    .TIMESTAMP_WIDTH         (TIMESTAMP_WIDTH         ),
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH        )
) u_ptp_event (
    .i_clk                               (i_clk                               ),
    .i_rst                               (i_rst                               ),
    .o_ptp_reg_bus_we                    (                                    ),
    .o_ptp_reg_bus_we_addr               (                                    ),
    .o_ptp_reg_bus_we_din                (                                    ),
    .o_ptp_reg_bus_we_din_v              (                                    ),
    .o_ptp_reg_bus_rd                    (                                    ),
    .o_ptp_reg_bus_rd_addr               (                                    ),
    .i_ptp_reg_bus_rd_dout               (                                    ),
    .i_ptp_reg_bus_rd_dout_v             (                                    ),
    .i_twostepflag                       (                                    ),
    .i_correctionfield                   (                                    ),
    .i_logmessageinterval                (                                    ),
    //.i_messagerec_port                   (                                    ),
    .i_stpv_priority1                    (                                    ),
    .i_stpv_clkclass                     (                                    ),
    .i_stpv_clkaccuracy                  (                                    ),
    .i_stpv_variance                     (                                    ),
    .i_stpv_priority2                    (                                    ),
    .i_stpv_clkidentity                  (                                    ),
    .i_stpv_stepsremoved                 (                                    ),
    .i_stpv_sourceportid                 (                                    ),
    .i_stpv_portnumrecofport             (                                    ),
    .i_stpv_valid                        (                                    ),
    .i_port_link                         (                                    ),
    .i_ann_sequenceid                    (                                    ),
    .i_sync_origintimestamp              (                                    ),
    .i_sync_sequenceid                   (                                    ),
    .i_sync_valid                        (                                    ),
    .i_follow_up_origintimestamp         (                                    ),
    .i_follow_up_valid                   (                                    ),
    .i_follow_up_sequenceid              (                                    ),
    .i_follow_up_rateratio               (                                    ),
    .i_pdelay_req_sequenceid             (                                    ),
    .i_pdelay_req_valid                  (                                    ),
    .i_pdelay_resprectimestamp_t1        (                                    ),
    .i_pdelay_respportid                 (                                    ),
    .i_pdelay_resp_sequenceid            (                                    ),
    .i_pdelay_resp_valid                 (                                    ),
    .i_pdelay_resporigntimestamp_t2      (                                    ),
    .i_pdelay_respfwportid               (                                    ),
    .i_pdelay_respfw_sequenceid          (                                    ),
    .i_pdelay_respfw_valid               (                                    ),
    .o_announce_req                      (                                    ),
    .o_sync_req                          (                                    ),
    .o_follow_up_req                     (                                    ),
    .o_pdelayreq_req                     (                                    ),
    .o_pdelayresp_req                    (                                    ),
    .o_pdelayresp_fw_req                 (                                    ),
    .i_announce_ack                      (                                    ),
    .i_sync_ack                          (                                    ),
    .i_follow_up_ack                     (                                    ),
    .i_pdelayreq_ack                     (                                    ),
    .i_pdelayresp_ack                    (                                    ),
    .i_pdelayresp_fw_ack                 (                                    ),
    .o_announce_send_port                (                                    ),
    .o_sync_send_port                    (                                    ),
    .o_follow_up_send_port               (                                    ),
    .o_pdelay_req_send_port              (                                    ),
    .o_pdelay_resp_send_port             (                                    ),
    .o_pdelay_resp_followup_send_port    (                                    ),
    .i_ptp_bcm_state                     (                                    ),
    .i_ptp_bcm_state_valid               (                                    ),
    .i_ptp_sync_busy                     (                                    ),
    .i_ptp_sync_end                      (                                    ),
    .i_ptp_pdelay_busy                   (                                    ),
    .i_ptp_pdelay_end                    (                                    ),
    .i_bcm_state                         (                                    ),
    .i_portrole_state                    (                                    ),
    .i_sync_state                        (                                    ),
    .i_pdelay_state                      (                                    ),
    .i_pdelay_resp_state                 (                                    ),
    .o_general_event_twostepflag         (                                    ),
    .o_bcm_event_start                   (                                    ),
    .o_bcm_event_monitor_end             (                                    ),
    .o_bcm_event_forced_gm               (                                    ),
    .o_bcm_event_forced_slave            (                                    ),
    .o_bcm_event_rec_announce            (                                    ),
    .o_bcm_event_rec_better_ann          (                                    ),
    .o_bcm_event_rec_nobetter_ann        (                                    ),
    .o_bcm_event_master_timeout          (                                    ),
    .o_bcm_event_master_linkdown         (                                    ),
    .o_sync_event_start                  (                                    ),
    .o_sync_event_send_sync_end          (                                    ),
    .o_sync_event_send_followup_end      (                                    ),
    .o_sync_event_end                    (                                    ),
    .o_pdelay_event_start                (                                    ),
    .o_pdelay_event_req_send_end         (                                    ),
    .o_pdelay_event_resp_rec_end         (                                    ),
    .o_pdelay_event_respfw_rec_end       (                                    ),
    .o_pdelay_event_end                  (                                    ),
    .o_pdelay_event_resp_start           (                                    ),
    .o_pdelay_event_resp_send_end        (                                    ),
    .o_pdelay_event_respfw_sned_end      (                                    ),
    .o_pdelay_event_resp_end             (                                    ),
    .i_slave_clockoffset                 (                                    ),
    .i_slave_clockoffset_sign            (                                    ),
    .i_slave_clockoffset_valid           (                                    ),
    .i_pdelay_time                       (                                    ),
    .i_pdelay_time_valid                 (                                    ),
    .i_forward_time                      (                                    ),
    .i_forward_time_valid                (                                    ),
    .i_clock_add_gap                     (                                    ),
    .i_clock_add_gap_sign                (                                    ),
    .i_clock_add_gap_valid               (                                    )
);

ptp_fsm #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .METADATA_WIDTH          (METADATA_WIDTH          ),
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH     ),
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM       ),
    .TIMESTAMP_WIDTH         (TIMESTAMP_WIDTH         ),
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH        )
) u_ptp_fsm (
    .i_clk                               (i_clk                               ),
    .i_rst                               (i_rst                               ),
    .o_ptp_bcm_state                     (                                    ),
    .o_ptp_bcm_state_valid               (                                    ),
    .o_ptp_sync_busy                     (                                    ),
    .o_ptp_sync_end                      (                                    ),
    .o_ptp_pdelay_busy                   (                                    ),
    .o_ptp_pdelay_end                    (                                    ),
    .o_bcm_state                         (                                    ),
    .o_portrole_state                    (                                    ),
    .o_sync_state                        (                                    ),
    .o_pdelay_state                      (                                    ),
    .o_pdelay_resp_state                 (                                    ),
    .i_general_event_twostepflag         (                                    ),
    .i_bcm_event_start                   (                                    ),
    .i_bcm_event_monitor_end             (                                    ),
    .i_bcm_event_forced_gm               (                                    ),
    .i_bcm_event_forced_slave            (                                    ),
    .i_bcm_event_rec_announce            (                                    ),
    .i_bcm_event_rec_better_ann          (                                    ),
    .i_bcm_event_rec_nobetter_ann        (                                    ),
    .i_bcm_event_master_timeout          (                                    ),
    .i_bcm_event_master_linkdown         (                                    ),
    .i_sync_event_start                  (                                    ),
    .i_sync_event_send_sync_end          (                                    ),
    .i_sync_event_send_followup_end      (                                    ),
    .i_sync_event_end                    (                                    ),
    .i_pdelay_event_start                (                                    ),
    .i_pdelay_event_req_send_end         (                                    ),
    .i_pdelay_event_resp_rec_end         (                                    ),
    .i_pdelay_event_respfw_rec_end       (                                    ),
    .i_pdelay_event_end                  (                                    ),
    .i_pdelay_event_resp_start           (                                    ),
    .i_pdelay_event_resp_send_end        (                                    ),
    .i_pdelay_event_respfw_sned_end      (                                    ),
    .i_pdelay_event_resp_end             (                                    )
);

ptp_reg_list #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .PORT_NUM                (PORT_NUM                )
) u_ptp_reg_list (
    .i_clk                   (i_clk                   ),
    .i_rst                   (i_rst                   ),
    .i_channel_linkup        (                         ), 

    // ptp模块交互
    .i_ptp_reg_bus_we        (                         ),
    .i_ptp_reg_bus_we_addr   (                         ),
    .i_ptp_reg_bus_we_din    (                         ),
    .i_ptp_reg_bus_we_din_v  (                         ),
    .i_ptp_reg_bus_rd        (                         ),
    .i_ptp_reg_bus_rd_addr   (                         ),
    .o_ptp_reg_bus_rd_dout   (                         ),
    .o_ptp_reg_bus_rd_dout_v (                         ),

    // 上层配置寄存�?
    .i_switch_reg_bus_we         (                      ),
    .i_switch_reg_bus_we_addr    (                      ),
    .i_switch_reg_bus_we_din     (                      ),
    .i_switch_reg_bus_we_din_v   (                      ),
    .i_switch_reg_bus_rd         (                      ),
    .i_switch_reg_bus_rd_addr    (                      ),
    .o_switch_reg_bus_rd_dout    (                      ),
    .o_switch_reg_bus_rd_dout_v  (                      )
);

ptp_time_reg_list #(
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH      ),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH      ),
    .TIMESTAMP_WIDTH         (TIMESTAMP_WIDTH         )
) u_ptp_time_reg_list (
    .i_clk                               (i_clk                               ),
    .i_rst                               (i_rst                               ),
    //.o_refresh_list_pulse                (                                    ),
    //.o_switch_err_cnt_clr                (                                    ),
    //.o_switch_err_cnt_stat               (                                    ),
    //.o_switch_reg_bus_we                 (                                    ),
    //.o_switch_reg_bus_we_addr            (                                    ),
    //.o_switch_reg_bus_we_din             (                                    ),
    //.o_switch_reg_bus_we_din_v           (                                    ),
    //.o_switch_reg_bus_rd                 (                                    ),
    //.o_switch_reg_bus_rd_addr            (                                    ),
    //.i_switch_reg_bus_rd_dout            (                                    ),
    //.i_switch_reg_bus_rd_dout_v          (                                    ),
    .i_sync_origintimestamp              (                                    ),
    .i_sync_correctionfield              (                                    ),
    .i_sync_port                         (                                    ),
    .i_sync_valid                        (                                    ),
    .i_follow_up_origintimestamp         (                                    ),
    .i_follow_up_correctionfield         (                                    ),
    .i_follow_up_valid                   (                                    ),
    .i_follow_up_port                    (                                    ),
    .i_follow_up_rateratio               (                                    ),
    .i_pdelay_resprectimestamp_t1        (                                    ),
    .i_pdelay_resp_port                  (                                    ),
    .i_pdelay_resp_valid                 (                                    ),
    .i_pdelay_resporigntimestamp_t2      (                                    ),
    .i_pdelay_respfw_port                (                                    ),
    .i_pdelay_respfw_valid               (                                    ),
    .i_sync_out_timestamp                (                                    ),
    .i_sync_out_port                     (                                    ),
    .i_sync_out_valid                    (                                    ),
    .i_sync_in_timestamp                 (                                    ),
    .i_sync_in_port                      (                                    ),
    .i_sync_in_valid                     (                                    ),
    .i_pdelay_req_out_timestamp_t0       (                                    ),
    .i_pdelay_req_out_port               (                                    ),
    .i_pdelay_req_out_valid              (                                    ),
    .i_pdelay_req_in_timestamp_t1        (                                    ),
    .i_pdelay_req_in_port                (                                    ),
    .i_pdelay_req_in_valid               (                                    ),
    .i_pdelay_resp_out_timestamp_t2      (                                    ),
    .i_pdelay_resp_out_port              (                                    ),
    .i_pdelay_resp_out_valid             (                                    ),
    .i_pdelay_resp_in_timestamp_t3       (                                    ),
    .i_pdelay_resp_in_port               (                                    ),
    .i_pdelay_resp_in_valid              (                                    ),
    .i_slave_clockoffset                 (                                    ),
    .i_slave_clockoffset_sign            (                                    ),
    .i_slave_clockoffset_valid           (                                    ),
    .i_pdelay_time                       (                                    ),
    .i_pdelay_time_valid                 (                                    ),
    .i_forward_time                      (                                    ),
    .i_forward_time_valid                (                                    ),
    .i_clock_add_gap                     (                                    ),
    .i_clock_add_gap_sign                (                                    ),
    .i_clock_add_gap_valid               (                                    ),
    .o_sync_origintimestamp              (                                    ),
    .o_slaveport_pdelay                  (                                    ),
    .o_correctionfield                   (                                    ),
    .o_clockoffsettime_valid             (                                    ),
    .o_pdelay_t0                         (                                    ),
    .o_pdelay_t1                         (                                    ),
    .o_pdelay_t2                         (                                    ),
    .o_pdelay_t3                         (                                    ),
    .o_pdelaytime_valid                  (                                    ),
    .o_sync_in_t4                        (                                    ),
    .o_sync_out_t5                       (                                    ),
    .o_forwardtime_valid                 (                                    ),
    //.i_pdelay_resp_req                   (                                    ),
    .o_pdelay_req_in_timestamp           (                                    ),
    .o_pdelay_req_in_timestamp_valid     (                                    ),
    //.i_pdelay_resp_followup_req          (                                    ),
    .o_pdelay_resp_out_timestamp         (                                    ),
    .o_pdelay_resp_out_timestamp_valid   (                                    ),
    //.i_sync_req                          (                                    ),
    //.i_follow_up_req                     (                                    ),
    .o_sync_out_timestamp                (                                    ),
    .o_sync_out_timestamp_valid          (                                    )
);


ptp_sync_time_cacl u_ptp_sync_time_cacl (
    .i_clk                   (i_clk                   ),
    .i_rst                   (i_rst                   ),
    .i_sync_origintimestamp  (                        ),
    .i_slaveport_pdelay      (                        ),
    .i_correctionfield       (                        ),
    .i_clockoffsettime_valid (                        ),
    .i_sync_in_t4            (                        ),
    .i_sync_in_t4_valid      (                        ),
    .o_slave_clockoffset     (                        ),
    .o_slave_clockoffset_sign(                        ),
    .o_slave_clockoffset_valid(                       ),
    .i_sync_origintimestamp_valid(                    ),
    .o_clock_add_gap         (                        ),
    .o_clock_add_gap_sign    (                        ),
    .o_clock_add_gap_valid   (                        ),
    .i_sync_out_t5           (                        ),
    .i_forwardtime_valid     (                        ),
    .o_forward_time          (                        ),
    .o_forward_time_valid    (                        ),
    .i_pdelay_t0             (                        ),
    .i_pdelay_t1             (                        ),
    .i_pdelay_t2             (                        ),
    .i_pdelay_t3             (                        ),
    .i_pdelaytime_valid      (                        ),
    .o_pdelay_time           (                        ),
    .o_pdelay_time_valid     (                        )
);

endmodule 