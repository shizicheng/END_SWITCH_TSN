`define CPU_MAC
`define MAC1
`define MAC2
`define MAC3
`define MAC4
`define MAC5
`define MAC6
`define MAC7
module key_arbit#(
    parameter                                                   PORT_NUM                =      8        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      81       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      15          // 哈希计算的值的位宽
    // parameter                                                   CROSS_DATA_WIDTH        =      PORT_MNG_DATA_WIDTH*PORT_NUM   // 聚合总线输出 
    // parameter                                                   PORT_WIDTH              =      clog2(PORT_NUM + 1) // 端口位宽
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,   
`ifdef CPU_MAC
    input               wire   [11:0]                           i_vlan_id_cpu                       , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac_cpu_hash_key                 , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac_cpu                          , // 目的 mac 的值
    input               wire                                    i_dmac_cpu_vld                      , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac_cpu_hash_key                 , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac_cpu                          , // 源 mac 的值
    input               wire                                    i_smac_cpu_vld                      , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_cpu_port                       ,
    output              wire                                    o_tx_cpu_port_vld                   ,
    output              wire   [1:0]                            o_tx_cpu_port_broadcast             , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC1
    input               wire   [11:0]                           i_vlan_id1                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac1_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac1                             , // 目的 mac 的值
    input               wire                                    i_dmac1_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac1_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac1                             , // 源 mac 的值
    input               wire                                    i_smac1_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_1_port                         ,
    output              wire                                    o_tx_1_port_vld                     ,
    output              wire   [1:0]                            o_tx_1_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif  
`ifdef MAC2
    input               wire   [11:0]                           i_vlan_id2                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac2_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac2                             , // 目的 mac 的值
    input               wire                                    i_dmac2_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac2_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac2                             , // 源 mac 的值
    input               wire                                    i_smac2_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_2_port                         ,
    output              wire                                    o_tx_2_port_vld                     ,
    output              wire   [1:0]                            o_tx_2_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC3
    input               wire   [11:0]                           i_vlan_id3                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac3_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac3                             , // 目的 mac 的值
    input               wire                                    i_dmac3_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac3_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac3                             , // 源 mac 的值
    input               wire                                    i_smac3_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_3_port                          ,
    output              wire                                    o_tx_3_port_vld                      ,
    output              wire   [1:0]                            o_tx_3_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC4
    input               wire   [11:0]                           i_vlan_id4                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac4_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac4                             , // 目的 mac 的值
    input               wire                                    i_dmac4_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac4_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac4                             , // 源 mac 的值
    input               wire                                    i_smac4_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_4_port                         ,
    output              wire                                    o_tx_4_port_vld                     ,
    output              wire   [1:0]                            o_tx_4_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC5
    input               wire   [11:0]                           i_vlan_id5                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac5_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac5                             , // 目的 mac 的值
    input               wire                                    i_dmac5_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac5_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac5                             , // 源 mac 的值
    input               wire                                    i_smac5_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_5_port                         ,
    output              wire                                    o_tx_5_port_vld                     ,
    output              wire   [1:0]                            o_tx_5_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC6
    input               wire   [11:0]                           i_vlan_id6                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac6_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac6                             , // 目的 mac 的值
    input               wire                                    i_dmac6_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac6_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac6                             , // 源 mac 的值
    input               wire                                    i_smac6_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_6_port                         ,
    output              wire                                    o_tx_6_port_vld                     ,
    output              wire   [1:0]                            o_tx_6_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC7
    input               wire   [11:0]                           i_vlan_id7                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac7_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac7                             , // 目的 mac 的值
    input               wire                                    i_dmac7_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac7_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac7                             , // 源 mac 的值
    input               wire                                    i_smac7_vld                         , // smac_vld

    output              wire   [PORT_NUM - 1:0]                 o_tx_7_port                         ,
    output              wire                                    o_tx_7_port_vld                     ,
    output              wire   [1:0]                            o_tx_7_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif 
    /*---------------------------------------- 仲裁输出 -------------------------------------------*/
    output              wire   [PORT_NUM - 1:0]                 o_dmac_port                         , // 仲裁的端口bitmap,每个bit代表一个端口
    output              wire   [11:0]                           o_vlan_id                           , // VLAN ID值
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac_hash_key                     , // 目的 mac 的哈希值
    output              wire   [47 : 0]                         o_dmac                              , // 目的 mac 的值
    output              wire                                    o_dmac_vld                          , // dmac_vld
    output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac_hash_key                     , // 源 mac 的值有效标识
    output              wire   [47 : 0]                         o_smac                              , // 源 mac 的值
    output              wire                                    o_smac_vld                          , // smac_vld

    input               wire   [PORT_NUM - 1:0]                 i_tx_port                           ,
    input               wire                                    i_tx_port_vld                       ,
    input               wire   [1:0]                            i_tx_port_broadcast                   // 01:组播 10：广播 11:泛洪
    
);

