`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/29 14:29:06
// Design Name: 
// Module Name: sim_arb
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


module sim_arb();
    reg rst , clk ;
    initial begin 
        rst = 1 ;
        #100;
        rst <= 0;
    end 
    initial begin 
        clk = 0;
        forever 
        clk = #5 ~clk;
    end 
reg [9:0]  r_port_req       ;
reg [9:0]  r_port_req_qdu   ;
wire   i_port0_req            ;
wire   i_data0_qbu_flag       ;
wire   i_port1_req            ;
wire   i_data1_qbu_flag       ;
wire   i_port2_req            ;
wire   i_data2_qbu_flag       ;
wire   i_port3_req            ;
wire   i_data3_qbu_flag       ;
wire   i_port4_req            ;
wire   i_data4_qbu_flag       ;
wire   i_port5_req            ;
wire   i_data5_qbu_flag       ;
wire   i_port6_req            ;
wire   i_data6_qbu_flag       ;
wire   i_port7_req            ;
wire   i_data7_qbu_flag       ;
wire   i_port8_req            ;
wire   i_port9_req            ;
reg    i_data_ready           ;

assign i_port0_req = r_port_req[0];
assign i_port1_req = r_port_req[1];
assign i_port2_req = r_port_req[2];
assign i_port3_req = r_port_req[3];
assign i_port4_req = r_port_req[4];
assign i_port5_req = r_port_req[5];
assign i_port6_req = r_port_req[6];
assign i_port7_req = r_port_req[7];
assign i_port8_req = r_port_req[8];
assign i_port9_req = r_port_req[9];
assign i_data0_qbu_flag = r_port_req_qdu[0];
assign i_data1_qbu_flag = r_port_req_qdu[1];
assign i_data2_qbu_flag = r_port_req_qdu[2];
assign i_data3_qbu_flag = r_port_req_qdu[3];
assign i_data4_qbu_flag = r_port_req_qdu[4];
assign i_data5_qbu_flag = r_port_req_qdu[5];
assign i_data6_qbu_flag = r_port_req_qdu[6];

initial begin 
    r_port_req       <= 9'b00_0100_1011;
    r_port_req_qdu   <= 7'b000_0000;
    i_data_ready     <= 1'd0;
    #2000;
    r_port_req       <= 9'b00_0100_1011;
    r_port_req_qdu   <= 7'b000_0000;
    i_data_ready     <= 1'd1;
    #2000;
    r_port_req       <= 9'b0_0100_0100;
    r_port_req_qdu   <= 7'b000_0000;
    i_data_ready     <= 1'd0;
    #2000;
    r_port_req       <= 9'b0_0100_0100;
    r_port_req_qdu   <= 7'b000_0000;
    i_data_ready     <= 1'd1;
    //
    #2000;
    r_port_req       <= 9'b0_0000_0000;
    r_port_req_qdu   <= 7'b010_1010;
    i_data_ready     <= 1'd0;
    #2000;
    r_port_req       <= 9'b0_0000_0000;
    r_port_req_qdu   <= 7'b010_1010;
    i_data_ready     <= 1'd1;
    #2000;
    r_port_req       <= 9'b0_0000_0000;
    r_port_req_qdu   <= 7'b000_1010;
    i_data_ready     <= 1'd0;
    #2000;
    r_port_req       <= 9'b0_0000_0000;
    r_port_req_qdu   <= 7'b000_1010;
    i_data_ready     <= 1'd1;
end 

req_arbit req_arbit_u0(
    .i_clk               (clk),
    .i_rst               (rst),
    
    .i_port0_req         (i_port0_req       ), 
    .i_data0_qbu_flag    (i_data0_qbu_flag  ), // 关键帧标�?
    
    .i_port1_req         (i_port1_req       ),
    .i_data1_qbu_flag    (i_data1_qbu_flag  ),

    .i_port2_req         (i_port2_req       ),
    .i_data2_qbu_flag    (i_data2_qbu_flag  ), 

    .i_port3_req         (i_port3_req       ),
    .i_data3_qbu_flag    (i_data3_qbu_flag  ),

    .i_port4_req         (i_port4_req       ),
    .i_data4_qbu_flag    (i_data4_qbu_flag  ),

    .i_port5_req         (i_port5_req       ),
    .i_data5_qbu_flag    (i_data5_qbu_flag  ),

    .i_port6_req         (i_port6_req       ),
    .i_data6_qbu_flag    (i_data6_qbu_flag  ),

    .i_port7_req         (i_port7_req       ),
    .i_data7_qbu_flag    (i_data7_qbu_flag  ),

    .i_port8_req         (i_port8_req       ),

    .i_port9_req         (i_port9_req       ),
    
    .i_data_ready        (i_data_ready      ), // 标识 FIFO 是否忙；1:空闲�?0：忙
    
    .o_port_ack          (), // 仲裁结果 
    .o_port_vld          ()  // 仲裁有效�?
    
);

endmodule
