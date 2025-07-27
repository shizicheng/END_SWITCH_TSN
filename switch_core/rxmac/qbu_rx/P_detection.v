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
    parameter   DWIDTH          = 'd8                                   ,
                P_SOURCE_MAC    = {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00} 
)(
    input       wire                        i_clk                       ,
    input       wire                        i_rst                       ,
    // input       wire    [8 - 1:0]           i_mac_axi_data                       ,
    // input       wire                        i_mac_axi_data_valid                      ,
    input       wire [DWIDTH-1:0]           i_mac_axi_data              ,
    input       wire [(DWIDTH/8)-1:0]       i_mac_axi_data_keep         ,
    input       wire                        i_mac_axi_data_valid        ,
    output      wire                        o_mac_axi_data_ready        ,
    input       wire                        i_mac_axi_data_last         ,
    // info fifo output port       
    output      wire    [47:0]              o_target_mac                , 
    output      wire                        o_target_mac_valid          ,
    output      wire    [47:0]              o_source_mac                ,
    output      wire                        o_source_mac_valid          ,
    output      wire    [15:0]              o_post_type                 ,
    output      wire                        o_post_type_valid           ,
    output      wire    [7:0]               o_SMD_type                  ,
    output      wire                        o_SMD_type_vld              ,
    output      wire    [7:0]               o_frag_cnt                  ,
    output      wire                        o_frag_cnt_vld              ,
    output      wire    [1:0]               o_crc_vld                   , // CRC 检测 0bit 是 CRC 有效位，1bit 是 mCRC 有效位
    output      wire                        o_crc_err                   ,
    // data port 
    output      wire    [8 - 1:0]           o_post_data                 ,
    output      wire                        o_post_last                 ,
    output      wire    [15:0]              o_post_data_len             ,
    output      wire                        o_post_data_len_vld         ,
    output      wire                        o_post_data_vld             ,
    //寄存器端口
    output      wire    [15:0]              o_rx_frames_cnt             ,
    output      wire    [15:0]              o_err_rx_crc_cnt            ,
    output      wire                        o_rx_busy                       
);
/***************function**************/

/***************parameter*************/
// IDLE HEAD_1 HEAD_2 HEAD_3 HEAD_4 HEAD_5 HEAD_6 HEAD_7 SMD_S SMD_C Frag SFD MACD MACS TYPE WATIE DATA CRC
localparam  IDLE        =      18'b00_0000_0000_0000_0001   ;
localparam  HEAD_1      =      18'b00_0000_0000_0000_0010   ;
localparam  HEAD_2      =      18'b00_0000_0000_0000_0100   ;
localparam  HEAD_3      =      18'b00_0000_0000_0000_1000   ;
localparam  HEAD_4      =      18'b00_0000_0000_0001_0000   ;
localparam  HEAD_5      =      18'b00_0000_0000_0010_0000   ;
localparam  HEAD_6      =      18'b00_0000_0000_0100_0000   ;
localparam  HEAD_7      =      18'b00_0000_0000_1000_0000   ;
localparam  SMD_S       =      18'b00_0000_0001_0000_0000   ;
localparam  SMD_C       =      18'b00_0000_0010_0000_0000   ;
localparam  Frag        =      18'b00_0000_0100_0000_0000   ;
localparam  MACD        =      18'b00_0000_1000_0000_0000   ;
localparam  MACS        =      18'b00_0001_0000_0000_0000   ;
localparam  TYPE        =      18'b00_0010_0000_0000_0000   ;
localparam  DATA        =      18'b00_0100_0000_0000_0000   ;
localparam  CRC         =      18'b00_1000_0000_0000_0000   ;
localparam  WATIE       =      18'b01_0000_0000_0000_0000   ;
localparam  SFD         =      18'b10_0000_0000_0000_0000   ;

