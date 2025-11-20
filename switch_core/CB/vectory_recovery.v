module vectory_recovery#(
    parameter                                                  RECOVERY_MODE                =      0        , // 0:向量恢复算法 1：匹配恢复算法
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

);

// 序列恢复算法参数
localparam                                                     FRER_SEQ_RCVY_INVALID_SEQUENCE_VALUE = 16'hFFFF     ; // 无效序列号值
localparam                                                     RECOVERY_SEQ_SPACE                   = 17'd65536    ; // 序列号空间
localparam                                                     FRER_SEQ_RCVY_HISTORY_LENGTH         = 5'd16        ; // 历史记录长度
localparam                                                     MAX_STREAMS                          = 9'd32       ; // 最大支持流数量(使用全部8位stream_handle)

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
reg    [15:0]                                                  r_stream_recov_seq_num  [0:MAX_STREAMS-1] ; // 每个流的预期序列号
reg    [15:0]                                                  r_stream_history        [0:MAX_STREAMS-1] ; // 每个流的序列历史记录
reg                                                            r_stream_take_any       [0:MAX_STREAMS-1] ; // 每个流的重置状态标志
reg                                                            r_stream_active         [0:MAX_STREAMS-1] ; // 流是否激活
reg    [15:0]                                                  r_stream_timer          [0:MAX_STREAMS-1] ; // 每个流的独立恢复计时器

// 通道处理状态
reg    [2:0]                                                   r_current_channel                   ; // 当前处理的通道
// reg    [2:0]                                                   r_current_channel_d1                ; // 当前处理的通道
reg                                                            r_processing_flag                   ; // 处理中标志(单周期脉冲)
reg                                                            r_channel_locked                    ; // 通道锁定标志(多周期保持)
reg    [7:0]                                                   r_active_channels                   ; // 有数据的通道掩码
reg    [7:0]                                                   r_active_channels_d1                ; // 上一周期的通道掩码
reg    [2:0]                                                   r_new_active_channel                ; // 新活动通道选择结果

// 当前处理包的信息
reg                                                            r_current_rtag_flag                 ;
reg    [15:0]                                                  r_current_sequence                  ;
reg    [7:0]                                                   r_current_stream_handle             ;
wire   [7:0]                                                   w_current_stream_index              ; // 流索引(0-255，使用全部8位)
reg    [7:0]                                                   r_current_stream_index              ;

// 序列恢复核心变量
reg                                                            r_is_valid_sequence                 ;
wire                                                           w_is_valid_sequence                 ; // 当前序列号是否有效
reg    [16:0]                                                  r_delta_raw                         ; // 原始偏差(17位)
reg    [15:0]                                                  r_delta_abs                         ; // 偏差绝对值
wire    [15:0]                                                 w_delta_abs                         ; 
wire                                                           w_delta_sign                        ; // 偏差符号位(1:负数,0:正数)
reg                                                            r_delta_sign                        ;
reg                                                            r_delta_sign_d1                     ;
reg                                                            r_is_delta_in_range                 ; // 偏差是否在范围内
reg    [4:0]                                                   r_history_bit_index                 ; // 历史位索引
reg                                                            r_is_duplicate                      ; // 是否为重复包
wire                                                           w_is_duplicate                      ;
reg                                                            r_is_rogue                          ; // 是否为异常包
wire                                                           w_is_rogue                          ;
reg                                                            r_is_out_of_order                   ; // 是否为乱序包
reg                                                            r_should_pass                       ; // 是否应该通过
reg    [2:0]                                                   r_valid_counter                     ; // valid处理时间计数器

// 流查找和处理
// reg                                                            r_stream_found                      ; // 流是否找到
reg                                                            r_frer_seq_rcvy_take_no_sequence    ; // 允许接收无序列号包

// 统计计数器(全局)
reg    [31:0]                                                  r_passed_packets_cnt                ; // 通过的包数
reg    [31:0]                                                  r_discarded_packets_cnt             ; // 丢弃的包数
reg    [31:0]                                                  r_out_of_order_packets_cnt          ; // 乱序包数
reg    [31:0]                                                  r_rogue_packets_cnt                 ; // 异常包数
reg    [31:0]                                                  r_tagless_packets_cnt               ; // 无标签包数

