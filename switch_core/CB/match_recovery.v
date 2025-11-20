`define CPU_MAC
`define MAC1
`define MAC2
`define MAC3
`define MAC4
`define MAC5
`define MAC6
`define MAC7

module match_recovery#(
    parameter                                                  RECOVERY_MODE                =      1        , // 0:向量恢复算法 1：匹配恢复算法
    parameter                                                  PORT_NUM                     =      8           // 交换机的端口数 
)( 
    input               wire                                   i_clk                              , // 250MHz
    input               wire                                   i_rst                              ,  
`ifdef CPU_MAC
    input               wire                                   i_rtag_flag0                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence0                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle0                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC1
    input               wire                                   i_rtag_flag1                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence1                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle1                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC2
    input               wire                                   i_rtag_flag2                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence2                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle2                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC3
    input               wire                                   i_rtag_flag3                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence3                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle3                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC4
    input               wire                                   i_rtag_flag4                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence4                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle4                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC5
    input               wire                                   i_rtag_flag5                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence5                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle5                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC6
    input               wire                                   i_rtag_flag6                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence6                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle6                   , // 区分流，每个流单独维护自己的 
`endif
`ifdef MAC7
    input               wire                                   i_rtag_flag7                       , // 是否携带rtag标签
    input               wire   [15:0]                          i_rtag_squence7                    , // rtag_squencenum
    input               wire   [7:0]                           i_stream_handle7                   , // 区分流，每个流单独维护自己的 
`endif
 
    output              wire   [PORT_NUM-1:0]                  o_pass_en                          , // 判断结果，可以接收该帧
    output              wire   [PORT_NUM-1:0]                  o_discard_en                       , // 判断结果，可以丢弃该帧
    output              wire   [PORT_NUM-1:0]                  o_judge_finish                       // 判断结果，表示本次报文的判断完成


//    input               wire   [7:0]                           i_cr_stream_handle                 ,
//    output              wire   [15:0]                          o_stream_recov_seq_num             ,
//    output              wire   [15:0]                          o_stream_take_any                  ,

//    output              wire   [31:0]                          o_passed_packets_cnt               ,
//    output              wire   [31:0]                          o_discarded_packets_cnt            

);  

// 匹配恢复算法参数
localparam                                                     FRER_SEQ_RCVY_INVALID_SEQUENCE_VALUE = 16'hFFFF     ; // 无效序列号值
localparam                                                     RECOVERY_SEQ_SPACE                   = 17'd65536    ; // 序列号空间
localparam                                                     FRER_SEQ_RCVY_RESET_TIME             = 16'd50       ; // 定时器重置时间  16'd10000
localparam                                                     MAX_STREAMS                          = 9'd256       ; // 最大支持流数量

/*========================================== 信号声明 ==========================================*/
// 输入打拍信号
`ifdef CPU_MAC
reg                                                            ri_rtag_flag0                       ;
reg    [15:0]                                                  ri_rtag_sequence0                   ;
reg    [7:0]                                                   ri_stream_handle0                   ;
`endif
`ifdef MAC1
reg                                                            ri_rtag_flag1                       ;
reg    [15:0]                                                  ri_rtag_sequence1                   ;
reg    [7:0]                                                   ri_stream_handle1                   ;
`endif
`ifdef MAC2
reg                                                            ri_rtag_flag2                       ;
reg    [15:0]                                                  ri_rtag_sequence2                   ;
reg    [7:0]                                                   ri_stream_handle2                   ;
`endif
`ifdef MAC3
reg                                                            ri_rtag_flag3                       ;
reg    [15:0]                                                  ri_rtag_sequence3                   ;
reg    [7:0]                                                   ri_stream_handle3                   ;
`endif
`ifdef MAC4
reg                                                            ri_rtag_flag4                       ;
reg    [15:0]                                                  ri_rtag_sequence4                   ;
reg    [7:0]                                                   ri_stream_handle4                   ;
`endif
`ifdef MAC5
reg                                                            ri_rtag_flag5                       ;
reg    [15:0]                                                  ri_rtag_sequence5                   ;
reg    [7:0]                                                   ri_stream_handle5                   ;
`endif
`ifdef MAC6
reg                                                            ri_rtag_flag6                       ;
reg    [15:0]                                                  ri_rtag_sequence6                   ;
reg    [7:0]                                                   ri_stream_handle6                   ;
`endif
`ifdef MAC7
reg                                                            ri_rtag_flag7                       ;
reg    [15:0]                                                  ri_rtag_sequence7                   ;
reg    [7:0]                                                   ri_stream_handle7                   ;
`endif

