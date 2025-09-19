module dmac_mng #(
        parameter                           PORT_NUM                =      8                                    ,   // 交换机的端口数
        parameter                           HASH_DATA_WIDTH         =      15                                   ,   // 哈希计算的值的位宽，支持32K表
        parameter                           REG_ADDR_BUS_WIDTH      =      8                                    ,   // 接收 MAC 层的配置寄存器地址位宽
        parameter                           REG_DATA_BUS_WIDTH      =      16                                   ,   // 接收 MAC 层的配置寄存器数据位宽
        parameter                           PORT_NUM_BIT            =      clog2(PORT_NUM)                      ,   // 端口号位宽
        parameter                           MAC_TABLE_DEPTH         =      2**HASH_DATA_WIDTH                   ,   // MAC表深度，32K
        parameter                           AGE_TIME_WIDTH          =      10                                   ,   // 老化时间位宽，支持1024秒
        parameter                           VLAN_ID_WIDTH           =      12                                   ,   // VLAN ID位宽
        parameter                           MAC_ADDR_WIDTH          =      48                                   ,   // MAC地址位宽
        parameter                           CLK_FREQ_MHZ            =      250                                  ,   // 输入时钟频率 
        parameter                           TABLE_FULL_THRESHOLD    =      29491                                ,   // MAC表满阈值（90% of 32K = 29491）
        parameter                           ENTRY_WIDTH             =      1 + AGE_TIME_WIDTH + VLAN_ID_WIDTH 
                                                                         + PORT_NUM + MAC_ADDR_WIDTH            ,   // 表项位宽: [有效位[1] + 老化时间[AGE_TIME_WIDTH-1:0] + VLAN_ID[VLAN_ID_WIDTH-1:0] + 端口号[PORT_NUM-1:0] + MAC地址[MAC_ADDR_WIDTH-1:0]]
        parameter                           AGE_SCAN_INTERVAL       =      5                                    ,   // 老化扫描间隔（秒）
        parameter                           SIM_MODE                =      0                                        // 仿真模式：1=快速仿真模式，0=正常模式
)(                      
        input               wire                                        i_clk                                   ,
        input               wire                                        i_rst                                  , 
        
        /*----------------------------- 寄存器写控制接口 ------------------------------*/     
        input               wire                                        i_reg_bus_we                            , // 寄存器写使能
        input               wire        [REG_ADDR_BUS_WIDTH-1:0]        i_reg_bus_addr                          , // 寄存器写地址
        input               wire        [REG_DATA_BUS_WIDTH-1:0]        i_reg_bus_data                          , // 寄存器写数据
        input               wire                                        i_reg_bus_data_vld                      , // 寄存器写数据使能
        
        /*----------------------------- 寄存器读控制接口 ------------------------------*/
        input               wire                                        i_reg_bus_re                            , // 寄存器读使能
        input               wire        [REG_ADDR_BUS_WIDTH-1:0]        i_reg_bus_raddr                         , // 寄存器读地址
        output              wire        [REG_DATA_BUS_WIDTH-1:0]        o_reg_bus_rdata                         , // 寄存器读数据
        output              wire                                        o_reg_bus_rdata_vld                     , // 寄存器读数据有效
        
        /*----------------------------- DMAC/SMAC 查表接口 ------------------------------*/
        input               wire        [VLAN_ID_WIDTH-1:0]             i_vlan_id                               , // 输入报文的VLAN ID
        input               wire        [MAC_ADDR_WIDTH-1:0]            i_dmac                                  , // 目的MAC地址输入
        input               wire        [HASH_DATA_WIDTH-1:0]           i_dmac_hash_addr                        , // 目的MAC的hash地址
        input               wire                                        i_dmac_hash_vld                         , // DMAC hash计算结果有效  
        input               wire        [MAC_ADDR_WIDTH-1:0]            i_smac                                  , // 源MAC地址输入
        input               wire        [HASH_DATA_WIDTH-1:0]           i_smac_hash_addr                        , // 源MAC的hash地址
        input               wire                                        i_smac_hash_vld                         , // SMAC hash计算结果有效  
        input               wire        [PORT_NUM_BIT-1:0]              i_rx_port                               , // 接收端口号
        
        /*----------------------------- 查表输出接口 ------------------------------*/                           
        output              wire                                        o_dmac_lookup_vld                       , // DMAC查表结果有效
        output              wire        [PORT_NUM-1:0]                  o_dmac_tx_port                          , // DMAC查表结果：转发端口 
        output              wire                                        o_dmac_lookup_hit                       , // DMAC查表命中标志
        output              wire                                        o_lookup_clash                          , // 查表冲突标志：哈希地址有表项但MAC/VLAN不匹配
        output              wire                                        o_table_full                              // MAC表满标志
);

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

/*---------------------------------------- 寄存器地址定义 -------------------------------------------*/
localparam  REG_AGE_TIME_THRESHOLD      = 8'h00                             ; // 老化时间阈值配置寄存器
localparam  REG_TABLE_CLEAR             = 8'h01                             ; // MAC表清空寄存器
localparam  REG_TABLE_FULL_THRESHOLD    = 8'h02                             ; // MAC表满阈值配置寄存器
localparam  REG_AGE_SCAN_INTERVAL       = 8'h03                             ; // 老化扫描间隔配置寄存器
localparam  REG_TABLE_ENTRY_cnt       = 8'h04                             ; // MAC表项计数器（只读）
localparam  REG_LEARN_STATISTICS        = 8'h05                             ; // MAC学习统计寄存器（只读）
localparam  REG_COLLISION_STATISTICS    = 8'h06                             ; // 哈希冲突统计寄存器（只读）
localparam  REG_PORT_MOVE_STATISTICS    = 8'h07                             ; // 端口移动统计寄存器（只读）

/*---------------------------------------- 状态机定义 -------------------------------------------*/
localparam  IDLE                        = 4'd0                              ; // 空闲状态
localparam  FIFO_READ_WAIT              = 4'd1                              ; // FIFO读取等待状态（STD模式需要）
localparam  DMAC_LOOKUP                 = 4'd2                              ; // DMAC查表状态
localparam  DMAC_REFRESH                = 4'd3                              ; // DMAC命中老化时间刷新状态
localparam  SMAC_LEARN_CHECK            = 4'd4                              ; // SMAC学习检查状态
localparam  SMAC_LEARN_UPDATE           = 4'd5                              ; // SMAC学习更新状态
localparam  AGE_SCAN                    = 4'd6                              ; // 老化扫描状态
localparam  AGE_UPDATE                  = 4'd7                              ; // 老化更新状态

/*---------------------------------------- 内部信号定义 -------------------------------------------*/
// 输入数据FIFO相关参数和信号
localparam  INPUT_FIFO_DEPTH            = 8                                 ; // 输入FIFO深度，支持8个报文缓存
localparam  INPUT_DATA_WIDTH            = VLAN_ID_WIDTH + MAC_ADDR_WIDTH*2 + 
                                          HASH_DATA_WIDTH*2 + 2 + PORT_NUM_BIT ; // 输入数据位宽：VLAN+DMAC+SMAC+DMAC_HASH+SMAC_HASH+2个VLD+PORT

// 5个分离FIFO的位宽定义
localparam  FIFO1_WIDTH                 = VLAN_ID_WIDTH + PORT_NUM_BIT      ; // FIFO1: VLAN_ID + RX_PORT
localparam  FIFO2_WIDTH                 = MAC_ADDR_WIDTH                    ; // FIFO2: DMAC
localparam  FIFO3_WIDTH                 = MAC_ADDR_WIDTH                    ; // FIFO3: SMAC  
localparam  FIFO4_WIDTH                 = HASH_DATA_WIDTH + 1               ; // FIFO4: DMAC_HASH_ADDR + DMAC_HASH_VLD
localparam  FIFO5_WIDTH                 = HASH_DATA_WIDTH + 1               ; // FIFO5: SMAC_HASH_ADDR + SMAC_HASH_VLD