/*========================================== 输入打拍逻辑 ==========================================*/
// 输入信号打拍
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
`ifdef CPU_MAC
        ri_rtag_flag0        <= 1'b0                           ;
        ri_rtag_sequence0    <= 16'h0                          ;
        ri_stream_handle0    <= 8'h0                           ;
`endif
`ifdef MAC1
        ri_rtag_flag1        <= 1'b0                           ;
        ri_rtag_sequence1    <= 16'h0                          ;
        ri_stream_handle1    <= 8'h0                           ;
`endif
`ifdef MAC2
        ri_rtag_flag2        <= 1'b0                           ;
        ri_rtag_sequence2    <= 16'h0                          ;
        ri_stream_handle2    <= 8'h0                           ;
`endif
`ifdef MAC3
        ri_rtag_flag3        <= 1'b0                           ;
        ri_rtag_sequence3    <= 16'h0                          ;
        ri_stream_handle3    <= 8'h0                           ;
`endif
`ifdef MAC4
        ri_rtag_flag4        <= 1'b0                           ;
        ri_rtag_sequence4    <= 16'h0                          ;
        ri_stream_handle4    <= 8'h0                           ;
`endif
`ifdef MAC5
        ri_rtag_flag5        <= 1'b0                           ;
        ri_rtag_sequence5    <= 16'h0                          ;
        ri_stream_handle5    <= 8'h0                           ;
`endif
`ifdef MAC6
        ri_rtag_flag6        <= 1'b0                           ;
        ri_rtag_sequence6    <= 16'h0                          ;
        ri_stream_handle6    <= 8'h0                           ;
`endif
`ifdef MAC7
        ri_rtag_flag7        <= 1'b0                           ;
        ri_rtag_sequence7    <= 16'h0                          ;
        ri_stream_handle7    <= 8'h0                           ;
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
        r_active_channels[0] <= `ifdef CPU_MAC (ri_rtag_flag0 == 1'b1 && ro_judge_finish[0] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[1] <= `ifdef MAC1    (ri_rtag_flag1 == 1'b1 && ro_judge_finish[1] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[2] <= `ifdef MAC2    (ri_rtag_flag2 == 1'b1 && ro_judge_finish[2] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[3] <= `ifdef MAC3    (ri_rtag_flag3 == 1'b1 && ro_judge_finish[3] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[4] <= `ifdef MAC4    (ri_rtag_flag4 == 1'b1 && ro_judge_finish[4] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[5] <= `ifdef MAC5    (ri_rtag_flag5 == 1'b1 && ro_judge_finish[5] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[6] <= `ifdef MAC6    (ri_rtag_flag6 == 1'b1 && ro_judge_finish[6] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
        r_active_channels[7] <= `ifdef MAC7    (ri_rtag_flag7 == 1'b1 && ro_judge_finish[7] == 1'd0) ? 1'b1 : 1'b0 `else 1'b0 `endif ;
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

// 处理中标志 - 单周期脉冲，标记开始处理
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_processing_flag <= 1'b0;
    end else begin
        r_processing_flag <= // 通道刚锁定时产生一个周期的处理脉冲
                            (r_channel_locked == 1'b0) && (r_active_channels[r_current_channel] == 1'b1) ? 
                            1'b1 : 
                            1'b0;
    end
end

// 当前处理通道计数器 - 只在通道未锁定时循环查找
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_channel <= 3'h0;
    end else begin
        r_current_channel <= // 通道锁定时保持不变
                             ((r_channel_locked == 1'b1 || r_active_channels[r_current_channel] == 1'b1) && ro_judge_finish[r_current_channel] == 1'd0) ?
                             r_current_channel :
                             // 当之前无活动通道现在有新活动通道时，立即跳转到新活动通道
                             (r_channel_locked == 1'b0) && (r_active_channels_d1 == 8'h0) && (r_active_channels != 8'h0) ?
                             r_new_active_channel :
                             // 未锁定状态：循环递增查找下一个通道
                             (r_channel_locked == 1'b0) && (r_current_channel == 3'd7) ? 3'h0 :
                             (r_channel_locked == 1'b0 ) ? 
                             r_current_channel + 3'h1 : 
                             r_current_channel;
    end
end

always @(posedge i_clk) begin
    r_current_stream_index <= w_current_stream_index;
end

// 当前处理包信息提取
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_current_rtag_flag <= 1'b0;
    end else begin
        r_current_rtag_flag <= (r_current_channel == 3'd0) ? `ifdef CPU_MAC ri_rtag_flag0 `else 1'b0 `endif :
                               (r_current_channel == 3'd1) ? `ifdef MAC1 ri_rtag_flag1 `else 1'b0 `endif :
                               (r_current_channel == 3'd2) ? `ifdef MAC2 ri_rtag_flag2 `else 1'b0 `endif :
                               (r_current_channel == 3'd3) ? `ifdef MAC3 ri_rtag_flag3 `else 1'b0 `endif :
                               (r_current_channel == 3'd4) ? `ifdef MAC4 ri_rtag_flag4 `else 1'b0 `endif :
                               (r_current_channel == 3'd5) ? `ifdef MAC5 ri_rtag_flag5 `else 1'b0 `endif :
                               (r_current_channel == 3'd6) ? `ifdef MAC6 ri_rtag_flag6 `else 1'b0 `endif :
                               (r_current_channel == 3'd7) ? `ifdef MAC7 ri_rtag_flag7 `else 1'b0 `endif :
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
// 流索引计算(直接使用stream_handle全部8位) 
assign w_current_stream_index  = r_current_stream_handle;

 

/*========================================== 序列恢复核心逻辑 ==========================================*/
// 序列号有效性判断 
assign w_is_valid_sequence = (r_current_rtag_flag == 1'b1) ?  1'b1 : 1'b0;
// 计算原始偏差
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_delta_raw <= 17'h0;
    end else begin
        r_delta_raw <= (w_is_valid_sequence == 1'b1 && r_processing_flag == 1'd1) ? 
                       {1'b0, r_current_sequence} - {1'b0, r_stream_recov_seq_num[w_current_stream_index]} : 
                       w_is_valid_sequence ? r_delta_raw : 17'h0;
    end
end

// 偏差符号和绝对值计算 
assign w_delta_sign = r_delta_raw[16];

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_delta_abs <= 16'h0;
    end else begin
        r_delta_abs <= (w_delta_sign == 1'b1) ? 
                       (~r_delta_raw[15:0] + 16'h1) : 
                       r_delta_raw[15:0];
    end
end

assign w_delta_abs = (w_delta_sign == 1'b1) ? 
(~r_delta_raw[15:0] + 16'h1) : 16'd0;

// 偏差范围检查
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_is_delta_in_range <= 1'b0;
    end else begin
        r_is_delta_in_range <= (r_delta_abs < {11'b0, FRER_SEQ_RCVY_HISTORY_LENGTH}) ? 
                               1'b1 : 
                               1'b0;
    end
end

// 历史位索引计算 - 滞后包的位索引
// 核心思想: bit[15]是最新接收的序列号, bit[14]是次新, ...
// 当前最新序列号在bit[15], 对应recov_seq-1
// 收到滞后包seq_rx, delta = seq_rx - recov_seq (delta<0)
// 例: recov_seq=12, seq_rx=9, delta=-3
//     bit[15]代表seq=11, bit[14]代表seq=10, bit[13]代表seq=9
//     所以seq=9应该在bit[15-2]=bit[13]
//     index = 15 - (recov_seq - seq_rx - 1) = 15 - |delta| + 1
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_history_bit_index <= 5'h0;
    end else begin
        // 滞后包位索引计算
        // bit[15]是最新(recov_seq-1), 往前推|delta|-1位
        // index = 15 - (|delta| - 1) = 16 - |delta|
        r_history_bit_index <= (w_delta_sign == 1'b1) ? (FRER_SEQ_RCVY_HISTORY_LENGTH - w_delta_abs[4:0]) : 5'd0;
    end
end

// 重复包检测
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_is_duplicate <= 1'b0;
    end else begin
        r_is_duplicate <= (r_delta_sign == 1'b1) && (r_history_bit_index < FRER_SEQ_RCVY_HISTORY_LENGTH) ? 
                          r_stream_history[r_current_stream_index][r_history_bit_index] : 
                          1'b0;
    end
end

assign w_is_duplicate = (r_delta_sign == 1'b1) && (r_history_bit_index < FRER_SEQ_RCVY_HISTORY_LENGTH) ? 
                          r_stream_history[r_current_stream_index][r_history_bit_index] : 
                          1'b0;


// 异常包检测
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_is_rogue <= 1'b0;
    end else begin
        r_is_rogue <= (w_is_valid_sequence == 1'b1) && (r_is_delta_in_range == 1'b0) ? 
                      1'b1 : 1'b0;
    end
end

assign w_is_rogue = (w_is_valid_sequence == 1'b1) && (r_is_delta_in_range == 1'b0) ? 1'b1 : 1'b0;

// 乱序包检测
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_is_out_of_order <= 1'b0;
    end else begin
        r_is_out_of_order <= ((r_delta_sign == 1'b1) && (r_is_duplicate == 1'b0)) ||
                             ((r_delta_sign == 1'b0) && (r_delta_abs != 16'h1) && (r_delta_abs != 16'h0)) ? 
                             1'b1 : 
                             1'b0;
    end
end
 
always @(posedge i_clk) begin
    r_delta_sign <= w_delta_sign;
    r_delta_sign_d1 <= r_delta_sign;
    r_is_valid_sequence <= w_is_valid_sequence;
end

// valid处理时间计数器
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_valid_counter <= 3'd0;
    end else  begin
        r_valid_counter <= ro_judge_finish != 1'd0 ? 
                            3'd0 :
                            (r_channel_locked == 1'd1 && r_valid_counter == 3'd4) ? 
                            3'd4 :
                            r_channel_locked == 1'd1 ? r_valid_counter + 3'd1 : r_valid_counter; // 无效时清零 
    end
end

// 允许接收无序列号包配置
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_frer_seq_rcvy_take_no_sequence <= 1'b0;
    end else begin
        r_frer_seq_rcvy_take_no_sequence <= r_frer_seq_rcvy_take_no_sequence;
    end
end

// 包通过判断逻辑
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_should_pass <= 1'b0;
    end else begin
        r_should_pass <= // 无效序列号的处理
                         (w_is_valid_sequence == 1'b0) ? 
                         (r_frer_seq_rcvy_take_no_sequence == 1'b1) ? 
                         1'b1 : 
                         1'b0 : 
                         // 有效序列号的处理
                         // TakeAny状态
                         (r_stream_take_any[w_current_stream_index] == 1'b1) ? 
                         1'b1 : 
                         // 异常包丢弃
                         (w_is_rogue == 1'b1) ? 
                         1'b0 : 
                         // 重复包丢弃
                         (r_is_duplicate == 1'b1) ? 
                         1'b0 :  
                         // 其他情况通过
                         1'b1;
    end
end

/*========================================== 流状态更新 ==========================================*/
// 流状态数组初始化和更新
// 流状态管理 - 使用generate展开
genvar g;
generate
    for (g = 0; g < MAX_STREAMS; g = g + 1) begin : stream_state_gen
        
        // 流预期序列号更新
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_recov_seq_num[g] <= 16'h0;
            end else begin
                r_stream_recov_seq_num[g] <= (r_current_rtag_flag == 1'b1) && (r_channel_locked == 1'd0) && (w_current_stream_index == g[7:0]) ?
                                            // TakeAny状态处理
                                            (r_stream_take_any[g] == 1'b1) && (r_should_pass == 1'b1) ?
                                            r_current_sequence + 16'h1 :
                                            // 正常流处理
                                            (w_is_valid_sequence == 1'b1) && (r_should_pass == 1'b1) ?
                                            // 超前包或正序包
                                            ((r_delta_sign == 1'b0) && (r_delta_abs > 16'h0)) || (r_delta_sign == 1'b0) && (r_delta_abs == 16'h0) ?
                                            r_current_sequence + 16'h1 :
                                            r_stream_recov_seq_num[g] :
                                            r_stream_recov_seq_num[g] :
                                            r_stream_recov_seq_num[g];
            end
        end
        
        // 流历史记录更新 - 滑动窗口策略
        // 核心原则: bit[15]是窗口最高位(最新位置)
        // 1. 正序包(delta=0): 右移1位, bit[15]置1
        // 2. 超前包(delta>0): 右移delta+1位, bit[15]置1 (窗口向前跳跃)
        // 3. 滞后包(delta<0): 在相应位置置1 (填补历史)
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_history[g] <= 16'd65535;
            end else begin
                // 只有当前包属于该流时才尝试更新历史
                if ((r_current_rtag_flag == 1'b1) && (w_current_stream_index == g[7:0])) begin
                    // TakeAny 状态下且通过: 初始化为bit[15]置1
                    if ((r_stream_take_any[g] == 1'b1) && (r_channel_locked == 1'b0)) begin
                        r_stream_history[g] <= 16'h1 << (FRER_SEQ_RCVY_HISTORY_LENGTH - 5'h1);
                    end else if ((w_delta_sign == 1'b0)&&(r_delta_raw == 17'h0) && (r_channel_locked == 1'b0)) begin
                        // 正序包(delta=0): 右移1位 + bit[15]置1
                        r_stream_history[g] <= (r_stream_history[g] >> 1) | (16'h1 << (FRER_SEQ_RCVY_HISTORY_LENGTH - 5'h1));
                    end else if ((r_channel_locked == 1'b0) && (w_delta_sign == 1'b0) && (r_delta_raw > 16'h0) && (r_delta_raw < FRER_SEQ_RCVY_HISTORY_LENGTH)) begin
                        // 超前包(delta>0): 右移(delta+1)位, bit[15]置1
                        // delta=seq_rx-recov_seq, 窗口需要移动(delta+1)才能让窗口起始对齐
                        // 例: recov_seq=9,窗口[8,7,6,5], seq_rx=11, delta=2
                        //     窗口需变为[11,10,9,8], 移动11-8=3=delta+1位
                        r_stream_history[g] <= (r_stream_history[g] >> (r_delta_raw[4:0] + 5'h1)) | (16'h1 << (FRER_SEQ_RCVY_HISTORY_LENGTH - 5'h1));
                    end else if ((w_delta_sign == 1'b1) && (r_delta_abs < FRER_SEQ_RCVY_HISTORY_LENGTH) && (r_channel_locked == 1'b0)) begin
                        // 滞后包(delta<0): 在计算出的位索引处置1
                        // 例: delta=-2, bit_index=16-2=14, [1,0,0,1] | (1<<14) = [1,1,0,1]
                        r_stream_history[g] <= r_stream_history[g] | (16'h1 << r_history_bit_index);
                    end else begin
                        // 超出范围,保持不变
                        r_stream_history[g] <= r_stream_history[g];
                    end
                end else begin
                    // 不属于当前流,保持不变
                    r_stream_history[g] <= r_stream_history[g];
                end
            end
        end
        // always @(posedge i_clk) begin
        //     if (i_rst == 1'b1) begin
        //         r_stream_history[g] <= 16'd65535;
        //     end else begin
        //         // 只有当前包属于该流时才尝试更新历史
        //         if ((r_channel_locked == 1'b1) && (w_current_stream_index == g[7:0])) begin
        //             // TakeAny 状态下且通过: 初始化为bit[15]置1
        //             if ((r_stream_take_any[g] == 1'b1) && (r_processing_flag == 1'b0)) begin
        //                 r_stream_history[g] <= 16'h1 << (FRER_SEQ_RCVY_HISTORY_LENGTH - 5'h1);
        //             end else if (r_is_valid_sequence == 1'b1) begin
        //                 // 常规流处理
        //                 if ((w_delta_sign == 1'b0)&&(r_delta_raw == 17'h0) && (r_processing_flag == 1'b0)) begin
        //                     // 正序包(delta=0): 右移1位 + bit[15]置1
        //                     r_stream_history[g] <= (r_stream_history[g] >> 1) | (16'h1 << (FRER_SEQ_RCVY_HISTORY_LENGTH - 5'h1));
        //                 end else if ((w_delta_sign == 1'b0) && (r_delta_raw > 16'h0) && (r_delta_raw < FRER_SEQ_RCVY_HISTORY_LENGTH)) begin
        //                     // 超前包(delta>0): 右移(delta+1)位, bit[15]置1
        //                     // delta=seq_rx-recov_seq, 窗口需要移动(delta+1)才能让窗口起始对齐
        //                     // 例: recov_seq=9,窗口[8,7,6,5], seq_rx=11, delta=2
        //                     //     窗口需变为[11,10,9,8], 移动11-8=3=delta+1位
        //                     r_stream_history[g] <= (r_stream_history[g] >> (r_delta_raw[4:0] + 5'h1)) | (16'h1 << (FRER_SEQ_RCVY_HISTORY_LENGTH - 5'h1));
        //                 end else if ((w_delta_sign == 1'b1) && (w_delta_abs < FRER_SEQ_RCVY_HISTORY_LENGTH)) begin
        //                     // 滞后包(delta<0): 在计算出的位索引处置1
        //                     // 例: delta=-2, bit_index=16-2=14, [1,0,0,1] | (1<<14) = [1,1,0,1]
        //                     r_stream_history[g] <= r_stream_history[g] | (16'h1 << r_history_bit_index);
        //                 end else begin
        //                     // 超出范围,保持不变
        //                     r_stream_history[g] <= r_stream_history[g];
        //                 end
        //             end else begin
        //                 // 无效序列号,保持不变
        //                 r_stream_history[g] <= r_stream_history[g];
        //             end
        //         end else begin
        //             // 不属于当前流,保持不变
        //             r_stream_history[g] <= r_stream_history[g];
        //         end
        //     end
        // end     
        
        // 流TakeAny状态更新
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_take_any[g] <= 1'b1;
            end else begin
                r_stream_take_any[g] <= (r_channel_locked == 1'b0) && (r_current_rtag_flag == 1'b1) && (w_current_stream_index == g[7:0]) ?
                                       (r_stream_take_any[g] == 1'b1) && (r_should_pass == 1'b1) ?
                                       1'b0 :
                                       r_stream_take_any[g] :
                                       r_stream_take_any[g];
            end
        end
        
        // 流激活状态更新
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_active[g] <= 1'b0;
            end else begin
                r_stream_active[g] <= (r_processing_flag == 1'b1) && (w_current_stream_index == g[7:0]) ?
                                     (r_stream_take_any[g] == 1'b1) && (r_should_pass == 1'b1) ?
                                     1'b1 :
                                     r_stream_active[g] :
                                     r_stream_active[g];
            end
        end
        
        // 流计时器更新
        always @(posedge i_clk) begin
            if (i_rst == 1'b1) begin
                r_stream_timer[g] <= 16'h0;
            end else begin
                r_stream_timer[g] <= (r_processing_flag == 1'b1) && (w_current_stream_index == g[7:0]) ?
                                    // 计时器重置条件
                                    (r_should_pass == 1'b1) || (r_is_rogue == 1'b1) ?
                                    16'h0 :
                                    r_stream_timer[g] + 16'h1 :
                                    // 非处理状态下的计时器递增
                                    (r_stream_active[g] == 1'b1) ?
                                    r_stream_timer[g] + 16'h1 :
                                    r_stream_timer[g];
            end
        end
        
    end
endgenerate

/*========================================== 统计计数器 ==========================================*/
// 通过包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_passed_packets_cnt <= 32'h0;
    end else begin
        r_passed_packets_cnt <= (r_processing_flag == 1'b1) && (r_should_pass == 1'b1) ? 
                                r_passed_packets_cnt + 32'h1 : 
                                r_passed_packets_cnt;
    end
end

// 丢弃包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_discarded_packets_cnt <= 32'h0;
    end else begin
        r_discarded_packets_cnt <= (r_processing_flag == 1'b1) && (r_should_pass == 1'b0) ? 
                                   r_discarded_packets_cnt + 32'h1 : 
                                   r_discarded_packets_cnt;
    end
end

// 乱序包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_out_of_order_packets_cnt <= 32'h0;
    end else begin
        r_out_of_order_packets_cnt <= (r_processing_flag == 1'b1) && (r_is_out_of_order == 1'b1) && (r_should_pass == 1'b1) ? 
                                      r_out_of_order_packets_cnt + 32'h1 : 
                                      r_out_of_order_packets_cnt;
    end
end

// 异常包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_rogue_packets_cnt <= 32'h0;
    end else begin
        r_rogue_packets_cnt <= (r_processing_flag == 1'b1) && (r_is_rogue == 1'b1) ? 
                               r_rogue_packets_cnt + 32'h1 : 
                               r_rogue_packets_cnt;
    end
end

// 无标签包计数
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_tagless_packets_cnt <= 32'h0;
    end else begin
        r_tagless_packets_cnt <= (r_processing_flag == 1'b1) && (w_is_valid_sequence == 1'b0) ? 
                                 r_tagless_packets_cnt + 32'h1 : 
                                 r_tagless_packets_cnt;
    end
end

/*========================================== 输出逻辑 ==========================================*/

// 通过使能输出
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_pass_en <= {PORT_NUM{1'b0}};
    end else begin
        ro_pass_en <= r_valid_counter == 3'd4 && (r_should_pass == 1'b1) ? 
                     ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_current_channel) : 
                     {PORT_NUM{1'b0}};
    end
end

// 丢弃使能输出
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_discard_en <= {PORT_NUM{1'b0}};
    end else begin
        ro_discard_en <= r_valid_counter == 3'd4 && (r_should_pass == 1'b0) ? 
                        ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_current_channel) : 
                        {PORT_NUM{1'b0}};
    end
end

// 判断完成输出
always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        ro_judge_finish <= {PORT_NUM{1'b0}};
    end else begin
        ro_judge_finish <= r_valid_counter == 3'd4 ? 
                          ({{(PORT_NUM-1){1'b0}}, 1'b1} << r_current_channel) : 
                          {PORT_NUM{1'b0}};
    end
end

/*========================================== 输出赋值 ==========================================*/
assign o_pass_en       = ro_pass_en       ;
assign o_discard_en    = ro_discard_en    ;
assign o_judge_finish  = ro_judge_finish  ;

endmodule 