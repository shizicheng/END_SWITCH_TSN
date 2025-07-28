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
//////////////////////////////////////////////////////////////////////////////////

module FAST_qbu_Pmac_tx#(
        parameter       AXIS_DATA_WIDTH      =          8
)(
    input           wire                                i_clk                       ,
    input           wire                                i_rst                       ,
    // TOP2PMAC
    input           wire    [AXIS_DATA_WIDTH - 1:0]     i_top_Pmac_tx_axis_data     ,
    input           wire    [15:0]                      i_top_Pmac_tx_axis_user     ,
    input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_top_Pmac_tx_axis_keep     ,
    input           wire                                i_top_Pmac_tx_axis_last     ,
    input           wire                                i_top_Pmac_tx_axis_valid    ,
    input           wire    [15:0]                      i_top_Pmac_tx_axis_type     ,  //位宽为16位 
    output          wire                                o_top_Pmac_tx_axis_ready    ,
    //PMAC2EMAC
    output          wire                                o_pamc_send_busy            ,
    output          wire                                o_pamc_send_apply           ,
    input           wire                                i_emac_send_busy            ,
    input           wire                                i_emac_send_apply           ,
    // output          reg                                 occupy_succ,
    //PMAC2NEXT
    input                                               i_rx_ready                  ,//组帧模块准备好了
    output          reg     [15:0]                      o_send_type  = 'd0          ,
    output                  [AXIS_DATA_WIDTH-1 :0]      o_send_data                 ,
    output          reg                                 o_send_last                 ,
    output                                              o_send_valid                ,
    output          reg     [15:0]                      o_pmac_send_len  = 'd0      ,
    output          reg                                 o_pmac_send_len_val         ,
    //PMAC2NEXT_type
    output          reg     [7:0]                       o_smd = 'd0                 ,
    output          reg     [7:0]                       o_fra = 'd0                 ,
    output          reg                                 o_smd_vld                   ,
    output          reg                                 o_fra_vld                   ,
    output          reg                                 o_crc                       ,//为1则为crc否则为mcrc。

    output          wire    [7:0]                       o_frag_next_tx              ,
    input           wire    [19:0]                      i_watchdog_timer            ,
    input           wire                                i_watchdog_timer_vld        ,
    output          wire                                o_tx_timeout                ,
    output          wire    [15:0]                      o_preempt_success_cnt       ,
    input           wire    [ 7:0]                      i_min_frag_size             ,//最小片段大小
    input           wire                                i_min_frag_size_vld         ,
    output          wire                                o_preempt_active            ,
    output          wire                                o_preemptable_frame            
    // input           wire    [ 7:0]                      i_add_frag_size          ,     //非最终片段的最小长度控制
          
); 


/***************function**************/

/***************parameter*************/
/*
//状态机参数
localparam              IDLE            =           5'b00001;
localparam              SEND            =           5'b00010;
localparam              STOP            =           5'b00100;
localparam              KEEP            =           5'b01000;
localparam              END             =           5'b10000;
*/

//ram定义参数
localparam           RAM_DEPTH           = 'd2048 ; //4096
localparam           RAM_PERFORMANCE     = "LOW_LATENCY" ;
localparam           INIT_FILE           = ""    ; 

//fifo参数
localparam           DATAWIDTH           = 'd32  ; //写位宽
localparam           DEPT_W              = 'd16  ; //写深度
localparam           AL_FUL              = DEPT_W - 10 ;
localparam           AL_EMP              = 10    ; //空信号    
localparam           READ_MODE           = "fwft" ;
localparam           FIFO_READ_LATENCY   = 'd0   ; 


//编号
localparam           SMD_S0     =       8'he6;
localparam           SMD_S1     =       8'h4c;
localparam           SMD_S2     =       8'h7f;
localparam           SMD_S3     =       8'hb3;

localparam           SMD_C0     =       8'h61;
localparam           SMD_C1     =       8'h52;
localparam           SMD_C2     =       8'h9E;
localparam           SMD_C3     =       8'h2A;

localparam           FRA_0      =       8'hE6;
localparam           FRA_1      =       8'h4C;
localparam           FRA_2      =       8'h7f;
localparam           FRA_3      =       8'hb3;

localparam           TIME_OUT   =       1600;//125000

/***************wire******************/
wire                          write_ram_en              ;
wire    [AXIS_DATA_WIDTH-1:0] write_ram_data            ;
wire    [AXIS_DATA_WIDTH-1:0] read_ram_data             ;
wire    [31:0]                write_fifo_data           ;
wire    [31:0]                read_fifo_data            ;
wire                          empty                     ;
wire                          occupy_succ               ;
wire                          o_sned_valid_pos          ;
wire                          r_mux_ready               ;