// 输出信号
reg    [PORT_NUM-1:0]                                          ro_pass_en                          ;
reg    [PORT_NUM-1:0]                                          ro_discard_en                       ;
reg    [PORT_NUM-1:0]                                          ro_judge_finish                     ;

// 流状态管理 - 每个流独立维护状态
reg    [15:0]                                                  r_stream_recov_seq_num  [0:MAX_STREAMS-1] ; // 每个流的上次序列号(RecovSeqNum)
reg                                                            r_stream_take_any       [0:MAX_STREAMS-1] ; // 每个流的TakeAny标志
reg    [15:0]                                                  r_stream_remaining_ticks[0:MAX_STREAMS-1] ; // 每个流的剩余计时器(RemainingTicks)
reg                                                            r_stream_active         [0:MAX_STREAMS-1] ; // 流是否激活

// 通道处理状态
reg    [2:0]                                                   r_current_channel                   ; // 当前处理的通道
reg    [7:0]                                                   r_active_channels_d1                ; // 上一周期的通道掩码
reg    [2:0]                                                   r_new_active_channel                ; // 新活动通道选择结果
reg                                                            r_processing_flag                   ; // 处理中标志
reg    [7:0]                                                   r_active_channels                   ; // 有数据的通道掩码

// 当前处理包的信息
reg    [2:0]                                                   r_valid_counter                     ; // valid处理时间计数器
reg                                                            r_current_rtag_flag                 ;
reg    [15:0]                                                  r_current_sequence                  ;
reg    [7:0]                                                   r_current_stream_handle             ;
reg    [7:0]                                                   r_current_stream_index              ; // 流索引(0-255)

// 匹配恢复核心变量
reg                                                            r_channel_locked                    ; // 通道锁定标志(多周期保持)
reg                                                            r_is_valid_sequence                 ; // 当前序列号是否有效
wire                                                           w_is_valid_sequence                 ; // 当前序列号是否有效
reg    [16:0]                                                  r_delta_raw                         ; // 原始偏差(17位)
wire    [15:0]                                                 w_delta                             ; // 调整后偏差(模运算结果)
reg                                                            r_is_duplicate                      ; // 是否为重复包
reg                                                            r_should_pass                       ; // 是否应该通过
reg                                                            r_should_pass_valid                 ;
reg                                                            r_should_pass_valid_d1              ;
reg                                                            r_timer_expired_flag                ; // 定时器到期标志

// 统计计数器(全局)
reg    [31:0]                                                  r_passed_packets_cnt                ; // 通过的包数
reg    [31:0]                                                  r_discarded_packets_cnt             ; // 丢弃的包数
reg    [31:0]                                                  r_duplicate_packets_cnt             ; // 重复包数
reg    [31:0]                                                  r_no_tag_packets_cnt                ; // 无标签包数

