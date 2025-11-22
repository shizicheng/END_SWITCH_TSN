`include "synth_cmd_define.vh"

`timescale 1ns / 1ps

module tb_crossbar;

    // Parameters
    // parameter PORTS = 2;
    // parameter PORTS_BIT = $clog2(PORTS);
    // parameter AXIS_DATA_WIDTH = 512;
    // parameter AXIS_KEEP_WIDTH = AXIS_DATA_WIDTH/8;
    // parameter PKT_METADATA_WIDTH = 1024;
    // parameter TIME_SLICE = 25;
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ;  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ;  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ;  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ;
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ;
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH; // 聚合总线输出 


  
    reg                                                 i_mac0_cross_port_link     ;
    reg                       [1:0]                     i_mac0_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]      i_mac0_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac0_cross_axi_data_keep ;
    reg                                                 i_mac0_cross_axi_data_valid;
    wire                                                o_mac0_cross_axi_data_ready;
    reg                                                 i_mac0_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]      i_mac0_cross_metadata      ;
    reg                                                 i_mac0_cross_metadata_valid;
    reg                                                 i_mac0_cross_metadata_last ;
    wire                                                o_mac0_cross_metadata_ready;
    reg                                                 i_tx0_req                  ;
    wire                                                o_mac0_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx0_ack_rst         ;
    wire                                                o_mac0_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx1_ack_rst         ;
    wire                                                o_mac0_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx2_ack_rst         ;
    wire                                                o_mac0_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx3_ack_rst         ;
    wire                                                o_mac0_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx4_ack_rst         ;
    wire                                                o_mac0_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx5_ack_rst         ;
    wire                                                o_mac0_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx6_ack_rst         ;
    wire                                                o_mac0_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac0_tx7_ack_rst         ;

    reg                                                 i_mac1_cross_port_link     ;
    reg                       [1:0]                     i_mac1_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]      i_mac1_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac1_cross_axi_data_keep ;
    reg                                                 i_mac1_cross_axi_data_valid;
    wire                                                o_mac1_cross_axi_data_ready;
    reg                                                 i_mac1_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]      i_mac1_cross_metadata      ;
    reg                                                 i_mac1_cross_metadata_valid;
    reg                                                 i_mac1_cross_metadata_last ;
    wire                                                o_mac1_cross_metadata_ready;
    reg                                                 i_tx1_req                  ;
    wire                                                o_mac1_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx0_ack_rst         ;
    wire                                                o_mac1_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx1_ack_rst         ;
    wire                                                o_mac1_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx2_ack_rst         ;
    wire                                                o_mac1_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx3_ack_rst         ;
    wire                                                o_mac1_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx4_ack_rst         ;
    wire                                                o_mac1_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx5_ack_rst         ;
    wire                                                o_mac1_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx6_ack_rst         ;
    wire                                                o_mac1_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac1_tx7_ack_rst         ;
    reg                                                 i_mac2_cross_port_link     ;
    reg                       [1:0]                     i_mac2_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]      i_mac2_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac2_cross_axi_data_keep ;
    reg                                                 i_mac2_cross_axi_data_valid;
    wire                                                o_mac2_cross_axi_data_ready;
    reg                                                 i_mac2_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]      i_mac2_cross_metadata      ;
    reg                                                 i_mac2_cross_metadata_valid;
    reg                                                 i_mac2_cross_metadata_last ;
    wire                                                o_mac2_cross_metadata_ready;
    reg                                                 i_tx2_req                  ;
    wire                                                o_mac2_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac2_tx0_ack_rst         ;
    wire                                                o_mac2_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac2_tx1_ack_rst         ;
    wire                                                o_mac2_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]   o_mac2_tx2_ack_rst         ;
    wire                                                o_mac2_tx3_ack             ;
    wire               [PORT_FIFO_PRI_NUM-1: 0]         o_mac2_tx3_ack_rst          ;
    wire                                                o_mac2_tx4_ack              ;
    wire               [PORT_FIFO_PRI_NUM-1: 0]         o_mac2_tx4_ack_rst          ;
    wire                                                o_mac2_tx5_ack              ;
    wire               [PORT_FIFO_PRI_NUM-1: 0]        o_mac2_tx5_ack_rst          ;
    wire                                                o_mac2_tx6_ack              ;
    wire               [PORT_FIFO_PRI_NUM-1: 0]        o_mac2_tx6_ack_rst          ;
    wire                                                o_mac2_tx7_ack              ;
    wire               [PORT_FIFO_PRI_NUM-1: 0]        o_mac2_tx7_ack_rst          ;
    reg                                                 i_mac3_cross_port_link      ;
    reg                [   1: 0]                        i_mac3_cross_port_speed     ;
    reg                [CROSS_DATA_WIDTH: 0]            i_mac3_cross_port_axi_data  ;
    reg                [(CROSS_DATA_WIDTH/8)-1: 0]        i_mac3_cross_axi_data_keep  ;
    reg                                 i_mac3_cross_axi_data_valid  ;
    wire                                o_mac3_cross_axi_data_ready  ;
    reg                                 i_mac3_cross_axi_data_last  ;
    reg                       [METADATA_WIDTH-1:0]i_mac3_cross_metadata      ;
    reg                                        i_mac3_cross_metadata_valid;
    reg                                        i_mac3_cross_metadata_last ;
    wire                                       o_mac3_cross_metadata_ready;
    reg                                        i_tx3_req                  ;
    wire                                       o_mac3_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx0_ack_rst         ;
    wire                                       o_mac3_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx1_ack_rst         ;
    wire                                       o_mac3_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx2_ack_rst         ;
    wire                                       o_mac3_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx3_ack_rst         ;
    wire                                       o_mac3_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx4_ack_rst         ;
    wire                                       o_mac3_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx5_ack_rst         ;
    wire                                       o_mac3_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx6_ack_rst         ;
    wire                                       o_mac3_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_tx7_ack_rst         ;
    reg                                        i_mac4_cross_port_link     ;
    reg                       [1:0]            i_mac4_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]i_mac4_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac4_cross_axi_data_keep ;
    reg                                        i_mac4_cross_axi_data_valid;
    wire                                       o_mac4_cross_axi_data_ready;
    reg                                        i_mac4_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]i_mac4_cross_metadata      ;
    reg                                        i_mac4_cross_metadata_valid;
    reg                                        i_mac4_cross_metadata_last ;
    wire                                       o_mac4_cross_metadata_ready;
    reg                                        i_tx4_req                  ;
    wire                                       o_mac4_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx0_ack_rst         ;
    wire                                       o_mac4_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx1_ack_rst         ;
    wire                                       o_mac4_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx2_ack_rst         ;
    wire                                       o_mac4_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx3_ack_rst         ;
    wire                                       o_mac4_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx4_ack_rst         ;
    wire                                       o_mac4_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx5_ack_rst         ;
    wire                                       o_mac4_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx6_ack_rst         ;
    wire                                       o_mac4_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_tx7_ack_rst         ;
    reg                                        i_mac5_cross_port_link     ;
    reg                       [1:0]            i_mac5_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]i_mac5_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac5_cross_axi_data_keep ;
    reg                                        i_mac5_cross_axi_data_valid;
    wire                                       o_mac5_cross_axi_data_ready;
    reg                                        i_mac5_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]i_mac5_cross_metadata      ;
    reg                                        i_mac5_cross_metadata_valid;
    reg                                        i_mac5_cross_metadata_last ;
    wire                                       o_mac5_cross_metadata_ready;
    reg                                        i_tx5_req                  ;
    wire                                       o_mac5_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx0_ack_rst         ;
    wire                                       o_mac5_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx1_ack_rst         ;
    wire                                       o_mac5_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx2_ack_rst         ;
    wire                                       o_mac5_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx3_ack_rst         ;
    wire                                       o_mac5_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx4_ack_rst         ;
    wire                                       o_mac5_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx5_ack_rst         ;
    wire                                       o_mac5_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx6_ack_rst         ;
    wire                                       o_mac5_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_tx7_ack_rst         ;
    reg                                        i_mac6_cross_port_link     ;
    reg                       [1:0]            i_mac6_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]i_mac6_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac6_cross_axi_data_keep ;
    reg                                        i_mac6_cross_axi_data_valid;
    wire                                       o_mac6_cross_axi_data_ready;
    reg                                        i_mac6_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]i_mac6_cross_metadata      ;
    reg                                        i_mac6_cross_metadata_valid;
    reg                                        i_mac6_cross_metadata_last ;
    wire                                       o_mac6_cross_metadata_ready;
    reg                                        i_tx6_req                  ;
    wire                                       o_mac6_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx0_ack_rst         ;
    wire                                       o_mac6_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx1_ack_rst         ;
    wire                                       o_mac6_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx2_ack_rst         ;
    wire                                       o_mac6_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx3_ack_rst         ;
    wire                                       o_mac6_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx4_ack_rst         ;
    wire                                       o_mac6_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx5_ack_rst         ;
    wire                                       o_mac6_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx6_ack_rst         ;
    wire                                       o_mac6_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_tx7_ack_rst         ;
    reg                                        i_mac7_cross_port_link     ;
    reg                       [1:0]            i_mac7_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]i_mac7_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_mac7_cross_axi_data_keep ;
    reg                                        i_mac7_cross_axi_data_valid;
    wire                                       o_mac7_cross_axi_data_ready;
    reg                                        i_mac7_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]i_mac7_cross_metadata      ;
    reg                                        i_mac7_cross_metadata_valid;
    reg                                        i_mac7_cross_metadata_last ;
    wire                                       o_mac7_cross_metadata_ready;
    reg                                        i_tx7_req                  ;
    wire                                       o_mac7_tx0_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx0_ack_rst         ;
    wire                                       o_mac7_tx1_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx1_ack_rst         ;
    wire                                       o_mac7_tx2_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx2_ack_rst         ;
    wire                                       o_mac7_tx3_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx3_ack_rst         ;
    wire                                       o_mac7_tx4_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx4_ack_rst         ;
    wire                                       o_mac7_tx5_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx5_ack_rst         ;
    wire                                       o_mac7_tx6_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx6_ack_rst         ;
    wire                                       o_mac7_tx7_ack             ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_tx7_ack_rst         ;
    reg                                        i_tsn_as_cross_port_link   ;
    reg                       [1:0]            i_tsn_as_cross_port_speed  ;
    reg                       [CROSS_DATA_WIDTH:0]i_tsn_as_cross_port_axi_data;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_tsn_as_cross_axi_data_keep;
    reg                                        i_tsn_as_cross_axi_data_valid;
    wire                                       o_tsn_as_cross_axi_data_ready;
    reg                                        i_tsn_as_cross_axi_data_last;
    reg                       [METADATA_WIDTH-1:0]i_tsn_as_cross_metadata    ;
    reg                                        i_tsn_as_cross_metadata_valid;
    reg                                        i_tsn_as_cross_metadata_last;
    wire                                       o_tsn_as_cross_metadata_ready;
    reg                                        i_tsn_as_tx_req            ;
    wire                                       o_tsn_as_tx_ack            ;
    reg                                        i_lldp_cross_port_link     ;
    reg                       [1:0]            i_lldp_cross_port_speed    ;
    reg                       [CROSS_DATA_WIDTH:0]i_lldp_cross_port_axi_data ;
    reg                       [(CROSS_DATA_WIDTH/8)-1:0]i_lldp_cross_axi_data_keep ;
    reg                                        i_lldp_cross_axi_data_valid;
    wire                                       o_lldp_cross_axi_data_ready;
    reg                                        i_lldp_cross_axi_data_last ;
    reg                       [METADATA_WIDTH-1:0]i_lldp_cross_metadata      ;
    reg                                        i_lldp_cross_metadata_valid;
    reg                                        i_lldp_cross_metadata_last ;
    wire                                       o_lldp_cross_metadata_ready;
    reg                                        i_lldp_tx_req              ;
    wire                                       o_lldp_tx_ack              ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac0_tx_axis_data       ;
    wire                      [15:0]           o_pmac0_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac0_tx_axis_keep       ;
    wire                                       o_pmac0_tx_axis_last       ;
    wire                                       o_pmac0_tx_axis_valid      ;
    reg                                        i_pmac0_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac0_tx_axis_data       ;
    wire                      [15:0]           o_emac0_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac0_tx_axis_keep       ;
    wire                                       o_emac0_tx_axis_last       ;
    wire                                       o_emac0_tx_axis_valid      ;
    reg                                        i_emac0_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac0_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac0_scheduing_rst       ;
    reg                                        i_mac0_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac1_tx_axis_data       ;
    wire                      [15:0]           o_pmac1_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac1_tx_axis_keep       ;
    wire                                       o_pmac1_tx_axis_last       ;
    wire                                       o_pmac1_tx_axis_valid      ;
    reg                                        i_pmac1_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac1_tx_axis_data       ;
    wire                      [15:0]           o_emac1_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac1_tx_axis_keep       ;
    wire                                       o_emac1_tx_axis_last       ;
    wire                                       o_emac1_tx_axis_valid      ;
    reg                                        i_emac1_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac1_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac1_scheduing_rst       ;
    reg                                        i_mac1_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac2_tx_axis_data       ;
    wire                      [15:0]           o_pmac2_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac2_tx_axis_keep       ;
    wire                                       o_pmac2_tx_axis_last       ;
    wire                                       o_pmac2_tx_axis_valid      ;
    reg                                        i_pmac2_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac2_tx_axis_data       ;
    wire                      [15:0]           o_emac2_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac2_tx_axis_keep       ;
    wire                                       o_emac2_tx_axis_last       ;
    wire                                       o_emac2_tx_axis_valid      ;
    reg                                        i_emac2_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac2_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac2_scheduing_rst       ;
    reg                                        i_mac2_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac3_tx_axis_data       ;
    wire                      [15:0]           o_pmac3_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac3_tx_axis_keep       ;
    wire                                       o_pmac3_tx_axis_last       ;
    wire                                       o_pmac3_tx_axis_valid      ;
    reg                                        i_pmac3_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac3_tx_axis_data       ;
    wire                      [15:0]           o_emac3_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac3_tx_axis_keep       ;
    wire                                       o_emac3_tx_axis_last       ;
    wire                                       o_emac3_tx_axis_valid      ;
    reg                                        i_emac3_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac3_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac3_scheduing_rst       ;
    reg                                        i_mac3_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac4_tx_axis_data       ;
    wire                      [15:0]           o_pmac4_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac4_tx_axis_keep       ;
    wire                                       o_pmac4_tx_axis_last       ;
    wire                                       o_pmac4_tx_axis_valid      ;
    reg                                        i_pmac4_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac4_tx_axis_data       ;
    wire                      [15:0]           o_emac4_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac4_tx_axis_keep       ;
    wire                                       o_emac4_tx_axis_last       ;
    wire                                       o_emac4_tx_axis_valid      ;
    reg                                        i_emac4_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac4_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac4_scheduing_rst       ;
    reg                                        i_mac4_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac5_tx_axis_data       ;
    wire                      [15:0]           o_pmac5_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac5_tx_axis_keep       ;
    wire                                       o_pmac5_tx_axis_last       ;
    wire                                       o_pmac5_tx_axis_valid      ;
    reg                                        i_pmac5_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac5_tx_axis_data       ;
    wire                      [15:0]           o_emac5_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac5_tx_axis_keep       ;
    wire                                       o_emac5_tx_axis_last       ;
    wire                                       o_emac5_tx_axis_valid      ;
    reg                                        i_emac5_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac5_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac5_scheduing_rst       ;
    reg                                        i_mac5_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac6_tx_axis_data       ;
    wire                      [15:0]           o_pmac6_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac6_tx_axis_keep       ;
    wire                                       o_pmac6_tx_axis_last       ;
    wire                                       o_pmac6_tx_axis_valid      ;
    reg                                        i_pmac6_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac6_tx_axis_data       ;
    wire                      [15:0]           o_emac6_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac6_tx_axis_keep       ;
    wire                                       o_emac6_tx_axis_last       ;
    wire                                       o_emac6_tx_axis_valid      ;
    reg                                        i_emac6_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac6_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac6_scheduing_rst       ;
    reg                                        i_mac6_scheduing_rst_vld   ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_pmac7_tx_axis_data       ;
    wire                      [15:0]           o_pmac7_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_pmac7_tx_axis_keep       ;
    wire                                       o_pmac7_tx_axis_last       ;
    wire                                       o_pmac7_tx_axis_valid      ;
    reg                                        i_pmac7_tx_axis_ready      ;
    wire                      [CROSS_DATA_WIDTH - 1:0]o_emac7_tx_axis_data       ;
    wire                      [15:0]           o_emac7_tx_axis_user       ;
    wire                      [(CROSS_DATA_WIDTH/8)-1:0]o_emac7_tx_axis_keep       ;
    wire                                       o_emac7_tx_axis_last       ;
    wire                                       o_emac7_tx_axis_valid      ;
    reg                                        i_emac7_tx_axis_ready      ;
    wire                      [PORT_FIFO_PRI_NUM-1:0]o_mac7_fifoc_empty         ;
    reg                       [PORT_FIFO_PRI_NUM-1:0]i_mac7_scheduing_rst       ;
    reg                                        i_mac7_scheduing_rst_vld   ;
    reg                                        i_clk                      ;
    reg                                        i_rst                      ;