/***************reg*******************/
reg                           ri_top_Pmac_tx_axis_valid ;
reg     [19:0]                ri_watchdog_timer         ;
reg                           ri_watchdog_timer_vld     ;
reg     [7:0]                 ri_min_frag_size          ;
reg                           ri_min_frag_size_vld      ;
reg                           ro_preempt_active         ;
reg     [11:0]                write_ram_addr            ; // 12位
reg     [11:0]                read_ram_addr             ; // 12位
reg                           read_ram_en               ;
reg                           r_read_ram_en             ;
reg     [15:0]                ram_data_suppy            ; // ram剩余的有效数据
reg     [2:0]                 smd_s_cnt                 ; // smd_s编码计数
reg     [2:0]                 fre_cnt                   ; // 帧计数器编码计数
reg     [7:0]                 r_smd                     ;
reg     [7:0]                 r_fra                     ;
reg                           r_occupy                  ; // 被抢占标志只要被抢占就一直拉高
reg                           r_last_frag               ; // 若为一组数据最后一帧则拉高
reg                           r_o_pamc_send_apply       ;
reg     [15:0]                r_preempt_success_cnt     ;
reg                           r_occupy_ban_flag         ;
reg     [31:0]                r_read_fifo_data          ;
reg                           r_read_fifo_en = 0        ;
reg     [7:0]                 r_frag_next_tx            ;
reg                           r_read_ram_en_1d          ;
reg                           r_pmac_timeout_flag       ;
reg                           read_fifo_en              ;
reg                           write_fifo_en_flag        ; // 写FIFO标志
reg                           last_flag                 ; // 接收到最后一个数据标志
reg     [10:0]                data_len = 'd0            ; // data_len 总的一组数据的长度
reg     [10:0]                data_len_supply           ; // 剩余没有发的数据的数量
reg                           r_occupy_succ             ;
reg     [10:0]                send_data_cnt             ; // 已经发送的一组数据的长度
reg     [10:0]                r_send_data_cnt           ; // 已经发送的一组数据的长度
reg                           result_send_apply         ;
reg     [19:0]                r_occupy_succ_cnt         ;
reg                           r_occupy_succ_flag        ;
reg                           ri_emac_send_busy         ;

