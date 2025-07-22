`include "synth_cmd_define.vh"

module key_arbit#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,   
`ifdef CPU_MAC
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac_cpu_hash_key                 , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac_cpu                          , // 目的 mac 的值
    input               wire                                    i_dmac_cpu_vld                      , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac_cpu_hash_key                 , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac_cpu                          , // 源 mac 的值
    input               wire                                    i_smac_cpu_vld                      , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 tx_cpu_port                         ,
    output              wire                                    tx_cpu_port_vld                     ,
`endif
`ifdef MAC0
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac0_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac0                             , // 目的 mac 的值
    input               wire                                    i_dmac0_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac0_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac0                             , // 源 mac 的值
    input               wire                                    i_smac0_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_0_port                         ,
    output              wire                                    o_tx_0_port_vld                     ,
`endif  
`ifdef MAC1
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac1_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac1                             , // 目的 mac 的值
    input               wire                                    i_dmac1_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac1_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac1                             , // 源 mac 的值
    input               wire                                    i_smac1_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_1_port                         ,
    output              wire                                    o_tx_1_port_vld                     ,
`endif  
`ifdef MAC2
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac2_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac2                             , // 目的 mac 的值
    input               wire                                    i_dmac2_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac2_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac2                             , // 源 mac 的值
    input               wire                                    i_smac2_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_2_port                         ,
    output              wire                                    o_tx_2_port_vld                     ,
`endif
`ifdef MAC3
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac3_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac3                             , // 目的 mac 的值
    input               wire                                    i_dmac3_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac3_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac3                             , // 源 mac 的值
    input               wire                                    i_smac3_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_3_port                          ,
    output              wire                                    o_tx_3_port_vld                      ,
`endif
`ifdef MAC4
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac4_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac4                             , // 目的 mac 的值
    input               wire                                    i_dmac4_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac4_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac4                             , // 源 mac 的值
    input               wire                                    i_smac4_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_4_port                         ,
    output              wire                                    o_tx_4_port_vld                     ,
`endif
`ifdef MAC5
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac5_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac5                             , // 目的 mac 的值
    input               wire                                    i_dmac5_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac5_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac5                             , // 源 mac 的值
    input               wire                                    i_smac5_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_5_port                         ,
    output              wire                                    o_tx_5_port_vld                     ,
`endif
`ifdef MAC6
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac6_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac6                             , // 目的 mac 的值
    input               wire                                    i_dmac6_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac6_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac6                             , // 源 mac 的值
    input               wire                                    i_smac6_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_6_port                         ,
    output              wire                                    o_tx_6_port_vld                     ,
`endif
`ifdef MAC7
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac7_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac7                             , // 目的 mac 的值
    input               wire                                    i_dmac7_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac7_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac7                             , // 源 mac 的值
    input               wire                                    i_smac7_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_7_port                         ,
    output              wire                                    o_tx_7_port_vld                     ,
`endif
`ifdef MAC8
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac8_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac8                             , // 目的 mac 的值
    input               wire                                    i_dmac8_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac8_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac8                             , // 源 mac 的值
    input               wire                                    i_smac8_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_8_port                         ,
    output              wire                                    o_tx_8_port_vld                     ,
`endif
    /*---------------------------------------- 仲裁输出 -------------------------------------------*/
    output              wire   [PORT_NUM - 1:0]                 o_dmac_port                         , // 仲裁的端口 
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac_hash_key                     , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac                              , // 目的 mac 的值
    output              wire                                    o_dmac_vld                          , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac_hash_key                     , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac                              , // 源 mac 的值
    output              wire                                    o_smac_vld                          , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_port                           ,
    input               wire                                    i_tx_port_vld                        
    
);


endmodule