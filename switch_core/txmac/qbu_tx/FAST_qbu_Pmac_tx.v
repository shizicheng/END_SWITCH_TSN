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
//BUG Posible ��1.�����ϲ����ݹ����Ƿ���ڼ������������fifo����Ϣ���ܻ���bug��
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
    input           wire    [15:0]                      i_top_Pmac_tx_axis_type     ,  //λ��Ϊ16λ 
    output          wire                                o_top_Pmac_tx_axis_ready    ,
    //PMAC2EMAC
    output          wire                                o_pamc_send_busy            ,
    output          wire                                o_pamc_send_apply           ,
    input           wire                                i_emac_send_busy            ,
    input           wire                                i_emac_send_apply           ,
    // output          reg                                 occupy_succ,
    //PMAC2NEXT
    input                                               i_rx_ready                  ,//��֡ģ��׼������
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
    output          reg                                 o_crc                       ,//Ϊ1��Ϊcrc����Ϊmcrc��

    output          wire    [7:0]                       o_frag_next_tx              ,
    input           wire    [19:0]                      i_watchdog_timer            ,
    input           wire                                i_watchdog_timer_vld        ,
    output          wire                                o_tx_timeout                ,
    output          wire    [15:0]                      o_preempt_success_cnt       ,
    input           wire    [ 7:0]                      i_min_frag_size             ,//��СƬ�δ�С
    input           wire                                i_min_frag_size_vld         ,
    output          wire                                o_preempt_active            ,
    output          wire                                o_preemptable_frame            
    // input           wire    [ 7:0]                      i_add_frag_size          ,     //������Ƭ�ε���С���ȿ���
          
); 


/***************function**************/

/***************parameter*************/
/*
//״̬������
localparam              IDLE            =           5'b00001;
localparam              SEND            =           5'b00010;
localparam              STOP            =           5'b00100;
localparam              KEEP            =           5'b01000;
localparam              END             =           5'b10000;
*/

//ram�������
localparam           RAM_DEPTH           = 'd2048 ; //4096
localparam           RAM_PERFORMANCE     = "LOW_LATENCY" ;
localparam           INIT_FILE           = ""    ; 

//fifo����
localparam           DATAWIDTH           = 'd32  ; //дλ��
localparam           DEPT_W              = 'd16  ; //д���
localparam           AL_FUL              = DEPT_W - 10 ;
localparam           AL_EMP              = 10    ; //���ź�    
localparam           READ_MODE           = "fwft" ;
localparam           FIFO_READ_LATENCY   = 'd0   ; 


//���
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
reg     [11:0]                write_ram_addr            ; // 12λ
reg     [11:0]                read_ram_addr             ; // 12λ
reg                           read_ram_en               ;
reg                           r_read_ram_en             ;
reg     [15:0]                ram_data_suppy            ; // ramʣ�����Ч����
reg     [2:0]                 smd_s_cnt                 ; // smd_s�������
reg     [2:0]                 fre_cnt                   ; // ֡�������������
reg     [7:0]                 r_smd                     ;
reg     [7:0]                 r_fra                     ;
reg                           r_occupy                  ; // ����ռ��־ֻҪ����ռ��һֱ����
reg                           r_last_frag               ; // ��Ϊһ���������һ֡������
reg                           r_o_pamc_send_apply       ;
reg     [15:0]                r_preempt_success_cnt     ;
reg                           r_occupy_ban_flag         ;
reg     [31:0]                r_read_fifo_data          ;
reg                           r_read_fifo_en = 0        ;
reg     [7:0]                 r_frag_next_tx            ;
reg                           r_read_ram_en_1d          ;
reg                           r_pmac_timeout_flag       ;
reg                           read_fifo_en              ;
reg                           write_fifo_en_flag        ; // дFIFO��־
reg                           last_flag                 ; // ���յ����һ�����ݱ�־
reg     [10:0]                data_len = 'd0            ; // data_len �ܵ�һ�����ݵĳ���
reg     [10:0]                data_len_supply           ; // ʣ��û�з������ݵ�����
reg                           r_occupy_succ             ;
reg     [10:0]                send_data_cnt             ; // �Ѿ����͵�һ�����ݵĳ���
reg     [10:0]                r_send_data_cnt           ; // �Ѿ����͵�һ�����ݵĳ���
reg                           result_send_apply         ;
reg     [19:0]                r_occupy_succ_cnt         ;
reg                           r_occupy_succ_flag        ;
reg                           ri_emac_send_busy         ;