// 包含头文件
`include "synth_cmd_define.vh"

/*---------------------------------------- clog2计算函数 -------------------------------------------*/
function integer clog2;
    input integer value;
    integer temp;
    begin
        temp = value - 1;
        for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
            temp = temp >> 1;
    end
endfunction 
/*========================================================================================================*/
/*                                           内部信号定义                                                  */
/*========================================================================================================*/ 

/*---------------------------------------- Wire类型信号 -------------------------------------------*/
// FIFO控制信号
wire                                     fifo_wr_en                                                  ; // FIFO写使能信号
wire    [2:0]                            fifo_wr_data                                                ; // FIFO写入数据（端口号）
wire                                     fifo_rd_en                                                  ; // FIFO读使能信号
wire    [2:0]                            fifo_rd_data                                                ; // FIFO读取数据（端口号）
wire                                     fifo_empty                                                  ; // FIFO空标志
wire                                     fifo_full                                                   ; // FIFO满标志
wire                                     fifo_almost_full                                            ; // FIFO接近满标志
wire                                     fifo_almost_empty                                           ; // FIFO接近空标志
wire    [4:0]                            fifo_data_cnt                                               ; // FIFO数据计数

/*---------------------------------------- Reg类型信号 -------------------------------------------*/
// 输入信号打拍寄存器 - 各端口MAC地址及哈希信息
`ifdef CPU_MAC
reg     [11:0]                           ri_vlan_id_cpu                                              ; // CPU端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac_cpu_hash_key                                        ; // CPU端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac_cpu                                                 ; // CPU端口目的MAC地址输入寄存器
reg                                      ri_dmac_cpu_vld                                             ; // CPU端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac_cpu_hash_key                                        ; // CPU端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac_cpu                                                 ; // CPU端口源MAC地址输入寄存器
reg                                      ri_smac_cpu_vld                                             ; // CPU端口源MAC有效输入寄存器
`endif
`ifdef MAC1
reg     [11:0]                           ri_vlan_id1                                                 ; // MAC1端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac1_hash_key                                           ; // MAC1端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac1                                                    ; // MAC1端口目的MAC地址输入寄存器
reg                                      ri_dmac1_vld                                                ; // MAC1端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac1_hash_key                                           ; // MAC1端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac1                                                    ; // MAC1端口源MAC地址输入寄存器
reg                                      ri_smac1_vld                                                ; // MAC1端口源MAC有效输入寄存器
`endif
`ifdef MAC2
reg     [11:0]                           ri_vlan_id2                                                 ; // MAC2端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac2_hash_key                                           ; // MAC2端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac2                                                    ; // MAC2端口目的MAC地址输入寄存器
reg                                      ri_dmac2_vld                                                ; // MAC2端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac2_hash_key                                           ; // MAC2端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac2                                                    ; // MAC2端口源MAC地址输入寄存器
reg                                      ri_smac2_vld                                                ; // MAC2端口源MAC有效输入寄存器
`endif
`ifdef MAC3
reg     [11:0]                           ri_vlan_id3                                                 ; // MAC3端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac3_hash_key                                           ; // MAC3端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac3                                                    ; // MAC3端口目的MAC地址输入寄存器
reg                                      ri_dmac3_vld                                                ; // MAC3端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac3_hash_key                                           ; // MAC3端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac3                                                    ; // MAC3端口源MAC地址输入寄存器
reg                                      ri_smac3_vld                                                ; // MAC3端口源MAC有效输入寄存器
`endif
`ifdef MAC4
reg     [11:0]                           ri_vlan_id4                                                 ; // MAC4端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac4_hash_key                                           ; // MAC4端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac4                                                    ; // MAC4端口目的MAC地址输入寄存器
reg                                      ri_dmac4_vld                                                ; // MAC4端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac4_hash_key                                           ; // MAC4端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac4                                                    ; // MAC4端口源MAC地址输入寄存器
reg                                      ri_smac4_vld                                                ; // MAC4端口源MAC有效输入寄存器
`endif
`ifdef MAC5
reg     [11:0]                           ri_vlan_id5                                                 ; // MAC5端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac5_hash_key                                           ; // MAC5端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac5                                                    ; // MAC5端口目的MAC地址输入寄存器
reg                                      ri_dmac5_vld                                                ; // MAC5端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac5_hash_key                                           ; // MAC5端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac5                                                    ; // MAC5端口源MAC地址输入寄存器
reg                                      ri_smac5_vld                                                ; // MAC5端口源MAC有效输入寄存器
`endif
`ifdef MAC6
reg     [11:0]                           ri_vlan_id6                                                 ; // MAC6端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac6_hash_key                                           ; // MAC6端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac6                                                    ; // MAC6端口目的MAC地址输入寄存器
reg                                      ri_dmac6_vld                                                ; // MAC6端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac6_hash_key                                           ; // MAC6端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac6                                                    ; // MAC6端口源MAC地址输入寄存器
reg                                      ri_smac6_vld                                                ; // MAC6端口源MAC有效输入寄存器
`endif
`ifdef MAC7
reg     [11:0]                           ri_vlan_id7                                                 ; // MAC7端口VLAN ID输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_dmac7_hash_key                                           ; // MAC7端口目的MAC哈希输入寄存器
reg     [47 : 0]                         ri_dmac7                                                    ; // MAC7端口目的MAC地址输入寄存器
reg                                      ri_dmac7_vld                                                ; // MAC7端口目的MAC有效输入寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ri_smac7_hash_key                                           ; // MAC7端口源MAC哈希输入寄存器
reg     [47 : 0]                         ri_smac7                                                    ; // MAC7端口源MAC地址输入寄存器
reg                                      ri_smac7_vld                                                ; // MAC7端口源MAC有效输入寄存器
`endif 

// 转发端口信息输入寄存器
reg     [PORT_NUM - 1:0]                 ri_tx_port                                                  ; // 转发端口输入寄存器
reg                                      ri_tx_port_vld                                              ; // 转发端口有效输入寄存器
reg     [1:0]                            ri_tx_port_broadcast                                        ; // 转发端口广播类型输入寄存器

// 仲裁逻辑寄存器
reg     [2:0]                            arbit_port_sel                                              ; // 仲裁选择的端口号
reg                                      arbit_vld                                                   ; // 仲裁有效信号
reg     [11:0]                           arbit_vlan_id                                               ; // 仲裁输出的VLAN ID
reg     [HASH_DATA_WIDTH - 1 : 0]        arbit_dmac_hash_key                                         ; // 仲裁输出的目的MAC哈希
reg     [47 : 0]                         arbit_dmac                                                  ; // 仲裁输出的目的MAC
reg                                      arbit_dmac_vld                                              ; // 仲裁输出的目的MAC有效
reg     [HASH_DATA_WIDTH - 1 : 0]        arbit_smac_hash_key                                         ; // 仲裁输出的源MAC哈希
reg     [47 : 0]                         arbit_smac                                                  ; // 仲裁输出的源MAC
reg                                      arbit_smac_vld                                              ; // 仲裁输出的源MAC有效

// 端口映射逻辑寄存器
reg     [2:0]                            port_map_sel                                                ; // 端口映射选择信号
reg                                      port_map_vld                                                ; // 端口映射有效信号
reg     [PORT_NUM - 1:0]                 ri_tx_port_d1                                               ; // 延迟一拍的转发端口信息
reg                                      ri_tx_port_vld_d1                                           ; // 延迟一拍的转发端口有效信号
reg     [1:0]                            ri_tx_port_broadcast_d1                                     ; // 延迟一拍的转发端口广播类型信号

// 主输出寄存器
reg     [PORT_NUM - 1:0]                 ro_dmac_port                                                ; // 仲裁端口bitmap输出寄存器
reg     [11:0]                           ro_vlan_id                                                  ; // VLAN ID输出寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ro_dmac_hash_key                                            ; // 目的MAC哈希输出寄存器
reg     [47 : 0]                         ro_dmac                                                     ; // 目的MAC地址输出寄存器
reg                                      ro_dmac_vld                                                 ; // 目的MAC有效输出寄存器
reg     [HASH_DATA_WIDTH - 1 : 0]        ro_smac_hash_key                                            ; // 源MAC哈希输出寄存器
reg     [47 : 0]                         ro_smac                                                     ; // 源MAC地址输出寄存器
reg                                      ro_smac_vld                                                 ; // 源MAC有效输出寄存器

// 各端口转发信息输出寄存器
`ifdef CPU_MAC
reg     [PORT_NUM - 1:0]                 ro_tx_cpu_port                                              ; // CPU端口转发端口输出寄存器
reg                                      ro_tx_cpu_port_vld                                          ; // CPU端口转发有效输出寄存器
reg     [1:0]                            ro_tx_cpu_port_broadcast                                    ; // CPU端口转发广播类型输出寄存器
`endif
`ifdef MAC1
reg     [PORT_NUM - 1:0]                 ro_tx_1_port                                                ; // MAC1端口转发端口输出寄存器
reg                                      ro_tx_1_port_vld                                            ; // MAC1端口转发有效输出寄存器
reg     [1:0]                            ro_tx_1_port_broadcast                                      ; // MAC1端口转发广播类型输出寄存器
`endif
`ifdef MAC2
reg     [PORT_NUM - 1:0]                 ro_tx_2_port                                                ; // MAC2端口转发端口输出寄存器
reg                                      ro_tx_2_port_vld                                            ; // MAC2端口转发有效输出寄存器
reg     [1:0]                            ro_tx_2_port_broadcast                                      ; // MAC2端口转发广播类型输出寄存器
`endif
`ifdef MAC3
reg     [PORT_NUM - 1:0]                 ro_tx_3_port                                                ; // MAC3端口转发端口输出寄存器
reg                                      ro_tx_3_port_vld                                            ; // MAC3端口转发有效输出寄存器
reg     [1:0]                            ro_tx_3_port_broadcast                                      ; // MAC3端口转发广播类型输出寄存器
`endif
`ifdef MAC4
reg     [PORT_NUM - 1:0]                 ro_tx_4_port                                                ; // MAC4端口转发端口输出寄存器
reg                                      ro_tx_4_port_vld                                            ; // MAC4端口转发有效输出寄存器
reg     [1:0]                            ro_tx_4_port_broadcast                                      ; // MAC4端口转发广播类型输出寄存器
`endif
`ifdef MAC5
reg     [PORT_NUM - 1:0]                 ro_tx_5_port                                                ; // MAC5端口转发端口输出寄存器
reg                                      ro_tx_5_port_vld                                            ; // MAC5端口转发有效输出寄存器
reg     [1:0]                            ro_tx_5_port_broadcast                                      ; // MAC5端口转发广播类型输出寄存器
`endif
`ifdef MAC6
reg     [PORT_NUM - 1:0]                 ro_tx_6_port                                                ; // MAC6端口转发端口输出寄存器
reg                                      ro_tx_6_port_vld                                            ; // MAC6端口转发有效输出寄存器
reg     [1:0]                            ro_tx_6_port_broadcast                                      ; // MAC6端口转发广播类型输出寄存器
`endif
`ifdef MAC7
reg     [PORT_NUM - 1:0]                 ro_tx_7_port                                                ; // MAC7端口转发端口输出寄存器
reg                                      ro_tx_7_port_vld                                            ; // MAC7端口转发有效输出寄存器
reg     [1:0]                            ro_tx_7_port_broadcast                                      ; // MAC7端口转发广播类型输出寄存器
`endif 
/*========================================================================================================*/
/*                                           Assign信号连接                                               */
/*========================================================================================================*/

/*---------------------------------------- FIFO控制信号连接 -------------------------------------------*/
assign fifo_wr_en   = arbit_vld;                            // FIFO写使能：仲裁有效时写入端口号
assign fifo_wr_data = arbit_port_sel;                       // FIFO写数据：仲裁选择的端口号
assign fifo_rd_en   = i_tx_port_vld == 1'd1 && (fifo_empty == 1'd0);      // FIFO读使能：有转发端口且FIFO非空时读取

/*---------------------------------------- 主输出信号连接 -------------------------------------------*/
assign o_dmac_port     = ro_dmac_port    ;                  // 仲裁端口输出
assign o_vlan_id       = ro_vlan_id      ;                  // VLAN ID输出
assign o_dmac_hash_key = ro_dmac_hash_key;                  // 目的MAC哈希输出
assign o_dmac          = ro_dmac         ;                  // 目的MAC地址输出
assign o_dmac_vld      = ro_dmac_vld     ;                  // 目的MAC有效输出
assign o_smac_hash_key = ro_smac_hash_key;                  // 源MAC哈希输出
assign o_smac          = ro_smac         ;                  // 源MAC地址输出
assign o_smac_vld      = ro_smac_vld     ;                  // 源MAC有效输出

/*---------------------------------------- 各端口输出信号连接 -------------------------------------------*/
`ifdef CPU_MAC
assign o_tx_cpu_port     = ro_tx_cpu_port    ;                // CPU端口转发端口输出
assign o_tx_cpu_port_vld = ro_tx_cpu_port_vld;                // CPU端口转发有效输出
assign o_tx_cpu_port_broadcast = ro_tx_cpu_port_broadcast;    // CPU端口转发广播类型输出
`endif
`ifdef MAC1
assign o_tx_1_port     = ro_tx_1_port    ;                  // MAC1端口转发端口输出
assign o_tx_1_port_vld = ro_tx_1_port_vld;                  // MAC1端口转发有效输出
assign o_tx_1_port_broadcast = ro_tx_1_port_broadcast;      // MAC1端口转发广播类型输出
`endif
`ifdef MAC2
assign o_tx_2_port     = ro_tx_2_port    ;                  // MAC2端口转发端口输出
assign o_tx_2_port_vld = ro_tx_2_port_vld;                  // MAC2端口转发有效输出
assign o_tx_2_port_broadcast = ro_tx_2_port_broadcast;      // MAC2端口转发广播类型输出
`endif
`ifdef MAC3
assign o_tx_3_port     = ro_tx_3_port    ;                  // MAC3端口转发端口输出
assign o_tx_3_port_vld = ro_tx_3_port_vld;                  // MAC3端口转发有效输出
assign o_tx_3_port_broadcast = ro_tx_3_port_broadcast;      // MAC3端口转发广播类型输出
`endif
`ifdef MAC4
assign o_tx_4_port     = ro_tx_4_port    ;                  // MAC4端口转发端口输出
assign o_tx_4_port_vld = ro_tx_4_port_vld;                  // MAC4端口转发有效输出
assign o_tx_4_port_broadcast = ro_tx_4_port_broadcast;      // MAC4端口转发广播类型输出
`endif
`ifdef MAC5
assign o_tx_5_port     = ro_tx_5_port    ;                  // MAC5端口转发端口输出
assign o_tx_5_port_vld = ro_tx_5_port_vld;                  // MAC5端口转发有效输出
assign o_tx_5_port_broadcast = ro_tx_5_port_broadcast;      // MAC5端口转发广播类型输出
`endif
`ifdef MAC6
assign o_tx_6_port     = ro_tx_6_port    ;                  // MAC6端口转发端口输出
assign o_tx_6_port_vld = ro_tx_6_port_vld;                  // MAC6端口转发有效输出
assign o_tx_6_port_broadcast = ro_tx_6_port_broadcast;      // MAC6端口转发广播类型输出
`endif
`ifdef MAC7
assign o_tx_7_port     = ro_tx_7_port    ;                  // MAC7端口转发端口输出
assign o_tx_7_port_vld = ro_tx_7_port_vld;                  // MAC7端口转发有效输出
assign o_tx_7_port_broadcast = ro_tx_7_port_broadcast;      // MAC7端口转发广播类型输出
`endif 

/*========================================================================================================*/
/*                                           逻辑实现模块                                                  */
/*========================================================================================================*/

/*---------------------------------------- 输入信号打拍 -------------------------------------------*/
// 输入信号打拍处理，降低耦合
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_tx_port     <= {PORT_NUM{1'b0}};
        ri_tx_port_vld <= 1'b0;
        ri_tx_port_broadcast <= 2'b0;
`ifdef CPU_MAC
        ri_vlan_id_cpu       <= 12'b0;
        ri_dmac_cpu_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac_cpu          <= 48'b0;
        ri_dmac_cpu_vld      <= 1'b0;
        ri_smac_cpu_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac_cpu          <= 48'b0;
        ri_smac_cpu_vld      <= 1'b0;