crossbar_switch_top#(
   .REG_ADDR_BUS_WIDTH  (8              ),
   .REG_DATA_BUS_WIDTH  (16             ),
   .METADATA_WIDTH      (64             ),
   .PORT_MNG_DATA_WIDTH (8              ),
   .PORT_FIFO_PRI_NUM   (8              ),
   .CROSS_DATA_WIDTH    (8              )
)
 u_crossbar_switch_top(
/*-------------------- RXMAC 输入数据流 -----------------------*/

/*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .i_mac0_cross_port_link             (i_mac0_cross_port_link    ),// 端口的连接状态
    .i_mac0_cross_port_speed            (i_mac0_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac0_cross_port_axi_data         (i_mac0_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac0_cross_axi_data_keep         (i_mac0_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac0_cross_axi_data_valid        (i_mac0_cross_axi_data_valid),// 端口数据有效
    .o_mac0_cross_axi_data_ready        (o_mac0_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac0_cross_axi_data_last         (i_mac0_cross_axi_data_last),// 数据流结束标识
    .i_mac0_cross_metadata              (i_mac0_cross_metadata     ),// 总线 metadata 数据
    .i_mac0_cross_metadata_valid        (i_mac0_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac0_cross_metadata_last         (i_mac0_cross_metadata_last),// 信息流结束标识
    .o_mac0_cross_metadata_ready        (o_mac0_cross_metadata_ready),// 下游模块反压流水线
    .i_tx0_req                          (i_tx0_req                 ),// RXMAC的请求信号
    .o_mac0_tx0_ack                     (o_mac0_tx0_ack            ),// 响应使能信号
    .o_mac0_tx0_ack_rst                 (o_mac0_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx1_ack                     (o_mac0_tx1_ack            ),// 响应使能信号
    .o_mac0_tx1_ack_rst                 (o_mac0_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx2_ack                     (o_mac0_tx2_ack            ),// 响应使能信号
    .o_mac0_tx2_ack_rst                 (o_mac0_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx3_ack                     (o_mac0_tx3_ack            ),// 响应使能信号
    .o_mac0_tx3_ack_rst                 (o_mac0_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx4_ack                     (o_mac0_tx4_ack            ),// 响应使能信号
    .o_mac0_tx4_ack_rst                 (o_mac0_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx5_ack                     (o_mac0_tx5_ack            ),// 响应使能信号
    .o_mac0_tx5_ack_rst                 (o_mac0_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx6_ack                     (o_mac0_tx6_ack            ),// 响应使能信号
    .o_mac0_tx6_ack_rst                 (o_mac0_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac0_tx7_ack                     (o_mac0_tx7_ack            ),// 响应使能信号
    .o_mac0_tx7_ack_rst                 (o_mac0_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac1_cross_port_link             (i_mac1_cross_port_link    ),// 端口的连接状态
    .i_mac1_cross_port_speed            (i_mac1_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac1_cross_port_axi_data         (i_mac1_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac1_cross_axi_data_keep         (i_mac1_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac1_cross_axi_data_valid        (i_mac1_cross_axi_data_valid),// 端口数据有效
    .o_mac1_cross_axi_data_ready        (o_mac1_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac1_cross_axi_data_last         (i_mac1_cross_axi_data_last),// 数据流结束标识
    .i_mac1_cross_metadata              (i_mac1_cross_metadata     ),// 总线 metadata 数据
    .i_mac1_cross_metadata_valid        (i_mac1_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac1_cross_metadata_last         (i_mac1_cross_metadata_last),// 信息流结束标识
    .o_mac1_cross_metadata_ready        (o_mac1_cross_metadata_ready),// 下游模块反压流水线
    .i_tx1_req                          (i_tx1_req                 ),
    .o_mac1_tx0_ack                     (o_mac1_tx0_ack            ),// 响应使能信号
    .o_mac1_tx0_ack_rst                 (o_mac1_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx1_ack                     (o_mac1_tx1_ack            ),// 响应使能信号
    .o_mac1_tx1_ack_rst                 (o_mac1_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx2_ack                     (o_mac1_tx2_ack            ),// 响应使能信号
    .o_mac1_tx2_ack_rst                 (o_mac1_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx3_ack                     (o_mac1_tx3_ack            ),// 响应使能信号
    .o_mac1_tx3_ack_rst                 (o_mac1_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx4_ack                     (o_mac1_tx4_ack            ),// 响应使能信号
    .o_mac1_tx4_ack_rst                 (o_mac1_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx5_ack                     (o_mac1_tx5_ack            ),// 响应使能信号
    .o_mac1_tx5_ack_rst                 (o_mac1_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx6_ack                     (o_mac1_tx6_ack            ),// 响应使能信号
    .o_mac1_tx6_ack_rst                 (o_mac1_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac1_tx7_ack                     (o_mac1_tx7_ack            ),// 响应使能信号
    .o_mac1_tx7_ack_rst                 (o_mac1_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac2_cross_port_link             (i_mac2_cross_port_link    ),// 端口的连接状态
    .i_mac2_cross_port_speed            (i_mac2_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac2_cross_port_axi_data         (i_mac2_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac2_cross_axi_data_keep         (i_mac2_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac2_cross_axi_data_valid        (i_mac2_cross_axi_data_valid),// 端口数据有效
    .o_mac2_cross_axi_data_ready        (o_mac2_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac2_cross_axi_data_last         (i_mac2_cross_axi_data_last),// 数据流结束标识
    .i_mac2_cross_metadata              (i_mac2_cross_metadata     ),// 总线 metadata 数据
    .i_mac2_cross_metadata_valid        (i_mac2_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac2_cross_metadata_last         (i_mac2_cross_metadata_last),// 信息流结束标识
    .o_mac2_cross_metadata_ready        (o_mac2_cross_metadata_ready),// 下游模块反压流水线
    .i_tx2_req                          (i_tx2_req                 ),
    .o_mac2_tx0_ack                     (o_mac2_tx0_ack            ),// 响应使能信号
    .o_mac2_tx0_ack_rst                 (o_mac2_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx1_ack                     (o_mac2_tx1_ack            ),// 响应使能信号
    .o_mac2_tx1_ack_rst                 (o_mac2_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx2_ack                     (o_mac2_tx2_ack            ),// 响应使能信号
    .o_mac2_tx2_ack_rst                 (o_mac2_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx3_ack                     (o_mac2_tx3_ack            ),// 响应使能信号
    .o_mac2_tx3_ack_rst                 (o_mac2_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx4_ack                     (o_mac2_tx4_ack            ),// 响应使能信号
    .o_mac2_tx4_ack_rst                 (o_mac2_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx5_ack                     (o_mac2_tx5_ack            ),// 响应使能信号
    .o_mac2_tx5_ack_rst                 (o_mac2_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx6_ack                     (o_mac2_tx6_ack            ),// 响应使能信号
    .o_mac2_tx6_ack_rst                 (o_mac2_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac2_tx7_ack                     (o_mac2_tx7_ack            ),// 响应使能信号
    .o_mac2_tx7_ack_rst                 (o_mac2_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac3_cross_port_link             (i_mac3_cross_port_link    ),// 端口的连接状态
    .i_mac3_cross_port_speed            (i_mac3_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac3_cross_port_axi_data         (i_mac3_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac3_cross_axi_data_keep         (i_mac3_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac3_cross_axi_data_valid        (i_mac3_cross_axi_data_valid),// 端口数据有效
    .o_mac3_cross_axi_data_ready        (o_mac3_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac3_cross_axi_data_last         (i_mac3_cross_axi_data_last),// 数据流结束标识
    .i_mac3_cross_metadata              (i_mac3_cross_metadata     ),// 总线 metadata 数据
    .i_mac3_cross_metadata_valid        (i_mac3_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac3_cross_metadata_last         (i_mac3_cross_metadata_last),// 信息流结束标识
    .o_mac3_cross_metadata_ready        (o_mac3_cross_metadata_ready),// 下游模块反压流水线
    .i_tx3_req                          (i_tx3_req                 ),
    .o_mac3_tx0_ack                     (o_mac3_tx0_ack            ),// 响应使能信号
    .o_mac3_tx0_ack_rst                 (o_mac3_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx1_ack                     (o_mac3_tx1_ack            ),// 响应使能信号
    .o_mac3_tx1_ack_rst                 (o_mac3_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx2_ack                     (o_mac3_tx2_ack            ),// 响应使能信号
    .o_mac3_tx2_ack_rst                 (o_mac3_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx3_ack                     (o_mac3_tx3_ack            ),// 响应使能信号
    .o_mac3_tx3_ack_rst                 (o_mac3_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx4_ack                     (o_mac3_tx4_ack            ),// 响应使能信号
    .o_mac3_tx4_ack_rst                 (o_mac3_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx5_ack                     (o_mac3_tx5_ack            ),// 响应使能信号
    .o_mac3_tx5_ack_rst                 (o_mac3_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx6_ack                     (o_mac3_tx6_ack            ),// 响应使能信号
    .o_mac3_tx6_ack_rst                 (o_mac3_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac3_tx7_ack                     (o_mac3_tx7_ack            ),// 响应使能信号
    .o_mac3_tx7_ack_rst                 (o_mac3_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac4_cross_port_link             (i_mac4_cross_port_link    ),// 端口的连接状态
    .i_mac4_cross_port_speed            (i_mac4_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac4_cross_port_axi_data         (i_mac4_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac4_cross_axi_data_keep         (i_mac4_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac4_cross_axi_data_valid        (i_mac4_cross_axi_data_valid),// 端口数据有效
    .o_mac4_cross_axi_data_ready        (o_mac4_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac4_cross_axi_data_last         (i_mac4_cross_axi_data_last),// 数据流结束标识
    .i_mac4_cross_metadata              (i_mac4_cross_metadata     ),// 总线 metadata 数据
    .i_mac4_cross_metadata_valid        (i_mac4_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac4_cross_metadata_last         (i_mac4_cross_metadata_last),// 信息流结束标识
    .o_mac4_cross_metadata_ready        (o_mac4_cross_metadata_ready),// 下游模块反压流水线
    .i_tx4_req                          (i_tx4_req                 ),
    .o_mac4_tx0_ack                     (o_mac4_tx0_ack            ),// 响应使能信号
    .o_mac4_tx0_ack_rst                 (o_mac4_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx1_ack                     (o_mac4_tx1_ack            ),// 响应使能信号
    .o_mac4_tx1_ack_rst                 (o_mac4_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx2_ack                     (o_mac4_tx2_ack            ),// 响应使能信号
    .o_mac4_tx2_ack_rst                 (o_mac4_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx3_ack                     (o_mac4_tx3_ack            ),// 响应使能信号
    .o_mac4_tx3_ack_rst                 (o_mac4_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx4_ack                     (o_mac4_tx4_ack            ),// 响应使能信号
    .o_mac4_tx4_ack_rst                 (o_mac4_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx5_ack                     (o_mac4_tx5_ack            ),// 响应使能信号
    .o_mac4_tx5_ack_rst                 (o_mac4_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx6_ack                     (o_mac4_tx6_ack            ),// 响应使能信号
    .o_mac4_tx6_ack_rst                 (o_mac4_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac4_tx7_ack                     (o_mac4_tx7_ack            ),// 响应使能信号
    .o_mac4_tx7_ack_rst                 (o_mac4_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac5_cross_port_link             (i_mac5_cross_port_link    ),// 端口的连接状态
    .i_mac5_cross_port_speed            (i_mac5_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac5_cross_port_axi_data         (i_mac5_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac5_cross_axi_data_keep         (i_mac5_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac5_cross_axi_data_valid        (i_mac5_cross_axi_data_valid),// 端口数据有效
    .o_mac5_cross_axi_data_ready        (o_mac5_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac5_cross_axi_data_last         (i_mac5_cross_axi_data_last),// 数据流结束标识
    .i_mac5_cross_metadata              (i_mac5_cross_metadata     ),// 总线 metadata 数据
    .i_mac5_cross_metadata_valid        (i_mac5_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac5_cross_metadata_last         (i_mac5_cross_metadata_last),// 信息流结束标识
    .o_mac5_cross_metadata_ready        (o_mac5_cross_metadata_ready),// 下游模块反压流水线
    .i_tx5_req                          (i_tx5_req                 ),
    .o_mac5_tx0_ack                     (o_mac5_tx0_ack            ),// 响应使能信号
    .o_mac5_tx0_ack_rst                 (o_mac5_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx1_ack                     (o_mac5_tx1_ack            ),// 响应使能信号
    .o_mac5_tx1_ack_rst                 (o_mac5_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx2_ack                     (o_mac5_tx2_ack            ),// 响应使能信号
    .o_mac5_tx2_ack_rst                 (o_mac5_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx3_ack                     (o_mac5_tx3_ack            ),// 响应使能信号
    .o_mac5_tx3_ack_rst                 (o_mac5_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx4_ack                     (o_mac5_tx4_ack            ),// 响应使能信号
    .o_mac5_tx4_ack_rst                 (o_mac5_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx5_ack                     (o_mac5_tx5_ack            ),// 响应使能信号
    .o_mac5_tx5_ack_rst                 (o_mac5_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx6_ack                     (o_mac5_tx6_ack            ),// 响应使能信号
    .o_mac5_tx6_ack_rst                 (o_mac5_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac5_tx7_ack                     (o_mac5_tx7_ack            ),// 响应使能信号
    .o_mac5_tx7_ack_rst                 (o_mac5_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac6_cross_port_link             (i_mac6_cross_port_link    ),// 端口的连接状态
    .i_mac6_cross_port_speed            (i_mac6_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac6_cross_port_axi_data         (i_mac6_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac6_cross_axi_data_keep         (i_mac6_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac6_cross_axi_data_valid        (i_mac6_cross_axi_data_valid),// 端口数据有效
    .o_mac6_cross_axi_data_ready        (o_mac6_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac6_cross_axi_data_last         (i_mac6_cross_axi_data_last),// 数据流结束标识
    .i_mac6_cross_metadata              (i_mac6_cross_metadata     ),// 总线 metadata 数据
    .i_mac6_cross_metadata_valid        (i_mac6_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac6_cross_metadata_last         (i_mac6_cross_metadata_last),// 信息流结束标识
    .o_mac6_cross_metadata_ready        (o_mac6_cross_metadata_ready),// 下游模块反压流水线
    .i_tx6_req                          (i_tx6_req                 ),
    .o_mac6_tx0_ack                     (o_mac6_tx0_ack            ),// 响应使能信号
    .o_mac6_tx0_ack_rst                 (o_mac6_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx1_ack                     (o_mac6_tx1_ack            ),// 响应使能信号
    .o_mac6_tx1_ack_rst                 (o_mac6_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx2_ack                     (o_mac6_tx2_ack            ),// 响应使能信号
    .o_mac6_tx2_ack_rst                 (o_mac6_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx3_ack                     (o_mac6_tx3_ack            ),// 响应使能信号
    .o_mac6_tx3_ack_rst                 (o_mac6_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx4_ack                     (o_mac6_tx4_ack            ),// 响应使能信号
    .o_mac6_tx4_ack_rst                 (o_mac6_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx5_ack                     (o_mac6_tx5_ack            ),// 响应使能信号
    .o_mac6_tx5_ack_rst                 (o_mac6_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx6_ack                     (o_mac6_tx6_ack            ),// 响应使能信号
    .o_mac6_tx6_ack_rst                 (o_mac6_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac6_tx7_ack                     (o_mac6_tx7_ack            ),// 响应使能信号
    .o_mac6_tx7_ack_rst                 (o_mac6_tx7_ack_rst        ),// 端口的优先级向量结果
    .i_mac7_cross_port_link             (i_mac7_cross_port_link    ),// 端口的连接状态
    .i_mac7_cross_port_speed            (i_mac7_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac7_cross_port_axi_data         (i_mac7_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_mac7_cross_axi_data_keep         (i_mac7_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_mac7_cross_axi_data_valid        (i_mac7_cross_axi_data_valid),// 端口数据有效
    .o_mac7_cross_axi_data_ready        (o_mac7_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_mac7_cross_axi_data_last         (i_mac7_cross_axi_data_last),// 数据流结束标识
    .i_mac7_cross_metadata              (i_mac7_cross_metadata     ),// 总线 metadata 数据
    .i_mac7_cross_metadata_valid        (i_mac7_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_mac7_cross_metadata_last         (i_mac7_cross_metadata_last),// 信息流结束标识
    .o_mac7_cross_metadata_ready        (o_mac7_cross_metadata_ready),// 下游模块反压流水线
    .i_tx7_req                          (i_tx7_req                 ),
    .o_mac7_tx0_ack                     (o_mac7_tx0_ack            ),// 响应使能信号
    .o_mac7_tx0_ack_rst                 (o_mac7_tx0_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx1_ack                     (o_mac7_tx1_ack            ),// 响应使能信号
    .o_mac7_tx1_ack_rst                 (o_mac7_tx1_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx2_ack                     (o_mac7_tx2_ack            ),// 响应使能信号
    .o_mac7_tx2_ack_rst                 (o_mac7_tx2_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx3_ack                     (o_mac7_tx3_ack            ),// 响应使能信号
    .o_mac7_tx3_ack_rst                 (o_mac7_tx3_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx4_ack                     (o_mac7_tx4_ack            ),// 响应使能信号
    .o_mac7_tx4_ack_rst                 (o_mac7_tx4_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx5_ack                     (o_mac7_tx5_ack            ),// 响应使能信号
    .o_mac7_tx5_ack_rst                 (o_mac7_tx5_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx6_ack                     (o_mac7_tx6_ack            ),// 响应使能信号
    .o_mac7_tx6_ack_rst                 (o_mac7_tx6_ack_rst        ),// 端口的优先级向量结果
    .o_mac7_tx7_ack                     (o_mac7_tx7_ack            ),// 响应使能信号
    .o_mac7_tx7_ack_rst                 (o_mac7_tx7_ack_rst        ),// 端口的优先级向量结果

`ifdef TSN_AS
    .i_tsn_as_cross_port_link           (i_tsn_as_cross_port_link  ),// 端口的连接状态
    .i_tsn_as_cross_port_speed          (i_tsn_as_cross_port_speed ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_tsn_as_cross_port_axi_data       (i_tsn_as_cross_port_axi_data ),// 端口数据流，最高位表示crcerr
    .i_tsn_as_cross_axi_data_keep       (i_tsn_as_cross_axi_data_keep ),// 端口数据流掩码，有效字节指示
    .i_tsn_as_cross_axi_data_valid      (i_tsn_as_cross_axi_data_valid),// 端口数据有效
    .o_tsn_as_cross_axi_data_ready      (o_tsn_as_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_tsn_as_cross_axi_data_last       (i_tsn_as_cross_axi_data_last ),// 数据流结束标识
    .i_tsn_as_cross_metadata            (i_tsn_as_cross_metadata      ),// 总线 metadata 数据
    .i_tsn_as_cross_metadata_valid      (i_tsn_as_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_tsn_as_cross_metadata_last       (i_tsn_as_cross_metadata_last ),// 信息流结束标识
    .o_tsn_as_cross_metadata_ready      (o_tsn_as_cross_metadata_ready),// 下游模块反压流水线
    .i_tsn_as_tx_req                    (i_tsn_as_tx_req           ),
    .o_tsn_as_tx_ack                    (o_tsn_as_tx_ack           ),
`endif
`ifdef LLDP
    .i_lldp_cross_port_link             (i_lldp_cross_port_link    ),// 端口的连接状态
    .i_lldp_cross_port_speed            (i_lldp_cross_port_speed   ),// 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_lldp_cross_port_axi_data         (i_lldp_cross_port_axi_data),// 端口数据流，最高位表示crcerr
    .i_lldp_cross_axi_data_keep         (i_lldp_cross_axi_data_keep),// 端口数据流掩码，有效字节指示
    .i_lldp_cross_axi_data_valid        (i_lldp_cross_axi_data_valid),// 端口数据有效
    .o_lldp_cross_axi_data_ready        (o_lldp_cross_axi_data_ready),// 交叉总线聚合架构反压流水线信号
    .i_lldp_cross_axi_data_last         (i_lldp_cross_axi_data_last),// 数据流结束标识
    .i_lldp_cross_metadata              (i_lldp_cross_metadata     ),// 总线 metadata 数据
    .i_lldp_cross_metadata_valid        (i_lldp_cross_metadata_valid),// 总线 metadata 数据有效信号
    .i_lldp_cross_metadata_last         (i_lldp_cross_metadata_last),// 信息流结束标识
    .o_lldp_cross_metadata_ready        (o_lldp_cross_metadata_ready),// 下游模块反压流水线
    .i_lldp_tx_req                      (i_lldp_tx_req             ),
    .o_lldp_tx_ack                      (o_lldp_tx_ack             ),
`endif

//pmac通道数据
    .o_pmac0_tx_axis_data               (o_pmac0_tx_axis_data      ),
    .o_pmac0_tx_axis_user               (o_pmac0_tx_axis_user      ),
    .o_pmac0_tx_axis_keep               (o_pmac0_tx_axis_keep      ),
    .o_pmac0_tx_axis_last               (o_pmac0_tx_axis_last      ),
    .o_pmac0_tx_axis_valid              (o_pmac0_tx_axis_valid     ),
    .i_pmac0_tx_axis_ready              (i_pmac0_tx_axis_ready     ),
//emac通道数据
    .o_emac0_tx_axis_data               (o_emac0_tx_axis_data      ),
    .o_emac0_tx_axis_user               (o_emac0_tx_axis_user      ),
    .o_emac0_tx_axis_keep               (o_emac0_tx_axis_keep      ),
    .o_emac0_tx_axis_last               (o_emac0_tx_axis_last      ),
    .o_emac0_tx_axis_valid              (o_emac0_tx_axis_valid     ),
    .i_emac0_tx_axis_ready              (i_emac0_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac0_fifoc_empty                 (o_mac0_fifoc_empty        ),
    .i_mac0_scheduing_rst               (i_mac0_scheduing_rst      ),
    .i_mac0_scheduing_rst_vld           (i_mac0_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac1_tx_axis_data               (o_pmac1_tx_axis_data      ),
    .o_pmac1_tx_axis_user               (o_pmac1_tx_axis_user      ),
    .o_pmac1_tx_axis_keep               (o_pmac1_tx_axis_keep      ),
    .o_pmac1_tx_axis_last               (o_pmac1_tx_axis_last      ),
    .o_pmac1_tx_axis_valid              (o_pmac1_tx_axis_valid     ),
    .i_pmac1_tx_axis_ready              (i_pmac1_tx_axis_ready     ),
//emac通道数据
    .o_emac1_tx_axis_data               (o_emac1_tx_axis_data      ),
    .o_emac1_tx_axis_user               (o_emac1_tx_axis_user      ),
    .o_emac1_tx_axis_keep               (o_emac1_tx_axis_keep      ),
    .o_emac1_tx_axis_last               (o_emac1_tx_axis_last      ),
    .o_emac1_tx_axis_valid              (o_emac1_tx_axis_valid     ),
    .i_emac1_tx_axis_ready              (i_emac1_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac1_fifoc_empty                 (o_mac1_fifoc_empty        ),
    .i_mac1_scheduing_rst               (i_mac1_scheduing_rst      ),
    .i_mac1_scheduing_rst_vld           (i_mac1_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac2_tx_axis_data               (o_pmac2_tx_axis_data      ),
    .o_pmac2_tx_axis_user               (o_pmac2_tx_axis_user      ),
    .o_pmac2_tx_axis_keep               (o_pmac2_tx_axis_keep      ),
    .o_pmac2_tx_axis_last               (o_pmac2_tx_axis_last      ),
    .o_pmac2_tx_axis_valid              (o_pmac2_tx_axis_valid     ),
    .i_pmac2_tx_axis_ready              (i_pmac2_tx_axis_ready     ),
//emac通道数据
    .o_emac2_tx_axis_data               (o_emac2_tx_axis_data      ),
    .o_emac2_tx_axis_user               (o_emac2_tx_axis_user      ),
    .o_emac2_tx_axis_keep               (o_emac2_tx_axis_keep      ),
    .o_emac2_tx_axis_last               (o_emac2_tx_axis_last      ),
    .o_emac2_tx_axis_valid              (o_emac2_tx_axis_valid     ),
    .i_emac2_tx_axis_ready              (i_emac2_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac2_fifoc_empty                 (o_mac2_fifoc_empty        ),
    .i_mac2_scheduing_rst               (i_mac2_scheduing_rst      ),
    .i_mac2_scheduing_rst_vld           (i_mac2_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac3_tx_axis_data               (o_pmac3_tx_axis_data      ),
    .o_pmac3_tx_axis_user               (o_pmac3_tx_axis_user      ),
    .o_pmac3_tx_axis_keep               (o_pmac3_tx_axis_keep      ),
    .o_pmac3_tx_axis_last               (o_pmac3_tx_axis_last      ),
    .o_pmac3_tx_axis_valid              (o_pmac3_tx_axis_valid     ),
    .i_pmac3_tx_axis_ready              (i_pmac3_tx_axis_ready     ),
//emac通道数据
    .o_emac3_tx_axis_data               (o_emac3_tx_axis_data      ),
    .o_emac3_tx_axis_user               (o_emac3_tx_axis_user      ),
    .o_emac3_tx_axis_keep               (o_emac3_tx_axis_keep      ),
    .o_emac3_tx_axis_last               (o_emac3_tx_axis_last      ),
    .o_emac3_tx_axis_valid              (o_emac3_tx_axis_valid     ),
    .i_emac3_tx_axis_ready              (i_emac3_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac3_fifoc_empty                 (o_mac3_fifoc_empty        ),
    .i_mac3_scheduing_rst               (i_mac3_scheduing_rst      ),
    .i_mac3_scheduing_rst_vld           (i_mac3_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac4_tx_axis_data               (o_pmac4_tx_axis_data      ),
    .o_pmac4_tx_axis_user               (o_pmac4_tx_axis_user      ),
    .o_pmac4_tx_axis_keep               (o_pmac4_tx_axis_keep      ),
    .o_pmac4_tx_axis_last               (o_pmac4_tx_axis_last      ),
    .o_pmac4_tx_axis_valid              (o_pmac4_tx_axis_valid     ),
    .i_pmac4_tx_axis_ready              (i_pmac4_tx_axis_ready     ),
//emac通道数据
    .o_emac4_tx_axis_data               (o_emac4_tx_axis_data      ),
    .o_emac4_tx_axis_user               (o_emac4_tx_axis_user      ),
    .o_emac4_tx_axis_keep               (o_emac4_tx_axis_keep      ),
    .o_emac4_tx_axis_last               (o_emac4_tx_axis_last      ),
    .o_emac4_tx_axis_valid              (o_emac4_tx_axis_valid     ),
    .i_emac4_tx_axis_ready              (i_emac4_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac4_fifoc_empty                 (o_mac4_fifoc_empty        ),
    .i_mac4_scheduing_rst               (i_mac4_scheduing_rst      ),
    .i_mac4_scheduing_rst_vld           (i_mac4_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac5_tx_axis_data               (o_pmac5_tx_axis_data      ),
    .o_pmac5_tx_axis_user               (o_pmac5_tx_axis_user      ),
    .o_pmac5_tx_axis_keep               (o_pmac5_tx_axis_keep      ),
    .o_pmac5_tx_axis_last               (o_pmac5_tx_axis_last      ),
    .o_pmac5_tx_axis_valid              (o_pmac5_tx_axis_valid     ),
    .i_pmac5_tx_axis_ready              (i_pmac5_tx_axis_ready     ),
//emac通道数据
    .o_emac5_tx_axis_data               (o_emac5_tx_axis_data      ),
    .o_emac5_tx_axis_user               (o_emac5_tx_axis_user      ),
    .o_emac5_tx_axis_keep               (o_emac5_tx_axis_keep      ),
    .o_emac5_tx_axis_last               (o_emac5_tx_axis_last      ),
    .o_emac5_tx_axis_valid              (o_emac5_tx_axis_valid     ),
    .i_emac5_tx_axis_ready              (i_emac5_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac5_fifoc_empty                 (o_mac5_fifoc_empty        ),
    .i_mac5_scheduing_rst               (i_mac5_scheduing_rst      ),
    .i_mac5_scheduing_rst_vld           (i_mac5_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac6_tx_axis_data               (o_pmac6_tx_axis_data      ),
    .o_pmac6_tx_axis_user               (o_pmac6_tx_axis_user      ),
    .o_pmac6_tx_axis_keep               (o_pmac6_tx_axis_keep      ),
    .o_pmac6_tx_axis_last               (o_pmac6_tx_axis_last      ),
    .o_pmac6_tx_axis_valid              (o_pmac6_tx_axis_valid     ),
    .i_pmac6_tx_axis_ready              (i_pmac6_tx_axis_ready     ),
//emac通道数据
    .o_emac6_tx_axis_data               (o_emac6_tx_axis_data      ),
    .o_emac6_tx_axis_user               (o_emac6_tx_axis_user      ),
    .o_emac6_tx_axis_keep               (o_emac6_tx_axis_keep      ),
    .o_emac6_tx_axis_last               (o_emac6_tx_axis_last      ),
    .o_emac6_tx_axis_valid              (o_emac6_tx_axis_valid     ),
    .i_emac6_tx_axis_ready              (i_emac6_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac6_fifoc_empty                 (o_mac6_fifoc_empty        ),
    .i_mac6_scheduing_rst               (i_mac6_scheduing_rst      ),
    .i_mac6_scheduing_rst_vld           (i_mac6_scheduing_rst_vld  ),
//pmac通道数据
    .o_pmac7_tx_axis_data               (o_pmac7_tx_axis_data      ),
    .o_pmac7_tx_axis_user               (o_pmac7_tx_axis_user      ),
    .o_pmac7_tx_axis_keep               (o_pmac7_tx_axis_keep      ),
    .o_pmac7_tx_axis_last               (o_pmac7_tx_axis_last      ),
    .o_pmac7_tx_axis_valid              (o_pmac7_tx_axis_valid     ),
    .i_pmac7_tx_axis_ready              (i_pmac7_tx_axis_ready     ),
//emac通道数据
    .o_emac7_tx_axis_data               (o_emac7_tx_axis_data      ),
    .o_emac7_tx_axis_user               (o_emac7_tx_axis_user      ),
    .o_emac7_tx_axis_keep               (o_emac7_tx_axis_keep      ),
    .o_emac7_tx_axis_last               (o_emac7_tx_axis_last      ),
    .o_emac7_tx_axis_valid              (o_emac7_tx_axis_valid     ),
    .i_emac7_tx_axis_ready              (i_emac7_tx_axis_ready     ),
// 调度流水线调度信息交互
    .o_mac7_fifoc_empty                 (o_mac7_fifoc_empty        ),
    .i_mac7_scheduing_rst               (i_mac7_scheduing_rst      ),
    .i_mac7_scheduing_rst_vld           (i_mac7_scheduing_rst_vld  ),
    .i_clk                              (i_clk                     ),// 250MHz
    .i_rst                              (i_rst                     )
);

    initial begin
        // Initialize Inputs
        i_rst = 1;
        i_mac0_cross_port_axi_data = 0;
        i_mac0_cross_axi_data_keep = 0;
        i_mac0_cross_axi_data_valid = 0;
        i_mac0_cross_axi_data_last = 0;
        i_mac0_cross_metadata = 0;
        i_mac0_cross_metadata_valid = 0;
        i_mac0_cross_metadata_last = 0;

        i_tx0_req = 0;
        // Reset the system
        #3000;
        i_rst = 0;
     
    end

initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;    
end


// Function to build metadata according to the specification
function [METADATA_WIDTH-1:0] build_metadata;
    input                [  15: 0]      rtag                       ;
    input                [   1: 0]      port_speed                 ;
    input                [   2: 0]      vlan_pri                   ;
    input                [   7: 0]      tx_prot                    ;
    input                [   7: 0]      acl_frmtype                ;
    input                [  15: 0]      acl_fetchinfo              ;
    input                               frm_vlan_flag              ;
    input                [   7: 0]      input_port                 ;
    input                [   1: 0]      flow_match                 ;// [0]: CB业务帧标识, [1]: rtag标签标识
    input                               discard_bit                ;
    input                               critical_frame             ;
    input                [   6: 0]      time_stamp_addr            ;
        
        begin
            build_metadata = {
                rtag,                    // [80:65] - 实际只用到[15:0]，因为METADATA_WIDTH=64
                port_speed,              // [64:63]
                vlan_pri,                // [62:60]
                tx_prot,                 // [59:52]
                acl_frmtype,             // [51:44]
                acl_fetchinfo,           // [43:28]
                frm_vlan_flag,           // [27]
                input_port,              // [26:19]
                4'b0,                    // [18:15] - 保留
                flow_match,              // [14:13]
                discard_bit,             // [12]
                critical_frame,          // [11]
                time_stamp_addr,         // [10:4]
                3'b0                     // [3:0] - 保留
            };
        end
endfunction

    task send_metadata;
        input [METADATA_WIDTH-1:0] metadata;
        input req;
        begin
            @(posedge i_clk); 
            i_mac0_cross_metadata = metadata;
            i_mac0_cross_metadata_valid = 1;
            i_tx0_req = req;
            // Wait for ack or ready signal
            wait(o_mac0_tx0_ack || o_mac0_cross_metadata_ready);
            @(posedge i_clk);
            i_mac0_cross_metadata_valid = 0;
            i_tx0_req = 0;

        end
    endtask

    
    task send_packet;
        input [CROSS_DATA_WIDTH-1:0] data;
        input [(CROSS_DATA_WIDTH/8)-1:0] keep;
        input valid;
        input last;
        begin
            @(posedge i_clk); 
            i_mac0_cross_port_axi_data = data;
            i_mac0_cross_axi_data_keep = keep;
            i_mac0_cross_axi_data_valid= valid;
            i_mac0_cross_metadata_last = last;

            // Wait for ready signal if valid is high
            if (valid) begin
                wait(o_mac0_cross_axi_data_ready);
                @(posedge i_clk);
            end else begin
                @(posedge i_clk);
            end
            
            i_mac0_cross_axi_data_valid = 0;
            i_mac0_cross_axi_data_last = 0;

        end
    endtask

reg [METADATA_WIDTH-1:0] metadata;

integer i;
    initial begin
        // Wait for reset to complete
        #200;
        $display("Starting test sequence at time %0t", $time);
        
        // Test Case 1: Normal CB business frame
        $display("Test Case 1: Normal CB business frame");

        begin
            
            // Build metadata for CB business frame targeting
            metadata = build_metadata(
                16'h1234,        // rtag
                2'b10,           // port_speed (1000M)
                3'b101,          // vlan_pri (priority 5)
                8'h01,           // tx_prot
                8'h02,           // acl_frmtype
                16'hABCD,        // acl_fetchinfo
                1'b1,            // frm_vlan_flag
                8'b00000001,     // input_port bitmap (port 0)
                2'b11,           // flow_match: CB业务帧且有rtag
                1'b0,            // discard_bit
                1'b0,            // critical_frame
                7'h3F            // time_stamp_addr
            );
            
            // Step 1: Send metadata and request
            send_metadata(metadata, 1'b1);
            
            // Step 2: Send packet data after receiving ack
            #20;
            
            // Send packet with 10 data cycles
            for(i = 0; i < 10; i = i + 1) begin
                send_packet({1'b0, 8'h45 + i}, 8'h01, 1, 0);
            end
            // Send last data
            send_packet({1'b0, 8'hFF}, 8'h01, 1, 1);
        end

        #200;
        $display("All test cases completed at time %0t", $time);
        $finish;
        // // Send  metadata
        // /**********需要改成对应的metadata数据***********/
        // send_metadata(64'h45, 1'h1, 1, 0, 0);     //补全64bit数据

        // /******************************/

        // // Send  packet
        // /**********需要改成对应的报文数据***********/
        // send_packet(8'h45, 1'h1, 1, 0, 0); 
        // for(i = 0;i < 20;i = i+1)begin
        //      send_packet(8'h45, 1'h1, 1, 0, 0);           //给出测试数据
        // end
        //  send_packet(8'h45, 1'h1, 1, 1, 0); 
        // /******************************/  
    end


   // Monitoring
    always @(posedge i_clk) begin
        if (o_mac0_tx0_ack) begin
            $display("TX0 ACK received at time %0t with priority: %b", $time, o_mac0_tx0_ack_rst);
        end
        if (o_mac0_tx1_ack) begin
            $display("TX1 ACK received at time %0t with priority: %b", $time, o_mac0_tx1_ack_rst);
        end
        if (o_mac0_tx2_ack) begin
            $display("TX2 ACK received at time %0t with priority: %b", $time, o_mac0_tx2_ack_rst);
        end
        if (o_mac0_tx3_ack) begin
            $display("TX3 ACK received at time %0t with priority: %b", $time, o_mac0_tx3_ack_rst);
        end
        if (o_mac0_tx4_ack) begin
            $display("TX4 ACK received at time %0t with priority: %b", $time, o_mac0_tx4_ack_rst);
        end
        if (o_mac0_tx5_ack) begin
            $display("TX5 ACK received at time %0t with priority: %b", $time, o_mac0_tx5_ack_rst);
        end 
        if (o_mac0_tx6_ack) begin
            $display("TX6 ACK received at time %0t with priority: %b", $time, o_mac0_tx6_ack_rst);
        end
        if (o_mac0_tx7_ack) begin
            $display("TX7 ACK received at time %0t with priority: %b", $time, o_mac0_tx7_ack_rst);
        end
              
    end



endmodule