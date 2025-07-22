`include "synth_cmd_define.vh"

module swlist#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽
    parameter                                                   ADDR_WIDTH              =      6        ,  // 地址表的深度 
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

    output              wire   [PORT_NUM - 1:0]                 o_tx_cpu_port                       ,
    output              wire                                    o_tx_cpu_port_vld                   ,
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

    output              wire   [PORT_NUM - 1:0]                 o_tx_3_port                         ,
    output              wire                                    o_tx_3_port_vld                     ,
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
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    // 寄存器控制信号                     
    input               wire                                    i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                    i_switch_err_cnt_clr                , // 刷新错误计数器
    input               wire                                    i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    input               wire                                    i_switch_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din             , // 寄存器写数据
    input               wire                                    i_switch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口     
    input               wire                                    i_switch_reg_bus_rd                 , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr            , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_we_dout            , // 读出寄存器数据
    output              wire                                    o_switch_reg_bus_we_dout_v            // 读数据有效使能
);

`ifdef CPU_MAC
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_cpu_hash_key                 ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac_cpu                          ; // 目的 mac 的值
    wire                                    w_dmac_cpu_vld                      ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_cpu_hash_key                 ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac_cpu                          ; // 源 mac 的值
    wire                                    w_smac_cpu_vld                      ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_cpu_port                       ;
    wire                                    w_tx_cpu_port_vld                   ;

    assign      i_dmac_cpu_hash_key     =   w_dmac_cpu_hash_key                 ;
    assign      i_dmac_cpu              =   w_dmac_cpu                          ;
    assign      i_dmac_cpu_vld          =   w_dmac_cpu_vld                      ;
    assign      i_smac_cpu_hash_key     =   w_smac_cpu_hash_key                 ;
    assign      i_smac_cpu              =   w_smac_cpu                          ;
    assign      i_smac_cpu_vld          =   w_smac_cpu_vld                      ;
    assign      o_tx_cpu_port           =   w_tx_cpu_port                       ;
    assign      o_tx_cpu_port_vld       =   w_tx_cpu_port_vld                   ;
`endif

`ifdef MAC0
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac0_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac0                             ; // 目的 mac 的值
    wire                                    w_dmac0_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac0_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac0                             ; // 源 mac 的值
    wire                                    w_smac0_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_0_port                         ;
    wire                                    w_tx_0_port_vld                     ;

    assign      i_dmac0_hash_key        =   w_dmac0_hash_key                    ;
    assign      i_dmac0                 =   w_dmac0                             ;
    assign      i_dmac0_vld             =   w_dmac0_vld                         ;
    assign      i_smac0_hash_key        =   w_smac0_hash_key                    ;
    assign      i_smac0                 =   w_smac0                             ;
    assign      i_smac0_vld             =   w_smac0_vld                         ;
    assign      o_tx_0_port             =   w_tx_0_port                         ;
    assign      o_tx_0_port_vld         =   w_tx_0_port_vld                     ;
`endif

`ifdef MAC1
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac1_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac1                             ; // 目的 mac 的值
    wire                                    w_dmac1_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac1_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac1                             ; // 源 mac 的值
    wire                                    w_smac1_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_1_port                         ;
    wire                                    w_tx_1_port_vld                     ;

    assign      i_dmac1_hash_key        =   w_dmac1_hash_key                    ;
    assign      i_dmac1                 =   w_dmac1                             ;
    assign      i_dmac1_vld             =   w_dmac1_vld                         ;
    assign      i_smac1_hash_key        =   w_smac1_hash_key                    ;
    assign      i_smac1                 =   w_smac1                             ;
    assign      i_smac1_vld             =   w_smac1_vld                         ;
    assign      o_tx_1_port             =   w_tx_1_port                         ;
    assign      o_tx_1_port_vld         =   w_tx_1_port_vld                     ;
`endif

`ifdef MAC2
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac2_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac2                             ; // 目的 mac 的值
    wire                                    w_dmac2_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac2_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac2                             ; // 源 mac 的值
    wire                                    w_smac2_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_2_port                         ;
    wire                                    w_tx_2_port_vld                     ;

    assign      i_dmac2_hash_key        =   w_dmac2_hash_key                    ;
    assign      i_dmac2                 =   w_dmac2                             ;
    assign      i_dmac2_vld             =   w_dmac2_vld                         ;
    assign      i_smac2_hash_key        =   w_smac2_hash_key                    ;
    assign      i_smac2                 =   w_smac2                             ;
    assign      i_smac2_vld             =   w_smac2_vld                         ;
    assign      o_tx_2_port             =   w_tx_2_port                         ;
    assign      o_tx_2_port_vld         =   w_tx_2_port_vld                     ;
