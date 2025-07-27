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
//Emac���յ����ݾ�ֱ�Ӵ���ram�У�ͬʱ��Ϣ����fifo�У�����⵽FIFO�������ݺ�emac����æ�źţ�ͬʱemac���pmac�Ƿ��ڷ����ݣ�
//��û�з��ͣ�������֡ģ���ܷ������ݣ������Է�����ֱ�ӷ������ݣ������ܷ��ȴ���
//Emac ram�洢�������������pmacһ����
//////////////////////////////////////////////////////////////////////////////////

module FAST_qbu_Emac_tx#(
        parameter       AXIS_DATA_WIDTH      =          8
)(
    input           wire                                i_clk                       ,
    input           wire                                i_rst                       ,
    // TOP2PMAC
    input           wire    [AXIS_DATA_WIDTH - 1:0]     i_top_Emac_tx_axis_data     ,
    input           wire    [15:0]                      i_top_Emac_tx_axis_user     , //user�����ݳ�����Ϣ
    input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_top_Emac_tx_axis_keep     , //keep��������
    input           wire                                i_top_Emac_tx_axis_last     ,
    input           wire                                i_top_Emac_tx_axis_valid    ,
    input           wire    [15:0]                      i_top_Emac_tx_axis_type     ,   //type��������
    output          wire                                o_top_Emac_tx_axis_ready    ,//����⵽��Ч���ݴ���1500ʱ�����ͣ�������������ݽ�����Ȼ���Դ洢
    //PMAC2EMAC
    input           wire                                i_pmac_send_busy            ,//pamcæ�źţ���ʾPmac���ڷ�����
    input           wire                                i_pmac_send_apply           ,//Pmac���ݷ�������
    output          wire                                o_emac_send_busy            ,//eamcæ�źţ���ʾemac���ڷ�����
    output 		    wire 								o_emac_send_apply           ,//emac���ݷ�������
    //PMAC2NEXT
    input   				         					i_rx_ready                  ,//��֡ģ��׼�������ź�
    output  				[15:0]   					o_send_type                 ,//Э�����ͣ�����mac֡��ʽ��
    output  				[AXIS_DATA_WIDTH-1 :0]   	o_send_data                 ,//�����ź�
    output  		wire	         					o_send_last                 ,//���һ�������ź�
    output  				         					o_send_valid                ,//������Ч�ź�
    output          reg     [15:0]                      o_send_len     = 'd0        ,//���ݳ���
    //PMAC2NEXT_type
    output          wire                                o_smd_val                   ,
    output 	 		wire 	[7:0]						o_smd                        //SMD���� 
    // input                                               i_occupy_succ

);

/***************function**************/

/***************parameter*************/
//(*mark_debug="true"*)

//ram�������
localparam           RAM_DEPTH          = 'd2048                                ;//4096
localparam           RAM_PERFORMANCE    = "LOW_LATENCY"                         ;
localparam           INIT_FILE          = ""                                    ; 


//fifo����
localparam           DATAWIDTH = 'd32                                           ;//дλ��
localparam           DEPT_W = 'd32                                              ;//д���
localparam           AL_FUL =  DEPT_W - 10                                      ;//���ź�
localparam           AL_EMP =  10                                               ;  //���ź�    
localparam           READ_MODE = "fwft"                                         ;
localparam           FIFO_READ_LATENCY = 'd0                                    ; 


//���
localparam			 SMD_E 	=		8'hD5                                       ;



/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg    										ri_top_Emac_tx_axis_valid           ;

//ram
reg     [11:0]  							write_ram_addr                      ;//12λ
reg     [11:0]  							read_ram_addr                       ;//12λ
wire    [AXIS_DATA_WIDTH - 1:0] 			write_ram_data                      ;
wire    [AXIS_DATA_WIDTH - 1:0] 			read_ram_data                       ;
wire    									write_ram_en                        ;
reg     									read_ram_en                         ;
reg     									r_read_ram_en                       ;
reg     [15:0]  							ram_data_suppy                      ;//ramʣ�����Ч����
wire    									o_send_last_q                       ;
reg     									r_o_send_last                       ;
//smd��ֵ
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
reg     									write_fifo_en_flag                  ;//��һ��дFIFO��ñ�־һֱ����
reg     									last_flag                           ;//���յ����һ�����ݱ�־


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
            .full          (),
            .rd_data_count (),
            .wr_data_count (),
            .almost_empty  (),
            .almost_full   ()
        );


/***************assign****************/

//ram

assign write_ram_en     = i_top_Emac_tx_axis_valid  ;
assign write_ram_data   = i_top_Emac_tx_axis_data   ;
assign write_fifo_en    = i_top_Emac_tx_axis_valid && ri_top_Emac_tx_axis_valid==0 && (write_fifo_en_flag==0||last_flag==1);   //�����ϲ����ݹ����Ƿ���ڼ�����������ڴ˴�����bug
assign write_fifo_data  = {i_top_Emac_tx_axis_user,i_top_Emac_tx_axis_type}   ; 	//������Ϣ��Э��������Ϣ

