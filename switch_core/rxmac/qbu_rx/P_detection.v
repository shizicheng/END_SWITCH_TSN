`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 16:32:21
// Design Name: 
// Module Name: P_detection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module P_detection #( 
    parameter   DWIDTH                      =       8         
)(
    input       wire                        i_clk                       ,
    input       wire                        i_rst                       ,  

    input       wire    [1:0]               i_mac_port_speed            , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input       wire    [DWIDTH-1:0]        i_mac_axi_data              ,
    input       wire    [(DWIDTH/8)-1:0]    i_mac_axi_data_keep         ,
    input       wire                        i_mac_axi_data_valid        ,
    output      wire                        o_mac_axi_data_ready        ,
    input       wire                        i_mac_axi_data_last         ,
    // info fifo output port       
    output      wire    [1:0]               o_mac_port_speed            , // 端口速率信息
    output      wire    [47:0]              o_target_mac                , 
    output      wire                        o_target_mac_valid          ,
    output      wire    [47:0]              o_source_mac                ,
    output      wire                        o_source_mac_valid          ,
    output      wire    [15:0]              o_post_type                 , // 以太网类型字段
    output      wire                        o_post_type_valid           ,

    output      wire    [2:0]               o_vlan_pri                  , // [62:60](3bit) : vlan_priority
    output      wire    [11:0]              o_vlan_id                   , // 12bit VLAN ID,取值范围 1-4094 
    output      wire                        o_frm_vlan_flag             , // [27](1bit) : frm_vlan_flag，表明带有802.1Q标签
    // output      wire    [PORT_NUM-1:0]      o_rx_port                   , // [26:19](8bit) : 输入端口，bitmap表示
    output      wire                        o_frm_qbu                   , // [11](1bit) : 是否为关键帧(Qbu) 
    output      wire                        o_frm_discard               , // 检验crc是否正确[12](1bit) 
    output      wire    [15:0]              o_rtag_sequence             , // CB协议 R-TAG字段  
    output      wire                        o_rtag_flag                 , // 报文含rtag的标志
    output      wire                        o_emac_info_valid           , // emac的报文头参数全部有效
    output      wire                        o_pmac_info_valid           , // pmac的报文头参数全部有效
    // qbu参数 
    output      wire    [7:0]               o_SMD_type                  ,
    output      wire                        o_SMD_type_vld              ,
    output      wire    [7:0]               o_frag_cnt                  ,
    output      wire                        o_frag_cnt_vld              ,

    output      wire    [1:0]               o_crc_vld                   , // CRC 检测 0bit 是 CRC 有效位，1bit 是 mCRC 有效位
    output      wire                        o_crc_err                   ,
    // data port 
    output      wire    [DWIDTH-1:0]        o_post_data                 ,
    output      wire                        o_post_last                 ,
    output      wire    [15:0]              o_post_data_len             ,
    output      wire                        o_post_data_len_vld         ,
    output      wire                        o_post_data_vld             ,
    //寄存器端口
    input       wire    [11:0]              i_default_vlan_id           , // 默认VLAN ID配置
    input       wire    [2:0]               i_default_vlan_pri          , // 默认VLAN优先级配置
    input       wire                        i_default_vlan_valid        , // 默认VLAN配置有效信号
    output      wire    [15:0]              o_rx_frames_cnt             ,
    output      wire    [15:0]              o_err_rx_crc_cnt            ,
    output      wire                        o_rx_busy                       
);
/***************function**************/

/***************parameter*************/
// IDLE HEAD_1 HEAD_2 HEAD_3 HEAD_4 HEAD_5 HEAD_6 HEAD_7 SMD_S SMD_C Frag SFD MACD MACS TYPE WATIE DATA CRC
localparam  IDLE        =      20'b0000_0000_0000_0000_0001   ;
localparam  HEAD_1      =      20'b0000_0000_0000_0000_0010   ;
localparam  HEAD_2      =      20'b0000_0000_0000_0000_0100   ;
localparam  HEAD_3      =      20'b0000_0000_0000_0000_1000   ;
localparam  HEAD_4      =      20'b0000_0000_0000_0001_0000   ;
localparam  HEAD_5      =      20'b0000_0000_0000_0010_0000   ;
localparam  HEAD_6      =      20'b0000_0000_0000_0100_0000   ;
localparam  HEAD_7      =      20'b0000_0000_0000_1000_0000   ;
localparam  SMD_S       =      20'b0000_0000_0001_0000_0000   ;
localparam  SMD_C       =      20'b0000_0000_0010_0000_0000   ;
localparam  Frag        =      20'b0000_0000_0100_0000_0000   ;
localparam  MACD        =      20'b0000_0000_1000_0000_0000   ;
localparam  MACS        =      20'b0000_0001_0000_0000_0000   ;
localparam  VLAN        =      20'b0000_0010_0000_0000_0000   ;
localparam  RTAG        =      20'b0000_0100_0000_0000_0000   ;
localparam  TYPE        =      20'b0000_1000_0000_0000_0000   ;
localparam  DATA        =      20'b0001_0000_0000_0000_0000   ;
localparam  CRC         =      20'b0010_0000_0000_0000_0000   ;
localparam  WATIE       =      20'b0100_0000_0000_0000_0000   ;
localparam  SFD         =      20'b1000_0000_0000_0000_0000   ;

localparam  MCRC_P      =      32'h0000ffff                   ;


localparam      [11:0]      LP_DEFAULT_VLAN_ID      =   12'd1                           ; // 默认VLAN ID参数值
localparam      [2:0]       LP_DEFAULT_VLAN_PRI     =   3'd0                            ; // 默认VLAN优先级参数值
/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg     [19:0]              state_n,state_c                 ;
reg     [47:0]              r_source_mac                    ;
reg     [1:0]               ri_mac_port_speed               ;
reg     [7:0]               ri_mac_axi_data                 ;
reg                         ri_mac_axi_data_valid           ;
reg     [7:0]               ri_mac_axi_data_1d              ;
reg     [7:0]               ri_mac_axi_data_2d              ;
reg     [7:0]               ri_mac_axi_data_3d              ;
reg     [7:0]               ri_mac_axi_data_4d              ;
reg     [7:0]               ri_mac_axi_data_5d              ;
reg                         ri_mac_axi_data_valid_1d        ;
reg                         ri_mac_axi_data_valid_2d        ;
reg                         ri_mac_axi_data_valid_3d        ;
reg                         ri_mac_axi_data_valid_4d        ;
reg                         ri_mac_axi_data_valid_5d        ;
reg                         ri_mac_axi_data_valid_6d        ;
reg     [15:0]              r_din_5d_cnt                    ;
reg     [2:0]               r_rec_macd_cnt                  ;
reg     [2:0]               r_rec_macs_cnt                  ;
reg     [47:0]              r_target_mac                    ;
reg                         r_target_mac_valid              ;
reg                         r_source_mac_valid              ;
reg     [15:0]              r_post_type                     ;
reg                         r_post_type_valid               ;
reg     [7:0]               r_post_data                     ;
reg                         r_post_data_vld                 ;
reg                         r_crc_en,r_crc_en_1d            ;
reg                         r_crc_rst                       ;  
reg     [31:0]              r_crc_result                    ;
reg                         r_crc_valid                     ; 
reg                         r_mrcr_vld                      ;
reg     [31:0]              r_mcrc_result                   ;
reg                         r_post_last                     ;
reg     [7:0]               r_SMD_type                      ;
reg                         r_SMD_type_vld                  ;
reg     [7:0]               r_frag_cnt                      ;
reg                         r_frag_cnt_vld                  ;
reg     [1:0]               r_crc_vld                       ;
reg                         r_crc_err                       ;
reg                         r_crc_err_1d                    ;
reg     [15:0]              r_post_data_len                 ;
reg     [15:0]              r_post_data_len_vld             ;

// VLAN 相关寄存器
reg     [2:0]               r_rec_vlan_cnt                  ;
reg     [31:0]              r_vlan_data                     ;
reg     [2:0]               r_vlan_pri                      ;
reg                         r_frm_vlan_flag                 ;
reg     [11:0]              r_vlan_id                       ;
reg     [11:0]              r_default_vlan_id               ; // 默认VLAN ID打拍
reg     [2:0]               r_default_vlan_pri              ; // 默认VLAN优先级打拍
reg                         r_default_vlan_valid            ; // 默认VLAN配置有效信号打拍

// RTAG 相关寄存器  
reg                         r_rtag_flag                     ;
reg     [2:0]               r_rec_rtag_cnt                  ;
reg     [47:0]              r_rtag_data                     ;
reg     [15:0]              r_rtag_sequence                 ;
reg     [1:0]               r_type_cnt                      ;
// 其他输出相关寄存器
// reg     [PORT_NUM-1:0]      r_rx_port                       ;
reg                         r_frm_qbu                       ;
reg                         r_frm_discard                   ;

//寄存器
reg     [15:0]              r_rx_frames_cnt                 ;
reg     [15:0]              ro_err_rx_crc_cnt               ;
reg                         r_emac_info_valid               ;
reg                         r_pmac_info_valid               ;
reg                         r_emac_info_flag                ;
reg                         r_pmac_info_flag                ;  
// reg     [1:0]               ro_mac_port_speed               ;
// reg     [15:0]              ro_err_rx_frame_cnt             ;

/***************wire******************/
wire                        idle2head_1_start               ;
wire                        head_12head_2_start             ;
wire                        head_22head_3_start             ;
wire                        head_32head_4_start             ;
wire                        head_42head_5_start             ;
wire                        head_52head_6_start             ;
wire                        head_62head_7_start             ;
wire                        head_72SMD_S_start              ;
wire                        head_62SMD_C_start              ;
wire                        SMD_S2_MACD_start               ;
wire                        head_72SFD_start                ;
wire                        SFD2MACD_start                  ;
wire                        MACD2MACS_start                 ;
wire                        MACS2TYPE_start                 ;

wire                        MACS2VLAN_start                 ;
wire                        MACS2RTAG_start                 ;
wire                        VLAN2TYPE_start                 ;
wire                        VLAN2RTAG_start                 ;
wire                        RTAG2TYPE_start                 ;

wire                        TYPE2DATA_start                 ;
wire                        WATIE2DATA_start                ;
wire                        DATA2CRC_start                  ;
wire                        CRC2IDLE_start                  ;
wire    [31:0]              w_o_crc_result                  ;
wire                        Frag2MACD_start                 ;
wire                        Frag2DATA                       ;
// wire                        head_72SMD_S_start              ;
wire                        SMD_C2Frag_start                ;
wire    [7:0]               w_crc_data_in                   ;
/***************component*************/
CRC32_D8 CRC32_D8_u0 
(
  .i_clk            (i_clk              )                   ,
  .i_rst            (r_crc_rst          )                   ,
  .i_en             (r_crc_en           )                   ,
  .i_data           (w_crc_data_in      )                   ,
  .o_crc            (w_o_crc_result     )   
);

/***************assign****************/
assign w_crc_data_in            =       r_crc_en ? ri_mac_axi_data_4d : 8'd0;
assign o_mac_port_speed         =       r_post_data_vld ? ri_mac_port_speed : 2'd0;
assign o_target_mac             =       r_target_mac          ;
assign o_target_mac_valid       =       r_target_mac_valid    ;
assign o_source_mac             =       r_source_mac          ;
assign o_source_mac_valid       =       r_source_mac_valid    ;
assign o_post_type              =       r_post_type           ;
assign o_post_type_valid        =       r_post_type_valid     ;
assign o_post_data_vld          =       r_post_data_vld       ;
assign o_post_data              =       r_post_data           ;
assign o_post_last              =       r_post_last           ;
assign o_post_data_len          =       r_post_data_len       ;
assign o_post_data_len_vld      =       r_post_data_len_vld   ;
assign o_SMD_type               =       r_SMD_type            ;
assign o_SMD_type_vld           =       r_SMD_type_vld        ;
assign o_frag_cnt               =       r_frag_cnt            ;
assign o_frag_cnt_vld           =       r_frag_cnt_vld        ;
assign o_crc_vld                =       r_crc_vld             ;
assign o_crc_err                =       r_crc_err             ;

// VLAN 和 RTAG 相关输出
assign o_vlan_pri               =       r_vlan_pri            ;
assign o_frm_vlan_flag          =       r_frm_vlan_flag       ; 
assign o_frm_qbu                =       r_frm_qbu             ;
assign o_frm_discard            =       r_frm_discard         ;
assign o_vlan_id                =       r_vlan_id             ;
assign o_rtag_sequence          =       r_rtag_sequence       ;
assign o_rtag_flag              =       r_rtag_flag           ;
assign o_emac_info_valid        =       r_emac_info_valid     ;
assign o_pmac_info_valid        =       r_pmac_info_valid     ;

assign o_rx_frames_cnt          =       r_rx_frames_cnt       ;
assign o_err_rx_crc_cnt         =       ro_err_rx_crc_cnt     ;
// assign o_err_rx_frame_cnt       =       ro_err_rx_frame_cnt   ;
assign o_rx_busy                =       ri_mac_axi_data_valid                ;
assign o_mac_axi_data_ready     =       1'b1 ;  //需要验证
/****************ZTJ*****************/

// 状态机第一段：同步时序逻辑电路，格式化描述次态寄存器搬移至现态寄存器(不需更改)
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        state_c <= IDLE;
    end
    else begin
        state_c <= state_n;
    end
end

// 状态机第二段：组合逻辑块，描述状态转移条件判断，第二段只描述状态机的架构
// 不写明状态的转移条件，方便其他人理解状态机的架构，同时也方便对状态机架构进行修改
// 使用 state_n = state_c 描述状态不变
// IDLE HEAD_1 HEAD_2 HEAD_3 HEAD_4 HEAD_5 HEAD_6 HEAD_7 SMD_S SMD_C Frag SFD MACD MACS TYPE WATIE DATA CRC
always @(*) begin
    case(state_c)
        IDLE: begin
            if (idle2head_1_start) begin
                state_n = HEAD_1;
            end
            else begin
                state_n = state_c;
            end
        end
        HEAD_1: begin
            if (head_12head_2_start) begin
                state_n = HEAD_2;
            end
            else begin
                state_n = IDLE;
            end
        end
        HEAD_2: begin
            if (head_22head_3_start) begin
                state_n = HEAD_3;
            end
            else begin
                state_n = IDLE;
            end
        end
        HEAD_3: begin
            if (head_32head_4_start) begin
                state_n = HEAD_4;
            end
            else begin
                state_n = IDLE;
            end
        end
        HEAD_4: begin
            if (head_42head_5_start) begin
                state_n = HEAD_5;
            end
            else begin
                state_n = IDLE;
            end
        end
        HEAD_5: begin
            if (head_52head_6_start) begin
                state_n = HEAD_6;
            end
            else begin
                state_n = IDLE;
            end
        end
        HEAD_6: begin
            if (head_62head_7_start) begin
                state_n = HEAD_7;
            end
            else if (head_62SMD_C_start) begin
                state_n = SMD_C;
            end
            else begin
                state_n = IDLE;
            end
        end
        SMD_S: begin
            if (SMD_S2_MACD_start) begin
                state_n = MACD;
            end
            else begin
                state_n = IDLE;
            end
        end
        SMD_C: begin
            if (SMD_C2Frag_start) begin
                state_n = Frag;
            end
            else begin
                state_n = IDLE;
            end
        end
        Frag: begin
            if (Frag2MACD_start) begin
                state_n = MACD;
            end
            else if(Frag2DATA) begin
                state_n = DATA; 
            end
            else begin
                state_n = IDLE;
            end
        end
        HEAD_7: begin
            if (head_72SMD_S_start) begin
                state_n = SMD_S;
            end
            else if (head_72SFD_start) begin
                state_n = SFD;
            end
            else begin
                state_n = IDLE;
            end
        end
        SFD: begin
            if (SFD2MACD_start) begin
                state_n = MACD;
            end
            else begin
                state_n = IDLE;
            end
        end
        MACD: begin
            if (MACD2MACS_start) begin
                state_n = MACS;
            end
            else begin
                state_n = state_c;
            end
        end
        MACS: begin
            if (MACS2TYPE_start) begin
                state_n = TYPE;
            end
            else if(MACS2VLAN_start) begin
                state_n = VLAN;
            end
            else if(MACS2RTAG_start) begin
                state_n = RTAG;
            end
            else begin
                state_n = state_c;
            end
        end
        VLAN: begin
            if (VLAN2TYPE_start) begin
                state_n = TYPE;
            end
            else if(VLAN2RTAG_start) begin
                state_n = RTAG;
            end
            else begin
                state_n = state_c;
            end
        end
        RTAG: begin
            if (RTAG2TYPE_start) begin
                state_n = TYPE;
            end
            else begin
                state_n = state_c;
            end
        end
        TYPE: begin
            if (TYPE2DATA_start) begin
                state_n = DATA;
            end
            else begin
                state_n = state_c;
            end
        end
        WATIE: begin
            if (WATIE2DATA_start) begin
                state_n = DATA;
            end
            else begin
                state_n = state_c;
            end
        end
        DATA: begin
            if (DATA2CRC_start) begin 
                state_n = CRC;
            end
            else begin
                state_n = state_c;
            end
        end
        CRC: begin
            if (CRC2IDLE_start) begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        default: begin
            state_n = IDLE;
        end
        
    endcase
end

// 状态机第三段：设计转移条件，命名状态机跳转为xx(现态)2xx(次态)
assign idle2head_1_start    =   state_c == IDLE     &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;
assign head_12head_2_start  =   state_c == HEAD_1   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;
assign head_22head_3_start  =   state_c == HEAD_2   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;
assign head_32head_4_start  =   state_c == HEAD_3   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;
assign head_42head_5_start  =   state_c == HEAD_4   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;
assign head_52head_6_start  =   state_c == HEAD_5   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;
assign head_62head_7_start  =   state_c == HEAD_6   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h55                                ;             //增加|| i_mac_axi_data == 8'h55，让普通发送模式下直接用emac通道
assign head_72SMD_S_start   =   state_c == HEAD_7   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'he6 || i_mac_axi_data == 8'h4c || i_mac_axi_data == 8'h7f || i_mac_axi_data == 8'hb3 || i_mac_axi_data == 8'h55;
assign head_62SMD_C_start   =   state_c == HEAD_6   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'h61 || i_mac_axi_data == 8'h52 || i_mac_axi_data == 8'h9e || i_mac_axi_data == 8'h2a   ;
assign SMD_C2Frag_start     =   state_c == SMD_C    &&    i_mac_axi_data_valid                                                  ;
// assign Frag2MACD_start      =   state_c == Frag     &&    i_mac_axi_data_valid                                                  ; 
assign Frag2DATA      =   state_c == Frag     &&    i_mac_axi_data_valid                                                  ; 
// assign FRAG2DATA            =   state_c == Frag 
assign SMD_S2_MACD_start    =   state_c == SMD_S    &&    i_mac_axi_data_valid                                                  ;
assign head_72SFD_start     =   state_c == HEAD_7   &&    i_mac_axi_data_valid && i_mac_axi_data == 8'hd5                       ;
assign SFD2MACD_start       =   state_c == SFD      &&    i_mac_axi_data_valid                                                  ;
assign MACD2MACS_start      =   state_c == MACD     &&    (ri_mac_axi_data_valid && r_rec_macd_cnt == 'd5)                      ;
assign MACS2TYPE_start      =   state_c == MACS     &&    (ri_mac_axi_data_valid && r_rec_macs_cnt == 'd5) && i_mac_axi_data != 8'h81 && i_mac_axi_data != 8'hf1 ;
assign MACS2VLAN_start      =   state_c == MACS     &&    (ri_mac_axi_data_valid && r_rec_macs_cnt == 'd5) && i_mac_axi_data == 8'h81 ;
assign MACS2RTAG_start      =   state_c == MACS     &&    (ri_mac_axi_data_valid && r_rec_macs_cnt == 'd5) && i_mac_axi_data == 8'hf1 ;
assign VLAN2TYPE_start      =   state_c == VLAN     &&    (ri_mac_axi_data_valid && r_rec_vlan_cnt == 'd3) && i_mac_axi_data != 8'hf1 ;
assign VLAN2RTAG_start      =   state_c == VLAN     &&    (ri_mac_axi_data_valid && r_rec_vlan_cnt == 'd3) && i_mac_axi_data == 8'hf1 ;
assign RTAG2TYPE_start      =   state_c == RTAG     &&    (ri_mac_axi_data_valid && r_rec_rtag_cnt == 'd5) ;    
assign TYPE2DATA_start      =   state_c == TYPE     &&    r_type_cnt == 2'd1    ;
assign WATIE2DATA_start     =   state_c == WATIE    &&    r_din_5d_cnt == 'd21                                    ;
assign DATA2CRC_start       =   state_c == DATA     &&    !i_mac_axi_data_valid && ri_mac_axi_data_valid                                       ;
assign CRC2IDLE_start       =   state_c == CRC      &&    r_crc_valid == 1'b1                                     ; 
/***************always****************/
/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_source_mac <= P_SOURCE_MAC;
    end
    else if (i_source_mac_valid == 1'b1) begin
        r_source_mac <= i_source_mac;
    end
    else begin
        r_source_mac <= r_source_mac;
    end
end
*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_mac_axi_data_valid    <= 1'd0;
        ri_mac_axi_data          <= 8'd0;
        ri_mac_axi_data_1d       <= 8'd0;   
        ri_mac_axi_data_2d       <= 8'd0;   
        ri_mac_axi_data_3d       <= 8'd0;   
        ri_mac_axi_data_4d       <= 8'd0;
        ri_mac_axi_data_5d       <= 8'd0;
        ri_mac_axi_data_valid_1d <= 1'd0;
        ri_mac_axi_data_valid_2d <= 1'd0;
        ri_mac_axi_data_valid_3d <= 1'd0;
        ri_mac_axi_data_valid_4d <= 1'd0;
        ri_mac_axi_data_valid_5d <= 1'd0;
        ri_mac_axi_data_valid_6d <= 1'd0;
        ri_mac_port_speed        <= 2'd0;
    end
    else begin
        ri_mac_axi_data_valid    <= i_mac_axi_data_valid;
        ri_mac_axi_data          <= i_mac_axi_data;
        ri_mac_axi_data_1d       <= ri_mac_axi_data;
        ri_mac_axi_data_2d       <= ri_mac_axi_data_1d;
        ri_mac_axi_data_3d       <= ri_mac_axi_data_2d;
        ri_mac_axi_data_4d       <= ri_mac_axi_data_3d;
        ri_mac_axi_data_5d       <= ri_mac_axi_data_4d;
        ri_mac_axi_data_valid_1d <= ri_mac_axi_data_valid;
        ri_mac_axi_data_valid_2d <= ri_mac_axi_data_valid_1d;
        ri_mac_axi_data_valid_3d <= ri_mac_axi_data_valid_2d;
        ri_mac_axi_data_valid_4d <= ri_mac_axi_data_valid_3d;
        ri_mac_axi_data_valid_5d <= ri_mac_axi_data_valid_4d;
        ri_mac_axi_data_valid_6d <= ri_mac_axi_data_valid_5d;
        ri_mac_port_speed        <= i_mac_port_speed;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rx_frames_cnt <= 'd0;
    end
    else if (!ri_mac_axi_data_valid & i_mac_axi_data_valid) begin
        r_rx_frames_cnt <= r_rx_frames_cnt + 1'd1;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_err_rx_crc_cnt <= 'd0;
    end
    else if (!r_crc_err_1d & r_crc_err) begin
        ro_err_rx_crc_cnt <= ro_err_rx_crc_cnt + 1'd1;
    end
end

// r_post_data_len
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_data_len <= 'd1;
    end
    else if (r_post_last) begin
        r_post_data_len <= 'd1;
    end
    else if (r_post_data_vld) begin
        r_post_data_len <= r_post_data_len + 1'd1;
    end
end

// r_post_data_len_vld
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_data_len_vld <= 'd0;
    end
    else if (!ri_mac_axi_data_valid && ri_mac_axi_data_valid_1d) begin
        r_post_data_len_vld <= 'd1;
    end
    else begin
        r_post_data_len_vld <= 'd0;
    end
end

// r_din_5d_cnt
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_din_5d_cnt <= 'd0;
    end
    else if (!ri_mac_axi_data_valid_5d && ri_mac_axi_data_valid_6d) begin
        r_din_5d_cnt <= 'd0;
    end
    else if (ri_mac_axi_data_valid_5d) begin
        r_din_5d_cnt <= r_din_5d_cnt + 1'b1;
    end
    else begin
        r_din_5d_cnt <= r_din_5d_cnt;
    end
end

/********************** MAC 层 SMD 校验相关寄存器 **********************************/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_SMD_type <= 'd0;
        r_SMD_type_vld <= 'd0;
    end
    else if ((state_c == SMD_S || state_c == SMD_C || state_c == SFD) && i_mac_axi_data_valid) begin
        r_SMD_type <= ri_mac_axi_data;
        r_SMD_type_vld <= 'd1;
    end
    else begin
        r_SMD_type <= r_SMD_type;
        r_SMD_type_vld <= 'd0;
    end
end

/************************ MAC 层帧计数器相关寄存器 **********************************/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_frag_cnt <= 'd0;
        r_frag_cnt_vld <= 'd0;
    end
    else if (state_c == Frag && i_mac_axi_data_valid) begin
        r_frag_cnt <= ri_mac_axi_data;
        r_frag_cnt_vld <= 'd1;
    end
    else begin
        r_frag_cnt <= r_frag_cnt;
        r_frag_cnt_vld <= 'd0;
    end
end

/********************** MAC 层 CRC 校验相关寄存器 **********************************/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_en <= 'd0;
    end
    else if (!i_mac_axi_data_valid && ri_mac_axi_data_valid) begin
        r_crc_en <= 'd0;
    end
    else if (r_din_5d_cnt == 'd6) begin
        r_crc_en <= 'd1;
    end
    else begin
        r_crc_en <= r_crc_en;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_en_1d <= 'd0;
        r_crc_err_1d <= 'd0;
    end
    else begin
        r_crc_en_1d <= r_crc_en;
        r_crc_err_1d <= r_crc_err;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_result <= 'd0;
    end
    else if (i_mac_axi_data_valid) begin
        r_crc_result <= {r_crc_result[23:0],i_mac_axi_data};
    end
    else begin
        r_crc_result <= r_crc_result;
    end
end

always @(*) begin
    if (r_crc_en==0 && r_crc_en_1d==1) begin
        r_crc_valid = 'd1;
    end
    else begin
        r_crc_valid = 'd0;
    end
end

integer  i;
always @(*) begin
    if (r_crc_valid) begin
        for (i=0;i<=31;i=i+1) begin
            r_mcrc_result[i] = w_o_crc_result[i] ^ MCRC_P[i];
        end
    end
    else begin
        r_mcrc_result = r_mcrc_result;
    end
end

// r_mrcr_vld与crc的一样，用随便一个就ok
always @(*) begin
    if (r_crc_en==0 && r_crc_en_1d==1) begin
        r_mrcr_vld = 'd1;
    end
    else begin
        r_mrcr_vld = 'd0;
    end
end

//r_crc_rst
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_rst <= 'd0;
    end
    else if (r_din_5d_cnt == 'd6) begin
        r_crc_rst <= 'd0;
    end
    else if (r_din_5d_cnt < 'd4 && r_din_5d_cnt > 'd2) begin
        r_crc_rst <= 'd1;
    end
    else begin
        r_crc_rst <= r_crc_rst;
    end
end

// r_crc_err
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_err <= 'd0;
    end
    else if ((r_crc_valid && r_crc_result != w_o_crc_result) && (r_mrcr_vld && r_crc_result != r_mcrc_result)) begin
        r_crc_err <= 'd1;
    end
    else if (state_c==IDLE) begin
        r_crc_err <= 'd0;
    end
    else begin
        r_crc_err <= r_crc_err;
    end
end

// r_crc_vld
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_vld <= 'b0;
    end
    else if (r_crc_valid && r_crc_result == w_o_crc_result) begin
        r_crc_vld <= 'b01;
    end
    else if (r_crc_valid && r_crc_result == r_mcrc_result) begin
        r_crc_vld <= 'b10;
    end
/*    else if (r_crc_valid && r_crc_result != w_o_crc_result) begin
        r_crc_vld <= 'b00;
    end*/
    else begin
        r_crc_vld <= 'b0;
    end
end

/********************** MAC 层 target_mac 信号解析 ********************************/
// r_rec_macd_cnt
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rec_macd_cnt <= 'd0;
    end
    else if (state_c == MACD && ri_mac_axi_data_valid && r_rec_macd_cnt == 'd5) begin
        r_rec_macd_cnt <= 'd0;
    end
    else if (state_c == MACD && ri_mac_axi_data_valid) begin
        r_rec_macd_cnt <= r_rec_macd_cnt + 1'b1;
    end
    else begin
        r_rec_macd_cnt <= r_rec_macd_cnt;
    end
end

// r_target_mac      
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_target_mac <= 'd0;
    end
    else if (state_c == MACD && ri_mac_axi_data_valid && r_rec_macd_cnt <= 'd5) begin
        r_target_mac <= {r_target_mac[39:0],ri_mac_axi_data};
    end
    else begin
        r_target_mac <= r_target_mac;
    end
end

// r_target_mac_valid 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_target_mac_valid <= 1'b0;
    end
    else if (state_c == MACD && ri_mac_axi_data_valid && r_rec_macd_cnt == 'd5) begin
        r_target_mac_valid <= 1'b1;
    end
    else begin
        r_target_mac_valid <= 1'b0;
    end
end

/********************** MAC 层 source_mac 信号解析 ********************************/
// r_rec_macs_cnt
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rec_macs_cnt <= 'd0;
    end
    else if (state_c == MACS && ri_mac_axi_data_valid && r_rec_macs_cnt == 'd5) begin
        r_rec_macs_cnt <= 'd0;
    end
    else if (state_c == MACS && ri_mac_axi_data_valid) begin
        r_rec_macs_cnt <= r_rec_macs_cnt + 1'b1;
    end
    else begin
        r_rec_macs_cnt <= r_rec_macs_cnt;
    end
end

// r_source_mac
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_source_mac <= 'd0;
    end
    else if (state_c == MACS && ri_mac_axi_data_valid && r_rec_macs_cnt <= 'd5) begin
        r_source_mac <= {r_source_mac[39:0],ri_mac_axi_data};
    end
    else begin
        r_source_mac <= r_source_mac;
    end
end

// r_source_mac_valid
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_source_mac_valid <= 1'b0;
    end
    else if (state_c == MACS && ri_mac_axi_data_valid && r_rec_macs_cnt == 'd5) begin
        r_source_mac_valid <= 1'b1;
    end
    else begin
        r_source_mac_valid <= 1'b0;
    end
end

/********************** MAC 层 VLAN 信号解析 ********************************/
// r_rec_vlan_cnt
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rec_vlan_cnt <= 'd0;
    end
    else if (state_c == VLAN && ri_mac_axi_data_valid && r_rec_vlan_cnt == 'd3) begin
        r_rec_vlan_cnt <= 'd0;
    end
    else if (state_c == VLAN && ri_mac_axi_data_valid) begin
        r_rec_vlan_cnt <= r_rec_vlan_cnt + 1'b1;
    end
    else begin
        r_rec_vlan_cnt <= r_rec_vlan_cnt;
    end
end

// r_vlan_data - 接收VLAN数据（4字节）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_vlan_data <= 'd0;
    end
    else if (state_c == VLAN && ri_mac_axi_data_valid && r_rec_vlan_cnt <= 'd3) begin
        r_vlan_data <= {r_vlan_data[23:0],ri_mac_axi_data};
    end
    else begin
        r_vlan_data <= r_vlan_data;
    end
end

// VLAN字段解析 - VLAN优先级和ID 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_vlan_pri <= 3'd0;
        r_vlan_id  <= 12'd0;
    end
    else if (r_frm_vlan_flag) begin
        r_vlan_pri <= r_vlan_data[15:13];        // 优先级字段，高3位
        r_vlan_id  <= r_vlan_data[11:0];         // VLAN ID字段，低12位
    end
    else begin
        r_vlan_pri <= r_default_vlan_pri;
        r_vlan_id  <= r_default_vlan_id;
    end
end

// VLAN标志 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_frm_vlan_flag <= 'd0;
    end
    else if (state_c == VLAN && ri_mac_axi_data_valid && r_rec_vlan_cnt == 'd3) begin
        r_frm_vlan_flag <= 1'b1;                 // 标记含有VLAN标签
    end
    else if (state_c == IDLE) begin
        r_frm_vlan_flag <= 'd0;                  // 新帧开始时清除VLAN标志
    end
    else begin
        r_frm_vlan_flag <= r_frm_vlan_flag;
    end
end

/********************** MAC 层 RTAG 信号解析 ********************************/
// r_rec_rtag_cnt
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rec_rtag_cnt <= 'd0;
    end
    else if (state_c == RTAG && ri_mac_axi_data_valid && r_rec_rtag_cnt == 'd5) begin
        r_rec_rtag_cnt <= 'd0;
    end
    else if (state_c == RTAG && ri_mac_axi_data_valid) begin
        r_rec_rtag_cnt <= r_rec_rtag_cnt + 1'b1;
    end
    else begin
        r_rec_rtag_cnt <= r_rec_rtag_cnt;
    end
end

// r_rtag_data - 接收RTAG数据（6字节）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rtag_data <= 'd0;
    end
    else if (state_c == RTAG && ri_mac_axi_data_valid && r_rec_rtag_cnt <= 'd5) begin
        r_rtag_data <= {r_rtag_data[39:0],ri_mac_axi_data};
    end
    else begin
        r_rtag_data <= r_rtag_data;
    end
end

// RTAG存在标志与序列号解析
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rtag_flag <= 1'b0;
    end
    else if (state_c == RTAG && ri_mac_axi_data_valid && r_rec_rtag_cnt == 'd0) begin
        // 收到 RTAG 的首字节，标记本帧含 RTAG
        r_rtag_flag <= 1'b1;
    end
    else if (state_c == IDLE) begin
        // 新帧开始时清除标志
        r_rtag_flag <= 1'b0;
    end
end

// RTAG序列号解析 - 从RTAG字段中提取序列号
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rtag_sequence <= 'd0;
    end
    else if (r_rtag_flag == 1'd1) begin
        r_rtag_sequence <= r_rtag_data[15:0];    // 取RTAG字段的低16位作为序列号
    end
    else begin
        r_rtag_sequence <= 'd0;
    end
end

/********************** MAC 层 TYPE 信号解析 ********************************/

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_type <= 16'd0;
    end
    else if (state_c == TYPE && ri_mac_axi_data_valid) begin
        r_post_type <= {r_post_type[7:0],ri_mac_axi_data};
    end
    else begin
        r_post_type <= 16'd0;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_type_valid <= 'd0;
    end
    else if (state_c == TYPE && r_type_cnt == 2'd1) begin
        r_post_type_valid <= 'd1;
    end
    else begin
        r_post_type_valid <= 'd0;
    end
end

// TYPE 状态计数器 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_type_cnt <= 2'd0;
    end
    else if(r_type_cnt >= 2'd1) begin
        r_type_cnt <= 2'd0;
    end
    else if (state_c == TYPE && ri_mac_axi_data_valid) begin
        r_type_cnt <= r_type_cnt + 1'b1;
    end
    else begin
        r_type_cnt <= 2'd0;
    end
end

/********************** MAC 层 DATA 信号解析 ********************************/
 
// r_post_data
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_data <= 'd0;
    end
    else begin
        r_post_data <= ri_mac_axi_data_5d;
    end
end

// r_post_data_vld
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_data_vld <= 'd0;
    end
    else if (r_din_5d_cnt == 16'd8) begin
        r_post_data_vld <= 'd1;
    end
    else if (ri_mac_axi_data_valid_1d == 'd0 && ri_mac_axi_data_valid_2d == 1) begin
        r_post_data_vld <= 'd0;
    end 
end

// r_post_last
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_last <= 'd0;
    end
    else if (ri_mac_axi_data_valid == 'd0 && ri_mac_axi_data_valid_1d==1) begin
        r_post_last <= 'd1;
    end
    else begin
        r_post_last <= 'd0;
    end
end

/********************** 其他输出信号处理 ********************************/
// r_frm_qbu - 关键帧标志（基于SMD类型判断）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_frm_qbu <= 'd0;
    end
    else if (state_c == SFD) begin
        r_frm_qbu <= 1'b1;  
    end
    else if (state_c == IDLE) begin
        r_frm_qbu <= 'd0;
    end
end

// r_frm_discard - 帧丢弃标志（基于CRC错误）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_frm_discard <= 'd0;
    end
    else if (r_crc_err) begin
        r_frm_discard <= 1'b1;
    end
    else if (state_c == IDLE) begin
        r_frm_discard <= 'd0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_emac_info_flag <= 1'b0;
    end
    else begin
        r_emac_info_flag <= state_c == HEAD_7 && (head_72SFD_start == 1'b1) ? 1'b1 : r_post_last ? 1'd0 : r_emac_info_flag;
    end
end 
 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_pmac_info_flag <= 1'b0;
    end
    else begin
        r_pmac_info_flag <= state_c == HEAD_7 && (head_72SMD_S_start == 1'b1) ? 1'b1 : r_post_last ? 1'd0 : r_pmac_info_flag;
    end
end
 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_emac_info_valid <= 1'b0;
        r_pmac_info_valid <= 1'b0;
    end
    else begin
        r_emac_info_valid <= state_n[16] == 1'd1 && state_c[16] != 1'd1 && r_emac_info_flag == 1'd1 ? 1'd1 : 1'd0;
        r_pmac_info_valid <= state_n[16] == 1'd1 && state_c[16] != 1'd1 && r_pmac_info_flag == 1'd1 ? 1'd1 : 1'd0;
    end
end


// 默认VLAN ID配置打拍，复位时使用参数默认值
always @(posedge i_clk) begin
    if (i_rst) begin
        r_default_vlan_id <= LP_DEFAULT_VLAN_ID;
    end else begin
        r_default_vlan_id <= (i_default_vlan_valid == 1'b1) ? i_default_vlan_id :
                             r_default_vlan_id;
    end
end

// 默认VLAN优先级配置打拍，复位时使用参数默认值
always @(posedge i_clk) begin
    if (i_rst) begin
        r_default_vlan_pri <= LP_DEFAULT_VLAN_PRI;
    end else begin
        r_default_vlan_pri <= (i_default_vlan_valid == 1'b1) ? i_default_vlan_pri :
                              r_default_vlan_pri;
    end
end

/*************************** 基础模板 *************************************/   
/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        
    end
    else if () begin
        
    end
    else begin
        
    end
end

*/




  


// wire [73:0]    probe0;

// assign probe0 = {
// i_mac_axi_data,
// i_mac_axi_data_valid,
// o_post_type,    
// o_post_type_valid,
// o_SMD_type,
// o_SMD_type_vld,    
// o_frag_cnt,   
// o_frag_cnt_vld,    
// o_crc_vld,   
// o_crc_err,        
// o_post_data,       
// o_post_last,       
// o_post_data_len,   
// o_post_data_len_vld,
// o_post_data_vld
// };


// ila_1_p inst_ila_1 (
//     .clk(i_clk), // input wire clk
//     .probe0(probe0)
// );



endmodule