`endif
`ifdef MAC1
        ri_vlan_id1          <= 12'b0;
        ri_dmac1_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac1             <= 48'b0;
        ri_dmac1_vld         <= 1'b0;
        ri_smac1_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac1             <= 48'b0;
        ri_smac1_vld         <= 1'b0;
`endif
`ifdef MAC2
        ri_vlan_id2          <= 12'b0;
        ri_dmac2_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac2             <= 48'b0;
        ri_dmac2_vld         <= 1'b0;
        ri_smac2_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac2             <= 48'b0;
        ri_smac2_vld         <= 1'b0;
`endif
`ifdef MAC3
        ri_vlan_id3          <= 12'b0;
        ri_dmac3_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac3             <= 48'b0;
        ri_dmac3_vld         <= 1'b0;
        ri_smac3_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac3             <= 48'b0;
        ri_smac3_vld         <= 1'b0;
`endif
`ifdef MAC4
        ri_vlan_id4          <= 12'b0;
        ri_dmac4_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac4             <= 48'b0;
        ri_dmac4_vld         <= 1'b0;
        ri_smac4_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac4             <= 48'b0;
        ri_smac4_vld         <= 1'b0;
`endif
`ifdef MAC5
        ri_vlan_id5          <= 12'b0;
        ri_dmac5_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac5             <= 48'b0;
        ri_dmac5_vld         <= 1'b0;
        ri_smac5_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac5             <= 48'b0;
        ri_smac5_vld         <= 1'b0;
