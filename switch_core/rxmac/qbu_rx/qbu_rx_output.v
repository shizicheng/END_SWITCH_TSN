module qbu_rx_output#(
    parameter                               DWIDTH          = 'd8                                   

)(
    input       wire                        i_clk                       ,
    input       wire                        i_rst                       ,

    input       wire    [DWIDTH - 1:0]      i_pmac_axis_data            ,          
    input       wire    [15:0]              i_pmac_axis_user            ,          
    input       wire    [(DWIDTH/8)-1:0]    i_pmac_axis_keep            ,          
    input       wire                        i_pmac_axis_last            ,          
    input       wire                        i_pmac_axis_valid           ,          
    output      wire                        o_pmac_axis_ready           ,

    input       wire    [DWIDTH - 1:0]      i_emac_axis_data            ,          
    input       wire    [15:0]              i_emac_axis_user            ,          
    input       wire    [(DWIDTH/8)-1:0]    i_emac_axis_keep            ,          
    input       wire                        i_emac_axis_last            ,          
    input       wire                        i_emac_axis_valid           ,          
    output      wire                        o_emac_axis_ready           ,

    output      wire                        o_rd_emac_info              , // 读EMAC信息
    output      wire                        o_rd_pmac_info              , // 读PMAC信息
    // output      wire    [47:0]				o_dmac				        ,
	// output      wire    					o_dmac_valid 		        ,
	// output      wire    [47:0]				o_samc 					    ,
	// output      wire    					o_smac_valid 		        ,

    output      wire    [DWIDTH - 1:0]      o_qbu_rx_axis_data          ,
    output      wire    [15:0]              o_qbu_rx_axis_user          ,  // 最高位表示当前数据是从emac还是pamc输出的 ， emac 为0 ， pmac 为1
    output      wire    [(DWIDTH/8)-1:0]    o_qbu_rx_axis_keep          ,
    output      wire                        o_qbu_rx_axis_last          ,
    output      wire                        o_qbu_rx_axis_valid         ,
    input       wire                        i_qbu_rx_axis_ready            
);
// 仲裁状态机
localparam                  IDLE  = 2'd0    ;
localparam                  EMAC  = 2'd1    ;
localparam                  PMAC  = 2'd2    ;

reg        [1:0]            current_state   ;
reg        [1:0]            next_state      ;

// 保存当前输出通道
reg        [DWIDTH-1:0]     data_r          ;
reg        [15:0]           user_r          ;
reg        [(DWIDTH/8)-1:0] keep_r          ;
reg                         last_r          ;
reg                         valid_r         ;
reg        [1:0]            current_state_r ;

// 读信息脉冲生成相关寄存器
reg                         r_rd_emac_info  ;
reg                         r_rd_pmac_info  ;

