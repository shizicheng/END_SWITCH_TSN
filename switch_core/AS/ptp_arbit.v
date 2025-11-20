/*
    时钟同步的数据流存储在RX——MAC ， 缓存中有数据时，向PTP模块请求输入数据 req ，以及对应数据的metadata,根据metadata确定是不是自己模块需要的数据
    如果是ptp的报文数据，本模块给出ack脉冲，rx_mac则将对应的报文数据流通过对应的axi接口输入进来，并且再次同步输入进来matadata。
    如果开始进行一个端口的时钟同步流程后，需要这个端口的全部流程走完后，才能进行下一个端口的时钟同步，所以ack信号应该注意当前是否正在运行其他通道的
    时钟同步流程。
    如果同时收到了多个请求，则优先级按照端口0->端口7依次变小。


*/


module ptp_arbit#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        , 
    parameter                                                   TIMESTAMP_WIDTH         =      80       ,
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*-------------------- RXMAC 输入数据流 -----------------------*/
`ifdef CPU_MAC
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac0_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac0_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac0_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac0_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac0_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac0_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac0_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac0_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac0_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx0_req                     , // 通道输入请求
    output             wire                                     o_tx0_ack                     , // 通道请求应答
`endif
`ifdef MAC1
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac1_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac1_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac1_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac1_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac1_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac1_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac1_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac1_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac1_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx1_req                     , // 通道输入请求
    output             wire                                     o_tx1_ack                     , // 通道请求应答
`endif
`ifdef MAC2
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac2_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac2_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac2_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac2_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac2_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac2_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac2_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac2_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac2_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx2_req                     , // 通道输入请求
    output             wire                                     o_tx2_ack                     , // 通道请求应答
`endif
`ifdef MAC3
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac3_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac3_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac3_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac3_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac3_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac3_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac3_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac3_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac3_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx3_req                     , // 通道输入请求
    output             wire                                     o_tx3_ack                     , // 通道请求应答
`endif
`ifdef MAC4
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac4_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac4_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac4_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac4_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac4_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac4_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac4_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac4_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac4_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx4_req                     , // 通道输入请求
    output             wire                                     o_tx4_ack                     , // 通道请求应答
`endif
`ifdef MAC5
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac5_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac5_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac5_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac5_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac5_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac5_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac5_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac5_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac5_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx5_req                     , // 通道输入请求
    output             wire                                     o_tx5_ack                     , // 通道请求应答
`endif
`ifdef MAC6
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac6_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac6_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac6_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac6_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac6_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac6_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac6_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac6_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac6_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx6_req                     , // 通道输入请求
    output             wire                                     o_tx6_ack                     , // 通道请求应答
`endif
`ifdef MAC7
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    input               wire                                    i_mac7_port_link              , // 端口的连接状态 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac7_port_axi_data          , // 端口数据流
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac7_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac7_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac7_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac7_axi_data_last          , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    input              wire   [METADATA_WIDTH-1:0]              i_mac7_metadata               , // 总线 metadata 数据
    input              wire                                     i_mac7_metadata_valid         , // 总线 metadata 数据有效信号
    input              wire                                     i_mac7_metadata_last          , // 信息流结束标识 

    input              wire                                     i_tx7_req                     , // 通道输入请求
    output             wire                                     o_tx7_ack                     , // 通道请求应答
`endif

    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    output              wire                                    o_tsn_as_port_link            , // 端口的连接状态 
    output              wire   [CROSS_DATA_WIDTH:0]             o_tsn_as_port_axi_data        , // 端口数据流
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_tsn_as_axi_data_keep        , // 端口数据流掩码，有效字节指示
    output              wire                                    o_tsn_as_axi_data_valid       , // 端口数据有效
    input               wire                                    i_tsn_as_axi_data_ready       , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_tsn_as_axi_data_last        , // 数据流结束标识
    input               wire                                    i_tsn_as_channel_end          , // 该通道结束一轮同步，可以开始下一个通道的发送了
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_tsn_as_metadata             , // 总线 metadata 数据  
    output              wire                                    o_tsn_as_metadata_valid       , // 总线 metadata 数据有效信号
    output              wire                                    o_tsn_as_metadata_last          // 信息流结束标识 

    // metadata as需要字段
    // [51:44](8bit) : acl_frmtype
    // [26:19](8bit) : 输入端口，bitmap表示
    // [10:4](7bit)  ：time_stamp_addr，报文时间戳的地址信息

);



`include "synth_cmd_define.vh"


endmodule