/***************component*************/
// ram�洢���ݣ�fifo�洢������Ϣ��Э��������Ϣ
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
//     .din               (write_fifo_data   ), // ������Ϣ��Э��������Ϣ
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
assign write_fifo_en    = i_top_Pmac_tx_axis_valid&&ri_top_Pmac_tx_axis_valid==0&&(write_fifo_en_flag==0||last_flag==1);   //�����ϲ����ݹ����Ƿ���ڼ�����������ڴ˴�����bug
assign write_fifo_data  = {i_top_Pmac_tx_axis_user,i_top_Pmac_tx_axis_type}   ;     //������Ϣ��Э��������Ϣ


//���

assign o_top_Pmac_tx_axis_ready     = ram_data_suppy <= 1500              ;
assign o_pamc_send_busy             = read_ram_en                       ;
//assign o_send_type                = read_fifo_en? read_fifo_data[15:0]:o_send_type    ;  //û����������һ�����ݣ�û��en��ǰ��Ч
assign o_send_data                  = r_read_ram_en ? read_ram_data : 'd0                     ;
//assign o_send_last                = occupy_succ && r_occupy_succ==0   ;    //�޸ģ����ֻ����ռ��ʱ�����Ч
//assign o_send_last                = (occupy_succ && r_occupy_succ==0)||data_len_supply==1;  //�ĳ���ʱ���߼�
assign o_send_valid                 = r_read_ram_en                     ;
//assign o_pmac_send_len              =read_fifo_en ? r_read_fifo_data[31:16] : o_send_last ? r_send_data_cnt+1 : o_pmac_send_len;//����ռʱ���������Ҫʱʱ����
//assign o_pmac_send_len_val          = o_send_last;  //read_fifo_en || o_send_last && data_len_supply > 2;
//assign o_smd                      = r_read_ram_en ? r_smd : o_smd     ;               
//assign o_fra                      = r_read_ram_en ? r_fra : o_fra     ;       
//assign o_crc                       = r_last_frag   ? 1'b1  : 0;   //����Ǳ���ϵ����һ��Ƭ�Σ�o_crc���ߡ��������o_crc�Ǳ���ռ�ź�ȡ�������ǵ�һ�α����֮ǰr_occupy=0��
                                                                            //�����Ļ���һ��Ƭ������crc��Ϊ1������0 ���������������Ķ�����0    
                                                                            //��������ĳ�o_crc  = r_last_frag   ? 1'b1  : 0;
                                                                          //�ĳ���ʱ���߼�
//assign data_len = read_fifo_en ? read_fifo_data[31:16]: data_len;//data_len �ܵ�һ�����ݵĳ��ȣ���fifo�ж������󱣴��ڼĴ����С��޸ģ��Ҿ��üӸ��������������
assign occupy_succ = (send_data_cnt> (ri_min_frag_size - 1) && data_len_supply >= (ri_min_frag_size + 1)) && i_emac_send_apply & !r_occupy_ban_flag;//�Ƿ���ռ�źţ����Ѿ����͵����ݴ���64�һ�û�з��͵�����Ҳ����64����������ռ(����read_ram_en��ʱ���߼��źţ��ͺ�һ�ģ������Ҫ��ǰһ������)
                                                                                   //o_emac_send_apply = read_ram_en ? 1'b0 : empty==0&&i_pmac_send_busy==1; emac��������pmac���ڷ���ʱemac��������
                                                                                   // read_ram_en=1 -> (empty==0||send_data_cnt<(data_len-1))&&i_pmac_send_busy==0   
                                                                                   //��occupy_succ=1����read_ram_en=0��o_pamc_send_busy=0��                                                                     
assign o_pamc_send_apply=r_o_pamc_send_apply;  //pMAC������Ҫ��������

//����r_mux_ready������֡ģ�����ʱ����emac���ڷ������ݾ������ߣ��ô��ź�ָʾ�ܲ������²㴫������
assign r_mux_ready = i_rx_ready || read_ram_en;

assign o_sned_valid_pos = !r_read_ram_en&&read_ram_en;


