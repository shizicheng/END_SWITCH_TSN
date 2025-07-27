module emac_rx_ram #(
    parameter       DWIDTH     =   'd8
)(
    input        wire                                          i_clk                ,
    input        wire                                          i_rst                ,
    //emac缓存
    input        wire    [DWIDTH - 1:0]                        i_emac_rx_axis_data  ,//数据信号  
    input        wire    [15:0]                                i_emac_rx_axis_user  ,//数据信息
    input        wire    [(DWIDTH/8)-1:0]                      i_emac_rx_axis_keep  ,//数据掩码   
    input        wire                                          i_emac_rx_axis_last  ,//数据截至信
    input        wire                                          i_emac_rx_axis_valid ,//数据有效信
    output       wire                                          o_emac_rx_axis_ready , //准备信号 
    output       wire                                          o_emac_no_empty      , //传给pmac，让emac的数据先发送
    //输出到下一层
    output       wire    [DWIDTH - 1:0]                        o_emac_rx_axis_data  ,//数据信号  
    output       wire    [15:0]                                o_emac_rx_axis_user  ,//数据信息
    output       wire    [(DWIDTH/8)-1:0]                      o_emac_rx_axis_keep  ,//数据掩码   
    output       wire                                          o_emac_rx_axis_last  ,//数据截至信
    output       wire                                          o_emac_rx_axis_valid ,//数据有效信
    input        wire                                          i_emac_rx_axis_ready  //准备信号                                            
);

//ram内部参数
localparam           RAM_DEPTH       = 'd1024;//4096
localparam           RAM_PERFORMANCE = "LOW_LATENCY";
localparam           INIT_FILE = ""  ;   

//fifo参数
localparam           DATAWIDTH = 'd16;//写位宽
localparam           DEPT_W = 'd16;//写深度
localparam           AL_FUL =  DEPT_W - 10;//满信号
localparam           AL_EMP =  10;  //空信号    
localparam           READ_MODE = "fwft";
localparam           FIFO_READ_LATENCY = 'd0 ;   

reg         [DWIDTH - 1:0]             r_emac_rx_axis_data      ;
reg         [15:0]                     r_emac_rx_axis_user      ;
reg         [(DWIDTH/8)-1:0]           r_emac_rx_axis_keep      ;
reg                                    r_emac_rx_axis_last      ;
reg                                    r_emac_rx_axis_valid     ;


reg         [DWIDTH - 1:0]             rr_emac_rx_axis_data     ;
reg         [15:0]                     rr_emac_rx_axis_user     ;
reg         [(DWIDTH/8)-1:0]           rr_emac_rx_axis_keep     ;
reg                                    rr_emac_rx_axis_last     ;
reg                                    rr_emac_rx_axis_valid    ;


reg         [15:0]                     ro_emac_rx_axis_user          ;


//ram
reg         [11:0]                      write_ram_addr          ;//13位
reg         [11:0]                      read_ram_addr           ;//13位
wire        [DWIDTH - 1:0]              write_ram_data          ;
wire        [DWIDTH - 1:0]              read_ram_data           ;
reg                                     write_ram_en            ;
reg                                     read_ram_en             ;
reg                                     r_read_ram_en           ;
    
wire        [(DWIDTH/8)-1:0]            write_ram_keep,read_ram_keep;   
 
reg ro_emac_rx_axis_valid;


reg         ro_emac_rx_axis_last;

reg [15:0] r_rd_data_cnt;

wire  [15:0]   write_fifo_data;
reg            write_fifo_en;
wire  [15:0]   read_fifo_data;
reg            read_fifo_en;
wire           empty;
wire           full ;
    
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

my_xpm_fifo_sync #(
        .DATAWIDTH(DATAWIDTH),
        .DEPT_W(DEPT_W),
        .AL_FUL(AL_FUL),
        .AL_EMP(AL_EMP),
        .READ_MODE(READ_MODE),
        .FIFO_READ_LATENCY(FIFO_READ_LATENCY)
    ) inst_my_xpm_fifo_sync (
        .wr_clk        (i_clk),
        .din           (write_fifo_data),
        .wr_en         (write_fifo_en),
        .dout          (read_fifo_data),
        .data_valid    (),
        .rd_en         (read_fifo_en),
        .rst           (i_rst),
        .empty         (empty),
        .full          (full ),
        .rd_data_count (),
        .wr_data_count (),
        .almost_empty  (),
        .almost_full   ()
    );


/***************assign****************/

//ram
assign write_ram_data = r_emac_rx_axis_data ;
assign write_ram_keep = r_emac_rx_axis_keep;
//fifo
//assign write_fifo_en   = r_data_end;
//在i_data_complete有效的时候给其赋值为起始与结束的地址
assign write_fifo_data = r_emac_rx_axis_user; 

assign o_emac_rx_axis_ready = !full;
assign o_emac_no_empty  = !empty & i_emac_rx_axis_ready | ro_emac_rx_axis_valid; //当emac缓存有数据，且可以发给下一级模块时，不准pmac发送