localparam  MCRC_P      =      32'h0000ffff                 ;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg     [17:0]              state_n,state_c                 ;
reg     [47:0]              r_source_mac                    ;
reg     [7:0]               ri_mac_axi_data                           ;
reg                         ri_mac_axi_data_valid                          ;
reg     [7:0]               ri_mac_axi_data_1d                        ;
reg     [7:0]               ri_mac_axi_data_2d                        ;
reg     [7:0]               ri_mac_axi_data_3d                        ;
reg     [7:0]               ri_mac_axi_data_4d                        ;
reg     [7:0]               ri_mac_axi_data_5d                        ;
reg                         ri_mac_axi_data_valid_1d                       ;
reg                         ri_mac_axi_data_valid_2d                       ;
reg                         ri_mac_axi_data_valid_3d                       ;
reg                         ri_mac_axi_data_valid_4d                       ;
reg                         ri_mac_axi_data_valid_5d                       ;
reg                         ri_mac_axi_data_valid_6d                       ;
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
reg                         r_post_data_len_vld             ;

//寄存器
reg     [15:0]              r_rx_frames_cnt                 ;
reg     [15:0]              ro_err_rx_crc_cnt               ;
// reg     [15:0]              ro_err_rx_frame_cnt             ;

/***************wire******************/
wire                        idle2head_1_start               ;
wire                        head_12head_2_start             ;
wire                        head_22head_3_start             ;
wire                        head_32head_4_start             ;
wire                        head_42head_5_start             ;
wire                        head_52head_6_start             ;
wire                        head_62head_7_start             ;
wire                        head_62SMD_S_start              ;
wire                        head_62SMD_C_start              ;
wire                        SMD_S2_MACD_start               ;
wire                        head_72SFD_start                ;
wire                        SFD2MACD_start                  ;
wire                        MACD2MACS_start                 ;
wire                        MACS2TYPE_start                 ;
wire                        TYPE2WATIE_start                ;
wire                        WATIE2DATA_start                ;
wire                        DATA2CRC_start                  ;
wire                        CRC2IDLE_start                  ;
wire    [31:0]              w_o_crc_result                  ;
wire                        Frag2MACD_start                 ;
wire                        head_72SMD_S_start              ;
wire                        SMD_C2Frag_start                ;

/***************component*************/
CRC32_D8 CRC32_D8_u0 (
  .i_clk            (i_clk              )                   ,
  .i_rst            (r_crc_rst          )                   ,
  .i_en             (r_crc_en           )                   ,
  .i_data           (ri_mac_axi_data_4d           )                   ,
  .o_crc            (w_o_crc_result     )   
);

/***************assign****************/
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

