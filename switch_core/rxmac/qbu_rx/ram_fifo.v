`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 16:32:21
// Design Name: 
// Module Name: P_detection
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

module ram_fifo #(
    parameter   DWIDTH          = 'd8                                   ,
                P_SOURCE_MAC    = {8'h00,8'h00,8'h00,8'hff,8'hff,8'hff} 
)(
    input       wire                                        i_clk                       ,
    input       wire                                        i_rst                       ,

    // info fifo output port       
    input          wire    [47:0]                           i_target_mac                , 
    input          wire                                     i_target_mac_valid          ,
    input          wire    [47:0]                           i_source_mac                ,
    input          wire                                     i_source_mac_valid          ,
    input          wire    [15:0]                           i_post_type                 ,
    input          wire                                     i_post_type_valid           ,
    input          wire    [7:0]                            i_SMD_type                  ,
    input          wire                                     i_SMD_type_vld              ,
    input          wire    [7:0]                            i_frag_cnt                  ,
    input          wire                                     i_frag_cnt_vld              ,
    input          wire    [1:0]                            i_crc_vld                   , // CRC 检测 0bit 是 CRC 有效位，1bit 是 mCRC 有效位
    input          wire                                     i_crc_err                   ,
    // data port               
    input          wire    [7:0]                            i_post_data                 ,
    input          wire                                     i_post_last                 ,
    input          wire    [15:0]                           i_post_data_len             ,
    input          wire                                     i_post_data_len_vld         ,
    input          wire                                     i_post_data_vld             ,
    //Data_diver
    output         wire    [DWIDTH - 1:0]                   o_Data_diver_axis_data      ,//数据信号      1  
    output         reg     [15:0]                           o_Data_diver_axis_user      ,//数据信息(i_info_vld,i_smd_type,i_frag_cnt,i_crc_vld,3'b0)      
    output         wire    [(DWIDTH/8)-1:0]                 o_Data_diver_axis_keep      ,//数据掩码       
    output         wire                                     o_Data_diver_axis_last      ,//数据截至信号       
    output         wire                                     o_Data_diver_axis_valid     ,//数据有效信号
    output         wire    [11:0]                           o_Data_len                  ,//数据有效信号       
    input          wire                                     i_Data_diver_axis_ready      //准备信号   
            
);


  /*---------------------------------------- clog2计算函数 ---------------------------------------------*/
  function integer clog2;
    input integer value;
    integer temp;
    begin
      temp = value - 1;
      for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
        temp = temp >> 1;
    end
  endfunction

/***************parameter*************/

parameter           S0_SMD        =        8'he6;
parameter           S1_SMD        =        8'h4c;
parameter           S2_SMD        =        8'h7f;
parameter           S3_SMD        =        8'hb3;

parameter           C0_SMD        =        8'h61;
parameter           C1_SMD        =        8'h52;
parameter           C2_SMD        =        8'h9E;
parameter           C3_SMD        =        8'h2A;


//状态机参数 
localparam           IDLE               =       3'b001;
localparam           REC                =       3'b010;
localparam           END                =       3'b100;


//ram定义参数
localparam           RAM_DEPTH          = 'd2048;//4096
localparam           ADDR_WIDTH         = clog2(RAM_DEPTH);
localparam           RAM_PERFORMANCE    = "LOW_LATENCY";
localparam           INIT_FILE          = ""  ; 


//fifo参数
localparam           DATAWIDTH = 13+ADDR_WIDTH;//写位宽
localparam           DEPT_W = 'd16;//写深度
localparam           AL_FUL =  DEPT_W - 10;//满信号
localparam           AL_EMP =  10;  //空信号    
localparam           READ_MODE = "fwft";
localparam           FIFO_READ_LATENCY = 'd0 ;  


/***************port******************/
/*             
ila_2 inst_ila_2 (
    .i_clk(i_clk), // input wire i_clk


    .probe0(i_post_data_vld ), // input wire [0:0]  probe0  
    .probe1(i_post_data), // input wire [7:0]  probe1 
    .probe2(o_Data_diver_axis_valid), // input wire [0:0]  probe2 
    .probe3(o_Data_diver_axis_data) // input wire [7:0]  probe3
);
*/
/***************mechine***************/

/***************reg*******************/


//输入信号 打拍       
reg      [7:0]                           r_post_data                 ;
reg                                      r_post_last                 ;
reg      [15:0]                          r_post_data_len             ;
reg                                      r_post_data_len_vld         ;
reg                                      r_post_data_vld             ;

reg                                      rr_post_data_vld            ;


reg    [7:0]                             r_SMD_type                  ;
reg    [1:0]                             r_frag_cnt                  ;
reg    [7:0]                             ri_frag_cnt                 ;
reg    [1:0]                             r_crc_vld                   ;
reg    [47:0]                            r_target_mac                ;


reg                                      r_Data_diver_axis_last      ;
reg     [ADDR_WIDTH-1:0]                 read_ram_add_begin_last     ;

//ram
reg     [ADDR_WIDTH-1:0]                 write_ram_addr              ;//12位
reg     [ADDR_WIDTH-1:0]                 read_ram_addr               ; //12位
wire    [DWIDTH - 1:0]                   write_ram_data              ;
wire    [DWIDTH - 1:0]                   read_ram_data               ;
reg                                      write_ram_en                ;
reg                                      read_ram_en                 ;

reg     [ADDR_WIDTH-1:0]                 addr_begin                  ;
reg     [ADDR_WIDTH-1:0]                 addr_end                    ;
reg     [ADDR_WIDTH-1:0]                 r_read_addr_end             ;//寄存fifo读出的地址

reg                                      read_ram_en_r               ;
reg                                      read_fifo_en_r              ;

//fifo
wire  [13+ADDR_WIDTH-1:0]                write_fifo_data             ;//(i_info_vld,i_smd_type,i_frag_cnt,i_crc_vld,addr_end)
reg                                      write_fifo_en               ;
wire  [13+ADDR_WIDTH-1:0]                read_fifo_data              ;
reg                                      read_fifo_en                ;
wire                                     empty                       ;

/***************component*************/
ram_simple2port #(
    .RAM_WIDTH        (DWIDTH         ),  
    .RAM_DEPTH        (RAM_DEPTH      ),  
    .RAM_PERFORMANCE  (RAM_PERFORMANCE),  
    .INIT_FILE        (INIT_FILE      )   
) inst_data (
    .addra            (write_ram_addr ),  
    .addrb            (read_ram_addr  ),  
    .dina             (write_ram_data ),  
    .clka             (i_clk          ),  
    .clkb             (i_clk          ),  
    .wea              (write_ram_en   ),  
    .enb              (read_ram_en    ),  
    .rstb             (i_rst          ),  
    .regceb           (1'b1           ),  
    .doutb            (read_ram_data  )  // RAM output data
);

// async_fifo_fwft #(
//     .C_WIDTH          (DATAWIDTH      ),
//     .C_DEPTH          (DEPT_W         )
// ) u_async_fifo_fwft (
//     .RD_CLK           (i_clk          ),
//     .RD_RST           (i_rst          ),
//     .WR_CLK           (i_clk          ),
//     .WR_RST           (i_rst          ),
//     .WR_DATA          (write_fifo_data),
//     .WR_EN            (write_fifo_en  ),
//     .RD_DATA          (read_fifo_data ),
//     .RD_EN            (read_fifo_en   ),
//     .WR_FULL          (               ),
//     .RD_EMPTY         (empty          )
// );
sync_fifo #(
    .DEPTH                  (DEPT_W                ),
    .WIDTH                  (DATAWIDTH             ),
    .ALMOST_FULL_THRESHOLD  (0                     ),
    .ALMOST_EMPTY_THRESHOLD (0                     ),
    .FLOP_DATA_OUT          (1                     ) // 1为fwft，0为standard
) inst_sync_fifo (
    .i_clk                  (i_clk                 ),
    .i_rst                  (i_rst                 ),
    .i_wr_en                (write_fifo_en         ),
    .i_din                  (write_fifo_data       ),
    .o_full                 (                      ),
    .i_rd_en                (read_fifo_en          ),
    .o_dout                 (read_fifo_data        ),
    .o_empty                (empty                 ),
    .o_almost_full          (                      ),
    .o_almost_empty         (                      ),
    .o_data_cnt             (                      )
);
  
    // my_xpm_fifo_sync #(
    //         .DATAWIDTH(DATAWIDTH),
    //         .DEPT_W(DEPT_W),
    //         .AL_FUL(AL_FUL),
    //         .AL_EMP(AL_EMP),
    //         .READ_MODE(READ_MODE),
    //         .FIFO_READ_LATENCY(FIFO_READ_LATENCY)
    //     ) inst_my_xpm_fifo_sync (
    //         .wr_clk        (i_clk),
    //         .din           (write_fifo_data),
    //         .wr_en         (write_fifo_en),
    //         .dout          (read_fifo_data),
    //         .data_valid    (),
    //         .rd_en         (read_fifo_en),
    //         .rst           (i_rst),
    //         .empty         (empty),
    //         .full          (),
    //         .rd_data_count (),
    //         .wr_data_count (),
    //         .almost_empty  (),
    //         .almost_full   ()
    //     );



/***************assign****************/

//输出信号

assign o_Data_diver_axis_data    = read_ram_en_r ? read_ram_data : 0;

assign o_Data_diver_axis_keep    = read_ram_en_r; 
assign o_Data_diver_axis_last    = r_Data_diver_axis_last;
assign o_Data_diver_axis_valid   = read_ram_en_r;
assign o_Data_len                = read_fifo_en_r ? r_read_addr_end - read_ram_addr + 12'd2 : read_ram_add_begin_last;
//r_crc_vld




//write_fifo_data 写入信息FIFO的数据，当写使能有效时写入数据
assign write_fifo_data  =  write_fifo_en ? {1'b1,r_SMD_type,r_frag_cnt,r_crc_vld,write_ram_addr} : 0 ;



//组合逻辑改时序逻辑

//assign o_Data_diver_axis_user    = read_fifo_en ? {read_fifo_data[24:12],3'b0} : o_Data_diver_axis_user;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_Data_diver_axis_user<='d0; 
    end
    // else if (read_fifo_en==1'd0&&read_ram_en==1'd0&&read_ram_en_r==1'd0&&empty==1'd0) begin
    else if (read_fifo_en== 1'd1 && empty == 1'd0) begin
        o_Data_diver_axis_user<={read_fifo_data[13+ADDR_WIDTH-1:ADDR_WIDTH],3'b0}; 
    end
    else begin
        o_Data_diver_axis_user<=o_Data_diver_axis_user;  
    end
end

//assign r_crc_vld = i_post_last ? i_crc_vld : r_crc_vld;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_crc_vld<='d0;
    end
    else if (i_post_last) begin
        r_crc_vld<=i_crc_vld;
    end
    else begin
        r_crc_vld<=r_crc_vld;
    end
end


//r_read_addr_end
//assign r_read_addr_end = read_fifo_en ? read_fifo_data[11:0] : r_read_addr_end;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_read_addr_end<='d0;
    end
    else if (read_fifo_en== 1'd1 && empty == 1'd0) begin
        r_read_addr_end<=read_fifo_data[ADDR_WIDTH-1:0];
    end
    else begin
        r_read_addr_end<=r_read_addr_end;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_add_begin_last <= 'b0;
    end    
    else if (read_fifo_en_r) begin
        read_ram_add_begin_last <= r_read_addr_end - read_ram_addr + 12'd2;
    end

end
 
//r_SMD_type,r_frag_cnt,r_target_mac
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_target_mac<='b0;
    end
    else if (i_target_mac_valid) begin
        r_target_mac<=i_target_mac;
    end
    else begin
        r_target_mac<=r_target_mac;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_SMD_type<='b0;
    end
    else if (i_SMD_type_vld) begin
        r_SMD_type<=i_SMD_type;
    end
    else begin
        r_SMD_type<=r_SMD_type;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_frag_cnt<='b0;
    end
    else if(i_SMD_type_vld & (i_SMD_type  == S0_SMD || i_SMD_type  == S1_SMD || i_SMD_type  == S2_SMD || i_SMD_type  == S3_SMD)) begin
        r_frag_cnt<='b0;
    end
    else if (i_frag_cnt_vld&&i_frag_cnt==8'he6) begin
        r_frag_cnt<=2'b00;
    end
    else if (i_frag_cnt_vld&&i_frag_cnt==8'h4c) begin
        r_frag_cnt<=2'b01;
    end
    else if (i_frag_cnt_vld&&i_frag_cnt==8'h7f) begin
        r_frag_cnt<=2'b10;
    end
    else if (i_frag_cnt_vld&&i_frag_cnt==8'hb3) begin
        r_frag_cnt<=2'b11;
    end
    else begin
        r_frag_cnt<=r_frag_cnt;
    end
end






//read_ram_en 读ram使能，为了保持与read_fifo_en同步所以二者触发条件一样，但是当读到数据结尾地址时停止读。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_en<=1'b0;
    end                     //之前为read_fifo_en==0&&read_ram_en==0&&empty==0
    else if (read_ram_en == 1'd0 && empty == 1'd0 && read_ram_en_r == 1'd0) begin
        read_ram_en<=1'b1;
    end
    else if (read_ram_en_r == 1'd1 && (read_ram_addr == r_read_addr_end)  ) begin
        read_ram_en <= 1'b0;
    end
    else begin
        read_ram_en<=read_ram_en;
    end
end

//r_Data_diver_axis_last //当读到最后一个数据时一起拉高
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_Data_diver_axis_last<='b0;
    end
    else if ((read_ram_addr == r_read_addr_end) && read_ram_en_r == 1'd1) begin
        r_Data_diver_axis_last<=1'b1;
    end
    else begin
        r_Data_diver_axis_last<=1'b0;
    end
end


//read_ram_addr
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_addr<='b0;
    end
    else if (read_ram_en==1&&read_ram_addr=='d4000) begin
        read_ram_addr<='d0;
    end
    else if (read_ram_en==1) begin
        read_ram_addr<=read_ram_addr+1'b1;
    end
    else begin
        read_ram_addr<=read_ram_addr;
    end
end

// addr_end 写地址的最后一个地址，记录r_post_data_vld时的地址。数据要与r_post_data_vld对齐。
//assign addr_end = r_post_data_vld ? write_ram_addr : addr_end ;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        addr_end<='b0;
    end
    else if (i_post_data_vld) begin 
        addr_end<=write_ram_addr;
    end
    else begin
        addr_end<=addr_end;
    end
end




//read_fifo_en 读FIFO使能，当ram没有读，fifo也没有读，且FIFO有数据就读一个时钟周期(ram读数据使能与数据会有一排延时)
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_fifo_en<='b0;
    end
    else if (read_fifo_en==0&&read_ram_en==0&&read_ram_en_r==0&&empty==0) begin 
        read_fifo_en<=1'b1;
    end
    else begin
        read_fifo_en<=1'b0;
    end
end




always @(posedge i_clk) begin 
    read_fifo_en_r <= read_fifo_en; 
end

//输入数据打拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_post_data             <= 'b0;
        r_post_last             <= 'b0;
        r_post_data_len         <= 'b0;
        r_post_data_len_vld     <= 'b0;
        r_post_data_vld         <= 'b0;
        ri_frag_cnt             <= 'd0;
    end
    else  begin
        r_post_data             <= i_post_data              ;
        r_post_last             <= i_post_last              ;
        r_post_data_len         <= i_post_data_len          ;
        r_post_data_len_vld     <= i_post_data_len_vld      ;
        r_post_data_vld         <= i_post_data_vld          ;
        ri_frag_cnt             <= i_frag_cnt               ;
    end

end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rr_post_data_vld <= 'b0;
        read_ram_en_r    <= 'b0;
    end
    else  begin
        rr_post_data_vld <= r_post_data_vld;
        read_ram_en_r    <= read_ram_en;
    end

end




//write_ram_en 数据写使能，与REC状态对齐，当收到数据有效信号就开始接收。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_en <= 'b0;
    end
    else  begin
        write_ram_en <= i_post_data_vld;
    end

end


//write_ram_addr ram写地址，当写使能有效时自加，当发现刚写的数据无效时会地址回溯。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if (r_post_last&&write_fifo_en==0) begin//r_post_last==1时write_fifo_en==0，则说明数据没用则地址回溯
        write_ram_addr<=addr_begin;
    end
    else if (write_ram_en&&write_ram_addr=='d4000) begin
        write_ram_addr<='d0;
    end
    else if (write_ram_en) begin
        write_ram_addr<=write_ram_addr+1'b1;
    end
    else begin
        write_ram_addr<=write_ram_addr;
    end
end


//write_ram_data 写ram数据，与ram写有效信号对齐。
assign write_ram_data = r_post_data;


//write_fifo_en 写fifo使能，当检测到数据正确可以传输给下一层的时候写一次数据。与r_post_data对齐
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_fifo_en<='b0;
    end
    // else if (i_post_last && r_target_mac == P_SOURCE_MAC && i_crc_err==0) begin
    else if (i_post_last && i_crc_err==0) begin
        write_fifo_en<=1'b1;
    end
    else begin
        write_fifo_en<='b0;
    end
end


//addr_begin 回溯地址，记录第一个r_post_data的写地址。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        addr_begin<=12'b0;
    end
    else if (r_post_data_vld ==1&&rr_post_data_vld==0) begin
        addr_begin<=write_ram_addr;
    end
    else begin
        addr_begin<=addr_begin;
    end
end




/*************************** 基础模板 *************************************/   
/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        
    end
    else if () begin
        
    end
    else begin
        
    end
end
*/

// //161bit
// wire    [160:0]     probe0;

// assign probe0 =  {

// i_target_mac       ,
// i_target_mac_valid ,
// i_SMD_type         ,
// i_SMD_type_vld     ,
// i_frag_cnt         ,
// i_frag_cnt_vld     ,
// i_crc_vld          ,
// i_crc_err          ,
// i_post_data        ,
// i_post_last        ,
// i_post_data_len    ,
// i_post_data_len_vld,
// i_post_data_vld  ,

// o_Data_diver_axis_data  ,
// o_Data_diver_axis_user  ,
// o_Data_diver_axis_keep  ,
// o_Data_diver_axis_last  ,
// o_Data_diver_axis_valid ,
// i_Data_diver_axis_ready ,

// addr_end,
// read_ram_addr,
// write_ram_addr 
// };


// ila_1_ram inst_ila_1 (
//     .i_clk(i_clk), // input wire i_clk
//     .probe0(probe0)
// );

endmodule
