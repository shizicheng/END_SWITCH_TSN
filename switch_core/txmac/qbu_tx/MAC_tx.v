`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: MAC_tx
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


module MAC_tx#(
    parameter       P_TARTGET_MAC   =   {8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
                    P_SOURCE_MAC    =   {8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
                    P_CRC_CHECK     =   'd1                                  ,
                    AXIS_DATA_WIDTH =   'd8
)(
    input                               i_clk                   ,
    input                               i_rst                   ,

    /*--------info port--------*/   
    input       [47:0]                  i_target_mac            ,
    input                               i_target_mac_valid      ,
    input       [47:0]                  i_source_mac            ,
    input                               i_source_mac_valid      ,

    /*--------data port--------*/
    output                              o_udp_ready             , //组帧模块准备好了
    input       [15:0]                  i_send_type             , //类型
    input       [15:0]                  i_send_len              , //长度
    input       [AXIS_DATA_WIDTH-1:0]   i_send_data             , //数据
    input                               i_send_last             , //最后一个数据
    input                               i_send_valid            , //数据有效信号
                    
    input       [7:0]                   i_smd                   ,
    input       [7:0]                   i_fra                   ,    
    input                               i_smd_vld               ,
    input                               i_fra_vld               ,
    input                               i_crc                   ,   //为1则为crc否则为mcrc。
                
    input                               i_eamc_send_busy        ,
    input                               i_pamc_send_busy        ,
    input       [15:0]                  i_pmac_send_len         ,
    input                               i_pmac_send_len_val     ,
    /*--------GMII port--------*/
    // output    [7:0]                   o_mac_axi_data          , //传输到GMII数据
    // output                           o_mac_axi_data_valid    , //数据有效信号
    output      [AXIS_DATA_WIDTH-1:0]   o_mac_axi_data          ,
    output      [(AXIS_DATA_WIDTH/8)-1:0] o_mac_axi_data_keep   ,
    output                              o_mac_axi_data_valid    ,
    output      [15:0]                  o_mac_axi_data_user     ,
    input                               i_mac_axi_data_ready    ,
    output                              o_mac_axi_data_last     ,

    output      [15:0]                  o_tx_frames_cnt         ,
    output      [15:0]                  o_tx_fragment_cnt       ,
    input       [7:0]                   i_ipg_timer             ,
    input                               i_ipg_timer_vld         ,
    output                              o_tx_busy               
);


/***************function**************/

/***************parameter*************/
localparam           SMD_C0     =       8'h61;
localparam           SMD_C1     =       8'h52;
localparam           SMD_C2     =       8'h9e;
localparam           SMD_C3     =       8'h2a;

//fifo参数
localparam           AL_EMP            =  10      ;  //空信号    
localparam           READ_MODE         = "fwft"   ;
localparam           FIFO_READ_LATENCY = 'd0      ;    
/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]         ri_send_type        ;
reg  [15:0]         ri_send_len         ;
reg  [7 :0]         ri_send_data        ;
reg                 ri_send_valid       ;
reg                 ri_send_valid_1d    ;
reg  [7 :0]         ro_mac_axi_data     ;
// reg                 ro_mac_axi_data_valid       ;
reg                 ro_GMII_valid_1d    ;
reg  [47:0]         r_target_mac        ;
reg  [47:0]         r_source_mac        ;
reg                 r_fifo_mac_rd_en    ;
reg  [15:0]         r_mac_pkg_cnt       ;
reg  [7 :0]         r_mac_data          ;
reg                 r_mac_data_valid    ;
reg                 r_mac_data_valid_1d ;
reg  [15:0]         r_mac_data_cnt      ;
reg                 r_crc_rst           ;          
reg                 r_crc_en            ;
reg  [1 :0]         r_crc_out_cnt       ;  
reg                 r_crc_out_cnt_1d    ;
reg  [15:0]         r_gap_cnt           ;
reg                 ro_udp_ready        ;
reg                 r_fifo_mac_rd_en_1d ;
reg                 r_len_en_flag       ;
reg  [15:0]         r_cur_frame_cnt     ;
reg  [15:0]         r_tx_frames_cnt     ;
reg  [15:0]         r_tx_fragment_cnt   ;
reg  [ 7:0]         ri_ipg_timer        ;
reg                 ri_ipg_timer_vld    ;
reg                 ro_mac_axi_data_valid ;
// reg  [15:0]         ro_mac_axi_data_user  ;
reg                 ri_mac_axi_data_ready ;
reg                 ro_mac_axi_data_last  ;


/***************wire******************/
wire [7 :0]         w_fifo_mac_dout     ;
wire                w_fifo_mac_full     ;
wire                w_fifo_mac_empty    ;
wire                w_send_valid_pos    ;
wire                w_send_valid_neg    ;
wire [31:0]         w_crc_result        ;
wire [15:0]         w_fifo_len_dout     ;
reg  [15:0]         r_w_fifo_len_dout   ;
wire                w_fifo_len_empty    ;
wire                w_fifo_len_full     ;
reg  [7 :0]         w_smd               ;
reg  [7 :0]         w_fra               ;
wire                read_fifo_len_en    ;

wire                write_fifo_len_en   ;
reg                 r_crc               ;
wire [15:0]         w_fifo_len          ;


reg                 test_flag           ;
reg                 r_crc_en_1d         ;

assign o_mac_axi_data_keep = 1'b1;
assign o_mac_axi_data_user = r_w_fifo_len_dout;
assign o_mac_axi_data_last = ro_mac_axi_data_last;
/***************component*************/

    my_xpm_fifo_sync #(
            .DATAWIDTH(AXIS_DATA_WIDTH),
            .DEPT_W('d1024),
            .AL_FUL('d1014),
            .AL_EMP(AL_EMP),
            .READ_MODE(READ_MODE),
            .FIFO_READ_LATENCY(FIFO_READ_LATENCY)
        ) inst_FIFO_MAC_8X1024_U0 (
            .wr_clk        (i_clk),
            .din           (ri_send_data),
            .wr_en         (ri_send_valid),
            .dout          (w_fifo_mac_dout),
            .data_valid    (),
            .rd_en         (r_fifo_mac_rd_en),
            .rst           (i_rst),
            .empty         (w_fifo_mac_empty),
            .full          (w_fifo_mac_full),
            .rd_data_count (),
            .wr_data_count (),
            .almost_empty  (),
            .almost_full   ()
        );
/*
FIFO_MAC_8X64 FIFO_MAC_8X1024_U0 (
  .clk              (i_clk              ),  // input wire clk
  .din              (ri_send_data       ),  // input wire [7 : 0] din
  .wr_en            (ri_send_valid      ),  // input wire wr_en
  .rd_en            (r_fifo_mac_rd_en   ),  // input wire rd_en
  .dout             (w_fifo_mac_dout    ),  // output wire [7 : 0] dout
  .full             (w_fifo_mac_full    ),  // output wire full
  .empty            (w_fifo_mac_empty   )   // output wire empty
);
*/
    my_xpm_fifo_sync #(
            .DATAWIDTH('d16),
            .DEPT_W('d32),
            .AL_FUL('d22),
            .AL_EMP(AL_EMP),
            .READ_MODE(READ_MODE),
            .FIFO_READ_LATENCY(FIFO_READ_LATENCY)
        ) inst_FIFO_16X64_LEN (
            .wr_clk        (i_clk),
            .din           (i_send_len),
            .wr_en         (write_fifo_len_en),
            .dout          (w_fifo_len_dout),
            .data_valid    (),
            .rd_en         (read_fifo_len_en),
            .rst           (i_rst),
            .empty         (w_fifo_len_empty),
            .full          (w_fifo_len_full),
            .rd_data_count (),
            .wr_data_count (),
            .almost_empty  (),
            .almost_full   ()
        );
        /*
FIFO_16X64 FIFO_16X64_LEN (
  .clk              (i_clk              ),      
  .din              (i_send_len         ),      
  .wr_en            (i_send_valid & !ri_send_valid), 
  .rd_en            (r_fifo_mac_rd_en & !r_fifo_mac_rd_en_1d), 
  .dout             (w_fifo_len_dout    ),   
  .full             (w_fifo_len_full    ),
  .empty            (w_fifo_len_empty   ) 
);
*/
CRC32_D8 CRC32_D8_u0(
  .i_clk            (i_clk              ),
  .i_rst            (r_crc_rst          ),
  .i_en             (r_crc_en           ),
  .i_data           (r_mac_data         ),
  .o_crc            (w_crc_result       )   
);

/***************assign****************/
assign o_mac_axi_data   = ro_mac_axi_data      ;
assign o_mac_axi_data_valid     = ro_mac_axi_data_valid     ;
assign o_tx_busy        = ro_mac_axi_data_valid     ;  
assign w_send_valid_pos = r_gap_cnt == (ri_ipg_timer - 1) && r_len_en_flag && i_mac_axi_data_ready;//发送数据信号上升沿
assign w_send_valid_neg = !ri_send_valid & ri_send_valid_1d;//发送数据信号下降沿
assign o_udp_ready      = ro_udp_ready      ;
//assign w_fra = i_fra_vld ? i_fra :  w_fra;
//assign w_smd = i_smd_vld ? i_smd :  w_smd;

assign write_fifo_len_en = i_send_valid & !ri_send_valid;
//assign r_w_fifo_len_dout =  read_fifo_len_en ? w_fifo_len_dout :i_pmac_send_len_val ? i_pmac_send_len :r_w_fifo_len_dout;
assign read_fifo_len_en  = r_fifo_mac_rd_en & !r_fifo_mac_rd_en_1d;
assign o_tx_frames_cnt = r_tx_frames_cnt;
assign o_tx_fragment_cnt = r_tx_fragment_cnt;
assign w_fifo_len = i_send_len * AXIS_DATA_WIDTH/8;


//assign r_crc             = i_send_last ? i_crc:r_crc;//防止数据刚从FIFO读完，下一组数据就来了，crc就更新了。
/***************always****************/

        //更改点由于存在组合逻辑循环因此改成reg类型//

always@(posedge i_clk,posedge i_rst) begin
    if (i_rst) begin
        r_len_en_flag <= 'd0;
    end
    else if(w_send_valid_pos) begin
        r_len_en_flag <= 'd0;
    end
    else if(write_fifo_len_en) begin
        r_len_en_flag <= 'd1;
    end
end

//assign w_fra = i_fra_vld ? i_fra :  w_fra;
always@(posedge i_clk,posedge i_rst)
begin
    if (i_rst) begin
    w_fra<= 'd0;
end
    else if(i_fra_vld )
        w_fra <= i_fra;
    else
        w_fra <= w_fra;
end


always@(posedge i_clk,posedge i_rst)
begin
    if (i_rst) begin
    test_flag<= 'd1;
end
    else if(i_fra_vld)
        test_flag <= !test_flag;
    else
        test_flag <= test_flag;
end

//assign w_smd = i_smd_vld ? i_smd :  w_smd;
always@(posedge i_clk,posedge i_rst)
begin
    if (i_rst) begin
        w_smd<= 'd0;
    end
    else if(i_smd_vld)
        w_smd <= i_smd ;//8'hd5
    else
        w_smd <= w_smd;
end

//assign r_w_fifo_len_dout =  read_fifo_len_en ? w_fifo_len_dout :i_pmac_send_len_val ? i_pmac_send_len :r_w_fifo_len_dout;
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_w_fifo_len_dout <= 'd1500;
    else if(read_fifo_len_en)
        r_w_fifo_len_dout <= w_fifo_len_dout;
    else if(i_pmac_send_len_val)
        r_w_fifo_len_dout <= i_pmac_send_len;
    else
        r_w_fifo_len_dout <= r_w_fifo_len_dout;
end
//assign r_crc = i_send_last ? i_crc:r_crc;//防止数据刚从FIFO读完，下一组数据就来了，crc就更新了。
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc <= 'd0;
    else if(i_send_last)
        r_crc = i_crc;
    else
        r_crc = r_crc;
end



always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_mac_rd_en_1d <= 'd0;
    else 
        r_fifo_mac_rd_en_1d <= r_fifo_mac_rd_en;
end



always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_mac <= P_TARTGET_MAC;
    else if(i_target_mac_valid)
        r_target_mac <= i_target_mac;
    else
        r_target_mac <= r_target_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_source_mac <= P_SOURCE_MAC ;
    else if(i_source_mac_valid)
        r_source_mac <= i_source_mac;
    else
        r_source_mac <= r_source_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_send_type  <= 'd0;
        ri_send_len   <= 'd0;
        ri_send_data  <= 'd0;
        ri_send_valid <= 'd0;
    end else if(i_send_valid) begin
        ri_send_type  <= i_send_type ;
        ri_send_len   <= i_send_len  ;
        ri_send_data  <= i_send_data ;
        ri_send_valid <= i_send_valid;
    end else begin
        ri_send_type  <= ri_send_type ;
        ri_send_len   <= ri_send_len  ;
        ri_send_data  <= 'd0 ;
        ri_send_valid <= 'd0;
    end
end

//组帧计数器，当检测到有信号需要发送信号的上升沿时开始计数，等到一组数据的最后一个crc发送完成后拉低，此时数据发送完成。
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_pkg_cnt <= 'd0;
    else if(r_crc_out_cnt == 3)
        r_mac_pkg_cnt <= 'd0;
    else if(w_send_valid_pos || r_mac_pkg_cnt)
        r_mac_pkg_cnt <= r_mac_pkg_cnt + 1;
    else 
        r_mac_pkg_cnt <= r_mac_pkg_cnt;
end
      
//组帧，前20字节根据输入数据组成，后边的为fifo的数据输出以及crc
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_data <= 'd0;
    else case(r_mac_pkg_cnt)
        0,1,2,3,4,5     :r_mac_data <= 8'h55;
        6               :r_mac_data <= (w_smd==SMD_C0||w_smd==SMD_C1||w_smd==SMD_C2||w_smd==SMD_C3)? w_smd : 8'h55;//当为SMD_C时第六字节为SMD编码
        7               :r_mac_data <= (w_smd==SMD_C0||w_smd==SMD_C1||w_smd==SMD_C2||w_smd==SMD_C3)? w_fra : w_smd;//为SMD_C时此处为帧计数器否则为SMD编码
        8               :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[47:40];
        9               :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[39:32];
        10              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[31:24];
        11              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[23:16];
        12              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[15: 8];
        13              :r_mac_data <= ri_send_type == 16'h0806 ? 8'hff : r_target_mac[7 : 0];
        14              :r_mac_data <= r_source_mac[47:40];
        15              :r_mac_data <= r_source_mac[39:32];
        16              :r_mac_data <= r_source_mac[31:24];
        17              :r_mac_data <= r_source_mac[23:16];
        18              :r_mac_data <= r_source_mac[15: 8];
        19              :r_mac_data <= r_source_mac[7 : 0];
        20              :r_mac_data <= ri_send_type[15: 8];
        21              :r_mac_data <= ri_send_type[7 : 0];
        default         :r_mac_data <= w_fifo_mac_dout;
    endcase
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_tx_fragment_cnt <= 'd0;
    else if(r_mac_pkg_cnt == 'd7 && (w_smd==SMD_C0||w_smd==SMD_C1||w_smd==SMD_C2||w_smd==SMD_C3))
        r_tx_fragment_cnt <= r_tx_fragment_cnt + 1;
    else 
        r_tx_fragment_cnt <= r_mac_data_valid;
end
//r_mac_data_valid，从组帧开始到FIFO数据都出来这一段数据有效信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_data_valid <= 'd0;
    else if(r_mac_data_cnt == r_w_fifo_len_dout && r_w_fifo_len_dout!='d0)
        r_mac_data_valid <= 'd0;
    else if(w_send_valid_pos)
        r_mac_data_valid <= 'd1;
    else 
        r_mac_data_valid <= r_mac_data_valid;
end

//记录从FIFO读出数据个数
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_data_cnt <= 'd0;
    else if(r_mac_data_cnt == r_w_fifo_len_dout && r_w_fifo_len_dout!='d0)
        r_mac_data_cnt <= 'd0;
    else if(r_fifo_mac_rd_en | r_mac_data_cnt)
        r_mac_data_cnt <= r_mac_data_cnt + 1;
    else 
        r_mac_data_cnt <= r_mac_data_cnt;
end

//读MAC数据fifo使能，前20个时钟在组帧头，20个之后开始读FIFO，当读完一组数据就停止。
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_mac_rd_en <= 'd0;
    else if((r_mac_data_cnt == r_w_fifo_len_dout - 1) && r_mac_data_cnt!='d0)
        r_fifo_mac_rd_en <= 'd0;
    else if(r_mac_pkg_cnt == 21)
        r_fifo_mac_rd_en <= 'd1;
    else 
        r_fifo_mac_rd_en <= r_fifo_mac_rd_en;
end

//crc模块的复位信号，当每次crc输出结束后复位，当到要做crc数据据到来时停止复位
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_rst <= 'd1;
    else if(r_mac_pkg_cnt == 8 )
        r_crc_rst <= 'd0;
    else if(r_crc_out_cnt == 3)
        r_crc_rst <= 'd1;
    else 
        r_crc_rst <= r_crc_rst;
end

//crc使能，数据开始时有效，数据结束时停止使能
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_en <= 'd0;
    else if(r_mac_data_cnt == r_w_fifo_len_dout && r_w_fifo_len_dout!='d0)
        r_crc_en <= 'd0;
    else if(r_mac_pkg_cnt == 8 )
        r_crc_en <= 'd1;
    else 
        r_crc_en <= r_crc_en;
end

//crc结果输出计数器，输入数据结束后开始输出数据，计数到3后输出完毕，停止输出。
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_out_cnt <= 'd0;
    else if(r_crc_out_cnt == 3)   
        r_crc_out_cnt <= 'd0;
    else if((!r_mac_data_valid && r_mac_data_valid_1d) || r_crc_out_cnt)
        r_crc_out_cnt <= r_crc_out_cnt + 1;
    else 
        r_crc_out_cnt <= r_crc_out_cnt;
end

//ro_GMII_data，输出的GMII信号，根据crc指示信号判断是crc还是mcrc。
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_axi_data <= 'd0;
    else if(r_mac_data_valid)
        ro_mac_axi_data <= r_mac_data;
    else case(r_crc_out_cnt)
        0       :ro_mac_axi_data <= w_crc_result[31: 24];
        1       :ro_mac_axi_data <= w_crc_result[23: 16];
        2       :    if (r_crc) begin
                        ro_mac_axi_data <= w_crc_result[15:8] ;
                        end 
                    else begin
                        ro_mac_axi_data <= w_crc_result[15:8]^8'b1111_1111;
                        end
        3       :    if (r_crc) begin
                        ro_mac_axi_data <= w_crc_result[7:0]  ;
                        end 
                    else begin
                        ro_mac_axi_data <= w_crc_result[7:0]^8'b1111_1111  ;
                        end
        default :ro_mac_axi_data <= 'd0;
    endcase   
end 

// ro_mac_axi_data_valid 
// ro_mac_axi_data_user  
// ri_mac_axi_data_ready 
// ro_mac_axi_data_last  
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_axi_data_last <= 'd0;
    else if(r_crc_out_cnt == 3 && o_mac_axi_data_valid)
        ro_mac_axi_data_last <= 'd1;
    else 
        ro_mac_axi_data_last <= 'd0;
end


//r_crc_out_cnt_1d crc输出计数器最后一拍打了一拍
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_out_cnt_1d <= 'd0;
    else if(r_crc_out_cnt == 3)
        r_crc_out_cnt_1d <= 'd1;
    else 
        r_crc_out_cnt_1d <= 'd0;
end

//ro_GMII_valid输出到phy的数据有效信号。从组帧的开始到crc结束
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_axi_data_valid <= 'd0;
    else if(r_crc_out_cnt_1d)
        ro_mac_axi_data_valid <= 'd0;
    else if(r_mac_data_valid)
        ro_mac_axi_data_valid <= 'd1;
    else    
        ro_mac_axi_data_valid <= ro_mac_axi_data_valid;
end 


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_tx_frames_cnt <= 'd0;
    else if(r_mac_data_valid & !r_mac_data_valid_1d)
        r_tx_frames_cnt <= r_tx_frames_cnt + 'd1;
end 


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cur_frame_cnt <= 'd0;
    else if(!ro_mac_axi_data_valid & ro_GMII_valid_1d)
        r_cur_frame_cnt <= 'd0;
    else if(r_crc_en & !r_crc_en_1d || r_cur_frame_cnt)
        r_cur_frame_cnt <= r_cur_frame_cnt + 'd1;
end 

//打拍

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_send_valid_1d    <= 'd0;
        r_mac_data_valid_1d <= 'd0;
        r_crc_en_1d <= 'd0;
        ri_ipg_timer_vld <= 'd0;
    end else begin
        ri_send_valid_1d    <= ri_send_valid   ;
        r_mac_data_valid_1d <= r_mac_data_valid;
        r_crc_en_1d <= r_crc_en;
        ri_ipg_timer_vld <= i_ipg_timer_vld;
    end
end
//打拍
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_GMII_valid_1d <= 'd0;       
    end else begin
        ro_GMII_valid_1d <= ro_mac_axi_data_valid;       
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_ipg_timer <= 'd12;
    end else if(ri_ipg_timer_vld)begin
        ri_ipg_timer <= i_ipg_timer;
    end
end



//ro_udp_ready 模块准备就绪 w_fifo_len_dout是发送的数据长度，从读FIFO的时候开始计时，FIFO里的数据读完了之后就可以再接受新的数据了
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_udp_ready <= 'd1;
    else if(i_send_valid)
        ro_udp_ready <= 'd0;
    else if(r_mac_data_cnt == r_w_fifo_len_dout  - 1)
        ro_udp_ready <= 'd1;
    else 
        ro_udp_ready <= ro_udp_ready;
end

//r_gap_cnt 以太网帧间隔
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_gap_cnt <= 'd1;
    else if(ro_mac_axi_data_valid)
        r_gap_cnt <= 'd0;
    else if(r_gap_cnt == ri_ipg_timer - 1)
        r_gap_cnt <= r_gap_cnt;
    else if((!ro_mac_axi_data_valid && ro_GMII_valid_1d) || r_gap_cnt)
        r_gap_cnt <= r_gap_cnt + 1;
    else 
        r_gap_cnt <= r_gap_cnt;
end


// //ila
// wire  [78:0] probe0;

// assign probe0 = {
// i_send_data  ,   
// i_send_valid  ,  
// o_mac_axi_data   ,  
// o_mac_axi_data_valid  ,  
// r_crc_en    ,
// r_mac_data  ,
// w_crc_result,
// r_crc,
// i_crc,

// i_smd    ,
// i_fra    ,
// i_smd_vld,
// i_fra_vld

// };                             

// ila_MAC your_instila_0 (
//     .clk(i_clk), // input wire clk


//     .probe0(probe0)
// );


endmodule
