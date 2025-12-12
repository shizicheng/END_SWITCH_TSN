module ptp_reg_list#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地�?位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位�?
    parameter                                                   PORT_NUM                =      8 
)(
    input               wire                                    i_clk                            ,   // 250MHz
    input               wire                                    i_rst                            ,    

    input               wire   [PORT_NUM-1:0]                   i_channel_linkup                 , // 8个�?�道的link信号
    
    /*---------------------------------------- 和ptp模块交互 -----------------------------------------*/
    // 寄存器写控制接口     
    input               wire                                    i_ptp_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_ptp_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_ptp_reg_bus_we_din             , // 寄存器写数据
    input               wire                                    i_ptp_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口       
    input               wire                                    i_ptp_reg_bus_rd                 , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_ptp_reg_bus_rd_addr            , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_ptp_reg_bus_rd_dout            , // 读出寄存器数�?
    output              wire                                    o_ptp_reg_bus_rd_dout_v          , // 读数据有效使�?
    /*---------------------------------------- 上层配置寄存�? -----------------------------------------*/
    // 寄存器写控制接口     
    input               wire                                    i_switch_reg_bus_we              , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr         , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din          , // 寄存器写数据
    input               wire                                    i_switch_reg_bus_we_din_v        , // 寄存器写数据使能
    // 寄存器读控制接口       
    input               wire                                    i_switch_reg_bus_rd              , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr         , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_rd_dout         , // 读出寄存器数�?
    output              wire                                    o_switch_reg_bus_rd_dout_v       , // 读数据有效使�?
    // AS寄存�?
    output              wire   [63:0]                           o_init_local_clkid               , // 初始化本地时钟ID
    output              wire   [7:0]                            o_init_local_priority1           , // 初始化本地优先级1
    output              wire   [7:0]                            o_init_local_priority2           , // 初始化本地优先级2
    output              wire   [7:0]                            o_init_local_class               , // 初始化本地类
    output              wire   [7:0]                            o_init_local_accuracy            , // 初始化本地精�?
    output              wire   [15:0]                           o_init_local_variance            , // 初始化本地方�?
    output              wire   [7:0]                            o_init_local_timesource          , // 初始化本地时钟源
    output              wire   [7:0]                            o_init_local_domain              , // 初始化本地域
    output              wire   [7:0]                            o_init_ann_log                   , // 初始化广播日�?
    output              wire   [7:0]                            o_init_sync_log                  , // 初始化同步日�?
    output              wire   [7:0]                            o_init_dly_log                   , // 初始化延迟日�?
    output              wire   [7:0]                            o_init_pdly_log                  , // 初始化延迟日�?
    output              wire   [7:0]                            o_ptp_sync_lock_num              , // PTP同步锁数
    output              wire                                    o_init_two_syncflg               , // 初始化两个同步标�?
    output              wire                                    o_init_two_pdlyflg               , // 初始化两个延迟标�?
    output              wire   [31:0]                           o_freq_sync_thhold               , // 频率同步阈�??
    output              wire   [31:0]                           o_phase_sync_thhold              , // 相位同步阈�??
    output              wire   [7:0]                            o_freq_sync_num                  , // 频率同步�?
    output              wire   [7:0]                            o_phase_over_num                 , // 相位过载�?
    output              wire   [7:0]                            o_tot_mult_ann                   , // 总乘法广播数
    output              wire   [7:0]                            o_tot_mult_sync                  , // 总乘法同步数
    output              wire                                    o_sync_clk_type                  , // 同步时钟类型
    output              wire                                    o_ptp_local_vflg                 , // PTP本地标志
    output              wire   [7:0]                            o_local_clkutc_offset            , // 本地时钟UTC偏移
    output              wire   [7:0]                            o_dly_req_en                     , // 延迟请求使能
    output              wire   [47:0]                           o_init_local_mac                 , // 初始化本地MAC地址
    output              wire   [31:0]                           o_init_local_ip                  , // 初始化本地IP地址
    output              wire   [31:0]                           o_sync_work_cycle                , // 同步工作周期
    output              wire   [31:0]                           o_sync_phase_limit               , // 同步相位限制
    output              wire   [31:0]                           o_sync_freq_limit                , // 同步频率限制
    output              wire   [3:0]                            o_sync_protocol                  , // 同步协议
    output              wire                                    o_sync_en                        , // 同步使能
    output              wire   [63:0]                           o_sync_time_param                , // 同步时间参数
    output              wire   [31:0]                           o_sync_cycle_param               , // 同步周期参数
    output              wire   [15:0]                           o_sync_high_param                , // 同步高电�?
    output              wire                                    o_cip_sync_en                    , // CIP同步使能
    output              wire                                    o_fault_alarm_rd                 , // 故障报警�?
    output              wire                                    o_fault_alarm_io                 , // 故障报警输出


    input               wire    [63:0]                          i_ptp_master_clkid               ,
    input               wire    [79:0]                          i_ptp_master_sourceid            ,
    input               wire    [7:0]                           i_ptp_master_priority1           ,
    input               wire    [7:0]                           i_ptp_master_priority2           ,
    input               wire    [7:0]                           i_ptp_master_class               ,
    input               wire    [7:0]                           i_ptp_master_accuracy            ,
    input               wire    [15:0]                          i_ptp_master_variance            ,
    input               wire    [7:0]                           i_ptp_master_timesource          ,
    input               wire    [15:0]                          i_ptp_master_steps               ,
    input               wire    [7:0]                           i_ptp_master_domain              ,
    input               wire    [7:0]                           i_node_property                  ,
    input               wire    [7:0]                           i_ptp_protype                    ,
    input               wire    [7:0]                           i_ptp_slave                      ,
    input               wire    [7:0]                           i_ptp_passive                    ,
    input               wire    [7:0]                           i_ptp_sync_flg                   ,
    input               wire    [7:0]                           i_ptp_ann_log                    ,
    input               wire    [7:0]                           i_ptp_sync_log                   ,
    input               wire    [7:0]                           i_ptp_pdly_log                   ,
    input               wire    [7:0]                           i_ann_tc_cnt                     ,
    input               wire    [7:0]                           i_sync_tc_cnt                    ,
    input               wire    [7:0]                           i_ann_err_cnt                    ,
    input               wire    [7:0]                           i_sync_err_cnt                   ,
    input               wire    [7:0]                           i_dlyreq_err_cnt                 ,
    input               wire    [7:0]                           i_dlyresp_err_cnt                ,
    input               wire    [7:0]                           i_pdlyreq_err_cnt                ,
    input               wire    [7:0]                           i_pdlyresp_err_cnt               ,  
    input               wire    [7:0]                           i_pdlyrespf_err_cnt              ,
    input               wire    [7:0]                           i_master_chg_cnt                 ,
    input               wire    [31:0]                          i_ptp_line0_delay                ,
    input               wire    [31:0]                          i_ptp_line1_delay                ,
    input               wire    [31:0]                          i_ptp_line2_delay                ,
    input               wire    [31:0]                          i_ptp_line3_delay                ,
    input               wire    [31:0]                          i_ptp_line4_delay                ,
    input               wire    [31:0]                          i_ptp_line5_delay                ,
    input               wire    [31:0]                          i_ptp_line6_delay                ,
    input               wire    [31:0]                          i_ptp_line7_delay                ,
    input               wire    [15:0]                          i_fault_type                     ,
    input               wire    [15:0]                          i_alarm_type                     ,
    input               wire    [63:0]                          i_curr_sync_time                 
);

