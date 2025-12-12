`include "synth_cmd_define.vh"

module  tx_qos_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8      // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                               , // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口 --------------------------------------*/
    input               wire   [3:0]                            i_qos_sch                           , // 000：WRR,001:SP,010: DWRR
    input               wire                                    i_qos_en                            , 

    input               wire   [PORT_FIFO_PRI_NUM*4-1:0]        i_weights                           , // WRR 权重 (高位 Q7，低位 Q0)
    input               wire                                    i_config_vld                        ,


    input               wire   [PORT_FIFO_PRI_NUM-1:0]          i_ControlList_state                 , // 门控列表的状态
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    input               wire                                    i_qos_req                           ,
    output              wire   [PORT_FIFO_PRI_NUM-1:0]          o_qos_scheduing_res                 ,
    output              wire                                    o_qos_scheduing_rst_vld                                
);


reg  [PORT_FIFO_PRI_NUM-1:0] r_ControlList_state;
reg                          r_ControlList_state_vld;
 
 
reg  [PORT_FIFO_PRI_NUM-1:0] r_qos_sche_res;
reg                          r_qos_sche_res_vld;
 
reg  [2:0]                   r_current_ptr;
reg  [3:0]                   r_weight [PORT_FIFO_PRI_NUM-1:0];
wire [PORT_FIFO_PRI_NUM-1:0] wn_weight;
wire                         wn_weight_flag;
wire [3:0]                   w_weight [PORT_FIFO_PRI_NUM-1:0];



always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_ControlList_state     <= {PORT_FIFO_PRI_NUM{1'b0}};
        r_ControlList_state_vld <= 1'b0;
    end else begin
        r_ControlList_state     <= (i_qos_req == 1'b1) ? i_ControlList_state : r_ControlList_state;
        r_ControlList_state_vld <= (i_qos_req == 1'b1) ? 1'b1 : 1'b0;
    end
end

genvar i;
generate
    for (i = 0; i < PORT_FIFO_PRI_NUM; i = i + 1) begin
        assign wn_weight[i] = |r_weight[i];
        assign w_weight[i] = i_weights[i*4 +: 4];
    end
endgenerate

assign wn_weight_flag = |wn_weight;

integer idx;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        for (idx = 0; idx < PORT_FIFO_PRI_NUM; idx = idx + 1) begin
            r_weight[idx] <= 4'd0;
        end
    end else if(i_qos_sch != 4'b0000) begin
        for (idx = 0; idx < PORT_FIFO_PRI_NUM; idx = idx + 1) begin
            r_weight[idx] <= 4'd0;
        end
    end else if (i_config_vld == 1'b1) begin
        for (idx = 0; idx < PORT_FIFO_PRI_NUM; idx = idx + 1) begin
            r_weight[idx] <= w_weight[idx];
        end
    end else if (wn_weight_flag == 1'b0 && i_qos_req == 1'b1 && r_current_ptr == PORT_FIFO_PRI_NUM - 1'b1) begin
        for (idx = 0; idx < PORT_FIFO_PRI_NUM; idx = idx + 1) begin
            r_weight[idx] <= w_weight[idx];
        end
    end else begin
        for (idx = 0; idx < PORT_FIFO_PRI_NUM; idx = idx + 1) begin
            r_weight[idx] <= r_qos_sche_res[idx] == 1'b1 && r_qos_sche_res_vld == 1'b1 && r_weight[idx] != 4'h0 ? r_weight[idx] - 1'b1 : r_weight[idx];
        end  
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_current_ptr <= 3'b000;
    end else if(i_qos_req == 1'b1) begin
        r_current_ptr <= r_current_ptr == PORT_FIFO_PRI_NUM - 1'b1 ? 3'b000 : r_current_ptr + 1'b1;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
            r_qos_sche_res <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else if(i_qos_sch == 4'b0001 && i_qos_req == 1'b1) begin//SP
        if(PORT_FIFO_PRI_NUM == 8) begin
            r_qos_sche_res <= i_ControlList_state[7] == 1'd1 ? 8'h80 : 
                              i_ControlList_state[6] == 1'd1 ? 8'h40 : 
                              i_ControlList_state[5] == 1'd1 ? 8'h20 : 
                              i_ControlList_state[4] == 1'd1 ? 8'h10 : 
                              i_ControlList_state[3] == 1'd1 ? 8'h08 : 
                              i_ControlList_state[2] == 1'd1 ? 8'h04 : 
                              i_ControlList_state[1] == 1'd1 ? 8'h02 : 
                              i_ControlList_state[0] == 1'd1 ? 8'h01 : 8'h00; 
        end else if(PORT_FIFO_PRI_NUM == 7) begin
            r_qos_sche_res <= i_ControlList_state[6] == 1'd1 ? 7'h40 : 
                              i_ControlList_state[5] == 1'd1 ? 7'h20 : 
                              i_ControlList_state[4] == 1'd1 ? 7'h10 : 
                              i_ControlList_state[3] == 1'd1 ? 7'h08 : 
                              i_ControlList_state[2] == 1'd1 ? 7'h04 : 
                              i_ControlList_state[1] == 1'd1 ? 7'h02 : 
                              i_ControlList_state[0] == 1'd1 ? 7'h01 : 7'h00; 
        end else if(PORT_FIFO_PRI_NUM == 6) begin
            r_qos_sche_res <= i_ControlList_state[5] == 1'd1 ? 6'h20 : 
                              i_ControlList_state[4] == 1'd1 ? 6'h10 : 
                              i_ControlList_state[3] == 1'd1 ? 6'h08 : 
                              i_ControlList_state[2] == 1'd1 ? 6'h04 : 
                              i_ControlList_state[1] == 1'd1 ? 6'h02 : 
                              i_ControlList_state[0] == 1'd1 ? 6'h01 : 6'h00; 
        end else if(PORT_FIFO_PRI_NUM == 5) begin
            r_qos_sche_res <= i_ControlList_state[4] == 1'd1 ? 5'h10 : 
                              i_ControlList_state[3] == 1'd1 ? 5'h08 : 
                              i_ControlList_state[2] == 1'd1 ? 5'h04 : 
                              i_ControlList_state[1] == 1'd1 ? 5'h02 : 
                              i_ControlList_state[0] == 1'd1 ? 5'h01 : 5'h00; 
        end else if(PORT_FIFO_PRI_NUM == 4) begin
            r_qos_sche_res <= i_ControlList_state[3] == 1'd1 ? 4'h8  : 
                              i_ControlList_state[2] == 1'd1 ? 4'h4  : 
                              i_ControlList_state[1] == 1'd1 ? 4'h2  : 
                              i_ControlList_state[0] == 1'd1 ? 4'h1  : 4'h00; 
        end else if(PORT_FIFO_PRI_NUM == 3) begin 
            r_qos_sche_res <= i_ControlList_state[2] == 1'd1 ? 3'h4  : 
                              i_ControlList_state[1] == 1'd1 ? 3'h2  : 
                              i_ControlList_state[0] == 1'd1 ? 3'h1  : 3'h00; 
        end else if(PORT_FIFO_PRI_NUM == 2) begin
            r_qos_sche_res <= i_ControlList_state[1] == 1'd1 ? 2'b10 : 
                              i_ControlList_state[0] == 1'd1 ? 2'b01 : 2'h00; 
        end else if(PORT_FIFO_PRI_NUM == 1) begin
            r_qos_sche_res <= i_ControlList_state[0] == 1'd1 ? 1'b1  : 1'b0; 
        end
    end else if(i_qos_sch == 4'b0000 && i_qos_req == 1'b1) begin//WRR
        if(PORT_FIFO_PRI_NUM == 8) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 : 8'h00;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 : 8'h00;
            end else if(r_current_ptr == 3'b010) begin
                r_qos_sche_res <= (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 : 8'h00;
            end else if(r_current_ptr == 3'b011) begin
                r_qos_sche_res <= (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 : 8'h00;
            end else if(r_current_ptr == 3'b100) begin
                r_qos_sche_res <= (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 : 8'h00;
            end else if(r_current_ptr == 3'b101) begin
                r_qos_sche_res <= (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 : 8'h00;
            end else if(r_current_ptr == 3'b110) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 : 8'h00;
            end else if(r_current_ptr == 3'b111) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 8'h01 :
                                  (i_ControlList_state[7] && r_weight[7] > 4'd0) ? 8'h80 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 8'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 8'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 8'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 8'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 8'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 8'h02 : 8'h00;
            end
        end else if(PORT_FIFO_PRI_NUM == 7) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 : 7'h00;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 : 7'h00;
            end else if(r_current_ptr == 3'b010) begin
                r_qos_sche_res <= (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 : 7'h00;
            end else if(r_current_ptr == 3'b011) begin
                r_qos_sche_res <= (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 : 7'h00;
            end else if(r_current_ptr == 3'b100) begin
                r_qos_sche_res <= (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 : 7'h00;
            end else if(r_current_ptr == 3'b101) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 : 7'h00;
            end else if(r_current_ptr == 3'b110) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 7'h01 :
                                  (i_ControlList_state[6] && r_weight[6] > 4'd0) ? 7'h40 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 7'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 7'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 7'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 7'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 7'h02 : 7'h00;
            end
        end else if(PORT_FIFO_PRI_NUM == 6) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 6'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 6'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 6'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 6'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 6'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 6'h01 : 6'h00;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 6'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 6'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 6'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 6'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 6'h01 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 6'h20 : 6'h00;
            end else if(r_current_ptr == 3'b010) begin
                r_qos_sche_res <= (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 6'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 6'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 6'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 6'h01 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 6'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 6'h10 : 6'h00;
            end else if(r_current_ptr == 3'b011) begin
                r_qos_sche_res <= (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 6'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 6'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 6'h01 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 6'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 6'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 6'h08 : 6'h00;
            end else if(r_current_ptr == 3'b100) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 6'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 6'h01 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 6'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 6'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 6'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 6'h04 : 6'h00;
            end else if(r_current_ptr == 3'b101) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 6'h01 :
                                  (i_ControlList_state[5] && r_weight[5] > 4'd0) ? 6'h20 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 6'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 6'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 6'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 6'h02 : 6'h00;
            end
        end else if(PORT_FIFO_PRI_NUM == 5) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 5'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 5'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 5'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 5'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 5'h01 : 5'h00;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 5'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 5'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 5'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 5'h01 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 5'h10 : 5'h00;
            end else if(r_current_ptr == 3'b010) begin
                r_qos_sche_res <= (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 5'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 5'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 5'h01 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 5'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 5'h08 : 5'h00;
            end else if(r_current_ptr == 3'b011) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 5'h02 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 5'h01 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 5'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 5'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 5'h04 : 5'h00;
            end else if(r_current_ptr == 3'b100) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 5'h01 :
                                  (i_ControlList_state[4] && r_weight[4] > 4'd0) ? 5'h10 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 5'h08 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 5'h04 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 5'h02 : 5'h00;
            end
        end else if(PORT_FIFO_PRI_NUM == 4) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 4'h8 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 4'h4 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 4'h2 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 4'h1 : 4'h0;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 4'h4 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 4'h2 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 4'h1 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 4'h8 : 4'h0;
            end else if(r_current_ptr == 3'b010) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 4'h2 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 4'h1 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 4'h8 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 4'h4 : 4'h0;
            end else if(r_current_ptr == 3'b011) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 4'h1 :
                                  (i_ControlList_state[3] && r_weight[3] > 4'd0) ? 4'h8 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 4'h4 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 4'h2 : 4'h0;
            end
        end else if(PORT_FIFO_PRI_NUM == 3) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 3'h4 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 3'h2 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 3'h1 : 3'h0;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 3'h2 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 3'h1 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 3'h4 : 3'h0;
            end else if(r_current_ptr == 3'b010) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 3'h1 :
                                  (i_ControlList_state[2] && r_weight[2] > 4'd0) ? 3'h4 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 3'h2 : 3'h0;
            end
        end else if(PORT_FIFO_PRI_NUM == 2) begin
            if(r_current_ptr == 3'b000) begin
                r_qos_sche_res <= (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 2'h2 :
                                  (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 2'h1 : 2'h0;
            end else if(r_current_ptr == 3'b001) begin
                r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 2'h1 :
                                  (i_ControlList_state[1] && r_weight[1] > 4'd0) ? 2'h2 : 2'h0;
            end
        end else if(PORT_FIFO_PRI_NUM == 1) begin
            r_qos_sche_res <= (i_ControlList_state[0] && r_weight[0] > 4'd0) ? 1'h1 : 1'h0;
        end
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_qos_sche_res_vld <= 1'b0;
    end else begin
        r_qos_sche_res_vld <= (i_qos_req == 1'b1) ? 1'b1 : 1'b0;
    end
end

assign o_qos_scheduing_res = i_qos_en == 1'b1 ? r_qos_sche_res : r_ControlList_state;
assign o_qos_scheduing_rst_vld = i_qos_en == 1'b1 ? r_qos_sche_res_vld : r_ControlList_state_vld;



endmodule