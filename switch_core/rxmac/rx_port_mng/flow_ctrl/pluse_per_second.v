`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/04 16:13:47
// Design Name: 
// Module Name: pluse_per_second
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
//  300Mhz / 250Mhz / 200Mhz / 100M / 50Mhz .... 
// 
//////////////////////////////////////////////////////////////////////////////////


module pluse_per_second#(
    parameter                       CLOCK_PERIOD    =  100_000_000  , 
    parameter                       SIM_MODE        =  "TRUE"         
)(              
    input                           i_pluse_clk                     , 
    input                           i_pluse_rst                     , 

    input                           i_pluse_valid                   , 

    output                          o_pluse_valid                   ,                         
    input                           i_pluse_ready                          
);              
    reg                             ri_pluse_valid                  ; 

    reg                             r_flow_run                      ; 

    reg         [15:0]              r_cnt_msec                      ; 
    reg                             r_cnt_msec_reset                ; 
    reg         [15:0]              r_cnt_second                    ; 

    reg                             r_cnt_second_reset              ; 
    reg                             r_cnt_second_reset_1d           ; 
    reg                             ro_pluse                        ; 

    wire                            w_pluse_valid_pos               ; 

    assign w_pluse_valid_pos    =   i_pluse_valid & !ri_pluse_valid ; 

    assign o_pluse_valid        =   ro_pluse                        ; 

    
    localparam  COUNTER_CNT     =   (SIM_MODE == "TRUE") ?         30    : CLOCK_PERIOD / 1000  ;     
    localparam  CARRY_NUM       =   (SIM_MODE == "TRUE") ?         10      : 1000                 ; 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            ri_pluse_valid <= 1'd0;
        else         
            ri_pluse_valid <= i_pluse_valid;
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_flow_run <= 1'd0;
        else begin 
            r_flow_run <=   w_pluse_valid_pos ? 1'd1 : 
                            r_flow_run;
        end 
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_msec <= 16'd0;
        else begin 
            r_cnt_msec <=   r_cnt_msec_reset    ? 16'd0 : 
                            r_flow_run == 1'b1  ? r_cnt_msec + 16'd1: 
                            r_cnt_msec;
        end 
    end 
    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_msec_reset <= 1'd0;
        else begin 
            r_cnt_msec_reset <= r_cnt_msec == COUNTER_CNT - 'd2 ? 1'd1: 
                                1'd0;
        end 
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_second <= 16'd0;
        else begin 
            r_cnt_second <= r_cnt_second_reset == 1'b1 ? 16'd0  : 
                            r_cnt_msec_reset   == 1'b1 ? r_cnt_second + 16'd1 : 
                            r_cnt_second;
        end 
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_second_reset <= 1'd0;
        else begin 
            r_cnt_second_reset <=   (r_cnt_second == CARRY_NUM -'d2 && r_cnt_msec_reset == 1'b1) ? 1'b1 : 
                                    1'd0;
        end     
    end 
    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_second_reset_1d <= 1'd0;
        else 
            r_cnt_second_reset_1d <= r_cnt_second_reset;
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            ro_pluse <= 1'd0;
        else begin 
            ro_pluse <= r_cnt_second_reset == 1'b1 ? 1'd1 : 
                        i_pluse_ready == 1'b1 ? 1'd0 : 
                        ro_pluse;
        end 
    end 

endmodule