/*========================================== 输入打拍逻辑 ==========================================*/
// 输入信号打拍
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
`ifdef CPU_MAC
        ri_rtag_flag0        <= 1'b0  ;
        ri_rtag_sequence0    <= 16'h0 ;
        ri_stream_handle0    <= 8'h0  ;
`endif
`ifdef MAC1
        ri_rtag_flag1        <= 1'b0  ;
        ri_rtag_sequence1    <= 16'h0 ;
        ri_stream_handle1    <= 8'h0  ;
`endif
`ifdef MAC2
        ri_rtag_flag2        <= 1'b0  ;
        ri_rtag_sequence2    <= 16'h0 ;
        ri_stream_handle2    <= 8'h0  ;
`endif
`ifdef MAC3
        ri_rtag_flag3        <= 1'b0  ;
        ri_rtag_sequence3    <= 16'h0 ;
        ri_stream_handle3    <= 8'h0  ;
`endif
`ifdef MAC4
        ri_rtag_flag4        <= 1'b0  ;
        ri_rtag_sequence4    <= 16'h0 ;
        ri_stream_handle4    <= 8'h0  ;
`endif
`ifdef MAC5
        ri_rtag_flag5        <= 1'b0  ;
        ri_rtag_sequence5    <= 16'h0 ;
        ri_stream_handle5    <= 8'h0  ;
`endif
`ifdef MAC6
        ri_rtag_flag6        <= 1'b0  ;
        ri_rtag_sequence6    <= 16'h0 ;
        ri_stream_handle6    <= 8'h0  ;
`endif
`ifdef MAC7
        ri_rtag_flag7        <= 1'b0  ;
        ri_rtag_sequence7    <= 16'h0 ;
        ri_stream_handle7    <= 8'h0  ;
`endif
    end else begin
`ifdef CPU_MAC
        ri_rtag_flag0        <= i_rtag_flag0 ? 1'd1 : ro_judge_finish[0] ? 1'd0 : ri_rtag_flag0  ;
        ri_rtag_sequence0    <= i_rtag_flag0 ? i_rtag_squence0 : ro_judge_finish[0] ? 16'h0 : ri_rtag_sequence0 ;
        ri_stream_handle0    <= i_rtag_flag0 ? i_stream_handle0 : ro_judge_finish[0] ? 8'h0  : ri_stream_handle0 ;
`endif
`ifdef MAC1
        ri_rtag_flag1        <= i_rtag_flag1 ? 1'd1 : ro_judge_finish[1] ? 1'd0 : ri_rtag_flag1  ;
        ri_rtag_sequence1    <= i_rtag_flag1 ? i_rtag_squence1 : ro_judge_finish[1] ? 16'h0 : ri_rtag_sequence1 ;
        ri_stream_handle1    <= i_rtag_flag1 ? i_stream_handle1 : ro_judge_finish[1] ? 8'h0  : ri_stream_handle1 ;
`endif
`ifdef MAC2
        ri_rtag_flag2        <= i_rtag_flag2 ? 1'd1 : ro_judge_finish[2] ? 1'd0 : ri_rtag_flag2  ;
        ri_rtag_sequence2    <= i_rtag_flag2 ? i_rtag_squence2 : ro_judge_finish[2] ? 16'h0 : ri_rtag_sequence2 ;
        ri_stream_handle2    <= i_rtag_flag2 ? i_stream_handle2 : ro_judge_finish[2] ? 8'h0  : ri_stream_handle2 ;
`endif
`ifdef MAC3
        ri_rtag_flag3        <= i_rtag_flag3 ? 1'd1 : ro_judge_finish[3] ? 1'd0 : ri_rtag_flag3  ;
        ri_rtag_sequence3    <= i_rtag_flag3 ? i_rtag_squence3 : ro_judge_finish[3] ? 16'h0 : ri_rtag_sequence3 ;
        ri_stream_handle3    <= i_rtag_flag3 ? i_stream_handle3 : ro_judge_finish[3] ? 8'h0  : ri_stream_handle3 ;
`endif
`ifdef MAC4
        ri_rtag_flag4        <= i_rtag_flag4 ? 1'd1 : ro_judge_finish[4] ? 1'd0 : ri_rtag_flag4  ;
        ri_rtag_sequence4    <= i_rtag_flag4 ? i_rtag_squence4 : ro_judge_finish[4] ? 16'h0 : ri_rtag_sequence4 ;
        ri_stream_handle4    <= i_rtag_flag4 ? i_stream_handle4 : ro_judge_finish[4] ? 8'h0  : ri_stream_handle4 ;
`endif
`ifdef MAC5
        ri_rtag_flag5        <= i_rtag_flag5 ? 1'd1 : ro_judge_finish[5] ? 1'd0 : ri_rtag_flag5  ;
        ri_rtag_sequence5    <= i_rtag_flag5 ? i_rtag_squence5 : ro_judge_finish[5] ? 16'h0 : ri_rtag_sequence5 ;
        ri_stream_handle5    <= i_rtag_flag5 ? i_stream_handle5 : ro_judge_finish[5] ? 8'h0  : ri_stream_handle5 ;
`endif
`ifdef MAC6
        ri_rtag_flag6        <= i_rtag_flag6 ? 1'd1 : ro_judge_finish[6] ? 1'd0 : ri_rtag_flag6  ;
        ri_rtag_sequence6    <= i_rtag_flag6 ? i_rtag_squence6 : ro_judge_finish[6] ? 16'h0 : ri_rtag_sequence6 ;
        ri_stream_handle6    <= i_rtag_flag6 ? i_stream_handle6 : ro_judge_finish[6] ? 8'h0  : ri_stream_handle6 ;
`endif
`ifdef MAC7
        ri_rtag_flag7        <= i_rtag_flag7 ? 1'd1 : ro_judge_finish[7] ? 1'd0 : ri_rtag_flag7  ;
        ri_rtag_sequence7    <= i_rtag_flag7 ? i_rtag_squence7 : ro_judge_finish[7] ? 16'h0 : ri_rtag_sequence7 ;
        ri_stream_handle7    <= i_rtag_flag7 ? i_stream_handle7 : ro_judge_finish[7] ? 8'h0  : ri_stream_handle7 ;
`endif
    end
