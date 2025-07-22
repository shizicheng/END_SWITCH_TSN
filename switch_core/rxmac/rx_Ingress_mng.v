`include "synth_cmd_define.vh"

module rx_Ingress_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽 
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
`ifdef CPU_MAC
    input              wire                                     i_mac0_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac0_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac0_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac0_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac0_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac0_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac0_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross0_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross0_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross0_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross0_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC1
    input              wire                                     i_mac1_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac1_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac1_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac1_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac1_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac1_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac1_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross1_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross1_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross1_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross1_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC2
    input              wire                                     i_mac2_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac2_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac2_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac2_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac2_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac2_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac2_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross2_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross2_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross2_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross2_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC3
    input              wire                                     i_mac3_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac3_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac3_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac3_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac3_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac3_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac3_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross3_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross3_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross3_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross3_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC4
    input              wire                                     i_mac4_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac4_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac4_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac4_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac4_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac4_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac4_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross4_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross4_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross4_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross4_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC5
    input              wire                                     i_mac5_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac5_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac5_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac5_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac5_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac5_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac5_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross5_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross5_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross5_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross5_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC6
    input              wire                                     i_mac6_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac6_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac6_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac6_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac6_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac6_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac6_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross6_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross6_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross6_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross6_metadata_ready             , // 下游模块反压流水线 
`endif

`ifdef MAC7
    input              wire                                     i_mac7_cross_port_link              , // 端口的连接状态
    input              wire   [1:0]                             i_mac7_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]              i_mac7_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_mac7_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input              wire                                     i_mac7_cross_axi_data_valid         , // 端口数据有效
    output             wire                                     o_mac7_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input              wire                                     i_mac7_cross_axi_data_last          , // 数据流结束标识
    
    input             wire   [METADATA_WIDTH-1:0]               i_cross7_metadata                   , // 聚合总线 metadata 数据
    input             wire                                      i_cross7_metadata_valid             , // 聚合总线 metadata 数据有效信号
    input             wire                                      i_cross7_metadata_last              , // 信息流结束标识
    output            wire                                      o_cross7_metadata_ready             , // 下游模块反压流水线 
`endif

    output             wire                                     o_mac_Ingress_port_link              , // 端口的连接状态
    output             wire   [1:0]                             o_mac_Ingress_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output             wire   [CROSS_DATA_WIDTH:0]              o_mac_Ingress_port_axi_data          , // 端口数据流，最高位表示crcerr
    output             wire   [(CROSS_DATA_WIDTH/8)-1:0]        o_mac_Ingress_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output             wire                                     o_mac_Ingress_axi_data_valid         , // 端口数据有效
    input              wire                                     i_mac_Ingress_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output             wire                                     o_mac_Ingress_axi_data_last          , // 数据流结束标识
    
    output             wire   [METADATA_WIDTH-1:0]              o_Ingress_metadata                   , // 聚合总线 metadata 数据
    output             wire                                     o_Ingress_metadata_valid             , // 聚合总线 metadata 数据有效信号
    output             wire                                     o_Ingress_metadata_last              , // 信息流结束标识
    input              wire                                     i_Ingress_metadata_ready              // 下游模块反压流水线 
);




endmodule