/*---------------------------------------- AS寄存器地�?定义 -------------------------------------------*/
localparam REG_INIT_LOCAL_CLKID0            = 8'h00;
localparam REG_INIT_LOCAL_CLKID1            = 8'h01;
localparam REG_INIT_LOCAL_CLKID2            = 8'h02;
localparam REG_INIT_LOCAL_CLKID3            = 8'h03;
localparam REG_INIT_LOCAL_PRIOR1            = 8'h04;
localparam REG_INIT_LOCAL_PRIOR2            = 8'h05;
localparam REG_INIT_LOCAL_CLASS             = 8'h06;
localparam REG_INIT_LOCAL_ACCURACY          = 8'h07;
localparam REG_INIT_LOCAL_VARIANCE          = 8'h08;
localparam REG_INIT_LOCAL_TIMESOURCE        = 8'h09;
localparam REG_INIT_LOCAL_DOMAIN            = 8'h0A;
localparam REG_INIT_ANN_LOG                 = 8'h0B;
localparam REG_INIT_SYNC_LOG                = 8'h0C;
localparam REG_INIT_DLY_LOG                 = 8'h0D;
localparam REG_INIT_PDLY_LOG                = 8'h0E;
localparam REG_PTP_SYNC_LOCK_NUM            = 8'h0F;
localparam REG_INIT_TWO_SYNCFLG             = 8'h10;
localparam REG_INIT_TWO_PDLYFLG             = 8'h11;
localparam REG_FREQ_SYNC_THHOLD0            = 8'h12;
localparam REG_FREQ_SYNC_THHOLD1            = 8'h13;
localparam REG_PHASE_SYNC_THHOLD0           = 8'h14;
localparam REG_PHASE_SYNC_THHOLD1           = 8'h15;
localparam REG_FREQ_SYNC_NUM                = 8'h16;
localparam REG_PHASE_OVER_NUM               = 8'h17;
localparam REG_TOT_MULT_ANN                 = 8'h18;
localparam REG_TOT_MULT_SYNC                = 8'h19;
localparam REG_SYNC_CLK_TYPE                = 8'h1A;
localparam REG_PTP_LOCAL_VFLG               = 8'h1B;
localparam REG_LOCAL_CLKUTC_OFFSET          = 8'h1C;
localparam REG_DLY_REQ_EN                   = 8'h1D;    
localparam REG_PTP_MASTER_CLKID0            = 8'h20;
localparam REG_PTP_MASTER_CLKID1            = 8'h21;
localparam REG_PTP_MASTER_CLKID2            = 8'h22;
localparam REG_PTP_MASTER_CLKID3            = 8'h23;
localparam REG_PTP_MASTER_SOURCEID0         = 8'h24;
localparam REG_PTP_MASTER_SOURCEID1         = 8'h25;
localparam REG_PTP_MASTER_SOURCEID2         = 8'h26;
localparam REG_PTP_MASTER_SOURCEID3         = 8'h27;
localparam REG_PTP_MASTER_SOURCEID4         = 8'h28;
localparam REG_PTP_MASTER_PRIORITY1         = 8'h29;
localparam REG_PTP_MASTER_PRIORITY2         = 8'h2A;
localparam REG_PTP_MASTER_CLASS             = 8'h2B;
localparam REG_PTP_MASTER_ACCURACY          = 8'h2C;
localparam REG_PTP_MASTER_TIMESOURCE        = 8'h2D;
localparam REG_PTP_MASTER_VARIANCE          = 8'h2E;
localparam REG_PTP_MASTER_STEPS             = 8'h2F;
localparam REG_PTP_MASTER_DOMAIN            = 8'h31;
localparam REG_NODE_PROPERTY                = 8'h40;
localparam REG_PTP_PROTYPE                  = 8'h41;
localparam REG_PTP_SLAVE                    = 8'h42;
localparam REG_PTP_PASSIVE                  = 8'h43;
localparam REG_PTP_SYNC_FLG                 = 8'h44;
localparam REG_PTP_ANN_LOG                  = 8'h45;
localparam REG_PTP_SYNC_LOG                 = 8'h46;
localparam REG_PTP_PDLY_LOG                 = 8'h47;
localparam REG_ANN_TC_CNT                   = 8'h50;
localparam REG_SYNC_TC_CNT                  = 8'h51;
localparam REG_ANN_ERR_CNT                  = 8'h52;
localparam REG_SYNC_ERR_CNT                 = 8'h53;
localparam REG_DLYREQ_ERR_CNT               = 8'h54;
localparam REG_DLYRESP_ERR_CNT              = 8'h55;
localparam REG_PDLYREQ_ERR_CNT              = 8'h56;
localparam REG_PDLYRESP_ERR_CNT             = 8'h57;
localparam REG_PDLYRESPF_ERR_CNT            = 8'h58;
localparam REG_MASTER_CHG_CNT               = 8'h59;
localparam REG_INIT_LOCAL_MAC0              = 8'h60;
localparam REG_INIT_LOCAL_MAC1              = 8'h61;
localparam REG_INIT_LOCAL_MAC2              = 8'h62;
localparam REG_INIT_LOCAL_IP0               = 8'h63;
localparam REG_INIT_LOCAL_IP1               = 8'h64;
localparam REG_PTP_LINE0_DELAY0             = 8'h70;
localparam REG_PTP_LINE0_DELAY1             = 8'h71;
localparam REG_PTP_LINE1_DELAY0             = 8'h72;
localparam REG_PTP_LINE1_DELAY1             = 8'h73;
localparam REG_PTP_LINE2_DELAY0             = 8'h74;
localparam REG_PTP_LINE2_DELAY1             = 8'h75;
localparam REG_PTP_LINE3_DELAY0             = 8'h76;
localparam REG_PTP_LINE3_DELAY1             = 8'h77;
localparam REG_PTP_LINE4_DELAY0             = 8'h78;
localparam REG_PTP_LINE4_DELAY1             = 8'h79;
localparam REG_PTP_LINE5_DELAY0             = 8'h7A;
localparam REG_PTP_LINE5_DELAY1             = 8'h7B;
localparam REG_PTP_LINE6_DELAY0             = 8'h7C;
localparam REG_PTP_LINE6_DELAY1             = 8'h7D;
localparam REG_PTP_LINE7_DELAY0             = 8'h7E;
localparam REG_PTP_LINE7_DELAY1             = 8'h7F;
localparam REG_SYNC_WORK_CYCLE0             = 8'h80;
localparam REG_SYNC_WORK_CYCLE1             = 8'h81;
localparam REG_SYNC_PHASE_LIMIT0            = 8'h82;
localparam REG_SYNC_PHASE_LIMIT1            = 8'h83;
localparam REG_SYNC_FREQ_LIMIT0             = 8'h84;
localparam REG_SYNC_FREQ_LIMIT1             = 8'h85;
localparam REG_SYNC_PROTOCOL                = 8'h90;
localparam REG_SYNC_EN                      = 8'h91;
localparam REG_SYNC_TIME_PARAM0             = 8'hA0;
localparam REG_SYNC_TIME_PARAM1             = 8'hA1;
localparam REG_SYNC_TIME_PARAM2             = 8'hA2;
localparam REG_SYNC_TIME_PARAM3             = 8'hA3;
localparam REG_SYNC_CYCLE_PARAM0            = 8'hA4;
localparam REG_SYNC_CYCLE_PARAM1            = 8'hA5;
localparam REG_SYNC_HIGH_PARAM              = 8'hA6;
localparam REG_CIP_SYNC_EN                  = 8'hA7;
localparam REG_FAULT_TYPE                   = 8'hA8;
localparam REG_ALARM_TYPE                   = 8'hA9;
localparam REG_CUR_SYNC_TIME0               = 8'hAA;
localparam REG_CUR_SYNC_TIME1               = 8'hAB;
localparam REG_CUR_SYNC_TIME2               = 8'hAC;
localparam REG_CUR_SYNC_TIME3               = 8'hAD;
localparam REG_FAULT_ALARM_RD               = 8'hAE;
localparam REG_FAULT_ALARM_IO               = 8'hAF;
/*------------------------------------------- 内部信号定义 -----------------------------------------------*/
/*------------------------------------------- 寄存器信号定�? ------------------------------------------*/
// 寄存器写控制信号  
reg                                         r_reg_bus_we                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_addr                      ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_data                      ;
reg                                         r_reg_bus_data_vld                  ;
// 寄存器读控制信号
reg                                         r_reg_bus_re                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_raddr                     ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_rdata                     ;
reg                                         r_reg_bus_rdata_vld                 ;
// AS寄存器定�?
reg             [63:0]                      r_init_local_clkid                  ; // 初始化本地时钟ID
reg             [7:0]                       r_init_local_priority1              ; // 初始化本地优先级1
reg             [7:0]                       r_init_local_priority2              ; // 初始化本地优先级2
reg             [7:0]                       r_init_local_class                  ; // 初始化本地类
reg             [7:0]                       r_init_local_accuracy               ; // 初始化本地精�?
reg             [15:0]                      r_init_local_variance               ; // 初始化本地方�?
reg             [7:0]                       r_init_local_timesource             ; // 初始化本地时钟源
reg             [7:0]                       r_init_local_domain                 ; // 初始化本地域
reg             [7:0]                       r_init_ann_log                      ; // 初始化广播日�?
reg             [7:0]                       r_init_sync_log                     ; // 初始化同步日�?
reg             [7:0]                       r_init_dly_log                      ; // 初始化延迟日�?
reg             [7:0]                       r_init_pdly_log                     ; // 初始化延迟日�?
reg             [7:0]                       r_ptp_sync_lock_num                 ; // PTP同步锁数
reg                                         r_init_two_syncflg                  ; // 初始化两个同步标�?
reg                                         r_init_two_pdlyflg                  ; // 初始化两个延迟标�?
reg             [31:0]                      r_freq_sync_thhold                  ; // 频率同步阈�??
reg             [31:0]                      r_phase_sync_thhold                 ; // 相位同步阈�??
reg             [7:0]                       r_freq_sync_num                     ; // 频率同步�?
reg             [7:0]                       r_phase_over_num                    ; // 相位过载�?
reg             [7:0]                       r_tot_mult_ann                      ; // 总乘法广播数
reg             [7:0]                       r_tot_mult_sync                     ; // 总乘法同步数
reg                                         r_sync_clk_type                     ; // 同步时钟类型
reg                                         r_ptp_local_vflg                    ; // PTP本地标志
reg             [7:0]                       r_local_clkutc_offset               ; // 本地时钟UTC偏移
reg             [7:0]                       r_dly_req_en                        ; // 延迟请求使能
reg             [47:0]                      r_init_local_mac                    ; // 初始化本地MAC地址
reg             [31:0]                      r_init_local_ip                     ; // 初始化本地IP地址
reg             [31:0]                      r_sync_work_cycle                   ; // 同步工作周期
reg             [31:0]                      r_sync_phase_limit                  ; // 同步相位限制
reg             [31:0]                      r_sync_freq_limit                   ; // 同步频率限制
reg             [3:0]                       r_sync_protocol                     ; // 同步协议
reg                                         r_sync_en                           ; // 同步使能
reg             [63:0]                      r_sync_time_param                   ; // 同步时间参数
reg             [31:0]                      r_sync_cycle_param                  ; // 同步周期参数
reg             [15:0]                      r_sync_high_param                   ; // 同步高电�?
reg                                         r_cip_sync_en                       ; // CIP同步使能
reg                                         r_fault_alarm_rd                    ; // 故障报警�?
reg             [1:0]                       r_fault_alarm_io                    ; // 故障报警输出