end


/*========================================== 通道活动检测 ==========================================*/
// 检测哪些通道有有效数据
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_active_channels <= 8'h0;
    end else begin
        r_active_channels[0] <= `ifdef CPU_MAC (ri_rtag_flag0 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[1] <= `ifdef MAC1    (ri_rtag_flag1 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[2] <= `ifdef MAC2    (ri_rtag_flag2 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[3] <= `ifdef MAC3    (ri_rtag_flag3 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[4] <= `ifdef MAC4    (ri_rtag_flag4 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[5] <= `ifdef MAC5    (ri_rtag_flag5 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[6] <= `ifdef MAC6    (ri_rtag_flag6 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[7] <= `ifdef MAC7    (ri_rtag_flag7 == 1'b1  ) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
    end
end

/*========================================== 通道轮询处理逻辑 ==========================================*/
// 通道锁定标志 - 从检测到数据开始，到输出judge_finish结束
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_channel_locked <= 1'b0;
    end else begin
        r_channel_locked <= // 未锁定状态：检查当前通道是否有数据，有则锁定
                            (r_channel_locked == 1'b0) && (r_active_channels[r_current_channel] == 1'b1) ? 
                            1'b1 : 
                            // 锁定状态：等待judge_finish输出后解锁
                            (r_channel_locked == 1'b1) && (ro_judge_finish != {PORT_NUM{1'b0}}) ?
                            1'b0 :
                            r_channel_locked;
    end
end

// 当前处理通道计数器
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_channel <= 3'h0;
    end else begin
        r_current_channel <= ((r_channel_locked == 1'b1) || r_active_channels[r_current_channel] == 1'b1) && r_should_pass_valid_d1 == 1'd0 ?
                             r_current_channel :
                             (r_channel_locked == 1'b0) && (r_active_channels != 8'h0)&& (r_active_channels_d1 == 8'h0) ?
                             r_new_active_channel:
                             (r_channel_locked == 1'b0) && (r_active_channels != 8'h0) && (r_current_channel == 3'd7)? 
                             3'h0 :  
                             (r_channel_locked == 1'b0 || r_should_pass_valid_d1 == 1'd1)  ?
                            r_current_channel + 3'h1 : 
                            r_current_channel;
    end
end

// 记录上一周期的活动通道掩码，用于检测从无到有的到达事件
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_active_channels_d1 <= 8'h0;
    end else begin
        r_active_channels_d1 <= r_active_channels;
    end
end

// 新活动通道选择逻辑 - 选择最低索引的活动通道
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_new_active_channel <= 3'h0;
    end else begin
        r_new_active_channel <= (r_active_channels[0] == 1'b1) ? 3'd0 :
                                (r_active_channels[1] == 1'b1) ? 3'd1 :
                                (r_active_channels[2] == 1'b1) ? 3'd2 :
                                (r_active_channels[3] == 1'b1) ? 3'd3 :
                                (r_active_channels[4] == 1'b1) ? 3'd4 :
                                (r_active_channels[5] == 1'b1) ? 3'd5 :
                                (r_active_channels[6] == 1'b1) ? 3'd6 :
                                (r_active_channels[7] == 1'b1) ? 3'd7 : 3'h0;
    end
end

// 处理中标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_processing_flag <= 1'b0;
    end else begin
        r_processing_flag <= (r_channel_locked == 1'b0) && (r_active_channels[r_current_channel] == 1'b1) ? 
                            1'b1 : 1'b0 ;
    end
end

// 当前处理包信息提取
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_rtag_flag <= 1'b0;
    end else begin
        r_current_rtag_flag <= (r_current_channel == 3'd0) ? `ifdef CPU_MAC ri_rtag_flag0 `else 1'b0 `endif :
                               (r_current_channel == 3'd1) ? `ifdef MAC1    ri_rtag_flag1 `else 1'b0 `endif :
                               (r_current_channel == 3'd2) ? `ifdef MAC2    ri_rtag_flag2 `else 1'b0 `endif :
                               (r_current_channel == 3'd3) ? `ifdef MAC3    ri_rtag_flag3 `else 1'b0 `endif :
                               (r_current_channel == 3'd4) ? `ifdef MAC4    ri_rtag_flag4 `else 1'b0 `endif :
                               (r_current_channel == 3'd5) ? `ifdef MAC5    ri_rtag_flag5 `else 1'b0 `endif :
                               (r_current_channel == 3'd6) ? `ifdef MAC6    ri_rtag_flag6 `else 1'b0 `endif :
                               (r_current_channel == 3'd7) ? `ifdef MAC7    ri_rtag_flag7 `else 1'b0 `endif :
                               1'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_sequence <= 16'h0;
    end else begin
        r_current_sequence <= (r_current_channel == 3'd0) ? `ifdef CPU_MAC ri_rtag_sequence0 `else 16'h0 `endif :
                             (r_current_channel == 3'd1) ? `ifdef MAC1 ri_rtag_sequence1 `else 16'h0 `endif :
                             (r_current_channel == 3'd2) ? `ifdef MAC2 ri_rtag_sequence2 `else 16'h0 `endif :
                             (r_current_channel == 3'd3) ? `ifdef MAC3 ri_rtag_sequence3 `else 16'h0 `endif :
                             (r_current_channel == 3'd4) ? `ifdef MAC4 ri_rtag_sequence4 `else 16'h0 `endif :
                             (r_current_channel == 3'd5) ? `ifdef MAC5 ri_rtag_sequence5 `else 16'h0 `endif :
                             (r_current_channel == 3'd6) ? `ifdef MAC6 ri_rtag_sequence6 `else 16'h0 `endif :
                             (r_current_channel == 3'd7) ? `ifdef MAC7 ri_rtag_sequence7 `else 16'h0 `endif :
                             16'h0;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_stream_handle <= 8'h0;
    end else begin
        r_current_stream_handle <= (r_current_channel == 3'd0) ? `ifdef CPU_MAC ri_stream_handle0 `else 8'h0 `endif :
                                  (r_current_channel == 3'd1) ? `ifdef MAC1 ri_stream_handle1 `else 8'h0 `endif :
                                  (r_current_channel == 3'd2) ? `ifdef MAC2 ri_stream_handle2 `else 8'h0 `endif :
                                  (r_current_channel == 3'd3) ? `ifdef MAC3 ri_stream_handle3 `else 8'h0 `endif :
                                  (r_current_channel == 3'd4) ? `ifdef MAC4 ri_stream_handle4 `else 8'h0 `endif :
                                  (r_current_channel == 3'd5) ? `ifdef MAC5 ri_stream_handle5 `else 8'h0 `endif :
                                  (r_current_channel == 3'd6) ? `ifdef MAC6 ri_stream_handle6 `else 8'h0 `endif :
                                  (r_current_channel == 3'd7) ? `ifdef MAC7 ri_stream_handle7 `else 8'h0 `endif :
                                  8'h0;
    end
end

/*========================================== 流索引查找 ==========================================*/
// 流索引计算(直接使用stream_handle的全部8位)
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_stream_index <= 8'h0;
    end else begin
        r_current_stream_index <= r_current_stream_handle;
    end
end

/*========================================== 匹配恢复核心逻辑 ==========================================*/
// 序列号有效性判断
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_is_valid_sequence <= 1'b0;
    end else begin
        r_is_valid_sequence <= (r_current_rtag_flag == 1'b1) && (r_current_sequence != FRER_SEQ_RCVY_INVALID_SEQUENCE_VALUE) ? 
                               1'b1 : 1'b0;
    end
end

assign w_is_valid_sequence = r_current_rtag_flag == 1'b1 && (r_current_sequence != FRER_SEQ_RCVY_INVALID_SEQUENCE_VALUE) ? 1'b1 : 1'b0;

// 计算序列号差值 delta = (sequence_number - RecovSeqNum) mod RecovSeqSpace
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_delta_raw <= 17'h0;
    end else begin
        r_delta_raw <= (w_is_valid_sequence == 1'b1) ? 
                       {1'b0, r_current_sequence} - {1'b0, r_stream_recov_seq_num[r_current_stream_handle]} : 
                       17'h0;
    end
end

// 模运算调整 (简化处理：直接取低16位作为delta) 

assign w_delta = r_delta_raw[15:0];


// 重复包检测 (delta == 0)
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_is_duplicate <= 1'b0;
    end else begin
        r_is_duplicate <= (r_is_valid_sequence == 1'b1) && (w_delta == 16'h0) && r_stream_take_any[r_current_stream_handle] == 1'd0 ? 
                          1'b1 : 
                          1'b0;
    end
end

// 包通过判断逻辑
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_should_pass <= 1'b0;
    end else begin
        r_should_pass <= // 无效序列号直接通过(交给上层处理)
                         (w_is_valid_sequence == 1'b0) ? 
                         1'b0 : 
                         // 有效序列号的处理
                         // TakeAny状态：直接接受
                         (r_stream_take_any[r_current_stream_handle] == 1'b1) && r_valid_counter == 3'd1 ? 
                         1'b1 : 
                         // 重复包：丢弃
                         (r_is_duplicate == 1'b1) ? 
                         1'b0 : 
                         // 新序列号：接受
                         1'b1;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_should_pass_valid <= 1'b0;
    end else begin
        r_should_pass_valid <= // 无效序列号直接通过(交给上层处理)
                         (w_is_valid_sequence == 1'b0) ? 
                         1'b0 : 
                         // 有效序列号的处理
                         // TakeAny状态：直接接受
                         (r_stream_take_any[r_current_stream_handle] == 1'b1) && r_valid_counter == 3'd1 ? 
                         1'b1 : 
                         // 重复包：丢弃
                         (r_is_duplicate == 1'b1) && r_valid_counter == 3'd1 ? 
                         1'b1 : 
                         // 新序列号：接受
                         r_valid_counter == 3'd1 ?
                         1'b1 : 1'd0;
    end
end

always @(posedge i_clk) begin
    r_should_pass_valid_d1 <= r_should_pass_valid;
end

/*========================================== 流状态更新 ==========================================*/
// 流状态数组初始化和更新
genvar j;
generate
    for (j = 0; j < MAX_STREAMS; j = j + 1) begin : stream_state_gen
        
        // r_stream_recov_seq_num 更新逻辑
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_recov_seq_num[j] <= 16'h0;
            end else begin
                r_stream_recov_seq_num[j] <= 
                    (r_should_pass_valid == 1'd1) && (r_current_stream_handle == j) && (r_stream_take_any[j] == 1'b1) && (r_should_pass == 1'b1) && (w_is_valid_sequence == 1'b1) ?
                    r_current_sequence :
                    (r_should_pass_valid == 1'd1) && (r_current_stream_handle == j) && (w_is_valid_sequence == 1'b1) && (r_should_pass == 1'b1) && (r_is_duplicate == 1'b0) ?
                    r_current_sequence :
                    r_stream_recov_seq_num[j];
            end
        end
        
        // r_stream_take_any 更新逻辑
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_take_any[j] <= 1'b1;
            end else begin
                r_stream_take_any[j] <= 
                    // 当前处理流：从TakeAny转为正常状态
                    (r_should_pass_valid == 1'd1) && (r_current_stream_handle == j) && (r_stream_take_any[j] == 1'b1) && (r_should_pass == 1'b1) && (w_is_valid_sequence == 1'b1) ?
                    1'b0 :
                    // 已激活流超时：重置为TakeAny状态
                    (r_stream_active[j] == 1'b1) && (r_stream_remaining_ticks[j] == 16'h0) ?
                    1'b1 :
                    // 其他情况保持不变
                    r_stream_take_any[j];
            end
        end
        
        // r_stream_remaining_ticks 更新逻辑
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_remaining_ticks[j] <= 16'h0;
            end else begin
                r_stream_remaining_ticks[j] <= 
                    // 当前处理流：重置计时器
                    (r_should_pass_valid == 1'd1) && (r_current_stream_handle == j) && (r_stream_take_any[j] == 1'b1) && (r_should_pass == 1'b1) && (w_is_valid_sequence == 1'b1) ?
                    FRER_SEQ_RCVY_RESET_TIME :
                    (r_should_pass_valid == 1'd1) && (r_current_stream_handle == j) && (w_is_valid_sequence == 1'b1) && (r_should_pass == 1'b1) && (r_is_duplicate == 1'b0) ?
                    FRER_SEQ_RCVY_RESET_TIME :
                    // 所有已激活的流：持续计时减少
                    (r_stream_active[j] == 1'b1) && (r_stream_remaining_ticks[j] > 16'h0) ?
                    r_stream_remaining_ticks[j] - 16'h1 :
                    // 未激活或已超时的流：保持0
                    r_stream_remaining_ticks[j];
            end
        end
        
        // r_stream_active 更新逻辑
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_active[j] <= 1'b0;
            end else begin
                r_stream_active[j] <= 
                    // 当前处理流：从TakeAny状态首次激活
                    (r_should_pass_valid == 1'd1) && (r_current_stream_handle == j) && (r_stream_take_any[j] == 1'b1) && (r_should_pass == 1'b1) && (w_is_valid_sequence == 1'b1) ?
                    1'b1 :
                    // 已激活流超时：重置为未激活状态
                    (r_stream_active[j] == 1'b1) && (r_stream_remaining_ticks[j] == 16'h0) ?
                    1'b0 :
                    // 其他情况保持不变
                    r_stream_active[j];
            end
        end
        
    end
endgenerate

//assign o_stream_recov_seq_num = r_stream_recov_seq_num[i_cr_stream_handle];
//assign o_stream_take_any = r_stream_take_any[i_cr_stream_handle];

/*========================================== 定时器超时检测 ==========================================*/
// 定时器到期标志
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_timer_expired_flag <= 1'b0;
    end else begin
        r_timer_expired_flag <= (r_stream_active[r_current_stream_handle] == 1'b1) && (r_stream_remaining_ticks[r_current_stream_handle] == 16'h0) ? 
                               1'b1 : 
                               1'b0;
    end
end

/*========================================== 统计计数器 ==========================================*/
// 通过包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_passed_packets_cnt <= 32'h0;
    end else begin
        r_passed_packets_cnt <= (r_should_pass_valid == 1'd1) && (r_should_pass == 1'b1) ? 
                                r_passed_packets_cnt + 32'h1 : 
                                r_passed_packets_cnt;
    end
end

// 丢弃包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_discarded_packets_cnt <= 32'h0;
    end else begin
        r_discarded_packets_cnt <= (r_should_pass_valid == 1'd1) && (r_should_pass == 1'b0) ? 
                                   r_discarded_packets_cnt + 32'h1 : 
                                   r_discarded_packets_cnt;
    end
end

// 重复包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_duplicate_packets_cnt <= 32'h0;
    end else begin
        r_duplicate_packets_cnt <= (r_should_pass_valid == 1'd1) && (r_is_duplicate == 1'b1) ? 
                                   r_duplicate_packets_cnt + 32'h1 : 
                                   r_duplicate_packets_cnt;
    end
end

// 无标签包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_no_tag_packets_cnt <= 32'h0;
    end else begin
        r_no_tag_packets_cnt <= (r_should_pass_valid == 1'd1) && (w_is_valid_sequence == 1'b0) ? 
                                r_no_tag_packets_cnt + 32'h1 : 
                                r_no_tag_packets_cnt;
    end
end

//assign o_passed_packets_cnt     = r_passed_packets_cnt;
//assign o_discarded_packets_cnt  = r_discarded_packets_cnt;

/*========================================== 输出逻辑 ==========================================*/
// valid处理时间计数器
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_valid_counter <= 3'd0;
    end else  begin
        r_valid_counter <=  ro_judge_finish != 1'd0 ? 
                            3'd0 :
                            (r_channel_locked == 1'd1 && r_valid_counter == 3'd2) ? 
                            3'd2 :
                            r_channel_locked == 1'd1 ? r_valid_counter + 3'd1 : r_valid_counter; // 无效时清零 
    end
end

// 通过使能输出
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_pass_en <= {PORT_NUM{1'b0}};
    end else begin
        ro_pass_en <= (r_should_pass_valid == 1'd1) && (r_should_pass == 1'b1)&& (r_is_duplicate == 1'b0) ? 
                     ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_current_channel) : 
                     {PORT_NUM{1'b0}};
    end
end

// 丢弃使能输出
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_discard_en <= {PORT_NUM{1'b0}};
    end else begin
        ro_discard_en <= (r_should_pass_valid == 1'd1) && (r_is_duplicate == 1'b1) ? 
                        ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_current_channel) : 
                        {PORT_NUM{1'b0}};
    end
end

// 判断完成输出
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_judge_finish <= {PORT_NUM{1'b0}};
    end else begin
        ro_judge_finish <= (r_current_rtag_flag == 1'b1) && (r_should_pass_valid == 1'd1) ? 
                          ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_current_channel) : 
                          {PORT_NUM{1'b0}};
    end
end

/*========================================== 输出赋值 ==========================================*/
assign o_pass_en       = ro_pass_en       ;
assign o_discard_en    = ro_discard_en    ;
assign o_judge_finish  = ro_judge_finish  ;

endmodule 