`endif
`ifdef MAC6
        ri_vlan_id6          <= 12'b0;
        ri_dmac6_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac6             <= 48'b0;
        ri_dmac6_vld         <= 1'b0;
        ri_smac6_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac6             <= 48'b0;
        ri_smac6_vld         <= 1'b0;
`endif
`ifdef MAC7
        ri_vlan_id7          <= 12'b0;
        ri_dmac7_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac7             <= 48'b0;
        ri_dmac7_vld         <= 1'b0;
        ri_smac7_hash_key    <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac7             <= 48'b0;
        ri_smac7_vld         <= 1'b0;
`endif 
    end
    else begin
        ri_tx_port           <= i_tx_port;
        ri_tx_port_vld       <= i_tx_port_vld;
        ri_tx_port_broadcast <= i_tx_port_broadcast;
`ifdef CPU_MAC
        ri_vlan_id_cpu       <=  i_vlan_id_cpu;
        ri_dmac_cpu_hash_key <=  i_dmac_cpu_hash_key;
        ri_dmac_cpu          <=  i_dmac_cpu;
        ri_dmac_cpu_vld      <=  i_dmac_cpu_vld ? 1'd1 : arbit_port_sel == 3'd0 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac_cpu_vld ;
        ri_smac_cpu_hash_key <=  i_smac_cpu_hash_key;
        ri_smac_cpu          <=  i_smac_cpu;
        ri_smac_cpu_vld      <=  i_dmac_cpu_vld ? 1'd1 : arbit_port_sel == 3'd0 && arbit_vld == 1'd1 ? 1'd0 : ri_smac_cpu_vld ; 
