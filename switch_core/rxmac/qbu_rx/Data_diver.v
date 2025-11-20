`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/26 15:50:03
// Design Name: 
// Module Name: Data_diver
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

module Data_diver #(
    parameter       DWIDTH     =   'd8
)(
        input          wire                                    i_clk                 ,
        input          wire                                    i_rst                 ,
		input		   wire									   i_qbu_frm			 ,
        // SGRAM
        input         wire    [DWIDTH - 1:0]                   i_Sgram_rx_axis_data  ,//数据信号       
        input         wire    [15:0]                           i_Sgram_rx_axis_user  ,//数据信息(i_info_vld,i_smd_type,i_frag_cnt,i_crc_vld,i_qbu_frm,2'b0)      
        input         wire    [(DWIDTH/8)-1:0]                 i_Sgram_rx_axis_keep  ,//数据掩码       
        input         wire                                     i_Sgram_rx_axis_last  ,//数据截至信号       
        input         wire                                     i_Sgram_rx_axis_valid ,//数据有效信号 
        input         wire    [11:0]                           i_data_len            ,     
        output        wire                                     o_Sgram_rx_axis_ready ,//准备信号   
        // EMAC AXIS     
        output         wire    [DWIDTH - 1:0]                  o_Emac_rx_axis_data   ,//数据信号       
        output         wire    [15:0]                          o_Emac_rx_axis_user   ,//数据信息      
        output         wire    [(DWIDTH/8)-1:0]                o_Emac_rx_axis_keep   ,//数据掩码       
        output         wire                                    o_Emac_rx_axis_last   ,//数据截至信号       
        output         wire                                    o_Emac_rx_axis_valid  ,//数据有效信号       
        input          wire                                    i_Emac_rx_axis_ready  ,//准备信号      
        // PMAC AXIS   
        output         wire    [DWIDTH - 1:0]                  o_Pmac_rx_axis_data   ,//数据信号  
        output         wire    [15:0]                          o_Pmac_rx_axis_user   ,//数据信息  
        output         wire    [(DWIDTH/8)-1:0]                o_Pmac_rx_axis_keep   ,//数据掩码  
        output         wire                                    o_Pmac_rx_axis_last   ,//数据截至信号
        output         wire                                    o_Pmac_rx_axis_valid  ,//数据有效信号
        input          wire                                    i_Pmac_rx_axis_ready  , //准备信号   
        // R AXIS        
        output         wire    [DWIDTH - 1:0]                  o_R_rx_axis_data      ,//数据信号  
        output         wire    [15:0]                          o_R_rx_axis_user      ,//数据信息  
        output         wire    [(DWIDTH/8)-1:0]                o_R_rx_axis_keep      ,//数据掩码  
        output         wire                                    o_R_rx_axis_last      ,//数据截至信号
        output         wire                                    o_R_rx_axis_valid     ,//数据有效信号
        input          wire                                    i_R_rx_axis_ready     , //准备信号 
        // V AX      
        output         wire    [DWIDTH - 1:0]                  o_V_rx_axis_data      ,//数据信号  
        output         wire    [15:0]                          o_V_rx_axis_user      ,//数据信息  
        output         wire    [(DWIDTH/8)-1:0]                o_V_rx_axis_keep      ,//数据掩码  
        output         wire                                    o_V_rx_axis_last      ,//数据截至信号
        output         wire                                    o_V_rx_axis_valid     ,//数据有效信号
        input          wire                                    i_V_rx_axis_ready      //准备信号 


);

/***************function**************/

/***************parameter*************/
localparam           SMD_V         =        8'H07;
localparam           SMD_R         =        8'H19;
localparam           SMD_E         =        8'HD5;

localparam           S0_SMD        =        8'hE6;
localparam           S1_SMD        =        8'h4C;
localparam           S2_SMD        =        8'h7F;
localparam           S3_SMD        =        8'hB3;
localparam           C0_SMD        =        8'h61;
localparam           C1_SMD        =        8'h52;
localparam           C2_SMD        =        8'h9E;
localparam           C3_SMD        =        8'h2A;

localparam           MCRC          =        2'b10;
localparam           CRC           =        2'b01;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/

/***************wire******************/
wire           [7:0]                          ri_smd_type        ;
wire           [1:0]                          ri_frag_cnt        ;
wire           [1:0]                          ri_crc_vld         ;// CRC 检测 0bit 是 CRC 有效位，1bit 是 mCRC 有效位
wire                                          ri_info_vld        ;     
/***************component*************/

/***************assign****************/

//数据分析
assign ri_info_vld  =   i_Sgram_rx_axis_user[15];
assign ri_smd_type  =   i_Sgram_rx_axis_user[14:7];
assign ri_frag_cnt  =   i_Sgram_rx_axis_user[6:5];
assign ri_crc_vld   =   i_Sgram_rx_axis_user[4:3];
// SGRAM
assign o_Sgram_rx_axis_ready = i_Emac_rx_axis_ready | i_Pmac_rx_axis_ready | i_R_rx_axis_ready | i_V_rx_axis_ready;

reg [15:0] data_cnt;



// EMAC AXIS
//数据有效且数据类型满足条件且crc正确就传输数据

assign o_Emac_rx_axis_data  =  ri_info_vld &&  (ri_smd_type      ==  SMD_E) && ri_crc_vld== CRC?  i_Sgram_rx_axis_data   :   'b0;
        
assign o_Emac_rx_axis_user  =  ri_info_vld &&  (ri_smd_type      ==  SMD_E) && ri_crc_vld== CRC?  i_Sgram_rx_axis_valid ? {4'b0000,i_data_len} : 0  :   'b0;
        
assign o_Emac_rx_axis_keep  =  ri_info_vld &&  (ri_smd_type      ==  SMD_E) && ri_crc_vld== CRC?  i_Sgram_rx_axis_keep   :   'b0;
        
assign o_Emac_rx_axis_last  =  ri_info_vld &&  (ri_smd_type      ==  SMD_E) && ri_crc_vld== CRC?  i_Sgram_rx_axis_last   :   'b0;
        
assign o_Emac_rx_axis_valid =  ri_info_vld &&  (ri_smd_type      ==  SMD_E) && ri_crc_vld== CRC?  i_Sgram_rx_axis_valid  :   'b0;



// PMAC AXIS
//数据有效且数据类型满足条件且crc正确就传输数据

assign o_Pmac_rx_axis_data  =  ri_info_vld &&  (ri_smd_type     ==  S0_SMD ||ri_smd_type    ==  S1_SMD ||ri_smd_type    ==  S2_SMD ||ri_smd_type    ==  S3_SMD ||ri_smd_type    ==  C0_SMD ||ri_smd_type==  C1_SMD ||ri_smd_type==  C2_SMD || ri_smd_type==  C3_SMD) && (ri_crc_vld == CRC ||ri_crc_vld == MCRC) ?  i_Sgram_rx_axis_data   :   'b0;
                    
assign o_Pmac_rx_axis_user  =  ri_info_vld &&  (ri_smd_type     ==  S0_SMD ||ri_smd_type    ==  S1_SMD ||ri_smd_type    ==  S2_SMD ||ri_smd_type    ==  S3_SMD ||ri_smd_type    ==  C0_SMD ||ri_smd_type==  C1_SMD ||ri_smd_type==  C2_SMD || ri_smd_type==  C3_SMD) && (ri_crc_vld == CRC ||ri_crc_vld == MCRC) ?  {4'b0000,i_Sgram_rx_axis_user[15:3]}   :   'b0;
                    
assign o_Pmac_rx_axis_keep  =  ri_info_vld &&  (ri_smd_type     ==  S0_SMD ||ri_smd_type    ==  S1_SMD ||ri_smd_type    ==  S2_SMD ||ri_smd_type    ==  S3_SMD ||ri_smd_type    ==  C0_SMD ||ri_smd_type==  C1_SMD ||ri_smd_type==  C2_SMD || ri_smd_type==  C3_SMD) && (ri_crc_vld == CRC ||ri_crc_vld == MCRC) ?  i_Sgram_rx_axis_keep   :   'b0;
                    
assign o_Pmac_rx_axis_last  =  ri_info_vld &&  (ri_smd_type     ==  S0_SMD ||ri_smd_type    ==  S1_SMD ||ri_smd_type    ==  S2_SMD ||ri_smd_type    ==  S3_SMD ||ri_smd_type    ==  C0_SMD ||ri_smd_type==  C1_SMD ||ri_smd_type==  C2_SMD || ri_smd_type==  C3_SMD) && (ri_crc_vld == CRC ||ri_crc_vld == MCRC) ?  i_Sgram_rx_axis_last   :   'b0;
                    
assign o_Pmac_rx_axis_valid =  ri_info_vld &&  (ri_smd_type     ==  S0_SMD ||ri_smd_type    ==  S1_SMD ||ri_smd_type    ==  S2_SMD ||ri_smd_type    ==  S3_SMD ||ri_smd_type    ==  C0_SMD ||ri_smd_type==  C1_SMD ||ri_smd_type==  C2_SMD || ri_smd_type==  C3_SMD) && (ri_crc_vld == CRC ||ri_crc_vld == MCRC) ?  i_Sgram_rx_axis_valid  :   'b0;



// R AXIS 
//数据有效且数据类型满足条件且crc正确就传输数据

assign o_R_rx_axis_data  =  ri_info_vld &&  ri_smd_type      ==  SMD_R && ri_crc_vld== CRC?  i_Sgram_rx_axis_data   :   'b0;
    
assign o_R_rx_axis_user  =  ri_info_vld &&  ri_smd_type      ==  SMD_R && ri_crc_vld== CRC?  i_Sgram_rx_axis_valid ? i_data_len : 0  :   'b0;
    
assign o_R_rx_axis_keep  =  ri_info_vld &&  ri_smd_type      ==  SMD_R && ri_crc_vld== CRC?  i_Sgram_rx_axis_keep   :   'b0;
    
assign o_R_rx_axis_last  =  ri_info_vld &&  ri_smd_type      ==  SMD_R && ri_crc_vld== CRC?  i_Sgram_rx_axis_last   :   'b0;
    
assign o_R_rx_axis_valid =  ri_info_vld &&  ri_smd_type      ==  SMD_R && ri_crc_vld== CRC?  i_Sgram_rx_axis_valid  :   'b0;




// V AXIS 
//数据有效且数据类型满足条件且crc正确就传输数据

assign o_V_rx_axis_data  =  ri_info_vld &&  ri_smd_type      ==  SMD_V && ri_crc_vld== CRC?  i_Sgram_rx_axis_data   :   'b0;
    
assign o_V_rx_axis_user  =  ri_info_vld &&  ri_smd_type      ==  SMD_V && ri_crc_vld== CRC?  i_Sgram_rx_axis_valid ? i_data_len : 0 :   'b0;
    
assign o_V_rx_axis_keep  =  ri_info_vld &&  ri_smd_type      ==  SMD_V && ri_crc_vld== CRC?  i_Sgram_rx_axis_keep   :   'b0;
    
assign o_V_rx_axis_last  =  ri_info_vld &&  ri_smd_type      ==  SMD_V && ri_crc_vld== CRC?  i_Sgram_rx_axis_last   :   'b0;
    
assign o_V_rx_axis_valid =  ri_info_vld &&  ri_smd_type      ==  SMD_V && ri_crc_vld== CRC?  i_Sgram_rx_axis_valid  :   'b0;

/***************always****************/

// reg [15:0] data_cnt;
always@(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        data_cnt <= 0;
    end
    else if(o_V_rx_axis_last | o_R_rx_axis_last  | o_Emac_rx_axis_last ) begin
        data_cnt <= 0;
    end
    else if(o_V_rx_axis_valid | o_R_rx_axis_valid  | o_Emac_rx_axis_valid ) begin
        data_cnt <= data_cnt + 1'b1;
    end
end


// //81bit
// wire [80:0]    probe0;

// assign probe0 = {
// i_Sgram_rx_axis_data   ,  
// i_Sgram_rx_axis_user   ,  
// i_Sgram_rx_axis_keep   ,  
// i_Sgram_rx_axis_last   ,  
// i_Sgram_rx_axis_valid  ,      

// o_Emac_rx_axis_data    ,
// o_Emac_rx_axis_user    ,
// o_Emac_rx_axis_keep    ,
// o_Emac_rx_axis_last    ,
// o_Emac_rx_axis_valid   ,

// o_Pmac_rx_axis_data    ,
// o_Pmac_rx_axis_user    ,
// o_Pmac_rx_axis_keep    ,
// o_Pmac_rx_axis_last    ,
// o_Pmac_rx_axis_valid   
// };

// ila_1_data inst_ila_1 (
//     .i_clk(i_clk), // input wire i_clk
//     .probe0(probe0)
// );

endmodule