`endif

`ifdef MAC3
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac3_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac3                             ; // 目的 mac 的值
    wire                                    w_dmac3_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac3_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac3                             ; // 源 mac 的值
    wire                                    w_smac3_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_3_port                         ;
    wire                                    w_tx_3_port_vld                     ;

    assign      i_dmac3_hash_key        =   w_dmac3_hash_key                    ;
    assign      i_dmac3                 =   w_dmac3                             ;
    assign      i_dmac3_vld             =   w_dmac3_vld                         ;
    assign      i_smac3_hash_key        =   w_smac3_hash_key                    ;
    assign      i_smac3                 =   w_smac3                             ;
    assign      i_smac3_vld             =   w_smac3_vld                         ;
    assign      o_tx_3_port             =   w_tx_3_port                         ;
    assign      o_tx_3_port_vld         =   w_tx_3_port_vld                     ;
`endif

`ifdef MAC4
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac4_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac4                             ; // 目的 mac 的值
    wire                                    w_dmac4_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac4_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac4                             ; // 源 mac 的值
    wire                                    w_smac4_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_4_port                         ;
    wire                                    w_tx_4_port_vld                     ;

    assign      i_dmac4_hash_key        =   w_dmac4_hash_key                    ;
    assign      i_dmac4                 =   w_dmac4                             ;
    assign      i_dmac4_vld             =   w_dmac4_vld                         ;
    assign      i_smac4_hash_key        =   w_smac4_hash_key                    ;
    assign      i_smac4                 =   w_smac4                             ;
    assign      i_smac4_vld             =   w_smac4_vld                         ;
    assign      o_tx_4_port             =   w_tx_4_port                         ;
    assign      o_tx_4_port_vld         =   w_tx_4_port_vld                     ;
`endif

`ifdef MAC5
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac5_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac5                             ; // 目的 mac 的值
    wire                                    w_dmac5_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac5_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac5                             ; // 源 mac 的值
    wire                                    w_smac5_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_5_port                         ;
    wire                                    w_tx_5_port_vld                     ;

    assign      i_dmac5_hash_key        =   w_dmac5_hash_key                    ;
    assign      i_dmac5                 =   w_dmac5                             ;
    assign      i_dmac5_vld             =   w_dmac5_vld                         ;
    assign      i_smac5_hash_key        =   w_smac5_hash_key                    ;
    assign      i_smac5                 =   w_smac5                             ;
    assign      i_smac5_vld             =   w_smac5_vld                         ;
    assign      o_tx_5_port             =   w_tx_5_port                         ;
    assign      o_tx_5_port_vld         =   w_tx_5_port_vld                     ;
`endif

`ifdef MAC6
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac6_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac6                             ; // 目的 mac 的值
    wire                                    w_dmac6_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac6_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac6                             ; // 源 mac 的值
    wire                                    w_smac6_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_6_port                         ;
    wire                                    w_tx_6_port_vld                     ;

    assign      i_dmac6_hash_key        =   w_dmac6_hash_key                    ;
    assign      i_dmac6                 =   w_dmac6                             ;
    assign      i_dmac6_vld             =   w_dmac6_vld                         ;
    assign      i_smac6_hash_key        =   w_smac6_hash_key                    ;
    assign      i_smac6                 =   w_smac6                             ;
    assign      i_smac6_vld             =   w_smac6_vld                         ;
    assign      o_tx_6_port             =   w_tx_6_port                         ;
    assign      o_tx_6_port_vld         =   w_tx_6_port_vld                     ;