`endif
`ifdef MAC1
        ri_vlan_id1          <= i_vlan_id1;
        ri_dmac1_hash_key    <= i_dmac1_hash_key;
        ri_dmac1             <= i_dmac1;
        ri_dmac1_vld         <= i_dmac1_vld ? 1'd1 : arbit_port_sel == 3'd1 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac1_vld ;
        ri_smac1_hash_key    <= i_smac1_hash_key;
        ri_smac1             <= i_smac1;
        ri_smac1_vld         <= i_smac1_vld ? 1'd1 : arbit_port_sel == 3'd1 && arbit_vld == 1'd1 ? 1'd0 : ri_smac1_vld ;
`endif
`ifdef MAC2
        ri_vlan_id2          <= i_vlan_id2;
        ri_dmac2_hash_key    <= i_dmac2_hash_key;
        ri_dmac2             <= i_dmac2;
        ri_dmac2_vld         <= i_dmac2_vld ? 1'd1 : arbit_port_sel == 3'd2 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac2_vld ;
        ri_smac2_hash_key    <= i_smac2_hash_key;
        ri_smac2             <= i_smac2;
        ri_smac2_vld         <= i_smac2_vld ? 1'd1 : arbit_port_sel == 3'd2 && arbit_vld == 1'd1 ? 1'd0 : ri_smac2_vld ;
`endif
`ifdef MAC3
        ri_vlan_id3          <= i_vlan_id3;
        ri_dmac3_hash_key    <= i_dmac3_hash_key;
        ri_dmac3             <= i_dmac3;
        ri_dmac3_vld         <= i_dmac3_vld ? 1'd1 : arbit_port_sel == 3'd3 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac3_vld ;
        ri_smac3_hash_key    <= i_smac3_hash_key;
        ri_smac3             <= i_smac3;
        ri_smac3_vld         <= i_smac3_vld ? 1'd1 : arbit_port_sel == 3'd3 && arbit_vld == 1'd1 ? 1'd0 : ri_smac3_vld ;
