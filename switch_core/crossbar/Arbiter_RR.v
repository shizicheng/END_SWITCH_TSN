`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/29 10:45:07
// Design Name: 
// Module Name: Arbiter_RR
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


module Arbiter_RR(
    input                           i_sys_clk               ,
    input                           i_sys_rst               ,

    input   [9 :0]                  i_arbiter_data          ,
    input                           i_arbiter_valid         ,
    
    output  [9 :0]                  o_arbiter_result        ,
    output                          o_arbiter_valid             
    );  
    reg     [19:0]                  ro_arbiter_result       ;
    reg                             ro_arbiter_valid        ;
    reg                             ro_arbiter_valid_1d     ;
    reg     [9 :0]                  r_pri                   ;
    // reg     [3 :0]                  r_pri_cnt               ;
    
    wire    [19:0]                  w_arbiter_data          ;
    wire                            w_arbiter_valid_pos     ;

    assign w_arbiter_valid_pos  =   ro_arbiter_valid == 1'b1 && ro_arbiter_valid_1d == 1'b0 ? 1'b1 : 1'b0;
    assign o_arbiter_result     =   ro_arbiter_result[9:0] | ro_arbiter_result[19:10] ;
    assign o_arbiter_valid      =   ro_arbiter_valid        ;
    

    assign w_arbiter_data       =   {i_arbiter_data,i_arbiter_data}  ;


    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_pri <= 10'b00_0000_0001;
        else 
            r_pri <= r_pri[9] == 10'd1 && w_arbiter_valid_pos == 1'b1 ? 10'b10_0000_0000 : 
                     w_arbiter_valid_pos == 1'b1 ? r_pri << 1  :  
                     r_pri;
    end 

    // always @(posedge i_sys_clk) begin
    //     if(i_sys_rst)
    //         r_pri_cnt <= 4'd0;
    //     else 
    //         r_pri_cnt <= r_pri_cnt == 4'd9 && w_arbiter_valid_pos == 1'b1 ? 4'd0 : 
    //                      w_arbiter_valid_pos == 1'b1 ? r_pri_cnt + 4'd1 : 
    //                      r_pri_cnt;
    // end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_arbiter_result <= 10'd0;
        else begin 
            ro_arbiter_result <= i_arbiter_valid == 1'b1 ? (~({w_arbiter_data - {10'd0,r_pri}})) & w_arbiter_data : 
                                 ro_arbiter_result;
        end 
    end

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_arbiter_valid <= 1'b0;
        else 
            ro_arbiter_valid <= i_arbiter_valid;
    end 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_arbiter_valid_1d <= 1'b0;
        else
            ro_arbiter_valid_1d <= ro_arbiter_valid;
    end 
endmodule   