// 5个分离FIFO的接口信号
// FIFO1: VLAN_ID + RX_PORT
wire                                    w_fifo1_wr_en                       ; // FIFO1写使能
wire        [FIFO1_WIDTH-1:0]           w_fifo1_din                         ; // FIFO1输入数据
wire                                    w_fifo1_full                        ; // FIFO1满标志
wire                                    w_fifo1_rd_en                       ; // FIFO1读使能
wire        [FIFO1_WIDTH-1:0]           w_fifo1_dout                        ; // FIFO1输出数据
wire                                    w_fifo1_empty                       ; // FIFO1空标志

// FIFO2: DMAC
wire                                    w_fifo2_wr_en                       ; // FIFO2写使能
wire        [FIFO2_WIDTH-1:0]           w_fifo2_din                         ; // FIFO2输入数据
wire                                    w_fifo2_full                        ; // FIFO2满标志
wire                                    w_fifo2_rd_en                       ; // FIFO2读使能
wire        [FIFO2_WIDTH-1:0]           w_fifo2_dout                        ; // FIFO2输出数据
wire                                    w_fifo2_empty                       ; // FIFO2空标志

// FIFO3: SMAC  
wire                                    w_fifo3_wr_en                       ; // FIFO3写使能
wire        [FIFO3_WIDTH-1:0]           w_fifo3_din                         ; // FIFO3输入数据
wire                                    w_fifo3_full                        ; // FIFO3满标志
wire                                    w_fifo3_rd_en                       ; // FIFO3读使能
wire        [FIFO3_WIDTH-1:0]           w_fifo3_dout                        ; // FIFO3输出数据
wire                                    w_fifo3_empty                       ; // FIFO3空标志

// FIFO4: DMAC_HASH_ADDR + DMAC_HASH_VLD
wire                                    w_fifo4_wr_en                       ; // FIFO4写使能
wire        [FIFO4_WIDTH-1:0]           w_fifo4_din                         ; // FIFO4输入数据
wire                                    w_fifo4_full                        ; // FIFO4满标志
wire                                    w_fifo4_rd_en                       ; // FIFO4读使能
wire        [FIFO4_WIDTH-1:0]           w_fifo4_dout                        ; // FIFO4输出数据
wire                                    w_fifo4_empty                       ; // FIFO4空标志

// FIFO5: SMAC_HASH_ADDR + SMAC_HASH_VLD
wire                                    w_fifo5_wr_en                       ; // FIFO5写使能
wire        [FIFO5_WIDTH-1:0]           w_fifo5_din                         ; // FIFO5输入数据
wire                                    w_fifo5_full                        ; // FIFO5满标志
wire                                    w_fifo5_rd_en                       ; // FIFO5读使能
wire        [FIFO5_WIDTH-1:0]           w_fifo5_dout                        ; // FIFO5输出数据
wire                                    w_fifo5_empty                       ; // FIFO5空标志

// 综合FIFO状态信号
wire                                    w_all_fifo_full                     ; // 所有FIFO满标志
wire                                    w_all_fifo_empty                    ; // 所有FIFO空标志

// 从FIFO输出数据中解析各个字段
wire        [VLAN_ID_WIDTH-1:0]         w_fifo_vlan_id                      ;
wire        [MAC_ADDR_WIDTH-1:0]        w_fifo_dmac                         ;
wire        [MAC_ADDR_WIDTH-1:0]        w_fifo_smac                         ;
wire        [HASH_DATA_WIDTH-1:0]       w_fifo_dmac_hash_addr               ;       
wire        [HASH_DATA_WIDTH-1:0]       w_fifo_smac_hash_addr               ;
wire        [PORT_NUM_BIT-1:0]          w_fifo_rx_port                      ;