`endif
`ifdef MAC4
        ri_vlan_id4          <= i_vlan_id4;
        ri_dmac4_hash_key    <= i_dmac4_hash_key;
        ri_dmac4             <= i_dmac4;
        ri_dmac4_vld         <= i_dmac4_vld ? 1'd1 : arbit_port_sel == 3'd4 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac4_vld ;
        ri_smac4_hash_key    <= i_smac4_hash_key;
        ri_smac4             <= i_smac4;
        ri_smac4_vld         <= i_smac4_vld ? 1'd1 : arbit_port_sel == 3'd4 && arbit_vld == 1'd1 ? 1'd0 : ri_smac4_vld ;
`endif
`ifdef MAC5
        ri_vlan_id5          <= i_vlan_id5;
        ri_dmac5_hash_key    <= i_dmac5_hash_key;
        ri_dmac5             <= i_dmac5;
        ri_dmac5_vld         <= i_dmac5_vld ? 1'd1 : arbit_port_sel == 3'd5 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac5_vld ;
        ri_smac5_hash_key    <= i_smac5_hash_key;
        ri_smac5             <= i_smac5;
        ri_smac5_vld         <= i_smac5_vld ? 1'd1 : arbit_port_sel == 3'd5 && arbit_vld == 1'd1 ? 1'd0 : ri_smac5_vld ;
`endif
`ifdef MAC6
        ri_vlan_id6          <= i_vlan_id6;
        ri_dmac6_hash_key    <= i_dmac6_hash_key;
        ri_dmac6             <= i_dmac6;
        ri_dmac6_vld         <= i_dmac6_vld ? 1'd1 : arbit_port_sel == 3'd6 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac6_vld ;
        ri_smac6_hash_key    <= i_smac6_hash_key;
        ri_smac6             <= i_smac6;
        ri_smac6_vld         <= i_smac6_vld ? 1'd1 : arbit_port_sel == 3'd6 && arbit_vld == 1'd1 ? 1'd0 : ri_smac6_vld ;
`endif
`ifdef MAC7
        ri_vlan_id7          <= i_vlan_id7;
        ri_dmac7_hash_key    <= i_dmac7_hash_key;
        ri_dmac7             <= i_dmac7;
        ri_dmac7_vld         <= i_dmac7_vld ? 1'd1 : arbit_port_sel == 3'd7 && arbit_vld == 1'd1 ? 1'd0 : ri_dmac7_vld ;
        ri_smac7_hash_key    <= i_smac7_hash_key;
        ri_smac7             <= i_smac7;
        ri_smac7_vld         <= i_smac7_vld ? 1'd1 : arbit_port_sel == 3'd7 && arbit_vld == 1'd1 ? 1'd0 : ri_smac7_vld ;
`endif 
    end
end

/*---------------------------------------- 优先级仲裁逻辑 -------------------------------------------*/
// 8端口优先级仲裁，优先级0-7依次降低
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        arbit_port_sel <= 3'b0;
        arbit_vld      <= 1'b0;
    end
    else begin
        arbit_vld <= 1'b0;
        arbit_port_sel <= 3'b0;
        
        // 优先级仲裁：0-7依次降低
       
    `ifdef CPU_MAC
            if ( ri_smac_cpu_vld) begin
                arbit_port_sel <= 3'd0;   
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC1
            else if ( ri_smac1_vld) begin
                arbit_port_sel <= 3'd1;
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC2
            else if ( ri_smac2_vld) begin
                arbit_port_sel <= 3'd2;
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC3
            else if ( ri_smac3_vld) begin
                arbit_port_sel <= 3'd3;
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC4
            else if ( ri_smac4_vld) begin
                arbit_port_sel <= 3'd4;
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC5
            else if ( ri_smac5_vld) begin
                arbit_port_sel <= 3'd5;
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC6
            else if ( ri_smac6_vld) begin
                arbit_port_sel <= 3'd6;
                arbit_vld      <= 1'b1;
            end
    `endif
    `ifdef MAC7
            else if ( ri_smac7_vld) begin
                arbit_port_sel <= 3'd7;
                arbit_vld      <= 1'b1;
            end
    `endif
    end
end

/*---------------------------------------- 仲裁数据选择 -------------------------------------------*/
// 根据仲裁结果选择对应端口的MAC数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        arbit_vlan_id       <= 12'b0;
        arbit_dmac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        arbit_dmac          <= 48'b0;
        arbit_dmac_vld      <= 1'b0;
        arbit_smac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        arbit_smac          <= 48'b0;
        arbit_smac_vld      <= 1'b0;
    end
    else begin
        arbit_vlan_id       <= 12'b0;
        arbit_dmac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        arbit_dmac          <= 48'b0;
        arbit_dmac_vld      <= 1'b0;
        arbit_smac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        arbit_smac          <= 48'b0;
        arbit_smac_vld      <= 1'b0;
        
        case (arbit_port_sel)
`ifdef CPU_MAC
            3'd0: begin
                arbit_vlan_id       <= ri_vlan_id_cpu;
                arbit_dmac_hash_key <= ri_dmac_cpu_hash_key;
                arbit_dmac          <= ri_dmac_cpu;         
                arbit_dmac_vld      <= ri_dmac_cpu_vld;     
                arbit_smac_hash_key <= ri_smac_cpu_hash_key;
                arbit_smac          <= ri_smac_cpu;         
                arbit_smac_vld      <= ri_smac_cpu_vld;     
            end