/***************component*************/
// ram存储数据，fifo存储长度信息和协议类型信息
ram_simple2port #(
    .RAM_WIDTH        (AXIS_DATA_WIDTH   ), // Specify RAM data width
    .RAM_DEPTH        (RAM_DEPTH         ), // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE  (RAM_PERFORMANCE   ), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"             
    .INIT_FILE        (INIT_FILE         )  // Specify name/location of RAM initialization file if using one (leave blank if not)
) inst_data (
    .addra            (write_ram_addr    ), // Write address bus, width determined from RAM_DEPTH
    .addrb            (read_ram_addr     ), // Read address bus, width determined from RAM_DEPTH
    .dina             (write_ram_data    ), // RAM input data
    .clka             (i_clk             ), // Write clock
    .clkb             (i_clk             ), // Read clock
    .wea              (write_ram_en      ), // Write enable
    .enb              (read_ram_en       ), // Read Enable, for additional power savings, disable when not in use
    .rstb             (i_rst             ), // Output reset (does not affect memory contents)
    .regceb           (1'b1              ), // Output register enable
    .doutb            (read_ram_data     )  // RAM output data
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
//     .DATAWIDTH         (DATAWIDTH         ),
//     .DEPT_W            (DEPT_W            ),
//     .AL_FUL            (AL_FUL            ),
//     .AL_EMP            (AL_EMP            ),
//     .READ_MODE         (READ_MODE         ),
//     .FIFO_READ_LATENCY (FIFO_READ_LATENCY )
// ) inst_my_xpm_fifo_sync (
//     .wr_clk            (i_clk             ),
//     .din               (write_fifo_data   ), // 长度信息与协议类型信息
//     .wr_en             (write_fifo_en     ),
//     .dout              (read_fifo_data    ),
//     .data_valid        (                  ),
//     .rd_en             (read_fifo_en      ),
//     .rst               (i_rst             ),
//     .empty             (empty             ),
//     .full              (                  ),
//     .rd_data_count     (                  ),
//     .wr_data_count     (                  ),
//     .almost_empty      (                  ),
//     .almost_full       (                  )
// );


/***************assign****************/

//ram

assign write_ram_en     = i_top_Pmac_tx_axis_valid  ;
assign write_ram_data   = i_top_Pmac_tx_axis_data   ;
assign write_fifo_en    = i_top_Pmac_tx_axis_valid&&ri_top_Pmac_tx_axis_valid==0&&(write_fifo_en_flag==0||last_flag==1);   //考虑上层数据过来是否存在间隔，若不存在此处处在bug
assign write_fifo_data  = {i_top_Pmac_tx_axis_user,i_top_Pmac_tx_axis_type}   ;     //长度信息与协议类型信息


//输出

assign o_top_Pmac_tx_axis_ready     = ram_data_suppy <= 1500              ;
assign o_pamc_send_busy             = read_ram_en                       ;
//assign o_send_type                = read_fifo_en? read_fifo_data[15:0]:o_send_type    ;  //没读完又来了一组数据，没给en提前有效
assign o_send_data                  = r_read_ram_en ? read_ram_data : 'd0                     ;
//assign o_send_last                = occupy_succ && r_occupy_succ==0   ;    //修改，这个只有抢占的时候才有效
//assign o_send_last                = (occupy_succ && r_occupy_succ==0)||data_len_supply==1;  //改成了时序逻辑
assign o_send_valid                 = r_read_ram_en                     ;
//assign o_pmac_send_len              =read_fifo_en ? r_read_fifo_data[31:16] : o_send_last ? r_send_data_cnt+1 : o_pmac_send_len;//被抢占时传输的数据要时时更新
//assign o_pmac_send_len_val          = o_send_last;  //read_fifo_en || o_send_last && data_len_supply > 2;
//assign o_smd                      = r_read_ram_en ? r_smd : o_smd     ;               
//assign o_fra                      = r_read_ram_en ? r_fra : o_fra     ;       
//assign o_crc                       = r_last_frag   ? 1'b1  : 0;   //如果是被打断的最后一个片段，o_crc拉高。其他情况o_crc是被抢占信号取反，但是第一次被打断之前r_occupy=0，
                                                                            //这样的话第一个片段数据crc会为1而不是0 ，所以我想其他的都等于0    
                                                                            //所以我想改成o_crc  = r_last_frag   ? 1'b1  : 0;
                                                                          //改成了时序逻辑
//assign data_len = read_fifo_en ? read_fifo_data[31:16]: data_len;//data_len 总的一组数据的长度，从fifo中都出来后保存在寄存器中。修改，我觉得加个清零条件会更好
assign occupy_succ = (send_data_cnt> (ri_min_frag_size - 1) && data_len_supply >= (ri_min_frag_size + 1)) && i_emac_send_apply & !r_occupy_ban_flag;//是否被抢占信号，当已经发送的数据大于64且还没有发送的数据也大于64表明可以抢占(由于read_ram_en是时序逻辑信号（滞后一拍），因此要提前一排数据)
                                                                                   //o_emac_send_apply = read_ram_en ? 1'b0 : empty==0&&i_pmac_send_busy==1; emac有数据且pmac正在发送时emac发出申请
                                                                                   // read_ram_en=1 -> (empty==0||send_data_cnt<(data_len-1))&&i_pmac_send_busy==0   
                                                                                   //若occupy_succ=1，则read_ram_en=0（o_pamc_send_busy=0）                                                                     
assign o_pamc_send_apply=r_o_pamc_send_apply;  //pMAC有数据要发就拉高

//新增r_mux_ready，当组帧模块空闲时或者emac正在发送数据就是拉高，用此信号指示能不能向下层传递数据
assign r_mux_ready = i_rx_ready || read_ram_en;

assign o_sned_valid_pos = !r_read_ram_en&&read_ram_en;


assign o_frag_next_tx = r_frag_next_tx;
assign o_tx_timeout = r_pmac_timeout_flag;
assign o_preempt_success_cnt = r_preempt_success_cnt;        
assign o_preempt_active    = ro_preempt_active   ; //是否处于抢占状态
assign o_preemptable_frame = !r_occupy_ban_flag ? read_ram_en : 'd0; //当前传输是否为可抢占帧                       
/***************always****************/


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_preempt_active <= 'b0;
    end
    else if(!i_emac_send_busy & ri_emac_send_busy) begin
        ro_preempt_active <= 'b0;
    end
    else if(occupy_succ & o_sned_valid_pos)begin 
        ro_preempt_active <= 1'b1;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_preempt_success_cnt <= 'b0;
    end
    else if(occupy_succ & !r_occupy_succ)begin 
         r_preempt_success_cnt <= r_preempt_success_cnt + 1'b1;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_read_fifo_data <= 'b0;
    end
    else if(read_fifo_en)begin 
         r_read_fifo_data <= read_fifo_data;
    end
end

always @(posedge i_clk) begin
    ri_emac_send_busy <= i_emac_send_busy;
    r_read_fifo_en <= read_fifo_en;
    ri_watchdog_timer_vld <= i_watchdog_timer_vld;
    ri_min_frag_size_vld <= i_min_frag_size_vld;
   
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         ri_min_frag_size <= 'd46;
    end
    else if(ri_min_frag_size_vld)begin 
         ri_min_frag_size <= i_min_frag_size;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_occupy_succ_flag <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag)begin 
         r_occupy_succ_flag <= 'b0;
    end
    else if(!r_read_ram_en_1d && r_read_ram_en)begin 
         r_occupy_succ_flag <= 'b0;
    end
    else if(occupy_succ)begin
         r_occupy_succ_flag <= 'b1;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         ri_watchdog_timer <= 'd125000; //1ms
    end
    else if(ri_watchdog_timer_vld) begin
         ri_watchdog_timer <= i_watchdog_timer;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_occupy_succ_flag <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag)begin  
         r_occupy_succ_flag <= 'b0;
    end
    else if(!r_read_ram_en_1d && r_read_ram_en)begin  
         r_occupy_succ_flag <= 'b0;
    end
    else if(occupy_succ)begin
         r_occupy_succ_flag <= 'b1;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_occupy_succ_cnt <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag)begin  
         r_occupy_succ_cnt <= 'b0;
    end
    else if(!r_read_ram_en_1d && r_read_ram_en)begin  
         r_occupy_succ_cnt <= 'b0;
    end
    else if(r_occupy_succ_flag)begin
         r_occupy_succ_cnt <= r_occupy_succ_cnt + 1'b1;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_pmac_timeout_flag <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag)begin  
         r_pmac_timeout_flag <= 1'b1;
    end
    else begin
         r_pmac_timeout_flag <= 'b0;
    end
