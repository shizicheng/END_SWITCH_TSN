//////////////////////////////////////////////////////////////////////////////////
// Company:         xxx
// Engineer:        yuqi
// 
// Create Date:     2023/07/01
// Design Name:     xxx
// Module Name:     xxx
// Project Name:    xxx
// Target Devices:  xxx
// Tool Versions:   VIVADO2017.4
// Description:     xxx
// 
// Dependencies:    xxx
// 
// Revision:     v0.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//BUG Posible ：1.考虑上层数据过来是否存在间隔，若不存间隔fifo存信息可能会有bug；
//Emac接收到数据就直接存在ram中，同时信息存在fifo中，当检测到FIFO中有数据后，emac拉高忙信号，同时emac检测pmac是否在发数据，
//若没有发送，则检测组帧模块能否发送数据，若可以发，则直接发送数据，若不能发等待，
//Emac ram存储的最大数据量与pmac一样。
//////////////////////////////////////////////////////////////////////////////////

module FAST_qbu_Emac_tx#(
        parameter       AXIS_DATA_WIDTH      =          8
)(
    input           wire                                i_clk                       ,
    input           wire                                i_rst                       ,
    // TOP2PMAC
    input           wire    [AXIS_DATA_WIDTH - 1:0]     i_top_Emac_tx_axis_data     ,
    input           wire    [15:0]                      i_top_Emac_tx_axis_user     , //user：数据长度信息
    input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_top_Emac_tx_axis_keep     , //keep数据掩码
    input           wire                                i_top_Emac_tx_axis_last     ,
    input           wire                                i_top_Emac_tx_axis_valid    ,
    input           wire    [15:0]                      i_top_Emac_tx_axis_type     ,   //type数据类型
    output          wire                                o_top_Emac_tx_axis_ready    ,//当检测到有效数据大于1500时会拉低，但是如果有数据进来依然可以存储
    //PMAC2EMAC
    input           wire                                i_pmac_send_busy            ,//pamc忙信号，表示Pmac正在发数据
    input           wire                                i_pmac_send_apply           ,//Pmac数据发送申请
    output          wire                                o_emac_send_busy            ,//eamc忙信号，表示emac正在发数据
    output 		    wire 								o_emac_send_apply           ,//emac数据发送申请
    //PMAC2NEXT
    input   				         					i_rx_ready                  ,//组帧模块准备好了信号
    output  				[15:0]   					o_send_type                 ,//协议类型（参照mac帧格式）
    output  				[AXIS_DATA_WIDTH-1 :0]   	o_send_data                 ,//数据信号
    output  		wire	         					o_send_last                 ,//最后一个数据信号
    output  				         					o_send_valid                ,//数据有效信号
    output          reg     [15:0]                      o_send_len     = 'd0        ,//数据长度
    //PMAC2NEXT_type
    output          wire                                o_smd_val                   ,
    output 	 		wire 	[7:0]						o_smd                        //SMD编码 
    // input                                               i_occupy_succ

);

/***************function**************/

/***************parameter*************/
//(*mark_debug="true"*)

//ram定义参数
localparam           RAM_DEPTH          = 'd2048                                ;//4096
localparam           RAM_PERFORMANCE    = "LOW_LATENCY"                         ;
localparam           INIT_FILE          = ""                                    ; 


//fifo参数
localparam           DATAWIDTH = 'd32                                           ;//写位宽
localparam           DEPT_W = 'd32                                              ;//写深度
localparam           AL_FUL =  DEPT_W - 10                                      ;//满信号
localparam           AL_EMP =  10                                               ;  //空信号    
localparam           READ_MODE = "fwft"                                         ;
localparam           FIFO_READ_LATENCY = 'd0                                    ; 


//编号
localparam			 SMD_E 	=		8'hD5                                       ;



/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg    										ri_top_Emac_tx_axis_valid           ;