//����r_mux_ready������֡ģ�����ʱ����emac���ڷ������ݾ������ߣ��ô��ź�ָʾ�ܲ������²㴫������
assign r_mux_ready = i_rx_ready || read_ram_en;


//���//ʣ��û�з������ݵ�����
//assign data_len_supply = read_fifo_en ? data_len : (read_ram_en ? data_len_supply-1 : data_len_supply); //Ƕ�׵�̫�࣬�ĳ�ʱ���߼���
assign o_top_Emac_tx_axis_ready 	=ram_data_suppy<=1500 	     	    ;  //ramû�дﵽ���������Կ��Խ���
//assign o_top_Emac_tx_axis_ready 	=write_ram_addr<=4095 	   ;//�ĳ��˵�ַû�дﵽ���������Կ��Խ���
assign o_send_type   				= read_fifo_data[15:0]			 	;
assign o_send_data   				= read_ram_data					 	;
assign o_send_last_q   				= data_len_supply==1                ;    
assign o_send_valid  				= r_read_ram_en					 	;
assign o_emac_send_busy             = read_ram_en                       ;
//���������ڷ������뷢�ͣ���fifo����������pmac���ڷ���ʱ���뷢��
assign o_emac_send_apply = read_ram_en ? 1'b0 : empty==0&&i_pmac_send_busy==1;		
//data_len �ܵ�һ�����ݵĳ��ȣ���fifo�ж������󱣴��ڼĴ����С�
//assign data_len = read_fifo_en ? (read_fifo_data[31:16]) : data_len;
assign o_send_last                  =r_o_send_last                      ;
assign o_smd                        =r_o_smd                            ;
assign o_smd_val                    =r_o_smd_val                        ;
/***************always****************/

        //���ĵ����ڴ�������߼�ѭ����˸ĳ�reg����//
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

//data_len �ܵ�һ�����ݵĳ��ȣ���fifo�ж������󱣴��ڼĴ����С�
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


//SMD�����ǹ̶���
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
//data_len_supplyʣ��û�з������ݵ�����
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


//ram_data_suppy,ram��ʣ�����Ч���ݣ���дram��Ч��ʱ��ͼ���д������ݳ��ȣ���ÿ�ζ������ݶ���ʱ��ͼ�һ

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

            ram��д��ַ

        ***************************/

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_read_ram_en <= 'b0;
    end
    else begin
        r_read_ram_en <= read_ram_en;
    end
end


//дʹ����Ч��ַ�ͼ�һ
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        write_ram_addr <= 'b0;
    end
    else if(write_ram_addr=='d4094) //�����������д��4095�����ݶ�������
        write_ram_addr <= 'b0;
    else if (write_ram_en) begin
        write_ram_addr <= write_ram_addr + 1'b1;
    end
    else begin
        write_ram_addr <= write_ram_addr;
    end
end

//��ʹ����Ч��ַ�ͼ�һ
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_addr <= 'b0;
    end
    else if( read_ram_addr =='d4094) //�����������д��4095�����ݶ�������
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

//last_flag���յ�i_top_Emac_tx_axis_last�źžͻ����ߣ����յ�дFIFOʹ�ܾͻ�����
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

//��ramʹ�ܣ�������������ֱ�Ӵ��䵽��һ�㣬��fifo�������ݣ���Ϣ�����ݲ��棩������һ������(Ϊʲô���ǵ�ǰ������)û�ж��� ��pmacû�з������ݡ�
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        read_ram_en <= 1'b0;
    end                                              //����i_pmac_send_apply
    else if (read_ram_en&&send_data_cnt==(data_len-1)||(i_pmac_send_apply&&read_ram_en==0)) //�������
        read_ram_en <= 1'b0;
    /*else if (read_ram_en&&send_data_cnt==0&&empty==1) begin //�����������һ�����ݶ����send_data_cnt=0����empty==1ʱ�ٴζ�
        read_ram_en <= 1'b0;
        end*/
                       // send_data_cnt<(data_len-1)                            //���fifo���������ݾ�һֱ��ram�� ramΪ0��������fifoΪ���ұ��η��͵����һ�����ݣ��������д�߶���fifo�Ͳ�һ��Ϊ��
    else if ((empty==0||data_len_supply)&&i_pmac_send_busy==0 && r_mux_ready ) begin //���fifo���������ݾ�һֱ��ram�� 
        read_ram_en <= 1'b1;
        end
    else begin
        read_ram_en<=1'b0;
    end
end

//��fifoʹ�ܣ�������������Ϊ��ǰ�ĳ�����Ϣ����fifo����������pmacû�з������ݣ�����֡ģ��׼������,ʱ���Կ�ʼ������ע��ÿ��ֻ�ܶ�ȡһ��fifo���ݡ�
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

//send_data_cnt �Ѿ����͵�һ�����ݵĳ���(������)��ram��ʹ����Ч��ʱ��ʼ�Լӣ����ӵ���󳤶��ǹ��㡣

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
       send_data_cnt  <= 10'b0;
    end
    //else if (read_ram_en&&send_data_cnt== data_len) begin //����������㲻��
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