end

                //更改点由于存在组合逻辑循环因此改成reg类型//



always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         r_occupy_ban_flag <= 'b0;
    end
    else if(r_occupy_ban_flag && data_len_supply < 2)begin
         r_occupy_ban_flag <= 'b0;
    end
    else if(i_emac_send_apply && o_fra == FRA_3)begin
         r_occupy_ban_flag <= 'b1;
    end
end

//data_len 总的一组数据的长度，从fifo中都出来后保存在寄存器中。修改，我觉得加个清零条件会更好
//与read_fifo_en 保持时序相同
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         data_len <= 'b0;
    end
    else if(r_pmac_timeout_flag)
         data_len <= 'b0;
    else if(occupy_succ||read_fifo_en==1)begin
         data_len <= data_len;
    end
    else if(empty==0&&i_emac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&&result_send_apply&&r_mux_ready&&fre_cnt<1)begin
         data_len <= read_fifo_data[31:16];
    end
    else data_len <= data_len ;
end

//assign o_send_type = r_read_fifo_en? read_fifo_data[15:0]:o_send_type;  //没读完又来了一组数据，没给en提前有效
//与read_fifo_en 保持时序相同
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         o_send_type <= 'b0;
    end
    else if(r_pmac_timeout_flag)
         o_send_type <= 'b0;
    else if(occupy_succ||read_fifo_en==1)begin
         o_send_type <= o_send_type;
    end
    else if(empty==0&&i_emac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&&result_send_apply&&r_mux_ready&&fre_cnt<1)begin
         o_send_type <= read_fifo_data[15:0];
    end
    else o_send_type <= o_send_type ;
end

//assign o_pmac_send_len =r_read_fifo_en ? r_read_fifo_data[31:16] : o_send_last ? r_send_data_cnt+1 : o_pmac_send_len;//被抢占时传输的数据要时时更新
//被抢占后重新发送时要更新新的长度信息。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         o_pmac_send_len <= 'b0;
    end
    else if(r_pmac_timeout_flag)begin
         o_pmac_send_len <= 'b0;
    end
    else if(read_fifo_en==1)begin
         o_pmac_send_len <= read_fifo_data[31:16];
    end
    else if(o_sned_valid_pos)begin
         o_pmac_send_len <= r_read_fifo_data[31:16];
    end
     else if(o_send_last)begin
         o_pmac_send_len <= r_send_data_cnt+1;
    end
    else o_pmac_send_len <= o_pmac_send_len ;