//ram
reg     [11:0]  							write_ram_addr                      ;//12位
reg     [11:0]  							read_ram_addr                       ;//12位
wire    [AXIS_DATA_WIDTH - 1:0] 			write_ram_data                      ;
wire    [AXIS_DATA_WIDTH - 1:0] 			read_ram_data                       ;
wire    									write_ram_en                        ;
reg     									read_ram_en                         ;
reg     									r_read_ram_en                       ;
reg     [15:0]  							ram_data_suppy                      ;//ram剩余的有效数据
wire    									o_send_last_q                       ;
reg     									r_o_send_last                       ;
//smd数值
reg 	[7:0] 								r_o_smd                             ;
reg     									r_o_smd_val                         ;
reg     [10:0] 								data_len_supply                     ;
reg     [10:0] 								send_data_cnt                       ;
reg     [10:0] 								data_len = 'd0                      ;
/***************wire******************/

wire    									r_mux_ready                         ;

//fifo
wire  [31:0]  								write_fifo_data                     ;//(i_info_vld,i_smd_type,i_frag_cnt,i_crc_vld,addr_end)
wire    									write_fifo_en                       ;
wire  [31:0]  								read_fifo_data                      ;
reg     									read_fifo_en                        ;
wire    									empty                               ;
reg     									write_fifo_en_flag                  ;//第一次写FIFO后该标志一直拉高
reg     									last_flag                           ;//接收到最后一个数据标志