// MAC地址解析相关寄存器
reg        [47:0]           r_dmac          ;
reg                         r_dmac_valid    ;
reg        [47:0]           r_smac          ;
reg                         r_smac_valid    ;
reg        [3:0]            r_byte_cnt      ; // 字节计数器，0-11表示MAC地址接收
// ready信号修改：IDLE时两路都拉高，其余按状态机选择，只有有一路数据进入后就拉低，直至再次没有数据进入，重新拉高
assign o_emac_axis_ready = (current_state == IDLE) ? 1'b1 : 
                           (current_state == EMAC ? i_qbu_rx_axis_ready : 1'b0);
assign o_pmac_axis_ready = (current_state == IDLE) ? 1'b1 : 
                           (current_state == PMAC ? i_qbu_rx_axis_ready : 1'b0);

assign  o_qbu_rx_axis_data   = data_r       ;
// assign  o_qbu_rx_axis_user   = user_r       ;
// 完善user信号，最高位表示数据来源（emac为0，pmac为1），其余位为原user信号
assign o_qbu_rx_axis_user = (current_state_r == EMAC) ? {1'b1, user_r[14:0]} :
                            (current_state_r == PMAC) ? {1'b0, user_r[14:0]} :
                           16'd0;
assign  o_qbu_rx_axis_keep   = keep_r       ;
assign  o_qbu_rx_axis_last   = last_r       ;
assign  o_qbu_rx_axis_valid  = valid_r      ;

// 读信息信号输出
assign  o_rd_emac_info       = r_rd_emac_info;
assign  o_rd_pmac_info       = r_rd_pmac_info;

// MAC地址输出
assign  o_dmac               = r_dmac;
assign  o_dmac_valid         = r_dmac_valid;
assign  o_samc               = r_smac;
assign  o_smac_valid         = r_smac_valid;


// one-cycle registers for the listed input signals (explicit bit widths)
reg  [DWIDTH-1:0]          r_pmac_axis_data;
reg  [15:0]                r_pmac_axis_user;
reg  [(DWIDTH/8)-1:0]      r_pmac_axis_keep;
reg                        r_pmac_axis_last;
reg                        r_pmac_axis_valid;

reg  [DWIDTH-1:0]          r_emac_axis_data;
reg  [15:0]                r_emac_axis_user;
reg  [(DWIDTH/8)-1:0]      r_emac_axis_keep;
reg                        r_emac_axis_last;
reg                        r_emac_axis_valid;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_pmac_axis_data  <= {DWIDTH{1'b0}};
        r_pmac_axis_user  <= 16'd0;
        r_pmac_axis_keep  <= {(DWIDTH/8){1'b0}};
        r_pmac_axis_last  <= 1'b0;
        r_pmac_axis_valid <= 1'b0;

        r_emac_axis_data  <= {DWIDTH{1'b0}};
        r_emac_axis_user  <= 16'd0;
        r_emac_axis_keep  <= {(DWIDTH/8){1'b0}};
        r_emac_axis_last  <= 1'b0;
        r_emac_axis_valid <= 1'b0;
    end else begin
        r_pmac_axis_data  <= i_pmac_axis_data;
        r_pmac_axis_user  <= i_pmac_axis_user;
        r_pmac_axis_keep  <= i_pmac_axis_keep;
        r_pmac_axis_last  <= i_pmac_axis_last;
        r_pmac_axis_valid <= i_pmac_axis_valid;

        r_emac_axis_data  <= i_emac_axis_data;
        r_emac_axis_user  <= i_emac_axis_user;
        r_emac_axis_keep  <= i_emac_axis_keep;
        r_emac_axis_last  <= i_emac_axis_last;
        r_emac_axis_valid <= i_emac_axis_valid;
    end
end
 


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end
 

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        current_state_r <= 2'd0;
    end
    else begin
        current_state_r <= current_state;
    end
end

// 读EMAC信息脉冲生成 - 在IDLE到EMAC转换时拉高
always @(*) begin
    if (i_rst == 1'b1) begin
        r_rd_emac_info <= 1'b0;
    end
    else begin
        r_rd_emac_info <= (current_state == IDLE && next_state == EMAC) ? 1'b1 : 1'b0;
    end
end

// 读PMAC信息脉冲生成 - 在IDLE到PMAC转换时拉高
always @(*) begin
    if (i_rst == 1'b1) begin
        r_rd_pmac_info <= 1'b0;
    end
    else begin
        r_rd_pmac_info <= (current_state == IDLE && next_state == PMAC) ? 1'b1 : 1'b0;
    end
end

// 字节计数器 - 用于MAC地址解析
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_byte_cnt <= 4'd0;
    end
    else begin
        r_byte_cnt <= (current_state == IDLE) ? 
                      4'd0 :
                      ((current_state == EMAC || current_state == PMAC) && valid_r == 1'b1 && i_qbu_rx_axis_ready == 1'b1 && r_byte_cnt < 4'd12) ?
                      r_byte_cnt + 4'd1 :
                      r_byte_cnt;
    end
end

// DMAC解析 - 前6个字节（字节0-5）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_dmac <= 48'd0;
    end
    else begin
        r_dmac <= ((current_state == EMAC || current_state == PMAC) && valid_r == 1'b1 && i_qbu_rx_axis_ready == 1'b1 && r_byte_cnt < 4'd6) ?
                  {r_dmac[39:0], data_r} :
                  r_dmac;
    end
end

// DMAC有效标志 - 接收到第6个字节后拉高
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_dmac_valid <= 1'b0;
    end
    else begin
        r_dmac_valid <= (current_state == IDLE) ?
                        1'b0 :
                        ((current_state == EMAC || current_state == PMAC) && valid_r == 1'b1 && i_qbu_rx_axis_ready == 1'b1 && r_byte_cnt == 4'd5) ?
                        1'b1 :
                        r_dmac_valid;
    end
end

// SMAC解析 - 第7-12个字节（字节6-11）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_smac <= 48'd0;
    end
    else begin
        r_smac <= ((current_state == EMAC || current_state == PMAC) && valid_r == 1'b1 && i_qbu_rx_axis_ready == 1'b1 && r_byte_cnt >= 4'd6 && r_byte_cnt < 4'd12) ?
                  {r_smac[39:0], data_r} :
                  r_smac;
    end
end

// SMAC有效标志 - 接收到第12个字节后拉高
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_smac_valid <= 1'b0;
    end
    else begin
        r_smac_valid <= (current_state == IDLE) ?
                        1'b0 :
                        ((current_state == EMAC || current_state == PMAC) && valid_r == 1'b1 && i_qbu_rx_axis_ready == 1'b1 && r_byte_cnt == 4'd11) ?
                        1'b1 :
                        r_smac_valid;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            if (i_emac_axis_valid)
                next_state = EMAC;
            else if (i_pmac_axis_valid)
                next_state = PMAC;
            else
                next_state = IDLE;
        end
        EMAC: begin
            if (i_qbu_rx_axis_ready) begin
                if (r_emac_axis_last)
                    next_state = IDLE;
                else
                    next_state = EMAC;
            end else
                next_state = EMAC;
        end
        PMAC: begin
            if (i_qbu_rx_axis_ready) begin
                if (r_pmac_axis_last)
                    next_state = IDLE;
                else
                    next_state = PMAC;
            end else
                next_state = PMAC;
        end
        default: next_state = IDLE;
    endcase
end

// 输出数据选择
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        data_r  <= {DWIDTH{1'b0}};
        user_r  <= 16'd0;
        keep_r  <= {(DWIDTH/8){1'b0}};
        last_r  <= 1'b0;
        valid_r <= 1'b0;
    end else begin
        case (current_state)
            EMAC: begin
                data_r  <= r_emac_axis_data;
                user_r  <= r_emac_axis_user;
                keep_r  <= r_emac_axis_keep;
                last_r  <= r_emac_axis_last;
                valid_r <= r_emac_axis_valid;
            end
            PMAC: begin
                data_r  <= r_pmac_axis_data;
                user_r  <= r_pmac_axis_user;
                keep_r  <= r_pmac_axis_keep;
                last_r  <= r_pmac_axis_last;
                valid_r <= r_pmac_axis_valid;
            end
            default: begin
                data_r  <= {DWIDTH{1'b0}};
                user_r  <= 16'd0;
                keep_r  <= {(DWIDTH/8){1'b0}};
                last_r  <= 1'b0;
                valid_r <= 1'b0;
            end
        endcase
    end
end

endmodule