`endif
`ifdef MAC1
            3'd1: begin
                arbit_vlan_id       <= ri_vlan_id1;
                arbit_dmac_hash_key <= ri_dmac1_hash_key;
                arbit_dmac          <= ri_dmac1;
                arbit_dmac_vld      <= ri_dmac1_vld;
                arbit_smac_hash_key <= ri_smac1_hash_key;
                arbit_smac          <= ri_smac1;
                arbit_smac_vld      <= ri_smac1_vld;
            end
`endif
`ifdef MAC2
            3'd2: begin
                arbit_vlan_id       <= ri_vlan_id2;
                arbit_dmac_hash_key <= ri_dmac2_hash_key;
                arbit_dmac          <= ri_dmac2;
                arbit_dmac_vld      <= ri_dmac2_vld;
                arbit_smac_hash_key <= ri_smac2_hash_key;
                arbit_smac          <= ri_smac2;
                arbit_smac_vld      <= ri_smac2_vld;
            end
`endif
`ifdef MAC3
            3'd3: begin
                arbit_vlan_id       <= ri_vlan_id3;
                arbit_dmac_hash_key <= ri_dmac3_hash_key;
                arbit_dmac          <= ri_dmac3;
                arbit_dmac_vld      <= ri_dmac3_vld;
                arbit_smac_hash_key <= ri_smac3_hash_key;
                arbit_smac          <= ri_smac3;
                arbit_smac_vld      <= ri_smac3_vld;
            end
`endif
`ifdef MAC4
            3'd4: begin
                arbit_vlan_id       <= ri_vlan_id4;
                arbit_dmac_hash_key <= ri_dmac4_hash_key;
                arbit_dmac          <= ri_dmac4;
                arbit_dmac_vld      <= ri_dmac4_vld;
                arbit_smac_hash_key <= ri_smac4_hash_key;
                arbit_smac          <= ri_smac4;
                arbit_smac_vld      <= ri_smac4_vld;
            end
`endif
`ifdef MAC5
            3'd5: begin
                arbit_vlan_id       <= ri_vlan_id5;
                arbit_dmac_hash_key <= ri_dmac5_hash_key;
                arbit_dmac          <= ri_dmac5;
                arbit_dmac_vld      <= ri_dmac5_vld;
                arbit_smac_hash_key <= ri_smac5_hash_key;
                arbit_smac          <= ri_smac5;
                arbit_smac_vld      <= ri_smac5_vld;
            end
`endif
`ifdef MAC6
            3'd6: begin
                arbit_vlan_id       <= ri_vlan_id6;
                arbit_dmac_hash_key <= ri_dmac6_hash_key;
                arbit_dmac          <= ri_dmac6;
                arbit_dmac_vld      <= ri_dmac6_vld;
                arbit_smac_hash_key <= ri_smac6_hash_key;
                arbit_smac          <= ri_smac6;
                arbit_smac_vld      <= ri_smac6_vld;
            end
`endif
`ifdef MAC7
            3'd7: begin
                arbit_vlan_id       <= ri_vlan_id7;
                arbit_dmac_hash_key <= ri_dmac7_hash_key;
                arbit_dmac          <= ri_dmac7;
                arbit_dmac_vld      <= ri_dmac7_vld;
                arbit_smac_hash_key <= ri_smac7_hash_key;
                arbit_smac          <= ri_smac7;
                arbit_smac_vld      <= ri_smac7_vld;
            end