/***************component*************/
ram_simple2port #(
    .RAM_WIDTH        (AXIS_DATA_WIDTH)    , // Specify RAM data width
    .RAM_DEPTH        (RAM_DEPTH      )    , // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE  (RAM_PERFORMANCE)    , // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"             
    .INIT_FILE        (INIT_FILE      )    // Specify name/location of RAM initialization file if using one (leave blank if not)
) inst_data (
    .addra            (write_ram_addr )    , // Write address bus, width determined from RAM_DEPTH
    .addrb            (read_ram_addr  )    , // Read address bus, width determined from RAM_DEPTH
    .dina             (write_ram_data )    , // RAM input data
    .clka             (i_clk          )    , // Write clock
    .clkb             (i_clk          )    , // Read clock
    .wea              (write_ram_en   )    , // Write enable
    .enb              (read_ram_en    )    , // Read Enable, for additional power savings, disable when not in use
    .rstb             (i_rst          )    , // Output reset (does not affect memory contents)
    .regceb           (1'b1           )    , // Output register enable
    .doutb            (read_ram_data  )      // RAM output data
);
    
async_fifo_fwft #(
    .C_WIDTH          (DATAWIDTH      ),
    .C_DEPTH          (DEPT_W         )
) u_async_fifo_fwft (
    .RD_CLK           (i_clk          ),
    .RD_RST           (i_rst          ),
    .WR_CLK           (i_clk          ),
    .WR_RST           (i_rst          ),
    .WR_DATA          (write_fifo_data),
    .WR_EN            (write_fifo_en  ),
    .RD_DATA          (read_fifo_data ),
    .RD_EN            (read_fifo_en   ),
    .WR_FULL          (               ),
    .RD_EMPTY         (empty          )
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

assign write_ram_en     = i_top_Emac_tx_axis_valid  ;
assign write_ram_data   = i_top_Emac_tx_axis_data   ;
assign write_fifo_en    = i_top_Emac_tx_axis_valid && ri_top_Emac_tx_axis_valid==0 && (write_fifo_en_flag==0||last_flag==1);   //考虑上层数据过来是否存在间隔，若不存在此处处在bug
assign write_fifo_data  = {i_top_Emac_tx_axis_user,i_top_Emac_tx_axis_type}   ; 	//长度信息与协议类型信息

//新增r_mux_ready，当组帧模块空闲时或者emac正在发送数据就是拉高，用此信号指示能不能向下层传递数据
assign r_mux_ready = i_rx_ready || read_ram_en;


//输出//剩余没有发的数据的数量
//assign data_len_supply = read_fifo_en ? data_len : (read_ram_en ? data_len_supply-1 : data_len_supply); //嵌套的太多，改成时序逻辑了
assign o_top_Emac_tx_axis_ready 	=ram_data_suppy<=1500 	     	    ;  //ram没有达到最大的量所以可以接收
//assign o_top_Emac_tx_axis_ready 	=write_ram_addr<=4095 	   ;//改成了地址没有达到最大的量所以可以接收
assign o_send_type   				= read_fifo_data[15:0]			 	;
assign o_send_data   				= read_ram_data					 	;
assign o_send_last_q   				= data_len_supply==1                ;    
assign o_send_valid  				= r_read_ram_en					 	;
assign o_emac_send_busy             = read_ram_en                       ;
//若数据正在发则不申请发送，当fifo中有数据且pmac正在发送时申请发送
assign o_emac_send_apply = read_ram_en ? 1'b0 : empty==0&&i_pmac_send_busy==1;		
//data_len 总的一组数据的长度，从fifo中都出来后保存在寄存器中。
//assign data_len = read_fifo_en ? (read_fifo_data[31:16]) : data_len;
assign o_send_last                  =r_o_send_last                      ;
assign o_smd                        =r_o_smd                            ;
assign o_smd_val                    =r_o_smd_val                        ;
/***************always****************/

        //更改点由于存在组合逻辑循环因此改成reg类型//
//assign o_send_len = read_fifo_en ? read_fifo_data[31:16]  : o_send_len ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_send_len <= 'b0;
    end
    else if(empty==0&&i_pmac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&& r_mux_ready)begin
        o_send_len <= read_fifo_data[31:16];
    end
    else begin
        o_send_len <= o_send_len;
    end
end

//data_len 总的一组数据的长度，从fifo中都出来后保存在寄存器中。
//assign data_len = read_fifo_en ? (read_fifo_data[31:16]) : data_len;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        data_len <= 'b0;
    end
    else if(empty==0&&i_pmac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&& r_mux_ready)begin
        data_len <= read_fifo_data[31:16];
    end
    else begin
        data_len <= data_len;
    end
end


//SMD编码是固定的
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_o_smd <= 'b0;
        r_o_smd_val<= 'b0;
    end
    else if(read_fifo_en==1)begin
        r_o_smd <= SMD_E;
        r_o_smd_val<= 'b1;
    end
    else begin
        r_o_smd <= r_o_smd;
        r_o_smd_val<= 'b0;
     end
end
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_o_send_last <= 'b0;
    end
    else begin
        r_o_send_last <= o_send_last_q;
    end
end
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_o_send_last <= 'b0;
    end
    else begin
        r_o_send_last <= o_send_last_q;
    end
end
//data_len_supply剩余没有发的数据的数量
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        data_len_supply <= 'b0;
    end
    else if (read_fifo_en) begin
         data_len_supply <=data_len-1;
    end
    else if (read_ram_en)begin
         data_len_supply <=data_len_supply-1;
    end
    else data_len_supply <=data_len_supply;
end

//ri_top_Pmac_tx_axis_valid;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_top_Emac_tx_axis_valid <= 'b0;
    end
    else begin
        ri_top_Emac_tx_axis_valid <= i_top_Emac_tx_axis_valid;
    end
end


//ram_data_suppy,ram中剩余的有效数据，当写ram有效的时候就加上写入的数据长度，当每次读出数据读的时候就减一

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ram_data_suppy <= 'b0;
    end
    else if(write_ram_en==1&&read_ram_en==1) begin
        ram_data_suppy <= ram_data_suppy;
    end
    else if(write_ram_en==1) begin
        ram_data_suppy <= ram_data_suppy + 1'b1;
    end
    else if(read_ram_en==1) begin
        ram_data_suppy <= ram_data_suppy - 1'b1;
    end
    else begin
        ram_data_suppy <= ram_data_suppy;
    end
end


        /***************************

            ram读写地址

        ***************************/

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_read_ram_en <= 'b0;
    end
    else begin
        r_read_ram_en <= read_ram_en;
    end
end


//写使能有效地址就加一
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if(write_ram_addr=='d4094) //加了这个避免写入4095的数据读不出来
        write_ram_addr <= 'b0;
    else if (write_ram_en) begin
        write_ram_addr <= write_ram_addr + 1'b1;
    end
    else begin
        write_ram_addr <= write_ram_addr;
    end
end

//读使能有效地址就加一
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_addr <= 'b0;
    end
    else if( read_ram_addr =='d4094) //加了这个避免写入4095的数据读不出来
         read_ram_addr <= 'b0;
    else if (read_ram_en) begin
        read_ram_addr <= read_ram_addr + 1'b1;
    end
    else begin
        read_ram_addr <= read_ram_addr;
    end
end

        /***************************

            读FIFO与读ram使能

        ***************************/
//write_fifo_en_flag写FIFO标志,只要fifo写过一次就会一直拉高
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_fifo_en_flag <= 'b0;
    end
    else if(write_fifo_en==1) begin
        write_fifo_en_flag <= 1'b1;
    end
    else begin
        write_fifo_en_flag <= write_fifo_en_flag;
    end
end

//last_flag，收到i_top_Emac_tx_axis_last信号就会拉高，当收到写FIFO使能就会拉低
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        last_flag <= 'b0;
    end
    else if(i_top_Emac_tx_axis_last==1) begin
        last_flag <= 1'b1;
    end
    else if(write_fifo_en==1) begin
        last_flag <= 1'b0;
    end
    else begin
        last_flag <= last_flag;
    end
end

//读ram使能，读出来的数据直接传输到下一层，当fifo里有数据（信息与数据并存）或者上一组数据(为什么不是当前组数据)没有读完 且pmac没有发送数据。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_en <= 1'b0;
    end                                              //增加i_pmac_send_apply
    else if (read_ram_en&&send_data_cnt==(data_len-1)||(i_pmac_send_apply&&read_ram_en==0)) //加了这个
        read_ram_en <= 1'b0;
    /*else if (read_ram_en&&send_data_cnt==0&&empty==1) begin //加了这个避免一组数据读完后，send_data_cnt=0，且empty==1时再次读
        read_ram_en <= 1'b0;
        end*/
                       // send_data_cnt<(data_len-1)                            //如果fifo里面有数据就一直读ram。 ram为0的条件是fifo为空且本次发送到最后一个数据，当如果边写边读，fifo就不一定为空
    else if ((empty==0||data_len_supply)&&i_pmac_send_busy==0 && r_mux_ready ) begin //如果fifo里面有数据就一直读ram。 
        read_ram_en <= 1'b1;
        end
    else begin
        read_ram_en<=1'b0;
    end
end

//读fifo使能，读出来的数据为当前的长度信息，当fifo里有数据且pmac没有发送数据，且组帧模块准备好了,时可以开始读数据注意每次只能读取一个fifo数据。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
       read_fifo_en  <= 1'b0;
    end
 else if (empty==0&&i_pmac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&& r_mux_ready) begin 
        read_fifo_en  <= 1'b1;
    end
    else begin
        read_fifo_en<=1'b0;
    end
end

//send_data_cnt 已经发送的一组数据的长度(计数器)当ram读使能有效的时候开始自加，当加到最大长度是归零。

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
       send_data_cnt  <= 10'b0;
    end
    //else if (read_ram_en&&send_data_cnt== data_len) begin //这个条件满足不了
    else if (r_read_ram_en&&send_data_cnt== data_len) begin
        send_data_cnt <= 1'b0;
    end
    else if (read_ram_en) begin
        send_data_cnt <= send_data_cnt +1'b1;
    end
    else begin
        send_data_cnt<=send_data_cnt;
    end
end

/*
wire    [83:0]  probe0;
assign  probe0 = {
i_top_Emac_tx_axis_data     ,
i_top_Emac_tx_axis_user     ,
i_top_Emac_tx_axis_keep     ,
i_top_Emac_tx_axis_last     ,
i_top_Emac_tx_axis_valid    ,
o_top_Emac_tx_axis_ready    ,

i_pmac_send_busy,
i_pmac_send_apply,
o_emac_send_busy,
o_emac_send_apply,

i_rx_ready          ,
o_send_type         ,
o_send_data         ,
o_send_last         ,
o_send_valid        ,
o_send_len          ,

o_smd_val,
o_smd
} ;

    ila_3 your_inst_ila_1 (
    .i_clk(i_clk), // input wire i_clk


    .probe0(probe0)
);
*/

endmodule