`include "synth_cmd_define.vh"

module  tsn_qav_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8      // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                   , // 250MHz
    input               wire                                    i_rst                   ,
    /*------------------------------ 寄存器配置接口 ----------------------------*/
    input               wire   [7:0]                            i_idleSlope_q0          ,
    input               wire   [7:0]                            i_idleSlope_q1          ,
    input               wire   [7:0]                            i_idleSlope_q2          ,
    input               wire   [7:0]                            i_idleSlope_q3          ,
    input               wire   [7:0]                            i_idleSlope_q4          ,
    input               wire   [7:0]                            i_idleSlope_q5          ,
    input               wire   [7:0]                            i_idleSlope_q6          ,
    input               wire   [7:0]                            i_idleSlope_q7          ,
    input               wire   [7:0]                            i_sendslope_q0          ,
    input               wire   [7:0]                            i_sendslope_q1          ,
    input               wire   [7:0]                            i_sendslope_q2          ,
    input               wire   [7:0]                            i_sendslope_q3          ,
    input               wire   [7:0]                            i_sendslope_q4          ,
    input               wire   [7:0]                            i_sendslope_q5          ,
    input               wire   [7:0]                            i_sendslope_q6          ,
    input               wire   [7:0]                            i_sendslope_q7          ,
    input               wire   [15:0]                           i_hithreshold_q0        ,
    input               wire   [15:0]                           i_hithreshold_q1        ,
    input               wire   [15:0]                           i_hithreshold_q2        ,
    input               wire   [15:0]                           i_hithreshold_q3        ,
    input               wire   [15:0]                           i_hithreshold_q4        ,
    input               wire   [15:0]                           i_hithreshold_q5        ,
    input               wire   [15:0]                           i_hithreshold_q6        ,
    input               wire   [15:0]                           i_hithreshold_q7        ,
    input               wire   [15:0]                           i_lothreshold_q0        ,
    input               wire   [15:0]                           i_lothreshold_q1        ,
    input               wire   [15:0]                           i_lothreshold_q2        ,
    input               wire   [15:0]                           i_lothreshold_q3        ,
    input               wire   [15:0]                           i_lothreshold_q4        ,
    input               wire   [15:0]                           i_lothreshold_q5        ,
    input               wire   [15:0]                           i_lothreshold_q6        ,
    input               wire   [15:0]                           i_lothreshold_q7        ,
    input               wire                                    i_config_vld            ,
    input               wire                                    i_qav_en                ,
    /*------------------------------ 调度信息输入 ------------------------------*/
    input               wire   [PORT_FIFO_PRI_NUM-1:0]          i_fifoc_empty           , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息
    input               wire   [PORT_FIFO_PRI_NUM-1:0]          i_scheduing_rst         , // 该端口调度流水线产生的调度结果
    input               wire                                    i_scheduing_rst_vld     , // 该端口调度流水线产生的调度结果有效位
    input               wire                                    i_mac_tx_axis_valid     , // 用于管理每个优先级队列的信用值
    input               wire                                    i_mac_tx_axis_last      ,  // 数据流 last 信号，用于使能调度流水线计算  
    input               wire  [15:0]                            i_mac_tx_axis_user      ,
    /*---------------- 将信用值满足调度需求的优先级队列信息输出 ------------------*/
    output              wire   [PORT_FIFO_PRI_NUM-1:0]          o_queue                 , // 输出满足信用值的队列结果向量
    output              wire                                    o_queue_vld            
);

wire        [7:0]                   w_idleSlope[0:PORT_FIFO_PRI_NUM-1];
wire        [7:0]                   w_sendslope[0:PORT_FIFO_PRI_NUM-1];
wire        [15:0]                  w_hithreshold[0:PORT_FIFO_PRI_NUM-1];
wire        [15:0]                  w_lothreshold[0:PORT_FIFO_PRI_NUM-1];

reg         [7:0]                   ri_admin_idleSlope[0:PORT_FIFO_PRI_NUM-1]      ;
reg         [7:0]                   ri_admin_sendslope[0:PORT_FIFO_PRI_NUM-1]      ;
reg         [15:0]                  ri_admin_hithreshold[0:PORT_FIFO_PRI_NUM-1]    ;
reg         [15:0]                  ri_admin_lothreshold[0:PORT_FIFO_PRI_NUM-1]    ;

reg                                 r_config_proc           ;
reg                                 r0_config_proc          ;

reg         [7:0]                   r_exe_idleSlope[0:PORT_FIFO_PRI_NUM-1]         ;
reg         [7:0]                   r_exe_sendslope[0:PORT_FIFO_PRI_NUM-1]         ;
reg         [15:0]                  r_exe_hithreshold[0:PORT_FIFO_PRI_NUM-1]       ;
reg         [15:0]                  r_exe_lothreshold[0:PORT_FIFO_PRI_NUM-1]       ;

reg         [15:0]                  queue_av_data   [7:0]   ; // 0 - 32768
reg         [PORT_FIFO_PRI_NUM-1:0] send_pri_flag           ;
reg                                 send_flag               ; // 是否有帧处于发送状态
reg         [PORT_FIFO_PRI_NUM-1:0] ro_queue                ;
reg                                 ro_queue_vld            ;
reg         [PORT_FIFO_PRI_NUM-1:0] r_av_rst                ;
reg                                 r_av_rst_vld            ;     

wire                                w_sche_star             ;
reg                                 r_sche                  ;
reg                                 r0_sche                 ;
reg                                 r_sche_star             ;
reg                                 r0_sche_star            ;
reg         [PORT_FIFO_PRI_NUM-1:0] ri_fifoc_empty          ;
wire        [PORT_FIFO_PRI_NUM-1:0] wn_fifoc_empty          ;


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_sche <= 1'b0;
    end else begin
        r_sche <= //(r0_config_proc == 1'b1 && r_config_proc == 1'b0 && i_mac_tx_axis_valid == 1'b0) ? 1'b1 :
                  (i_fifoc_empty != {PORT_FIFO_PRI_NUM{1'b1}} && i_mac_tx_axis_valid == 1'b0) ? 1'b1 : 
                  (r_sche == 1'b1 && i_mac_tx_axis_valid == 1'b1 && i_mac_tx_axis_last == 1'b1) ? 1'b0 : r_sche;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r0_sche <= 1'b0;
    end else begin
        r0_sche <= r_sche;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_sche_star  <= 1'b0;
        r0_sche_star <= 1'b0;
    end else begin
        r_sche_star  <= w_sche_star;
        r0_sche_star <= r_sche_star;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_fifoc_empty <= 8'hFF;
    end else begin
        ri_fifoc_empty <= (r_sche_star == 1'b1) ? i_fifoc_empty : ri_fifoc_empty;
    end
end

assign w_idleSlope[0]   = i_idleSlope_q0;
assign w_sendslope[0]   = i_sendslope_q0;
assign w_hithreshold[0] = i_hithreshold_q0;
assign w_lothreshold[0] = i_lothreshold_q0;
assign w_idleSlope[1]   = i_idleSlope_q1;
assign w_sendslope[1]   = i_sendslope_q1;
assign w_hithreshold[1] = i_hithreshold_q1;
assign w_lothreshold[1] = i_lothreshold_q1;
assign w_idleSlope[2]   = i_idleSlope_q2;
assign w_sendslope[2]   = i_sendslope_q2;
assign w_hithreshold[2] = i_hithreshold_q2;
assign w_lothreshold[2] = i_lothreshold_q2;
assign w_idleSlope[3]   = i_idleSlope_q3;
assign w_sendslope[3]   = i_sendslope_q3;
assign w_hithreshold[3] = i_hithreshold_q3;
assign w_lothreshold[3] = i_lothreshold_q3;
assign w_idleSlope[4]   = i_idleSlope_q4;
assign w_sendslope[4]   = i_sendslope_q4;
assign w_hithreshold[4] = i_hithreshold_q4;
assign w_lothreshold[4] = i_lothreshold_q4;
assign w_idleSlope[5] = i_idleSlope_q5;
assign w_sendslope[5] = i_sendslope_q5;
assign w_hithreshold[5] = i_hithreshold_q5;
assign w_lothreshold[5] = i_lothreshold_q5;
assign w_idleSlope[6] = i_idleSlope_q6;
assign w_sendslope[6] = i_sendslope_q6;
assign w_hithreshold[6] = i_hithreshold_q6;
assign w_lothreshold[6] = i_lothreshold_q6;
assign w_idleSlope[7] = i_idleSlope_q7;
assign w_sendslope[7] = i_sendslope_q7;
assign w_hithreshold[7] = i_hithreshold_q7;
assign w_lothreshold[7] = i_lothreshold_q7;

genvar i;
generate
    for(i=0;i<PORT_FIFO_PRI_NUM;i=i+1) begin
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                ri_admin_idleSlope[i]    <= 8'd0;
                ri_admin_sendslope[i]    <= 8'd0;
                ri_admin_hithreshold[i]  <= 16'd0;
                ri_admin_lothreshold[i]  <= 16'd0;
            end else begin
                ri_admin_idleSlope[i]    <= (i_config_vld == 1'b1) ? w_idleSlope[i] : ri_admin_idleSlope[i];
                ri_admin_sendslope[i]    <= (i_config_vld == 1'b1) ? w_sendslope[i] : ri_admin_sendslope[i];
                ri_admin_hithreshold[i]  <= (i_config_vld == 1'b1) ? w_hithreshold[i] : ri_admin_hithreshold[i];
                ri_admin_lothreshold[i]  <= (i_config_vld == 1'b1) ? w_lothreshold[i] : ri_admin_lothreshold[i];
            end
        end
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_exe_idleSlope[i]       <= 8'd0;
                r_exe_sendslope[i]       <= 8'd0;
                r_exe_hithreshold[i]     <= 16'd0;
                r_exe_lothreshold[i]     <= 16'd0;
            end else begin
                r_exe_idleSlope[i]       <= (i_mac_tx_axis_valid == 1'b0) ? ri_admin_idleSlope[i] : r_exe_idleSlope[i];
                r_exe_sendslope[i]       <= (i_mac_tx_axis_valid == 1'b0) ? ri_admin_sendslope[i] : r_exe_sendslope[i];
                r_exe_hithreshold[i]     <= (i_mac_tx_axis_valid == 1'b0) ? ri_admin_hithreshold[i] : r_exe_hithreshold[i];
                r_exe_lothreshold[i]     <= (i_mac_tx_axis_valid == 1'b0) ? ri_admin_lothreshold[i] : r_exe_lothreshold[i];
            end
        end
    end
endgenerate

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_config_proc <= 1'b0;
        r0_config_proc <= 1'b0;
    end else begin
        r_config_proc <= (i_config_vld == 1'b1) ? 1'b1 : (i_mac_tx_axis_valid == 1'b0) ? 1'b0 : r_config_proc;
        r0_config_proc <= r_config_proc;
    end
end



always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_queue <= {(PORT_FIFO_PRI_NUM){1'b0}};
        ro_queue_vld <= 1'b0;
    end else begin
        ro_queue        <= (i_qav_en == 1'b1) ? r_av_rst     : wn_fifoc_empty;
        ro_queue_vld    <= (i_qav_en == 1'b1) ? r_av_rst_vld : r0_sche_star;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        send_flag <= 1'b0;
    end else begin
        send_flag <= |send_pri_flag;
    end
end

generate
    for (i = 0; i < PORT_FIFO_PRI_NUM; i = i + 1) begin
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                send_pri_flag[i] <= 1'b0;
            end else begin
                send_pri_flag[i] <= (i_mac_tx_axis_last == 1'b1 && i_mac_tx_axis_valid == 1'b1 && i_scheduing_rst[i] == 1'b1) ? 1'b0 : 
                                    (i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[i] == 1'b1) ? 1'b1 : send_pri_flag[i];
            end
        end
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                queue_av_data[i] <= 16'd0;
            end else begin
                queue_av_data[i] <= (r0_config_proc == 1'b1 && r_config_proc == 1'b0) ? r_exe_lothreshold[i] : 
                (send_pri_flag[i] == 1'b1 && send_flag == 1'b1 && queue_av_data[i] != 16'h0000) ? (queue_av_data[i] - r_exe_sendslope[i]) : 
                (send_pri_flag[i] == 1'b1 && send_flag == 1'b1 && queue_av_data[i] == 16'h0000) ? queue_av_data[i] :
                (send_pri_flag[i] == 1'b0 && queue_av_data[i] != r_exe_hithreshold[i]) ? (queue_av_data[i] + r_exe_idleSlope[i]) : queue_av_data[i];
            end
        end
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_av_rst[i] <= {(PORT_FIFO_PRI_NUM){1'b0}};
            end else begin
                r_av_rst[i] <= ((queue_av_data[i] >= r_exe_lothreshold[i]) && ri_fifoc_empty[i] == 1'b0) ? 1'b1 : 1'b0;  
            end
        end
    end
endgenerate

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_av_rst_vld <= 1'b0;
    end else begin
        r_av_rst_vld <= r0_sche_star;
    end
end

assign w_sche_star    = (r_sche == 1'b1 && r0_sche == 1'b0) ? 1'b1 : 
                        (i_mac_tx_axis_valid == 1'b1 && i_mac_tx_axis_last == 1'b1 && i_fifoc_empty != {PORT_FIFO_PRI_NUM{1'b1}}) ? 1'b1 : 1'b0;
assign wn_fifoc_empty = ~ri_fifoc_empty;
assign o_queue        =  ro_queue ;
assign o_queue_vld    =  ro_queue_vld;

endmodule