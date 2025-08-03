// FPGA开发组 - 状态机模板

`timescale 1ns / 1ps

module fram #(
    parameter       DWIDTH     =   'd8
)(
    input         wire                                          i_clk                 ,
    input         wire                                          i_rst                 ,
    //Data_diver
    input         wire    [DWIDTH - 1:0]                        i_rx_axis_data        ,//数据信号  
    input         wire    [15:0]                                i_rx_axis_user        ,//数据信息(i_info_vld,i_smd_type,i_frag_cnt,i_crc_vld,3'b0)
    input         wire    [(DWIDTH/8)-1:0]                      i_rx_axis_keep        ,//数据掩码  
    input         wire                                          i_rx_axis_last        ,//数据截至信号
    input         wire                                          i_rx_axis_valid       ,//数据有效信号
    // info port
    output        wire                                          o_rx_axis_ready       ,//准备信号              
    //SGRAM
    output        wire    [DWIDTH - 1:0]                        o_sgram_rx_axis_data  ,//数据信号  
    output        wire    [15:0]                                o_sgram_rx_axis_user  ,//数据信息{r_data_start,r_data_end,r_data_complete,'b0} 
    output        wire    [(DWIDTH/8)-1:0]                      o_sgram_rx_axis_keep  ,//数据掩码   
    output        wire                                          o_sgram_rx_axis_last  ,//数据截至信
    output        wire                                          o_sgram_rx_axis_valid ,//数据有效信
    input         wire                                          i_sgram_rx_axis_ready , //准备信号 
    output        reg                                           o_data_start          , //数据起点
    output        reg                                           o_data_end            , //数据截至点
    output        reg                                           o_data_complete       , //数据完整标志1完整，0不完整；r_data_end为高时有效。
    
    output        wire    [ 7:0]                                o_frag_next_rx        ,
    output        wire    [15:0]                                o_rx_fragment_cnt     , //当前接收的片段计数器
    output        wire    [ 7:0]                                o_frame_seq           ,
    output        wire    [15:0]                                o_err_rx_frame_cnt    ,  //smd错误计数 err_fragment_cnt
    output        wire    [15:0]                                o_err_fragment_cnt    ,
    output        wire                                          o_rx_fragment_mismatch
    );




//STATE
parameter           IDLE            =        22'b00_0000_0000_0000_0000_0001;

parameter           SMD_S0          =        22'b00_0000_0000_0000_0000_0010;
parameter           SMD_S1          =        22'b00_0000_0000_0000_0000_0100;
parameter           SMD_S2          =        22'b00_0000_0000_0000_0000_1000;
parameter           SMD_S3          =        22'b00_0000_0000_0000_0001_0000;

parameter           SMD_C0_0        =        22'b00_0000_0000_0000_0010_0000;
parameter           SMD_C0_1        =        22'b00_0000_0000_0000_0100_0000;
parameter           SMD_C0_2        =        22'b00_0000_0000_0000_1000_0000;
parameter           SMD_C0_3        =        22'b00_0000_0000_0001_0000_0000;

parameter           SMD_C1_0        =        22'b00_0000_0000_0010_0000_0000;
parameter           SMD_C1_1        =        22'b00_0000_0000_0100_0000_0000;
parameter           SMD_C1_2        =        22'b00_0000_0000_1000_0000_0000;
parameter           SMD_C1_3        =        22'b00_0000_0001_0000_0000_0000;

parameter           SMD_C2_0        =        22'b00_0000_0010_0000_0000_0000;
parameter           SMD_C2_1        =        22'b00_0000_0100_0000_0000_0000;
parameter           SMD_C2_2        =        22'b00_0000_1000_0000_0000_0000;
parameter           SMD_C2_3        =        22'b00_0001_0000_0000_0000_0000;

parameter           SMD_C3_0        =        22'b00_0010_0000_0000_0000_0000;
parameter           SMD_C3_1        =        22'b00_0100_0000_0000_0000_0000;
parameter           SMD_C3_2        =        22'b00_1000_0000_0000_0000_0000;
parameter           SMD_C3_3        =        22'b01_0000_0000_0000_0000_0000;

parameter           ERR             =        22'b10_0000_0000_0000_0000_0000;


//SMD
parameter           S0_SMD        =        8'he6;
parameter           S1_SMD        =        8'h4c;
parameter           S2_SMD        =        8'h7f;
parameter           S3_SMD        =        8'hb3;

parameter           C0_SMD        =        8'h61;
parameter           C1_SMD        =        8'h52;
parameter           C2_SMD        =        8'h9E;
parameter           C3_SMD        =        8'h2A;

//CRC
parameter           MCRC          =        2'b10;
parameter           CRC           =        2'b01;

//FRAG
parameter           FRAG_0        =        2'b00;
parameter           FRAG_1        =        2'b01;
parameter           FRAG_2        =        2'b10;
parameter           FRAG_3        =        2'b11;

parameter           FRAG_C_0      =        8'hE6   ;
parameter           FRAG_C_1      =        8'h4C   ;
parameter           FRAG_C_2      =        8'h7F   ;
parameter           FRAG_C_3      =        8'hB3   ;



reg    [DWIDTH - 1:0]               r_rx_axis_data        ;
reg    [15:0]                       r_rx_axis_user        ;
reg    [(DWIDTH/8)-1:0]             r_rx_axis_keep        ;
reg                                 r_rx_axis_last        ;
reg                                 r_rx_axis_valid       ;

reg    [DWIDTH - 1:0]               rr_rx_axis_data       ;
reg    [15:0]                       rr_rx_axis_user       ;
reg    [(DWIDTH/8)-1:0]             rr_rx_axis_keep       ;
reg                                 rr_rx_axis_last       ;
reg                                 rr_rx_axis_valid      ;


//预期接收片段编号
reg    [ 7:0]                       r_frag_next_rx        ;
wire                                w_smd_ok_flag         ;
reg    [ 7:0]                       r_frame_seq           ;  //当前SMD
// reg    [ 7:0]                       r_frame_seq_next      ;  //下一个SMD
// reg    [ 2:0]                       r_frame_seq_next_cnt  ;
reg                                 r_smd_err_flag        ;









reg      [1:0]     r_crc_vld                ;// CRC 检测 0bit 是 CRC 有效位，1bit 是 mCRC 有效位
reg                r_info_vld               ;
reg                rr_info_vld              ;
reg      [1:0]     rr_crc_vld               ;
reg     [15:0]     ro_err_rx_frame_cnt      ;
reg     [15:0]     ro_rx_fragment_cnt       ;
reg     [15:0]     ro_err_fragment_cnt      ;
reg                ro_rx_fragment_mismatch  ;

reg                 r_data_start_flag;

reg                 CRC_pre; 

reg    [21:0]       state_c;
reg    [21:0]       state_n;

reg    [ 7:0]       ri_smd_type;
reg                 rrr_rx_axis_last;

/***********************************
i_smd_type
i_frag_cnt
i_crc_vld 
i_info_vld
与输入信号同步

***********************************/
wire           [7:0]                          i_smd_type        ;
wire           [1:0]                          i_frag_cnt        ;
wire           [1:0]                          i_crc_vld         ;// CRC 检测 0bit 是 CRC 有效位，1bit 是 mCRC 有效位
wire                                          i_info_vld        ;

//状态跳转  IDLE   
wire      IDLE_to_SMD_S0                   ;
wire      IDLE_to_SMD_S1                   ;
wire      IDLE_to_SMD_S2                   ;
wire      IDLE_to_SMD_S3                   ;
wire      IDLE_to_ERR                      ;
//状态跳转  SMD_S0       
wire      SMD_S0_to_SMD_C0_0               ;
wire      SMD_S0_to_SMD_S1                 ;
wire      SMD_S0_to_SMD_S2                 ;
wire      SMD_S0_to_SMD_S3                 ;
wire      SMD_S0_to_ERR                    ;
//状态跳转  SMD_S1   
wire      SMD_S1_to_SMD_C1_0               ;
wire      SMD_S1_to_SMD_S0                 ;
wire      SMD_S1_to_SMD_S2                 ;
wire      SMD_S1_to_SMD_S3                 ;
wire      SMD_S1_to_ERR                    ;
//状态跳转  SMD_S2   
wire      SMD_S2_to_SMD_C2_0               ;
wire      SMD_S2_to_SMD_S0                 ;
wire      SMD_S2_to_SMD_S1                 ;
wire      SMD_S2_to_SMD_S3                 ;
wire      SMD_S2_to_ERR                    ;
//状态跳转  SMD_S3   
wire      SMD_S3_to_SMD_C3_0               ;
wire      SMD_S3_to_SMD_S0                 ;
wire      SMD_S3_to_SMD_S1                 ;
wire      SMD_S3_to_SMD_S2                 ;
wire      SMD_S3_to_ERR                    ;

//状态跳转  SMD_C0_0 
wire      SMD_C0_0_to_SMD_C0_1             ;
wire      SMD_C0_0_to_SMD_S0               ;
wire      SMD_C0_0_to_SMD_S1               ;
wire      SMD_C0_0_to_SMD_S2               ;
wire      SMD_C0_0_to_SMD_S3               ;
wire      SMD_C0_0_to_ERR                  ;
//状态跳转  SMD_C0_1 
wire      SMD_C0_1_to_SMD_C0_2             ;
wire      SMD_C0_1_to_SMD_S0               ;
wire      SMD_C0_1_to_SMD_S1               ;
wire      SMD_C0_1_to_SMD_S2               ;
wire      SMD_C0_1_to_SMD_S3               ;
wire      SMD_C0_1_to_ERR                  ;
//状态跳转  SMD_C0_2 
wire      SMD_C0_2_to_SMD_C0_3             ;
wire      SMD_C0_2_to_SMD_S0               ;
wire      SMD_C0_2_to_SMD_S1               ;
wire      SMD_C0_2_to_SMD_S2               ;
wire      SMD_C0_2_to_SMD_S3               ;
wire      SMD_C0_2_to_ERR                  ;
//状态跳转  SMD_C0_3 
wire      SMD_C0_3_to_SMD_C0_0             ;
wire      SMD_C0_3_to_SMD_S0               ;
wire      SMD_C0_3_to_SMD_S1               ;
wire      SMD_C0_3_to_SMD_S2               ;
wire      SMD_C0_3_to_SMD_S3               ;
wire      SMD_C0_3_to_ERR                  ;

//状态跳转  SMD_C1_0 
wire      SMD_C1_0_to_SMD_C1_1             ;
wire      SMD_C1_0_to_SMD_S0               ;
wire      SMD_C1_0_to_SMD_S1               ;
wire      SMD_C1_0_to_SMD_S2               ;
wire      SMD_C1_0_to_SMD_S3               ;
wire      SMD_C1_0_to_ERR                  ;
//状态跳转  SMD_C1_1 
wire      SMD_C1_1_to_SMD_C1_2             ;
wire      SMD_C1_1_to_SMD_S0               ;
wire      SMD_C1_1_to_SMD_S1               ;
wire      SMD_C1_1_to_SMD_S2               ;
wire      SMD_C1_1_to_SMD_S3               ;
wire      SMD_C1_1_to_ERR                  ; 
//状态跳转  SMD_C1_2 
wire      SMD_C1_2_to_SMD_C1_3             ;
wire      SMD_C1_2_to_SMD_S0               ;
wire      SMD_C1_2_to_SMD_S1               ;
wire      SMD_C1_2_to_SMD_S2               ;
wire      SMD_C1_2_to_SMD_S3               ;
wire      SMD_C1_2_to_ERR                  ; 
//状态跳转  SMD_C1_3 
wire      SMD_C1_3_to_SMD_C1_0             ;
wire      SMD_C1_3_to_SMD_S0               ;
wire      SMD_C1_3_to_SMD_S1               ;
wire      SMD_C1_3_to_SMD_S2               ;
wire      SMD_C1_3_to_SMD_S3               ;
wire      SMD_C1_3_to_ERR                  ;

//状态跳转  SMD_C2_0 
wire      SMD_C2_0_to_SMD_C2_1             ;
wire      SMD_C2_0_to_SMD_S0               ;
wire      SMD_C2_0_to_SMD_S1               ;
wire      SMD_C2_0_to_SMD_S2               ;
wire      SMD_C2_0_to_SMD_S3               ;
wire      SMD_C2_0_to_ERR                  ;
//状态跳转  SMD_C2_1 
wire      SMD_C2_1_to_SMD_C2_2             ;
wire      SMD_C2_1_to_SMD_S0               ;
wire      SMD_C2_1_to_SMD_S1               ;
wire      SMD_C2_1_to_SMD_S2               ;
wire      SMD_C2_1_to_SMD_S3               ;
wire      SMD_C2_1_to_ERR                  ;
//状态跳转  SMD_C2_2 
wire      SMD_C2_2_to_SMD_C2_3             ;
wire      SMD_C2_2_to_SMD_S0               ;
wire      SMD_C2_2_to_SMD_S1               ;
wire      SMD_C2_2_to_SMD_S2               ;
wire      SMD_C2_2_to_SMD_S3               ;
wire      SMD_C2_2_to_ERR                  ;
//状态跳转  SMD_C2_3 
wire      SMD_C2_3_to_SMD_C2_0             ;
wire      SMD_C2_3_to_SMD_S0               ;
wire      SMD_C2_3_to_SMD_S1               ;
wire      SMD_C2_3_to_SMD_S2               ;
wire      SMD_C2_3_to_SMD_S3               ;
wire      SMD_C2_3_to_ERR                  ;

//状态跳转  SMD_C3_0 
wire      SMD_C3_0_to_SMD_C3_1             ;
wire      SMD_C3_0_to_SMD_S0               ;
wire      SMD_C3_0_to_SMD_S1               ;
wire      SMD_C3_0_to_SMD_S2               ;
wire      SMD_C3_0_to_SMD_S3               ;
wire      SMD_C3_0_to_ERR                  ;
//状态跳转  SMD_C3_1 
wire      SMD_C3_1_to_SMD_C3_2             ;
wire      SMD_C3_1_to_SMD_S0               ;
wire      SMD_C3_1_to_SMD_S1               ;
wire      SMD_C3_1_to_SMD_S2               ;
wire      SMD_C3_1_to_SMD_S3               ;
wire      SMD_C3_1_to_ERR                  ;
//状态跳转  SMD_C3_2 
wire      SMD_C3_2_to_SMD_C3_3             ;
wire      SMD_C3_2_to_SMD_S0               ;
wire      SMD_C3_2_to_SMD_S1               ;
wire      SMD_C3_2_to_SMD_S2               ;
wire      SMD_C3_2_to_SMD_S3               ;
wire      SMD_C3_2_to_ERR                  ;
//状态跳转  SMD_C3_3 
wire      SMD_C3_3_to_SMD_C3_0             ;
wire      SMD_C3_3_to_SMD_S0               ;
wire      SMD_C3_3_to_SMD_S1               ;
wire      SMD_C3_3_to_SMD_S2               ;
wire      SMD_C3_3_to_SMD_S3               ;
wire      SMD_C3_3_to_ERR                  ;

//状态跳转  ERR 
wire      ERR_to_IDLE                      ;




assign i_smd_type = i_rx_axis_valid ? i_rx_axis_user[14:7] : 0;
assign i_frag_cnt = i_rx_axis_valid ? i_rx_axis_user[6:5] : 0;
assign i_crc_vld  = i_rx_axis_valid ? i_rx_axis_user[4:3] : 0;
assign i_info_vld = i_rx_axis_valid&&r_rx_axis_valid==0 ? i_rx_axis_user[15] : 0;//只保持一个时钟周期有效制约状态机的跳转
assign w_smd_ok_flag = state_c == SMD_S0 && i_smd_type==C0_SMD || state_c == SMD_S1 && i_smd_type==C1_SMD || state_c == SMD_S2 && i_smd_type==C2_SMD || state_c == SMD_S3 && i_smd_type==C3_SMD;
assign o_frag_next_rx = r_frag_next_rx;
assign o_frame_seq = r_frame_seq;
assign o_err_rx_frame_cnt = ro_err_rx_frame_cnt;
assign o_rx_fragment_cnt = ro_rx_fragment_cnt;
assign o_err_fragment_cnt = ro_err_fragment_cnt;
assign o_rx_fragment_mismatch = ro_rx_fragment_mismatch;


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_smd_err_flag<='b0;
    end
    else if (state_n == ERR && state_c != ERR) begin
        r_smd_err_flag<=1'b1;
    end
    else begin
        r_smd_err_flag<='b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin //当前的SMD值
    if (i_rst == 1'b1) begin
        r_frame_seq <= 'd0;
    end
    else if(i_info_vld)begin
        r_frame_seq <= i_smd_type; 
    end
end


always @(posedge i_clk or posedge i_rst) begin //当前的SMD值
    if (i_rst == 1'b1) begin
        ro_err_rx_frame_cnt <= 'd0;
    end
    else if(r_smd_err_flag)begin
        ro_err_rx_frame_cnt <= ro_err_rx_frame_cnt + 1'b1; 
    end
end

always @(*) begin
    if (i_rst == 1'b1) begin
        r_frag_next_rx <= FRAG_C_0;
    end
    else if(o_data_end & o_data_complete) begin
        r_frag_next_rx <= FRAG_C_0;
    end
    else if(i_frag_cnt == 'd0 & r_info_vld & r_data_start_flag) begin
        r_frag_next_rx <= FRAG_C_1;
    end
    else if(i_frag_cnt == 'd1 & r_info_vld & r_data_start_flag)begin
        r_frag_next_rx <= FRAG_C_2;
    end
    else if(i_frag_cnt == 'd2 & r_info_vld & r_data_start_flag)begin
        r_frag_next_rx <= FRAG_C_3;
    end
    else if(i_frag_cnt == 'd3 & r_info_vld & r_data_start_flag)begin
        r_frag_next_rx <= FRAG_C_0; 
    end
end


always @(posedge i_clk or posedge i_rst) begin //当前的接收片段计数器
    if (i_rst == 1'b1) begin
        ro_rx_fragment_cnt <= 'd0;
    end
    else if(r_data_start_flag && (i_frag_cnt == 'd0 || i_frag_cnt == 'd1 || i_frag_cnt == 'd2 || i_frag_cnt == 'd3) && i_info_vld && !o_data_complete)begin
        ro_rx_fragment_cnt <= ro_rx_fragment_cnt + 1'b1; 
    end
end
// reg r_rx_valid;
// always @(posedge i_clk or posedge i_rst) begin
//     if (i_rst == 1'b1) begin
//         r_rx_valid <= 'd0;
//     end
//     else if(i_rx_axis_valid && !r_rx_axis_valid)begin
//         r_rx_valid <= 1'b1;
//     end
//     else begin
//         r_rx_valid <= 'd0;
//     end
// end
wire w_rx_valid;
assign  w_rx_valid = i_rx_axis_valid && !r_rx_axis_valid ? 1'b1 : 1'b0;
always @(posedge i_clk or posedge i_rst) begin 
    if (i_rst == 1'b1) begin
        ro_err_fragment_cnt <= 'd0;
        ro_rx_fragment_mismatch <= 'd0;
    end
    else if(i_frag_cnt == 'd0 && r_frag_next_rx != FRAG_C_0 &i_info_vld)begin
        ro_err_fragment_cnt <= ro_err_fragment_cnt + 1'b1;
        ro_rx_fragment_mismatch <= 1'b1; 
    end
    else if(i_frag_cnt == 'd1 && r_frag_next_rx != FRAG_C_1 &i_info_vld)begin
        ro_err_fragment_cnt <= ro_err_fragment_cnt + 1'b1; 
        ro_rx_fragment_mismatch <= 1'b1; 
    end
    else if(i_frag_cnt == 'd2 && r_frag_next_rx != FRAG_C_2 &i_info_vld)begin
        ro_err_fragment_cnt <= ro_err_fragment_cnt + 1'b1; 
        ro_rx_fragment_mismatch <= 1'b1; 
    end
    else if(i_frag_cnt == 'd3 && r_frag_next_rx != FRAG_C_3 &i_info_vld)begin
        ro_err_fragment_cnt <= ro_err_fragment_cnt + 1'b1; 
        ro_rx_fragment_mismatch <= 1'b1; 
    end
    else begin
        ro_rx_fragment_mismatch <= 1'b0; 
    end
end

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
always @(*) begin
    case(state_c)
        IDLE: begin
            if (IDLE_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(IDLE_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(IDLE_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(IDLE_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(IDLE_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_S0: begin
            if (SMD_S0_to_SMD_C0_0) begin
                state_n =SMD_C0_0 ;
            end
            else if(SMD_S0_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_S0_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_S0_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_S0_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_S1: begin
            if (SMD_S1_to_SMD_C1_0) begin
                state_n =SMD_C1_0 ;
            end
            else if(SMD_S1_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_S1_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_S1_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_S1_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_S2: begin
            if (SMD_S2_to_SMD_C2_0) begin
                state_n =SMD_C2_0 ;
            end
            else if(SMD_S2_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_S2_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_S2_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_S2_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_S3: begin
            if (SMD_S3_to_SMD_C3_0) begin
                state_n =SMD_C3_0 ;
            end
            else if(SMD_S3_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_S3_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_S3_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_S3_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C0_0: begin
            if (SMD_C0_0_to_SMD_C0_1) begin
                state_n =SMD_C0_1 ;
            end
            else if(SMD_C0_0_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C0_0_to_SMD_S1) begin
                state_n =SMD_S1 ;  
            end
            else if(SMD_C0_0_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C0_0_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C0_0_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C0_1: begin
            if (SMD_C0_1_to_SMD_C0_2) begin
                state_n =SMD_C0_2 ;
            end
            else if(SMD_C0_1_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C0_1_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C0_1_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C0_1_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C0_1_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end 
        SMD_C0_2: begin
            if (SMD_C0_2_to_SMD_C0_3) begin
                state_n =SMD_C0_3 ;
            end
            else if(SMD_C0_2_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C0_2_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C0_2_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C0_2_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C0_2_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C0_3: begin
            if (SMD_C0_3_to_SMD_C0_0) begin
                state_n =SMD_C0_0 ;
            end
            else if(SMD_C0_3_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C0_3_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C0_3_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C0_3_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C0_3_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C1_0: begin
            if (SMD_C1_0_to_SMD_C1_1) begin
                state_n =SMD_C1_1 ;
            end
            else if(SMD_C1_0_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C1_0_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C1_0_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C1_0_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C1_0_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C1_1: begin
            if (SMD_C1_1_to_SMD_C1_2) begin
                state_n =SMD_C1_2 ;
            end
            else if(SMD_C1_1_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C1_1_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C1_1_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C1_1_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C1_1_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C1_2: begin
            if (SMD_C1_2_to_SMD_C1_3) begin
                state_n =SMD_C1_3 ;
            end
            else if(SMD_C1_2_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C1_2_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C1_2_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C1_2_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C1_2_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C1_3: begin
            if (SMD_C1_3_to_SMD_C1_0) begin
                state_n =SMD_C1_0 ;
            end
            else if(SMD_C1_3_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C1_3_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C1_3_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C1_3_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C1_3_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C2_0: begin
            if (SMD_C2_0_to_SMD_C2_1) begin
                state_n =SMD_C2_1 ;
            end
            else if(SMD_C2_0_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C2_0_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C2_0_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C2_0_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C2_0_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C2_1: begin
            if (SMD_C2_1_to_SMD_C2_2) begin
                state_n =SMD_C2_2 ;
            end
            else if(SMD_C2_1_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C2_1_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C2_1_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C2_1_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C2_1_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C2_2: begin
            if (SMD_C2_2_to_SMD_C2_3) begin
                state_n =SMD_C2_3 ;
            end
            else if(SMD_C2_2_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C2_2_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C2_2_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C2_2_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C2_2_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C2_3: begin
            if (SMD_C2_3_to_SMD_C2_0) begin
                state_n =SMD_C2_0 ;
            end
            else if(SMD_C2_3_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C2_3_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C2_3_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C2_3_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C2_3_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C3_0: begin
            if (SMD_C3_0_to_SMD_C3_1) begin
                state_n =SMD_C3_1 ;
            end
            else if(SMD_C3_0_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C3_0_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C3_0_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C3_0_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C3_0_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C3_1: begin
            if (SMD_C3_1_to_SMD_C3_2) begin
                state_n =SMD_C3_2 ;
            end
            else if(SMD_C3_1_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C3_1_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C3_1_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C3_1_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C3_1_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C3_2: begin
            if (SMD_C3_2_to_SMD_C3_3) begin
                state_n =SMD_C3_3 ;
            end
            else if(SMD_C3_2_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C3_2_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C3_2_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C3_2_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C3_2_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        SMD_C3_3: begin
            if (SMD_C3_3_to_SMD_C3_0) begin
                state_n =SMD_C3_0 ;
            end
            else if(SMD_C3_3_to_SMD_S0) begin
                state_n =SMD_S0 ;
            end
            else if(SMD_C3_3_to_SMD_S1) begin
                state_n =SMD_S1 ;
            end
            else if(SMD_C3_3_to_SMD_S2) begin
                state_n =SMD_S2 ;
            end
            else if(SMD_C3_3_to_SMD_S3) begin
                state_n =SMD_S3 ;
            end
            else if(SMD_C3_3_to_ERR) begin
                state_n =ERR ;
            end
            else begin
                state_n = state_c;
            end
        end
        ERR: begin
            if (ERR_to_IDLE) begin
                state_n =IDLE ;
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

//更改i_info_vld为只有一个时钟有效防止状态机提前跳转,保证每次只在开头跳
                                    
assign IDLE_to_SMD_S0       = state_c == IDLE     &&   i_info_vld   && i_smd_type==S0_SMD;
assign IDLE_to_SMD_S1       = state_c == IDLE     &&   i_info_vld   && i_smd_type==S1_SMD;
assign IDLE_to_SMD_S2       = state_c == IDLE     &&   i_info_vld   && i_smd_type==S2_SMD;
assign IDLE_to_SMD_S3       = state_c == IDLE     &&   i_info_vld   && i_smd_type==S3_SMD;
assign IDLE_to_ERR          = state_c == IDLE     &&   i_info_vld  ;
                                                                                             
assign SMD_S0_to_SMD_C0_0   = state_c == SMD_S0   && i_info_vld && i_smd_type==C0_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_S0_to_SMD_S1     = state_c == SMD_S0   && i_info_vld && i_smd_type==S1_SMD;
assign SMD_S0_to_SMD_S2     = state_c == SMD_S0   && i_info_vld && i_smd_type==S2_SMD;
assign SMD_S0_to_SMD_S3     = state_c == SMD_S0   && i_info_vld && i_smd_type==S3_SMD;
assign SMD_S0_to_ERR        = state_c == SMD_S0   && i_info_vld ; 
      
assign SMD_S1_to_SMD_C1_0   = state_c == SMD_S1   && i_info_vld && i_smd_type==C1_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_S1_to_SMD_S0     = state_c == SMD_S1   && i_info_vld && i_smd_type==S0_SMD;
assign SMD_S1_to_SMD_S2     = state_c == SMD_S1   && i_info_vld && i_smd_type==S2_SMD;
assign SMD_S1_to_SMD_S3     = state_c == SMD_S1   && i_info_vld && i_smd_type==S3_SMD;
assign SMD_S1_to_ERR        = state_c == SMD_S1   && i_info_vld;
      
assign SMD_S2_to_SMD_C2_0   = state_c == SMD_S2   && i_info_vld && i_smd_type==C2_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_S2_to_SMD_S0     = state_c == SMD_S2   && i_info_vld && i_smd_type==S0_SMD;
assign SMD_S2_to_SMD_S1     = state_c == SMD_S2   && i_info_vld && i_smd_type==S1_SMD;
assign SMD_S2_to_SMD_S3     = state_c == SMD_S2   && i_info_vld && i_smd_type==S3_SMD;
assign SMD_S2_to_ERR        = state_c == SMD_S2   && i_info_vld;
      
assign SMD_S3_to_SMD_C3_0   = state_c == SMD_S3   && i_info_vld && i_smd_type==C3_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_S3_to_SMD_S0     = state_c == SMD_S3   && i_info_vld && i_smd_type==S0_SMD;
assign SMD_S3_to_SMD_S1     = state_c == SMD_S3   && i_info_vld && i_smd_type==S1_SMD;
assign SMD_S3_to_SMD_S2     = state_c == SMD_S3   && i_info_vld && i_smd_type==S2_SMD;
assign SMD_S3_to_ERR        = state_c == SMD_S3   && i_info_vld;

assign SMD_C0_0_to_SMD_C0_1 = state_c == SMD_C0_0 && i_info_vld && i_smd_type==C0_SMD && i_frag_cnt==FRAG_1 && CRC_pre==0;
assign SMD_C0_0_to_SMD_S0   = state_c == SMD_C0_0 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C0_0_to_SMD_S1   = state_c == SMD_C0_0 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C0_0_to_SMD_S2   = state_c == SMD_C0_0 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C0_0_to_SMD_S3   = state_c == SMD_C0_0 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C0_0_to_ERR      = state_c == SMD_C0_0 && i_info_vld;

assign SMD_C0_1_to_SMD_C0_2 = state_c == SMD_C0_1 && i_info_vld && i_smd_type==C0_SMD && i_frag_cnt==FRAG_2 && CRC_pre==0;
assign SMD_C0_1_to_SMD_S0   = state_c == SMD_C0_1 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C0_1_to_SMD_S1   = state_c == SMD_C0_1 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C0_1_to_SMD_S2   = state_c == SMD_C0_1 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C0_1_to_SMD_S3   = state_c == SMD_C0_1 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C0_1_to_ERR      = state_c == SMD_C0_1 && i_info_vld;

assign SMD_C0_2_to_SMD_C0_3 = state_c == SMD_C0_2 && i_info_vld && i_smd_type==C0_SMD && i_frag_cnt==FRAG_3 && CRC_pre==0;
assign SMD_C0_2_to_SMD_S0   = state_c == SMD_C0_2 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C0_2_to_SMD_S1   = state_c == SMD_C0_2 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C0_2_to_SMD_S2   = state_c == SMD_C0_2 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C0_2_to_SMD_S3   = state_c == SMD_C0_2 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C0_2_to_ERR      = state_c == SMD_C0_2 && i_info_vld;

assign SMD_C0_3_to_SMD_C0_0 = state_c == SMD_C0_3 && i_info_vld && i_smd_type==C0_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_C0_3_to_SMD_S0   = state_c == SMD_C0_3 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C0_3_to_SMD_S1   = state_c == SMD_C0_3 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C0_3_to_SMD_S2   = state_c == SMD_C0_3 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C0_3_to_SMD_S3   = state_c == SMD_C0_3 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C0_3_to_ERR      = state_c == SMD_C0_3 && i_info_vld ;


assign SMD_C1_0_to_SMD_C1_1 = state_c == SMD_C1_0 && i_info_vld && i_smd_type==C1_SMD && i_frag_cnt==FRAG_1 && CRC_pre==0;
assign SMD_C1_0_to_SMD_S0   = state_c == SMD_C1_0 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C1_0_to_SMD_S1   = state_c == SMD_C1_0 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C1_0_to_SMD_S2   = state_c == SMD_C1_0 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C1_0_to_SMD_S3   = state_c == SMD_C1_0 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C1_0_to_ERR      = state_c == SMD_C1_0 && i_info_vld ;

assign SMD_C1_1_to_SMD_C1_2 = state_c == SMD_C1_1 && i_info_vld && i_smd_type==C1_SMD && i_frag_cnt==FRAG_2 && CRC_pre==0;
assign SMD_C1_1_to_SMD_S0   = state_c == SMD_C1_1 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C1_1_to_SMD_S1   = state_c == SMD_C1_1 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C1_1_to_SMD_S2   = state_c == SMD_C1_1 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C1_1_to_SMD_S3   = state_c == SMD_C1_1 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C1_1_to_ERR      = state_c == SMD_C1_1 && i_info_vld ;

assign SMD_C1_2_to_SMD_C1_3 = state_c == SMD_C1_2 && i_info_vld && i_smd_type==C1_SMD && i_frag_cnt==FRAG_3 && CRC_pre==0;
assign SMD_C1_2_to_SMD_S0   = state_c == SMD_C1_2 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C1_2_to_SMD_S1   = state_c == SMD_C1_2 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C1_2_to_SMD_S2   = state_c == SMD_C1_2 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C1_2_to_SMD_S3   = state_c == SMD_C1_2 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C1_2_to_ERR      = state_c == SMD_C1_2 && i_info_vld ;

assign SMD_C1_3_to_SMD_C1_0 = state_c == SMD_C1_3 && i_info_vld && i_smd_type==C1_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_C1_3_to_SMD_S0   = state_c == SMD_C1_3 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C1_3_to_SMD_S1   = state_c == SMD_C1_3 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C1_3_to_SMD_S2   = state_c == SMD_C1_3 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C1_3_to_SMD_S3   = state_c == SMD_C1_3 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C1_3_to_ERR      = state_c == SMD_C1_3 && i_info_vld ;

assign SMD_C2_0_to_SMD_C2_1 = state_c == SMD_C2_0 && i_info_vld && i_smd_type==C2_SMD && i_frag_cnt==FRAG_1 && CRC_pre==0;
assign SMD_C2_0_to_SMD_S0   = state_c == SMD_C2_0 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C2_0_to_SMD_S1   = state_c == SMD_C2_0 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C2_0_to_SMD_S2   = state_c == SMD_C2_0 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C2_0_to_SMD_S3   = state_c == SMD_C2_0 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C2_0_to_ERR      = state_c == SMD_C2_0 && i_info_vld ;

assign SMD_C2_1_to_SMD_C2_2 = state_c == SMD_C2_1 && i_info_vld && i_smd_type==C2_SMD && i_frag_cnt==FRAG_2 && CRC_pre==0;
assign SMD_C2_1_to_SMD_S0   = state_c == SMD_C2_1 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C2_1_to_SMD_S1   = state_c == SMD_C2_1 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C2_1_to_SMD_S2   = state_c == SMD_C2_1 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C2_1_to_SMD_S3   = state_c == SMD_C2_1 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C2_1_to_ERR      = state_c == SMD_C2_1 && i_info_vld ;

assign SMD_C2_2_to_SMD_C2_3 = state_c == SMD_C2_2 && i_info_vld && i_smd_type==C2_SMD && i_frag_cnt==FRAG_3 && CRC_pre==0;
assign SMD_C2_2_to_SMD_S0   = state_c == SMD_C2_2 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C2_2_to_SMD_S1   = state_c == SMD_C2_2 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C2_2_to_SMD_S2   = state_c == SMD_C2_2 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C2_2_to_SMD_S3   = state_c == SMD_C2_2 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C2_2_to_ERR      = state_c == SMD_C2_2 && i_info_vld ;

assign SMD_C2_3_to_SMD_C2_0 = state_c == SMD_C2_3 && i_info_vld && i_smd_type==C2_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_C2_3_to_SMD_S0   = state_c == SMD_C2_3 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C2_3_to_SMD_S1   = state_c == SMD_C2_3 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C2_3_to_SMD_S2   = state_c == SMD_C2_3 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C2_3_to_SMD_S3   = state_c == SMD_C2_3 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C2_3_to_ERR      = state_c == SMD_C2_3 && i_info_vld ;



assign SMD_C3_0_to_SMD_C3_1 = state_c == SMD_C3_0 && i_info_vld && i_smd_type==C3_SMD && i_frag_cnt==FRAG_1 && CRC_pre==0;
assign SMD_C3_0_to_SMD_S0   = state_c == SMD_C3_0 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C3_0_to_SMD_S1   = state_c == SMD_C3_0 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C3_0_to_SMD_S2   = state_c == SMD_C3_0 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C3_0_to_SMD_S3   = state_c == SMD_C3_0 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C3_0_to_ERR      = state_c == SMD_C3_0 && i_info_vld ;

assign SMD_C3_1_to_SMD_C3_2 = state_c == SMD_C3_1 && i_info_vld && i_smd_type==C3_SMD && i_frag_cnt==FRAG_2 && CRC_pre==0;
assign SMD_C3_1_to_SMD_S0   = state_c == SMD_C3_1 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C3_1_to_SMD_S1   = state_c == SMD_C3_1 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C3_1_to_SMD_S2   = state_c == SMD_C3_1 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C3_1_to_SMD_S3   = state_c == SMD_C3_1 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C3_1_to_ERR      = state_c == SMD_C3_1 && i_info_vld ;

assign SMD_C3_2_to_SMD_C3_3 = state_c == SMD_C3_2 && i_info_vld && i_smd_type==C3_SMD && i_frag_cnt==FRAG_3 && CRC_pre==0;
assign SMD_C3_2_to_SMD_S0   = state_c == SMD_C3_2 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C3_2_to_SMD_S1   = state_c == SMD_C3_2 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C3_2_to_SMD_S2   = state_c == SMD_C3_2 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C3_2_to_SMD_S3   = state_c == SMD_C3_2 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C3_2_to_ERR      = state_c == SMD_C3_2 && i_info_vld ;

assign SMD_C3_3_to_SMD_C3_0 = state_c == SMD_C3_3 && i_info_vld && i_smd_type==C3_SMD && i_frag_cnt==FRAG_0 && CRC_pre==0;
assign SMD_C3_3_to_SMD_S0   = state_c == SMD_C3_3 && i_info_vld && i_smd_type==S0_SMD;
assign SMD_C3_3_to_SMD_S1   = state_c == SMD_C3_3 && i_info_vld && i_smd_type==S1_SMD;
assign SMD_C3_3_to_SMD_S2   = state_c == SMD_C3_3 && i_info_vld && i_smd_type==S2_SMD;
assign SMD_C3_3_to_SMD_S3   = state_c == SMD_C3_3 && i_info_vld && i_smd_type==S3_SMD;
assign SMD_C3_3_to_ERR      = state_c == SMD_C3_3 && i_info_vld ;


assign ERR_to_IDLE          = state_c == ERR && rr_rx_axis_last ;//延时2个时钟再跳回idle状态，防止输出数据有效信号提前拉高




/*
状态转移会相对于信息数据延时一拍，因此做一个信息数据打拍(r_info_vld)
*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_vld<='b0;
    end
    else if (i_info_vld) begin
        r_crc_vld<=i_crc_vld;
        end
    else begin
        r_crc_vld<=r_crc_vld;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rr_crc_vld<='b0;
    end
    else if (r_info_vld) begin
        rr_crc_vld<=r_crc_vld;
        end
    else begin
        rr_crc_vld<=rr_crc_vld;
    end
end
//r_info_vld落后i_info_vld一拍，与state对齐
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_info_vld<='b0;
    end
    else if (i_info_vld) begin
        r_info_vld<=i_info_vld;
        end
    else begin
        r_info_vld<=0;
    end
end
// rr_info_vld;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rr_info_vld<='b0;
    end
    else if (r_info_vld) begin
        rr_info_vld<=r_info_vld;
        end
    else begin
        rr_info_vld<=0;
    end
end




/************************
状态机做状态跳转，根据跳转的状态以及crc来判断数据的接收与丢弃

例如：SMD_C_X状态，通过判断此状态下的CRC就可一判断数据是否接收，若是crc则表明这一部分数据ok，可以上传到上层，
************************/


/********************
上一帧数据CRC。保留上一帧数据的CRC，若为CRC则可以往C跳，否则不能。为了防止C0—1—crc后边出现C0—1—mcrc时出错。
i_info_vld下一拍更新
*******************/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        CRC_pre<=0;
    end
    else if (r_info_vld&&i_crc_vld==CRC) begin
        CRC_pre<=1;
    end
    else if (r_info_vld&&r_crc_vld==MCRC) begin
        CRC_pre<=0;
    end
    else begin
        CRC_pre<=CRC_pre;
    end
end

reg   r_CRC_pre;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_CRC_pre<=0;
    end
    else begin
        r_CRC_pre<=CRC_pre;
    end
end



//一组数据开始信号，每次进入SMD_S后状态拉高一次。(落后STATE一个时钟周期，落后输入信号2个clk)
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_data_start <= 1'b0;
    end
        else if (r_info_vld &&  (state_c == SMD_S0 ||state_c == SMD_S1||state_c == SMD_S2||state_c == SMD_S3) ) begin
            o_data_start <= 1'b1;
        end
    else begin
        o_data_start <= 1'b0;
    end
end

//r_data_start_flag,数据起点拉高，终点拉低
//更改为时序逻辑，延迟一拍拉高拉低。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_data_start_flag <= 1'b0;
    end
    else if (o_data_start) begin
        r_data_start_flag <= 1'b1;
    end
    else if (o_data_end) begin
        r_data_start_flag <= 1'b0;
    end
    else begin
        r_data_start_flag <= r_data_start_flag;
    end
end


//一组数据结束信号，每一次进入SMD_S状态拉高一次。
//最迟落后输入信号2个clk
//添加r_data_start_flag可以保证每次起点后o_data_end只会拉高一次，不会多次
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_data_end <='b0;
    end
    else if (r_data_start_flag&&state_c==ERR||(r_info_vld&&r_CRC_pre==0&&(state_c == SMD_S0||state_c == SMD_S1||state_c == SMD_S2||state_c == SMD_S3))) begin
        o_data_end<='b1;
    end
    else if (r_data_start_flag&&r_crc_vld==CRC&&rr_rx_axis_last) begin
        o_data_end<='b1;
    end
    else begin
        o_data_end<='b0;
    end
end


//信号接收完毕之后检查接收的信号是否完整。若接收到了CRC则表明信号接收完整，若在ERR状态或者检测到上一个为MCRC且当前状态为SMD_S则表明数据不完整
//最迟落后输入信号2个clk
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_data_complete<='b0;
    end
    else if (state_c==ERR||(r_info_vld&&r_CRC_pre==0&&(state_c == SMD_S0||state_c == SMD_S1||state_c == SMD_S2||state_c == SMD_S3))) begin
        o_data_complete<='b0;
    end 
    else if (r_crc_vld==CRC&&rr_rx_axis_last) begin
        o_data_complete<='b1;
    end
    else begin
        o_data_complete<='b0;
    end
end




always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      r_rx_axis_data    <=  'b0   ; 
      r_rx_axis_user    <=  'b0   ; 
      r_rx_axis_keep    <=  'b0   ; 
      r_rx_axis_last    <=  'b0   ; 
      r_rx_axis_valid   <=  'b0   ;
      end   
    else begin
      r_rx_axis_data    <=  i_rx_axis_data    ; 
      r_rx_axis_user    <=  i_rx_axis_user    ; 
      r_rx_axis_keep    <=  i_rx_axis_keep    ; 
      r_rx_axis_last    <=  i_rx_axis_last    ; 
      r_rx_axis_valid   <=  i_rx_axis_valid   ; 
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      rr_rx_axis_data    <=  'b0   ; 
      rr_rx_axis_user    <=  'b0   ; 
      rr_rx_axis_keep    <=  'b0   ; 
      rr_rx_axis_last    <=  'b0   ; 
      rr_rx_axis_valid   <=  'b0   ;
      rrr_rx_axis_last    <=  'b0   ;
      end   
    else begin
      rr_rx_axis_data    <=  r_rx_axis_data    ; 
      rr_rx_axis_user    <=  r_rx_axis_user    ; 
      rr_rx_axis_keep    <=  r_rx_axis_keep    ; 
      rr_rx_axis_last    <=  r_rx_axis_last    ; 
      rr_rx_axis_valid   <=  r_rx_axis_valid   ; 
      rrr_rx_axis_last   <=  rr_rx_axis_last   ;
    end
end

assign o_sgram_rx_axis_data     = state_c!=ERR ? rr_rx_axis_data  : 0  ;//落后输入信号2个clk
assign o_sgram_rx_axis_user     = state_c!=ERR ? rr_rx_axis_user  : 0  ;//落后输入信号2个clk
assign o_sgram_rx_axis_keep     = state_c!=ERR ? rr_rx_axis_keep  : 0  ;//落后输入信号2个clk
assign o_sgram_rx_axis_last     = state_c!=ERR ? rr_rx_axis_last  : 0  ;//落后输入信号2个clk
assign o_sgram_rx_axis_valid    = state_c!=ERR ? rr_rx_axis_valid : 0  ;//落后输入信号2个clk
assign o_rx_axis_ready          = 1;



 

/*
// 状态机第四段：同步always输出，可以有多个输出（例如计数器清零、数据有效位使能）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        
    end
    else if () begin
 
        end

    else begin     
    end
end
*/

// //161bit
// wire    [57:0]     probe0;

// assign probe0 =  {

// i_rx_axis_data        ,
// i_rx_axis_user        ,
// i_rx_axis_keep        ,
// i_rx_axis_last        ,
// i_rx_axis_valid       ,
// o_rx_axis_ready       ,
// o_sgram_rx_axis_data  ,
// o_sgram_rx_axis_user  ,
// o_sgram_rx_axis_keep  ,
// o_sgram_rx_axis_last  ,
// o_sgram_rx_axis_valid ,

// o_data_start          ,
// o_data_end            ,
// o_data_complete        
// };


// ila_1_fast inst_ila_1 (
//     .i_clk(i_clk), // input wire i_clk
//     .probe0(probe0)
// );

endmodule