assign o_frag_next_tx = r_frag_next_tx;
assign o_tx_timeout = r_pmac_timeout_flag;
assign o_preempt_success_cnt = r_preempt_success_cnt;        
assign o_preempt_active    = ro_preempt_active   ; //�Ƿ�����ռ״̬
assign o_preemptable_frame = !r_occupy_ban_flag ? read_ram_en : 'd0; //��ǰ�����Ƿ�Ϊ����ռ֡                       
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

                //���ĵ����ڴ�������߼�ѭ����˸ĳ�reg����//



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

//data_len �ܵ�һ�����ݵĳ��ȣ���fifo�ж������󱣴��ڼĴ����С��޸ģ��Ҿ��üӸ��������������
//��read_fifo_en ����ʱ����ͬ
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

//assign o_send_type = r_read_fifo_en? read_fifo_data[15:0]:o_send_type;  //û����������һ�����ݣ�û��en��ǰ��Ч
//��read_fifo_en ����ʱ����ͬ
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

//assign o_pmac_send_len =r_read_fifo_en ? r_read_fifo_data[31:16] : o_send_last ? r_send_data_cnt+1 : o_pmac_send_len;//����ռʱ���������Ҫʱʱ����
//����ռ�����·���ʱҪ�����µĳ�����Ϣ��
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

//assign o_send_last                = (occupy_succ && r_occupy_succ==0)||data_len_supply==1;  //�ĳ���ʱ���߼�
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
//data_len_supplyʣ��û�з������ݵ�����
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

//ram_data_suppy,ram��ʣ�����Ч���ݣ���дFIFO��Ч��ʱ��ͼ���д������ݳ��ȣ���ÿ�ζ������ݶ���ʱ��ͼ�һ    �������ram������Ч�����ݣ�
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

            ram��д��ַ

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