`endif
            default: begin
                arbit_vlan_id       <= 12'b0;
                arbit_dmac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
                arbit_dmac          <= 48'b0;
                arbit_dmac_vld      <= 1'b0;
                arbit_smac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
                arbit_smac          <= 48'b0;
                arbit_smac_vld      <= 1'b0;
            end
        endcase
    end
end

/*---------------------------------------- 端口映射FIFO模块实例化 -------------------------------------------*/
sync_fifo #(
    .DEPTH                 (16                    ),
    .WIDTH                 (3                     ),
    .ALMOST_FULL_THRESHOLD (0                     ),
    .ALMOST_EMPTY_THRESHOLD(0                     ),
    .FLOP_DATA_OUT         (1                     ) //1为fwft ， 0为stander
) u_port_map_fifo (
    .i_clk                 (i_clk                 ),
    .i_rst                 (i_rst                 ),
    .i_wr_en               (fifo_wr_en            ),
    .i_din                 (fifo_wr_data          ),
    .o_full                (fifo_full             ),
    .i_rd_en               (fifo_rd_en            ),
    .o_dout                (fifo_rd_data          ),
    .o_empty               (fifo_empty            ),
    .o_almost_full         (fifo_almost_full      ),
    .o_almost_empty        (fifo_almost_empty     ),
    .o_data_cnt            (fifo_data_cnt         )
);

/*---------------------------------------- 端口映射逻辑 -------------------------------------------*/
// 转发端口信息延迟一拍，与FWFT FIFO读取数据时序对齐
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_tx_port_d1     <= {PORT_NUM{1'b0}};
        ri_tx_port_vld_d1 <= 1'b0;
        ri_tx_port_broadcast_d1 <= 2'b0;
    end
    else begin
        ri_tx_port_d1     <= ri_tx_port;
        ri_tx_port_vld_d1 <= ri_tx_port_vld;
        ri_tx_port_broadcast_d1 <= ri_tx_port_broadcast;
    end
end

// 从FIFO中读取端口映射信息
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        port_map_sel <= 3'b0;
        port_map_vld <= 1'b0;
    end
    else begin
        // 使用FWFT模式，数据立即可用，无需额外延迟
        port_map_sel <= fifo_rd_data;
        port_map_vld <= fifo_rd_en;
    end
end

/*---------------------------------------- 输出端口映射分发 -------------------------------------------*/
// 根据端口映射结果，将转发端口信息分发到对应的MAC端口
`ifdef CPU_MAC
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_cpu_port     <= {PORT_NUM{1'b0}};
        ro_tx_cpu_port_vld <= 1'b0;
        ro_tx_cpu_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd0)) begin
            ro_tx_cpu_port     <= ri_tx_port;
            ro_tx_cpu_port_vld <= 1'b1;
            ro_tx_cpu_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_cpu_port     <= {PORT_NUM{1'b0}};
            ro_tx_cpu_port_vld <= 1'b0;
            ro_tx_cpu_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC1
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_1_port     <= {PORT_NUM{1'b0}};
        ro_tx_1_port_vld <= 1'b0;
        ro_tx_1_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd1)) begin
            ro_tx_1_port     <= ri_tx_port;
            ro_tx_1_port_vld <= 1'b1;
            ro_tx_1_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_1_port     <= {PORT_NUM{1'b0}};
            ro_tx_1_port_vld <= 1'b0;
            ro_tx_1_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC2
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_2_port     <= {PORT_NUM{1'b0}};
        ro_tx_2_port_vld <= 1'b0;
        ro_tx_2_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd2)) begin
            ro_tx_2_port     <= ri_tx_port;
            ro_tx_2_port_vld <= 1'b1;
            ro_tx_2_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_2_port     <= {PORT_NUM{1'b0}};
            ro_tx_2_port_vld <= 1'b0;
            ro_tx_2_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC3
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_3_port     <= {PORT_NUM{1'b0}};
        ro_tx_3_port_vld <= 1'b0;
        ro_tx_3_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd3)) begin
            ro_tx_3_port     <= ri_tx_port;
            ro_tx_3_port_vld <= 1'b1;
            ro_tx_3_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_3_port     <= {PORT_NUM{1'b0}};
            ro_tx_3_port_vld <= 1'b0;
            ro_tx_3_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC4
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_4_port     <= {PORT_NUM{1'b0}};
        ro_tx_4_port_vld <= 1'b0;
        ro_tx_4_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd4)) begin
            ro_tx_4_port     <= ri_tx_port;
            ro_tx_4_port_vld <= 1'b1;
            ro_tx_4_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_4_port     <= {PORT_NUM{1'b0}};
            ro_tx_4_port_vld <= 1'b0;
            ro_tx_4_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC5
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_5_port     <= {PORT_NUM{1'b0}};
        ro_tx_5_port_vld <= 1'b0;
        ro_tx_5_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd5)) begin
            ro_tx_5_port     <= ri_tx_port;
            ro_tx_5_port_vld <= 1'b1;
            ro_tx_5_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_5_port     <= {PORT_NUM{1'b0}};
            ro_tx_5_port_vld <= 1'b0;
            ro_tx_5_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC6
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_6_port     <= {PORT_NUM{1'b0}};
        ro_tx_6_port_vld <= 1'b0;
        ro_tx_6_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd6)) begin
            ro_tx_6_port     <= ri_tx_port;
            ro_tx_6_port_vld <= 1'b1;
            ro_tx_6_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_6_port     <= {PORT_NUM{1'b0}};
            ro_tx_6_port_vld <= 1'b0;
            ro_tx_6_port_broadcast <= 2'b0;
        end
    end
end
`endif

`ifdef MAC7
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_tx_7_port     <= {PORT_NUM{1'b0}};
        ro_tx_7_port_vld <= 1'b0;
        ro_tx_7_port_broadcast <= 2'b0;
    end
    else begin
        if (port_map_vld == 1'd1 && (port_map_sel == 3'd7)) begin
            ro_tx_7_port     <= ri_tx_port;
            ro_tx_7_port_vld <= 1'b1;
            ro_tx_7_port_broadcast <= ri_tx_port_broadcast;
        end
        else begin
            ro_tx_7_port     <= {PORT_NUM{1'b0}};
            ro_tx_7_port_vld <= 1'b0;
            ro_tx_7_port_broadcast <= 2'b0;
        end
    end
end
`endif 

/*---------------------------------------- 主输出信号生成 -------------------------------------------*/
// 主输出信号寄存器更新
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_dmac_port     <= {PORT_NUM{1'b0}};
        ro_vlan_id       <= 12'b0;
        ro_dmac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        ro_dmac          <= 48'b0;
        ro_dmac_vld      <= 1'b0;
        ro_smac_hash_key <= {HASH_DATA_WIDTH{1'b0}};
        ro_smac          <= 48'b0;
        ro_smac_vld      <= 1'b0;
    end
    else begin
        // 将端口号转换为bitmap: 端口号3'dX -> bitmap位置 (1 << X)
        ro_dmac_port     <= (arbit_vld == 1'd1) ? ({{(PORT_NUM-1){1'b0}}, 1'b1} << arbit_port_sel) : {PORT_NUM{1'b0}};
        ro_vlan_id       <= arbit_vlan_id;
        ro_dmac_hash_key <= arbit_dmac_hash_key;
        ro_dmac          <= arbit_dmac;
        ro_dmac_vld      <= arbit_dmac_vld;
        ro_smac_hash_key <= arbit_smac_hash_key;
        ro_smac          <= arbit_smac;
        ro_smac_vld      <= arbit_smac_vld;
    end
end

endmodule