assign o_rx_frames_cnt          =       r_rx_frames_cnt       ;
assign o_err_rx_crc_cnt         =       ro_err_rx_crc_cnt     ;
// assign o_err_rx_frame_cnt       =       ro_err_rx_frame_cnt   ;
assign o_rx_busy                =       ri_mac_axi_data_valid                ;
assign o_mac_axi_data_ready     = ~ri_mac_axi_data_valid ;  //需要验证
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
            else begin
                state_n = state_c;
            end
        end
        TYPE: begin
            if (TYPE2WATIE_start) begin
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
assign Frag2MACD_start      =   state_c == Frag     &&    i_mac_axi_data_valid                                                  ; 
assign SMD_S2_MACD_start    =   state_c == SMD_S    &&    i_mac_axi_data_valid                                                  ;
assign head_72SFD_start     =   state_c == HEAD_7   &&    i_mac_axi_data_valid                                                  ;
assign SFD2MACD_start       =   state_c == SFD      &&    i_mac_axi_data_valid                                                  ;
assign MACD2MACS_start      =   state_c == MACD     &&    (ri_mac_axi_data_valid && r_rec_macd_cnt == 'd5)                       ;
assign MACS2TYPE_start      =   state_c == MACS     &&    (ri_mac_axi_data_valid && r_rec_macs_cnt == 'd5)                       ;
assign TYPE2WATIE_start     =   state_c == TYPE     &&    i_mac_axi_data_valid &&  r_din_5d_cnt == 'd16                                               ;
assign WATIE2DATA_start     =   state_c == WATIE    &&    r_din_5d_cnt == 'd21                                    ;
assign DATA2CRC_start       =   state_c == DATA     &&    !i_mac_axi_data_valid && ri_mac_axi_data_valid                                       ;
assign CRC2IDLE_start       =   state_c == CRC      &&    r_crc_valid == 1'b1                                     ; 
/***************always****************/
/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
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
        ri_mac_axi_data_valid      <=      'd0;
        ri_mac_axi_data            <=      'd0;
        ri_mac_axi_data_1d         <=      'd0;   
        ri_mac_axi_data_2d         <=      'd0;   
        ri_mac_axi_data_3d         <=      'd0;   
        ri_mac_axi_data_4d         <=      'd0;
        ri_mac_axi_data_5d         <=      'd0;
        ri_mac_axi_data_valid_1d   <=      'd0;
        ri_mac_axi_data_valid_2d   <=      'd0;
        ri_mac_axi_data_valid_3d   <=      'd0;
        ri_mac_axi_data_valid_4d   <=      'd0;
        ri_mac_axi_data_valid_5d   <=      'd0;
        ri_mac_axi_data_valid_6d   <=      'd0;
    end
    else begin
        ri_mac_axi_data_valid      <=      i_mac_axi_data_valid;
        ri_mac_axi_data            <=      i_mac_axi_data;
        ri_mac_axi_data_1d         <=      ri_mac_axi_data;
        ri_mac_axi_data_2d         <=      ri_mac_axi_data_1d;
        ri_mac_axi_data_3d         <=      ri_mac_axi_data_2d;
        ri_mac_axi_data_4d         <=      ri_mac_axi_data_3d;
        ri_mac_axi_data_5d         <=      ri_mac_axi_data_4d;
        ri_mac_axi_data_valid_1d   <=      ri_mac_axi_data_valid;
        ri_mac_axi_data_valid_2d   <=      ri_mac_axi_data_valid_1d;
        ri_mac_axi_data_valid_3d   <=      ri_mac_axi_data_valid_2d;
        ri_mac_axi_data_valid_4d   <=      ri_mac_axi_data_valid_3d;
        ri_mac_axi_data_valid_5d   <=      ri_mac_axi_data_valid_4d;
        ri_mac_axi_data_valid_6d   <=      ri_mac_axi_data_valid_5d;
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

/********************** MAC 层 TYPE 信号解析 ********************************/
// r_post_type             
// r_post_type_valid
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_type <= 'd0;
    end
    else if (state_c == TYPE && ri_mac_axi_data_valid) begin
        r_post_type <= {r_post_type[7:0],ri_mac_axi_data};
    end
    else begin
        r_post_type <= r_post_type;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_type_valid <= 'd0;
    end
    else if (r_din_5d_cnt=='d16) begin
        r_post_type_valid <= 'd1;
    end
    else begin
        r_post_type_valid <= 'd0;
    end
end

/********************** MAC 层 DATA 信号解析 ********************************/
/*  r_post_data    
    r_post_data_vld */
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_data <= 'd0;
        r_post_data_vld <= 'd0;
    end
    else if (r_din_5d_cnt == 'd22) begin
        r_post_data <= ri_mac_axi_data_5d;
        r_post_data_vld <= 'd1;
    end
    else if (ri_mac_axi_data_valid_1d == 'd0 && ri_mac_axi_data_valid_2d==1 ) begin
        r_post_data <= ri_mac_axi_data_5d;
        r_post_data_vld <= 'd0;
    end
    else begin
        r_post_data <= ri_mac_axi_data_5d;
        r_post_data_vld <= r_post_data_vld;
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