`endif

`ifdef MAC7
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac7_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac7                             ; // 目的 mac 的值
    wire                                    w_dmac7_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac7_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac7                             ; // 源 mac 的值
    wire                                    w_smac7_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_7_port                         ;
    wire                                    w_tx_7_port_vld                     ;

    assign      i_dmac7_hash_key        =   w_dmac7_hash_key                    ;
    assign      i_dmac7                 =   w_dmac7                             ;
    assign      i_dmac7_vld             =   w_dmac7_vld                         ;
    assign      i_smac7_hash_key        =   w_smac7_hash_key                    ;
    assign      i_smac7                 =   w_smac7                             ;
    assign      i_smac7_vld             =   w_smac7_vld                         ;
    assign      o_tx_7_port             =   w_tx_7_port                         ;
    assign      o_tx_7_port_vld         =   w_tx_7_port_vld                     ;
`endif

`ifdef MAC8
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac8_hash_key                    ; // 目的 mac 的哈希值
    wire   [47 : 0]                         w_dmac8                             ; // 目的 mac 的值
    wire                                    w_dmac8_vld                         ; // dmac_vld
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac8_hash_key                    ; // 源 mac 的值有效标识
    wire   [47 : 0]                         w_smac8                             ; // 源 mac 的值
    wire                                    w_smac8_vld                         ; // smac_vld
    wire   [PORT_NUM - 1:0]                 w_tx_8_port                         ;
    wire                                    w_tx_8_port_vld                     ;

    assign      i_dmac8_hash_key        =   w_dmac8_hash_key                    ;
    assign      i_dmac8                 =   w_dmac8                             ;
    assign      i_dmac8_vld             =   w_dmac8_vld                         ;
    assign      i_smac8_hash_key        =   w_smac8_hash_key                    ;
    assign      i_smac8                 =   w_smac8                             ;
    assign      i_smac8_vld             =   w_smac8_vld                         ;
    assign      o_tx_8_port             =   w_tx_8_port                         ;
    assign      o_tx_8_port_vld         =   w_tx_8_port_vld                     ;
`endif

    wire   [PORT_NUM - 1:0]                 w_dmac_port                         ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_hash_key                     ;
    wire   [47 : 0]                         w_dmac                              ;
    wire                                    w_dmac_vld                          ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_hash_key                     ;
    wire   [47 : 0]                         w_smac                              ;
    wire                                    w_smac_vld                          ;
    wire   [PORT_NUM - 1:0]                 w_tx_port                           ;
    wire                                    w_tx_port_vld                       ;

    wire                                    w_dmac_old_en                       ;   // DMAC 老化时间使能
    wire   [HASH_DATA_WIDTH-1:0]            w_dmac_old_num                      ;   // DMAC 老化的表项
    wire   [HASH_DATA_WIDTH-1:0]            w_dmac_item_mac_addr                ;   // DMAC 地址表项
    wire                                    w_dmac_item_mac_addr_vld            ;   // DMAC 地址表项有效位
    wire                                    w_dmac_item_mac_we                  ;   // DMAC 地址表读写信号
    wire   [47:0]                           w_dmac_item_mac_in                  ;   // MAC输入
    wire   [PORT_NUM - 1:0]                 w_dmac_item_mac_rx_port             ;   // DMAC 输入端口

    wire                                    w_clash_mac_old_en                  ;   // CLASH_MAC 老化时间使能
    wire   [HASH_DATA_WIDTH-1:0]            w_clash_mac_old_num                 ;   // CLASH_MAC 老化的表项
    wire   [HASH_DATA_WIDTH-1:0]            w_clash_mac_item_mac_addr           ;   // CLASH_MAC 地址表项
    wire                                    w_clash_mac_item_mac_addr_vld       ;   // CLASH_MAC 地址表项有效位
    wire                                    w_clash_mac_item_mac_we             ;   // CLASH_MAC 地址表读写信号
    wire   [47:0]                           w_clash_mac_item_mac_in             ;   // MAC输入
    wire   [PORT_NUM - 1:0]                 w_clash_mac_item_mac_rx_port        ;   // CLASH_MAC 输入端口

    wire   [PORT_NUM  : 0]                  w_smac_tx_port_rslt                 ;
    wire                                    w_smac_tx_port_vld                  ;

    wire                                    w_dmac_find_out_en                  ;
    wire        [PORT_NUM:0]                w_dmac_find_rslt                    ;
    wire                                    w_dmac_find_out_clash               ;

   wire                                     w_clash_tx_port_rslt                ;
   wire        [PORT_NUM:0]                 w_clash_tx_port_vld                 ;

// 多端口哈希仲裁
key_arbit#(
    .PORT_NUM                           (PORT_NUM                          ),  // 交换机的端口数
    .REG_ADDR_BUS_WIDTH                 (REG_ADDR_BUS_WIDTH                ),  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH                 (REG_DATA_BUS_WIDTH                ),  // 接收 MAC 层的配置寄存器数据位宽
    .METADATA_WIDTH                     (METADATA_WIDTH                    ),  // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH               ),  // Mac_port_mng 数据位宽 
    .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                   ),  // 哈希计算的值的位宽
    .CROSS_DATA_WIDTH                   (PORT_MNG_DATA_WIDTH*PORT_NUM      ) // 聚合总线输出 
) key_arbit_inst (
    .i_clk                              (i_clk                             ) ,   // 250MHz
    .i_rst                              (i_rst                             ) ,   
`ifdef CPU_MAC
    .i_dmac_cpu_hash_key                (w_dmac_cpu_hash_key               ) , // 目的 mac 的哈希值
    .i_dmac_cpu                         (w_dmac_cpu                        ) , // 目的 mac 的值
    .i_dmac_cpu_vld                     (w_dmac_cpu_vld                    ) , // dmac_vld
    .i_smac_cpu_hash_key                (w_smac_cpu_hash_key               ) , // 源 mac 的值有效标识
    .i_smac_cpu                         (w_smac_cpu                        ) , // 源 mac 的值
    .i_smac_cpu_vld                     (w_smac_cpu_vld                    ) , // smac_vld

    .tx_cpu_port                        (w_tx_cpu_port                     ),
    .tx_cpu_port_vld                    (w_tx_cpu_port_vld                 ),
