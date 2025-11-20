`timescale 1ns / 1ps

module FAST_RAM #(
    parameter       DWIDTH     =   'd8
)(
    input         wire                                         i_clk                ,
    input         wire                                         i_rst                ,
    //fram
    input        wire    [DWIDTH - 1:0]                        i_fram_rx_axis_data  ,//数据信号  
    input        wire    [15:0]                                i_fram_rx_axis_user  ,//数据信息
    input        wire    [(DWIDTH/8)-1:0]                      i_fram_rx_axis_keep  ,//数据掩码   
    input        wire                                          i_fram_rx_axis_last  ,//数据截至信
    input        wire                                          i_fram_rx_axis_valid ,//数据有效信
    output       wire                                          o_fram_rx_axis_ready , //准备信号 
    input        wire                                          i_data_start         , //数据起点
    input        wire                                          i_data_end           , //数据截至点
    input        wire                                          i_data_complete      ,  //数据完整标志1完整，0不完整；r_data_end为高时有效。

    //输出到下一层
    input        wire                                          i_emac_no_empty      ,
    output       wire    [DWIDTH - 1:0]                        o_rx_axis_data       ,//数据信号  
    output       wire    [15:0]                                o_rx_axis_user       ,//数据信息
    output       wire    [(DWIDTH/8)-1:0]                      o_rx_axis_keep       ,//数据掩码   
    output       wire                                          o_rx_axis_last       ,//数据截至信
    output       wire                                          o_rx_axis_valid      ,//数据有效信
    input        wire                                          i_rx_axis_ready       //准备信号                                            
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


//ram内部参数
localparam           RAM_DEPTH       = 'd2048;//4096
localparam           ADDR_WIDTH         = clog2(RAM_DEPTH);
localparam           RAM_PERFORMANCE = "LOW_LATENCY";
localparam           INIT_FILE = ""  ;   

//fifo参数
localparam           DATAWIDTH = ADDR_WIDTH*3;//写位宽
localparam           DEPT_W = 'd16;//写深度
localparam           AL_FUL =  DEPT_W - 10;//满信号
localparam           AL_EMP =  10;  //空信号    
localparam           READ_MODE = "fwft";
localparam           FIFO_READ_LATENCY = 'd0 ;           

/***************port******************/             

/***************mechine***************/

/***************reg*******************/

//
reg         [DWIDTH - 1:0]             r_fram_rx_axis_data      ;
reg         [15:0]                     r_fram_rx_axis_user      ;
reg         [(DWIDTH/8)-1:0]           r_fram_rx_axis_keep      ;
reg                                    r_fram_rx_axis_last      ;
reg                                    r_fram_rx_axis_valid     ;
reg                                    r_data_start             ;
reg                                    r_data_end               ;
reg                                    r_data_complete          ;

reg         [DWIDTH - 1:0]             rr_fram_rx_axis_data     ;
reg         [15:0]                     rr_fram_rx_axis_user     ;
reg         [(DWIDTH/8)-1:0]           rr_fram_rx_axis_keep     ;
reg                                    rr_fram_rx_axis_last     ;
reg                                    rr_fram_rx_axis_valid    ;
reg                                    rr_data_start            ;
reg                                    rr_data_end              ;
reg                                    rr_data_complete         ;

reg         [15:0]                     ro_rx_axis_user          ;


//ram
reg         [ADDR_WIDTH-1:0]            write_ram_addr          ;//13位
reg         [ADDR_WIDTH-1:0]            read_ram_addr           ;//13位
wire        [DWIDTH - 1:0]              write_ram_data          ;
wire        [DWIDTH - 1:0]              read_ram_data           ;
reg                                     write_ram_en            ;
reg                                     read_ram_en             ;
reg                                     r_read_ram_en           ;
    
wire        [(DWIDTH/8)-1:0]            write_ram_keep,read_ram_keep;   
    
reg         [ADDR_WIDTH-1:0]            read_ram_add_begin      ;//13位
reg         [ADDR_WIDTH-1:0]            read_ram_add_end        ;//13位      
reg                                     ro_rx_axis_valid        ;

reg         [ADDR_WIDTH-1:0]            read_ram_add_begin_last ;
//out
reg                                     r_rx_last_valid         ;
reg                                     ri_rx_axis_ready        ;
/***************wire******************/


wire   [ADDR_WIDTH*2-1:0]               addr_begin_to_end        ;//起点与终点数据位置

//fifo
wire  [ADDR_WIDTH*3-1:0]                write_fifo_data         ;
reg                                     write_fifo_en           ;
wire  [ADDR_WIDTH*3-1:0]                read_fifo_data          ;
reg                                     read_fifo_en            ;
wire                                    empty                   ;

    
/***************component*************/
    ram_simple2port #(
            .RAM_WIDTH(DWIDTH),              // Specify RAM data width
            .RAM_DEPTH(RAM_DEPTH),              // Specify RAM depth (number of entries)
            .RAM_PERFORMANCE(RAM_PERFORMANCE),  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"             
            .INIT_FILE(INIT_FILE)               // Specify name/location of RAM initialization file if using one (leave blank if not)
        ) inst_data (
            .addra  (write_ram_addr),    // Write address bus, width determined from RAM_DEPTH
            .addrb  (read_ram_addr),    // Read address bus, width determined from RAM_DEPTH
            .dina   (write_ram_data),     // RAM input data
            .clka   (i_clk),     // Write clock
            .clkb   (i_clk),     // Read clock
            .wea    (write_ram_en),      // Write enable
            .enb    (read_ram_en),      // Read Enable, for additional power savings, disable when not in use
            .rstb   (i_rst),     // Output reset (does not affect memory contents)
            .regceb (1'b1),   // Output register enable
            .doutb  (read_ram_data)     // RAM output data
        );

    ram_simple2port #(
            .RAM_WIDTH(DWIDTH/8),              // Specify RAM data width
            .RAM_DEPTH(RAM_DEPTH),              // Specify RAM depth (number of entries)
            .RAM_PERFORMANCE(RAM_PERFORMANCE),  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"             
            .INIT_FILE(INIT_FILE)               // Specify name/location of RAM initialization file if using one (leave blank if not)
        ) inst_keep (
            .addra  (write_ram_addr),    // Write address bus, width determined from RAM_DEPTH
            .addrb  (read_ram_addr),    // Read address bus, width determined from RAM_DEPTH
            .dina   (write_ram_keep),     // RAM input data
            .clka   (i_clk),     // Write clock
            .clkb   (i_clk),     // Read clock
            .wea    (write_ram_en),      // Write enable
            .enb    (read_ram_en),      // Read Enable, for additional power savings, disable when not in use
            .rstb   (i_rst),     // Output reset (does not affect memory contents)
            .regceb (1'b1),   // Output register enable
            .doutb  (read_ram_keep)     // RAM output data
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

//ram
assign write_ram_data = r_fram_rx_axis_data ;
assign write_ram_keep = r_fram_rx_axis_keep;
//fifo
//assign write_fifo_en   = r_data_end;
//在i_data_complete有效的时候给其赋值为起始与结束的地址
assign write_fifo_data = {write_ram_addr,read_ram_add_begin,read_ram_add_end}; 

assign o_fram_rx_axis_ready = 1;


//out

assign o_rx_axis_data   = read_ram_data;
assign o_rx_axis_user   = ro_rx_axis_user  ;//待定
assign o_rx_axis_keep   = r_read_ram_en ? read_ram_keep : 'b0;
assign o_rx_axis_last   = r_rx_last_valid;
assign o_rx_axis_valid  = r_read_ram_en  ;

/***************always****************/

                        /*********************
                        输入信号打拍
                        *********************/

//对输入信号打一拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_fram_rx_axis_data <=      'b0 ;
        r_fram_rx_axis_user <=      'b0 ;
        r_fram_rx_axis_keep <=      'b0 ;
        r_fram_rx_axis_last <=      'b0 ;
        r_fram_rx_axis_valid<=      'b0 ;
        r_data_start        <=      'b0 ;
        r_data_end          <=      'b0 ;
        r_data_complete     <=      'b0 ;
        ri_rx_axis_ready    <=      'd0 ;
    end
    else begin
        r_fram_rx_axis_data <=      i_fram_rx_axis_data  ;
        r_fram_rx_axis_user <=      i_fram_rx_axis_user  ;
        r_fram_rx_axis_keep <=      i_fram_rx_axis_keep  ;
        r_fram_rx_axis_last <=      i_fram_rx_axis_last  ;
        r_fram_rx_axis_valid<=      i_fram_rx_axis_valid ;
        r_data_start        <=      i_data_start    ;
        r_data_end          <=      i_data_end      ;
        r_data_complete     <=      i_data_complete ;
        ri_rx_axis_ready    <=      i_rx_axis_ready ;
    end
end
//对输入信号打二拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rr_fram_rx_axis_data <=      'b0 ;
        rr_fram_rx_axis_user <=      'b0 ;
        rr_fram_rx_axis_keep <=      'b0 ;
        rr_fram_rx_axis_last <=      'b0 ;
        rr_fram_rx_axis_valid<=      'b0 ;
        rr_data_start        <=      'b0 ;
        rr_data_end          <=      'b0 ;
        rr_data_complete     <=      'b0 ;
    end
    else begin
        rr_fram_rx_axis_data <=      r_fram_rx_axis_data  ;
        rr_fram_rx_axis_user <=      r_fram_rx_axis_user  ;
        rr_fram_rx_axis_keep <=      r_fram_rx_axis_keep  ;
        rr_fram_rx_axis_last <=      r_fram_rx_axis_last  ;
        rr_fram_rx_axis_valid<=      r_fram_rx_axis_valid ;
        rr_data_start        <=      r_data_start    ;
        rr_data_end          <=      r_data_end      ;
        rr_data_complete     <=      r_data_complete ;
    end
end


                        /*********************
                        ram端口
                        *********************/
//write_ram_en与r_fram_rx_axis_valid对齐，保证了数据读取与读取状态的同步
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_en <= 1'b0;
    end
    else begin
        write_ram_en <= i_fram_rx_axis_valid;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_rx_axis_user <= 16'b0;
    end
    else if(r_read_ram_en & !read_ram_en)begin
        ro_rx_axis_user <= 16'b0;
    end
    else if (read_fifo_en) begin
        // 处理地址回绕的情况：如果结束地址小于起始地址，说明发生了回绕
        // 回绕时的长度 = (RAM_DEPTH - 起始地址) + 结束地址
        // 正常时的长度 = 结束地址 - 起始地址
        if (read_fifo_data[ADDR_WIDTH-1:0] < read_fifo_data[ADDR_WIDTH*2-1:ADDR_WIDTH]) begin
            // 地址回绕情况
            ro_rx_axis_user <= (RAM_DEPTH - read_fifo_data[ADDR_WIDTH*2-1:ADDR_WIDTH]) + read_fifo_data[ADDR_WIDTH-1:0] + 1'd1;
        end
        else begin
            // 正常情况
            ro_rx_axis_user <= read_fifo_data[ADDR_WIDTH-1:0] - read_fifo_data[ADDR_WIDTH*2-1:ADDR_WIDTH]  + 1'd1;
        end
    end
    
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_add_begin_last <= 'b0;
    end
    else if (read_fifo_en) begin
        read_ram_add_begin_last <= read_fifo_data[ADDR_WIDTH*3-1:ADDR_WIDTH*2];
    end
end
//write_ram_add接收数据时自加，在数据无效回溯地址
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if (i_data_end&&i_data_complete==0) begin
        write_ram_addr <=read_ram_add_begin;
    end
    else if (write_ram_en) begin
        write_ram_addr <= write_ram_addr+1'b1;
    end
    else begin
        write_ram_addr <= write_ram_addr;
    end
end

//read_ram_add_begin与r_data_start同步，在一组接收数据开始写入ram时记录数据存的地址
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_add_begin <= 'b0;
    end
    else if (i_data_start == 1) begin
        read_ram_add_begin <= write_ram_addr;
    end
    else begin
        read_ram_add_begin <= read_ram_add_begin;
    end
end
//read_ram_add_end 与r_data_end同步，一组接收数据结束写入ram时记录数据存的地址
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_add_end <= 1'b0;
    end
    else if (i_data_end == 1'b1) begin
        read_ram_add_end <= write_ram_addr;
    end
    else begin
        read_ram_add_end <= read_ram_add_end;
    end
end



//write_fifo_en在i_data_complete有效的时候存入数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_fifo_en <= 1'b0;
    end
    else if (i_data_end&&i_data_complete) begin
        write_fifo_en <= 1'b1;
    end
    else begin
        write_fifo_en <= 1'b0;
    end
end




//当fifo非空且read_ram_en不为1就读下一组数据（上一组数据读完了就开始读下一组）
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_fifo_en <= 1'b0;
    end //防止emacready和pamcready同时拉高
    else if (!empty & !read_ram_en & !read_fifo_en & i_rx_axis_ready & ri_rx_axis_ready & !i_emac_no_empty) begin
        read_fifo_en <= 1'b1;
    end
    else begin
        read_fifo_en <= 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_rx_axis_valid <= 1'b0;
    end
    else if(o_rx_axis_last & ro_rx_axis_valid)
        ro_rx_axis_valid <= 1'b0;
    else if (!empty & !read_ram_en & !ro_rx_axis_valid) begin
        ro_rx_axis_valid <= 1'b1;
    end
end


//用一个寄存器保存从fifo读出来的起始地址数据
assign addr_begin_to_end = read_fifo_en ? read_fifo_data[ADDR_WIDTH*2-1:0] : addr_begin_to_end;


//read_ram_en当fifo有数据输出的时候就开始读，一直读到尾地址停下
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_en <= 1'b0;
    end
    else if (read_fifo_en) begin
        read_ram_en <= 1'b1;
    end
    else if(read_ram_addr==addr_begin_to_end[ADDR_WIDTH-1:0]) begin
        read_ram_en <= 1'b0;
    end
    else begin
        read_ram_en <= read_ram_en;
    end
end

//r_read_ram_en
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_read_ram_en <= 1'b0;
    end
    else begin
        r_read_ram_en <= read_ram_en;
    end
end


//当读到倒数最后一个数据时拉高r_rx_axis_valid
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rx_last_valid <= 1'b0;
    end
    else if (read_ram_addr == addr_begin_to_end[ADDR_WIDTH-1:0]) begin
        r_rx_last_valid <= 1'b1;
    end
    else begin
        r_rx_last_valid <= 1'b0;
    end
end


//read_fifo_data在读使能有效的时候自加；因为会有地址回溯，所以每一个地址的数据都是有效的，读使能有效就可以直接读不用考虑起点地址。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_addr <= 1'b0;
    end
    else if (read_ram_en) begin
        read_ram_addr <= read_ram_addr+1'b1;
    end
    else begin
        read_ram_addr <= read_ram_addr;
    end
end


// 状态机第四段：同步always输出，可以有多个输出（例如计数器清零、数据有效位使能）

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        out1 <= 1'b0;
    end
    else if () begin
        out1 <= 1'b1;
    end
    else begin
        out1 <= 1'b0;
    end
end
*/




// //57bit
// wire [56:0]    probe0;

// assign probe0 = {
// i_fram_rx_axis_data  ,
// i_fram_rx_axis_user  ,
// i_fram_rx_axis_keep  ,
// i_fram_rx_axis_last  ,
// i_fram_rx_axis_valid ,
// i_data_start         ,
// i_data_end           ,
// i_data_complete      ,

// o_rx_axis_data       ,
// o_rx_axis_user       ,
// o_rx_axis_keep       ,
// o_rx_axis_last       ,
// o_rx_axis_valid      

// };

// ila_fast_ram inst_ila_4 (
//     .i_clk(i_clk), // input wire i_clk
//     .probe0(probe0)
// );


endmodule