end

always @(posedge i_clk or posedge i_rst) begin
     if (i_rst) begin
         o_pmac_send_len_val<=0; 
     end
     else begin
         o_pmac_send_len_val<= o_send_last||o_sned_valid_pos;
     end
 end  

//assign o_smd = r_read_ram_en ? r_smd : o_smd     ;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         o_smd<=0; 
     end
    else if(read_ram_en)begin
         o_smd <= r_smd;
    end
    else o_smd <= o_smd ;
end

//assign o_fra = r_read_ram_en ? r_fra : o_fra     ;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
         o_fra<=0; 
     end
    else if(read_ram_en)begin
         o_fra <= r_fra;
    end
    else o_fra <= o_fra;
end



always @(posedge i_clk) begin
    if(r_last_frag)begin
         o_crc = 1;
    end
    else if(read_ram_en)begin
         o_crc = 'b0;
    end
    else o_crc = o_crc ;
end

//assign o_send_last                = (occupy_succ && r_occupy_succ==0)||data_len_supply==1;  //改成了时序逻辑
always @(posedge i_clk) begin
    if (i_rst) begin
         o_send_last <= 'b0;
    end
    else if((occupy_succ && r_occupy_succ==0)||data_len_supply==1)begin
         o_send_last <= 1;
    end
    else o_send_last <= 'b0;
end

//ri_top_Pmac_tx_axis_valid;
always @(posedge i_clk) begin
    if (i_rst) begin
        ri_top_Pmac_tx_axis_valid <= 'b0;
    end
    else begin
        ri_top_Pmac_tx_axis_valid <= i_top_Pmac_tx_axis_valid;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        o_smd_vld<= 'b0;
    end
    else if(read_ram_en && !r_read_ram_en)begin
        o_smd_vld<= 'b1;
    end
    else begin
        o_smd_vld<= 'b0;
     end
end
//data_len_supply剩余没有发的数据的数量
always @(posedge i_clk) begin
    if (i_rst) begin
        data_len_supply <= 'b0;
    end
    else if(r_pmac_timeout_flag) begin
        data_len_supply <= 'b0;
    end
    else if (read_fifo_en==1) begin
         data_len_supply <=data_len-1;
    end
    else if (read_ram_en)begin
         data_len_supply <=data_len_supply-1;
    end
    else data_len_supply <=data_len_supply;
end

//ram_data_suppy,ram中剩余的有效数据，当写FIFO有效的时候就加上写入的数据长度，当每次读出数据读的时候就减一    这个代表ram里面有效的数据？
always @(posedge i_clk) begin
    if (i_rst) begin
        ram_data_suppy <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag) begin
        ram_data_suppy <= ram_data_suppy - data_len_supply - 1;
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

always @(posedge i_clk) begin
    if (i_rst) begin
        r_read_ram_en <= 'b0;
        r_read_ram_en_1d <= 'd0;
    end
    else begin
        r_read_ram_en <= read_ram_en;
        r_read_ram_en_1d <= r_read_ram_en;
    end
end