`endif
`ifdef MAC0
    .i_dmac0_hash_key                   (w_dmac0_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac0                            (w_dmac0                           ) , // 目的 mac 的值
    .i_dmac0_vld                        (w_dmac0_vld                       ) , // dmac_vld
    .i_smac0_hash_key                   (w_smac0_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac0                            (w_smac0                           ) , // 源 mac 的值
    .i_smac0_vld                        (w_smac0_vld                       ) , // smac_vld

    .o_tx_0_port                        (w_tx_0_port                       ) ,
    .o_tx_0_port_vld                    (w_tx_0_port_vld                   ) ,
`endif  
`ifdef MAC1
    .i_dmac1_hash_key                   (w_dmac1_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac1                            (w_dmac1                           ) , // 目的 mac 的值
    .i_dmac1_vld                        (w_dmac1_vld                       ) , // dmac_vld
    .i_smac1_hash_key                   (w_smac1_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac1                            (w_smac1                           ) , // 源 mac 的值
    .i_smac1_vld                        (w_smac1_vld                       ) , // smac_vld

    .o_tx_1_port                        (w_tx_1_port                       ) ,
    .o_tx_1_port_vld                    (w_tx_1_port_vld                   ) ,
`endif  
`ifdef MAC2
    .i_dmac2_hash_key                   (w_dmac2_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac2                            (w_dmac2                           ) , // 目的 mac 的值
    .i_dmac2_vld                        (w_dmac2_vld                       ) , // dmac_vld
    .i_smac2_hash_key                   (w_smac2_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac2                            (w_smac2                           ) , // 源 mac 的值
    .i_smac2_vld                        (w_smac2_vld                       ) , // smac_vld

    .o_tx_2_port                        (w_tx_2_port                       ) ,
    .o_tx_2_port_vld                    (w_tx_2_port_vld                   ) ,
`endif
`ifdef MAC3
    .i_dmac3_hash_key                   (w_dmac3_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac3                            (w_dmac3                           ) , // 目的 mac 的值
    .i_dmac3_vld                        (w_dmac3_vld                       ) , // dmac_vld
    .i_smac3_hash_key                   (w_smac3_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac3                            (w_smac3                           ) , // 源 mac 的值
    .i_smac3_vld                        (w_smac3_vld                       ) , // smac_vld

    .o_tx_3_port                        (w_tx_3_port                       ) ,
    .o_tx_3_port_vld                    (w_tx_3_port_vld                   ) ,
`endif
`ifdef MAC4
    .i_dmac4_hash_key                   (w_dmac4_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac4                            (w_dmac4                           ) , // 目的 mac 的值
    .i_dmac4_vld                        (w_dmac4_vld                       ) , // dmac_vld
    .i_smac4_hash_key                   (w_smac4_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac4                            (w_smac4                           ) , // 源 mac 的值
    .i_smac4_vld                        (w_smac4_vld                       ) , // smac_vld

    .o_tx_4_port                        (w_tx_4_port                       ) ,
    .o_tx_4_port_vld                    (w_tx_4_port_vld                   ) ,
`endif
`ifdef MAC5
    .i_dmac5_hash_key                   (w_dmac5_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac5                            (w_dmac5                           ) , // 目的 mac 的值
    .i_dmac5_vld                        (w_dmac5_vld                       ) , // dmac_vld
    .i_smac5_hash_key                   (w_smac5_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac5                            (w_smac5                           ) , // 源 mac 的值
    .i_smac5_vld                        (w_smac5_vld                       ) , // smac_vld

    .o_tx_5_port                        (w_tx_5_port                       ) ,
    .o_tx_5_port_vld                    (w_tx_5_port_vld                   ) ,
`endif
`ifdef MAC6
    .i_dmac6_hash_key                   (w_dmac6_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac6                            (w_dmac6                           ) , // 目的 mac 的值
    .i_dmac6_vld                        (w_dmac6_vld                       ) , // dmac_vld
    .i_smac6_hash_key                   (w_smac6_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac6                            (w_smac6                           ) , // 源 mac 的值
    .i_smac6_vld                        (w_smac6_vld                       ) , // smac_vld

    .o_tx_6_port                        (w_tx_6_port                       ) ,
    .o_tx_6_port_vld                    (w_tx_6_port_vld                   ) ,
`endif
`ifdef MAC7
    .i_dmac7_hash_key                   (w_dmac7_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac7                            (w_dmac7                           ) , // 目的 mac 的值
    .i_dmac7_vld                        (w_dmac7_vld                       ) , // dmac_vld
    .i_smac7_hash_key                   (w_smac7_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac7                            (w_smac7                           ) , // 源 mac 的值
    .i_smac7_vld                        (w_smac7_vld                       ) , // smac_vld

    .o_tx_7_port                        (w_tx_7_port                       ) ,
    .o_tx_7_port_vld                    (w_tx_7_port_vld                   ) ,
`endif
`ifdef MAC8
    .i_dmac8_hash_key                   (w_dmac8_hash_key                  ) , // 目的 mac 的哈希值
    .i_dmac8                            (w_dmac8                           ) , // 目的 mac 的值
    .i_dmac8_vld                        (w_dmac8_vld                       ) , // dmac_vld
    .i_smac8_hash_key                   (w_smac8_hash_key                  ) , // 源 mac 的值有效标识
    .i_smac8                            (w_smac8                           ) , // 源 mac 的值
    .i_smac8_vld                        (w_smac8_vld                       ) , // smac_vld

    .o_tx_8_port                        (w_tx_8_port                       ),
    .o_tx_8_port_vld                    (w_tx_8_port_vld                   ),
`endif
    /*---------------------------------------- 仲裁输出 -------------------------------------------*/
    .o_dmac_port                        (w_dmac_port                       ) , // 仲裁输出的端口                     
    .o_dmac_hash_key                    (w_dmac_hash_key                   ) , // 目的 mac 的哈希值
    .o_dmac                             (w_dmac                            ) , // 目的 mac 的值
    .o_dmac_vld                         (w_dmac_vld                        ) , // dmac_vld
    .o_smac_hash_key                    (w_smac_hash_key                   ) , // 源 mac 的值有效标识
    .o_smac                             (w_smac                            ) , // 源 mac 的值
    .o_smac_vld                         (w_smac_vld                        ) , // smac_vld

    .i_tx_port                          (w_tx_port                         ) ,
    .i_tx_port_vld                      (w_tx_port_vld                     )  
);

// 查表引擎
look_up_mng #(
        .HASH_DATA_WIDTH          (HASH_DATA_WIDTH                   ),   // 哈希计算的值的位宽
        .PORT_NUM                 (PORT_NUM                          ),   // 交换机的端口数
        .ADDR_WIDTH               (ADDR_WIDTH                        )    // 地址表的深度
)look_up_mng_inst (     
        .i_clk                    (i_clk                             )   ,
        .i_rst                    (i_rst                             )   ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
        .i_cfg_smac_list_clr      ()    ,   // 静态MAC配置-清空列表
        .i_cfg_smac_list_we       ()    ,   // 静态MAC配置-写使能
        .i_cfg_smac_list_din_0    ()    ,   // 静态MAC配置条目-MAC地址字段
        .i_cfg_smac_list_din_1    ()    ,   // 静态MAC配置条目-发送指定端口字段
        .i_cfg_smac_list_din_2    ()    ,   // 静态MAC配置条目-有效使能及掩码配置字段(掩码必须连续有效)
        /*----------------------------- KEY仲裁结果输入 ------------------------------*/
        .i_dmac_port              (w_dmac_port                       )    ,
        .i_dmac_hash_key          (w_dmac_hash_key                   )    ,   // 目的 mac 的哈希值
        .i_dmac                   (w_dmac                            )    ,   // 目的 mac 的值
        .i_dmac_vld               (w_dmac_vld                        )    ,   // dmac_vld
        .i_smac_hash_key          (w_smac_hash_key                   )    ,   // 源 mac 的值有效标识
        .i_smac                   (w_smac                            )    ,   // 源 mac 的值
        .i_smac_vld               (w_smac_vld                        )    ,   // smac_vld
 
        .o_tx_port                (w_tx_port                         )    ,
        .o_tx_port_vld            (w_tx_port_vld                     )    ,
        /*----------------------------- DMAC 表读写接口 ------------------------------*/
        .i_dmac_old_en            (w_dmac_old_en                     )    ,   // DMAC 老化时间使能
        .i_dmac_old_num           (w_dmac_old_num                    )    ,   // DMAC 老化的表项
        .o_dmac_item_mac_addr     (w_dmac_item_mac_addr              )    ,   // DMAC 地址表项
        .o_dmac_item_mac_addr_vld (w_dmac_item_mac_addr_vld          )    ,   // DMAC 地址表项有效位
        .o_dmac_item_mac_we       (w_dmac_item_mac_we                )    ,   // DMAC 地址表读写信号
        .o_dmac_item_mac_in       (w_dmac_item_mac_in                )    ,   // MAC输入
        .o_dmac_item_mac_rx_port  (w_dmac_item_mac_rx_port           )    ,   // DMAC 输入端口
        /*----------------------------- 哈希冲突表读写接口 ------------------------------*/
        .o_clash_clr              ()   ,   // 哈希冲突表清空
        .i_clash_rdy              ()   ,   
        .i_clash_old_en           (w_clash_mac_old_en               )   ,   // DMAC 老化时间使能
        .i_clash_old_num          (w_clash_mac_old_num              )   ,   // DMAC 老化的表项
        .o_clash_item_mac_addr    (w_clash_mac_item_mac_addr        )   ,   // DMAC 地址表项
        .o_clash_item_mac_addr_vld(w_clash_mac_item_mac_addr_vld    )   ,   // DMAC 地址表项有效位
        .o_clash_item_mac_we      (w_clash_mac_item_mac_we          )   ,   // DMAC 地址表读写信号
        .o_clash_item_mac_in      (w_clash_mac_item_mac_in          )   ,   // MAC输入
        .o_clash_item_mac_rx_port (w_clash_mac_item_mac_rx_port     )   ,   // DMAC 输入端口
        /*----------------------------- 查表的结果 ------------------------------*/
        // smac
        .i_smac_tx_port_rslt      (w_smac_tx_port_rslt              )   , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        .i_smac_tx_port_vld       (w_smac_tx_port_vld               )   ,
        // dmac
        .i_dmac_tx_port_rslt      (w_dmac_find_out_en               )   , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        .i_dmac_tx_port_vld       (w_dmac_find_rslt                 )   ,
        .i_clash_out              (w_dmac_find_out_clash            )   , // 表明在 DMAC 中，没有查找到合适的表项，转到哈希冲突表查找
        // clash
        .i_clash_tx_port_rslt     (w_clash_tx_port_rslt             )   , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        .i_clash_tx_port_vld      (w_clash_tx_port_vld              )   
);

smac_mng #(
        .PORT_NUM                (PORT_NUM          )                    ,   // 交换机的端口数
        .ADDR_WIDTH              (ADDR_WIDTH        )                        // 地址表的深度
)smac_mng_inst (  
        .i_clk                   (i_clk                             )    ,
        .i_rst                   (i_rst                             )    ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
        .i_cfg_smac_list_clr     ()    ,   // 静态MAC配置-清空列表
        .i_cfg_smac_list_we      ()    ,   // 静态MAC配置-写使能
        .i_cfg_smac_list_din_0   ()    ,   // 静态MAC配置条目-MAC地址字段
        .i_cfg_smac_list_din_1   ()    ,   // 静态MAC配置条目-发送指定端口字段
        .i_cfg_smac_list_din_2   ()    ,   // 静态MAC配置条目-有效使能及掩码配置字段(掩码必须连续有效)
        /*----------------------------- 查找 DMAC 输入 ------------------------------*/
        .i_mac_in                ()   ,   
        .i_mac_in_vld            ()   ,   
        .o_match_rdy             ()   , 
        /*----------------------------- 表项的状态 ------------------------------*/
        .smac_list_num           ()    ,
        .smac_list_full          ()    ,
        /*----------------------------- 查表的结果 ------------------------------*/
        // smac
        .o_smac_tx_port_rslt     (w_smac_tx_port_rslt           )    , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        .o_smac_tx_port_vld      (w_smac_tx_port_vld            )    
);

dmac_mng #(
        .PORT_NUM                (PORT_NUM          )                    ,   // 交换机的端口数
        .HASH_DATA_WIDTH         (HASH_DATA_WIDTH   )                    ,   // 哈希计算的值的位宽
        .ADDR_WIDTH              (ADDR_WIDTH        )                        // 地址表的深度
)dmac_mng_inst (  
        .i_clk                   (i_clk                             )    ,
        .i_rst                   (i_rst                             )    ,
        /*----------------------------- 老化表项接口 ------------------------------*/
        .i_cfg_live_time         (),
        .o_old_num               (w_dmac_old_en                     ),
        .o_old_en                (w_dmac_old_num                    ),
        /*----------------------------- DMAC 读写接口 ------------------------------*/
        .i_item_mac_addr         (w_dmac_item_mac_addr              ),
        .i_item_mac_addr_vld     (w_dmac_item_mac_addr_vld          ),
        .i_item_mac_we           (w_dmac_item_mac_we                ),
        .i_item_mac_in           (w_dmac_item_mac_in                ),
        .i_rx_port_in            (w_dmac_item_mac_rx_port           ),
        /*----------------------------- 查表输出接口接口 ------------------------------*/     
        .o_dmac_find_out_en      (w_dmac_find_out_en                )  ,
        .o_dmac_find_rslt        (w_dmac_find_rslt                  )  , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        .o_dmac_find_out_clash   (w_dmac_find_out_clash             )
);

clash_mac_mng #(
        .PORT_NUM                 (PORT_NUM          )                    ,   // 交换机的端口数
        .HASH_DATA_WIDTH          (HASH_DATA_WIDTH   )                    ,   // 哈希计算的值的位宽
        .ADDR_WIDTH               (ADDR_WIDTH        )                        // 地址表的深度
)(  
        .i_clk                    (i_clk                             )    ,
        .i_rst                    (i_rst                             )    ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
        .i_cfg_smac_list_clr      (), // 用于一键清空静态MAC列表
        .o_match_rdy              (),
        /*----------------------------- 老化表项接口 ------------------------------*/
        .i_cfg_live_time          (),
        .o_old_num                (w_clash_mac_old_en               ),
        .o_old_en                 (w_clash_mac_old_num              ),
        /*----------------------------- Clash MAC 读写接口 ------------------------------*/
        .i_item_mac_addr          (w_clash_mac_item_mac_addr        ),
        .i_item_mac_addr_vld      (w_clash_mac_item_mac_addr_vld    ),
        .i_item_mac_we            (w_clash_mac_item_mac_we          ),
        .i_item_mac_in            (w_clash_mac_item_mac_in          ),
        .i_rx_port_in             (w_clash_mac_item_mac_rx_port     ),
        /*----------------------------- 查表输出接口接口 ------------------------------*/     
        .o_clash_tx_port_rslt     (w_clash_tx_port_rslt             ),
        .o_clash_tx_port_vld      (w_clash_tx_port_vld              ) // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
);

endmodule
