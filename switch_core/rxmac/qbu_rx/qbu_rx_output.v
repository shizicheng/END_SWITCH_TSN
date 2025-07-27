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

    output      wire    [DWIDTH - 1:0]      o_qbu_rx_axis_data          ,
    output      wire    [15:0]              o_qbu_rx_axis_user          ,
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

// ready信号修改：IDLE时两路都拉高，其余按状态机选择，只有有一路数据进入后就拉低，直至再次没有数据进入，重新拉高
assign o_emac_axis_ready = (current_state == IDLE) ? 1'b1 : 
                           (current_state == EMAC ? i_qbu_rx_axis_ready : 1'b0);
assign o_pmac_axis_ready = (current_state == IDLE) ? 1'b1 : 
                           (current_state == PMAC ? i_qbu_rx_axis_ready : 1'b0);

assign  o_qbu_rx_axis_data   = data_r       ;
assign  o_qbu_rx_axis_user   = user_r       ;
assign  o_qbu_rx_axis_keep   = keep_r       ;
assign  o_qbu_rx_axis_last   = last_r       ;
assign  o_qbu_rx_axis_valid  = valid_r      ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
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
                if (i_emac_axis_last)
                    next_state = IDLE;
                else
                    next_state = EMAC;
            end else
                next_state = EMAC;
        end
        PMAC: begin
            if (i_qbu_rx_axis_ready) begin
                if (i_pmac_axis_last)
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
                data_r  <= i_emac_axis_data;
                user_r  <= i_emac_axis_user;
                keep_r  <= i_emac_axis_keep;
                last_r  <= i_emac_axis_last;
                valid_r <= i_emac_axis_valid;
            end
            PMAC: begin
                data_r  <= i_pmac_axis_data;
                user_r  <= i_pmac_axis_user;
                keep_r  <= i_pmac_axis_keep;
                last_r  <= i_pmac_axis_last;
                valid_r <= i_pmac_axis_valid;
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