//写使能有效地址就加一
always @(posedge i_clk) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if(write_ram_addr=='d4090) //加了这个避免写入4095的数据读不出来
        write_ram_addr <= 'b0;   
    else if (write_ram_en) begin
        write_ram_addr <= write_ram_addr + 1'b1;
    end
    else begin
        write_ram_addr <= write_ram_addr;
    end
end

//读使能有效地址就加一
always @(posedge i_clk) begin
    if (i_rst) begin
        read_ram_addr <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag) begin
        read_ram_addr <= read_ram_addr + data_len_supply ;
    end
    else if( read_ram_addr =='d4090) //加了这个避免写入4095的数据读不出来  ram与fifo尽量不要写满应该留出5-10个位置，否则会出现奇怪的问题
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
always @(posedge i_clk) begin
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

//last_flag，收到i_top_Pmac_tx_axis_last信号就会拉高，当收到写FIFO使能就会拉低
always @(posedge i_clk) begin
    if (i_rst) begin
        last_flag <= 'b0;
    end
    else if(i_top_Pmac_tx_axis_last==1) begin
        last_flag <= 1'b1;
    end
    else if(write_fifo_en==1) begin
        last_flag <= 1'b0;
    end
    else begin
        last_flag <= last_flag;
    end
end

//o_pamc_send_apply 防止emac与pmac数据同时出现，因此发送pamc数据前先发送一个申请到emac.   只要有数据，就发送申请
always @(posedge i_clk) begin
    if (i_rst) begin
        r_o_pamc_send_apply <= 1'b0;
    end                 //send_data_cnt<data_len-1
    else if ((empty==0||data_len_supply)&&i_emac_send_busy==0&&read_ram_en==0&&r_mux_ready==1) begin  //pmac与emac都没在发数据。而pmc有数据要发或者被打断了需要再次发，都会向emac发送请求
                                                                                                              //是否加一个r_o_pamc_send_apply <= 1'b0，因为只拉高1个周期
                                                                                                              //所有数据都发完，存在send_data_cnt<data_len-1且read_ram_en==0的情况，这个时候不需要发送申请
        r_o_pamc_send_apply <= 1'b1;
    end
    else begin
        r_o_pamc_send_apply<=1'b0;
    end
end

//result_send_apply 当o_pamc_send_apply发送完申请后若emac也有数据发就会i_emac_send_busy==1,此时pmac就不会发了   回应是i_emac_send_busy？？那不申请不是就可以直接看到

always @(posedge i_clk) begin
    if (i_rst) begin
        result_send_apply <= 'b0;
    end
    else if(o_pamc_send_apply) begin
        result_send_apply <= ~i_emac_send_busy;
    end
  //  else if(read_ram_en==0) begin             //一组数据发送完就拉低 修改原因：result_send_apply比read_ram_en==0晚一拍，当empty=0,result_send_apply=1,emac_busy=0时read_ram_en=1
 //   else if((data_len_supply==1)||(send_data_cnt==0&&empty==1&&!r_occupy)) begin
      else if((data_len_supply==1)||(send_data_cnt==0)) begin
        result_send_apply <= 1'b0;
    end
    else begin
        result_send_apply <= result_send_apply;
    end
end

//读ram使能，读出来的数据直接传输到下一层，当fifo里有数据（信息与数据并存）或者上一组数据没有读完 且没有没有被抢占，且满足帧间隔时间时可以开始读数据,同时组帧模块准备好了组帧。
//上边有与这个时序对其的数据更改这个上边的也应该更改如data_len
always @(posedge i_clk) begin
    if (i_rst) begin
        read_ram_en <= 1'b0;
    end
    else if (occupy_succ && r_occupy_succ==0) begin
        read_ram_en <= 1'b0;
    end
     else if(data_len_supply==1)
           read_ram_en <= 1'b0;       //加了这个因为被打断后send_data_cnt会清零一次，只能通过data_len_supply代表一组数据读完
     else if (send_data_cnt==(data_len-1)) //加了这个因为一组数据读完后read_ram_en要拉低
           read_ram_en <= 1'b0;
     else if (send_data_cnt==0&&empty==1&&!r_occupy) begin //加了这个避免一组数据读完后，send_data_cnt=0，且empty==1且非抢占组 时再次读     
           read_ram_en <= 1'b0;     
     end    // send_data_cnt<(data_len-1)
     else if ((empty==0||data_len_supply)&&result_send_apply&&i_emac_send_busy==0&&r_mux_ready) begin    //当fifo有数据或者发送的数据量小于总长度    
           read_ram_en <= 1'b1;
    end
    else begin
          read_ram_en<=1'b0;
    end
end

//读fifo使能，读出来的数据为当前的长度信息，当fifo里有数据且没有没有被抢占，且满足帧间隔时间时可以开始读数据注意每次只能读取一个fifo数据。
always @(posedge i_clk) begin
    if (i_rst) begin
        read_fifo_en  <= 1'b0;
    end
    else if (occupy_succ||read_fifo_en==1) begin 
        read_fifo_en  <= 1'b0;
    end
    // else if (r_occupy_succ_cnt == TIME_OUT - 1 && r_occupy_succ_flag) begin 
    //     read_fifo_en  <= 1'b1;
    // end                                                                                                     //加上fre_cnt为了防止被抢占后上一组数据还没发完就发下一组
    else if (empty==0&&i_emac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&&result_send_apply&&r_mux_ready&&fre_cnt<1) begin//加了result_send_apply
        read_fifo_en  <= 1'b1;
    end
    else begin
        read_fifo_en<=1'b0;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        r_occupy_succ <= 1'b0;
    end
    else begin
        r_occupy_succ<=occupy_succ; 
    end
end


//send_data_cnt 已经发送的一组数据的长度(计数器)当ram读使能有效的时候开始自加，当加到最大长度是归零，或者加到被抢占时也归零。

always @(posedge i_clk) begin
    if (i_rst) begin
       send_data_cnt  <= 10'b0;
    end
    else if (occupy_succ&&r_occupy_succ== 0 || r_pmac_timeout_flag) begin  //若强占成功，send_data_cnt就清零是不是data_len也要换一下，要不然怎么知道剩余的数据发送完毕
        send_data_cnt <= 1'b0;
    end
    //else if (read_ram_en&&data_len_supply== 0) begin //data_len_supply赋值延迟read_ram_en一拍，当data_len_supply=0时，read_ram_en等于0，所以这个条件无法满足
    else if (r_read_ram_en&&data_len_supply== 0) begin 
        send_data_cnt <= 1'b0;
    end
    else if (read_ram_en) begin
        send_data_cnt <= send_data_cnt +1'b1;
    end
    else begin
        send_data_cnt<=send_data_cnt;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        r_send_data_cnt <= 'b0;
    end
    else begin
       r_send_data_cnt <= send_data_cnt; 
    end
end

        /***************************

            SMD等编码的生成

        ***************************/


//smd_s_cnt 每当data_len_supply为1时加一，当加到3时清零。既每当一组数据发送完成时加一
always @(posedge i_clk) begin
    if (i_rst) begin
       smd_s_cnt  <= 'b0;
    end
    else if (data_len_supply==1 && smd_s_cnt==3) begin
        smd_s_cnt <= 'b0;
    end
    else if (data_len_supply==1 || r_pmac_timeout_flag) begin
        smd_s_cnt <= smd_s_cnt +1'b1;
    end
    else begin
        smd_s_cnt <= smd_s_cnt;
    end
end


//smd编码：当计数器为0123得某一个数时对应为S0S1S2S3,同时判断有没有被抢占，若是被抢占了就是对应的C了。
always @(posedge i_clk) begin
    if (i_rst) begin
        r_smd <= 'b0;
    end
    else case (smd_s_cnt)
        0       : begin if (fre_cnt>0) begin
                        r_smd <= SMD_C0;
                        end
                        else begin
                            r_smd <= SMD_S0;
                        end         
                    end
        1       :begin if (fre_cnt>0) begin
                        r_smd <= SMD_C1;
                        end
                        else begin
                            r_smd <= SMD_S1;
                        end         
                    end
        2       :begin if (fre_cnt>0) begin
                        r_smd <= SMD_C2;
                        end
                        else begin
                            r_smd <= SMD_S2;
                        end         
                    end
        3       :begin if (fre_cnt>0) begin
                        r_smd <= SMD_C3;
                        end
                        else begin
                            r_smd <= SMD_S3;
                        end         
                    end
        default :r_smd<=r_smd;       
    endcase
end


//fre_cnt 当每次被打断时加一最大加到5，第一被打断数值变为1此时没有帧计数器，第二次被打断数值变为2此时帧计数器为0    
//第三次打断数值为3，帧计数器为1；第四次打断数值为4，帧计数器为2；第五次打断数值为5，帧计数器为3；
//第六次打断此时帧计数器应为0，因此使得fre_cnt数值为2；
//每当读一次fifo时表明新的一组数据来了，就会重新开始一次计数给fre_cnt置零。
always @(posedge i_clk) begin
    if (i_rst) begin
        fre_cnt <= 'b0;
    end
  // else if (read_fifo_en) begin   //修改原因：read_fifo_en=1时才清零，会导致上一组数据的fre_cnt延续到下一组数据发送过程，从而导致smd出错
    else if (r_pmac_timeout_flag) begin     
        fre_cnt <= 'b0;
    end
    else if (data_len_supply==1 ) begin     
        fre_cnt <= 'b0;
    end
    
  //  else if (occupy_succ && r_occupy_succ&&fre_cnt==5) begin
    else if (occupy_succ && r_occupy_succ==0&&fre_cnt==4) begin //修改了有明显错误
        fre_cnt <= 'd1;
    end
   // else if (occupy_succ && r_occupy_succ) begin
    else if (occupy_succ && r_occupy_succ==0) begin //修改了有明显错误
        fre_cnt <= fre_cnt + 1'b1;
    end
    else begin
        fre_cnt <= fre_cnt;
    end
end

//同上

always @(posedge i_clk) begin
    if (i_rst) begin
        r_fra <= 'b0;
        r_frag_next_tx <= FRA_0;
    end
    else if (fre_cnt==1) begin
        r_fra <= FRA_0;
        r_frag_next_tx <= FRA_1;
    end
    else if (fre_cnt==2) begin
        r_fra <= FRA_1;
        r_frag_next_tx <= FRA_2;
    end
    else if (fre_cnt==3) begin
        r_fra <= FRA_2;
        r_frag_next_tx <= FRA_3;
    end
    else if (fre_cnt==4) begin
        r_fra <= FRA_3;
        r_frag_next_tx <= FRA_0;
    end
    else begin
        r_fra<=r_fra;
        r_frag_next_tx <= r_frag_next_tx;
    end
end



//always @(posedge i_clk) begin
//    if (i_rst) begin
//        r_fra_vld <= 'b0;
//    end
//  //  else if (occupy_succ && r_occupy_succ) begin
//    else if (occupy_succ && r_occupy_succ==0) begin //修改 
//        r_fra_vld <= 'b1;
//    end
//    else begin
//     //  r_fra_vld <= 'b0;
//       r_fra_vld <= r_fra_vld;
//    end
//end
//添加了这个判断
always @(posedge i_clk) begin
    if (i_rst) begin
        o_fra_vld <= 'b0;
    end
    else if(r_pmac_timeout_flag) begin
        o_fra_vld <= 'b0;
    end
    //else if (occupy_succ && r_occupy_succ==0) begin //修改
    else if (r_occupy && read_ram_en && !r_read_ram_en) begin //修改，开始读fifo，且是强占的组
        o_fra_vld <= 'b1;
    end
    else begin
        o_fra_vld <= 'b0;
    end
end

////第一次用write_fifo_en_flag判断剩下的用data_len_supply判断  ，不是和输出的第一个数据对齐了吗？为什么不检测fifo_en=1
//always @(posedge i_clk) begin
//    if (i_rst) begin
//         o_smd_vld <= 'b0;
//    end
//    else if (data_len_supply==1||write_fifo_en_flag==0) begin
//        o_smd_vld <= 'b1;
//    end
//    else begin
//        o_smd_vld <= 'b0;
//    end
//end

//r_occupy当抢占成功了就会拉高，直到下次读取新的一组数据拉低
always @(posedge i_clk) begin
    if (i_rst) begin
        r_occupy <= 'b0;
    end
    else if (r_pmac_timeout_flag) begin
        r_occupy <= 'b0;
    end
    else if (occupy_succ) begin
        r_occupy <= 'b1;
    end
   //else if (read_fifo_en) begin  //修改原因：r_occupy持续到下一次发送数据，可能会有bug
     else if (data_len_supply==1) begin
        r_occupy <= 'b0;
    end
    else begin
        r_occupy <= r_occupy;
    end
end


//r_last_frag最后一帧数据标志，若剩余的数据u小于64了肯定就是最后一帧的数据了，直到下次读取新的一组数据拉低。 为什么这里写的60
always @(posedge i_clk) begin
    if (i_rst) begin
        r_last_frag <= 'b0;
    end
    else if (data_len_supply==0) begin //避免影响下一次 ，与下面的换了个顺序
        r_last_frag <= 'b0;
    end
    else if (read_ram_en && data_len_supply < ri_min_frag_size) begin
        r_last_frag <= 'b1;
    end

    else begin
        r_last_frag <= r_last_frag;
    end
end

/*
always @(posedge i_clk) begin
    if (i_rst) begin
         <= 'b0;
    end
    else if () begin
        
    end
    else begin
        
    end
end



wire    [104:0]  probe0;
assign  probe0 = {
i_top_Pmac_tx_axis_data     ,
i_top_Pmac_tx_axis_user     ,
i_top_Pmac_tx_axis_keep     ,
i_top_Pmac_tx_axis_last     ,
i_top_Pmac_tx_axis_valid    ,
o_top_Pmac_tx_axis_ready    ,
o_pamc_send_busy,
o_pamc_send_apply,
i_emac_send_busy,
i_emac_send_apply,

i_rx_ready          ,
o_send_data         ,
o_send_last         ,
o_send_valid        ,
o_pmac_send_len     ,
o_pmac_send_len_val ,

o_smd ,
o_fra ,
o_smd_vld,
o_fra_vld,
o_crc,

write_ram_addr,
read_ram_addr,
write_ram_en,
read_ram_en         
} ;

    ila_4 your_inst_ila_1 (
    .i_clk(i_clk), // input wire i_clk


    .probe0(probe0)
);
*/
endmodule