//out

assign o_emac_rx_axis_data   = read_ram_data;
assign o_emac_rx_axis_user   = ro_emac_rx_axis_user  ;
assign o_emac_rx_axis_keep   = r_read_ram_en ? read_ram_keep : 'b0;
assign o_emac_rx_axis_last   = ro_emac_rx_axis_last;
assign o_emac_rx_axis_valid  = ro_emac_rx_axis_valid ;

/***************always****************/

                        /*********************
                        输入信号打拍
                        *********************/

//对输入信号打一拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_emac_rx_axis_data <=      'b0 ;
        r_emac_rx_axis_user <=      'b0 ;
        r_emac_rx_axis_keep <=      'b0 ;
        r_emac_rx_axis_last <=      'b0 ;
        r_emac_rx_axis_valid<=      'b0 ;
    end
    else begin
        r_emac_rx_axis_data <=      i_emac_rx_axis_data  ;
        r_emac_rx_axis_user <=      i_emac_rx_axis_user  ;
        r_emac_rx_axis_keep <=      i_emac_rx_axis_keep  ;
        r_emac_rx_axis_last <=      i_emac_rx_axis_last  ;
        r_emac_rx_axis_valid<=      i_emac_rx_axis_valid ;
    end
end

//对输入信号打二拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rr_emac_rx_axis_data <=      'b0 ;
        rr_emac_rx_axis_user <=      'b0 ;
        rr_emac_rx_axis_keep <=      'b0 ;
        rr_emac_rx_axis_last <=      'b0 ;
        rr_emac_rx_axis_valid<=      'b0 ;
    end
    else begin
        rr_emac_rx_axis_data <=      r_emac_rx_axis_data  ;
        rr_emac_rx_axis_user <=      r_emac_rx_axis_user  ;
        rr_emac_rx_axis_keep <=      r_emac_rx_axis_keep  ;
        rr_emac_rx_axis_last <=      r_emac_rx_axis_last  ;
        rr_emac_rx_axis_valid<=      r_emac_rx_axis_valid ;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_en <= 1'b0;
    end
    else begin
        write_ram_en <= i_emac_rx_axis_valid;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if (write_ram_en) begin
        write_ram_addr <= write_ram_addr + 1'b1;
    end
    else begin
        write_ram_addr <= write_ram_addr;
    end
end
 
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_fifo_en <= 1'b0;
    end
    else if (i_emac_rx_axis_valid & !r_emac_rx_axis_valid) begin
        write_fifo_en <= 1'b1;
    end
    else begin
        write_fifo_en <= 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_fifo_en <= 1'b0;
    end
    else if (!empty & !read_ram_en & !read_fifo_en & i_emac_rx_axis_ready) begin
        read_fifo_en <= 1'b1;
    end
    else begin
        read_fifo_en <= 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_en <= 1'b0;
    end
    else if(r_rd_data_cnt == read_fifo_data - 1 && read_ram_en) begin
        read_ram_en <= 1'b0;
    end
    else if (!empty & !read_ram_en & !read_fifo_en & i_emac_rx_axis_ready) begin
        read_ram_en <= 1'b1;
    end
end

//read_fifo_data在读使能有效的时候自加；因为会有地址回溯，所以每一个地址的数据都是有效的，读使能有效就可以直接读不用考虑起点地址。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_addr <= 1'b0;
    end
    else if (read_ram_en) begin
        read_ram_addr <= read_ram_addr + 1'b1;
    end
    else begin
        read_ram_addr <= read_ram_addr;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_emac_rx_axis_user <= 'b0;
    end
    else if(r_read_ram_en & !read_ram_en)begin
        ro_emac_rx_axis_user <= 'b0;
    end
    else if (read_fifo_en) begin
        ro_emac_rx_axis_user <= read_fifo_data;
    end
    
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_emac_rx_axis_valid <= 1'b0;
    end
    else if(o_emac_rx_axis_last & ro_emac_rx_axis_valid)
        ro_emac_rx_axis_valid <= 1'b0;
    else if (read_ram_en) begin
        ro_emac_rx_axis_valid <= 1'b1;
    end
end

//r_read_ram_en
always @(posedge i_clk) begin
    r_read_ram_en <= read_ram_en;
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rd_data_cnt <= 16'd0;
    end
    else if (read_ram_en) begin
        if (r_rd_data_cnt == ro_emac_rx_axis_user - 1)
            r_rd_data_cnt <= 16'd0;
        else
            r_rd_data_cnt <= r_rd_data_cnt + 1'b1;
    end
end

//当读到倒数最后一个数据时拉高r_rx_axis_valid
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_emac_rx_axis_last <= 1'b0;
    end
    else if (ro_emac_rx_axis_valid & i_emac_rx_axis_ready &&  r_rd_data_cnt == ro_emac_rx_axis_user - 1) begin
        ro_emac_rx_axis_last <= 1'b1;
    end
    else begin
        ro_emac_rx_axis_last <= 1'b0;
    end
end




endmodule