/*========================================  寄存器读写控制信号管�? ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_we          <= 1'b0;
        r_reg_bus_addr        <= {REG_ADDR_BUS_WIDTH{1'b0}};
        r_reg_bus_data        <= {REG_DATA_BUS_WIDTH{1'b0}};
        r_reg_bus_data_vld    <= 1'b0;
        r_reg_bus_re          <= 1'b0;
        r_reg_bus_raddr       <= {REG_ADDR_BUS_WIDTH{1'b0}};
    end else begin
        r_reg_bus_we          <= i_switch_reg_bus_we;
        r_reg_bus_addr        <= i_switch_reg_bus_we_addr;
        r_reg_bus_data        <= i_switch_reg_bus_we_din;
        r_reg_bus_data_vld    <= i_switch_reg_bus_we_din_v;
        r_reg_bus_re          <= i_switch_reg_bus_rd;
        r_reg_bus_raddr       <= i_switch_reg_bus_rd_addr;
    end
end 

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_init_local_clkid <= 64'h70CA_4DFF_FE00_0001;
        r_init_local_priority1<=8'h80;
        r_init_local_priority2<=8'h80;
        r_init_local_class<=8'h80;
        r_init_local_accuracy<=8'h80;
        r_init_local_variance<=16'h0001;
        r_init_local_timesource<=8'h00;
        r_init_local_domain<=8'h00;
        r_init_ann_log<=8'h00;
        r_init_sync_log<=8'h00;
        r_init_dly_log<=8'h00;
        r_init_pdly_log<=8'h00;
        r_ptp_sync_lock_num<=8'h05;
        r_init_two_syncflg<=1'b1;
        r_init_two_pdlyflg<=1'b1;
        r_freq_sync_thhold<=32'h0000_03E8;
        r_phase_sync_thhold<=32'h0000_0001;
        r_freq_sync_num<=8'h05;
        r_phase_over_num<=8'h05;
        r_tot_mult_ann<=8'h05;
        r_tot_mult_sync<=8'h05;
        r_sync_clk_type<=1'b0;
        r_ptp_local_vflg<=1'b0;
        r_local_clkutc_offset<=8'h00;
        r_dly_req_en<=8'h01;
        r_init_local_mac <= 48'h70_CA_4D_00_00_01;
        r_init_local_ip <= 32'hC0_A8_05_02;
        r_sync_work_cycle<=32'h000F_4240;
        r_sync_phase_limit<=32'h0000_03E8;
        r_sync_freq_limit<=32'h0000_012C;
        r_sync_protocol<=4'h0;
        r_sync_en<=1'b0;
        r_sync_time_param<=64'h0000_0000_0000_0000;
        r_sync_cycle_param<=32'h0000_8000;
        r_sync_high_param<=16'h0100;
        r_cip_sync_en<=1'b0;
        r_fault_alarm_rd<=1'b0;
        r_fault_alarm_io<=2'b00;
    end else begin
        r_init_local_clkid[15:0]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_CLKID0 ? r_reg_bus_data[15:0] : r_init_local_clkid[15:0];
        r_init_local_clkid[31:16]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_CLKID1 ? r_reg_bus_data[15:0] : r_init_local_clkid[31:16];
        r_init_local_clkid[47:32]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_CLKID2 ? r_reg_bus_data[15:0] : r_init_local_clkid[47:32];
        r_init_local_clkid[63:48]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_CLKID3 ? r_reg_bus_data[7:0] : r_init_local_clkid[63:48];
        r_init_local_priority1    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_PRIOR1 ? r_reg_bus_data[7:0] : r_init_local_priority1;
        r_init_local_priority2    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_PRIOR2 ? r_reg_bus_data[7:0] : r_init_local_priority2;
        r_init_local_class      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_CLASS ? r_reg_bus_data[7:0] : r_init_local_class;
        r_init_local_accuracy   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_ACCURACY ? r_reg_bus_data[7:0] : r_init_local_accuracy;
        r_init_local_variance   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_VARIANCE ? r_reg_bus_data[15:0] : r_init_local_variance;
        r_init_local_timesource <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_TIMESOURCE ? r_reg_bus_data[7:0] : r_init_local_timesource;
        r_init_local_domain     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_DOMAIN ? r_reg_bus_data[7:0] : r_init_local_domain;
        r_init_ann_log        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_ANN_LOG ? r_reg_bus_data[7:0] : r_init_ann_log;
        r_init_sync_log       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_SYNC_LOG ? r_reg_bus_data[7:0] : r_init_sync_log;
        r_init_dly_log        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_DLY_LOG ? r_reg_bus_data[7:0] : r_init_dly_log;
        r_init_pdly_log       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_PDLY_LOG ? r_reg_bus_data[7:0] : r_init_pdly_log;
        r_ptp_sync_lock_num   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PTP_SYNC_LOCK_NUM ? r_reg_bus_data[7:0] : r_ptp_sync_lock_num;
        r_init_two_syncflg    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_TWO_SYNCFLG ? r_reg_bus_data[0] : r_init_two_syncflg;
        r_init_two_pdlyflg    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_TWO_PDLYFLG ? r_reg_bus_data[0] : r_init_two_pdlyflg;
        r_freq_sync_thhold[15:0]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FREQ_SYNC_THHOLD0 ? r_reg_bus_data[15:0] : r_freq_sync_thhold[15];
        r_freq_sync_thhold[31:16]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FREQ_SYNC_THHOLD1 ? r_reg_bus_data[15:0] : r_freq_sync_thhold[31:16];
        r_phase_sync_thhold[15:0]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PHASE_SYNC_THHOLD0 ? r_reg_bus_data[15:0] : r_phase_sync_thhold[15:0];
        r_phase_sync_thhold[31:16]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PHASE_SYNC_THHOLD1 ? r_reg_bus_data[15:0] : r_phase_sync_thhold[31:16];
        r_freq_sync_num       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FREQ_SYNC_NUM ? r_reg_bus_data[7:0] : r_freq_sync_num;
        r_phase_over_num      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PHASE_OVER_NUM ? r_reg_bus_data[7:0] : r_phase_over_num;
        r_tot_mult_ann        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_TOT_MULT_ANN ? r_reg_bus_data[7:0] : r_tot_mult_ann;
        r_tot_mult_sync       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_TOT_MULT_SYNC ? r_reg_bus_data[7:0] : r_tot_mult_sync;
        r_sync_clk_type       <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_CLK_TYPE ? r_reg_bus_data[0] : r_sync_clk_type;
        r_ptp_local_vflg      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PTP_LOCAL_VFLG ? r_reg_bus_data[0] : r_ptp_local_vflg;
        r_local_clkutc_offset <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_LOCAL_CLKUTC_OFFSET ? r_reg_bus_data[7:0] : r_local_clkutc_offset;
        r_dly_req_en          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_DLY_REQ_EN ? r_reg_bus_data[7:0] : r_dly_req_en;
        r_init_local_mac[15:0] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_MAC0 ? r_reg_bus_data[15:0] : r_init_local_mac[15:0];
        r_init_local_mac[31:16]<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_MAC1 ? r_reg_bus_data[15:0] : r_init_local_mac[31:16];
        r_init_local_mac[47:32]<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_MAC2 ? r_reg_bus_data[15:0] : r_init_local_mac[47:32];
        r_init_local_ip[15:0]  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_IP0 ? r_reg_bus_data[15:0] : r_init_local_ip[15:0];
        r_init_local_ip[31:16] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_INIT_LOCAL_IP1 ? r_reg_bus_data[15:0] : r_init_local_ip[31:16];
        r_sync_work_cycle[15:0] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_WORK_CYCLE0 ? r_reg_bus_data[15:0] : r_sync_work_cycle[15:0];
        r_sync_work_cycle[31:16] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_WORK_CYCLE1 ? r_reg_bus_data[15:0] : r_sync_work_cycle[31:16];
        r_sync_phase_limit[15:0] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_PHASE_LIMIT0 ? r_reg_bus_data[15:0] : r_sync_phase_limit[15:0];
        r_sync_phase_limit[31:16] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_PHASE_LIMIT1 ? r_reg_bus_data[15:0] : r_sync_phase_limit[31:16];
        r_sync_freq_limit[15:0]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_FREQ_LIMIT0 ? r_reg_bus_data[15:0] : r_sync_freq_limit[15:0];
        r_sync_freq_limit[31:16]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_FREQ_LIMIT1 ? r_reg_bus_data[15:0] : r_sync_freq_limit[31:16];
        r_sync_protocol           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_PROTOCOL ? r_reg_bus_data[3:0] : r_sync_protocol;
        r_sync_en                 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_EN ? r_reg_bus_data[0] : r_sync_en;
        r_sync_time_param[15:0]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_TIME_PARAM0 ? r_reg_bus_data[15:0] : r_sync_time_param[15:0];
        r_sync_time_param[31:16]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_TIME_PARAM1 ? r_reg_bus_data[15:0] : r_sync_time_param[31:16];
        r_sync_time_param[47:32]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_TIME_PARAM2 ? r_reg_bus_data[15:0] : r_sync_time_param[47:32];
        r_sync_time_param[63:48]   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_TIME_PARAM3 ? r_reg_bus_data[15:0] : r_sync_time_param[63:48];
        r_sync_cycle_param[15:0]  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_CYCLE_PARAM0 ? r_reg_bus_data[15:0] : r_sync_cycle_param[15:0];
        r_sync_cycle_param[31:16] <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_CYCLE_PARAM1 ? r_reg_bus_data[15:0] : r_sync_cycle_param[31:16];
        r_sync_high_param         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_SYNC_HIGH_PARAM ? r_reg_bus_data[15:0] : r_sync_high_param;
        r_cip_sync_en <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CIP_SYNC_EN ? r_reg_bus_data[0] : r_cip_sync_en;
        r_fault_alarm_rd <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FAULT_ALARM_RD ? r_reg_bus_data[0] : r_fault_alarm_rd;
        r_fault_alarm_io <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FAULT_ALARM_IO ? r_reg_bus_data[1:0] : r_fault_alarm_io;
    end
end


assign o_init_local_clkid[63:0] = r_init_local_clkid[63:0];
assign o_init_local_priority1 = r_init_local_priority1;
assign o_init_local_priority2 = r_init_local_priority2;
assign o_init_local_class = r_init_local_class;
assign o_init_local_accuracy = r_init_local_accuracy;
assign o_init_local_variance = r_init_local_variance;
assign o_init_local_timesource = r_init_local_timesource;
assign o_init_local_domain = r_init_local_domain;
assign o_init_ann_log = r_init_ann_log;
assign o_init_sync_log = r_init_sync_log;
assign o_init_dly_log = r_init_dly_log;
assign o_init_pdly_log = r_init_pdly_log;
assign o_ptp_sync_lock_num = r_ptp_sync_lock_num;
assign o_init_two_syncflg = r_init_two_syncflg;
assign o_init_two_pdlyflg = r_init_two_pdlyflg;
assign o_freq_sync_thhold = r_freq_sync_thhold;
assign o_phase_sync_thhold = r_phase_sync_thhold;
assign o_freq_sync_num = r_freq_sync_num;
assign o_phase_over_num = r_phase_over_num;
assign o_tot_mult_ann = r_tot_mult_ann;
assign o_tot_mult_sync = r_tot_mult_sync;
assign o_sync_clk_type = r_sync_clk_type;
assign o_ptp_local_vflg = r_ptp_local_vflg;
assign o_local_clkutc_offset = r_local_clkutc_offset;
assign o_dly_req_en = r_dly_req_en;
assign o_init_local_mac = r_init_local_mac;
assign o_init_local_ip = r_init_local_ip;
assign o_sync_work_cycle = r_sync_work_cycle;
assign o_sync_phase_limit = r_sync_phase_limit;
assign o_sync_freq_limit = r_sync_freq_limit;
assign o_sync_protocol = r_sync_protocol;
assign o_sync_en = r_sync_en;
assign o_sync_time_param = r_sync_time_param;
assign o_sync_cycle_param = r_sync_cycle_param;
assign o_sync_high_param = r_sync_high_param;
assign o_cip_sync_en = r_cip_sync_en;
assign o_fault_alarm_rd = r_fault_alarm_rd;
assign o_fault_alarm_io = r_fault_alarm_io;
/*========================================= 寄存器读控制逻辑 =========================================*/
// 寄存器读数据逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else if (r_reg_bus_re) begin
        case (r_reg_bus_raddr)
            REG_INIT_LOCAL_CLKID0  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_clkid[15:0]};
            REG_INIT_LOCAL_CLKID1  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_clkid[31:16]};
            REG_INIT_LOCAL_CLKID2  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_clkid[47:32]};
            REG_INIT_LOCAL_CLKID3  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_clkid[63:48]};
            REG_INIT_LOCAL_PRIOR1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_local_priority1};
            REG_INIT_LOCAL_PRIOR2 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_local_priority2};
            REG_INIT_LOCAL_CLASS   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_local_class};
            REG_INIT_LOCAL_ACCURACY: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_local_accuracy};
            REG_INIT_LOCAL_VARIANCE: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_variance};
            REG_INIT_LOCAL_TIMESOURCE: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_local_timesource};
            REG_INIT_LOCAL_DOMAIN  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_local_domain};
            REG_INIT_ANN_LOG       : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_ann_log};
            REG_INIT_SYNC_LOG      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_sync_log};
            REG_INIT_DLY_LOG       : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_dly_log};
            REG_INIT_PDLY_LOG      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_init_pdly_log};
            REG_PTP_SYNC_LOCK_NUM  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_ptp_sync_lock_num};
            REG_INIT_TWO_SYNCFLG   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},r_init_two_syncflg};
            REG_INIT_TWO_PDLYFLG   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},r_init_two_pdlyflg};
            REG_FREQ_SYNC_THHOLD0  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_freq_sync_thhold[15:0]};
            REG_FREQ_SYNC_THHOLD1  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_freq_sync_thhold[31:16]};
            REG_PHASE_SYNC_THHOLD0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_phase_sync_thhold[15:0]};
            REG_PHASE_SYNC_THHOLD1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_phase_sync_thhold[31:16]};
            REG_FREQ_SYNC_NUM    : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_freq_sync_num};
            REG_PHASE_OVER_NUM   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_phase_over_num};
            REG_TOT_MULT_ANN     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_tot_mult_ann};
            REG_TOT_MULT_SYNC    : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_tot_mult_sync};
            REG_SYNC_CLK_TYPE    : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_sync_clk_type};
            REG_PTP_LOCAL_VFLG   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},r_ptp_local_vflg};
            REG_LOCAL_CLKUTC_OFFSET: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_local_clkutc_offset};
            REG_DLY_REQ_EN       : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},r_dly_req_en};
            REG_PTP_MASTER_CLKID0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_clkid[15:0]};
            REG_PTP_MASTER_CLKID1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_clkid[31:16]};
            REG_PTP_MASTER_CLKID2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_clkid[47:32]};
            REG_PTP_MASTER_CLKID3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_clkid[63:48]};
            REG_PTP_MASTER_SOURCEID0: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_sourceid[15:0]};
            REG_PTP_MASTER_SOURCEID1: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_sourceid[31:16]};
            REG_PTP_MASTER_SOURCEID2: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_sourceid[47:32]};
            REG_PTP_MASTER_SOURCEID3: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_sourceid[63:48]};
            REG_PTP_MASTER_SOURCEID4: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_sourceid[79:64]};
            REG_PTP_MASTER_PRIORITY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_master_priority1};
            REG_PTP_MASTER_PRIORITY2 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_master_priority2};
            REG_PTP_MASTER_CLASS   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_master_class};
            REG_PTP_MASTER_ACCURACY: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_master_accuracy};
            REG_PTP_MASTER_TIMESOURCE: r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_master_timesource};
            REG_PTP_MASTER_VARIANCE  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_variance};
            REG_PTP_MASTER_STEPS  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_master_steps};
            REG_PTP_MASTER_DOMAIN : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_master_domain};
            REG_NODE_PROPERTY    : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_node_property};
            REG_PTP_PROTYPE      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_protype};
            REG_PTP_SLAVE        : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},i_ptp_slave};
            REG_PTP_PASSIVE      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},i_ptp_passive};
            REG_PTP_SYNC_FLG     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},i_ptp_sync_flg};
            REG_PTP_ANN_LOG      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_ann_log};
            REG_PTP_SYNC_LOG     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_sync_log};
            REG_PTP_PDLY_LOG      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ptp_pdly_log};
            REG_ANN_TC_CNT       : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ann_tc_cnt};
            REG_SYNC_TC_CNT      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_sync_tc_cnt};
            REG_ANN_ERR_CNT      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_ann_err_cnt};
            REG_SYNC_ERR_CNT     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_sync_err_cnt};
            REG_DLYREQ_ERR_CNT   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_dlyreq_err_cnt};
            REG_DLYRESP_ERR_CNT  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_dlyresp_err_cnt};
            REG_PDLYREQ_ERR_CNT  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_pdlyreq_err_cnt};
            REG_PDLYRESP_ERR_CNT : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_pdlyresp_err_cnt};
            REG_PDLYRESPF_ERR_CNT  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_pdlyrespf_err_cnt};
            REG_MASTER_CHG_CNT   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_master_chg_cnt};
            REG_INIT_LOCAL_MAC0  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_mac[15:0]};
            REG_INIT_LOCAL_MAC1  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_mac[31:16]};
            REG_INIT_LOCAL_MAC2  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_mac[47:32]};
            REG_INIT_LOCAL_IP0    : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_ip[15:0]};
            REG_INIT_LOCAL_IP1   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_init_local_ip[31:16]};
            REG_PTP_LINE0_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line0_delay[15:0]};
            REG_PTP_LINE0_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line0_delay[31:16]};
            REG_PTP_LINE1_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line1_delay[15:0]};
            REG_PTP_LINE1_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line1_delay[31:16]};
            REG_PTP_LINE2_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line2_delay[15:0]};
            REG_PTP_LINE2_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line2_delay[31:16]};
            REG_PTP_LINE3_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line3_delay[15:0]};
            REG_PTP_LINE3_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line3_delay[31:16]};
            REG_PTP_LINE4_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line4_delay[15:0]};
            REG_PTP_LINE4_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line4_delay[31:16]};
            REG_PTP_LINE5_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line5_delay[15:0]};
            REG_PTP_LINE5_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line5_delay[31:16]};
            REG_PTP_LINE6_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line6_delay[15:0]};
            REG_PTP_LINE6_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line6_delay[31:16]};
            REG_PTP_LINE7_DELAY0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line7_delay[15:0]};
            REG_PTP_LINE7_DELAY1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_ptp_line7_delay[31:16]};
            REG_SYNC_WORK_CYCLE0 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_work_cycle[15:0]};
            REG_SYNC_WORK_CYCLE1 : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_work_cycle[31:16]};
            REG_SYNC_PHASE_LIMIT0  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_phase_limit[15:0]};
            REG_SYNC_PHASE_LIMIT1  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_phase_limit[31:16]};
            REG_SYNC_FREQ_LIMIT0  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_freq_limit[15:0]};
            REG_SYNC_FREQ_LIMIT1  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_freq_limit[31:16]};
            REG_SYNC_PROTOCOL      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-4{1'b0}},r_sync_protocol};
            REG_SYNC_EN            : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},r_sync_en};
            REG_SYNC_TIME_PARAM0   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_time_param[15:0]};
            REG_SYNC_TIME_PARAM1   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_time_param[31:16]};
            REG_SYNC_TIME_PARAM2   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_time_param[47:32]};
            REG_SYNC_TIME_PARAM3   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_time_param[63:48]};
            REG_SYNC_CYCLE_PARAM0  :r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_cycle_param[15:0]};
            REG_SYNC_CYCLE_PARAM1  :r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_cycle_param[31:16]};
            REG_SYNC_HIGH_PARAM  : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},r_sync_high_param[15:0]};
            REG_CIP_SYNC_EN      : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},r_cip_sync_en};
            REG_FAULT_TYPE       : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_fault_type};
            REG_ALARM_TYPE       : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_alarm_type};
            REG_CUR_SYNC_TIME0     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_curr_sync_time[15:0]};
            REG_CUR_SYNC_TIME1     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_curr_sync_time[31:16]};
            REG_CUR_SYNC_TIME2     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_curr_sync_time[47:32]};
            REG_CUR_SYNC_TIME3     : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}},i_curr_sync_time[63:48]};
            REG_FAULT_ALARM_RD   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},r_fault_alarm_rd};
            REG_FAULT_ALARM_IO   : r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-2{1'b0}},r_fault_alarm_io};
            default                                 : r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
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

assign o_switch_reg_bus_rd_dout  = r_reg_bus_rdata;
assign o_switch_reg_bus_rd_dout_v= r_reg_bus_rdata_vld;


endmodule