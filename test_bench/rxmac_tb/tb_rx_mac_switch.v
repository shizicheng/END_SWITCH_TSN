`timescale 1ns / 1ns

//==============================================================================
// 文件名        : tb_rx_mac_switch.v
// 作者          : 
// 创建日期      : 2025-10-08
// 版本          : V1.0
// 描述          : RX MAC 交换机测试平台
//                支持8通道以太网帧数据输入，测试MAC学习功能
//==============================================================================

`define CPU_MAC
`define MAC1
`define MAC2
`define MAC3
`define MAC4
`define MAC5
`define MAC6
`define MAC7

module tb_rx_mac_switch; 
    //==========================================================================
    // 参数定义
    //==========================================================================
    parameter   CLK_PERIOD          = 4                            ; // 时钟周期 100MHz
    parameter   PORT_NUM            = 8                            ; // 端口数量
    parameter   DATA_WIDTH          = 8                            ; // 数据位宽
    parameter   KEEP_WIDTH          = 1                            ; // Keep位宽
    parameter   MAX_FRAME_LEN       = 1518                         ; // 最大帧长度
    parameter   MIN_FRAME_LEN       = 64                           ; // 最小帧长度
    
    // 以太网帧字段长度定义
    parameter   PREAMBLE_LEN        = 7                            ; // 前导码长度
    parameter   SFD_LEN             = 1                            ; // 帧起始定界符长度
    parameter   MAC_ADDR_LEN        = 6                            ; // MAC地址长度
    parameter   VLAN_LEN            = 4                            ; // VLAN标签长度
    parameter   RTAG_LEN            = 4                            ; // R-TAG长度
    parameter   TYPE_LEN            = 2                            ; // 类型字段长度
    parameter   CRC_LEN             = 4                            ; // CRC长度
 
    parameter   PORT_MNG_DATA_WIDTH = 8                            ; 
    parameter   MAC_NUM             = 8                            ;
    parameter   PKT_MAX_LEN         = 1518                         ;
    parameter   HASH_DATA_WIDTH     = 15                           ;
    parameter   METADATA_WIDTH      = 81                           ;
    parameter   REG_ADDR_BUS_WIDTH  = 8                            ;
    parameter   REG_DATA_BUS_WIDTH  = 16                           ; 
    parameter   CROSS_DATA_WIDTH    = PORT_MNG_DATA_WIDTH          ;
    parameter   AGE_SCAN_INTERVAL   = 1000                         ; // MAC地址表老化扫描间隔(时钟周期数)
    parameter   SIM_MODE            = 1                            ; // 仿真模式: 1=使能, 0=禁用
    
    //==========================================================================
    // 信号定义
    //==========================================================================
wire                                tcam_o_reg_bus_we;
wire [REG_ADDR_BUS_WIDTH-1:0]       tcam_o_reg_bus_we_addr;
wire [REG_DATA_BUS_WIDTH-1:0]       tcam_o_reg_bus_we_din;
wire                                tcam_o_reg_bus_we_din_v;
wire                                tcam_o_write_done;
wire                                tcam_o_write_busy;
 
wire                                tb_i_tcam_busy = 1'b0;
 
reg                                 tb_i_write_start;
reg  [2:0]                          tb_i_cmd_type;
reg  [143:0]                        tb_i_raw_data;
reg  [143:0]                        tb_i_dont_care_mask;
reg  [23:0]                         tb_i_action_data;
// 时钟复位信号
reg         r_clk                                             ;
reg         r_rst_n                                           ;

// 全局控制信号
reg         r_test_start                                      ;
reg [7:0]   r_test_case                                       ;

// 端口连接和配置信号
wire [PORT_NUM-1:0]               w_mac_port_link             ;
wire [PORT_NUM*2-1:0]             w_mac_port_speed            ;
wire [PORT_NUM-1:0]               w_mac_port_filter_preamble_v;

// 8个端口的AXI Stream数据接口
wire [DATA_WIDTH-1:0]   w_mac_axi_data [PORT_NUM-1:0]         ;
// wire [PORT_NUM*DATA_WIDTH-1:0]     w_mac_axi_data             ;
wire [PORT_NUM*KEEP_WIDTH-1:0]     w_mac_axi_data_keep        ;
wire                               w_mac_axi_data_valid  [PORT_NUM-1:0]     ;
wire                               w_mac_axi_data_ready  [PORT_NUM-1:0]     ;
wire                               w_mac_axi_data_last   [PORT_NUM-1:0]     ;

// 单独端口信号声明 - 便于连接
wire [DATA_WIDTH-1:0]   w_port_axi_data    [PORT_NUM-1:0]     ;
wire [KEEP_WIDTH-1:0]   w_port_axi_keep    [PORT_NUM-1:0]     ;
wire                    w_port_axi_valid   [PORT_NUM-1:0]     ;
wire                    w_port_axi_ready   [PORT_NUM-1:0]     ;
wire                    w_port_axi_last    [PORT_NUM-1:0]     ;
wire [15:0]             w_port_axi_user    [PORT_NUM-1:0]     ; // 添加user信号(帧长度)

// QBU eMAC通道信号 (高优先级，可抢占pMAC) - 改为reg以支持独立输入
reg  [DATA_WIDTH-1:0]   r_emac_axi_data    [PORT_NUM-1:0]     ;
reg  [KEEP_WIDTH-1:0]   r_emac_axi_keep    [PORT_NUM-1:0]     ;
reg                     r_emac_axi_valid   [PORT_NUM-1:0]     ;
wire                    w_emac_axi_ready   [PORT_NUM-1:0]     ;
reg                     r_emac_axi_last    [PORT_NUM-1:0]     ;
reg  [15:0]             r_emac_axi_user    [PORT_NUM-1:0]     ;
reg  [15:0]             r_emac_ethertype   [PORT_NUM-1:0]     ;

// QBU pMAC通道信号 (低优先级，可被抢占)
reg  [DATA_WIDTH-1:0]   r_pmac_axi_data    [PORT_NUM-1:0]     ;
reg  [KEEP_WIDTH-1:0]   r_pmac_axi_keep    [PORT_NUM-1:0]     ;
reg                     r_pmac_axi_valid   [PORT_NUM-1:0]     ;
wire                    w_pmac_axi_ready   [PORT_NUM-1:0]     ;
reg                     r_pmac_axi_last    [PORT_NUM-1:0]     ;
reg  [15:0]             r_pmac_axi_user    [PORT_NUM-1:0]     ;
reg  [15:0]             r_pmac_ethertype   [PORT_NUM-1:0]     ;

// QBU输出到MAC接口的信号
wire [DATA_WIDTH-1:0]   w_qbu_mac_axi_data [PORT_NUM-1:0]     ;
wire [KEEP_WIDTH-1:0]   w_qbu_mac_axi_keep [PORT_NUM-1:0]     ;
wire                    w_qbu_mac_axi_valid[PORT_NUM-1:0]     ;
wire                    w_qbu_mac_axi_ready[PORT_NUM-1:0]     ;
wire                    w_qbu_mac_axi_last [PORT_NUM-1:0]     ;
wire [15:0]             w_qbu_mac_axi_user [PORT_NUM-1:0]     ;

// QBU验证和响应信号
reg                     r_qbu_verify_valid  [PORT_NUM-1:0]    ;
reg                     r_qbu_response_valid[PORT_NUM-1:0]    ;

// QBU时间戳信号
wire                    w_qbu_time_irq     [PORT_NUM-1:0]     ;
wire [7:0]              w_qbu_frame_seq    [PORT_NUM-1:0]     ;
wire [7:0]              w_qbu_timestamp_addr[PORT_NUM-1:0]    ;

// 帧生成器控制信号
reg  [PORT_NUM-1:0]     r_frame_gen_enable                    ;
reg  [PORT_NUM-1:0]     r_frame_gen_start                     ;
wire [PORT_NUM-1:0]     w_frame_gen_done                      ;
wire [PORT_NUM-1:0]     w_frame_gen_busy                      ;

// 帧生成器配置信号
reg  [15:0]             r_frame_len         [PORT_NUM-1:0]    ;  // 帧长度配置
reg  [PORT_NUM-1:0]     r_add_vlan                            ;  // VLAN标签使能
reg  [PORT_NUM-1:0]     r_add_rtag                            ;  // RTAG标签使能
reg  [15:0]             r_vlan_tag          [PORT_NUM-1:0]    ;  // VLAN标签配置
reg  [15:0]             r_rtag              [PORT_NUM-1:0]    ;  // RTAG配置
reg  [15:0]             r_ether_type        [PORT_NUM-1:0]    ;  // 以太类型配置

// AXI驱动信号 - 用于send_frame_to_port任务
reg  [DATA_WIDTH-1:0]   r_port_axi_data    [PORT_NUM-1:0]     ;
reg  [KEEP_WIDTH-1:0]   r_port_axi_keep    [PORT_NUM-1:0]     ;
reg                     r_port_axi_valid   [PORT_NUM-1:0]     ;
reg                     r_port_axi_last    [PORT_NUM-1:0]     ;

// 帧生成器输出信号
wire [DATA_WIDTH-1:0]   w_gen_axi_data     [PORT_NUM-1:0]     ;
wire [KEEP_WIDTH-1:0]   w_gen_axi_keep     [PORT_NUM-1:0]     ;
wire                    w_gen_axi_valid    [PORT_NUM-1:0]     ;
wire                    w_gen_axi_last     [PORT_NUM-1:0]     ;

// 控制信号：选择数据源 (0=testbench驱动, 1=帧生成器)
reg  [PORT_NUM-1:0]     r_axi_source_sel                      ;

// 统计信号
reg  [31:0]             r_frame_count       [PORT_NUM-1:0]    ;
reg  [31:0]             r_byte_count        [PORT_NUM-1:0]    ;
reg  [31:0]             r_error_count       [PORT_NUM-1:0]    ;

// MAC地址表 - 用于重复MAC测试
reg  [47:0]             r_src_mac_table     [0:15]            ;
reg  [47:0]             r_dst_mac_table     [0:15]            ;
reg  [3:0]              r_mac_table_index                     ;

// CRC32计算模块信号
reg                     r_crc_en                              ;
reg  [7:0]              r_crc_data                            ;
wire [31:0]             w_crc_out                             ;
reg                     r_crc_rst                             ;

// QBU测试进程变量
reg  [47:0]             r_test_dmac_pmac                      ;
reg  [47:0]             r_test_smac_pmac                      ;
reg  [47:0]             r_test_dmac_emac                      ;
reg  [47:0]             r_test_smac_emac                      ;
integer                 r_test_port_pmac                      ;
integer                 r_test_port_emac                      ;
integer                 r_test_loop_i                         ; // pMAC测试循环变量
integer                 r_test_loop_j                         ; // eMAC测试循环变量
 
// 以太网帧配置参数（使用reg变量存储配置）
reg [47:0] r_frame_dest_mac;        // 目标MAC地址
reg [47:0] r_frame_src_mac;         // 源MAC地址

// 可选VLAN字段
reg        r_frame_vlan_enable;     // VLAN使能
reg [15:0] r_frame_vlan_tpid;       // VLAN TPID (0x8100)
reg [2:0]  r_frame_vlan_pcp;        // VLAN PCP
reg        r_frame_vlan_dei;        // VLAN DEI
reg [11:0] r_frame_vlan_vid;        // VLAN ID

// 可选RTAG字段
reg        r_frame_rtag_enable;     // RTAG使能
reg [15:0] r_frame_rtag_tpid;       // RTAG TPID (0x8100)
reg [2:0]  r_frame_rtag_pcp;        // RTAG PCP
reg        r_frame_rtag_dei;        // RTAG DEI
reg [11:0] r_frame_rtag_vid;        // RTAG VID
reg [15:0] r_frame_rtag_sequence;   // RTAG序列号
reg [7:0]  r_frame_rtag_stream_id;  // RTAG流ID

// 以太网类型
reg [15:0] r_frame_eth_type;        // 以太网类型字段

// 载荷配置
integer    r_frame_payload_len;     // 载荷长度
reg [7:0]  r_frame_payload_pattern; // 载荷模式(0=递增, 1=全0, 2=全1, 3=随机)

// CRC配置
reg        r_frame_auto_crc = 1'b1;        // 自动计算CRC
reg [31:0] r_frame_manual_crc;      // 手动指定CRC值

// 前导码配置
reg        r_frame_preamble_enable = 1'b1; // 前导码使能 (默认使能)

// 预定义的以太网类型
parameter ETH_TYPE_IPV4     = 16'h0800;
parameter ETH_TYPE_ARP      = 16'h0806;
parameter ETH_TYPE_IPV6     = 16'h86DD;
parameter ETH_TYPE_MPLS     = 16'h8847;
parameter ETH_TYPE_PTP      = 16'h88F7;
parameter ETH_TYPE_LLDP     = 16'h88CC;
parameter ETH_TYPE_TSN      = 16'h22F0;
parameter VLAN_TPID         = 16'h8100;
parameter RTAG_TPID         = 16'hF1C1;
parameter PORT_FIFO_PRI_NUM =      8       ;  // 优先级fifo数量
// 帧生成缓冲区
reg [7:0] frame_buffer [0:MAX_FRAME_LEN-1];
integer   frame_length;   

// req_ack 交互信号reg定义（用于always块赋值）
wire                                      w_tx0_req         ;
wire                                      w_tx1_req         ;
wire                                      w_tx2_req         ;
wire                                      w_tx3_req         ;
wire                                      w_tx4_req         ;
wire                                      w_tx5_req         ;
wire                                      w_tx6_req         ;
wire                                      w_tx7_req         ;

reg                                      r_mac0_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx0_ack_rst;
reg                                      r_mac0_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx1_ack_rst;
reg                                      r_mac0_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx2_ack_rst;
reg                                      r_mac0_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx3_ack_rst;
reg                                      r_mac0_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx4_ack_rst;
reg                                      r_mac0_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx5_ack_rst;
reg                                      r_mac0_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx6_ack_rst;
reg                                      r_mac0_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac0_tx7_ack_rst;
reg                                       r_tx1_req         ;
reg                                      r_mac1_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx0_ack_rst;
reg                                      r_mac1_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx1_ack_rst;
reg                                      r_mac1_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx2_ack_rst;
reg                                      r_mac1_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx3_ack_rst;
reg                                      r_mac1_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx4_ack_rst;
reg                                      r_mac1_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx5_ack_rst;
reg                                      r_mac1_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx6_ack_rst;
reg                                      r_mac1_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac1_tx7_ack_rst;
reg                                       r_tx2_req         ;
reg                                      r_mac2_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx0_ack_rst;
reg                                      r_mac2_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx1_ack_rst;
reg                                      r_mac2_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx2_ack_rst;
reg                                      r_mac2_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx3_ack_rst;
reg                                      r_mac2_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx4_ack_rst;
reg                                      r_mac2_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx5_ack_rst;
reg                                      r_mac2_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx6_ack_rst;
reg                                      r_mac2_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac2_tx7_ack_rst;
reg                                       r_tx3_req         ;
reg                                      r_mac3_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx0_ack_rst;
reg                                      r_mac3_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx1_ack_rst;
reg                                      r_mac3_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx2_ack_rst;
reg                                      r_mac3_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx3_ack_rst;
reg                                      r_mac3_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx4_ack_rst;
reg                                      r_mac3_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx5_ack_rst;
reg                                      r_mac3_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx6_ack_rst;
reg                                      r_mac3_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac3_tx7_ack_rst;
reg                                       r_tx4_req         ;
reg                                      r_mac4_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx0_ack_rst;
reg                                      r_mac4_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx1_ack_rst;
reg                                      r_mac4_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx2_ack_rst;
reg                                      r_mac4_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx3_ack_rst;
reg                                      r_mac4_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx4_ack_rst;
reg                                      r_mac4_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx5_ack_rst;
reg                                      r_mac4_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx6_ack_rst;
reg                                      r_mac4_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac4_tx7_ack_rst;
reg                                       r_tx5_req         ;
reg                                      r_mac5_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx0_ack_rst;
reg                                      r_mac5_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx1_ack_rst;
reg                                      r_mac5_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx2_ack_rst;
reg                                      r_mac5_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx3_ack_rst;
reg                                      r_mac5_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx4_ack_rst;
reg                                      r_mac5_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx5_ack_rst;
reg                                      r_mac5_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx6_ack_rst;
reg                                      r_mac5_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac5_tx7_ack_rst;
reg                                       r_tx6_req         ;
reg                                      r_mac6_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx0_ack_rst;
reg                                      r_mac6_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx1_ack_rst;
reg                                      r_mac6_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx2_ack_rst;
reg                                      r_mac6_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx3_ack_rst;
reg                                      r_mac6_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx4_ack_rst;
reg                                      r_mac6_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx5_ack_rst;
reg                                      r_mac6_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx6_ack_rst;
reg                                      r_mac6_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac6_tx7_ack_rst;
reg                                       r_tx7_req         ;
reg                                      r_mac7_tx0_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx0_ack_rst;
reg                                      r_mac7_tx1_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx1_ack_rst;
reg                                      r_mac7_tx2_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx2_ack_rst;
reg                                      r_mac7_tx3_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx3_ack_rst;
reg                                      r_mac7_tx4_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx4_ack_rst;
reg                                      r_mac7_tx5_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx5_ack_rst;
reg                                      r_mac7_tx6_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx6_ack_rst;
reg                                      r_mac7_tx7_ack    ;
reg    [PORT_FIFO_PRI_NUM-1:0]           r_mac7_tx7_ack_rst;

// wire信号连接（将reg输出连接到原wire信号）
// assign w_tx0_req = w_tx0_req;
assign w_mac0_tx0_ack = r_mac0_tx0_ack; assign w_mac0_tx0_ack_rst = r_mac0_tx0_ack_rst;
assign w_mac0_tx1_ack = r_mac0_tx1_ack; assign w_mac0_tx1_ack_rst = r_mac0_tx1_ack_rst;
assign w_mac0_tx2_ack = r_mac0_tx2_ack; assign w_mac0_tx2_ack_rst = r_mac0_tx2_ack_rst;
assign w_mac0_tx3_ack = r_mac0_tx3_ack; assign w_mac0_tx3_ack_rst = r_mac0_tx3_ack_rst;
assign w_mac0_tx4_ack = r_mac0_tx4_ack; assign w_mac0_tx4_ack_rst = r_mac0_tx4_ack_rst;
assign w_mac0_tx5_ack = r_mac0_tx5_ack; assign w_mac0_tx5_ack_rst = r_mac0_tx5_ack_rst;
assign w_mac0_tx6_ack = r_mac0_tx6_ack; assign w_mac0_tx6_ack_rst = r_mac0_tx6_ack_rst;
assign w_mac0_tx7_ack = r_mac0_tx7_ack; assign w_mac0_tx7_ack_rst = r_mac0_tx7_ack_rst;
// assign w_tx1_req = r_tx1_req;
assign w_mac1_tx0_ack = r_mac1_tx0_ack; assign w_mac1_tx0_ack_rst = r_mac1_tx0_ack_rst;
assign w_mac1_tx1_ack = r_mac1_tx1_ack; assign w_mac1_tx1_ack_rst = r_mac1_tx1_ack_rst;
assign w_mac1_tx2_ack = r_mac1_tx2_ack; assign w_mac1_tx2_ack_rst = r_mac1_tx2_ack_rst;
assign w_mac1_tx3_ack = r_mac1_tx3_ack; assign w_mac1_tx3_ack_rst = r_mac1_tx3_ack_rst;
assign w_mac1_tx4_ack = r_mac1_tx4_ack; assign w_mac1_tx4_ack_rst = r_mac1_tx4_ack_rst;
assign w_mac1_tx5_ack = r_mac1_tx5_ack; assign w_mac1_tx5_ack_rst = r_mac1_tx5_ack_rst;
assign w_mac1_tx6_ack = r_mac1_tx6_ack; assign w_mac1_tx6_ack_rst = r_mac1_tx6_ack_rst;
assign w_mac1_tx7_ack = r_mac1_tx7_ack; assign w_mac1_tx7_ack_rst = r_mac1_tx7_ack_rst;
// assign w_tx2_req = r_tx2_req;
assign w_mac2_tx0_ack = r_mac2_tx0_ack; assign w_mac2_tx0_ack_rst = r_mac2_tx0_ack_rst;
assign w_mac2_tx1_ack = r_mac2_tx1_ack; assign w_mac2_tx1_ack_rst = r_mac2_tx1_ack_rst;
assign w_mac2_tx2_ack = r_mac2_tx2_ack; assign w_mac2_tx2_ack_rst = r_mac2_tx2_ack_rst;
assign w_mac2_tx3_ack = r_mac2_tx3_ack; assign w_mac2_tx3_ack_rst = r_mac2_tx3_ack_rst;
assign w_mac2_tx4_ack = r_mac2_tx4_ack; assign w_mac2_tx4_ack_rst = r_mac2_tx4_ack_rst;
assign w_mac2_tx5_ack = r_mac2_tx5_ack; assign w_mac2_tx5_ack_rst = r_mac2_tx5_ack_rst;
assign w_mac2_tx6_ack = r_mac2_tx6_ack; assign w_mac2_tx6_ack_rst = r_mac2_tx6_ack_rst;
assign w_mac2_tx7_ack = r_mac2_tx7_ack; assign w_mac2_tx7_ack_rst = r_mac2_tx7_ack_rst;
// assign w_tx3_req = r_tx3_req;
assign w_mac3_tx0_ack = r_mac3_tx0_ack; assign w_mac3_tx0_ack_rst = r_mac3_tx0_ack_rst;
assign w_mac3_tx1_ack = r_mac3_tx1_ack; assign w_mac3_tx1_ack_rst = r_mac3_tx1_ack_rst;
assign w_mac3_tx2_ack = r_mac3_tx2_ack; assign w_mac3_tx2_ack_rst = r_mac3_tx2_ack_rst;
assign w_mac3_tx3_ack = r_mac3_tx3_ack; assign w_mac3_tx3_ack_rst = r_mac3_tx3_ack_rst;
assign w_mac3_tx4_ack = r_mac3_tx4_ack; assign w_mac3_tx4_ack_rst = r_mac3_tx4_ack_rst;
assign w_mac3_tx5_ack = r_mac3_tx5_ack; assign w_mac3_tx5_ack_rst = r_mac3_tx5_ack_rst;
assign w_mac3_tx6_ack = r_mac3_tx6_ack; assign w_mac3_tx6_ack_rst = r_mac3_tx6_ack_rst;
assign w_mac3_tx7_ack = r_mac3_tx7_ack; assign w_mac3_tx7_ack_rst = r_mac3_tx7_ack_rst;
// assign w_tx4_req = r_tx4_req;
assign w_mac4_tx0_ack = r_mac4_tx0_ack; assign w_mac4_tx0_ack_rst = r_mac4_tx0_ack_rst;
assign w_mac4_tx1_ack = r_mac4_tx1_ack; assign w_mac4_tx1_ack_rst = r_mac4_tx1_ack_rst;
assign w_mac4_tx2_ack = r_mac4_tx2_ack; assign w_mac4_tx2_ack_rst = r_mac4_tx2_ack_rst;
assign w_mac4_tx3_ack = r_mac4_tx3_ack; assign w_mac4_tx3_ack_rst = r_mac4_tx3_ack_rst;
assign w_mac4_tx4_ack = r_mac4_tx4_ack; assign w_mac4_tx4_ack_rst = r_mac4_tx4_ack_rst;
assign w_mac4_tx5_ack = r_mac4_tx5_ack; assign w_mac4_tx5_ack_rst = r_mac4_tx5_ack_rst;
assign w_mac4_tx6_ack = r_mac4_tx6_ack; assign w_mac4_tx6_ack_rst = r_mac4_tx6_ack_rst;
assign w_mac4_tx7_ack = r_mac4_tx7_ack; assign w_mac4_tx7_ack_rst = r_mac4_tx7_ack_rst;
// assign w_tx5_req = r_tx5_req;
assign w_mac5_tx0_ack = r_mac5_tx0_ack; assign w_mac5_tx0_ack_rst = r_mac5_tx0_ack_rst;
assign w_mac5_tx1_ack = r_mac5_tx1_ack; assign w_mac5_tx1_ack_rst = r_mac5_tx1_ack_rst;
assign w_mac5_tx2_ack = r_mac5_tx2_ack; assign w_mac5_tx2_ack_rst = r_mac5_tx2_ack_rst;
assign w_mac5_tx3_ack = r_mac5_tx3_ack; assign w_mac5_tx3_ack_rst = r_mac5_tx3_ack_rst;
assign w_mac5_tx4_ack = r_mac5_tx4_ack; assign w_mac5_tx4_ack_rst = r_mac5_tx4_ack_rst;
assign w_mac5_tx5_ack = r_mac5_tx5_ack; assign w_mac5_tx5_ack_rst = r_mac5_tx5_ack_rst;
assign w_mac5_tx6_ack = r_mac5_tx6_ack; assign w_mac5_tx6_ack_rst = r_mac5_tx6_ack_rst;
assign w_mac5_tx7_ack = r_mac5_tx7_ack; assign w_mac5_tx7_ack_rst = r_mac5_tx7_ack_rst;
// assign w_tx6_req = r_tx6_req;
assign w_mac6_tx0_ack = r_mac6_tx0_ack; assign w_mac6_tx0_ack_rst = r_mac6_tx0_ack_rst;
assign w_mac6_tx1_ack = r_mac6_tx1_ack; assign w_mac6_tx1_ack_rst = r_mac6_tx1_ack_rst;
assign w_mac6_tx2_ack = r_mac6_tx2_ack; assign w_mac6_tx2_ack_rst = r_mac6_tx2_ack_rst;
assign w_mac6_tx3_ack = r_mac6_tx3_ack; assign w_mac6_tx3_ack_rst = r_mac6_tx3_ack_rst;
assign w_mac6_tx4_ack = r_mac6_tx4_ack; assign w_mac6_tx4_ack_rst = r_mac6_tx4_ack_rst;
assign w_mac6_tx5_ack = r_mac6_tx5_ack; assign w_mac6_tx5_ack_rst = r_mac6_tx5_ack_rst;
assign w_mac6_tx6_ack = r_mac6_tx6_ack; assign w_mac6_tx6_ack_rst = r_mac6_tx6_ack_rst;
assign w_mac6_tx7_ack = r_mac6_tx7_ack; assign w_mac6_tx7_ack_rst = r_mac6_tx7_ack_rst;
// assign w_tx7_req = r_tx7_req;
assign w_mac7_tx0_ack = r_mac7_tx0_ack; assign w_mac7_tx0_ack_rst = r_mac7_tx0_ack_rst;
assign w_mac7_tx1_ack = r_mac7_tx1_ack; assign w_mac7_tx1_ack_rst = r_mac7_tx1_ack_rst;
assign w_mac7_tx2_ack = r_mac7_tx2_ack; assign w_mac7_tx2_ack_rst = r_mac7_tx2_ack_rst;
assign w_mac7_tx3_ack = r_mac7_tx3_ack; assign w_mac7_tx3_ack_rst = r_mac7_tx3_ack_rst;
assign w_mac7_tx4_ack = r_mac7_tx4_ack; assign w_mac7_tx4_ack_rst = r_mac7_tx4_ack_rst;
assign w_mac7_tx5_ack = r_mac7_tx5_ack; assign w_mac7_tx5_ack_rst = r_mac7_tx5_ack_rst;
assign w_mac7_tx6_ack = r_mac7_tx6_ack; assign w_mac7_tx6_ack_rst = r_mac7_tx6_ack_rst;
assign w_mac7_tx7_ack = r_mac7_tx7_ack; assign w_mac7_tx7_ack_rst = r_mac7_tx7_ack_rst;

// metadata信号
wire   [METADATA_WIDTH-1:0]              w_mac0_cross_metadata       ;
wire                                     w_mac0_cross_metadata_valid ;
wire                                     w_mac0_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac1_cross_metadata       ;
wire                                     w_mac1_cross_metadata_valid ;
wire                                     w_mac1_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac2_cross_metadata       ;
wire                                     w_mac2_cross_metadata_valid ;
wire                                     w_mac2_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac3_cross_metadata       ;
wire                                     w_mac3_cross_metadata_valid ;
wire                                     w_mac3_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac4_cross_metadata       ;
wire                                     w_mac4_cross_metadata_valid ;
wire                                     w_mac4_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac5_cross_metadata       ;
wire                                     w_mac5_cross_metadata_valid ;
wire                                     w_mac5_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac6_cross_metadata       ;
wire                                     w_mac6_cross_metadata_valid ;
wire                                     w_mac6_cross_metadata_last  ;

wire   [METADATA_WIDTH-1:0]              w_mac7_cross_metadata       ;
wire                                     w_mac7_cross_metadata_valid ;
wire                                     w_mac7_cross_metadata_last  ;

// CB相关信号
wire                                     w_rtag_flag0                ;
wire   [15:0]                            w_rtag_sequence0            ;
wire   [7:0]                             w_stream_handle0            ;
wire                                     w_rtag_flag1                ;
wire   [15:0]                            w_rtag_sequence1            ;
wire   [7:0]                             w_stream_handle1            ;
wire                                     w_rtag_flag2                ;
wire   [15:0]                            w_rtag_sequence2            ;
wire   [7:0]                             w_stream_handle2            ;
wire                                     w_rtag_flag3                ;
wire   [15:0]                            w_rtag_sequence3            ;
wire   [7:0]                             w_stream_handle3            ;
wire                                     w_rtag_flag4                ;
wire   [15:0]                            w_rtag_sequence4            ;
wire   [7:0]                             w_stream_handle4            ;
wire                                     w_rtag_flag5                ;
wire   [15:0]                            w_rtag_sequence5            ;
wire   [7:0]                             w_stream_handle5            ;
wire                                     w_rtag_flag6                ;
wire   [15:0]                            w_rtag_sequence6            ;
wire   [7:0]                             w_stream_handle6            ;
wire                                     w_rtag_flag7                ;
wire   [15:0]                            w_rtag_sequence7            ;
wire   [7:0]                             w_stream_handle7            ;

wire   [PORT_NUM-1:0]                    w_cb_pass_en                ;
wire   [PORT_NUM-1:0]                    w_cb_discard_en             ;
wire   [PORT_NUM-1:0]                    w_cb_judge_finish           ;

reg   tcam_done;  // TCAM初始化完成标志

    //==========================================================================
    // req-ack交互逻辑实现
    // 当w_txN_req拉高时，解析w_macN_cross_metadata生成对应的ack和ack_rst信号
    //==========================================================================
    
    // 通道0的req-ack逻辑
    always @(*) begin
        // 默认所有ack信号为0
        r_mac0_tx0_ack = 1'b0; r_mac0_tx1_ack = 1'b0; r_mac0_tx2_ack = 1'b0; r_mac0_tx3_ack = 1'b0;
        r_mac0_tx4_ack = 1'b0; r_mac0_tx5_ack = 1'b0; r_mac0_tx6_ack = 1'b0; r_mac0_tx7_ack = 1'b0;
        // 默认所有ack_rst信号为0
        r_mac0_tx0_ack_rst = 8'b0; r_mac0_tx1_ack_rst = 8'b0; r_mac0_tx2_ack_rst = 8'b0; r_mac0_tx3_ack_rst = 8'b0;
        r_mac0_tx4_ack_rst = 8'b0; r_mac0_tx5_ack_rst = 8'b0; r_mac0_tx6_ack_rst = 8'b0; r_mac0_tx7_ack_rst = 8'b0;
        
        if (w_tx0_req) begin
            // 解析转发通道bitmap [59:52] 和优先级 [62:60]
            if (w_mac0_cross_metadata[52]) begin r_mac0_tx0_ack = 1'b1; r_mac0_tx0_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[53]) begin r_mac0_tx1_ack = 1'b1; r_mac0_tx1_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[54]) begin r_mac0_tx2_ack = 1'b1; r_mac0_tx2_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[55]) begin r_mac0_tx3_ack = 1'b1; r_mac0_tx3_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[56]) begin r_mac0_tx4_ack = 1'b1; r_mac0_tx4_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[57]) begin r_mac0_tx5_ack = 1'b1; r_mac0_tx5_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[58]) begin r_mac0_tx6_ack = 1'b1; r_mac0_tx6_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
            if (w_mac0_cross_metadata[59]) begin r_mac0_tx7_ack = 1'b1; r_mac0_tx7_ack_rst = 8'b1 << w_mac0_cross_metadata[62:60]; end
        end
    end
    
    // 通道1的req-ack逻辑
    always @(*) begin
        r_mac1_tx0_ack = 1'b0; r_mac1_tx1_ack = 1'b0; r_mac1_tx2_ack = 1'b0; r_mac1_tx3_ack = 1'b0;
        r_mac1_tx4_ack = 1'b0; r_mac1_tx5_ack = 1'b0; r_mac1_tx6_ack = 1'b0; r_mac1_tx7_ack = 1'b0;
        r_mac1_tx0_ack_rst = 8'b0; r_mac1_tx1_ack_rst = 8'b0; r_mac1_tx2_ack_rst = 8'b0; r_mac1_tx3_ack_rst = 8'b0;
        r_mac1_tx4_ack_rst = 8'b0; r_mac1_tx5_ack_rst = 8'b0; r_mac1_tx6_ack_rst = 8'b0; r_mac1_tx7_ack_rst = 8'b0;
        
        if (w_tx1_req) begin
            if (w_mac1_cross_metadata[52]) begin r_mac1_tx0_ack = 1'b1; r_mac1_tx0_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[53]) begin r_mac1_tx1_ack = 1'b1; r_mac1_tx1_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[54]) begin r_mac1_tx2_ack = 1'b1; r_mac1_tx2_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[55]) begin r_mac1_tx3_ack = 1'b1; r_mac1_tx3_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[56]) begin r_mac1_tx4_ack = 1'b1; r_mac1_tx4_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[57]) begin r_mac1_tx5_ack = 1'b1; r_mac1_tx5_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[58]) begin r_mac1_tx6_ack = 1'b1; r_mac1_tx6_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
            if (w_mac1_cross_metadata[59]) begin r_mac1_tx7_ack = 1'b1; r_mac1_tx7_ack_rst = 8'b1 << w_mac1_cross_metadata[62:60]; end
        end
    end
    
    // 通道2的req-ack逻辑
    always @(*) begin
        r_mac2_tx0_ack = 1'b0; r_mac2_tx1_ack = 1'b0; r_mac2_tx2_ack = 1'b0; r_mac2_tx3_ack = 1'b0;
        r_mac2_tx4_ack = 1'b0; r_mac2_tx5_ack = 1'b0; r_mac2_tx6_ack = 1'b0; r_mac2_tx7_ack = 1'b0;
        r_mac2_tx0_ack_rst = 8'b0; r_mac2_tx1_ack_rst = 8'b0; r_mac2_tx2_ack_rst = 8'b0; r_mac2_tx3_ack_rst = 8'b0;
        r_mac2_tx4_ack_rst = 8'b0; r_mac2_tx5_ack_rst = 8'b0; r_mac2_tx6_ack_rst = 8'b0; r_mac2_tx7_ack_rst = 8'b0;
        
        if (w_tx2_req) begin
            if (w_mac2_cross_metadata[52]) begin r_mac2_tx0_ack = 1'b1; r_mac2_tx0_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[53]) begin r_mac2_tx1_ack = 1'b1; r_mac2_tx1_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[54]) begin r_mac2_tx2_ack = 1'b1; r_mac2_tx2_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[55]) begin r_mac2_tx3_ack = 1'b1; r_mac2_tx3_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[56]) begin r_mac2_tx4_ack = 1'b1; r_mac2_tx4_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[57]) begin r_mac2_tx5_ack = 1'b1; r_mac2_tx5_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[58]) begin r_mac2_tx6_ack = 1'b1; r_mac2_tx6_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
            if (w_mac2_cross_metadata[59]) begin r_mac2_tx7_ack = 1'b1; r_mac2_tx7_ack_rst = 8'b1 << w_mac2_cross_metadata[62:60]; end
        end
    end
    
    // 通道3的req-ack逻辑
    always @(*) begin
        r_mac3_tx0_ack = 1'b0; r_mac3_tx1_ack = 1'b0; r_mac3_tx2_ack = 1'b0; r_mac3_tx3_ack = 1'b0;
        r_mac3_tx4_ack = 1'b0; r_mac3_tx5_ack = 1'b0; r_mac3_tx6_ack = 1'b0; r_mac3_tx7_ack = 1'b0;
        r_mac3_tx0_ack_rst = 8'b0; r_mac3_tx1_ack_rst = 8'b0; r_mac3_tx2_ack_rst = 8'b0; r_mac3_tx3_ack_rst = 8'b0;
        r_mac3_tx4_ack_rst = 8'b0; r_mac3_tx5_ack_rst = 8'b0; r_mac3_tx6_ack_rst = 8'b0; r_mac3_tx7_ack_rst = 8'b0;
        
        if (w_tx3_req) begin
            if (w_mac3_cross_metadata[52]) begin r_mac3_tx0_ack = 1'b1; r_mac3_tx0_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[53]) begin r_mac3_tx1_ack = 1'b1; r_mac3_tx1_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[54]) begin r_mac3_tx2_ack = 1'b1; r_mac3_tx2_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[55]) begin r_mac3_tx3_ack = 1'b1; r_mac3_tx3_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[56]) begin r_mac3_tx4_ack = 1'b1; r_mac3_tx4_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[57]) begin r_mac3_tx5_ack = 1'b1; r_mac3_tx5_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[58]) begin r_mac3_tx6_ack = 1'b1; r_mac3_tx6_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
            if (w_mac3_cross_metadata[59]) begin r_mac3_tx7_ack = 1'b1; r_mac3_tx7_ack_rst = 8'b1 << w_mac3_cross_metadata[62:60]; end
        end
    end
    
    // 通道4的req-ack逻辑
    always @(*) begin
        r_mac4_tx0_ack = 1'b0; r_mac4_tx1_ack = 1'b0; r_mac4_tx2_ack = 1'b0; r_mac4_tx3_ack = 1'b0;
        r_mac4_tx4_ack = 1'b0; r_mac4_tx5_ack = 1'b0; r_mac4_tx6_ack = 1'b0; r_mac4_tx7_ack = 1'b0;
        r_mac4_tx0_ack_rst = 8'b0; r_mac4_tx1_ack_rst = 8'b0; r_mac4_tx2_ack_rst = 8'b0; r_mac4_tx3_ack_rst = 8'b0;
        r_mac4_tx4_ack_rst = 8'b0; r_mac4_tx5_ack_rst = 8'b0; r_mac4_tx6_ack_rst = 8'b0; r_mac4_tx7_ack_rst = 8'b0;
        
        if (w_tx4_req) begin
            if (w_mac4_cross_metadata[52]) begin r_mac4_tx0_ack = 1'b1; r_mac4_tx0_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[53]) begin r_mac4_tx1_ack = 1'b1; r_mac4_tx1_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[54]) begin r_mac4_tx2_ack = 1'b1; r_mac4_tx2_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[55]) begin r_mac4_tx3_ack = 1'b1; r_mac4_tx3_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[56]) begin r_mac4_tx4_ack = 1'b1; r_mac4_tx4_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[57]) begin r_mac4_tx5_ack = 1'b1; r_mac4_tx5_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[58]) begin r_mac4_tx6_ack = 1'b1; r_mac4_tx6_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
            if (w_mac4_cross_metadata[59]) begin r_mac4_tx7_ack = 1'b1; r_mac4_tx7_ack_rst = 8'b1 << w_mac4_cross_metadata[62:60]; end
        end
    end
    
    // 通道5的req-ack逻辑
    always @(*) begin
        r_mac5_tx0_ack = 1'b0; r_mac5_tx1_ack = 1'b0; r_mac5_tx2_ack = 1'b0; r_mac5_tx3_ack = 1'b0;
        r_mac5_tx4_ack = 1'b0; r_mac5_tx5_ack = 1'b0; r_mac5_tx6_ack = 1'b0; r_mac5_tx7_ack = 1'b0;
        r_mac5_tx0_ack_rst = 8'b0; r_mac5_tx1_ack_rst = 8'b0; r_mac5_tx2_ack_rst = 8'b0; r_mac5_tx3_ack_rst = 8'b0;
        r_mac5_tx4_ack_rst = 8'b0; r_mac5_tx5_ack_rst = 8'b0; r_mac5_tx6_ack_rst = 8'b0; r_mac5_tx7_ack_rst = 8'b0;
        
        if (w_tx5_req) begin
            if (w_mac5_cross_metadata[52]) begin r_mac5_tx0_ack = 1'b1; r_mac5_tx0_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[53]) begin r_mac5_tx1_ack = 1'b1; r_mac5_tx1_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[54]) begin r_mac5_tx2_ack = 1'b1; r_mac5_tx2_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[55]) begin r_mac5_tx3_ack = 1'b1; r_mac5_tx3_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[56]) begin r_mac5_tx4_ack = 1'b1; r_mac5_tx4_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[57]) begin r_mac5_tx5_ack = 1'b1; r_mac5_tx5_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[58]) begin r_mac5_tx6_ack = 1'b1; r_mac5_tx6_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
            if (w_mac5_cross_metadata[59]) begin r_mac5_tx7_ack = 1'b1; r_mac5_tx7_ack_rst = 8'b1 << w_mac5_cross_metadata[62:60]; end
        end
    end
    
    // 通道6的req-ack逻辑
    always @(*) begin
        r_mac6_tx0_ack = 1'b0; r_mac6_tx1_ack = 1'b0; r_mac6_tx2_ack = 1'b0; r_mac6_tx3_ack = 1'b0;
        r_mac6_tx4_ack = 1'b0; r_mac6_tx5_ack = 1'b0; r_mac6_tx6_ack = 1'b0; r_mac6_tx7_ack = 1'b0;
        r_mac6_tx0_ack_rst = 8'b0; r_mac6_tx1_ack_rst = 8'b0; r_mac6_tx2_ack_rst = 8'b0; r_mac6_tx3_ack_rst = 8'b0;
        r_mac6_tx4_ack_rst = 8'b0; r_mac6_tx5_ack_rst = 8'b0; r_mac6_tx6_ack_rst = 8'b0; r_mac6_tx7_ack_rst = 8'b0;
        
        if (w_tx6_req) begin
            if (w_mac6_cross_metadata[52]) begin r_mac6_tx0_ack = 1'b1; r_mac6_tx0_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[53]) begin r_mac6_tx1_ack = 1'b1; r_mac6_tx1_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[54]) begin r_mac6_tx2_ack = 1'b1; r_mac6_tx2_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[55]) begin r_mac6_tx3_ack = 1'b1; r_mac6_tx3_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[56]) begin r_mac6_tx4_ack = 1'b1; r_mac6_tx4_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[57]) begin r_mac6_tx5_ack = 1'b1; r_mac6_tx5_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[58]) begin r_mac6_tx6_ack = 1'b1; r_mac6_tx6_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
            if (w_mac6_cross_metadata[59]) begin r_mac6_tx7_ack = 1'b1; r_mac6_tx7_ack_rst = 8'b1 << w_mac6_cross_metadata[62:60]; end
        end
    end
    
    // 通道7的req-ack逻辑
    always @(*) begin
        r_mac7_tx0_ack = 1'b0; r_mac7_tx1_ack = 1'b0; r_mac7_tx2_ack = 1'b0; r_mac7_tx3_ack = 1'b0;
        r_mac7_tx4_ack = 1'b0; r_mac7_tx5_ack = 1'b0; r_mac7_tx6_ack = 1'b0; r_mac7_tx7_ack = 1'b0;
        r_mac7_tx0_ack_rst = 8'b0; r_mac7_tx1_ack_rst = 8'b0; r_mac7_tx2_ack_rst = 8'b0; r_mac7_tx3_ack_rst = 8'b0;
        r_mac7_tx4_ack_rst = 8'b0; r_mac7_tx5_ack_rst = 8'b0; r_mac7_tx6_ack_rst = 8'b0; r_mac7_tx7_ack_rst = 8'b0;
        
        if (w_tx7_req) begin
            if (w_mac7_cross_metadata[52]) begin r_mac7_tx0_ack = 1'b1; r_mac7_tx0_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[53]) begin r_mac7_tx1_ack = 1'b1; r_mac7_tx1_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[54]) begin r_mac7_tx2_ack = 1'b1; r_mac7_tx2_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[55]) begin r_mac7_tx3_ack = 1'b1; r_mac7_tx3_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[56]) begin r_mac7_tx4_ack = 1'b1; r_mac7_tx4_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[57]) begin r_mac7_tx5_ack = 1'b1; r_mac7_tx5_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[58]) begin r_mac7_tx6_ack = 1'b1; r_mac7_tx6_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
            if (w_mac7_cross_metadata[59]) begin r_mac7_tx7_ack = 1'b1; r_mac7_tx7_ack_rst = 8'b1 << w_mac7_cross_metadata[62:60]; end
        end
    end


// Wires for connecting rx_mac_mng to swlist
`ifdef CPU_MAC
wire [11:0] w_vlan_id_cpu;
wire [HASH_DATA_WIDTH-1:0] w_dmac_cpu_hash_key;
wire [47:0] w_dmac_cpu;
wire w_dmac_cpu_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac_cpu_hash_key;
wire [47:0] w_smac_cpu;
wire w_smac_cpu_vld;
wire [PORT_NUM-1:0] w_tx_cpu_port;
wire       w_tx_cpu_port_vld        ;
wire [1:0] w_tx_cpu_port_broadcast;
`endif
`ifdef MAC1
wire [11:0] w_vlan_id1;
wire [HASH_DATA_WIDTH-1:0] w_dmac1_hash_key;
wire [47:0] w_dmac1;
wire w_dmac1_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac1_hash_key;
wire [47:0] w_smac1;
wire w_smac1_vld;
wire [PORT_NUM-1:0] w_tx_1_port;
wire w_tx_1_port_vld;
wire [1:0] w_tx_1_port_broadcast;
`endif
`ifdef MAC2
wire [11:0] w_vlan_id2;
wire [HASH_DATA_WIDTH-1:0] w_dmac2_hash_key;
wire [47:0] w_dmac2;
wire w_dmac2_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac2_hash_key;
wire [47:0] w_smac2;
wire w_smac2_vld;
wire [PORT_NUM-1:0] w_tx_2_port;
wire w_tx_2_port_vld;
wire [1:0] w_tx_2_port_broadcast;
`endif
`ifdef MAC3
wire [11:0] w_vlan_id3;
wire [HASH_DATA_WIDTH-1:0] w_dmac3_hash_key;
wire [47:0] w_dmac3;
wire w_dmac3_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac3_hash_key;
wire [47:0] w_smac3;
wire w_smac3_vld;
wire [PORT_NUM-1:0] w_tx_3_port;
wire w_tx_3_port_vld;
wire [1:0] w_tx_3_port_broadcast;
`endif
`ifdef MAC4
wire [11:0] w_vlan_id4;
wire [HASH_DATA_WIDTH-1:0] w_dmac4_hash_key;
wire [47:0] w_dmac4;
wire w_dmac4_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac4_hash_key;
wire [47:0] w_smac4;
wire w_smac4_vld;
wire [PORT_NUM-1:0] w_tx_4_port;
wire w_tx_4_port_vld;
wire [1:0] w_tx_4_port_broadcast;
`endif
`ifdef MAC5
wire [11:0] w_vlan_id5;
wire [HASH_DATA_WIDTH-1:0] w_dmac5_hash_key;
wire [47:0] w_dmac5;
wire w_dmac5_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac5_hash_key;
wire [47:0] w_smac5;
wire w_smac5_vld;
wire [PORT_NUM-1:0] w_tx_5_port;
wire w_tx_5_port_vld;
wire [1:0] w_tx_5_port_broadcast;
`endif
`ifdef MAC6
wire [11:0] w_vlan_id6;
wire [HASH_DATA_WIDTH-1:0] w_dmac6_hash_key;
wire [47:0] w_dmac6;
wire w_dmac6_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac6_hash_key;
wire [47:0] w_smac6;
wire w_smac6_vld;
wire [PORT_NUM-1:0] w_tx_6_port;
wire        w_tx_6_port_vld         ;
wire [1:0]  w_tx_6_port_broadcast;
`endif
`ifdef MAC7
wire [11:0] w_vlan_id7;
wire [HASH_DATA_WIDTH-1:0] w_dmac7_hash_key;
wire [47:0] w_dmac7;
wire w_dmac7_vld;
wire [HASH_DATA_WIDTH-1:0] w_smac7_hash_key;
wire [47:0] w_smac7;
wire w_smac7_vld;
wire [PORT_NUM-1:0] w_tx_7_port;
wire w_tx_7_port_vld;
wire [1:0] w_tx_7_port_broadcast;
`endif
    //==========================================================================
    // 时钟和复位生成
    //==========================================================================
    initial begin
        r_clk = 1'b0;
        forever #(CLK_PERIOD/2) r_clk = ~r_clk;
    end
    
    initial begin
        r_rst_n = 1'b0;
        tcam_done = 1'b0;  // 初始化TCAM完成标志为0
        #(CLK_PERIOD * 10);
        r_rst_n = 1'b1;
    end
    
    //==========================================================================
    // 端口配置信号赋值
    //==========================================================================
    assign w_mac_port_link = 8'hFF;                                // 所有端口连接
    assign w_mac_port_speed = 16'h5555;                            // 所有端口1000M (每端口2bit，01=100M，10=1000M)
    assign w_mac_port_filter_preamble_v = 8'h00;                   // 不过滤前导码
    
    //==========================================================================
    // 信号拆分与组合
    //==========================================================================
    genvar i;
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : gen_port_signals
            // 数据源选择：帧生成器 或 testbench驱动 (保留用于兼容旧代码)
            assign w_port_axi_data[i]  = r_axi_source_sel[i] ? w_gen_axi_data[i]  : r_port_axi_data[i];
            assign w_port_axi_keep[i]  = r_axi_source_sel[i] ? w_gen_axi_keep[i]  : r_port_axi_keep[i];
            assign w_port_axi_valid[i] = r_axi_source_sel[i] ? w_gen_axi_valid[i] : r_port_axi_valid[i];
            assign w_port_axi_last[i]  = r_axi_source_sel[i] ? w_gen_axi_last[i]  : r_port_axi_last[i];
            assign w_port_axi_user[i]  = 16'd1500;  // 默认帧长度
            
            // ready信号反向传播到原有接口
            assign w_port_axi_ready[i] = w_emac_axi_ready[i] | w_pmac_axi_ready[i];
            
            // 组合QBU输出信号到系统总线
            assign w_mac_axi_data[i] = w_qbu_mac_axi_data[i];
            assign w_mac_axi_data_keep[(i+1)*KEEP_WIDTH-1:i*KEEP_WIDTH] = w_qbu_mac_axi_keep[i];
            assign w_mac_axi_data_valid[i] = w_qbu_mac_axi_valid[i];
            assign w_mac_axi_data_last[i] = w_qbu_mac_axi_last[i];
            
            // ready信号反向传播
            assign w_qbu_mac_axi_ready[i] = w_mac_axi_data_ready[i];
        end
    endgenerate
    
    //==========================================================================
    // QBU模块例化 - 8个端口的帧抢占发送器
    //==========================================================================
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : gen_qbu_send
            qbu_send #(
                .AXIS_DATA_WIDTH (DATA_WIDTH),
                .QUEUE_NUM       (8)
            ) u_qbu_send (
                .i_clk                      (r_clk                      ),
                .i_rst                      (!r_rst_n                   ),
                
                // pMAC输入通道 (可抢占通道，低优先级)
                .i_pmac_tx_axis_data       (r_pmac_axi_data[i]          ),
                .i_pmac_tx_axis_user       (r_pmac_axi_user[i]          ),
                .i_pmac_tx_axis_keep       (r_pmac_axi_keep[i]          ),
                .i_pmac_tx_axis_last       (r_pmac_axi_last[i]          ),
                .i_pmac_tx_axis_valid      (r_pmac_axi_valid[i]         ),
                .o_pmac_tx_axis_ready      (w_pmac_axi_ready[i]         ),
                .i_pmac_ethertype          (r_pmac_ethertype[i]         ),
                
                // eMAC输入通道 (高优先级，可抢占pMAC)
                .i_emac_tx_axis_data       (r_emac_axi_data[i]          ),
                .i_emac_tx_axis_user       (r_emac_axi_user[i]          ),
                .i_emac_tx_axis_keep       (r_emac_axi_keep[i]          ),
                .i_emac_tx_axis_last       (r_emac_axi_last[i]          ),
                .i_emac_tx_axis_valid      (r_emac_axi_valid[i]         ),
                .o_emac_tx_axis_ready      (w_emac_axi_ready[i]         ),
                .i_emac_ethertype          (r_emac_ethertype[i]         ),
                
                // QBU验证和响应
                .i_qbu_verify_valid        (r_qbu_verify_valid[i]       ),
                .i_qbu_response_valid      (r_qbu_response_valid[i]     ),
                
                // MAC输出接口
                .o_mac_axi_data            (w_qbu_mac_axi_data[i]       ),
                .o_mac_axi_data_keep       (w_qbu_mac_axi_keep[i]       ),
                .o_mac_axi_data_valid      (w_qbu_mac_axi_valid[i]      ),
                .o_mac_axi_data_user       (w_qbu_mac_axi_user[i]       ),
                .i_mac_axi_data_ready      (w_qbu_mac_axi_ready[i]      ),
                .o_mac_axi_data_last       (w_qbu_mac_axi_last[i]       ),
                
                // 时间戳接口
                .o_mac_time_irq            (w_qbu_time_irq[i]           ),
                .o_mac_frame_seq           (w_qbu_frame_seq[i]          ),
                .o_timestamp_addr          (w_qbu_timestamp_addr[i]     )
            );
        end
    endgenerate 

tcam_write_test_utils u_tcam_write_test_utils (
    .clk                    (r_clk                         ),
    .rst                    (~r_rst_n                      ), // active-high reset for the utility
    .o_reg_bus_we           (tcam_o_reg_bus_we             ),
    .o_reg_bus_we_addr      (tcam_o_reg_bus_we_addr        ),
    .o_reg_bus_we_din       (tcam_o_reg_bus_we_din         ),
    .o_reg_bus_we_din_v     (tcam_o_reg_bus_we_din_v       ),
    .i_tcam_busy            (tb_i_tcam_busy                ),
    .i_write_start          (tb_i_write_start              ),
    .i_cmd_type             (tb_i_cmd_type                 ),
    .i_raw_data             (tb_i_raw_data                 ),
    .i_dont_care_mask       (tb_i_dont_care_mask           ),
    .i_action_data          (tb_i_action_data              ),
    .o_write_done           (tcam_o_write_done             ),
    .o_write_busy           (tcam_o_write_busy             )
);
    
    //==========================================================================
    // QBU pMAC和eMAC数据生成初始化
    //==========================================================================
    integer j;
    initial begin
        // 初始化pMAC和eMAC以及QBU控制信号
        for (j = 0; j < PORT_NUM; j = j + 1) begin
            // pMAC通道初始化
            r_pmac_axi_data[j]     = 8'h00;
            r_pmac_axi_keep[j]     = 1'b0;
            r_pmac_axi_valid[j]    = 1'b0;
            r_pmac_axi_last[j]     = 1'b0;
            r_pmac_axi_user[j]     = 16'd0;
            r_pmac_ethertype[j]    = 16'h0800;
            
            // eMAC通道初始化
            r_emac_axi_data[j]     = 8'h00;
            r_emac_axi_keep[j]     = 1'b0;
            r_emac_axi_valid[j]    = 1'b0;
            r_emac_axi_last[j]     = 1'b0;
            r_emac_axi_user[j]     = 16'd0;
            r_emac_ethertype[j]    = 16'h0800;
            
            // QBU控制信号初始化
            r_qbu_verify_valid[j]  = 1'b0;
            r_qbu_response_valid[j]= 1'b0;
        end
        
        // 等待复位结束
        @(posedge r_rst_n);
        repeat(10) @(posedge r_clk);
        
        // 启用QBU验证
        for (j = 0; j < PORT_NUM; j = j + 1) begin
            r_qbu_verify_valid[j] = 1'b1;
        end
        
        // pMAC和eMAC默认关闭，需要时可以在测试用例中启用
        $display("[QBU] pMAC and eMAC channels initialized - all disabled by default");
        $display("[QBU] Both channels are independent and can work simultaneously for frame preemption test");
    end
    
    //==========================================================================
    // MAC地址表初始化
    //==========================================================================
    initial begin 
        
        // 初始化源MAC地址表
        r_src_mac_table[0]  = 48'h00_11_22_33_44_55;
        r_src_mac_table[1]  = 48'h00_AA_BB_CC_DD_EE;
        r_src_mac_table[2]  = 48'h00_12_34_56_78_9A;
        r_src_mac_table[3]  = 48'h00_FE_DC_BA_98_76;
        r_src_mac_table[4]  = 48'h00_11_11_11_11_11;
        r_src_mac_table[5]  = 48'h00_22_22_22_22_22;
        r_src_mac_table[6]  = 48'h00_33_33_33_33_33;
        r_src_mac_table[7]  = 48'h00_44_44_44_44_44;
        r_src_mac_table[8]  = 48'h00_55_55_55_55_55;
        r_src_mac_table[9]  = 48'h00_66_66_66_66_66;
        r_src_mac_table[10] = 48'h00_77_77_77_77_77;
        r_src_mac_table[11] = 48'h00_88_88_88_88_88;
        r_src_mac_table[12] = 48'h00_99_99_99_99_99;
        r_src_mac_table[13] = 48'h00_AA_AA_AA_AA_AA;
        r_src_mac_table[14] = 48'h00_BB_BB_BB_BB_BB;
        r_src_mac_table[15] = 48'h00_CC_CC_CC_CC_CC;
        
        // 初始化目的MAC地址表
        r_dst_mac_table[0]  = 48'hFF_FF_FF_FF_FF_FF;              // 广播地址
        r_dst_mac_table[1]  = 48'h01_00_5E_00_00_01;              // 多播地址
        r_dst_mac_table[2]  = 48'h00_50_56_C0_00_01;
        r_dst_mac_table[3]  = 48'h00_50_56_C0_00_02;
        r_dst_mac_table[4]  = 48'h00_0C_29_12_34_56;
        r_dst_mac_table[5]  = 48'h00_1B_21_AB_CD_EF;
        r_dst_mac_table[6]  = 48'h08_00_27_FE_DC_BA;
        r_dst_mac_table[7]  = 48'h52_54_00_12_35_02;
        r_dst_mac_table[8]  = 48'h00_11_22_33_44_55;              // 重复源MAC
        r_dst_mac_table[9]  = 48'h00_AA_BB_CC_DD_EE;              // 重复源MAC
        r_dst_mac_table[10] = 48'h00_12_34_56_78_9A;              // 重复源MAC
        r_dst_mac_table[11] = 48'h00_FE_DC_BA_98_76;              // 重复源MAC
        r_dst_mac_table[12] = 48'h02_00_00_00_00_01;
        r_dst_mac_table[13] = 48'h02_00_00_00_00_02;
        r_dst_mac_table[14] = 48'h02_00_00_00_00_03;
        r_dst_mac_table[15] = 48'h02_00_00_00_00_04;
        
        r_mac_table_index = 4'b0;
        
        // 初始化AXI驱动信号
        r_axi_source_sel = 8'b00000000;   
        // 手动初始化端口信号
        r_port_axi_data[0]  = 0; r_port_axi_keep[0]  = 0; r_port_axi_valid[0] = 0; r_port_axi_last[0] = 0;
        r_port_axi_data[1]  = 0; r_port_axi_keep[1]  = 0; r_port_axi_valid[1] = 0; r_port_axi_last[1] = 0;
        r_port_axi_data[2]  = 0; r_port_axi_keep[2]  = 0; r_port_axi_valid[2] = 0; r_port_axi_last[2] = 0;
        r_port_axi_data[3]  = 0; r_port_axi_keep[3]  = 0; r_port_axi_valid[3] = 0; r_port_axi_last[3] = 0;
        r_port_axi_data[4]  = 0; r_port_axi_keep[4]  = 0; r_port_axi_valid[4] = 0; r_port_axi_last[4] = 0;
        r_port_axi_data[5]  = 0; r_port_axi_keep[5]  = 0; r_port_axi_valid[5] = 0; r_port_axi_last[5] = 0;
        r_port_axi_data[6]  = 0; r_port_axi_keep[6]  = 0; r_port_axi_valid[6] = 0; r_port_axi_last[6] = 0;
        r_port_axi_data[7]  = 0; r_port_axi_keep[7]  = 0; r_port_axi_valid[7] = 0; r_port_axi_last[7] = 0;
        
        // 初始化TCAM写表控制信号
        tb_i_write_start     = 1'b0;
        tb_i_cmd_type        = 3'b000;
        tb_i_raw_data        = 144'h0;
        tb_i_dont_care_mask  = 144'h0;
        tb_i_action_data     = 24'h0;
        
        // 初始化帧生成器配置信号
        r_frame_gen_enable = 8'b11111111;  // 使能所有端口的帧生成器
        r_frame_gen_start  = 8'b00000000;  // 初始不启动
        r_add_vlan         = 8'b00000000;  // 初始不添加VLAN标签
        r_add_rtag         = 8'b00000000;  // 初始不添加RTAG标签
        
        // 初始化前导码控制
        // r_frame_preamble_enable will be initialized in the variable declaration section
        
        // 初始化CRC计算信号
        r_crc_en = 1'b0;
        r_crc_data = 8'h00;
        r_crc_rst = 1'b1;
        
        // 初始化每个端口的配置
        r_frame_len[0] = 16'd64;  r_vlan_tag[0] = 16'h8100; r_rtag[0] = 16'h0000; r_ether_type[0] = 16'h0800;
        r_frame_len[1] = 16'd64;  r_vlan_tag[1] = 16'h8100; r_rtag[1] = 16'h0000; r_ether_type[1] = 16'h0800;
        r_frame_len[2] = 16'd64;  r_vlan_tag[2] = 16'h8100; r_rtag[2] = 16'h0000; r_ether_type[2] = 16'h0800;
        r_frame_len[3] = 16'd64;  r_vlan_tag[3] = 16'h8100; r_rtag[3] = 16'h0000; r_ether_type[3] = 16'h0800;
        r_frame_len[4] = 16'd64;  r_vlan_tag[4] = 16'h8100; r_rtag[4] = 16'h0000; r_ether_type[4] = 16'h0800;
        r_frame_len[5] = 16'd64;  r_vlan_tag[5] = 16'h8100; r_rtag[5] = 16'h0000; r_ether_type[5] = 16'h0800;
        r_frame_len[6] = 16'd64;  r_vlan_tag[6] = 16'h8100; r_rtag[6] = 16'h0000; r_ether_type[6] = 16'h0800;
        r_frame_len[7] = 16'd64;  r_vlan_tag[7] = 16'h8100; r_rtag[7] = 16'h0000; r_ether_type[7] = 16'h0800;
    end
    
    //==========================================================================
    // 以太网帧生成器实例化
    //==========================================================================
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : gen_frame_generators
            eth_frame_generator #(
                .DATA_WIDTH     (DATA_WIDTH         )
            ) u_eth_frame_gen (
                // 时钟和复位
                .i_clk                      (r_clk                      ),
                .i_rst                      (~r_rst_n                   ),  // 复位信号取反
                
                // 控制信号
                .i_gen_frame                (r_frame_gen_start[i] & r_frame_gen_enable[i]),  // 生成帧使能
                .i_frame_len                (r_frame_len[i]             ),  // 帧长度(不包括前导码)
                .i_add_vlan                 (r_add_vlan[i]              ),  // 是否添加VLAN标签
                .i_add_rtag                 (r_add_rtag[i]              ),  // 是否添加R-TAG
                
                // MAC地址配置
                .i_dst_mac                  (r_dst_mac_table[r_mac_table_index]),  // 目的MAC地址
                .i_src_mac                  (r_src_mac_table[i % 16]    ),  // 源MAC地址
                
                // VLAN配置
                .i_vlan_tag                 (r_vlan_tag[i]              ),  // VLAN标签
                
                // R-TAG配置  
                .i_rtag                     (r_rtag[i]                  ),  // R-TAG字段
                
                // 以太类型
                .i_ether_type               (r_ether_type[i]            ),  // 以太类型字段
                
                // AXI-Stream 输出接口
                .o_axi_data                 (w_gen_axi_data[i]          ),  // 输出数据
                .o_axi_data_valid           (w_gen_axi_valid[i]         ),  // 数据有效
                .i_axi_data_ready           (w_port_axi_ready[i]        ),  // 数据就绪
                .o_axi_data_last            (w_gen_axi_last[i]          ),  // 数据结束
                .o_axi_data_keep            (w_gen_axi_keep[i]          ),  // 数据掩码
                
                // 状态输出
                .o_frame_done               (w_frame_gen_done[i]        ),  // 帧生成完成
                .o_busy                     (w_frame_gen_busy[i]        )   // 忙状态
            );
        end
    endgenerate

    //==========================================================================
    // CRC32计算模块实例化
    // 使用标准IEEE 802.3 CRC32硬件模块，支持8位并行数据输入
    // 多项式: 0x04C11DB7 (x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1)
    //==========================================================================
    CRC32_D8 u_crc32_d8 (
        .i_clk      (r_clk      ),  // 时钟信号
        .i_rst      (r_crc_rst  ),  // 复位信号 (高有效)
        .i_en       (r_crc_en   ),  // 使能信号
        .i_data     (r_crc_data ),  // 8位数据输入
        .o_crc      (w_crc_out  )   // 32位CRC输出
    );

    //==========================================================================
    // 便捷以太网帧生成相关定义和任务  
    //==========================================================================

    
    // 便捷以太网帧生成任务
    task generate_eth_frame(
        input integer port_id
    );
        integer byte_idx;
        integer payload_idx;
        reg [31:0] crc_value;
        
        begin
            byte_idx = 0;
            
            // 0. 添加前导码(如果使能)
            if (r_frame_preamble_enable) begin
                // 前导码：7字节的0x55
                frame_buffer[byte_idx+0] = 8'h55;
                frame_buffer[byte_idx+1] = 8'h55;
                frame_buffer[byte_idx+2] = 8'h55;
                frame_buffer[byte_idx+3] = 8'h55;
                frame_buffer[byte_idx+4] = 8'h55;
                frame_buffer[byte_idx+5] = 8'h55;
                frame_buffer[byte_idx+6] = 8'h55;
                // 帧起始分隔符(SFD)：1字节的0xD5
                frame_buffer[byte_idx+7] = 8'hD5;
                byte_idx = byte_idx + 8;
            end
            
            // 1. 添加目标MAC地址
            frame_buffer[byte_idx+0] = r_frame_dest_mac[47:40];
            frame_buffer[byte_idx+1] = r_frame_dest_mac[39:32];
            frame_buffer[byte_idx+2] = r_frame_dest_mac[31:24];
            frame_buffer[byte_idx+3] = r_frame_dest_mac[23:16];
            frame_buffer[byte_idx+4] = r_frame_dest_mac[15:8];
            frame_buffer[byte_idx+5] = r_frame_dest_mac[7:0];
            byte_idx = byte_idx + 6;
            
            // 2. 添加源MAC地址
            frame_buffer[byte_idx+0] = r_frame_src_mac[47:40];
            frame_buffer[byte_idx+1] = r_frame_src_mac[39:32];
            frame_buffer[byte_idx+2] = r_frame_src_mac[31:24];
            frame_buffer[byte_idx+3] = r_frame_src_mac[23:16];
            frame_buffer[byte_idx+4] = r_frame_src_mac[15:8];
            frame_buffer[byte_idx+5] = r_frame_src_mac[7:0];
            byte_idx = byte_idx + 6;
            
            // 3. 添加VLAN字段（如果使能）
            if (r_frame_vlan_enable) begin
                frame_buffer[byte_idx+0] = r_frame_vlan_tpid[15:8];
                frame_buffer[byte_idx+1] = r_frame_vlan_tpid[7:0];
                frame_buffer[byte_idx+2] = {r_frame_vlan_pcp, r_frame_vlan_dei, r_frame_vlan_vid[11:8]};
                frame_buffer[byte_idx+3] = r_frame_vlan_vid[7:0];
                byte_idx = byte_idx + 4;
            end
            
            // 4. 添加RTAG字段（如果使能）
            if (r_frame_rtag_enable) begin
                frame_buffer[byte_idx+0] = r_frame_rtag_tpid[15:8];
                frame_buffer[byte_idx+1] = r_frame_rtag_tpid[7:0];
                frame_buffer[byte_idx+2] = 8'd0;
                frame_buffer[byte_idx+3] = 8'd0;
                frame_buffer[byte_idx+4] = r_frame_rtag_sequence[15:8];
                frame_buffer[byte_idx+5] = r_frame_rtag_sequence[7:0]; 
                byte_idx = byte_idx + 6;
            end
            
            // 5. 添加以太网类型
            frame_buffer[byte_idx+0] = r_frame_eth_type[15:8];
            frame_buffer[byte_idx+1] = r_frame_eth_type[7:0];
            byte_idx = byte_idx + 2;
            
            // 6. 添加载荷数据
            for (payload_idx = 0; payload_idx < r_frame_payload_len; payload_idx = payload_idx + 1) begin
                case (r_frame_payload_pattern)
                    8'h00: frame_buffer[byte_idx] = payload_idx[7:0];        // 递增模式
                    8'h01: frame_buffer[byte_idx] = 8'h00;                   // 全0模式
                    8'h02: frame_buffer[byte_idx] = 8'hFF;                   // 全1模式
                    8'h03: frame_buffer[byte_idx] = $random & 8'hFF;         // 随机模式
                    default: frame_buffer[byte_idx] = payload_idx[7:0];
                endcase
                byte_idx = byte_idx + 1;
            end
            
            // 7. 添加CRC（如果自动计算）
            if (r_frame_auto_crc) begin
                calculate_crc32_hw(byte_idx-8, crc_value);
            end else begin
                crc_value = r_frame_manual_crc;
            end
            
            frame_buffer[byte_idx+0] = crc_value[31:24];
            frame_buffer[byte_idx+1] = crc_value[23:16];
            frame_buffer[byte_idx+2] = crc_value[15:8];
            frame_buffer[byte_idx+3] = crc_value[7:0];
            byte_idx = byte_idx + 4;
            
            frame_length = byte_idx;
            
            // 发送帧到指定端口
            send_frame_to_port(port_id, frame_length);
            
            $display("Generated Ethernet Frame: Port=%0d, Length=%0d bytes", port_id, frame_length);
            if (r_frame_preamble_enable) $display("  Preamble: Enabled (7x55 + D5)");
            $display("  DMAC=%012h, SMAC=%012h", r_frame_dest_mac, r_frame_src_mac);
            if (r_frame_vlan_enable) $display("  VLAN: TPID=%04h, PCP=%0d, DEI=%0d, VID=%03h", r_frame_vlan_tpid, r_frame_vlan_pcp, r_frame_vlan_dei, r_frame_vlan_vid);
            if (r_frame_rtag_enable) $display("  RTAG: Seq=%04h", r_frame_rtag_sequence);
            $display("  EthType=%04h, PayloadLen=%0d", r_frame_eth_type, r_frame_payload_len);
            if (r_frame_auto_crc) $display("  CRC32: %08h (Hardware calculated)", crc_value);
            else $display("  CRC32: %08h (Manual)", crc_value);
        end
    endtask
    
    // CRC32计算任务 - 使用CRC32_D8硬件模块
    // 替换了原来的简化软件计算函数，使用标准IEEE 802.3 CRC32硬件实现
    task calculate_crc32_hw;
        input integer length;
        output [31:0] crc_result;
        
        integer i;
        
        begin
            // 复位CRC模块
            r_crc_rst = 1'b1;
            r_crc_en = 1'b0;
            @(posedge r_clk);
            r_crc_rst = 1'b0;
 
            
            // 逐字节输入数据进行CRC计算
            for (i = 0; i < length; i = i + 1) begin
                 r_crc_data = frame_buffer[i+8];
               #1 r_crc_en = 1'b1;
                @(posedge r_clk);
            end
            
            // 停止使能，等待最终结果
          #1  r_crc_en = 1'b0;
            @(posedge r_clk);
            
            // 获取CRC结果
            crc_result = w_crc_out;
        end
    endtask
    
    // 发送帧到指定端口的任务
    task send_frame_to_port;
        input integer port_id;
        input integer frame_len;
        
        integer byte_idx;
        integer cycle_count;
        integer i;
        reg [DATA_WIDTH-1:0] data_word;
        reg [KEEP_WIDTH-1:0] keep_word;
        reg last_word;
        
        begin
            byte_idx = 0;
            cycle_count = 0;
            
            while (byte_idx < frame_len) begin
                // 构造8位数据字和1位keep信号
                data_word = 0;
                keep_word = 0;
                last_word = 0;
                
                // 填充1字节数据 - 8位数据位宽
                if (byte_idx < frame_len) begin 
                    data_word = frame_buffer[byte_idx]; 
                    keep_word = 1'b1; 
                end
                
                // 检查是否为最后一个字节
                if (byte_idx + 1 >= frame_len) begin
                    last_word = 1'b1;
                end
                
                // 切换到testbench驱动模式
                r_axi_source_sel[port_id] = 1'b0;
                
                // 发送数据到对应端口
                @(posedge r_clk);
                r_port_axi_data[port_id]  = data_word;
                r_port_axi_keep[port_id]  = keep_word;
                r_port_axi_valid[port_id] = 1'b1;
                r_port_axi_last[port_id]  = last_word;
                
                // 等待ready信号
                wait (w_port_axi_ready[port_id] == 1'b1);
                
                byte_idx = byte_idx + 1;  // 8位数据位宽，每次处理1字节
                cycle_count = cycle_count + 1;
            end
            
            // 清除valid信号
            @(posedge r_clk);
            r_port_axi_valid[port_id] = 1'b0;
            
            // 恢复到帧生成器模式（可选）
            // r_axi_source_sel[port_id] = 1'b1;
        end
    endtask
    
    // 配置帧参数的任务
    task config_frame;
        input [47:0] dest_mac;
        input [47:0] src_mac;
        input        vlan_enable;
        input [2:0]  vlan_pri;     // 新增：VLAN优先级(PCP)
        input [11:0] vlan_id;
        input        rtag_enable;
        input [15:0] rtag_seq;
        input [15:0] eth_type;
        input integer payload_len;
        input [7:0]  payload_pattern;
        input        preamble_enable;
        
        begin
            r_frame_dest_mac = dest_mac;
            r_frame_src_mac = src_mac;
            r_frame_vlan_enable = vlan_enable;
            r_frame_vlan_tpid = VLAN_TPID;
            r_frame_vlan_pcp = vlan_pri;   // 使用传入的VLAN优先级
            r_frame_vlan_dei = 1'b0;
            r_frame_vlan_vid = vlan_id;
            r_frame_rtag_enable = rtag_enable;
            r_frame_rtag_tpid = RTAG_TPID;
            r_frame_rtag_sequence = rtag_seq;
            r_frame_eth_type = eth_type;
            r_frame_payload_len = payload_len;
            r_frame_payload_pattern = payload_pattern;
            r_frame_preamble_enable = preamble_enable;
            r_frame_auto_crc = 1'b1;
            r_frame_manual_crc = 32'h0;
        end
    endtask
    
    // 便捷的帧生成函数集合
    task send_basic_frame;
        input integer port_id;
        input [47:0] dmac;
        input [47:0] smac;
        begin
            config_frame(dmac, smac, 1'b0, 3'b000, 12'h0, 1'b0, 16'h0, ETH_TYPE_IPV4, 46, 8'h0, 1'b1);
            generate_eth_frame(port_id);
        end
    endtask
    
    task send_vlan_frame;
        input integer port_id;
        input [47:0] dmac;
        input [47:0] smac;
        input [2:0]  vlan_pri;  // 新增：VLAN优先级
        input [11:0] vlan_id;
        begin
            config_frame(dmac, smac, 1'b1, vlan_pri, vlan_id, 1'b0, 16'h0, ETH_TYPE_IPV4, 42, 8'h0, 1'b1);
            generate_eth_frame(port_id);
        end
    endtask
    
    task send_rtag_frame;
        input integer port_id;
        input [47:0] dmac;
        input [47:0] smac;
        input [15:0] seq;
        input [7:0] stream_id;
        begin
            config_frame(dmac, smac, 1'b0, 3'b000, 12'h0, 1'b1, seq, ETH_TYPE_IPV4, 38, 8'h0, 1'b1);
            generate_eth_frame(port_id);
        end
    endtask
    
    task send_complex_frame;
        input integer port_id; 
        input [47:0] dmac; 
        input [47:0] smac;
        input        has_vlan;
        input [11:0] vlan_id;
        input        has_rtag;
        input [15:0] rtag_seq;
        input [7:0]  stream_id;
        input [15:0] eth_type;
        input integer payload_len;
        begin
            config_frame(dmac, smac, has_vlan, 3'h2, vlan_id, has_rtag, rtag_seq, eth_type, payload_len, 8'h0, 1'b1);
            generate_eth_frame(port_id);
        end
    endtask

    //==========================================================================
    // 前导码控制任务
    //==========================================================================
    
    // 设置前导码使能
    task set_preamble_enable;
        input enable;
        begin
            r_frame_preamble_enable = enable;
            $display("Preamble %s", enable ? "ENABLED" : "DISABLED");
        end
    endtask
    
    // CRC32硬件模块测试任务
    task test_crc32_hw;
        input integer test_data_len;
        
        reg [31:0] hw_crc_result;
        integer i;
        
        begin
            $display("\n=== CRC32 Hardware Module Test ===");
            $display("Testing with %0d bytes of test data", test_data_len);
            
            // 准备测试数据
            for (i = 0; i < test_data_len; i = i + 1) begin
                frame_buffer[i] = i[7:0];  // 简单的递增测试数据
            end
            
            // 使用硬件CRC模块计算
            calculate_crc32_hw(test_data_len, hw_crc_result);
            
            $display("Hardware CRC32 result: %08h", hw_crc_result);
            $display("Test data pattern: 00 01 02 03 ... %02h", (test_data_len-1));
            $display("=== CRC32 Test Completed ===\n");
        end
    endtask

    //==========================================================================
    // TCAM初始化任务定义
    //==========================================================================
    
    // TCAM表项初始化task
    task tcam_initialize;
        begin
            $display("[%0t] Starting TCAM initialization", $time);
            
            // 写入TCAM表项1: IPv4单播帧 - 匹配quick_send_ipv4格式 (无VLAN)
            // Action Data: [22:15]=8'b00000001(转发到端口0), [14:12]=2'b00(100%流控), [11:4]=8'h64(CB帧stream_handle=100), [3]=1'b1(CB), [2:0]=3'b000(允许通过)
            tcam_write_entry(
                r_src_mac_table[0],//48'h01_02_03_04_05_06,     // 匹配MAC表中的DMAC[0]
                48'h00_11_22_33_44_55,     // 匹配MAC表中的SMAC[1]  
                16'h8100,                  // 无VLAN时填充0000
                3'h0,                      // 无VLAN优先级
                12'h001,                   // 无VLAN ID
                16'h0800,                  // EtherType IPv4
                24'h016408                 // Action Data: 端口bitmap=0x01, 流控=100%, CB帧(stream_handle=100), 允许通过
            );
           repeat (1000) @(posedge r_clk);
            // // 写入TCAM表项2: VLAN帧 - 匹配quick_send_vlan格式
            // // Action Data: [21:14]=8'b00000010(转发到端口1), [13:12]=2'b00(100%流控), [11:4]=8'h00(非CB帧), [3]=1'b0(非CB), [2:0]=3'b000(允许通过)
            // tcam_write_entry(
            //     48'h00_50_56_C0_00_01,     // 匹配MAC表中的DMAC[2]
            //     48'h00_12_34_56_78_9A,     // 匹配MAC表中的SMAC[2]
            //     16'h8100,                  // VLAN EtherType
            //     3'h2,                      // VLAN Priority = 2
            //     12'h100,                   // VLAN ID = 0x100
            //     16'h0800,                  // EtherType IPv4
            //     24'h008000                 // Action Data: 端口bitmap=0x02, 流控=100%, 非CB帧, 允许通过
            // );
            // #500; // 1微秒延时 (1ns时间精度)
            
            // 写入TCAM表项3: 广播帧 - 匹配quick_send_broadcast格式
            // Action Data: [21:14]=8'b11111111(广播到所有端口), [13:12]=2'b00(100%流控), [11:4]=8'h00(非CB帧), [3]=1'b0(非CB), [2:0]=3'b000(允许通过)
            tcam_write_entry(
                48'hFF_FF_FF_FF_FF_FF,     // 广播DMAC
                48'h00_11_22_33_44_55,     // 匹配MAC表中的SMAC[3]
                16'h0000,                  // 无VLAN
                3'h0,                      // 无VLAN优先级
                12'h000,                   // 无VLAN ID
                16'h0800,                  // EtherType IPv4
                24'h3FC008                 // Action Data: 端口bitmap=0xFF, 流控=100%, 非CB帧, 允许通过
            );
        repeat (1000) @(posedge r_clk);
            // 写入TCAM表项4: PTP帧 - 匹配quick_send_ptp格式
            // Action Data: [21:14]=8'b00001111(转发到端口0-3), [13:12]=2'b00(100%流控), [11:4]=8'h00(非CB帧), [3]=1'b0(非CB), [2:0]=3'b000(允许通过)
            tcam_write_entry(
                48'h01_1B_19_00_00_00,     // PTP组播DMAC
                48'h00_11_11_11_11_11,     // 匹配MAC表中的SMAC[4]
                16'h0000,                  // 无VLAN
                3'h0,                      // 无VLAN优先级
                12'h000,                   // 无VLAN ID
                16'h88F7,                  // EtherType PTP
                24'h03C000                 // Action Data: 端口bitmap=0x0F, 流控=100%, 非CB帧, 允许通过
            );
       repeat (1000) @(posedge r_clk);
            // 写入TCAM表项5: LLDP帧 - 匹配quick_send_lldp格式
            // Action Data: [21:14]=8'b11111111(广播到所有端口), [13:12]=2'b00(100%流控), [11:4]=8'h00(非CB帧), [3]=1'b0(非CB), [2:0]=3'b000(允许通过)
            tcam_write_entry(
                48'h01_80_C2_00_00_0E,     // LLDP组播DMAC
                48'h00_22_22_22_22_22,     // 匹配MAC表中的SMAC[5]
                16'h0000,                  // 无VLAN
                3'h0,                      // 无VLAN优先级
                12'h000,                   // 无VLAN ID
                16'h88CC,                  // EtherType LLDP
                24'h3FC000                 // Action Data: 端口bitmap=0xFF, 流控=100%, 非CB帧, 允许通过
            );
 
repeat (1000) @(posedge r_clk);
            // 写入TCAM表项7: 拒绝通过测试 - SMAC=48'h00_11_22_33_44_55
            // Action Data: [21:14]=8'b00000000(无转发), [13:12]=2'b00(100%流控), [11:4]=8'h00, [3]=1'b0(非CB), [2:0]=3'b001(拒绝通过)
            tcam_write_entry(
                48'h02_00_00_00_00_01,     // 测试用DMAC
                48'h00_11_22_33_44_55,     // SMAC - 拒绝通过测试
                16'h0000,                  // 无VLAN
                3'h0,                      // 无VLAN优先级
                12'h000,                   // 无VLAN ID
                16'h0800,                  // EtherType IPv4
                24'h000001                 // Action Data: 无转发, 100%流控, 非CB帧, 拒绝通过
            );
      repeat (1000) @(posedge r_clk);
            // // 写入TCAM表项8: 50%流控测试 - SMAC=48'h00_11_22_33_44_55
            // // Action Data: [21:14]=8'b00000100(转发到端口2), [13:12]=2'b01(50%流控), [11:4]=8'h00, [3]=1'b0(非CB), [2:0]=3'b000(允许通过)
            // tcam_write_entry(
            //     48'h02_00_00_00_00_02,     // 测试用DMAC
            //     48'h00_11_22_33_44_55,     // SMAC - 50%流控测试
            //     16'h0000,                  // 无VLAN
            //     3'h0,                      // 无VLAN优先级
            //     12'h000,                   // 无VLAN ID
            //     16'h0800,                  // EtherType IPv4
            //     24'h011000                 // Action Data: 端口bitmap=0x04, 50%流控, 非CB帧, 允许通过
            // );
            // #500;
 
            $display("[%0t] TCAM initialization completed - 10 entries added", $time);
        end
    endtask
    
    // TCAM单个表项写入task
    task tcam_write_entry;
        input [47:0] dmac;
        input [47:0] smac;
        input [15:0] vlan_ether_type;
        input [2:0]  vlan_priority;
        input [11:0] vlan_id;
        input [15:0] ether_type;
        input [23:0] action_data; // 兼容旧格式传入: [21:14]=端口bitmap, [13:12]=流控(2bit), [11:4]=stream_handle, [3]=CB, [2:0]=操作
        
        reg [143:0] raw_data_144bit;
        reg [143:0] dont_care_mask_144bit;
        reg [23:0]  action_data_new; // 新格式: [22:15]=端口bitmap, [14:12]=流控(扩展为3bit), [11:4]=stream_handle, [3]=CB, [2:0]=操作
        
        begin
            // 构造144bit原始数据: DMAC(48bit) + SMAC(48bit) + VLAN_TAG(32bit) + EtherType(16bit)
            raw_data_144bit = {dmac, smac, vlan_ether_type, vlan_priority, 1'b0, vlan_id, ether_type};
            
            // 设置don't care掩码 (0表示精确匹配，1表示don't care)
            dont_care_mask_144bit = {48'h000000000000,48'h000000000000,48'hffffffffffff}; // 全部精确匹配
            
            // 将旧格式action_data映射到新位域定义
            // 旧: [21:14]=端口, [13:12]=流控(2bit), [11:4]=stream, [3]=CB, [2:0]=操作
            // 新: [22:15]=端口, [14:12]=流控(3bit, 高位新增/保留0), 其他相同
            // action_data_new = 24'b0;
            // action_data_new[2:0]   = action_data[2:0];       // 操作
            // action_data_new[3]     = action_data[3];         // CB标志
            // action_data_new[11:4]  = action_data[11:4];      // stream_handle
            // action_data_new[14:12] = {1'b0, action_data[13:12]}; // 流控扩展为3bit，MSB填0
            // action_data_new[22:15] = action_data[21:14];     // 端口bitmap整体左移1bit到[22:15]
            // action_data_new[23]    = 1'b0;                   // 保留
            action_data_new = action_data ;
            
            $display("[%0t] Writing TCAM entry:", $time);
            $display("  DMAC: %012h", dmac);
            $display("  SMAC: %012h", smac);
            $display("  VLAN: %04h %01h %03h", vlan_ether_type, vlan_priority, vlan_id);
            $display("  EtherType: %04h", ether_type);
            $display("  Action Data (old->new mapped): %06h -> %06h", action_data, action_data_new);
            $display("    新[22:15] 转发端口bitmap: %08b", action_data_new[22:15]);
            $display("    新[14:12] 流控处理(3bit): %03b", action_data_new[14:12]);
            $display("    新[11:4]  stream_handle: %02h", action_data_new[11:4]);
            $display("    新[3]     CB协议帧标志: %01b", action_data_new[3]);
            $display("    新[2:0]   操作类型: %03b", action_data_new[2:0]);
            $display("  Raw Data (144bit): %036h", raw_data_144bit);
            
            // 配置TCAM写表工具
            tb_i_cmd_type       = 3'b000;                // 写表命令
            tb_i_raw_data       = raw_data_144bit;       // 原始数据
            tb_i_dont_care_mask = dont_care_mask_144bit; // don't care掩码
            tb_i_action_data    = action_data_new;       // Action数据(按新位域)
            
            // 启动写表操作
            tb_i_write_start = 1'b1;
            @(posedge r_clk);
            tb_i_write_start = 1'b0;
            
            // 等待写表完成
            wait(tcam_o_write_done);
            @(posedge r_clk);
            
            $display("  TCAM entry write completed\n");
        end
    endtask

    //==========================================================================
    // 测试用例任务定义
    //==========================================================================
    
    // 测试用例1: 单端口数据发送
    task test_case_1_single_port;
        integer port_id;
        begin
            $display("\n--- Test Case 1: Single Port Test ---");
            r_test_case = 8'h01;
            
            // 逐个端口测试
            for (port_id = 0; port_id < PORT_NUM; port_id = port_id + 1) begin
                $display("Testing Port %0d", port_id);
                
                r_frame_gen_enable = 8'h00;
                r_frame_gen_enable[port_id] = 1'b1;
                #(CLK_PERIOD * 10);
                
                // 发送3帧数据
                repeat(3) begin
                    r_frame_gen_start[port_id] = 1'b1;
                    #(CLK_PERIOD);
                    r_frame_gen_start[port_id] = 1'b0;
                    
                    // 等待帧发送完成
                    wait(w_frame_gen_done[port_id] == 1'b1);
                    #(CLK_PERIOD * 10);
                    
                    // 更新MAC地址索引
                    r_mac_table_index = (r_mac_table_index + 1) % 16;
                end
                
                r_frame_gen_enable[port_id] = 1'b0;
                #(CLK_PERIOD * 20);
            end
        end
    endtask
    
    // 测试用例2: 多端口同时发送
    task test_case_2_multi_port;
        begin
            $display("\n--- Test Case 2: Multi-Port Simultaneous Test ---");
            r_test_case = 8'h02;
            
            // 使能所有端口
            r_frame_gen_enable = 8'hFF;
            #(CLK_PERIOD * 10);
            
            // 同时启动所有端口发送
            repeat(5) begin
                $display("Multi-port transmission round %0d", $time/CLK_PERIOD);
                
                r_frame_gen_start = 8'hFF;
                #(CLK_PERIOD);
                r_frame_gen_start = 8'h00;
                
                // 等待所有端口完成
                wait(&w_frame_gen_done == 1'b1);
                #(CLK_PERIOD * 20);
                
                // 更新MAC地址
                r_mac_table_index = (r_mac_table_index + 1) % 16;
            end
            
            r_frame_gen_enable = 8'h00;
        end
    endtask
    
    // 测试用例3: MAC地址重复测试
    task test_case_3_mac_repeat;
        integer i;
        begin
            $display("\n--- Test Case 3: MAC Address Repeat Test ---");
            r_test_case = 8'h03;
            
            // 专门测试MAC地址重复场景
            r_frame_gen_enable = 8'hFF;
            #(CLK_PERIOD * 10);
            
            // 发送重复MAC地址的帧
            for (i = 0; i < 8; i = i + 1) begin
                r_mac_table_index = 4'h8 + (i % 4);  // 使用重复MAC的索引
                
                r_frame_gen_start = 8'hFF;
                #(CLK_PERIOD);
                r_frame_gen_start = 8'h00;
                
                wait(&w_frame_gen_done == 1'b1);
                #(CLK_PERIOD * 15);
            end
            
            r_frame_gen_enable = 8'h00;
        end
    endtask
    
    // 测试用例4: 随机压力测试
    task test_case_4_random_stress;
        integer rand_delay;
        integer rand_ports;
        integer test_round;
        begin
            $display("\n--- Test Case 4: Random Stress Test ---");
            r_test_case = 8'h04;
            
            for (test_round = 0; test_round < 20; test_round = test_round + 1) begin
                // 随机选择端口
                rand_ports = $random % 256;
                r_frame_gen_enable = rand_ports[7:0];
                
                // 随机延时
                rand_delay = ($random % 50) + 10;
                #(CLK_PERIOD * rand_delay);
                
                if (|r_frame_gen_enable) begin
                    r_frame_gen_start = r_frame_gen_enable;
                    #(CLK_PERIOD);
                    r_frame_gen_start = 8'h00;
                    
                    // 等待完成
                    wait((w_frame_gen_done & r_frame_gen_enable) == r_frame_gen_enable);
                    
                    // 随机更新MAC地址
                    r_mac_table_index = $random % 16;
                end
                
                #(CLK_PERIOD * 10);
            end
            
            r_frame_gen_enable = 8'h00;
        end
    endtask
    
    //==========================================================================
    // 统计和监控
    //==========================================================================
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : gen_monitors
            always @(posedge r_clk or negedge r_rst_n) begin
                if (!r_rst_n) begin
                    r_frame_count[i] <= 32'h0;
                    r_byte_count[i]  <= 32'h0;
                    r_error_count[i] <= 32'h0;
                end else begin
                    // 统计发送的帧数
                    if (w_frame_gen_done[i]) begin
                        r_frame_count[i] <= r_frame_count[i] + 1;
                    end
                    
                    // 统计字节数
                    if (w_port_axi_valid[i] && w_port_axi_ready[i]) begin
                        case (w_port_axi_keep[i])
                            8'b11111111: r_byte_count[i] <= r_byte_count[i] + 8;
                            8'b01111111: r_byte_count[i] <= r_byte_count[i] + 7;
                            8'b00111111: r_byte_count[i] <= r_byte_count[i] + 6;
                            8'b00011111: r_byte_count[i] <= r_byte_count[i] + 5;
                            8'b00001111: r_byte_count[i] <= r_byte_count[i] + 4;
                            8'b00000111: r_byte_count[i] <= r_byte_count[i] + 3;
                            8'b00000011: r_byte_count[i] <= r_byte_count[i] + 2;
                            8'b00000001: r_byte_count[i] <= r_byte_count[i] + 1;
                            default:     r_byte_count[i] <= r_byte_count[i];
                        endcase
                    end
                end
            end
        end
    endgenerate
    
    //==========================================================================
    // 测试结果显示
    //==========================================================================
    integer idx;
    always @(posedge r_clk) begin
        if (r_test_case != 8'h00 && ($time % (CLK_PERIOD * 1000) == 0)) begin
            $display("\n--- Statistics at time %0t ---", $time);
            for (idx = 0; idx < PORT_NUM; idx = idx + 1) begin
                $display("Port[%0d]: Frames=%0d, Bytes=%0d, Errors=%0d", 
                        idx, r_frame_count[idx], r_byte_count[idx], r_error_count[idx]);
            end
        end
    end

    // 端口信号定义 - 使用规范命名（reg以r_开头，wire以w_开头）
    // MAC0 端口信号
    reg                                 r_mac0_port_link                    ;
    reg  [1:0]                          r_mac0_port_speed                   ;
    reg                                 r_mac0_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac0_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac0_axi_data_keep                ;
    reg                                 r_mac0_axi_data_valid               ;
    wire                                w_mac0_axi_data_ready               ;
    reg                                 r_mac0_axi_data_last                ;
    
    // MAC1 端口信号  
    reg                                 r_mac1_port_link                    ;
    reg  [1:0]                          r_mac1_port_speed                   ;
    reg                                 r_mac1_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac1_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac1_axi_data_keep                ;
    reg                                 r_mac1_axi_data_valid               ;
    wire                                w_mac1_axi_data_ready               ;
    reg                                 r_mac1_axi_data_last                ;
    
    // MAC2 端口信号
    reg                                 r_mac2_port_link                    ;
    reg  [1:0]                          r_mac2_port_speed                   ;
    reg                                 r_mac2_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac2_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac2_axi_data_keep                ;
    reg                                 r_mac2_axi_data_valid               ;
    wire                                w_mac2_axi_data_ready               ;
    reg                                 r_mac2_axi_data_last                ;
    
    // MAC3 端口信号
    reg                                 r_mac3_port_link                    ;
    reg  [1:0]                          r_mac3_port_speed                   ;
    reg                                 r_mac3_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac3_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac3_axi_data_keep                ;
    reg                                 r_mac3_axi_data_valid               ;
    wire                                w_mac3_axi_data_ready               ;
    reg                                 r_mac3_axi_data_last                ;
    
    // MAC4 端口信号
    reg                                 r_mac4_port_link                    ;
    reg  [1:0]                          r_mac4_port_speed                   ;
    reg                                 r_mac4_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac4_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac4_axi_data_keep                ;
    reg                                 r_mac4_axi_data_valid               ;
    wire                                w_mac4_axi_data_ready               ;
    reg                                 r_mac4_axi_data_last                ;
    
    // MAC5 端口信号
    reg                                 r_mac5_port_link                    ;
    reg  [1:0]                          r_mac5_port_speed                   ;
    reg                                 r_mac5_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac5_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac5_axi_data_keep                ;
    reg                                 r_mac5_axi_data_valid               ;
    wire                                w_mac5_axi_data_ready               ;
    reg                                 r_mac5_axi_data_last                ;
    
    // MAC6 端口信号
    reg                                 r_mac6_port_link                    ;
    reg  [1:0]                          r_mac6_port_speed                   ;
    reg                                 r_mac6_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac6_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac6_axi_data_keep                ;
    reg                                 r_mac6_axi_data_valid               ;
    wire                                w_mac6_axi_data_ready               ;
    reg                                 r_mac6_axi_data_last                ;
    
    // MAC7 端口信号
    reg                                 r_mac7_port_link                    ;
    reg  [1:0]                          r_mac7_port_speed                   ;
    reg                                 r_mac7_port_filter_preamble_v       ;
    reg  [PORT_MNG_DATA_WIDTH-1:0]      r_mac7_axi_data                     ;
    reg  [KEEP_WIDTH-1:0]               r_mac7_axi_data_keep                ;
    reg                                 r_mac7_axi_data_valid               ;
    wire                                w_mac7_axi_data_ready               ;
    reg                                 r_mac7_axi_data_last                ;

    reg                                 r_rst                               ;

    //==========================================================================
    // DUT模块例化 - rx_mac_mng
    //==========================================================================
    rx_mac_mng #(
        .PORT_NUM                (PORT_NUM),              // 交换机的端口数
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH),   // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH),   // 接收 MAC 层的配置寄存器数据位宽
    .METADATA_WIDTH          (METADATA_WIDTH),       // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH),  // Mac_port_mng 数据位宽 
    .HASH_DATA_WIDTH         (HASH_DATA_WIDTH),      // 哈希计算的值的位宽
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH)      // 聚合总线输出 
) u_rx_mac_mng (
    /*---------------------------------------- CPU_MAC数据流 -------------------------------------------*/
`ifdef CPU_MAC
 
    .i_cpu_mac0_port_link                (w_mac_port_link[0]             ), // 端口的连接状态
    .i_cpu_mac0_port_speed               (w_mac_port_speed[1:0]          ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_cpu_mac0_port_filter_preamble_v   (w_mac_port_filter_preamble_v[0]), // 端口是否过滤前导码信息
    .i_cpu_mac0_axi_data                 (w_mac_axi_data[0]              ), // 端口数据流
    .i_cpu_mac0_axi_data_keep            (w_mac_axi_data_keep[0]         ), // 端口数据流掩码，有效字节指示
    .i_cpu_mac0_axi_data_valid           (w_mac_axi_data_valid[0]        ), // 端口数据有效
    .o_cpu_mac0_axi_data_ready           (w_mac_axi_data_ready[0]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_cpu_mac0_axi_data_last            (w_mac_axi_data_last[0]         ), // 数据流结束标识
 
    .o_cpu_mac0_time_irq                 (), // 打时间戳中断信号
    .o_cpu_mac0_frame_seq                (), // 帧序列号
    .o_timestamp0_addr                   (), // 打时间戳存储的 RAM 地址
    
    .o_vlan_id_cpu                       (w_vlan_id_cpu                  ),
    .o_dmac_cpu_hash_key                 (w_dmac_cpu_hash_key            ), // 目的 mac 的哈希值
    .o_dmac_cpu                          (w_dmac_cpu                     ), // 目的 mac 的值
    .o_dmac_cpu_vld                      (w_dmac_cpu_vld                 ), // dmac_vld
    .o_smac_cpu_hash_key                 (w_smac_cpu_hash_key            ), // 源 mac 的值有效标识
    .o_smac_cpu                          (w_smac_cpu                     ), // 源 mac 的值
    .o_smac_cpu_vld                      (w_smac_cpu_vld                 ), // smac_vld
 
    .i_tx_cpu_port                       (w_tx_cpu_port                  ), // 交换表模块返回的查表端口信息
    .i_tx_cpu_port_vld                   (w_tx_cpu_port_vld              ),
    .i_tx_cpu_port_broadcast             (w_tx_cpu_port_broadcast        ),
    .o_mac0_rtag_flag                    (w_rtag_flag0                   ),
    .o_mac0_rtag_squence                 (w_rtag_sequence0               ),
    .o_mac0_stream_handle                (w_stream_handle0               ),
   .i_mac0_pass_en                      (1),//(w_cb_pass_en[0]        ),
   .i_mac0_discard_en                   (0),//(w_cb_discard_en[0]     ),
   .i_mac0_judge_finish                 (1),//(w_cb_judge_finish[0]   ),
 
    // .o_mac0_rtag_sequence                (), // MAC0 R-TAG序列号
    // .o_mac0_rtag_valid                   (), // MAC0 R-TAG有效
 
    .o_mac0_cross_port_link              (), // 端口的连接状态
    .o_mac0_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac0_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac0_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac0_cross_axi_data_valid         (), // 端口数据有效
    .i_mac0_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac0_cross_axi_data_last          (), // 数据流结束标识
 
    .o_mac0_cross_metadata               (w_mac0_cross_metadata      ), // 总线 metadata 数据
    .o_mac0_cross_metadata_valid         (w_mac0_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac0_cross_metadata_last          (w_mac0_cross_metadata_last ), // 信息流结束标识
    .i_mac0_cross_metadata_ready         (1'd1), // 下游模块反压流水线 
 
    .o_tx0_req                           ( w_tx0_req         ),
 
    .i_mac0_tx0_ack                      ( w_mac0_tx0_ack    ), // 响应使能信号
    .i_mac0_tx0_ack_rst                  ( w_mac0_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac0_tx1_ack                      ( w_mac0_tx1_ack    ), // 响应使能信号
    .i_mac0_tx1_ack_rst                  ( w_mac0_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac0_tx2_ack                      ( w_mac0_tx2_ack    ), // 响应使能信号
    .i_mac0_tx2_ack_rst                  ( w_mac0_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac0_tx3_ack                      ( w_mac0_tx3_ack    ), // 响应使能信号
    .i_mac0_tx3_ack_rst                  ( w_mac0_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac0_tx4_ack                      ( w_mac0_tx4_ack    ), // 响应使能信号
    .i_mac0_tx4_ack_rst                  ( w_mac0_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac0_tx5_ack                      ( w_mac0_tx5_ack    ), // 响应使能信号
    .i_mac0_tx5_ack_rst                  ( w_mac0_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac0_tx6_ack                      ( w_mac0_tx6_ack    ), // 响应使能信号
    .i_mac0_tx6_ack_rst                  ( w_mac0_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac0_tx7_ack                      ( w_mac0_tx7_ack    ), // 响应使能信号
    .i_mac0_tx7_ack_rst                  ( w_mac0_tx7_ack_rst), // 端口的优先级向量结果
`endif
`ifdef MAC1
    // 数据流信息 
    .i_mac1_port_link                    (w_mac_port_link[1]             ), // 端口的连接状态
    .i_mac1_port_speed                   (w_mac_port_speed[3:2]            ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac1_port_filter_preamble_v       (w_mac_port_filter_preamble_v[1]), // 端口是否过滤前导码信息
    .i_mac1_axi_data                     (w_mac_axi_data[1]              ), // 端口数据流
    .i_mac1_axi_data_keep                (w_mac_axi_data_keep[1]         ), // 端口数据流掩码，有效字节指示
    .i_mac1_axi_data_valid               (w_mac_axi_data_valid[1]        ), // 端口数据有效
    .o_mac1_axi_data_ready               (w_mac_axi_data_ready[1]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac1_axi_data_last                (w_mac_axi_data_last[1]         ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac1_time_irq                     (), // 打时间戳中断信号
    .o_mac1_frame_seq                    (), // 帧序列号
    .o_timestamp1_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id1                          (),
    .o_dmac1_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac1                             (), // 目的 mac 的值
    .o_dmac1_vld                         (), // dmac_vld
    .o_smac1_hash_key                    (), // 源 mac 的值有效标识
    .o_smac1                             (), // 源 mac 的值
    .o_smac1_vld                         (), // smac_vld

    .i_tx_1_port                         (w_tx_1_port               ), // 交换表模块返回的查表端口信息
    .i_tx_1_port_vld                     (w_tx_1_port_vld           ),
    .i_tx_1_port_broadcast               (w_tx_1_port_broadcast     ),
    .o_mac1_rtag_flag                    (w_rtag_flag1                   ),
    .o_mac1_rtag_squence                 (w_rtag_sequence1               ),
    .o_mac1_stream_handle                (w_stream_handle1               ),
    .i_mac1_pass_en                      (w_cb_pass_en[1]        ),
    .i_mac1_discard_en                   (w_cb_discard_en[1]     ),
    .i_mac1_judge_finish                 (w_cb_judge_finish[1]   ),
    // .o_mac1_rtag_sequence                (), // MAC1 R-TAG序列号
    // .o_mac1_rtag_valid                   (), // MAC1 R-TAG有效
    // MAC1 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac1_cross_port_link              (), // 端口的连接状态
    .o_mac1_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac1_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac1_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac1_cross_axi_data_valid         (), // 端口数据有效
    .i_mac1_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac1_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac1_cross_metadata               (w_mac1_cross_metadata      ), // 总线 metadata 数据
    .o_mac1_cross_metadata_valid         (w_mac1_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac1_cross_metadata_last          (w_mac1_cross_metadata_last ), // 信息流结束标识
    .i_mac1_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx1_req                           ( w_tx1_req         ),
 
    .i_mac1_tx0_ack                      ( w_mac1_tx0_ack    ), // 响应使能信号
    .i_mac1_tx0_ack_rst                  ( w_mac1_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac1_tx1_ack                      ( w_mac1_tx1_ack    ), // 响应使能信号
    .i_mac1_tx1_ack_rst                  ( w_mac1_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac1_tx2_ack                      ( w_mac1_tx2_ack    ), // 响应使能信号
    .i_mac1_tx2_ack_rst                  ( w_mac1_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac1_tx3_ack                      ( w_mac1_tx3_ack    ), // 响应使能信号
    .i_mac1_tx3_ack_rst                  ( w_mac1_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac1_tx4_ack                      ( w_mac1_tx4_ack    ), // 响应使能信号
    .i_mac1_tx4_ack_rst                  ( w_mac1_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac1_tx5_ack                      ( w_mac1_tx5_ack    ), // 响应使能信号
    .i_mac1_tx5_ack_rst                  ( w_mac1_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac1_tx6_ack                      ( w_mac1_tx6_ack    ), // 响应使能信号
    .i_mac1_tx6_ack_rst                  ( w_mac1_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac1_tx7_ack                      ( w_mac1_tx7_ack    ), // 响应使能信号
    .i_mac1_tx7_ack_rst                  ( w_mac1_tx7_ack_rst), // 端口的优先级向量结果
`endif
    /*---------------------------------------- MAC2 数据流 -------------------------------------------*/
`ifdef MAC2
    // 数据流信息 
    .i_mac2_port_link                    (w_mac_port_link[2]             ),
    .i_mac2_port_speed                   (w_mac_port_speed[5:4]            ),
    .i_mac2_port_filter_preamble_v       (w_mac_port_filter_preamble_v[2]),
    .i_mac2_axi_data                     (w_mac_axi_data[2]              ),
    .i_mac2_axi_data_keep                (w_mac_axi_data_keep[2]         ),
    .i_mac2_axi_data_valid               (w_mac_axi_data_valid[2]        ),
    .o_mac2_axi_data_ready               (w_mac_axi_data_ready[2]        ),
    .i_mac2_axi_data_last                (w_mac_axi_data_last[2]         ),
    // 报文时间打时间戳 
    .o_mac2_time_irq                     (), // 打时间戳中断信号
    .o_mac2_frame_seq                    (), // 帧序列号
    .o_timestamp2_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id2                          (),
    .o_dmac2_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac2                             (), // 目的 mac 的值
    .o_dmac2_vld                         (), // dmac_vld
    .o_smac2_hash_key                    (), // 源 mac 的值有效标识
    .o_smac2                             (), // 源 mac 的值
    .o_smac2_vld                         (), // smac_vld

    .i_tx_2_port                         (w_tx_2_port    ), // 交换表模块返回的查表端口信息
    .i_tx_2_port_vld                     (w_tx_2_port_vld),
    .i_tx_2_port_broadcast               (w_tx_2_port_broadcast     ),
    .o_mac2_rtag_flag                    (w_rtag_flag2                  ),
    .o_mac2_rtag_squence                 (w_rtag_sequence2               ),
    .o_mac2_stream_handle                (w_stream_handle2               ),
    .i_mac2_pass_en                      (w_cb_pass_en[2]        ),
    .i_mac2_discard_en                   (w_cb_discard_en[2]     ),
    .i_mac2_judge_finish                 (w_cb_judge_finish[2]   ),

    // .o_mac2_rtag_sequence                (), // MAC2 R-TAG序列号
    // .o_mac2_rtag_valid                   (), // MAC2 R-TAG有效
    // MAC2 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac2_cross_port_link              (), // 端口的连接状态
    .o_mac2_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac2_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac2_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac2_cross_axi_data_valid         (), // 端口数据有效
    .i_mac2_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac2_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac2_cross_metadata               (w_mac2_cross_metadata      ), // 总线 metadata 数据
    .o_mac2_cross_metadata_valid         (w_mac2_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac2_cross_metadata_last          (w_mac2_cross_metadata_last ), // 信息流结束标识
    .i_mac2_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx2_req                           ( w_tx2_req         ),

    .i_mac2_tx0_ack                      ( w_mac2_tx0_ack    ), // 响应使能信号
    .i_mac2_tx0_ack_rst                  ( w_mac2_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac2_tx1_ack                      ( w_mac2_tx1_ack    ), // 响应使能信号
    .i_mac2_tx1_ack_rst                  ( w_mac2_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac2_tx2_ack                      ( w_mac2_tx2_ack    ), // 响应使能信号
    .i_mac2_tx2_ack_rst                  ( w_mac2_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac2_tx3_ack                      ( w_mac2_tx3_ack    ), // 响应使能信号
    .i_mac2_tx3_ack_rst                  ( w_mac2_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac2_tx4_ack                      ( w_mac2_tx4_ack    ), // 响应使能信号
    .i_mac2_tx4_ack_rst                  ( w_mac2_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac2_tx5_ack                      ( w_mac2_tx5_ack    ), // 响应使能信号
    .i_mac2_tx5_ack_rst                  ( w_mac2_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac2_tx6_ack                      ( w_mac2_tx6_ack    ), // 响应使能信号
    .i_mac2_tx6_ack_rst                  ( w_mac2_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac2_tx7_ack                      ( w_mac2_tx7_ack    ), // 响应使能信号
    .i_mac2_tx7_ack_rst                  ( w_mac2_tx7_ack_rst), // 端口的优先级向量结果
`endif
    /*---------------------------------------- MAC3 数据流 -------------------------------------------*/
`ifdef MAC3
    // 数据流信息 
    .i_mac3_port_link                    (w_mac_port_link[3]             ), // 端口的连接状态
    .i_mac3_port_speed                   (w_mac_port_speed[7:6]            ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac3_port_filter_preamble_v       (w_mac_port_filter_preamble_v[3]), // 端口是否过滤前导码信息
    .i_mac3_axi_data                     (w_mac_axi_data[3]              ), // 端口数据流
    .i_mac3_axi_data_keep                (w_mac_axi_data_keep[3]         ), // 端口数据流掩码，有效字节指示
    .i_mac3_axi_data_valid               (w_mac_axi_data_valid[3]        ), // 端口数据有效
    .o_mac3_axi_data_ready               (w_mac_axi_data_ready[3]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac3_axi_data_last                (w_mac_axi_data_last[3]         ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac3_time_irq                     (), // 打时间戳中断信号
    .o_mac3_frame_seq                    (), // 帧序列号
    .o_timestamp3_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id3                          (),
    .o_dmac3_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac3                             (), // 目的 mac 的值
    .o_dmac3_vld                         (), // dmac_vld
    .o_smac3_hash_key                    (), // 源 mac 的值有效标识
    .o_smac3                             (), // 源 mac 的值
    .o_smac3_vld                         (), // smac_vld

    .i_tx_3_port                         (w_tx_3_port    ), // 交换表模块返回的查表端口信息
    .i_tx_3_port_vld                     (w_tx_3_port_vld),
    .i_tx_3_port_broadcast               (w_tx_3_port_broadcast     ),
    .o_mac3_rtag_flag                    (w_rtag_flag3                   ),
    .o_mac3_rtag_squence                 (w_rtag_sequence3               ),
    .o_mac3_stream_handle                (w_stream_handle3               ),
    .i_mac3_pass_en                      (w_cb_pass_en[3]        ),
    .i_mac3_discard_en                   (w_cb_discard_en[3]     ),
    .i_mac3_judge_finish                 (w_cb_judge_finish[3]   ),

    // .o_mac3_rtag_sequence                (), // MAC3 R-TAG序列号
    // .o_mac3_rtag_valid                   (), // MAC3 R-TAG有效
    // MAC3 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac3_cross_port_link              (), // 端口的连接状态
    .o_mac3_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac3_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac3_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac3_cross_axi_data_valid         (), // 端口数据有效
    .i_mac3_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac3_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac3_cross_metadata               (w_mac3_cross_metadata      ), // 总线 metadata 数据
    .o_mac3_cross_metadata_valid         (w_mac3_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac3_cross_metadata_last          (w_mac3_cross_metadata_last ), // 信息流结束标识
    .i_mac3_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx3_req                           ( w_tx3_req         ),

    .i_mac3_tx0_ack                      ( w_mac3_tx0_ack    ), // 响应使能信号
    .i_mac3_tx0_ack_rst                  ( w_mac3_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac3_tx1_ack                      ( w_mac3_tx1_ack    ), // 响应使能信号
    .i_mac3_tx1_ack_rst                  ( w_mac3_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac3_tx2_ack                      ( w_mac3_tx2_ack    ), // 响应使能信号
    .i_mac3_tx2_ack_rst                  ( w_mac3_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac3_tx3_ack                      ( w_mac3_tx3_ack    ), // 响应使能信号
    .i_mac3_tx3_ack_rst                  ( w_mac3_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac3_tx4_ack                      ( w_mac3_tx4_ack    ), // 响应使能信号
    .i_mac3_tx4_ack_rst                  ( w_mac3_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac3_tx5_ack                      ( w_mac3_tx5_ack    ), // 响应使能信号
    .i_mac3_tx5_ack_rst                  ( w_mac3_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac3_tx6_ack                      ( w_mac3_tx6_ack    ), // 响应使能信号
    .i_mac3_tx6_ack_rst                  ( w_mac3_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac3_tx7_ack                      ( w_mac3_tx7_ack    ), // 响应使能信号
    .i_mac3_tx7_ack_rst                  ( w_mac3_tx7_ack_rst), // 端口的优先级向量结果
`endif
    /*---------------------------------------- MAC4 数据流 -------------------------------------------*/
`ifdef MAC4
    // 数据流信息 
    .i_mac4_port_link                    (w_mac_port_link[4]             ), // 端口的连接状态
    .i_mac4_port_speed                   (w_mac_port_speed[9:8]            ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac4_port_filter_preamble_v       (w_mac_port_filter_preamble_v[4]), // 端口是否过滤前导码信息
    .i_mac4_axi_data                     (w_mac_axi_data[4]              ), // 端口数据流
    .i_mac4_axi_data_keep                (w_mac_axi_data_keep[4]         ), // 端口数据流掩码，有效字节指示
    .i_mac4_axi_data_valid               (w_mac_axi_data_valid[4]        ), // 端口数据有效
    .o_mac4_axi_data_ready               (w_mac_axi_data_ready[4]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac4_axi_data_last                (w_mac_axi_data_last[4]         ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac4_time_irq                     (), // 打时间戳中断信号
    .o_mac4_frame_seq                    (), // 帧序列号
    .o_timestamp4_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id4                          (),
    .o_dmac4_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac4                             (), // 目的 mac 的值
    .o_dmac4_vld                         (), // dmac_vld
    .o_smac4_hash_key                    (), // 源 mac 的值有效标识
    .o_smac4                             (), // 源 mac 的值
    .o_smac4_vld                         (), // smac_vld

    .i_tx_4_port                         (w_tx_4_port    ), // 交换表模块返回的查表端口信息
    .i_tx_4_port_vld                     (w_tx_4_port_vld),
    .i_tx_4_port_broadcast               (w_tx_4_port_broadcast     ),
    .o_mac4_rtag_flag                    (w_rtag_flag4                   ),
    .o_mac4_rtag_squence                 (w_rtag_sequence4               ),
    .o_mac4_stream_handle                (w_stream_handle4               ),
    .i_mac4_pass_en                      (w_cb_pass_en[4]        ),
    .i_mac4_discard_en                   (w_cb_discard_en[4]     ),
    .i_mac4_judge_finish                 (w_cb_judge_finish[4]   ),

    // .o_mac4_rtag_sequence                (), // MAC4 R-TAG序列号
    // .o_mac4_rtag_valid                   (), // MAC4 R-TAG有效
    // MAC4 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac4_cross_port_link              (), // 端口的连接状态
    .o_mac4_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac4_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac4_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac4_cross_axi_data_valid         (), // 端口数据有效
    .i_mac4_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac4_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac4_cross_metadata               (w_mac4_cross_metadata      ), // 总线 metadata 数据
    .o_mac4_cross_metadata_valid         (w_mac4_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac4_cross_metadata_last          (w_mac4_cross_metadata_last ), // 信息流结束标识
    .i_mac4_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx4_req                           ( w_tx4_req         ),

    .i_mac4_tx0_ack                      ( w_mac4_tx0_ack    ), // 响应使能信号
    .i_mac4_tx0_ack_rst                  ( w_mac4_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac4_tx1_ack                      ( w_mac4_tx1_ack    ), // 响应使能信号
    .i_mac4_tx1_ack_rst                  ( w_mac4_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac4_tx2_ack                      ( w_mac4_tx2_ack    ), // 响应使能信号
    .i_mac4_tx2_ack_rst                  ( w_mac4_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac4_tx3_ack                      ( w_mac4_tx3_ack    ), // 响应使能信号
    .i_mac4_tx3_ack_rst                  ( w_mac4_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac4_tx4_ack                      ( w_mac4_tx4_ack    ), // 响应使能信号
    .i_mac4_tx4_ack_rst                  ( w_mac4_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac4_tx5_ack                      ( w_mac4_tx5_ack    ), // 响应使能信号
    .i_mac4_tx5_ack_rst                  ( w_mac4_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac4_tx6_ack                      ( w_mac4_tx6_ack    ), // 响应使能信号
    .i_mac4_tx6_ack_rst                  ( w_mac4_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac4_tx7_ack                      ( w_mac4_tx7_ack    ), // 响应使能信号
    .i_mac4_tx7_ack_rst                  ( w_mac4_tx7_ack_rst), // 端口的优先级向量结果
`endif
    /*---------------------------------------- MAC5 数据流 -------------------------------------------*/
`ifdef MAC5
    // 数据流信息 
    .i_mac5_port_link                    (w_mac_port_link[5]             ), // 端口的连接状态
    .i_mac5_port_speed                   (w_mac_port_speed[11:10]            ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac5_port_filter_preamble_v       (w_mac_port_filter_preamble_v[5]), // 端口是否过滤前导码信息
    .i_mac5_axi_data                     (w_mac_axi_data[5]              ), // 端口数据流
    .i_mac5_axi_data_keep                (w_mac_axi_data_keep[5]         ), // 端口数据流掩码，有效字节指示
    .i_mac5_axi_data_valid               (w_mac_axi_data_valid[5]        ), // 端口数据有效
    .o_mac5_axi_data_ready               (w_mac_axi_data_ready[5]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac5_axi_data_last                (w_mac_axi_data_last[5]         ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac5_time_irq                     (), // 打时间戳中断信号
    .o_mac5_frame_seq                    (), // 帧序列号
    .o_timestamp5_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id5                          (),
    .o_dmac5_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac5                             (), // 目的 mac 的值
    .o_dmac5_vld                         (), // dmac_vld
    .o_smac5_hash_key                    (), // 源 mac 的值有效标识
    .o_smac5                             (), // 源 mac 的值
    .o_smac5_vld                         (), // smac_vld

    .i_tx_5_port                         (w_tx_5_port    ), // 交换表模块返回的查表端口信息
    .i_tx_5_port_vld                     (w_tx_5_port_vld),
    .i_tx_5_port_broadcast               (w_tx_5_port_broadcast     ),
    .o_mac5_rtag_flag                    (w_rtag_flag5                   ),
    .o_mac5_rtag_squence                 (w_rtag_sequence5               ),
    .o_mac5_stream_handle                (w_stream_handle5               ),
    .i_mac5_pass_en                      (w_cb_pass_en[5]        ),
    .i_mac5_discard_en                   (w_cb_discard_en[5]     ),
    .i_mac5_judge_finish                 (w_cb_judge_finish[5]   ),
    
    // .o_mac5_rtag_sequence                (), // MAC5 R-TAG序列号
    // .o_mac5_rtag_valid                   (), // MAC5 R-TAG有效
    // MAC5 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac5_cross_port_link              (), // 端口的连接状态
    .o_mac5_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac5_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac5_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac5_cross_axi_data_valid         (), // 端口数据有效
    .i_mac5_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac5_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac5_cross_metadata               (w_mac5_cross_metadata      ), // 总线 metadata 数据
    .o_mac5_cross_metadata_valid         (w_mac5_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac5_cross_metadata_last          (w_mac5_cross_metadata_last ), // 信息流结束标识
    .i_mac5_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx5_req                           ( w_tx5_req         ),

    .i_mac5_tx0_ack                      ( w_mac5_tx0_ack    ), // 响应使能信号
    .i_mac5_tx0_ack_rst                  ( w_mac5_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac5_tx1_ack                      ( w_mac5_tx1_ack    ), // 响应使能信号
    .i_mac5_tx1_ack_rst                  ( w_mac5_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac5_tx2_ack                      ( w_mac5_tx2_ack    ), // 响应使能信号
    .i_mac5_tx2_ack_rst                  ( w_mac5_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac5_tx3_ack                      ( w_mac5_tx3_ack    ), // 响应使能信号
    .i_mac5_tx3_ack_rst                  ( w_mac5_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac5_tx4_ack                      ( w_mac5_tx4_ack    ), // 响应使能信号
    .i_mac5_tx4_ack_rst                  ( w_mac5_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac5_tx5_ack                      ( w_mac5_tx5_ack    ), // 响应使能信号
    .i_mac5_tx5_ack_rst                  ( w_mac5_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac5_tx6_ack                      ( w_mac5_tx6_ack    ), // 响应使能信号
    .i_mac5_tx6_ack_rst                  ( w_mac5_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac5_tx7_ack                      ( w_mac5_tx7_ack    ), // 响应使能信号
    .i_mac5_tx7_ack_rst                  ( w_mac5_tx7_ack_rst), // 端口的优先级向量结果
`endif
    /*---------------------------------------- MAC6 数据流 -------------------------------------------*/
`ifdef MAC6
    // 数据流信息 
    .i_mac6_port_link                    (w_mac_port_link[6]             ), // 端口的连接状态
    .i_mac6_port_speed                   (w_mac_port_speed[13:12]            ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac6_port_filter_preamble_v       (w_mac_port_filter_preamble_v[6]), // 端口是否过滤前导码信息
    .i_mac6_axi_data                     (w_mac_axi_data[6]              ), // 端口数据流
    .i_mac6_axi_data_keep                (w_mac_axi_data_keep[6]         ), // 端口数据流掩码，有效字节指示
    .i_mac6_axi_data_valid               (w_mac_axi_data_valid[6]        ), // 端口数据有效
    .o_mac6_axi_data_ready               (w_mac_axi_data_ready[6]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac6_axi_data_last                (w_mac_axi_data_last[6]         ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac6_time_irq                     (), // 打时间戳中断信号
    .o_mac6_frame_seq                    (), // 帧序列号
    .o_timestamp6_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id6                          (),
    .o_dmac6_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac6                             (), // 目的 mac 的值
    .o_dmac6_vld                         (), // dmac_vld
    .o_smac6_hash_key                    (), // 源 mac 的值有效标识
    .o_smac6                             (), // 源 mac 的值
    .o_smac6_vld                         (), // smac_vld

    .i_tx_6_port                         (w_tx_6_port    ), // 交换表模块返回的查表端口信息
    .i_tx_6_port_vld                     (w_tx_6_port_vld),
    .i_tx_6_port_broadcast               (w_tx_6_port_broadcast     ),
    .o_mac6_rtag_flag                    (w_rtag_flag6                   ),
    .o_mac6_rtag_squence                 (w_rtag_sequence6               ),
    .o_mac6_stream_handle                (w_stream_handle6               ),
    .i_mac6_pass_en                      (w_cb_pass_en[6]        ),
    .i_mac6_discard_en                   (w_cb_discard_en[6]     ),
    .i_mac6_judge_finish                 (w_cb_judge_finish[6]   ),

    // .o_mac6_rtag_sequence                (), // MAC6 R-TAG序列号
    // .o_mac6_rtag_valid                   (), // MAC6 R-TAG有效
    // MAC6 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac6_cross_port_link              (), // 端口的连接状态
    .o_mac6_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac6_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac6_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac6_cross_axi_data_valid         (), // 端口数据有效
    .i_mac6_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac6_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac6_cross_metadata               (w_mac6_cross_metadata      ), // 总线 metadata 数据
    .o_mac6_cross_metadata_valid         (w_mac6_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac6_cross_metadata_last          (w_mac6_cross_metadata_last ), // 信息流结束标识
    .i_mac6_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx6_req                           ( w_tx6_req         ),

    .i_mac6_tx0_ack                      ( w_mac6_tx0_ack    ), // 响应使能信号
    .i_mac6_tx0_ack_rst                  ( w_mac6_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac6_tx1_ack                      ( w_mac6_tx1_ack    ), // 响应使能信号
    .i_mac6_tx1_ack_rst                  ( w_mac6_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac6_tx2_ack                      ( w_mac6_tx2_ack    ), // 响应使能信号
    .i_mac6_tx2_ack_rst                  ( w_mac6_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac6_tx3_ack                      ( w_mac6_tx3_ack    ), // 响应使能信号
    .i_mac6_tx3_ack_rst                  ( w_mac6_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac6_tx4_ack                      ( w_mac6_tx4_ack    ), // 响应使能信号
    .i_mac6_tx4_ack_rst                  ( w_mac6_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac6_tx5_ack                      ( w_mac6_tx5_ack    ), // 响应使能信号
    .i_mac6_tx5_ack_rst                  ( w_mac6_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac6_tx6_ack                      ( w_mac6_tx6_ack    ), // 响应使能信号
    .i_mac6_tx6_ack_rst                  ( w_mac6_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac6_tx7_ack                      ( w_mac6_tx7_ack    ), // 响应使能信号
    .i_mac6_tx7_ack_rst                  ( w_mac6_tx7_ack_rst), // 端口的优先级向量结果
`endif
    /*---------------------------------------- MAC7 数据流 -------------------------------------------*/
`ifdef MAC7
    // 数据流信息 
    .i_mac7_port_link                    (w_mac_port_link[7]             ), // 端口的连接状态
    .i_mac7_port_speed                   (w_mac_port_speed[15:14]            ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_mac7_port_filter_preamble_v       (w_mac_port_filter_preamble_v[7]), // 端口是否过滤前导码信息
    .i_mac7_axi_data                     (w_mac_axi_data[7]              ), // 端口数据流
    .i_mac7_axi_data_keep                (w_mac_axi_data_keep[7]         ), // 端口数据流掩码，有效字节指示
    .i_mac7_axi_data_valid               (w_mac_axi_data_valid[7]        ), // 端口数据有效
    .o_mac7_axi_data_ready               (w_mac_axi_data_ready[7]        ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_mac7_axi_data_last                (w_mac_axi_data_last[7]         ), // 数据流结束标识
    // 报文时间打时间戳 
    .o_mac7_time_irq                     (), // 打时间戳中断信号
    .o_mac7_frame_seq                    (), // 帧序列号
    .o_timestamp7_addr                   (), // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
    .o_vlan_id7                          (),
    .o_dmac7_hash_key                    (), // 目的 mac 的哈希值
    .o_dmac7                             (), // 目的 mac 的值
    .o_dmac7_vld                         (), // dmac_vld
    .o_smac7_hash_key                    (), // 源 mac 的值有效标识
    .o_smac7                             (), // 源 mac 的值
    .o_smac7_vld                         (), // smac_vld

    .i_tx_7_port                         (w_tx_7_port    ), // 交换表模块返回的查表端口信息
    .i_tx_7_port_vld                     (w_tx_7_port_vld),
    .i_tx_7_port_broadcast               (w_tx_7_port_broadcast     ),
    .o_mac7_rtag_flag                    (w_rtag_flag7                   ),
    .o_mac7_rtag_squence                 (w_rtag_sequence7               ),
    .o_mac7_stream_handle                (w_stream_handle7               ),
    .i_mac7_pass_en                      (w_cb_pass_en[7]        ),
    .i_mac7_discard_en                   (w_cb_discard_en[7]     ),
    .i_mac7_judge_finish                 (w_cb_judge_finish[7]   ),

    // .o_mac7_rtag_sequence                (), // MAC7 R-TAG序列号
    // .o_mac7_rtag_valid                   (), // MAC7 R-TAG有效
    // MAC7 输出数据流
    /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
    .o_mac7_cross_port_link              (), // 端口的连接状态
    .o_mac7_cross_port_speed             (), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    .o_mac7_cross_port_axi_data          (), // 端口数据流，最高位表示crcerr
    .o_mac7_cross_axi_data_keep          (), // 端口数据流掩码，有效字节指示
    .o_mac7_cross_axi_data_valid         (), // 端口数据有效
    .i_mac7_cross_axi_data_ready         (1'd1), // 交叉总线聚合架构反压流水线信号
    .o_mac7_cross_axi_data_last          (), // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    .o_mac7_cross_metadata               (w_mac7_cross_metadata      ), // 总线 metadata 数据
    .o_mac7_cross_metadata_valid         (w_mac7_cross_metadata_valid), // 总线 metadata 数据有效信号
    .o_mac7_cross_metadata_last          (w_mac7_cross_metadata_last ), // 信息流结束标识
    .i_mac7_cross_metadata_ready         (1'd1), // 下游模块反压流水线 

    .o_tx7_req                           ( w_tx7_req         ),

    .i_mac7_tx0_ack                      ( w_mac7_tx0_ack    ), // 响应使能信号
    .i_mac7_tx0_ack_rst                  ( w_mac7_tx0_ack_rst), // 端口的优先级向量结果
    .i_mac7_tx1_ack                      ( w_mac7_tx1_ack    ), // 响应使能信号
    .i_mac7_tx1_ack_rst                  ( w_mac7_tx1_ack_rst), // 端口的优先级向量结果  
    .i_mac7_tx2_ack                      ( w_mac7_tx2_ack    ), // 响应使能信号
    .i_mac7_tx2_ack_rst                  ( w_mac7_tx2_ack_rst), // 端口的优先级向量结果
    .i_mac7_tx3_ack                      ( w_mac7_tx3_ack    ), // 响应使能信号
    .i_mac7_tx3_ack_rst                  ( w_mac7_tx3_ack_rst), // 端口的优先级向量结果
    .i_mac7_tx4_ack                      ( w_mac7_tx4_ack    ), // 响应使能信号
    .i_mac7_tx4_ack_rst                  ( w_mac7_tx4_ack_rst), // 端口的优先级向量结果
    .i_mac7_tx5_ack                      ( w_mac7_tx5_ack    ), // 响应使能信号
    .i_mac7_tx5_ack_rst                  ( w_mac7_tx5_ack_rst), // 端口的优先级向量结果
    .i_mac7_tx6_ack                      ( w_mac7_tx6_ack    ), // 响应使能信号
    .i_mac7_tx6_ack_rst                  ( w_mac7_tx6_ack_rst), // 端口的优先级向量结果
    .i_mac7_tx7_ack                      ( w_mac7_tx7_ack    ), // 响应使能信号
    .i_mac7_tx7_ack_rst                  ( w_mac7_tx7_ack_rst), // 端口的优先级向量结果
`endif
    .i_clk                               (r_clk                                  ),   // 250MHz
    .i_rst                               (~r_rst_n                               ), 
       
    .i_switch_reg_bus_we                 (tcam_o_reg_bus_we                      ),
    .i_switch_reg_bus_we_addr            (tcam_o_reg_bus_we_addr                 ),
    .i_switch_reg_bus_we_din             (tcam_o_reg_bus_we_din                  ),
    .i_switch_reg_bus_we_din_v           (tcam_o_reg_bus_we_din_v                ),
    .i_switch_reg_bus_rd                 (1'd0              ),
    .i_switch_reg_bus_rd_addr            (8'd0              ),
    .o_switch_reg_bus_we_dout            (o_switch_reg_bus_we_dout               ),
    .o_switch_reg_bus_we_dout_v          (o_switch_reg_bus_we_dout_v             ) 
    /*
        metadata 数据组成
            [93:79] : CB协议 R-TAG字段
            [78:64] : CB协议 R-TAG字段
            [63](1bit) : port_speed 
            [62:60](3bit) : vlan_pri 
            [59:52](8bit) : tx_prot
            [51:44](8bit) : acl_frmtype
            [43:28](16bit): acl_fetchinfo
            [27](1bit) : frm_vlan_flag
            [26:19](8bit) : 输入端口，bitmap表示
            [18:15](4bit) : Qos策略
            [14:13](2bit) : 冗余复制与消除(cb)，01表示复制，10表示消除，00表示非CB业务帧
            [12](1bit) : 丢弃位
            [11](1bit) : 是否为关键帧(Qbu)
            [10:4](7bit) ：time_stamp_addr，报文时间戳的地址信息
    */
);




// Instantiate swlist module
swlist #(
    .PORT_NUM                (PORT_NUM),
    .REG_ADDR_BUS_WIDTH      (REG_ADDR_BUS_WIDTH),
    .REG_DATA_BUS_WIDTH      (REG_DATA_BUS_WIDTH),
    .METADATA_WIDTH          (METADATA_WIDTH),
    .PORT_MNG_DATA_WIDTH     (PORT_MNG_DATA_WIDTH),
    .HASH_DATA_WIDTH         (HASH_DATA_WIDTH),
    .ADDR_WIDTH              (6),  // Default from swlist
    .VLAN_ID_WIDTH           (12), // Default from swlist
    .MAC_ADDR_WIDTH          (48), // Default from swlist
    .STATIC_RAM_SIZE         (256), // Default from swlist
    .AGE_SCAN_INTERVAL       (5),  // Default from swlist
    .SIM_MODE                (1),  // Default from swlist
    .CROSS_DATA_WIDTH        (CROSS_DATA_WIDTH)
) u_swlist (
    .i_clk                               (r_clk),
    .i_rst                               (~r_rst_n),  // Assuming r_rst is active high; adjust if needed
`ifdef CPU_MAC
    .i_vlan_id_cpu                       (w_vlan_id_cpu                  ),  // Not connected in rx_mac_mng, set to 0
    .i_dmac_cpu_hash_key                 (w_dmac_cpu_hash_key            ),
    .i_dmac_cpu                          (w_dmac_cpu                     ),
    .i_dmac_cpu_vld                      (w_dmac_cpu_vld                 ),
    .i_smac_cpu_hash_key                 (w_smac_cpu_hash_key            ),
    .i_smac_cpu                          (w_smac_cpu                     ),
    .i_smac_cpu_vld                      (w_smac_cpu_vld                 ),
    .o_tx_cpu_port                       (w_tx_cpu_port                  ),
    .o_tx_cpu_port_vld                   (w_tx_cpu_port_vld              ),
    .o_tx_cpu_port_broadcast             (w_tx_cpu_port_broadcast        ),
`endif
`ifdef MAC1
    .i_vlan_id1                          (w_vlan_id1                     ),  // Not connected, set to 0
    .i_dmac1_hash_key                    (w_dmac1_hash_key               ),
    .i_dmac1                             (w_dmac1                        ),
    .i_dmac1_vld                         (w_dmac1_vld                    ),
    .i_smac1_hash_key                    (w_smac1_hash_key               ),
    .i_smac1                             (w_smac1                        ),
    .i_smac1_vld                         (w_smac1_vld                    ),
    .o_tx_1_port                         (w_tx_1_port                    ),
    .o_tx_1_port_vld                     (w_tx_1_port_vld                ),
    .o_tx_1_port_broadcast               (w_tx_1_port_broadcast          ),
`endif
`ifdef MAC2
    .i_vlan_id2                          (w_vlan_id2                     ),
    .i_dmac2_hash_key                    (w_dmac2_hash_key               ),
    .i_dmac2                             (w_dmac2                        ),
    .i_dmac2_vld                         (w_dmac2_vld                    ),
    .i_smac2_hash_key                    (w_smac2_hash_key               ),
    .i_smac2                             (w_smac2                        ),
    .i_smac2_vld                         (w_smac2_vld                    ),
    .o_tx_2_port                         (w_tx_2_port                    ),
    .o_tx_2_port_vld                     (w_tx_2_port_vld                ),
    .o_tx_2_port_broadcast               (w_tx_2_port_broadcast          ),
`endif
`ifdef MAC3
    .i_vlan_id3                          (w_vlan_id3                     ),
    .i_dmac3_hash_key                    (w_dmac3_hash_key               ),
    .i_dmac3                             (w_dmac3                        ),
    .i_dmac3_vld                         (w_dmac3_vld                    ),
    .i_smac3_hash_key                    (w_smac3_hash_key               ),
    .i_smac3                             (w_smac3                        ),
    .i_smac3_vld                         (w_smac3_vld                    ),
    .o_tx_3_port                         (w_tx_3_port                    ),
    .o_tx_3_port_vld                     (w_tx_3_port_vld                ),
    .o_tx_3_port_broadcast               (w_tx_3_port_broadcast          ),
`endif
`ifdef MAC4
    .i_vlan_id4                          (w_vlan_id4                     ),
    .i_dmac4_hash_key                    (w_dmac4_hash_key               ),
    .i_dmac4                             (w_dmac4                        ),
    .i_dmac4_vld                         (w_dmac4_vld                    ),
    .i_smac4_hash_key                    (w_smac4_hash_key               ),
    .i_smac4                             (w_smac4                        ),
    .i_smac4_vld                         (w_smac4_vld                    ),
    .o_tx_4_port                         (w_tx_4_port                    ),
    .o_tx_4_port_vld                     (w_tx_4_port_vld                ),
    .o_tx_4_port_broadcast               (w_tx_4_port_broadcast          ),
`endif
`ifdef MAC5
    .i_vlan_id5                          (w_vlan_id5                     ),
    .i_dmac5_hash_key                    (w_dmac5_hash_key               ),
    .i_dmac5                             (w_dmac5                        ),
    .i_dmac5_vld                         (w_dmac5_vld                    ),
    .i_smac5_hash_key                    (w_smac5_hash_key               ),
    .i_smac5                             (w_smac5                        ),
    .i_smac5_vld                         (w_smac5_vld                    ),
    .o_tx_5_port                         (w_tx_5_port                    ),
    .o_tx_5_port_vld                     (w_tx_5_port_vld                ),
    .o_tx_5_port_broadcast               (w_tx_5_port_broadcast          ),
`endif
`ifdef MAC6
    .i_vlan_id6                          (w_vlan_id6                     ),
    .i_dmac6_hash_key                    (w_dmac6_hash_key               ),
    .i_dmac6                             (w_dmac6                        ),
    .i_dmac6_vld                         (w_dmac6_vld                    ),
    .i_smac6_hash_key                    (w_smac6_hash_key               ),
    .i_smac6                             (w_smac6                        ),
    .i_smac6_vld                         (w_smac6_vld                    ),
    .o_tx_6_port                         (w_tx_6_port                    ),
    .o_tx_6_port_vld                     (w_tx_6_port_vld                ),
    .o_tx_6_port_broadcast               (w_tx_6_port_broadcast          ),
`endif
`ifdef MAC7
    .i_vlan_id7                          (w_vlan_id7                     ),
    .i_dmac7_hash_key                    (w_dmac7_hash_key               ),
    .i_dmac7                             (w_dmac7                        ),
    .i_dmac7_vld                         (w_dmac7_vld                    ),
    .i_smac7_hash_key                    (w_smac7_hash_key               ),
    .i_smac7                             (w_smac7                        ),
    .i_smac7_vld                         (w_smac7_vld                    ),
    .o_tx_7_port                         (w_tx_7_port                    ),
    .o_tx_7_port_vld                     (w_tx_7_port_vld                ),
    .o_tx_7_port_broadcast               (w_tx_7_port_broadcast          ),
`endif
    // Register interface ports (not connected in testbench, left open)
    .i_refresh_list_pulse                (),
    .i_switch_err_cnt_clr                (),
    .i_switch_err_cnt_stat               (),
    .i_switch_reg_bus_we                 (),
    .i_switch_reg_bus_we_addr            (),
    .i_switch_reg_bus_we_din             (),
    .i_switch_reg_bus_we_din_v           (),
    .i_switch_reg_bus_rd                 (),
    .i_switch_reg_bus_rd_addr            (),
    .o_switch_reg_bus_we_dout            (),
    .o_switch_reg_bus_we_dout_v          ()
);



//--------------------------------------------------------------------------
// 便捷任务：快速生成IPv4帧并发送
//--------------------------------------------------------------------------
task quick_send_ipv4;
    input integer port_id;
    input [47:0] dest_mac;
    input [47:0] src_mac;
    input integer payload_len;
    begin
        // 使用现有的config_frame任务生成帧
    config_frame(dest_mac, src_mac, 1'b0, 3'b000, 12'h0, 1'b0, 16'h0, ETH_TYPE_IPV4, payload_len, 8'h00, 1'b1);
        // 使用现有的send_frame_to_port任务发送
        send_frame_to_port(port_id, frame_length);
        $display("[QUICK_SEND] IPv4 frame sent: Port=%0d, DMAC=%012h, SMAC=%012h, Len=%0d", 
                 port_id, dest_mac, src_mac, frame_length);
    end
endtask

//--------------------------------------------------------------------------
// 便捷任务：快速生成VLAN帧并发送
//--------------------------------------------------------------------------
task quick_send_vlan;
    input integer port_id;
    input [47:0] dest_mac;
    input [47:0] src_mac;
    input [11:0] vlan_id;
    input integer payload_len;
    begin
        // 使用现有的config_frame任务生成VLAN帧
    config_frame(dest_mac, src_mac, 1'b1, 3'h2, vlan_id, 1'b0, 16'h0, ETH_TYPE_IPV4, payload_len, 8'h00, 1'b1);
        // 使用现有的send_frame_to_port任务发送
        send_frame_to_port(port_id, frame_length);
        $display("[QUICK_SEND] VLAN frame sent: Port=%0d, DMAC=%012h, SMAC=%012h, VID=%03h, Len=%0d", 
                 port_id, dest_mac, src_mac, vlan_id, frame_length);
    end
endtask

//--------------------------------------------------------------------------
// 便捷任务：快速生成广播帧并发送
//--------------------------------------------------------------------------
task quick_send_broadcast;
    input integer port_id;
    input [47:0] src_mac;
    input integer payload_len;
    begin
        // 发送到广播MAC地址
    config_frame(48'hFF_FF_FF_FF_FF_FF, src_mac, 1'b0, 3'b000, 12'h0, 1'b0, 16'h0, ETH_TYPE_IPV4, payload_len, 8'h00, 1'b1);
        send_frame_to_port(port_id, frame_length);
        $display("[QUICK_SEND] Broadcast frame sent: Port=%0d, SMAC=%012h, Len=%0d", 
                 port_id, src_mac, frame_length);
    end
endtask

//--------------------------------------------------------------------------
// 便捷任务：快速生成PTP帧并发送
//--------------------------------------------------------------------------
task quick_send_ptp;
    input integer port_id;
    input [47:0] src_mac;
    input integer payload_len;
    begin
        // 发送到PTP组播地址
    config_frame(48'h01_1B_19_00_00_00, src_mac, 1'b0, 3'b000, 12'h0, 1'b0, 16'h0, ETH_TYPE_PTP, payload_len, 8'h00, 1'b1);
        send_frame_to_port(port_id, frame_length);
        $display("[QUICK_SEND] PTP frame sent: Port=%0d, SMAC=%012h, Len=%0d", 
                 port_id, src_mac, frame_length);
    end
endtask

//--------------------------------------------------------------------------
// 便捷任务：快速生成LLDP帧并发送
//--------------------------------------------------------------------------
task quick_send_lldp;
    input integer port_id;
    input [47:0] src_mac;
    input integer payload_len;
    begin
        // 发送到LLDP组播地址
    config_frame(48'h01_80_C2_00_00_0E, src_mac, 1'b0, 3'b000, 12'h0, 1'b0, 16'h0, ETH_TYPE_LLDP, payload_len, 8'h00, 1'b1);
        send_frame_to_port(port_id, frame_length);
        $display("[QUICK_SEND] LLDP frame sent: Port=%0d, SMAC=%012h, Len=%0d", 
                 port_id, src_mac, frame_length);
    end
endtask

//--------------------------------------------------------------------------
// 便捷任务：批量发送测试帧
//--------------------------------------------------------------------------
task send_test_sequence;
    input integer start_port;
    input integer frame_count;
    integer i, port_id;
    reg [47:0] test_dmac, test_smac;
    begin
        $display("[TEST_SEQ] Starting test sequence: start_port=%0d, count=%0d", start_port, frame_count);
        
        for (i = 0; i < frame_count; i = i + 1) begin
            port_id = (start_port + i) % PORT_NUM; // 循环使用端口
            test_dmac = {16'h0102, 32'h03040500 + i}; // 变化的目标MAC
            test_smac = r_src_mac_table[port_id];      // 使用预定义的源MAC
            
            // 发送不同长度的帧进行测试
            case (i % 4)
                0: quick_send_ipv4(port_id, test_dmac, test_smac, 46);  // 最小载荷
                1: quick_send_ipv4(port_id, test_dmac, test_smac, 100); // 小帧
                2: quick_send_ipv4(port_id, test_dmac, test_smac, 500); // 中等帧
                3: quick_send_ipv4(port_id, test_dmac, test_smac, 1200);// 大帧
            endcase
        end
        
        $display("[TEST_SEQ] Test sequence completed");
    end
endtask

//==========================================================================
// TCAM表初始化任务：配置所有测试场景的ACL规则
//==========================================================================
task tcam_table_init;
    begin
        $display("\n");
        $display("================================================================================");
        $display("=== TCAM Table Initialization Started                                       ===");
        $display("================================================================================");
        
        //======================================================================
        // pMAC场景1: DMAC匹配单个输出端口
        //======================================================================
        $display("[TCAM Init] pMAC Scenario 1: DMAC=AA:BB:CC:DD:EE:01 -> TX Port 3");
        tcam_write_entry(
            48'hAA_BB_CC_DD_EE_01,     // DMAC (与测试报文匹配)
            48'h00_E0_4C_00_00_00,    // SMAC基址 (don't care，但与测试报文对应)
            16'h8100,                 // VLAN EtherType
            3'b001,                   // VLAN Priority (与测试报文匹配)
            12'h001,                  // VLAN ID (与测试报文匹配)
            16'h0800,                 // EtherType
            {1'b0,
             8'b0000_1000,            // [22:15] 端口bitmap: 端口3 (bit3=1)
             3'b000,                  // [14:12] 流控处理: 无流控
             8'h00,                   // [11:4]  stream_handle: 0
             1'b0,                    // [3]     CB协议帧标志: 否
             3'b000}                  // [2:0]   操作类型: 转发
        );
        repeat(1000) @(posedge r_clk);
        
        //======================================================================
        // pMAC场景2: DMAC匹配多个输出端口
        //======================================================================
        $display("[TCAM Init] pMAC Scenario 2: DMAC=AA:BB:CC:DD:EE:02 -> TX Ports 1,3,5");
        tcam_write_entry(
            48'hAA_BB_CC_DD_EE_02,     // DMAC (与测试报文匹配)
            48'h00_E0_4C_00_01_00,    // SMAC基址 (don't care，但与测试报文对应)
            16'h8100,                 // VLAN EtherType
            3'b001,                   // VLAN Priority (与测试报文匹配)
            12'h002,                  // VLAN ID (与测试报文匹配)
            16'h0800,                 // EtherType
            {1'b0,
             8'b0010_1010,            // [22:15] 端口bitmap: 端口1,3,5 (bits 1,3,5=1)
             3'b000,                  // [14:12] 流控处理: 无流控
             8'h00,                   // [11:4]  stream_handle: 0
             1'b0,                    // [3]     CB协议帧标志: 否
             3'b000}                  // [2:0]   操作类型: 转发
        );
        repeat(1000) @(posedge r_clk);
        
        //======================================================================
        // pMAC场景3: DMAC匹配相同输出端口 (用于不同/相同优先级测试)
        //======================================================================
        $display("[TCAM Init] pMAC Scenario 3: DMAC=AA:BB:CC:DD:EE:03 -> TX Port 2");
        tcam_write_entry(
            48'hAA_BB_CC_DD_EE_03,     // DMAC (与测试报文匹配)
            48'h00_E0_4C_00_02_00,    // SMAC基址 (don't care，但与场景3.1测试报文对应)
            16'h8100,                 // VLAN EtherType
            3'b000,                   // VLAN Priority (don't care，场景3.1用不同优先级，场景3.2用固定优先级3)
            12'h003,                  // VLAN ID (与测试报文匹配)
            16'h0800,                 // EtherType
            {1'b0,
             8'b0000_0100,            // [22:15] 端口bitmap: 端口2 (bit2=1)
             3'b000,                  // [14:12] 流控处理: 无流控
             8'h00,                   // [11:4]  stream_handle: 0
             1'b0,                    // [3]     CB协议帧标志: 否
             3'b000}                  // [2:0]   操作类型: 转发
        );
        repeat(1000) @(posedge r_clk);
        
        //======================================================================
        // pMAC场景4&5: 为每个端口配置不同的DMAC和TX端口
        //======================================================================
        $display("[TCAM Init] pMAC Scenario 4&5: Port-specific DMAC -> Port-specific TX");
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            tcam_write_entry(
                48'hAA_BB_CC_DD_EE_10 + r_test_loop_i,  // DMAC (与测试报文匹配)
                48'h00_E0_4C_00_04_00 | r_test_loop_i, // SMAC (don't care，但与场景4测试报文对应)
                16'h8100,                               // VLAN EtherType
                3'b100,                                 // VLAN Priority (场景4用固定优先级4，场景5用不同优先级)
                12'h004,                                // VLAN ID (场景4用004，场景5用005)
                16'h0800,                               // EtherType
                {1'b0,
                 (8'b1 << r_test_loop_i),  // [22:15] 端口bitmap: 对应端口
                 3'b000,                   // [14:12] 流控处理: 无流控
                 8'h00,                    // [11:4]  stream_handle: 0
                 1'b0,                     // [3]     CB协议帧标志: 否
                 3'b000}                   // [2:0]   操作类型: 转发
            );
            $display("  Port %0d: DMAC=AA:BB:CC:DD:EE:%02h -> TX Port %0d", 
                     r_test_loop_i, 8'h10 + r_test_loop_i, r_test_loop_i);
            repeat(1000) @(posedge r_clk);
        end
        
        //======================================================================
        // eMAC场景1: DMAC匹配单个输出端口
        //======================================================================
        $display("[TCAM Init] eMAC Scenario 1: DMAC=BB:CC:DD:EE:FF:01 -> TX Port 5");
        tcam_write_entry(
            48'hBB_CC_DD_EE_FF_01,     // DMAC (与测试报文匹配)
            48'h00_E0_4C_01_00_00,    // SMAC基址 (don't care，但与测试报文对应)
            16'h8100,                 // VLAN EtherType
            3'b111,                   // VLAN Priority (与测试报文匹配)
            12'h101,                  // VLAN ID (与测试报文匹配)
            16'h0800,                 // EtherType
            {1'b0,
             8'b0010_0000,            // [22:15] 端口bitmap: 端口5 (bit5=1)
             3'b000,                  // [14:12] 流控处理: 无流控
             8'h00,                   // [11:4]  stream_handle: 0
             1'b0,                    // [3]     CB协议帧标志: 否
             3'b000}                  // [2:0]   操作类型: 转发
        );
        repeat(1000) @(posedge r_clk);
        
        //======================================================================
        // eMAC场景2: DMAC匹配多个输出端口
        //======================================================================
        $display("[TCAM Init] eMAC Scenario 2: DMAC=BB:CC:DD:EE:FF:02 -> TX Ports 0,2,4,6");
        tcam_write_entry(
            48'hBB_CC_DD_EE_FF_02,     // DMAC (与测试报文匹配)
            48'h00_E0_4C_01_01_00,    // SMAC基址 (don't care，但与测试报文对应)
            16'h8100,                 // VLAN EtherType
            3'b111,                   // VLAN Priority (与测试报文匹配)
            12'h102,                  // VLAN ID (与测试报文匹配)
            16'h0800,                 // EtherType
            {1'b0,
             8'b0101_0101,            // [22:15] 端口bitmap: 端口0,2,4,6 (bits 0,2,4,6=1)
             3'b000,                  // [14:12] 流控处理: 无流控
             8'h00,                   // [11:4]  stream_handle: 0
             1'b0,                    // [3]     CB协议帧标志: 否
             3'b000}                  // [2:0]   操作类型: 转发
        );
        repeat(1000) @(posedge r_clk);
        
        //======================================================================
        // eMAC场景3: DMAC匹配相同输出端口 (用于不同/相同优先级测试)
        //======================================================================
        $display("[TCAM Init] eMAC Scenario 3: DMAC=BB:CC:DD:EE:FF:03 -> TX Port 7");
        tcam_write_entry(
            48'hBB_CC_DD_EE_FF_03,     // DMAC (与测试报文匹配)
            48'h00_E0_4C_01_02_00,    // SMAC基址 (don't care，但与场景3.1测试报文对应)
            16'h8100,                 // VLAN EtherType
            3'b000,                   // VLAN Priority (don't care，场景3.1用不同优先级，场景3.2用固定优先级6)
            12'h103,                  // VLAN ID (与测试报文匹配)
            16'h0800,                 // EtherType
            {1'b0,
             8'b1000_0000,            // [22:15] 端口bitmap: 端口7 (bit7=1)
             3'b000,                  // [14:12] 流控处理: 无流控
             8'h00,                   // [11:4]  stream_handle: 0
             1'b0,                    // [3]     CB协议帧标志: 否
             3'b000}                  // [2:0]   操作类型: 转发
        );
        repeat(1000) @(posedge r_clk);
        
        //======================================================================
        // eMAC场景4&5: 为每个端口配置不同的DMAC和TX端口
        //======================================================================
        $display("[TCAM Init] eMAC Scenario 4&5: Port-specific DMAC -> Port-specific TX");
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            tcam_write_entry(
                48'hBB_CC_DD_EE_FF_10 + r_test_loop_j,  // DMAC (与测试报文匹配)
                48'h00_E0_4C_01_04_00 | r_test_loop_j, // SMAC (don't care，但与场景4测试报文对应)
                16'h8100,                               // VLAN EtherType
                3'b111,                                 // VLAN Priority (场景4用固定优先级7，场景5用不同优先级)
                12'h104,                                // VLAN ID (场景4用104，场景5用105)
                16'h0800,                               // EtherType
                {1'b0,
                 (8'b1 << r_test_loop_j),  // [22:15] 端口bitmap: 对应端口
                 3'b000,                // [14:12] 流控处理: 无流控
                 8'h00,                 // [11:4]  stream_handle: 0
                 1'b0,                  // [3]     CB协议帧标志: 否
                 3'b000}                // [2:0]   操作类型: 转发
            );
            $display("  Port %0d: DMAC=BB:CC:DD:EE:FF:%02h -> TX Port %0d", 
                     r_test_loop_j, 8'h10 + r_test_loop_j, r_test_loop_j);
        repeat(1000) @(posedge r_clk);
        end
        

        tcam_done = 1'd1;
        $display("\n================================================================================");
        $display("=== TCAM Table Initialization Completed - Total Entries Configured         ===");
        $display("================================================================================\n");
        
        repeat(100) @(posedge r_clk);
    end
endtask

//==========================================================================
// QBU pMAC通道任务：发送低优先级可抢占帧
//==========================================================================

//--------------------------------------------------------------------------
// 任务：通过pMAC通道发送帧（与eMAC格式相同但VLAN优先级较低）
//--------------------------------------------------------------------------
task send_pmac_frame;
    input integer rport_id;
    input [47:0] dmac;
    input [47:0] smac;
    input [2:0] vlan_priority;   // pMAC使用较低的VLAN优先级
    input [11:0] vlan_id;
    input integer payload_len;
    integer i, total_bytes;
    reg [7:0] rframe_buffer[0:1535];  // pMAC帧缓冲
    integer buf_idx;
    begin
        buf_idx = 0;
        
        // 构建以太网帧头部
        rframe_buffer[buf_idx+0] = dmac[47:40];
        rframe_buffer[buf_idx+1] = dmac[39:32];
        rframe_buffer[buf_idx+2] = dmac[31:24];
        rframe_buffer[buf_idx+3] = dmac[23:16];
        rframe_buffer[buf_idx+4] = dmac[15:8];
        rframe_buffer[buf_idx+5] = dmac[7:0];
        buf_idx = buf_idx + 6;
        
        rframe_buffer[buf_idx+0] = smac[47:40];
        rframe_buffer[buf_idx+1] = smac[39:32];
        rframe_buffer[buf_idx+2] = smac[31:24];
        rframe_buffer[buf_idx+3] = smac[23:16];
        rframe_buffer[buf_idx+4] = smac[15:8];
        rframe_buffer[buf_idx+5] = smac[7:0];
        buf_idx = buf_idx + 6;
        
        // 添加VLAN标签 (pMAC使用低优先级)
        rframe_buffer[buf_idx+0] = 8'h81;
        rframe_buffer[buf_idx+1] = 8'h00;
        rframe_buffer[buf_idx+2] = {vlan_priority, 1'b0, vlan_id[11:8]};
        rframe_buffer[buf_idx+3] = vlan_id[7:0];
        buf_idx = buf_idx + 4;
        
        // EtherType (IPv4)
        rframe_buffer[buf_idx+0] = 8'h08;
        rframe_buffer[buf_idx+1] = 8'h00;
        buf_idx = buf_idx + 2;
        
        // Payload - 递增模式 (0x00, 0x01, 0x02, ..., 0xFF, 0x00, ...)，便于调试验证数据正确性
        for (i = 0; i < payload_len; i = i + 1) begin
            rframe_buffer[buf_idx+i] = i[7:0];
        end
        buf_idx = buf_idx + payload_len;
        
        total_bytes = buf_idx;
        
        // 通过pMAC通道发送
        r_pmac_ethertype[rport_id] = 16'h0800;
        r_pmac_axi_user[rport_id] = total_bytes;
        
        for (i = 0; i < total_bytes; i = i + 1) begin
            @(posedge r_clk);
            r_pmac_axi_data[rport_id] = rframe_buffer[i];
            r_pmac_axi_keep[rport_id] = 1'b1;
            r_pmac_axi_valid[rport_id] = 1'b1;
            r_pmac_axi_last[rport_id] = (i == total_bytes - 1);
            
            // 等待ready
            while (!w_pmac_axi_ready[rport_id]) begin
                @(posedge r_clk);
            end
        end
        
        // 结束传输
        @(posedge r_clk);
        r_pmac_axi_valid[rport_id] = 1'b0;
        r_pmac_axi_last[rport_id] = 1'b0;
        
        $display("[PMAC] Frame sent: Port=%0d, DMAC=%012h, SMAC=%012h, VLAN_PRI=%0d, Len=%0d (Payload: 0x00~0x%02h)", 
                 rport_id, dmac, smac, vlan_priority, total_bytes, (payload_len-1)%256);
    end
endtask

//--------------------------------------------------------------------------
// 任务：启用/禁用pMAC通道
//--------------------------------------------------------------------------
task enable_pmac_channel;
    input integer port_id;
    input integer enable;
    begin
        if (enable) begin
            $display("[PMAC] Enabling pMAC channel on port %0d", port_id);
        end else begin
            r_pmac_axi_valid[port_id] = 1'b0;
            $display("[PMAC] Disabling pMAC channel on port %0d", port_id);
        end
    end
endtask

//--------------------------------------------------------------------------
// 任务：快速发送pMAC帧（使用默认低优先级）
//--------------------------------------------------------------------------
task quick_send_pmac;
    input integer port_id;
    input [47:0] dmac;
    input [47:0] smac;
    input integer payload_len;
    begin
        // pMAC使用低优先级0或1
        send_pmac_frame(port_id, dmac, smac, 3'b001, 12'h001, payload_len);
    end
endtask

//==========================================================================
// QBU eMAC通道任务：发送高优先级不可抢占帧
//==========================================================================

//--------------------------------------------------------------------------
// 任务：通过eMAC通道发送帧（高优先级，可抢占pMAC）
//--------------------------------------------------------------------------
task send_emac_frame;
    input integer port_id;
    input [47:0] dmac;
    input [47:0] smac;
    input [2:0] vlan_priority;   // eMAC使用较高的VLAN优先级
    input [11:0] vlan_id;
    input integer payload_len;
    integer j, rtotal_bytes;
    reg [7:0] frame_buffer[0:1535];  // eMAC帧缓冲
    integer buf_idx;
    begin
        buf_idx = 0;
        
        // 构建以太网帧头部
        frame_buffer[buf_idx+0] = dmac[47:40];
        frame_buffer[buf_idx+1] = dmac[39:32];
        frame_buffer[buf_idx+2] = dmac[31:24];
        frame_buffer[buf_idx+3] = dmac[23:16];
        frame_buffer[buf_idx+4] = dmac[15:8];
        frame_buffer[buf_idx+5] = dmac[7:0];
        buf_idx = buf_idx + 6;
        
        frame_buffer[buf_idx+0] = smac[47:40];
        frame_buffer[buf_idx+1] = smac[39:32];
        frame_buffer[buf_idx+2] = smac[31:24];
        frame_buffer[buf_idx+3] = smac[23:16];
        frame_buffer[buf_idx+4] = smac[15:8];
        frame_buffer[buf_idx+5] = smac[7:0];
        buf_idx = buf_idx + 6;
        
        // 添加VLAN标签 (eMAC使用高优先级)
        frame_buffer[buf_idx+0] = 8'h81;
        frame_buffer[buf_idx+1] = 8'h00;
        frame_buffer[buf_idx+2] = {vlan_priority, 1'b0, vlan_id[11:8]};
        frame_buffer[buf_idx+3] = vlan_id[7:0];
        buf_idx = buf_idx + 4;
        
        // EtherType (IPv4)
        frame_buffer[buf_idx+0] = 8'h08;
        frame_buffer[buf_idx+1] = 8'h00;
        buf_idx = buf_idx + 2;
        
        // Payload - 递增模式 (0x00, 0x01, 0x02, ..., 0xFF, 0x00, ...)，便于调试验证数据正确性
        for (j = 0; j < payload_len; j = j + 1) begin
            frame_buffer[buf_idx+j] = j[7:0];
        end
        buf_idx = buf_idx + payload_len;
        
        rtotal_bytes = buf_idx;
        
        // 通过eMAC通道发送
        r_emac_ethertype[port_id] = 16'h0800;
        r_emac_axi_user[port_id] = rtotal_bytes;
        
        for (j = 0; j < rtotal_bytes; j = j + 1) begin
            @(posedge r_clk);
            r_emac_axi_data[port_id] = frame_buffer[j];
            r_emac_axi_keep[port_id] = 1'b1;
            r_emac_axi_valid[port_id] = 1'b1;
            r_emac_axi_last[port_id] = (j == rtotal_bytes - 1);
            
            // 等待ready
            while (!w_emac_axi_ready[port_id]) begin
                @(posedge r_clk);
            end
        end
        
        // 结束传输
        @(posedge r_clk);
        r_emac_axi_valid[port_id] = 1'b0;
        r_emac_axi_last[port_id] = 1'b0;
        
        $display("[EMAC] Frame sent: Port=%0d, DMAC=%012h, SMAC=%012h, VLAN_PRI=%0d, Len=%0d (Payload: 0x00~0x%02h)", 
                 port_id, dmac, smac, vlan_priority, rtotal_bytes, (payload_len-1)%256);
    end
endtask

//--------------------------------------------------------------------------
// 任务：启用/禁用eMAC通道
//--------------------------------------------------------------------------
task enable_emac_channel;
    input integer port_id;
    input integer enable;
    begin
        if (enable) begin
            $display("[EMAC] Enabling eMAC channel on port %0d", port_id);
        end else begin
            r_emac_axi_valid[port_id] = 1'b0;
            $display("[EMAC] Disabling eMAC channel on port %0d", port_id);
        end
    end
endtask

//--------------------------------------------------------------------------
// 任务：快速发送eMAC帧（使用默认高优先级）
//--------------------------------------------------------------------------
task quick_send_emac;
    input integer port_id;
    input [47:0] dmac;
    input [47:0] smac;
    input integer payload_len;
    begin
        // eMAC使用高优先级6或7
        send_emac_frame(port_id, dmac, smac, 3'b111, 12'h001, payload_len);
    end
endtask

//==========================================================================
// QBU帧抢占测试任务：同时发送pMAC和eMAC以测试抢占功能
//==========================================================================

//--------------------------------------------------------------------------
// 任务：测试帧抢占 - eMAC抢占pMAC
//--------------------------------------------------------------------------
task test_frame_preemption;
    input integer port_id;
    input [47:0] dmac;
    input [47:0] smac_pmac;
    input [47:0] smac_emac;
    input integer pmac_payload_len;
    input integer emac_payload_len;
    begin
        $display("\n[QBU_TEST] ========================================");
        $display("[QBU_TEST] Frame Preemption Test on Port %0d", port_id);
        $display("[QBU_TEST] pMAC frame length: %0d bytes", pmac_payload_len);
        $display("[QBU_TEST] eMAC frame length: %0d bytes", emac_payload_len);
        $display("[QBU_TEST] ========================================");
        
        // Fork两个并行任务：同时发送pMAC和eMAC帧
        fork
            begin
                // 发送pMAC帧（低优先级，可被抢占）
                $display("[QBU_TEST] Starting pMAC transmission...");
                send_pmac_frame(port_id, dmac, smac_pmac, 3'b001, 12'h001, pmac_payload_len);
            end
            begin
                // 延迟一段时间后发送eMAC帧（模拟抢占场景）
                repeat(pmac_payload_len / 4) @(posedge r_clk);  // 在pMAC传输1/4时插入eMAC
                $display("[QBU_TEST] Starting eMAC transmission (should preempt pMAC)...");
                send_emac_frame(port_id, dmac, smac_emac, 3'b111, 12'h001, emac_payload_len);
            end
        join
        
        $display("[QBU_TEST] Preemption test completed on Port %0d", port_id);
        $display("[QBU_TEST] ========================================\n");
    end
endtask

//--------------------------------------------------------------------------
// 任务：测试pMAC和eMAC同时传输（无抢占，两个小帧）
//--------------------------------------------------------------------------
task test_concurrent_transmission;
    input integer port_id;
    input [47:0] dmac;
    input [47:0] smac_pmac;
    input [47:0] smac_emac;
    begin
        $display("\n[QBU_TEST] ========================================");
        $display("[QBU_TEST] Concurrent Transmission Test on Port %0d", port_id);
        $display("[QBU_TEST] ========================================");
        
        // Fork两个并行任务：同时开始发送
        fork
            begin
                $display("[QBU_TEST] pMAC: Sending short frame...");
                quick_send_pmac(port_id, r_dst_mac_table[1], smac_pmac, 64);
            end
            begin
                $display("[QBU_TEST] eMAC: Sending short frame...");
                quick_send_emac(port_id, r_dst_mac_table[1], smac_emac, 64);
            end
        join
        
        $display("[QBU_TEST] Concurrent transmission test completed");
        $display("[QBU_TEST] ========================================\n");
    end
endtask

//==========================================================================
// QBU任务结束
//==========================================================================

//==========================================================================
// DUT实际输入信号测试任务 (直接驱动被测模块MAC端口信号)
//==========================================================================

//--------------------------------------------------------------------------
// 任务：将帧数据发送到被测模块的实际MAC端口输入信号
//--------------------------------------------------------------------------
task send_frame_to_dut_port;
    input integer port_id;
    input integer frame_len;
    
    integer byte_idx;
    integer cycle_count;
    reg [PORT_MNG_DATA_WIDTH-1:0] data_word;
    reg [KEEP_WIDTH-1:0] keep_word;
    reg last_word;
    
    begin
        $display("[%0t] Send %0d bytes frame to DUT port %0d", $time, frame_len, port_id);
        
        // 初始化端口状态和链路参数
        case (port_id)
            0: begin
                r_mac0_port_link = 1'b1;                    // 端口连接
                r_mac0_port_speed = 2'b10;                  // 1000M速率
                r_mac0_port_filter_preamble_v = 1'b1;       // 过滤前导码
                r_mac0_axi_data_valid = 1'b0;
                r_mac0_axi_data_last = 1'b0;
            end
            1: begin
                r_mac1_port_link = 1'b1;
                r_mac1_port_speed = 2'b10;
                r_mac1_port_filter_preamble_v = 1'b1;
                r_mac1_axi_data_valid = 1'b0;
                r_mac1_axi_data_last = 1'b0;
            end
            2: begin
                r_mac2_port_link = 1'b1;
                r_mac2_port_speed = 2'b10;
                r_mac2_port_filter_preamble_v = 1'b1;
                r_mac2_axi_data_valid = 1'b0;
                r_mac2_axi_data_last = 1'b0;
            end
            3: begin
                r_mac3_port_link = 1'b1;
                r_mac3_port_speed = 2'b10;
                r_mac3_port_filter_preamble_v = 1'b1;
                r_mac3_axi_data_valid = 1'b0;
                r_mac3_axi_data_last = 1'b0;
            end
            4: begin
                r_mac4_port_link = 1'b1;
                r_mac4_port_speed = 2'b10;
                r_mac4_port_filter_preamble_v = 1'b1;
                r_mac4_axi_data_valid = 1'b0;
                r_mac4_axi_data_last = 1'b0;
            end
            5: begin
                r_mac5_port_link = 1'b1;
                r_mac5_port_speed = 2'b10;
                r_mac5_port_filter_preamble_v = 1'b1;
                r_mac5_axi_data_valid = 1'b0;
                r_mac5_axi_data_last = 1'b0;
            end
            6: begin
                r_mac6_port_link = 1'b1;
                r_mac6_port_speed = 2'b10;
                r_mac6_port_filter_preamble_v = 1'b1;
                r_mac6_axi_data_valid = 1'b0;
                r_mac6_axi_data_last = 1'b0;
            end
            7: begin
                r_mac7_port_link = 1'b1;
                r_mac7_port_speed = 2'b10;
                r_mac7_port_filter_preamble_v = 1'b1;
                r_mac7_axi_data_valid = 1'b0;
                r_mac7_axi_data_last = 1'b0;
            end
        endcase
        
        byte_idx = 0;
        cycle_count = 0;
        
        // 等待复位完成和端口稳定
        repeat (5) @(posedge r_clk);
        
        // 逐字节发送帧数据
        while (byte_idx < frame_len) begin
            // 构造8位数据字和1位keep信号
            data_word = 0;
            keep_word = 0;
            last_word = 0;
            
            // 填充1字节数据 - 8位数据位宽
            if (byte_idx < frame_len) begin 
                data_word = frame_buffer[byte_idx]; 
                keep_word = 1'b1; 
            end
            
            // 检查是否为最后一个字节
            if (byte_idx + 1 >= frame_len) begin
                last_word = 1'b1;
            end
            
            // 发送数据到被测模块对应端口的输入信号
            @(posedge r_clk);
            case (port_id)
                0: begin
                    r_mac0_axi_data = data_word;
                    r_mac0_axi_data_keep = keep_word;
                    r_mac0_axi_data_valid = 1'b1;
                    r_mac0_axi_data_last = last_word;
                    // 等待ready信号
                    while (!w_mac0_axi_data_ready) @(posedge r_clk);
                end
                1: begin
                    r_mac1_axi_data = data_word;
                    r_mac1_axi_data_keep = keep_word;
                    r_mac1_axi_data_valid = 1'b1;
                    r_mac1_axi_data_last = last_word;
                    while (!w_mac1_axi_data_ready) @(posedge r_clk);
                end
                2: begin
                    r_mac2_axi_data = data_word;
                    r_mac2_axi_data_keep = keep_word;
                    r_mac2_axi_data_valid = 1'b1;
                    r_mac2_axi_data_last = last_word;
                    while (!w_mac2_axi_data_ready) @(posedge r_clk);
                end
                3: begin
                    r_mac3_axi_data = data_word;
                    r_mac3_axi_data_keep = keep_word;
                    r_mac3_axi_data_valid = 1'b1;
                    r_mac3_axi_data_last = last_word;
                    while (!w_mac3_axi_data_ready) @(posedge r_clk);
                end
                4: begin
                    r_mac4_axi_data = data_word;
                    r_mac4_axi_data_keep = keep_word;
                    r_mac4_axi_data_valid = 1'b1;
                    r_mac4_axi_data_last = last_word;
                    while (!w_mac4_axi_data_ready) @(posedge r_clk);
                end
                5: begin
                    r_mac5_axi_data = data_word;
                    r_mac5_axi_data_keep = keep_word;
                    r_mac5_axi_data_valid = 1'b1;
                    r_mac5_axi_data_last = last_word;
                    while (!w_mac5_axi_data_ready) @(posedge r_clk);
                end
                6: begin
                    r_mac6_axi_data = data_word;
                    r_mac6_axi_data_keep = keep_word;
                    r_mac6_axi_data_valid = 1'b1;
                    r_mac6_axi_data_last = last_word;
                    while (!w_mac6_axi_data_ready) @(posedge r_clk);
                end
                7: begin
                    r_mac7_axi_data = data_word;
                    r_mac7_axi_data_keep = keep_word;
                    r_mac7_axi_data_valid = 1'b1;
                    r_mac7_axi_data_last = last_word;
                    while (!w_mac7_axi_data_ready) @(posedge r_clk);
                end
            endcase
            
            byte_idx = byte_idx + 1;  // 8位数据位宽，每次处理1字节
            cycle_count = cycle_count + 1;
        end
        
        // 清除valid和last信号
        @(posedge r_clk);
        case (port_id)
            0: begin r_mac0_axi_data_valid = 1'b0; r_mac0_axi_data_last = 1'b0; end
            1: begin r_mac1_axi_data_valid = 1'b0; r_mac1_axi_data_last = 1'b0; end
            2: begin r_mac2_axi_data_valid = 1'b0; r_mac2_axi_data_last = 1'b0; end
            3: begin r_mac3_axi_data_valid = 1'b0; r_mac3_axi_data_last = 1'b0; end
            4: begin r_mac4_axi_data_valid = 1'b0; r_mac4_axi_data_last = 1'b0; end
            5: begin r_mac5_axi_data_valid = 1'b0; r_mac5_axi_data_last = 1'b0; end
            6: begin r_mac6_axi_data_valid = 1'b0; r_mac6_axi_data_last = 1'b0; end
            7: begin r_mac7_axi_data_valid = 1'b0; r_mac7_axi_data_last = 1'b0; end
        endcase
        
        $display("[%0t] Port %0d frame transmission completed, total %0d cycles", $time, port_id, cycle_count);
    end
endtask

//--------------------------------------------------------------------------
// 任务：使用DUT端口发送预配置帧 (使用现有generate_eth_frame任务)
//--------------------------------------------------------------------------
task dut_send_configured_frame;
    input integer port_id;
    input integer frame_type; // 0=IPv4, 1=VLAN, 2=PTP, 3=Broadcast
    
    integer total_frame_len;
    
    begin
        case (frame_type)
            0: begin
                $display("[%0t] DUT port %0d send IPv4 frame", $time, port_id);
                config_frame(48'h01_02_03_04_05_06, r_src_mac_table[port_id], 1'b0, 3'b000, 12'h000, 1'b0, 16'h0000, 16'h0800, 46, 8'hAA, 1'b1);
                total_frame_len = 46 + 14 + 8; // payload + ethernet header + preamble
            end
            1: begin
                $display("[%0t] DUT port %0d send VLAN frame", $time, port_id);
                config_frame(48'h01_AA_BB_CC_DD_EE, r_src_mac_table[port_id], 1'b1, 3'h2, 12'h100 + port_id, 1'b0, 16'h0000, 16'h0800, 46, 8'hBB, 1'b1);
                total_frame_len = 46 + 18 + 8; // payload + ethernet header + VLAN + preamble
            end
            2: begin
                $display("[%0t] DUT port %0d send PTP frame", $time, port_id);
                config_frame(48'h01_1B_19_00_00_00, r_src_mac_table[port_id], 1'b0, 3'b000, 12'h000, 1'b0, 16'h0000, 16'h88F7, 50, 8'hCC, 1'b1);
                total_frame_len = 50 + 14 + 8; // payload + ethernet header + preamble
            end
            3: begin
                $display("[%0t] DUT port %0d send broadcast frame", $time, port_id);
                config_frame(48'hFF_FF_FF_FF_FF_FF, r_src_mac_table[port_id], 1'b0, 3'b000, 12'h000, 1'b0, 16'h0000, 16'h0800, 64, 8'hDD, 1'b1);
                total_frame_len = 64 + 14 + 8; // payload + ethernet header + preamble
            end
        endcase
        
        // 生成帧到缓冲区
        generate_eth_frame(port_id);
        
        // 发送到DUT端口
        send_frame_to_dut_port(port_id, total_frame_len);
    end
endtask

//--------------------------------------------------------------------------
// 任务：DUT端口批量测试序列
//--------------------------------------------------------------------------
task dut_test_sequence;
    input integer start_port;
    input integer frame_count;
    
    integer frame_idx;
    integer port_idx;
    
    begin
        $display("[%0t] === Start DUT port batch test sequence ===", $time);
        $display("Start port: %0d, Frame count: %0d", start_port, frame_count);
        
        for (frame_idx = 0; frame_idx < frame_count; frame_idx = frame_idx + 1) begin
            port_idx = (start_port + frame_idx) % PORT_NUM;
            
            $display("[%0t] DUT test frame %0d to port %0d", $time, frame_idx, port_idx);
            
            // 根据帧索引选择不同的帧类型进行测试
            dut_send_configured_frame(port_idx, frame_idx % 4);
            
            repeat (20) @(posedge r_clk); // 帧间间隔
        end
        
        $display("[%0t] === DUT port batch test sequence completed ===", $time);
    end
endtask

//==========================================================================
// QBU帧抢占测试用例
//==========================================================================

//--------------------------------------------------------------------------
// 测试用例：QBU eMAC和pMAC独立传输测试
//--------------------------------------------------------------------------
task test_qbu_independent_channels;
    integer port_id;
    reg [47:0] test_dmac;
    reg [47:0] test_smac_emac;
    reg [47:0] test_smac_pmac;
    begin
        $display("\n");
        $display("========================================================================");
        $display("=== TEST CASE: QBU Independent Channel Test                         ===");
        $display("=== Verify eMAC and pMAC can transmit independently                 ===");
        $display("========================================================================");
        
        test_dmac = 48'hFF_FF_FF_FF_FF_FF;  // Broadcast
        test_smac_emac = 48'h00_E0_4C_11_11_11;
        test_smac_pmac = 48'h00_E0_4C_22_22_22;
        
        // 测试1: 仅eMAC发送
        port_id = 0;
        $display("\n[TEST 1] Port %0d: eMAC only transmission", port_id);
        quick_send_emac(port_id, test_dmac, test_smac_emac, 100);
        repeat(50) @(posedge r_clk);
        
        // 测试2: 仅pMAC发送
        $display("\n[TEST 2] Port %0d: pMAC only transmission", port_id);
        quick_send_pmac(port_id, test_dmac, test_smac_pmac, 100);
        repeat(50) @(posedge r_clk);
        
        // // 测试3: eMAC和pMAC同时发送（并发）
        // $display("\n[TEST 3] Port %0d: Concurrent eMAC and pMAC transmission", port_id);
        // test_concurrent_transmission(port_id, test_dmac, test_smac_pmac, test_smac_emac);
        // repeat(50) @(posedge r_clk);
        
        $display("\n========================================================================");
        $display("=== QBU Independent Channel Test Completed                          ===");
        $display("========================================================================\n");
    end
endtask

//--------------------------------------------------------------------------
// 测试用例：QBU帧抢占功能测试
//--------------------------------------------------------------------------
task test_qbu_frame_preemption;
    integer port_id;
    reg [47:0] test_dmac;
    reg [47:0] test_smac_emac;
    reg [47:0] test_smac_pmac;
    begin
        $display("\n");
        $display("========================================================================");
        $display("=== TEST CASE: QBU Frame Preemption Test                            ===");
        $display("=== Verify eMAC can preempt pMAC transmission                       ===");
        $display("========================================================================");
        
        test_dmac = 48'h01_02_03_04_05_06;
        test_smac_emac = 48'h00_E0_4C_AA_AA_AA;
        test_smac_pmac = 48'h00_E0_4C_BB_BB_BB;
        
        // 测试不同端口的抢占功能
        for (port_id = 0; port_id < 4; port_id = port_id + 1) begin
            $display("\n[PREEMPTION TEST] Testing port %0d", port_id);
            
            // 场景1: pMAC大帧 + eMAC小帧（模拟典型抢占场景）
            $display("[Scenario 1] Large pMAC frame + Small eMAC frame");
            test_frame_preemption(port_id, test_dmac, test_smac_pmac, test_smac_emac, 1200, 64);
            repeat(100) @(posedge r_clk);
            
            // 场景2: pMAC中等帧 + eMAC中等帧
            $display("[Scenario 2] Medium pMAC frame + Medium eMAC frame");
            test_frame_preemption(port_id, test_dmac, test_smac_pmac, test_smac_emac, 500, 500);
            repeat(100) @(posedge r_clk);
        end
        
        $display("\n========================================================================");
        $display("=== QBU Frame Preemption Test Completed                             ===");
        $display("========================================================================\n");
    end
endtask

//--------------------------------------------------------------------------
// 测试用例：QBU多端口混合测试
//--------------------------------------------------------------------------
task test_qbu_multiport_mixed;
    integer port_id;
    reg [47:0] test_dmac;
    reg [47:0] test_smac;
    begin
        $display("\n");
        $display("========================================================================");
        $display("=== TEST CASE: QBU Multi-Port Mixed Traffic Test                    ===");
        $display("=== Verify multiple ports with mixed eMAC/pMAC traffic              ===");
        $display("========================================================================");
        
        test_dmac = 48'hFF_FF_FF_FF_FF_FF;
        
        // 在多个端口上同时发送eMAC和pMAC流量
        fork
            // Port 0-1: eMAC高优先级流
            begin
                for (port_id = 0; port_id < 2; port_id = port_id + 1) begin
                    test_smac = {16'h00E0, 8'h4C, 8'h10, 8'h00, port_id[7:0]};
                    quick_send_emac(port_id, test_dmac, test_smac, 200);
                    repeat(20) @(posedge r_clk);
                end
            end
            
            // Port 2-3: pMAC低优先级流
            begin
                for (port_id = 2; port_id < 4; port_id = port_id + 1) begin
                    test_smac = {16'h00E0, 8'h4C, 8'h20, 8'h00, port_id[7:0]};
                    quick_send_pmac(port_id, test_dmac, test_smac, 800);
                    repeat(20) @(posedge r_clk);
                end
            end
            
            // Port 4-5: 混合传输（抢占测试）
            begin
                for (port_id = 4; port_id < 6; port_id = port_id + 1) begin
                    test_frame_preemption(
                        port_id, 
                        test_dmac, 
                        {16'h00E0, 8'h4C, 8'h30, 8'h00, port_id[7:0]},  // pMAC SMAC
                        {16'h00E0, 8'h4C, 8'h40, 8'h00, port_id[7:0]},  // eMAC SMAC
                        1000,  // pMAC length
                        100    // eMAC length
                    );
                    repeat(50) @(posedge r_clk);
                end
            end
        join
        
        repeat(200) @(posedge r_clk);
        
        $display("\n========================================================================");
        $display("=== QBU Multi-Port Mixed Traffic Test Completed                     ===");
        $display("========================================================================\n");
    end
endtask

//--------------------------------------------------------------------------
// 任务：DUT多端口并行测试 (简化版本避免automatic变量问题)
//--------------------------------------------------------------------------
task dut_parallel_test;
    input integer frame_count_per_port;
    
    integer i;
    
    begin
        $display("[%0t] === Start DUT multi-port parallel test ===", $time);
        
        // 顺序发送到所有端口
        fork
            begin
                for (i = 0; i < frame_count_per_port; i = i + 1) begin
                    gen_send_ipv4_frame(0, 64);
                    repeat (10) @(posedge r_clk);
                end
            end
            begin
                for (i = 0; i < frame_count_per_port; i = i + 1) begin
                    gen_send_vlan_frame(1, 64, 12'h200 + i[11:0], 3'h3);
                    repeat (10) @(posedge r_clk);
                end
            end
            begin
                for (i = 0; i < frame_count_per_port; i = i + 1) begin
                    gen_send_ptp_frame(2, 64);
                    repeat (10) @(posedge r_clk);
                end
            end
            begin
                for (i = 0; i < frame_count_per_port; i = i + 1) begin
                    quick_send_broadcast(3, r_src_mac_table[3], 64);
                    repeat (10) @(posedge r_clk);
                end
            end
        join
        
        $display("[%0t] === DUT multi-port parallel test completed ===", $time);
    end
endtask

//==========================================================================
// 以太网帧生成器控制任务
//==========================================================================

//--------------------------------------------------------------------------
// 任务：配置帧生成器
//--------------------------------------------------------------------------
task config_frame_generator;
    input integer port_id;
    input [15:0] frame_len;
    input vlan_enable;
    input rtag_enable;
    input [15:0] vlan_tag;
    input [15:0] rtag;
    input [15:0] ether_type;
    begin
        if (port_id >= 0 && port_id < PORT_NUM) begin
            r_frame_len[port_id]   = frame_len;
            r_add_vlan[port_id]    = vlan_enable;
            r_add_rtag[port_id]    = rtag_enable;
            r_vlan_tag[port_id]    = vlan_tag;
            r_rtag[port_id]        = rtag;
            r_ether_type[port_id]  = ether_type;
            $display("[FRAME_GEN] Port %0d configured: Len=%0d, VLAN=%b, RTAG=%b, EthType=0x%04h", 
                     port_id, frame_len, vlan_enable, rtag_enable, ether_type);
        end else begin
            $display("[ERROR] Invalid port_id: %0d", port_id);
        end
    end
endtask

//--------------------------------------------------------------------------
// 任务：启动帧生成器
//--------------------------------------------------------------------------
task start_frame_generator;
    input integer port_id;
    begin
        if (port_id >= 0 && port_id < PORT_NUM) begin
            // 切换到帧生成器模式
            r_axi_source_sel[port_id] = 1'b1;
            // 启动帧生成
            r_frame_gen_start[port_id] = 1'b1;
            @(posedge r_clk);
            r_frame_gen_start[port_id] = 1'b0;
            $display("[FRAME_GEN] Port %0d generator started", port_id);
        end else begin
            $display("[ERROR] Invalid port_id: %0d", port_id);
        end
    end
endtask

//--------------------------------------------------------------------------
// 任务：等待帧生成完成
//--------------------------------------------------------------------------
task wait_frame_generation_done;
    input integer port_id;
    begin
        if (port_id >= 0 && port_id < PORT_NUM) begin
            wait(w_frame_gen_done[port_id] == 1'b1);
            $display("[FRAME_GEN] Port %0d generation completed", port_id);
        end else begin
            $display("[ERROR] Invalid port_id: %0d", port_id);
        end
    end
endtask

//--------------------------------------------------------------------------
// 任务：生成并发送标准IPv4帧（使用帧生成器）
//--------------------------------------------------------------------------
task gen_send_ipv4_frame;
    input integer port_id;
    input [15:0] frame_len;
    begin
        // 配置帧生成器为IPv4帧
        config_frame_generator(port_id, frame_len, 1'b0, 1'b0, 16'h8100, 16'h0000, ETH_TYPE_IPV4);
        // 启动生成
        start_frame_generator(port_id);
        // 等待完成
        wait_frame_generation_done(port_id);
        $display("[FRAME_GEN] IPv4 frame sent on port %0d, length=%0d", port_id, frame_len);
    end
endtask

//--------------------------------------------------------------------------
// 任务：生成并发送VLAN帧（使用帧生成器）
//--------------------------------------------------------------------------
task gen_send_vlan_frame;
    input integer port_id;
    input [15:0] frame_len;
    input [11:0] vlan_id;
    input [2:0] vlan_pcp;
    begin
        // 配置帧生成器为VLAN帧
        config_frame_generator(port_id, frame_len, 1'b1, 1'b0, {vlan_pcp, 1'b0, vlan_id}, 16'h0000, ETH_TYPE_IPV4);
        // 启动生成
        start_frame_generator(port_id);
        // 等待完成
        wait_frame_generation_done(port_id);
        $display("[FRAME_GEN] VLAN frame sent on port %0d, length=%0d, VLAN ID=%03h", port_id, frame_len, vlan_id);
    end
endtask

//--------------------------------------------------------------------------
// 任务：生成并发送PTP帧（使用帧生成器）
//--------------------------------------------------------------------------
task gen_send_ptp_frame;
    input integer port_id;
    input [15:0] frame_len;
    begin
        // 配置帧生成器为PTP帧
        config_frame_generator(port_id, frame_len, 1'b0, 1'b0, 16'h8100, 16'h0000, ETH_TYPE_PTP);
        // 启动生成
        start_frame_generator(port_id);
        // 等待完成
        wait_frame_generation_done(port_id);
        $display("[FRAME_GEN] PTP frame sent on port %0d, length=%0d", port_id, frame_len);
    end
endtask


    //==========================================================================
    // DUT端口直接测试示例 (将帧数据发送到被测模块的实际MAC端口输入信号)
    // //==========================================================================
    
    // initial begin
    //     // 等待复位完成
    //     wait(r_rst_n == 1'b1);
    //     repeat (100) @(posedge r_clk);
        
    //     $display("\n===============================================");
    //     $display("=== TCAM Initialization Started ===");
    //     $display("===============================================");
        
        


    //     // TCAM表项初始化
    //     tcam_initialize();
        
    //     // $display("\n===============================================");
    //     // $display("=== DUT Direct Port Test Started ===");
    //     // $display("=== Direct Drive DUT MAC Port Input Signals ===");
    //     // $display("===============================================");
        
    //     // // Demonstrate preamble control
    //     // $display("\n[Preamble Demo] Testing with and without preamble");
    //     // set_preamble_enable(1'b1);  // Enable preamble
    //     // $display("Preamble enabled - frames will include 7x55 + D5 prefix");
        
    //     // // Demonstrate hardware CRC32 calculation
    //     // // test_crc32_hw(64);  // Test with 64 bytes of data
        
    //     // // Test 1: Send IPv4 frame to port 0 actual input signals
    //     // $display("\n[DUT Test 1] Port 0 MAC Input Signal - IPv4 Frame");
    //     // dut_send_configured_frame(0, 0); // frame_type 0 = IPv4
    //     // repeat (10) @(posedge r_clk);
    //     // dut_send_configured_frame(1, 0); // frame_type 1 = VLAN
    //     // send_vlan_frame(0, r_dst_mac_table[0], r_src_mac_table[0], 3'h6, 12'h100);// VLAN EtherType   
        
    //     // send_vlan_frame(0, r_dst_mac_table[0], r_src_mac_table[0], 3'h1, 12'h100);// VLAN EtherType
    //     // send_vlan_frame(0, r_dst_mac_table[0], r_src_mac_table[0], 3'h5, 12'h100);// VLAN EtherType
    //     // send_vlan_frame(0, r_dst_mac_table[0], r_src_mac_table[0], 3'h3, 12'h100);// VLAN EtherType
    //     // send_vlan_frame(0, r_src_mac_table[0], r_dst_mac_table[0], 3'h4, 12'h100);// VLAN EtherType
    //     // send_vlan_frame(0, r_src_mac_table[0], r_dst_mac_table[0], 3'h2, 12'h100);// VLAN EtherType
    //     // send_rtag_frame(0,r_src_mac_table[0],r_src_mac_table[1],{16'd5},{8'd7});  
    //     // send_rtag_frame(0,r_src_mac_table[0],r_src_mac_table[1],{16'd6},{8'd7});  
    //     // send_rtag_frame(0,r_src_mac_table[0],r_src_mac_table[1],{16'd7},{8'd7});  
    //     // send_rtag_frame(0,r_src_mac_table[0],r_src_mac_table[1],{16'd8},{8'd7});  
    //     // send_rtag_frame(0,r_src_mac_table[0],r_src_mac_table[1],{16'd10},{8'd7});  
    //     // send_rtag_frame(0,r_src_mac_table[0],r_src_mac_table[1],{16'd9},{8'd7});  
    //     // send_complex_frame(0,r_dst_mac_table[2],r_src_mac_table[2],1'd1,{12'd128},1'd1,{16'd64},8'd8,16'h0800,'d200);                       
    //     // // Test 2: Send VLAN frame to port 1 actual input signals
    //     // $display("\n[DUT Test 2] Port 1 MAC Input Signal - VLAN Frame");
    //     // dut_send_configured_frame(1, 1); // frame_type 1 = VLAN
    //     // repeat (50) @(posedge r_clk);
        
    //     // // Test 3: Send PTP frame to port 2 actual input signals
    //     // $display("\n[DUT Test 3] Port 2 MAC Input Signal - PTP Frame");
    //     // dut_send_configured_frame(2, 2); // frame_type 2 = PTP
    //     // repeat (50) @(posedge r_clk);
        
    //     // // Test 4: Send broadcast frame to port 3 actual input signals
    //     // $display("\n[DUT Test 4] Port 3 MAC Input Signal - Broadcast Frame");
    //     // dut_send_configured_frame(3, 3); // frame_type 3 = Broadcast
    //     // repeat (50) @(posedge r_clk);
        
    //     // // Test 5: Batch test sequence - multi-port sequential test
    //     // $display("\n[DUT Test 5] Batch Test Sequence - 8 Port Loop");
    //     // dut_test_sequence(0, 16); // Start from port 0, send 16 frames to 8 ports
    //     // repeat (100) @(posedge r_clk);
        
    //     // // Test 6: Multi-port parallel test
    //     // $display("\n[DUT Test 6] Multi-port Parallel Test");
    //     // dut_parallel_test(4); // Send 4 frames per port
    //     // repeat (200) @(posedge r_clk);
        
    //     //======================================================================
    //     // QBU Frame Preemption Tests
    //     //======================================================================
    //     $display("\n===============================================");
    //     $display("=== QBU Frame Preemption Tests Started ===");
    //     $display("===============================================");
        
    //     // QBU测试1: 独立通道测试
    //     test_qbu_independent_channels();
    //     repeat (200) @(posedge r_clk);
        
    //     // QBU测试2: 帧抢占功能测试
    //     test_qbu_frame_preemption();
    //     repeat (200) @(posedge r_clk);
        
    //     // QBU测试3: 多端口混合流量测试
    //     test_qbu_multiport_mixed();
    //     repeat (200) @(posedge r_clk);


        
    //     $display("\n===============================================");
    //     $display("=== QBU Frame Preemption Tests Completed ===");
    //     $display("===============================================");
    //     //======================================================================
        
    //     $display("\n===============================================");
    //     $display("=== DUT Direct Port Test Completed ===");
    //     $display("=== All Frames Sent to DUT Input Ports ===");
    //     $display("===============================================");
        
    //     // 继续运行一段时间以观察DUT的响应
    //     repeat (1000) @(posedge r_clk);
        
    //     $display("\n[INFO] Test completed, simulation finished");
    //     $finish;
    // end  // initial block end

    //==========================================================================
    // TCAM初始化进程 - 在所有测试之前配置ACL表
    //==========================================================================
    initial begin
        // 等待复位和初始化完成
        wait(r_rst_n == 1'b1);
        repeat (10) @(posedge r_clk);
        
        // 执行TCAM表初始化
        tcam_table_init();
        repeat (3000) @(posedge r_clk);
        $display("[TCAM Init] TCAM table initialization completed, tests can now begin");
    end

    //==========================================================================
    // pMAC测试进程 - 5种测试场景
    //==========================================================================
    initial begin
        // 等待复位和TCAM初始化完成
        wait(r_rst_n == 1'b1);
        wait(tcam_done);  // 等待TCAM初始化完成
        
        $display("\n");
        $display("================================================================================");
        $display("=== pMAC Test Process Started - 5 Test Scenarios                            ===");
        $display("================================================================================");
        
        //======================================================================
        // 场景1: 每个通道依次输入pMAC数据，DMAC匹配到单个随机输出端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** pMAC Scenario 1: Sequential Input, Single Random Output Port            ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: DMAC=AA:BB:CC:DD:EE:01, 转发到端口3
        r_test_dmac_pmac = 48'hAA_BB_CC_DD_EE_01;
        
        // 每个端口依次发送pMAC帧到相同DMAC
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            r_test_smac_pmac = 48'h00_E0_4C_00_00_00 | r_test_loop_i; // 每个端口不同的SMAC
            $display("[pMAC S1] Port %0d -> DMAC=%012h (expect TX port 3)", r_test_loop_i, r_test_dmac_pmac);
            send_pmac_frame(r_test_loop_i, r_test_dmac_pmac, r_test_smac_pmac, 3'b001, 12'h001, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景2: 每个通道依次输入pMAC数据，DMAC匹配到多个随机输出端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** pMAC Scenario 2: Sequential Input, Multiple Random Output Ports         ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: DMAC=AA:BB:CC:DD:EE:02, 转发到端口1,3,5
        r_test_dmac_pmac = 48'hAA_BB_CC_DD_EE_02;
        
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            r_test_smac_pmac = 48'h00_E0_4C_00_01_00 | r_test_loop_i;
            $display("[pMAC S2] Port %0d -> DMAC=%012h (expect TX ports 1,3,5)", r_test_loop_i, r_test_dmac_pmac);
            send_pmac_frame(r_test_loop_i, r_test_dmac_pmac, r_test_smac_pmac, 3'b001, 12'h002, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景3.1: 每个通道依次输入pMAC数据，相同输出端口，不同优先级
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** pMAC Scenario 3.1: Sequential Input, Same Output Port, Different Priority ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: DMAC=AA:BB:CC:DD:EE:03, 转发到端口2
        r_test_dmac_pmac = 48'hAA_BB_CC_DD_EE_03;
        
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            r_test_smac_pmac = 48'h00_E0_4C_00_02_00 | r_test_loop_i;
            $display("[pMAC S3.1] Port %0d -> DMAC=%012h, Priority=%0d (expect TX port 2)", 
                     r_test_loop_i, r_test_dmac_pmac, r_test_loop_i[2:0]);
            send_pmac_frame(r_test_loop_i, r_test_dmac_pmac, r_test_smac_pmac, r_test_loop_i[2:0], 12'h003, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景3.2: 每个通道依次输入pMAC数据，相同输出端口，相同优先级
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** pMAC Scenario 3.2: Sequential Input, Same Output Port, Same Priority    ***");
        $display("********************************************************************************");
        
        // 使用相同的TCAM表项 (DMAC=AA:BB:CC:DD:EE:03, 端口2)
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            r_test_smac_pmac = 48'h00_E0_4C_00_03_00 | r_test_loop_i;
            $display("[pMAC S3.2] Port %0d -> DMAC=%012h, Priority=3 (expect TX port 2)", 
                     r_test_loop_i, r_test_dmac_pmac);
            send_pmac_frame(r_test_loop_i, r_test_dmac_pmac, r_test_smac_pmac, 3'b011, 12'h003, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景4: 多个端口相同优先级，传入不同TX端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** pMAC Scenario 4: Multiple Ports Same Priority, Different TX Ports       ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: 每个端口有独立的DMAC和TX端口映射
        // 所有端口以相同优先级发送
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            r_test_dmac_pmac = 48'hAA_BB_CC_DD_EE_10 + r_test_loop_i;
            r_test_smac_pmac = 48'h00_E0_4C_00_04_00 | r_test_loop_i;
            $display("[pMAC S4] Port %0d -> DMAC=%012h, Priority=4 (expect TX port %0d)", 
                     r_test_loop_i, r_test_dmac_pmac, r_test_loop_i);
            send_pmac_frame(r_test_loop_i, r_test_dmac_pmac, r_test_smac_pmac, 3'b100, 12'h004, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景5: 多个端口不同优先级，传入不同TX端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** pMAC Scenario 5: Multiple Ports Different Priority, Different TX Ports  ***");
        $display("********************************************************************************");
        
        // 使用场景4已配置的TCAM表项，但改变优先级
        for (r_test_loop_i = 0; r_test_loop_i < 8; r_test_loop_i = r_test_loop_i + 1) begin
            r_test_dmac_pmac = 48'hAA_BB_CC_DD_EE_10 + r_test_loop_i;
            r_test_smac_pmac = 48'h00_E0_4C_00_05_00 | r_test_loop_i;
            $display("[pMAC S5] Port %0d -> DMAC=%012h, Priority=%0d (expect TX port %0d)", 
                     r_test_loop_i, r_test_dmac_pmac, r_test_loop_i[2:0], r_test_loop_i);
            send_pmac_frame(r_test_loop_i, r_test_dmac_pmac, r_test_smac_pmac, r_test_loop_i[2:0], 12'h005, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        $display("\n================================================================================");
        $display("=== pMAC Test Process Completed - All 5 Scenarios Done                      ===");
        $display("================================================================================\n");
    end

    //==========================================================================
    // eMAC测试进程 - 5种测试场景
    //==========================================================================
    initial begin
        // 等待复位和TCAM初始化完成
        wait(r_rst_n == 1'b1);
        wait(tcam_done);  // 等待TCAM初始化完成
        
        $display("\n");
        $display("================================================================================");
        $display("=== eMAC Test Process Started - 5 Test Scenarios                            ===");
        $display("================================================================================");
        
        //======================================================================
        // 场景1: 每个通道依次输入eMAC数据，DMAC匹配到单个随机输出端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** eMAC Scenario 1: Sequential Input, Single Random Output Port            ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: DMAC=BB:CC:DD:EE:FF:01, 转发到端口5
        r_test_dmac_emac = 48'hBB_CC_DD_EE_FF_01;
        
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            r_test_smac_emac = 48'h00_E0_4C_01_00_00 | r_test_loop_j;
            $display("[eMAC S1] Port %0d -> DMAC=%012h (expect TX port 5)", r_test_loop_j, r_test_dmac_emac);
            send_emac_frame(r_test_loop_j, r_test_dmac_emac, r_test_smac_emac, 3'b111, 12'h101, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景2: 每个通道依次输入eMAC数据，DMAC匹配到多个随机输出端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** eMAC Scenario 2: Sequential Input, Multiple Random Output Ports         ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: DMAC=BB:CC:DD:EE:FF:02, 转发到端口0,2,4,6
        r_test_dmac_emac = 48'hBB_CC_DD_EE_FF_02;
        
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            r_test_smac_emac = 48'h00_E0_4C_01_01_00 | r_test_loop_j;
            $display("[eMAC S2] Port %0d -> DMAC=%012h (expect TX ports 0,2,4,6)", r_test_loop_j, r_test_dmac_emac);
            send_emac_frame(r_test_loop_j, r_test_dmac_emac, r_test_smac_emac, 3'b111, 12'h102, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景3.1: 每个通道依次输入eMAC数据，相同输出端口，不同优先级
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** eMAC Scenario 3.1: Sequential Input, Same Output Port, Different Priority ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: DMAC=BB:CC:DD:EE:FF:03, 转发到端口7
        r_test_dmac_emac = 48'hBB_CC_DD_EE_FF_03;
        
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            r_test_smac_emac = 48'h00_E0_4C_01_02_00 | r_test_loop_j;
            $display("[eMAC S3.1] Port %0d -> DMAC=%012h, Priority=%0d (expect TX port 7)", 
                     r_test_loop_j, r_test_dmac_emac, r_test_loop_j[2:0]);
            send_emac_frame(r_test_loop_j, r_test_dmac_emac, r_test_smac_emac, r_test_loop_j[2:0], 12'h103, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景3.2: 每个通道依次输入eMAC数据，相同输出端口，相同优先级
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** eMAC Scenario 3.2: Sequential Input, Same Output Port, Same Priority    ***");
        $display("********************************************************************************");
        
        // 使用相同的TCAM表项 (DMAC=BB:CC:DD:EE:FF:03, 端口7)
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            r_test_smac_emac = 48'h00_E0_4C_01_03_00 | r_test_loop_j;
            $display("[eMAC S3.2] Port %0d -> DMAC=%012h, Priority=6 (expect TX port 7)", 
                     r_test_loop_j, r_test_dmac_emac);
            send_emac_frame(r_test_loop_j, r_test_dmac_emac, r_test_smac_emac, 3'b110, 12'h103, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景4: 多个端口相同优先级，传入不同TX端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** eMAC Scenario 4: Multiple Ports Same Priority, Different TX Ports       ***");
        $display("********************************************************************************");
        
        // 使用预配置的TCAM表项: 每个端口有独立的DMAC和TX端口映射
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            r_test_dmac_emac = 48'hBB_CC_DD_EE_FF_10 + r_test_loop_j;
            r_test_smac_emac = 48'h00_E0_4C_01_04_00 | r_test_loop_j;
            $display("[eMAC S4] Port %0d -> DMAC=%012h, Priority=7 (expect TX port %0d)", 
                     r_test_loop_j, r_test_dmac_emac, r_test_loop_j);
            send_emac_frame(r_test_loop_j, r_test_dmac_emac, r_test_smac_emac, 3'b111, 12'h104, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        //======================================================================
        // 场景5: 多个端口不同优先级，传入不同TX端口
        //======================================================================
        $display("\n");
        $display("********************************************************************************");
        $display("*** eMAC Scenario 5: Multiple Ports Different Priority, Different TX Ports  ***");
        $display("********************************************************************************");
        
        for (r_test_loop_j = 0; r_test_loop_j < 8; r_test_loop_j = r_test_loop_j + 1) begin
            r_test_dmac_emac = 48'hBB_CC_DD_EE_FF_10 + r_test_loop_j;
            r_test_smac_emac = 48'h00_E0_4C_01_05_00 | r_test_loop_j;
            $display("[eMAC S5] Port %0d -> DMAC=%012h, Priority=%0d (expect TX port %0d)", 
                     r_test_loop_j, r_test_dmac_emac, r_test_loop_j[2:0], r_test_loop_j);
            send_emac_frame(r_test_loop_j, r_test_dmac_emac, r_test_smac_emac, r_test_loop_j[2:0], 12'h105, 128);
            repeat(150) @(posedge r_clk);
        end
        repeat(200) @(posedge r_clk);
        
        $display("\n================================================================================");
        $display("=== eMAC Test Process Completed - All 5 Scenarios Done                      ===");
        $display("================================================================================\n");
        
        // 所有测试完成后结束仿真
        repeat(1000) @(posedge r_clk);
        $display("\n[INFO] All pMAC and eMAC tests completed!");
        // $finish;
    end


    //==========================================================================
    // TSN CB模块例化
    //==========================================================================
    tsn_cb_top #(
        .RECOVERY_MODE  (0      ),  // 0:向量恢复算法 1：匹配恢复算法
        .PORT_NUM       (PORT_NUM)  // 交换机的端口数 
    ) u_tsn_cb_top (
        .i_clk                  (r_clk              ),
        .i_rst                  (!r_rst_n              ),
    `ifdef CPU_MAC
        .i_rtag_flag0           (w_rtag_flag0       ),
        .i_rtag_squence0        (w_rtag_sequence0   ),
        .i_stream_handle0       (w_stream_handle0   ),
    `endif
    `ifdef MAC1
        .i_rtag_flag1           (w_rtag_flag1       ),
        .i_rtag_squence1        (w_rtag_sequence1   ),
        .i_stream_handle1       (w_stream_handle1   ),
    `endif
    `ifdef MAC2
        .i_rtag_flag2           (w_rtag_flag2       ),
        .i_rtag_squence2        (w_rtag_sequence2   ),
        .i_stream_handle2       (w_stream_handle2   ),
    `endif
    `ifdef MAC3
        .i_rtag_flag3           (w_rtag_flag3       ),
        .i_rtag_squence3        (w_rtag_sequence3   ),
        .i_stream_handle3       (w_stream_handle3   ),
    `endif
    `ifdef MAC4
        .i_rtag_flag4           (w_rtag_flag4       ),
        .i_rtag_squence4        (w_rtag_sequence4   ),
        .i_stream_handle4       (w_stream_handle4   ),
    `endif
    `ifdef MAC5
        .i_rtag_flag5           (w_rtag_flag5       ),
        .i_rtag_squence5        (w_rtag_sequence5   ),
        .i_stream_handle5       (w_stream_handle5   ),
    `endif
    `ifdef MAC6
        .i_rtag_flag6           (w_rtag_flag6       ),
        .i_rtag_squence6        (w_rtag_sequence6   ),
        .i_stream_handle6       (w_stream_handle6   ),
    `endif
    `ifdef MAC7
        .i_rtag_flag7           (w_rtag_flag7       ),
        .i_rtag_squence7        (w_rtag_sequence7   ),
        .i_stream_handle7       (w_stream_handle7   ),
    `endif
        .o_pass_en              (w_cb_pass_en       ),
        .o_discard_en           (w_cb_discard_en    ),
        .o_judge_finish         (w_cb_judge_finish  )
    );
 

endmodule