//дʹ����Ч��ַ�ͼ�һ
always @(posedge i_clk) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if(write_ram_addr=='d4090) //�����������д��4095�����ݶ�������
        write_ram_addr <= 'b0;   
    else if (write_ram_en) begin
        write_ram_addr <= write_ram_addr + 1'b1;
    end
    else begin
        write_ram_addr <= write_ram_addr;
    end
end

//��ʹ����Ч��ַ�ͼ�һ
always @(posedge i_clk) begin
    if (i_rst) begin
        read_ram_addr <= 'b0;
    end
    else if(r_occupy_succ_cnt == (ri_watchdog_timer - 1) && r_occupy_succ_flag) begin
        read_ram_addr <= read_ram_addr + data_len_supply ;
    end
    else if( read_ram_addr =='d4090) //�����������д��4095�����ݶ�������  ram��fifo������Ҫд��Ӧ������5-10��λ�ã�����������ֵ�����
        read_ram_addr <= 'b0;
    else if (read_ram_en) begin
        read_ram_addr <= read_ram_addr + 1'b1;
    end
    else begin
        read_ram_addr <= read_ram_addr;
    end
end
        /***************************

            ��FIFO���ramʹ��

        ***************************/
//write_fifo_en_flagдFIFO��־,ֻҪfifoд��һ�ξͻ�һֱ����
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

//last_flag���յ�i_top_Pmac_tx_axis_last�źžͻ����ߣ����յ�дFIFOʹ�ܾͻ�����
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

//o_pamc_send_apply ��ֹemac��pmac����ͬʱ���֣���˷���pamc����ǰ�ȷ���һ�����뵽emac.   ֻҪ�����ݣ��ͷ�������
always @(posedge i_clk) begin
    if (i_rst) begin
        r_o_pamc_send_apply <= 1'b0;
    end                 //send_data_cnt<data_len-1
    else if ((empty==0||data_len_supply)&&i_emac_send_busy==0&&read_ram_en==0&&r_mux_ready==1) begin  //pmac��emac��û�ڷ����ݡ���pmc������Ҫ�����߱��������Ҫ�ٴη���������emac��������
                                                                                                              //�Ƿ��һ��r_o_pamc_send_apply <= 1'b0����Ϊֻ����1������
                                                                                                              //�������ݶ����꣬����send_data_cnt<data_len-1��read_ram_en==0����������ʱ����Ҫ��������
        r_o_pamc_send_apply <= 1'b1;
    end
    else begin
        r_o_pamc_send_apply<=1'b0;
    end
end

//result_send_apply ��o_pamc_send_apply�������������emacҲ�����ݷ��ͻ�i_emac_send_busy==1,��ʱpmac�Ͳ��ᷢ��   ��Ӧ��i_emac_send_busy�����ǲ����벻�ǾͿ���ֱ�ӿ���

always @(posedge i_clk) begin
    if (i_rst) begin
        result_send_apply <= 'b0;
    end
    else if(o_pamc_send_apply) begin
        result_send_apply <= ~i_emac_send_busy;
    end
  //  else if(read_ram_en==0) begin             //һ�����ݷ���������� �޸�ԭ��result_send_apply��read_ram_en==0��һ�ģ���empty=0,result_send_apply=1,emac_busy=0ʱread_ram_en=1
 //   else if((data_len_supply==1)||(send_data_cnt==0&&empty==1&&!r_occupy)) begin
      else if((data_len_supply==1)||(send_data_cnt==0)) begin
        result_send_apply <= 1'b0;
    end
    else begin
        result_send_apply <= result_send_apply;
    end
end

//��ramʹ�ܣ�������������ֱ�Ӵ��䵽��һ�㣬��fifo�������ݣ���Ϣ�����ݲ��棩������һ������û�ж��� ��û��û�б���ռ��������֡���ʱ��ʱ���Կ�ʼ������,ͬʱ��֡ģ��׼��������֡��
//�ϱ��������ʱ���������ݸ�������ϱߵ�ҲӦ�ø�����data_len
always @(posedge i_clk) begin
    if (i_rst) begin
        read_ram_en <= 1'b0;
    end
    else if (occupy_succ && r_occupy_succ==0) begin
        read_ram_en <= 1'b0;
    end
     else if(data_len_supply==1)
           read_ram_en <= 1'b0;       //���������Ϊ����Ϻ�send_data_cnt������һ�Σ�ֻ��ͨ��data_len_supply����һ�����ݶ���
     else if (send_data_cnt==(data_len-1)) //���������Ϊһ�����ݶ����read_ram_enҪ����
           read_ram_en <= 1'b0;
     else if (send_data_cnt==0&&empty==1&&!r_occupy) begin //�����������һ�����ݶ����send_data_cnt=0����empty==1�ҷ���ռ�� ʱ�ٴζ�     
           read_ram_en <= 1'b0;     
     end    // send_data_cnt<(data_len-1)
     else if ((empty==0||data_len_supply)&&result_send_apply&&i_emac_send_busy==0&&r_mux_ready) begin    //��fifo�����ݻ��߷��͵�������С���ܳ���    
           read_ram_en <= 1'b1;
    end
    else begin
          read_ram_en<=1'b0;
    end
end

//��fifoʹ�ܣ�������������Ϊ��ǰ�ĳ�����Ϣ����fifo����������û��û�б���ռ��������֡���ʱ��ʱ���Կ�ʼ������ע��ÿ��ֻ�ܶ�ȡһ��fifo���ݡ�
always @(posedge i_clk) begin
    if (i_rst) begin
        read_fifo_en  <= 1'b0;
    end
    else if (occupy_succ||read_fifo_en==1) begin 
        read_fifo_en  <= 1'b0;
    end
    // else if (r_occupy_succ_cnt == TIME_OUT - 1 && r_occupy_succ_flag) begin 
    //     read_fifo_en  <= 1'b1;
    // end                                                                                                     //����fre_cntΪ�˷�ֹ����ռ����һ�����ݻ�û����ͷ���һ��
    else if (empty==0&&i_emac_send_busy==0&&read_fifo_en==0&&read_ram_en==0&&result_send_apply&&r_mux_ready&&fre_cnt<1) begin//����result_send_apply
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


//send_data_cnt �Ѿ����͵�һ�����ݵĳ���(������)��ram��ʹ����Ч��ʱ��ʼ�Լӣ����ӵ���󳤶��ǹ��㣬���߼ӵ�����ռʱҲ���㡣

always @(posedge i_clk) begin
    if (i_rst) begin
       send_data_cnt  <= 10'b0;
    end
    else if (occupy_succ&&r_occupy_succ== 0 || r_pmac_timeout_flag) begin  //��ǿռ�ɹ���send_data_cnt�������ǲ���data_lenҲҪ��һ�£�Ҫ��Ȼ��ô֪��ʣ������ݷ������
        send_data_cnt <= 1'b0;
    end
    //else if (read_ram_en&&data_len_supply== 0) begin //data_len_supply��ֵ�ӳ�read_ram_enһ�ģ���data_len_supply=0ʱ��read_ram_en����0��������������޷�����
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

            SMD�ȱ��������

        ***************************/


//smd_s_cnt ÿ��data_len_supplyΪ1ʱ��һ�����ӵ�3ʱ���㡣��ÿ��һ�����ݷ������ʱ��һ
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


//smd���룺��������Ϊ0123��ĳһ����ʱ��ӦΪS0S1S2S3,ͬʱ�ж���û�б���ռ�����Ǳ���ռ�˾��Ƕ�Ӧ��C�ˡ�
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


//fre_cnt ��ÿ�α����ʱ��һ���ӵ�5����һ�������ֵ��Ϊ1��ʱû��֡���������ڶ��α������ֵ��Ϊ2��ʱ֡������Ϊ0    
//�����δ����ֵΪ3��֡������Ϊ1�����Ĵδ����ֵΪ4��֡������Ϊ2������δ����ֵΪ5��֡������Ϊ3��
//�����δ�ϴ�ʱ֡������ӦΪ0�����ʹ��fre_cnt��ֵΪ2��
//ÿ����һ��fifoʱ�����µ�һ���������ˣ��ͻ����¿�ʼһ�μ�����fre_cnt���㡣
always @(posedge i_clk) begin
    if (i_rst) begin
        fre_cnt <= 'b0;
    end
  // else if (read_fifo_en) begin   //�޸�ԭ��read_fifo_en=1ʱ�����㣬�ᵼ����һ�����ݵ�fre_cnt��������һ�����ݷ��͹��̣��Ӷ�����smd����
    else if (r_pmac_timeout_flag) begin     
        fre_cnt <= 'b0;
    end
    else if (data_len_supply==1 ) begin     
        fre_cnt <= 'b0;
    end
    
  //  else if (occupy_succ && r_occupy_succ&&fre_cnt==5) begin
    else if (occupy_succ && r_occupy_succ==0&&fre_cnt==4) begin //�޸��������Դ���
        fre_cnt <= 'd1;
    end
   // else if (occupy_succ && r_occupy_succ) begin
    else if (occupy_succ && r_occupy_succ==0) begin //�޸��������Դ���
        fre_cnt <= fre_cnt + 1'b1;
    end
    else begin
        fre_cnt <= fre_cnt;
    end
end

//ͬ��

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
//    else if (occupy_succ && r_occupy_succ==0) begin //�޸� 
//        r_fra_vld <= 'b1;
//    end
//    else begin
//     //  r_fra_vld <= 'b0;
//       r_fra_vld <= r_fra_vld;
//    end
//end
//���������ж�
always @(posedge i_clk) begin
    if (i_rst) begin
        o_fra_vld <= 'b0;
    end
    else if(r_pmac_timeout_flag) begin
        o_fra_vld <= 'b0;
    end
    //else if (occupy_succ && r_occupy_succ==0) begin //�޸�
    else if (r_occupy && read_ram_en && !r_read_ram_en) begin //�޸ģ���ʼ��fifo������ǿռ����
        o_fra_vld <= 'b1;
    end
    else begin
        o_fra_vld <= 'b0;
    end
end

////��һ����write_fifo_en_flag�ж�ʣ�µ���data_len_supply�ж�  �����Ǻ�����ĵ�һ�����ݶ�������Ϊʲô�����fifo_en=1
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

//r_occupy����ռ�ɹ��˾ͻ����ߣ�ֱ���´ζ�ȡ�µ�һ����������
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
   //else if (read_fifo_en) begin  //�޸�ԭ��r_occupy��������һ�η������ݣ����ܻ���bug
     else if (data_len_supply==1) begin
        r_occupy <= 'b0;
    end
    else begin
        r_occupy <= r_occupy;
    end
end


//r_last_frag���һ֡���ݱ�־����ʣ�������uС��64�˿϶��������һ֡�������ˣ�ֱ���´ζ�ȡ�µ�һ���������͡� Ϊʲô����д��60
always @(posedge i_clk) begin
    if (i_rst) begin
        r_last_frag <= 'b0;
    end
    else if (data_len_supply==0) begin //����Ӱ����һ�� ��������Ļ��˸�˳��
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
