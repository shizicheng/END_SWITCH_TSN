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

    output                          o_pluse                         ,
    output                          o_pluse_last                                
);              
    reg                             ri_pluse_valid                  ; 

    reg                             r_flow_run                      ; 
    reg         [31:0]              r_cnt_msec                      ; 
    reg                             r_cnt_msec_reset                ; 
    reg         [31:0]              r_cnt_second                    ; 
    reg                             r_cnt_second_reset              ; 
    reg                             r_cnt_second_reset_1d           ; 
    reg         [15:0]              r_second_keep_cnt               ; 
    reg                             ro_pluse                        ; 
    reg                             ro_pluse_last                   ;
    wire                            w_pluse_valid_pos               ; 

    assign w_pluse_valid_pos    =   i_pluse_valid & !ri_pluse_valid ; 

    assign o_pluse              =   ro_pluse                        ; 
    assign o_pluse_last         =   ro_pluse_last                   ;
    
    localparam  COUNTER_CNT     =   (SIM_MODE == "TRUE") ?         300    : CLOCK_PERIOD / 1000  ;     
    localparam  CARRY_NUM       =   (SIM_MODE == "TRUE") ?         2     : 1000                 ; 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            ri_pluse_valid <= 'd0;
        else         
            ri_pluse_valid <= i_pluse_valid;
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_flow_run <= 'd0;
        else if(w_pluse_valid_pos)
            r_flow_run <= 'd1;
        else 
            r_flow_run <= r_flow_run;
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_msec <= 'd0;
        else if(r_cnt_msec_reset)
            r_cnt_msec <= 'd0;
        else if(r_flow_run)
            r_cnt_msec <= r_cnt_msec + 'd1;
        else 
            r_cnt_msec <= r_cnt_msec;
    end

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_msec_reset <= 'd0;
        else if(r_cnt_msec == COUNTER_CNT - 'd2)
            r_cnt_msec_reset <= 'd1;
        else 
            r_cnt_msec_reset <= 'd0;
    end 


    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_second <= 'd0;
        else if(r_cnt_second_reset)
            r_cnt_second <= 'd0;
        else if(r_cnt_msec_reset)
            r_cnt_second <= r_cnt_second + 'd1;
        else 
            r_cnt_second <= r_cnt_second;
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_second_reset <= 'd0;
        else if(r_cnt_second == CARRY_NUM -'d2 && r_cnt_msec_reset)
            r_cnt_second_reset <= 'd1;
        else 
            r_cnt_second_reset <= 'd0;
    end 

    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            r_cnt_second_reset_1d <= 'd0;
        else 
            r_cnt_second_reset_1d <= r_cnt_second_reset;
    end 




    always @(posedge i_pluse_clk) begin
        if(i_pluse_rst)
            ro_pluse <= 'd0;
        else if(r_cnt_second_reset)
            ro_pluse <= 'd1;
        else 
            ro_pluse <= 'd0;
    end 

endmodule