// 寄存器相关信号  
reg                                     r_reg_bus_we                        ;
reg         [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_addr                      ;
reg         [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_data                      ;
reg                                     r_reg_bus_data_vld                  ;

// 寄存器读控制信号
reg                                     r_reg_bus_re                        ;
reg         [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_raddr                     ;
reg         [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_rdata                     ;
reg                                     r_reg_bus_rdata_vld                 ;

// 输出寄存器
reg                                     r_dmac_lookup_vld                   ;
reg         [PORT_NUM-1:0]              r_dmac_tx_port                      ;             
reg                                     r_dmac_lookup_hit                   ;
reg                                     r_lookup_clash                      ; // 查表冲突标志寄存器

// 状态机相关
reg         [3:0]                       r_fsm_cur_state                     ;
reg         [3:0]                       r_fsm_nxt_state                     ;
reg         [15:0]                      r_state_cnt                         ; // 状态计数器，计数每个状态保持时间

// MAC表存储器接口
reg         [HASH_DATA_WIDTH-1:0]       r_mac_table_addr                    ;
reg         [ENTRY_WIDTH-1:0]           r_mac_table_wdata                   ;
wire        [ENTRY_WIDTH-1:0]           w_mac_table_rdata                   ;
reg                                     r_mac_table_we                      ;
reg                                     r_mac_table_re                      ;


// 配置寄存器
reg         [AGE_TIME_WIDTH-1:0]        r_age_time_threshold                ; // 老化时间阈值（默认300秒）
reg                                     r_table_clear_req                   ; // 表清空请求
reg         [14:0]                      r_table_full_threshold              ; // MAC表满阈值配置寄存器
reg         [31:0]                      r_age_scan_interval                 ; // 老化扫描间隔配置寄存器（秒）

// 统计寄存器
reg         [31:0]                      r_learn_success_cnt               ; // 学习成功计数器
reg         [31:0]                      r_learn_fail_cnt                  ; // 学习失败计数器
reg         [31:0]                      r_collision_cnt                   ; // 哈希冲突计数器
reg         [31:0]                      r_port_move_cnt                   ; // 端口移动计数器

// 表项计数相关
reg         [14:0]                      r_table_entry_cnt                   ; // MAC表有效表项计数器（最大32768）
reg                                     r_entry_add                         ; // 表项添加标志
reg                                     r_entry_del                         ; // 表项删除标志
wire                                    w_table_full                        ; // 表满状态信号
wire                                    w_age_scan_trigger                  ; // 老化扫描触发信号

// 老化相关信号
reg                                     r_age_scan_en                       ; // 老化扫描使能
reg                                     r_age_timer_pulse                   ; // 老化定时器脉冲（1秒脉冲）
reg         [AGE_TIME_WIDTH-1:0]        r_global_timestamp                  ; // 全局时间戳计数器（秒）
reg         [7:0]                       r_clear_burst_cnt                   ; // 清表突发计数器，限制连续清表操作数
reg                                     r_agescan_cnt                       ; // 老化地址保持计数器
reg         [HASH_DATA_WIDTH-1:0]       r_age_scan_breakpoint               ; // 老化扫描断点地址

// 分级时间计数器相关信号
reg         [15:0]                      r_us_cnt                            ; // 微秒计数器（1-65535us，支持不同时钟频率）
reg         [9:0]                       r_ms_cnt                            ; // 毫秒计数器
reg         [31:0]                      r_s_cnt                             ; // 毫秒总计数器（用于内部1秒脉冲生成）
reg         [31:0]                      r_age_scan_timer                    ; // 老化扫描间隔计数器（秒）
reg                                     r_us_pulse                          ;  
reg                                     r_ms_pulse                          ;  

// 时间计算 - 支持仿真模式和正常模式
localparam  US_CNT_MAX                  = SIM_MODE ? 16'd5 : CLK_FREQ_MHZ   ; // 仿真模式：10个时钟周期=1us，正常模式：CLK_FREQ_MHZ个时钟周期=1us
localparam  MS_CNT_MAX                  = SIM_MODE ? 10'd5 : 10'd1000       ; // 仿真模式：10us=1ms，正常模式：1000us=1ms  
localparam  S_CNT_MAX                   = SIM_MODE ? 10'd5 : 10'd1000       ; // 仿真模式：10ms=1s，正常模式：1000ms=1s  
localparam  CLEAR_BURST_LIMIT           = 8'd16                             ; // 清表突发限制：连续清除16个地址后让位给数据包处理  

// 表项解析信号
wire                                    w_entry_valid                       ; // 表项有效标志
wire        [AGE_TIME_WIDTH-1:0]        w_entry_age_time                    ; // 表项老化时间
wire        [VLAN_ID_WIDTH-1:0]         w_entry_vlan_id                     ; // 表项VLAN ID
wire        [PORT_NUM-1:0]              w_entry_port                        ; // 表项端口号（one-hot编码）
wire        [MAC_ADDR_WIDTH-1:0]        w_entry_mac                         ; // 表项MAC地址

// 查表匹配信号
wire                                    w_dmac_match                        ; // DMAC匹配
wire                                    w_smac_match                        ; // SMAC匹配
wire                                    w_smac_port_match                   ; // SMAC端口匹配
wire                                    w_entry_expired                     ; // 表项过期标志

/*---------------------------------------- 输入数据FIFO管理 -------------------------------------------*/
// 上升沿检测寄存器
reg                                     r_dmac_hash_vld_d1                  ; // DMAC哈希有效信号延迟一拍
reg                                     r_smac_hash_vld_d1                  ; // SMAC哈希有效信号延迟一拍
reg                                     r_entry_expired_flag                ;
// 上升沿检测逻辑
wire                                    w_dmac_hash_vld_posedge             ; // DMAC哈希有效上升沿
wire                                    w_smac_hash_vld_posedge             ; // SMAC哈希有效上升沿
wire                                    w_both_hash_valid                   ; // 两个hash都有效
wire                                    w_new_packet_arrival                ; // 新报文到达信号
wire                                    w_can_use_direct_path               ; // 可以使用直连路径信号
wire                                    w_fifo_dmac_hash_vld                ;
wire                                    w_fifo_smac_hash_vld                ;

assign w_dmac_hash_vld_posedge = i_dmac_hash_vld == 1'd1 && r_dmac_hash_vld_d1 == 1'd0 ? 1'd1 : 1'd0      ;
assign w_smac_hash_vld_posedge = i_smac_hash_vld == 1'd1 && r_smac_hash_vld_d1 == 1'd0 ? 1'd1 : 1'd0      ;
assign w_both_hash_valid = w_dmac_hash_vld_posedge == 1'd1 && w_smac_hash_vld_posedge == 1'd1 ? 1'd1 : 1'd0;
assign w_new_packet_arrival = w_both_hash_valid;

// 综合FIFO状态信号
assign w_all_fifo_full = (w_fifo1_full == 1'd1) || (w_fifo2_full == 1'd1) || (w_fifo3_full == 1'd1) || (w_fifo4_full == 1'd1) || (w_fifo5_full == 1'd1);
assign w_all_fifo_empty = (w_fifo1_empty == 1'd1) && (w_fifo2_empty == 1'd1) && (w_fifo3_empty == 1'd1) && (w_fifo4_empty == 1'd1) && (w_fifo5_empty == 1'd1);

// 直连路径判断：FIFO为空且模块空闲时可以直接处理
assign w_can_use_direct_path = w_new_packet_arrival == 1'd1 && w_all_fifo_empty == 1'd1 && (r_fsm_cur_state == IDLE) && r_table_clear_req == 1'd0 && r_age_scan_en == 1'd0 
                               ? 1'd1 : 1'd0;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_dmac_hash_vld_d1 <= 1'b0;
        r_smac_hash_vld_d1 <= 1'b0;
    end else begin
        r_dmac_hash_vld_d1 <= i_dmac_hash_vld;
        r_smac_hash_vld_d1 <= i_smac_hash_vld;
    end
end

// 5个分离FIFO的数据打包：将输入信号分别写入对应的FIFO
assign w_fifo1_din = {i_vlan_id, i_rx_port};                         // VLAN_ID + RX_PORT
assign w_fifo2_din = i_dmac;                                         // DMAC
assign w_fifo3_din = i_smac;                                         // SMAC
assign w_fifo4_din = {i_dmac_hash_addr, i_dmac_hash_vld};           // DMAC_HASH_ADDR + DMAC_HASH_VLD
assign w_fifo5_din = {i_smac_hash_addr, i_smac_hash_vld};           // SMAC_HASH_ADDR + SMAC_HASH_VLD

// 5个FIFO的写使能：同时写入，只有当所有FIFO都不满时才写入
assign w_fifo1_wr_en = (w_dmac_hash_vld_posedge == 1'd1) && (w_smac_hash_vld_posedge == 1'd1) && (w_all_fifo_full == 1'd0) && (w_can_use_direct_path == 1'd0);
assign w_fifo2_wr_en = w_fifo1_wr_en;
assign w_fifo3_wr_en = w_fifo1_wr_en;
assign w_fifo4_wr_en = w_fifo1_wr_en;
assign w_fifo5_wr_en = w_fifo1_wr_en;

// 从5个FIFO输出数据中解析各个字段
assign w_fifo_vlan_id = w_fifo1_dout[FIFO1_WIDTH-1:PORT_NUM_BIT];
assign w_fifo_rx_port = w_fifo1_dout[PORT_NUM_BIT-1:0];
assign w_fifo_dmac = w_fifo2_dout;
assign w_fifo_smac = w_fifo3_dout;
assign w_fifo_dmac_hash_addr = w_fifo4_dout[FIFO4_WIDTH-1:1];

assign w_fifo_dmac_hash_vld = w_fifo4_dout[0];
assign w_fifo_smac_hash_addr = w_fifo5_dout[FIFO5_WIDTH-1:1];

assign w_fifo_smac_hash_vld = w_fifo5_dout[0];

// 5个FIFO的读使能：同时读取，只有当所有FIFO都不空时才读取
assign w_fifo1_rd_en = (r_fsm_cur_state == IDLE) && (w_all_fifo_empty == 1'd0) && (r_table_clear_req == 1'd0) && (r_age_scan_en == 1'd0) ? 1'd1 : 1'd0;
assign w_fifo2_rd_en = w_fifo1_rd_en;
assign w_fifo3_rd_en = w_fifo1_rd_en;
assign w_fifo4_rd_en = w_fifo1_rd_en;
assign w_fifo5_rd_en = w_fifo1_rd_en;


// 锁存FIFO输出的当前处理数据
reg         [VLAN_ID_WIDTH-1:0]         r_cur_vlan_id                       ;
reg         [MAC_ADDR_WIDTH-1:0]        r_cur_dmac                          ;
reg         [HASH_DATA_WIDTH-1:0]       r_cur_dmac_hash_addr                ;       
reg         [MAC_ADDR_WIDTH-1:0]        r_cur_smac                          ;
reg         [HASH_DATA_WIDTH-1:0]       r_cur_smac_hash_addr                ;
reg         [PORT_NUM_BIT-1:0]          r_cur_rx_port                       ;

// STD模式FIFO读使能延迟寄存器，用于正确的数据锁存时序
reg                                     r_fifo_rd_en_d1                     ; // 读使能延迟一拍

// STD模式读使能延迟逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_fifo_rd_en_d1 <= 1'b0;
    end else begin
        r_fifo_rd_en_d1 <= w_fifo1_rd_en;
    end
end

// 在读取FIFO或直连输入时锁存当前处理数据
// STD模式：在rd_en的下一个周期数据才有效，所以使用延迟的rd_en信号
always @(posedge i_clk) begin
    if (i_rst) begin
        r_cur_vlan_id       <= {VLAN_ID_WIDTH{1'b0}};
        r_cur_dmac          <= {MAC_ADDR_WIDTH{1'b0}};
        r_cur_dmac_hash_addr<= {HASH_DATA_WIDTH{1'b0}};
        r_cur_smac          <= {MAC_ADDR_WIDTH{1'b0}};
        r_cur_smac_hash_addr<= {HASH_DATA_WIDTH{1'b0}};
        r_cur_rx_port       <= {PORT_NUM_BIT{1'b0}};
    end else if (r_fifo_rd_en_d1 == 1'd1) begin  // 使用延迟的读使能信号
        r_cur_vlan_id       <= w_fifo_vlan_id;
        r_cur_dmac          <= w_fifo_dmac;
        r_cur_dmac_hash_addr<= w_fifo_dmac_hash_addr;
        r_cur_smac          <= w_fifo_smac;
        r_cur_smac_hash_addr<= w_fifo_smac_hash_addr;
        r_cur_rx_port       <= w_fifo_rx_port;
    end else if (w_can_use_direct_path == 1'd1) begin
        r_cur_vlan_id       <= i_vlan_id;
        r_cur_dmac          <= i_dmac;
        r_cur_dmac_hash_addr<= i_dmac_hash_addr;
        r_cur_smac          <= i_smac;
        r_cur_smac_hash_addr<= i_smac_hash_addr;
        r_cur_rx_port       <= i_rx_port;
    end
end

/*---------------------------------------- 5个分离sync_fifo实例化 -------------------------------------------*/
// FIFO1: VLAN_ID + RX_PORT
sync_fifo #(
    .DEPTH                 ( INPUT_FIFO_DEPTH       ),
    .WIDTH                 ( FIFO1_WIDTH            ),
    .ALMOST_FULL_THRESHOLD ( 1                      ),
    .ALMOST_EMPTY_THRESHOLD( 1                      ),
    .FLOP_DATA_OUT         ( 0                      )  
) u_fifo1_vlan_port (
    .CLK                   ( i_clk                  ),
    .RST                   ( i_rst                  ),
    .WR_EN                 ( w_fifo1_wr_en          ),
    .DIN                   ( w_fifo1_din            ),
    .FULL                  ( w_fifo1_full           ),
    .RD_EN                 ( w_fifo1_rd_en          ),
    .DOUT                  ( w_fifo1_dout           ),
    .EMPTY                 ( w_fifo1_empty          ),
    .ALMOST_FULL           (                        ),
    .ALMOST_EMPTY          (                        ),
    .DATA_CNT              (                        )
);

// FIFO2: DMAC
sync_fifo #(
    .DEPTH                 ( INPUT_FIFO_DEPTH       ),
    .WIDTH                 ( FIFO2_WIDTH            ),
    .ALMOST_FULL_THRESHOLD ( 1                      ),
    .ALMOST_EMPTY_THRESHOLD( 1                      ),
    .FLOP_DATA_OUT         ( 0                      )  
) u_fifo2_dmac (
    .CLK                   ( i_clk                  ),
    .RST                   ( i_rst                  ),
    .WR_EN                 ( w_fifo2_wr_en          ),
    .DIN                   ( w_fifo2_din            ),
    .FULL                  ( w_fifo2_full           ),
    .RD_EN                 ( w_fifo2_rd_en          ),
    .DOUT                  ( w_fifo2_dout           ),
    .EMPTY                 ( w_fifo2_empty          ),
    .ALMOST_FULL           (                        ),
    .ALMOST_EMPTY          (                        ),
    .DATA_CNT              (                        )
);

// FIFO3: SMAC  
sync_fifo #(
    .DEPTH                 ( INPUT_FIFO_DEPTH       ),
    .WIDTH                 ( FIFO3_WIDTH            ),
    .ALMOST_FULL_THRESHOLD ( 1                      ),
    .ALMOST_EMPTY_THRESHOLD( 1                      ),
    .FLOP_DATA_OUT         ( 0                      )  
) u_fifo3_smac (
    .CLK                   ( i_clk                  ),
    .RST                   ( i_rst                  ),
    .WR_EN                 ( w_fifo3_wr_en          ),
    .DIN                   ( w_fifo3_din            ),
    .FULL                  ( w_fifo3_full           ),
    .RD_EN                 ( w_fifo3_rd_en          ),
    .DOUT                  ( w_fifo3_dout           ),
    .EMPTY                 ( w_fifo3_empty          ),
    .ALMOST_FULL           (                        ),
    .ALMOST_EMPTY          (                        ),
    .DATA_CNT              (                        )
);

// FIFO4: DMAC_HASH_ADDR + DMAC_HASH_VLD
sync_fifo #(
    .DEPTH                 ( INPUT_FIFO_DEPTH       ),
    .WIDTH                 ( FIFO4_WIDTH            ),
    .ALMOST_FULL_THRESHOLD ( 1                      ),
    .ALMOST_EMPTY_THRESHOLD( 1                      ),
    .FLOP_DATA_OUT         ( 0                      )  
) u_fifo4_dmac_hash (
    .CLK                   ( i_clk                  ),
    .RST                   ( i_rst                  ),
    .WR_EN                 ( w_fifo4_wr_en          ),
    .DIN                   ( w_fifo4_din            ),
    .FULL                  ( w_fifo4_full           ),
    .RD_EN                 ( w_fifo4_rd_en          ),
    .DOUT                  ( w_fifo4_dout           ),
    .EMPTY                 ( w_fifo4_empty          ),
    .ALMOST_FULL           (                        ),
    .ALMOST_EMPTY          (                        ),
    .DATA_CNT              (                        )
);

// FIFO5: SMAC_HASH_ADDR + SMAC_HASH_VLD
sync_fifo #(
    .DEPTH                 ( INPUT_FIFO_DEPTH       ),
    .WIDTH                 ( FIFO5_WIDTH            ),
    .ALMOST_FULL_THRESHOLD ( 1                      ),
    .ALMOST_EMPTY_THRESHOLD( 1                      ),
    .FLOP_DATA_OUT         ( 0                      )  
) u_fifo5_smac_hash (
    .CLK                   ( i_clk                  ),
    .RST                   ( i_rst                  ),
    .WR_EN                 ( w_fifo5_wr_en          ),
    .DIN                   ( w_fifo5_din            ),
    .FULL                  ( w_fifo5_full           ),
    .RD_EN                 ( w_fifo5_rd_en          ),
    .DOUT                  ( w_fifo5_dout           ),
    .EMPTY                 ( w_fifo5_empty          ),
    .ALMOST_FULL           (                        ),
    .ALMOST_EMPTY          (                        ),
    .DATA_CNT              (                        )
);

/*---------------------------------------- 表项字段解析 -------------------------------------------*/
// 表项格式: [有效位[1] + 老化时间[AGE_TIME_WIDTH-1:0] + VLAN_ID[VLAN_ID_WIDTH-1:0] + 端口号[PORT_NUM-1:0] + MAC地址[MAC_ADDR_WIDTH-1:0]]
assign w_entry_valid    = w_mac_table_rdata[ENTRY_WIDTH-1]                                                                    ;
assign w_entry_age_time = w_mac_table_rdata[ENTRY_WIDTH-2:ENTRY_WIDTH-1-AGE_TIME_WIDTH]                                       ;  
assign w_entry_vlan_id  = w_mac_table_rdata[ENTRY_WIDTH-1-AGE_TIME_WIDTH-1:ENTRY_WIDTH-1-AGE_TIME_WIDTH-VLAN_ID_WIDTH]        ;
assign w_entry_port     = w_mac_table_rdata[PORT_NUM+MAC_ADDR_WIDTH-1:MAC_ADDR_WIDTH]                                         ;
assign w_entry_mac      = w_mac_table_rdata[MAC_ADDR_WIDTH-1:0]                                                               ;

/*---------------------------------------- 匹配逻辑 ----------------------------------------------*/
assign w_dmac_match     = (w_entry_valid == 1'd1 && (w_entry_mac == r_cur_dmac) && (w_entry_vlan_id == r_cur_vlan_id)) ? 1'd1 : 1'd0      ;
assign w_smac_match     = (w_entry_valid == 1'd1 && (w_entry_mac == r_cur_smac) && (w_entry_vlan_id == r_cur_vlan_id)) ? 1'd1 : 1'd0      ;
assign w_smac_port_match= (w_smac_match  == 1'd1 && (r_cur_rx_port < PORT_NUM) && (w_entry_port == ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_cur_rx_port))) ? 1'd1 : 1'd0 ;

// 老化检测逻辑：  当前时间戳减去表项时间戳的差值大于等于老化阈值时认为过期
assign w_entry_expired  = w_entry_valid == 1'd1 && (r_entry_expired_flag == 1'd1) ? 1'd1 : 1'd0 ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_entry_expired_flag <= 1'b0;
    end else begin
        r_entry_expired_flag <= (r_global_timestamp - w_entry_age_time) >= r_age_time_threshold ? 1'd1 : 1'd0;
    end
end
/*---------------------------------------- 表满检测逻辑 -------------------------------------------*/
assign w_table_full     = (r_table_entry_cnt >= r_table_full_threshold) ? 1'd1 : 1'd0                   ;

/*---------------------------------------- 老化扫描触发逻辑 -------------------------------------------*/
// 32bit分成4段比较，每段8bit
wire w_age_scan_flag0 ;
wire w_age_scan_flag1 ;
wire w_age_scan_flag2 ;
wire w_age_scan_flag3 ;

assign w_age_scan_flag0 = (r_age_scan_timer[7:0]   >= r_age_scan_interval[7:0]);
assign w_age_scan_flag1 = (r_age_scan_timer[15:8]  >= r_age_scan_interval[15:8]);
assign w_age_scan_flag2 = (r_age_scan_timer[23:16] >= r_age_scan_interval[23:16]);
assign w_age_scan_flag3 = (r_age_scan_timer[31:24] >= r_age_scan_interval[31:24]);

assign w_age_scan_trigger = (w_age_scan_flag0 == 1'd1 && w_age_scan_flag1 == 1'd1 && w_age_scan_flag2 == 1'd1 && w_age_scan_flag3 == 1'd1) && (r_table_entry_cnt > 15'd0) ? 1'd1 : 1'd0;

/*---------------------------------------- 输出赋值 -------------------------------------------*/
assign o_dmac_lookup_vld    = r_dmac_lookup_vld                                                           ;
assign o_dmac_tx_port       = r_dmac_tx_port                                                              ;
assign o_dmac_lookup_hit    = r_dmac_lookup_hit                                                           ;
assign o_lookup_clash       = r_lookup_clash                                                              ;
assign o_table_full         = w_table_full                                                                ;
assign o_reg_bus_rdata      = r_reg_bus_rdata                                                             ;
assign o_reg_bus_rdata_vld  = r_reg_bus_rdata_vld                                                         ;


/*======================================== 状态机  ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_fsm_cur_state <= IDLE;
    end else begin
        r_fsm_cur_state <= r_fsm_nxt_state;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_state_cnt <= 16'd0;
    end else if (r_fsm_cur_state != r_fsm_nxt_state) begin
        r_state_cnt <= 16'd0;
    end else begin
        r_state_cnt <= r_state_cnt + 1'b1;  
    end
end

always @(*) begin
    r_fsm_nxt_state = r_fsm_cur_state;   
    case (r_fsm_cur_state)
        IDLE: 
            r_fsm_nxt_state = (r_table_clear_req == 1'd1) ? AGE_SCAN :       // 清表优先级最高
                              // 检查FIFO是否有数据可处理或有直连数据可用
                              (w_can_use_direct_path == 1'd1) ? DMAC_LOOKUP :  // 直连路径跳过等待状态
                              (w_all_fifo_empty == 1'd0) ? FIFO_READ_WAIT :    // STD模式需要等待数据准备
                              (r_age_scan_en == 1'd1) ? AGE_SCAN :             // 老化扫描
                              IDLE;
        FIFO_READ_WAIT:   // STD模式FIFO读取等待状态
            r_fsm_nxt_state = DMAC_LOOKUP;                                    // 等待一个周期后数据准备好，进入查表
        DMAC_LOOKUP:   
            r_fsm_nxt_state = (r_state_cnt == 16'd1) ? 
                              (w_dmac_match == 1'd1) ? DMAC_REFRESH : SMAC_LEARN_CHECK : // 匹配则刷新老化时间 ，然后学习SMAC
                              DMAC_LOOKUP;                                            
        DMAC_REFRESH: 
            r_fsm_nxt_state = SMAC_LEARN_CHECK;                     // 刷新完成，进入SMAC学习        
        SMAC_LEARN_CHECK: 
            r_fsm_nxt_state = ((w_smac_match == 1'd1) || ((w_entry_valid == 1'd0) && (w_table_full == 1'd0))) ? SMAC_LEARN_UPDATE :  // SMAC+VLAN匹配或空表项可学习
                              IDLE;                                  // 哈希冲突（MAC+VLAN不匹配）或表已满，返回空闲        
        SMAC_LEARN_UPDATE: 
            r_fsm_nxt_state = (r_state_cnt == 16'd1) ? IDLE : SMAC_LEARN_UPDATE;   // 等待1个时钟周期让RAM数据稳定后返回IDLE        
        AGE_SCAN: 
            r_fsm_nxt_state = (r_mac_table_addr == {HASH_DATA_WIDTH{1'b1}}) ? IDLE :    // 扫描完成（包括清表完成）
                              ((w_all_fifo_empty == 1'd0) && ((r_table_clear_req == 1'd0) || (r_clear_burst_cnt >= CLEAR_BURST_LIMIT))) ? IDLE : // 有报文等待且(非清表模式 或 已达到突发限制)时才优先处理报文
                              ((w_entry_valid == 1'd1) && (w_entry_expired == 1'd1) && (r_table_clear_req == 1'd0) && (r_state_cnt >= 16'd1)) ? AGE_UPDATE :    // 需要老化更新（非清表模式），确保数据稳定
                              AGE_SCAN;                                              // 继续扫描下一个地址        
        AGE_UPDATE: 
            r_fsm_nxt_state = (r_mac_table_addr == {HASH_DATA_WIDTH{1'b1}}) ? IDLE :  // 扫描完成
                              ((w_all_fifo_empty == 1'd0) && ((r_table_clear_req == 1'd0) || (r_clear_burst_cnt >= CLEAR_BURST_LIMIT))) ? IDLE : // 有报文等待且(非清表模式 或 已达到突发限制)时才优先处理报文
                              AGE_SCAN;                                                // 老化更新完成，继续扫描        
        default: 
            r_fsm_nxt_state = IDLE;
    endcase
end

/*========================================  输入数据管理 ========================================*/
// FIFO输入缓存管理：支持连续输入而不会覆盖正在处理的数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_we          <= 1'b0;
        r_reg_bus_addr        <= {REG_ADDR_BUS_WIDTH{1'b0}};
        r_reg_bus_data        <= {REG_DATA_BUS_WIDTH{1'b0}};
        r_reg_bus_data_vld    <= 1'b0;
        r_reg_bus_re          <= 1'b0;
        r_reg_bus_raddr       <= {REG_ADDR_BUS_WIDTH{1'b0}};
    end else begin
        r_reg_bus_we       <= i_reg_bus_we;
        r_reg_bus_addr     <= i_reg_bus_addr;
        r_reg_bus_data     <= i_reg_bus_data;
        r_reg_bus_data_vld <= i_reg_bus_data_vld;
        r_reg_bus_re       <= i_reg_bus_re;
        r_reg_bus_raddr    <= i_reg_bus_raddr;
    end
end

/*======================================== 配置寄存器管理 ========================================*/
// 老化时间阈值配置寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_time_threshold <= 10'd300;
    end else if(SIM_MODE == 1) begin
        r_age_time_threshold <= 10'd3;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_AGE_TIME_THRESHOLD)) begin
        r_age_time_threshold <= r_reg_bus_data[AGE_TIME_WIDTH-1:0];
    end
end

// 表清空请求寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_clear_req <= 1'b0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_TABLE_CLEAR)) begin
        r_table_clear_req <= r_reg_bus_data[0];
    end else if ((r_table_clear_req == 1'd1) && (r_mac_table_addr == {HASH_DATA_WIDTH{1'b1}}) && (r_fsm_cur_state == AGE_SCAN)) begin
        r_table_clear_req <= 1'b0;
    end
end

// 表满阈值配置寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_full_threshold <= TABLE_FULL_THRESHOLD;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_TABLE_FULL_THRESHOLD)) begin
        r_table_full_threshold <= r_reg_bus_data[14:0];
    end
end

// 老化扫描间隔配置寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_scan_interval <= AGE_SCAN_INTERVAL;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_AGE_SCAN_INTERVAL)) begin
        r_age_scan_interval <= {{16{1'b0}}, r_reg_bus_data};
    end
end

/*======================================== 统计计数器管理 ========================================*/
// MAC学习成功统计计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_learn_success_cnt <= 32'd0;
    end else if (r_table_clear_req == 1'd1) begin
        r_learn_success_cnt <= 32'd0;
    end else if ((r_fsm_cur_state == SMAC_LEARN_UPDATE) && (r_state_cnt == 16'd1)) begin
        if ((w_smac_match == 1'd1) || ((w_entry_valid == 1'd0) && (r_cur_rx_port < PORT_NUM) && (w_table_full == 1'd0))) begin
            r_learn_success_cnt <= r_learn_success_cnt + 1'b1;
        end
    end
end

// MAC学习失败统计计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_learn_fail_cnt <= 32'd0;
    end else if (r_table_clear_req == 1'd1) begin
        r_learn_fail_cnt <= 32'd0;
    end else if ((r_fsm_cur_state == SMAC_LEARN_UPDATE) && (r_state_cnt == 16'd1)) begin
        if (((w_entry_valid == 1'd1) && (w_smac_match == 1'd0)) || ((w_entry_valid == 1'd0) && (w_table_full == 1'd1)) || (r_cur_rx_port >= PORT_NUM)) begin
            r_learn_fail_cnt <= r_learn_fail_cnt + 1'b1;
        end
    end else if (r_fsm_cur_state == SMAC_LEARN_CHECK) begin
        if ((w_entry_valid == 1'd0) && (w_table_full == 1'd1)) begin
            r_learn_fail_cnt <= r_learn_fail_cnt + 1'b1;
        end
    end
end

// 哈希冲突统计计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_collision_cnt <= 32'd0;
    end else if (r_table_clear_req) begin
        r_collision_cnt <= 32'd0;
    end else if (r_fsm_cur_state == DMAC_LOOKUP && r_state_cnt == 16'd1 && w_entry_valid == 1'd1 && w_dmac_match == 1'd0) begin
        r_collision_cnt <= r_collision_cnt + 1'b1;
    end else if (r_fsm_cur_state == SMAC_LEARN_UPDATE && r_state_cnt == 16'd1 && w_entry_valid == 1'd1 && w_smac_match == 1'd0) begin
        r_collision_cnt <= r_collision_cnt + 1'b1;
    end
end

// 端口移动统计计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_move_cnt <= 32'd0;
    end else if (r_table_clear_req) begin
        r_port_move_cnt <= 32'd0;
    end else if (r_fsm_cur_state == SMAC_LEARN_UPDATE && r_state_cnt == 16'd1) begin
        if (w_smac_match == 1'd1 && (r_cur_rx_port < PORT_NUM) && 
            (w_entry_port != ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_cur_rx_port))) begin
            r_port_move_cnt <= r_port_move_cnt + 1'b1;
        end
    end
end

/*======================================== 表项计数器管理 ========================================*/
// 表项计数器 - 跟踪有效MAC表项数量，防止下溢和上溢
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_entry_cnt <= 15'd0;
    end else if (r_table_clear_req) begin
        r_table_entry_cnt <= 15'd0;
    end else if (r_entry_add == 1'd1 && r_entry_del == 1'd0) begin
        if (r_table_entry_cnt < 15'h7FFF) begin  
            r_table_entry_cnt <= r_table_entry_cnt + 1'b1;  
        end
    end else if (r_entry_add == 1'd0 && r_entry_del == 1'd1) begin
        if (r_table_entry_cnt > 15'd0) begin  
            r_table_entry_cnt <= r_table_entry_cnt - 1'b1; 
        end
    end
end

/*======================================== 寄存器读控制逻辑 ========================================*/
// 寄存器读数据逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else if (r_reg_bus_re) begin
        case (r_reg_bus_raddr)
            REG_AGE_TIME_THRESHOLD: begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-AGE_TIME_WIDTH){1'b0}}, r_age_time_threshold};
            end
            REG_TABLE_CLEAR: begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}}, r_table_clear_req};
            end
            REG_TABLE_FULL_THRESHOLD: begin
                if (REG_DATA_BUS_WIDTH >= 15) begin
                    r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-15){1'b0}}, r_table_full_threshold};
                end else begin
                    r_reg_bus_rdata <= r_table_full_threshold[REG_DATA_BUS_WIDTH-1:0];
                end
            end
            REG_AGE_SCAN_INTERVAL: begin
                if (REG_DATA_BUS_WIDTH >= 32) begin
                    r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-32){1'b0}}, r_age_scan_interval};
                end else begin
                    r_reg_bus_rdata <= r_age_scan_interval[REG_DATA_BUS_WIDTH-1:0];
                end
            end
            REG_TABLE_ENTRY_cnt: begin
                if (REG_DATA_BUS_WIDTH >= 15) begin
                    r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-15){1'b0}}, r_table_entry_cnt};
                end else begin
                    r_reg_bus_rdata <= r_table_entry_cnt[REG_DATA_BUS_WIDTH-1:0];
                end
            end
            REG_LEARN_STATISTICS: begin
                r_reg_bus_rdata <= {r_learn_success_cnt[15:0]};
            end
            REG_COLLISION_STATISTICS: begin
                r_reg_bus_rdata <= r_collision_cnt[REG_DATA_BUS_WIDTH-1:0];
            end
            REG_PORT_MOVE_STATISTICS: begin
                r_reg_bus_rdata <= r_port_move_cnt[REG_DATA_BUS_WIDTH-1:0];
            end
            default: begin
                r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
            end
        endcase
    end else begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end
end

// 寄存器读数据有效标志
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata_vld <= 1'b0;
    end else begin
        r_reg_bus_rdata_vld <= r_reg_bus_re;
    end
end

/*======================================== 时间计数器 ========================================*/
// 微秒计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_us_cnt <= 16'd0;
    end else if (r_us_cnt >= US_CNT_MAX - 1) begin
        r_us_cnt <= 16'd0;
    end else begin
        r_us_cnt <= r_us_cnt + 1'b1;
    end
end

// 微秒脉冲信号生成  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_us_pulse <= 1'b0;
    end else begin
        r_us_pulse <= (r_us_cnt == US_CNT_MAX - 1);
    end
end
// 毫秒计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_ms_cnt <= 10'd0;
    end else if (r_us_pulse) begin
        if (r_ms_cnt >= MS_CNT_MAX - 1) begin
            r_ms_cnt <= 10'd0;
        end else begin
            r_ms_cnt <= r_ms_cnt + 1'b1;
        end
    end
end

// 毫秒脉冲信号生成  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_ms_pulse <= 1'b0;
    end else begin
        r_ms_pulse <= r_us_pulse == 1'd1 && (r_ms_cnt == MS_CNT_MAX - 1) ? 1'd1 : 1'd0;
    end
end

// 毫秒总计数器 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_s_cnt <= 32'd0;
    end else if (r_ms_pulse) begin
        if (r_s_cnt >= S_CNT_MAX - 1) begin
            r_s_cnt <= 32'd0;
        end else begin
            r_s_cnt <= r_s_cnt + 1'b1;
        end
    end
end

// 1秒脉冲信号生成  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_timer_pulse <= 1'b0;
    end else begin
        r_age_timer_pulse <= r_ms_pulse == 1'd1 && (r_s_cnt == S_CNT_MAX - 1) ? 1'd1 : 1'd0;
    end
end

// 全局时间戳计数器  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_global_timestamp <= {AGE_TIME_WIDTH{1'b0}};
    end else if (r_age_timer_pulse) begin
        r_global_timestamp <= r_global_timestamp + 1'b1;
    end
end

// 老化扫描间隔计数器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_scan_timer <= 32'd0;
    end else if (w_age_scan_trigger) begin
        r_age_scan_timer <= 32'd0;
    end else if (r_age_timer_pulse) begin
        r_age_scan_timer <= r_age_scan_timer + 1'b1;
    end
end

/*======================================== 清表突发控制逻辑 ========================================*/
// 清表突发计数器 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_clear_burst_cnt <= 8'd0;
    end else if (r_fsm_cur_state != AGE_SCAN || r_table_clear_req == 1'd0) begin
        r_clear_burst_cnt <= 8'd0;
    end else if (r_fsm_cur_state == AGE_SCAN && r_table_clear_req == 1'd1) begin
        if (r_clear_burst_cnt < CLEAR_BURST_LIMIT) begin
            r_clear_burst_cnt <= r_clear_burst_cnt + 1'b1;
        end
    end
end

/*======================================== 老化扫描地址管理 ========================================*/
// 老化扫描断点地址控制
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_scan_breakpoint <= {HASH_DATA_WIDTH{1'b0}};
    end else if (r_fsm_cur_state == AGE_SCAN && r_fsm_nxt_state == IDLE && r_mac_table_addr != {HASH_DATA_WIDTH{1'b1}}) begin
        r_age_scan_breakpoint <= r_mac_table_addr;  // 被打断时保存当前地址
    end else if (r_mac_table_addr == {HASH_DATA_WIDTH{1'b1}}) begin
        r_age_scan_breakpoint <= {HASH_DATA_WIDTH{1'b0}};  // 扫描完成时重置断点
    end
end

// 老化扫描使能信号 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_scan_en <= 1'b0;
    end else if (r_mac_table_addr == {HASH_DATA_WIDTH{1'b1}}) begin
        r_age_scan_en <= 1'b0;
    end else if (w_age_scan_trigger) begin
        r_age_scan_en <= 1'b1;
    end
end

/*======================================== MAC表存储器访问控制 ========================================*/
// MAC表地址控制  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_mac_table_addr <= {HASH_DATA_WIDTH{1'b0}};
    end else begin
        case (r_fsm_cur_state)
            IDLE: begin
                if (w_can_use_direct_path == 1'd1) begin
                    r_mac_table_addr <= i_dmac_hash_addr;  // 直连路径可以立即使用
                end else if (w_all_fifo_empty == 1'd0) begin
                    // STD模式：不能立即使用FIFO输出，需要等读取后再在FIFO_READ_WAIT状态设置
                    r_mac_table_addr <= {HASH_DATA_WIDTH{1'b0}};  // 先清零
                end else begin
                    r_mac_table_addr <= {HASH_DATA_WIDTH{1'b0}};
                end
            end
            FIFO_READ_WAIT: begin  // 在此状态设置从锁存数据中获取的地址
                r_mac_table_addr <= r_cur_dmac_hash_addr;  // 使用已锁存的数据
            end
            DMAC_LOOKUP: begin
                r_mac_table_addr <= r_cur_dmac_hash_addr;  // 使用已锁存的数据
            end
            DMAC_REFRESH: begin
                r_mac_table_addr <= r_cur_smac_hash_addr;
            end
            SMAC_LEARN_CHECK, SMAC_LEARN_UPDATE: begin
                r_mac_table_addr <= r_cur_smac_hash_addr;
            end
            AGE_SCAN, AGE_UPDATE: begin
                if (r_fsm_cur_state == IDLE && (r_fsm_nxt_state == AGE_SCAN)) begin
                    r_mac_table_addr <= r_age_scan_breakpoint;  // 从断点恢复或从0开始
                end else if (r_fsm_cur_state == AGE_SCAN) begin
                    if (r_table_clear_req == 1'd1) begin
                        if (r_mac_table_addr != {HASH_DATA_WIDTH{1'b1}}) begin
                            r_mac_table_addr <= r_mac_table_addr + 1'b1;
                        end
                    end else begin
                        if (r_fsm_nxt_state == AGE_UPDATE) begin
                            r_mac_table_addr <= r_mac_table_addr;
                        end else if ((r_mac_table_addr != {HASH_DATA_WIDTH{1'b1}}) && (r_agescan_cnt == 1'd1)) begin
                            r_mac_table_addr <= r_mac_table_addr + 1'b1;
                        end
                    end
                end else if (r_fsm_cur_state == AGE_UPDATE) begin
                    if (r_fsm_nxt_state == AGE_SCAN) begin
                        if (r_mac_table_addr != {HASH_DATA_WIDTH{1'b1}}) begin
                            r_mac_table_addr <= r_mac_table_addr + 1'b1;
                        end
                    end else begin
                        r_mac_table_addr <= r_mac_table_addr;
                    end
                end
            end
            default: begin
                r_mac_table_addr <= {HASH_DATA_WIDTH{1'b0}};
            end
        endcase
    end
end

// 让AGE_SCNA时都地址状态保持两拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_agescan_cnt <= 1'd0;
    end else if (r_mac_table_re == 1'd1 && r_fsm_cur_state == AGE_SCAN) begin
        r_agescan_cnt <= r_agescan_cnt == 1'd0 ? 1'd1 : 1'd0;
    end else begin
        r_agescan_cnt <= 1'd0;
    end
end

// MAC表读使能控制  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_mac_table_re <= 1'b0;
    end else begin
        case (r_fsm_cur_state)
            IDLE: begin
                r_mac_table_re <= ((w_can_use_direct_path == 1'd1) || (w_all_fifo_empty == 1'd0)) && (r_table_clear_req == 1'd0) && (r_age_scan_en == 1'd0) ? 1'd1 : 1'd0;
            end
            FIFO_READ_WAIT: begin  // FIFO读取等待状态，启动RAM读取
                r_mac_table_re <= 1'b1;
            end
            DMAC_LOOKUP, SMAC_LEARN_CHECK: begin
                r_mac_table_re <= 1'b1;
            end
            DMAC_REFRESH: begin
                r_mac_table_re <= 1'b0;
            end
            SMAC_LEARN_UPDATE: begin
                r_mac_table_re <= 1'b0;
            end
            AGE_SCAN: begin
                if ((r_table_clear_req == 1'd1) && (r_fsm_nxt_state == AGE_UPDATE)) begin
                    r_mac_table_re <= 1'b0;
                end else if(((r_state_cnt == 1'd0) || !((w_entry_valid == 1'd1) && (w_entry_expired == 1'd1)))  )begin
                    r_mac_table_re <= 1'b1;
                end else begin
                    r_mac_table_re <= 1'b0;
                end
            end
            AGE_UPDATE: begin
                r_mac_table_re <= 1'b1;
            end
            default: begin
                r_mac_table_re <= 1'b0;
            end
        endcase
    end
end

// MAC表写使能控制  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_mac_table_we <= 1'b0;
    end else begin
        case (r_fsm_cur_state)
            DMAC_REFRESH: begin
                r_mac_table_we <= 1'b1;
            end
            SMAC_LEARN_UPDATE: begin
                if (r_state_cnt == 16'd1) begin
                    r_mac_table_we <= (w_smac_match || (w_entry_valid == 1'd0 && (r_cur_rx_port < PORT_NUM) && w_table_full == 1'd0));
                end else begin
                    r_mac_table_we <= 1'b0;  
                end
            end
            AGE_SCAN: begin
                if (r_table_clear_req) begin
                    r_mac_table_we <= 1'b1;
                end else begin
                    r_mac_table_we <= r_fsm_nxt_state == AGE_UPDATE ? 1'b1 : 1'b0;
                end
            end
            AGE_UPDATE: begin
                r_mac_table_we <= 1'b0;
            end
            default: begin
                r_mac_table_we <= 1'b0;
            end
        endcase
    end
end

// MAC表写数据控制 - 使用当前处理的缓存数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_mac_table_wdata <= {ENTRY_WIDTH{1'b0}};
    end else begin
        case (r_fsm_cur_state)
            DMAC_REFRESH: begin
                r_mac_table_wdata <= {w_entry_valid, r_global_timestamp, w_entry_vlan_id, 
                                    w_entry_port, w_entry_mac};
            end
            SMAC_LEARN_UPDATE: begin
                if (r_state_cnt == 16'd1) begin
                    if (w_smac_match) begin
                        if (w_smac_port_match) begin
                            r_mac_table_wdata <= {1'b1, r_global_timestamp, w_entry_vlan_id, 
                                                w_entry_port, w_entry_mac};
                        end else begin
                            r_mac_table_wdata <= {1'b1, 
                                                r_global_timestamp[AGE_TIME_WIDTH-1:0], 
                                                r_cur_vlan_id[VLAN_ID_WIDTH-1:0], 
                                                {{(PORT_NUM-1){1'b0}}, 1'b1} << r_cur_rx_port, 
                                                r_cur_smac[MAC_ADDR_WIDTH-1:0]};
                        end
                    end else if (w_entry_valid == 1'd0 && (r_cur_rx_port < PORT_NUM) && w_table_full == 1'd0) begin
                        r_mac_table_wdata <= {1'b1, 
                                            r_global_timestamp[AGE_TIME_WIDTH-1:0], 
                                            r_cur_vlan_id[VLAN_ID_WIDTH-1:0], 
                                            {{(PORT_NUM-1){1'b0}}, 1'b1} << r_cur_rx_port, 
                                            r_cur_smac[MAC_ADDR_WIDTH-1:0]};
                    end else begin  
                        r_mac_table_wdata <= w_mac_table_rdata;
                    end
                end else begin
                    r_mac_table_wdata <= r_mac_table_wdata;
                end
            end
            AGE_UPDATE: begin
                r_mac_table_wdata <= {ENTRY_WIDTH{1'b0}};
            end
            AGE_SCAN: begin
                if (r_table_clear_req) begin
                    r_mac_table_wdata <= {ENTRY_WIDTH{1'b0}};
                end else if (w_entry_valid == 1'd1 && w_entry_expired == 1'd1) begin
                    r_mac_table_wdata <= {ENTRY_WIDTH{1'b0}};
                end else begin
                    r_mac_table_wdata <= w_mac_table_rdata; 
                end
            end
            default: begin
                r_mac_table_wdata <= {ENTRY_WIDTH{1'b0}};
            end
        endcase
    end
end

/*======================================== 表项计数控制逻辑 ========================================*/
// 表项添加标志控制  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_entry_add <= 1'b0;
    end else if (r_fsm_cur_state == SMAC_LEARN_UPDATE && r_state_cnt == 16'd1 && 
                 w_entry_valid == 1'd0 && (r_cur_rx_port < PORT_NUM) && w_table_full == 1'd0) begin
        r_entry_add <= 1'b1;
    end else begin
        r_entry_add <= 1'b0;
    end
end

// 表项删除标志控制  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_entry_del <= 1'b0;
    end else if (r_fsm_cur_state == AGE_UPDATE && w_entry_valid == 1'd1 && w_entry_expired == 1'd1) begin
        r_entry_del <= 1'b1;
    end else if (r_fsm_cur_state == AGE_SCAN && r_table_clear_req == 1'd1 && w_entry_valid == 1'd1) begin
        r_entry_del <= 1'b1;
    end else begin
        r_entry_del <= 1'b0;
    end
end

/*======================================== 输出控制逻辑 ========================================*/
// DMAC查表结果有效标志  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_dmac_lookup_vld <= 1'b0;
    end else if (r_fsm_cur_state == DMAC_LOOKUP && r_state_cnt == 16'd1) begin
        r_dmac_lookup_vld <= 1'b1;
    end else begin
        r_dmac_lookup_vld <= 1'b0;
    end
end

// DMAC查表命中标志  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_dmac_lookup_hit <= 1'b0;
    end else if (r_fsm_cur_state == DMAC_LOOKUP && r_state_cnt == 16'd1) begin
        r_dmac_lookup_hit <= w_dmac_match;
    end else begin
        r_dmac_lookup_hit <= 1'b0;
    end
end

// DMAC转发端口  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_dmac_tx_port <= {PORT_NUM{1'b0}};
    end else if (r_fsm_cur_state == DMAC_LOOKUP && r_state_cnt == 16'd1) begin
        if (w_dmac_match) begin
            r_dmac_tx_port <= w_entry_port;
        end else begin
            r_dmac_tx_port <= {PORT_NUM{1'b0}};  // 未查到时直接输出0
        end
    end else begin
        r_dmac_tx_port <= {PORT_NUM{1'b0}};
    end
end

// 查表冲突检测逻辑  
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_lookup_clash <= 1'b0;
    end else if (r_fsm_cur_state == DMAC_LOOKUP && r_state_cnt == 16'd1) begin
        r_lookup_clash <= w_entry_valid == 1'd1 && w_dmac_match == 1'd0;
    end else begin
        r_lookup_clash <= 1'b0;
    end
end

/*======================================== MAC表存储 ========================================*/
ram_simple2port #(
    .RAM_WIDTH      (ENTRY_WIDTH                ),
    .RAM_DEPTH      (MAC_TABLE_DEPTH            ),
    .RAM_PERFORMANCE("LOW_LATENCY"              ), 
    .INIT_FILE      (                           )  
) u_mac_table_ram (
    .addra          (r_mac_table_addr           ),
    .addrb          (r_mac_table_addr           ),
    .dina           (r_mac_table_wdata          ), 
    .clka           (i_clk                      ), 
    .clkb           (i_clk                      ), 
    .wea            (r_mac_table_we             ), 
    .enb            (r_mac_table_re             ), 
    .rstb           (i_rst                     ), 
    .regceb         (1'b0                       ),
    .doutb          (w_mac_table_rdata          )  
);

endmodule