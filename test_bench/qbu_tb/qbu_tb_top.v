`timescale 1ns / 1ns

module qbu_tb_top();

parameter AXIS_DATA_WIDTH = 8;
localparam  QUEUE_NUM       = 8;
// localparam  AXIS_DATA_WIDTH = 8;
reg clk,rst ;

always begin
    clk = 0;
    #4;
    clk = 1;
    #4;
end

initial begin
    rst = 1;
    #100@(posedge clk)rst <= 0;

end
wire                                     i_verify_enabled;
reg     [AXIS_DATA_WIDTH - 1:0]     	i_top_Emac_axis_tx_data 			;
reg     [15:0]                      	i_top_Emac_axis_tx_user 			;
wire     [(AXIS_DATA_WIDTH/8)-1:0]   	i_top_Emac_axis_tx_keep 			;
reg                                 	i_top_Emac_axis_tx_last 			;
reg                                 	i_top_Emac_axis_tx_valid			;
wire     [15:0]                      	i_top_Emac_axis_tx_type 			;

wire	[AXIS_DATA_WIDTH - 1:0]     	w_top_v_r_tx_axis_data 				;
wire	[15:0]                      	w_top_v_r_tx_axis_user 				;
wire	[(AXIS_DATA_WIDTH/8)-1:0]   	w_top_v_r_tx_axis_keep 				;
wire	                            	w_top_v_r_tx_axis_last 				;
wire	                            	w_top_v_r_tx_axis_valid				;
wire	[15:0]                      	w_top_v_r_tx_axis_type 				;

reg	 							    	i_V_rx_axis_valid 					;
reg	 							    	i_R_rx_axis_valid 					;
wire									o_verify_succ 	 					;
wire									o_verify_succ_val 					;

reg     [AXIS_DATA_WIDTH - 1:0]     	i_top_Pmac_axis_tx_data 			;
reg     [15:0]                      	i_top_Pmac_axis_tx_user 			;
wire     [(AXIS_DATA_WIDTH/8)-1:0]   	i_top_Pmac_axis_tx_keep 			;
reg                                 	i_top_Pmac_axis_tx_last 			;
reg                                 	i_top_Pmac_axis_tx_valid			;
wire     [15:0]                      	i_top_Pmac_axis_tx_type 			;
wire 	[7:0]							o_GMII_data  						;
wire 									o_GMII_valid 						;


wire 	[AXIS_DATA_WIDTH - 1:0]  		Data_o_R_rx_axis_data  	 			;
wire 	[15:0]                  		Data_o_R_rx_axis_user  	 			;
wire 	[(AXIS_DATA_WIDTH/8)-1:0]		Data_o_R_rx_axis_keep  	 			;
wire 									Data_o_R_rx_axis_last  	 			;
wire 									Data_o_R_rx_axis_valid 	 			;
wire 	[AXIS_DATA_WIDTH - 1:0]  		Data_o_V_rx_axis_data  	 			;
wire 	[15:0]                  		Data_o_V_rx_axis_user  	 			;
wire 	[(AXIS_DATA_WIDTH/8)-1:0]		Data_o_V_rx_axis_keep  	 			;
wire 									Data_o_V_rx_axis_last  	 			;
wire 									Data_o_V_rx_axis_valid 	 			;

wire    [AXIS_DATA_WIDTH - 1:0]         fast_ram_o_rx_axis_data 			;
wire    [15:0]                          fast_ram_o_rx_axis_user 			;
wire    [(AXIS_DATA_WIDTH/8)-1:0]       fast_ram_o_rx_axis_keep 			;
wire    						        fast_ram_o_rx_axis_last 			;
wire    						        fast_ram_o_rx_axis_valid			;

wire    [AXIS_DATA_WIDTH - 1:0]         Data_o_Emac_rx_axis_data            ;
wire    [15:0]                          Data_o_Emac_rx_axis_user            ;
wire    [(AXIS_DATA_WIDTH/8)-1:0]       Data_o_Emac_rx_axis_keep            ;
wire                                    Data_o_Emac_rx_axis_last            ;
wire                                    Data_o_Emac_rx_axis_valid           ;

// wire    [AXIS_DATA_WIDTH - 1:0]         i_R_rx_axis_data      ;
// wire    [15:0]                          i_R_rx_axis_user      ;
// wire    [(AXIS_DATA_WIDTH/8)-1:0]       i_R_rx_axis_keep      ;
// wire                                    i_R_rx_axis_last      ;
// wire                                    i_R_rx_axis_valid     ;
// wire                                    o_R_rx_axis_ready     ;
// wire    [AXIS_DATA_WIDTH - 1:0]         i_V_rx_axis_data      ;
// wire    [15:0]                          i_V_rx_axis_user      ;
// wire    [(AXIS_DATA_WIDTH/8)-1:0]       i_V_rx_axis_keep      ;
// wire                                    i_V_rx_axis_last      ;
// wire                                    i_V_rx_axis_valid     ;
// wire                                    o_V_rx_axis_ready     ;
// wire                                    i_verify_again     	  ;
// wire                                    i_verify_again_val    ;

wire    [AXIS_DATA_WIDTH - 1:0]     	o_mux_axis_data       ;
wire    [15:0]                      	o_mux_axis_user       ;
wire    [(AXIS_DATA_WIDTH/8)-1:0]   	o_mux_axis_keep       ;
wire                                	o_mux_axis_last       ;
wire                                	o_mux_axis_valid      ;
wire                                	o_mux_axis_ready      ;
wire    [7:0]                       	o_mux_smd 		      ;
wire                                    o_mux_smd_val         ;
// wire 									o_verify_succ 		  ;
// wire 									o_verify_succ_val 	  ;

reg i_qbu_verify_open	;

reg  [7 :0]                 r_axis_tx_data          ;
reg  [15:0]                 r_axis_tx_user          ;
reg                         r_axis_tx_last          ;
reg                         r_axis_tx_valid         ;
wire                         i_start_verify         ;

wire                        w_axis_tx_ready         ;


assign i_top_Emac_axis_tx_keep  = 1;
assign i_top_Emac_axis_tx_type  = 16'h0800;
assign i_top_Pmac_axis_tx_keep  = 1;
assign i_top_Pmac_axis_tx_type  = 16'h0800;


    // MCU bus signals
    reg         bus_we;
    reg         bus_rd;
    reg [7:0]   bus_addr;
    reg [15:0]  bus_wdata;
    wire[15:0]  bus_rdata;

    // QBU core inputs (drive from TB)
    reg         tb_i_rx_busy;
    reg         tb_i_tx_busy;
    reg [15:0]  tb_i_tx_fragment_cnt;
    reg [15:0]  tb_i_rx_fragment_cnt;
    reg         tb_i_rx_fragment_mismatch;
    reg         tb_i_preemptable_frame;
    reg         tb_i_preempt_active;
    reg [15:0]  tb_i_err_rx_crc_cnt;
    reg [15:0]  tb_i_err_rx_frame_cnt;
    reg [15:0]  tb_i_err_fragment_cnt;
    reg [15:0]  tb_i_err_verify_cnt;
    reg [15:0]  tb_i_tx_frames_cnt;
    reg [15:0]  tb_i_rx_frames_cnt;
    reg [15:0]  tb_i_preempt_success_cnt;
    reg [7:0]   tb_i_frag_next_rx;
    reg [7:0]   tb_i_frag_next_tx;
    reg [7:0]   tb_i_frame_seq;

    // Outputs to QBU core (ignored in TB)
    wire [7:0]  o_min_frag_size;
    wire [15:0] o_verify_timer;
    wire [7:0]  o_ipg_timer;
    wire        o_reset;
    wire        o_start_verify;
    wire        o_clear_verify;
    wire        o_verify_enabled;
    wire        o_preempt_enabled;
    wire [30:0] o_watchdog_timer;

    // Valid flags
    wire        o_reg_min_frag_size_valid;
    wire        o_reg_verify_timer_valid;
    wire        o_reg_ipg_timer_valid;
    wire        o_reg_verify_enabled_valid;
    wire        o_reg_preempt_enabled_valid;
    wire        o_reg_watchdog_timer_valid;

    // wire [QUEUE_NUM - 1 : 0]i_tx_mac_forward_info ;    
    // wire                i_tx_mac_forward_info_vld ;
 wire    [AXIS_DATA_WIDTH - 1:0]     i_mac_tx_axis_data          ;
 wire    [15:0]                      i_mac_tx_axis_user          ;
 wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_mac_tx_axis_keep          ;
 wire                                i_mac_tx_axis_last          ;
 wire                                i_mac_tx_axis_valid         ;
//  wire    [QUEUE_NUM - 1:0]           i_tx_mac_forward_info       ;
//  wire                                i_tx_mac_forward_info_vld   ;
 reg [QUEUE_NUM-1:0] i_tx_mac_forward_info       ;
reg                  i_tx_mac_forward_info_vld   ;


 wire    [AXIS_DATA_WIDTH - 1:0]     o_mac_axi_data              ;
wire     [(AXIS_DATA_WIDTH/8)-1:0]   o_mac_axi_data_keep         ;
wire                                 o_mac_axi_data_valid        ;
wire     [63:0]                      o_mac_axi_data_user         ;
wire                                 i_mac_axi_data_ready        ;
wire                                 o_mac_axi_data_last         ;

wire     [7:0]                       o_frag_next_tx              ;
wire                                 o_tx_timeout                ;
wire     [15:0]                      o_preempt_success_cnt       ;
wire                                 o_preempt_active            ;
wire                                 o_preemptable_frame         ;
wire     [15:0]                      o_tx_frames_cnt             ;
wire     [15:0]                      o_tx_fragment_cnt           ;
wire                                 o_tx_busy                   ;
wire     [19:0]                      i_watchdog_timer            ;
wire                                 i_watchdog_timer_vld        ;
wire     [ 7:0]                      i_min_frag_size             ;
wire                                 i_min_frag_size_vld         ;
wire     [ 7:0]                      i_ipg_timer                 ;
wire                                 i_ipg_timer_vld             ;

wire 							o_rx_busy             	         ;  
wire 	[15:0]   				o_rx_fragment_cnt     	         ;  
wire 							o_rx_fragment_mismatch	         ;  
wire 	[15:0]    				o_err_rx_crc_cnt      	         ;  
wire 	[15:0]    				o_err_rx_frame_cnt    	         ;  
wire 	[15:0]  				o_err_fragment_cnt    	         ;  
wire 	[15:0]  				o_rx_frames_cnt       	         ;  
wire 	[7:0]   				o_frag_next_rx        	         ;  
wire 	[7:0]    				o_frame_seq           	         ;  
// wire                            i_verify_enabled                 ;  
// wire                            i_start_verify                   ;  
wire                            i_clear_verify                   ;  
// wire                            o_verify_succ                    ;  
// wire                            o_verify_succ_val                ;  
wire    [15:0]                  i_verify_timer                   ;  
wire                            i_verify_timer_vld               ;  
wire    [15:0]                  o_err_verify_cnt                 ;  
wire                            o_preempt_enable                 ;

wire 	[AXIS_DATA_WIDTH - 1:0] o_qbu_rx_axis_data               ;
wire 	[15:0]                  o_qbu_rx_axis_user               ;
wire 	[(AXIS_DATA_WIDTH/8)-1:0]o_qbu_rx_axis_keep              ;
wire 							o_qbu_rx_axis_last               ;
wire 							o_qbu_rx_axis_valid              ;
wire                            i_qbu_rx_axis_ready              ;
wire o_mac_tx_axis_ready;
wire 							o_pmac_tx_axis_ready             ;
wire                            o_emac_tx_axis_ready             ;

// 总线信号声明
reg             qbu_reg_bus_we                   ;
reg             qbu_reg_bus_rd                   ;
reg  [7:0]      qbu_reg_bus_addr                 ;
reg  [15:0]     qbu_reg_bus_din                  ;
wire [15:0]     qbu_reg_bus_dout                 ;

// 例化
qbu_reg_list u_qbu_reg_list (
    .i_clk                  ( clk                             ),
    .i_rst_n                ( ~rst                            ),
    .i_qbu_bus_we           ( qbu_reg_bus_we                  ),
    .i_qbu_bus_addr         ( qbu_reg_bus_addr                ),
    .i_qbu_bus_din          ( qbu_reg_bus_din                 ),
    .i_qbu_bus_rd           ( qbu_reg_bus_rd                  ),
    .o_qbu_bus_dout         ( qbu_reg_bus_dout                ),
          
    .i_rx_busy              ( o_rx_busy                       ),
    .i_tx_busy              ( o_tx_busy                       ),
    .i_preemptable_frame    ( o_preemptable_frame             ),
    .i_preempt_active       ( o_preempt_active                ),
    .i_preempt_enable       ( o_preempt_enable                ),
    .i_tx_fragment_cnt      ( o_tx_fragment_cnt               ),
    .i_rx_fragment_cnt      ( o_rx_fragment_cnt               ),
    .i_rx_fragment_mismatch ( o_rx_fragment_mismatch          ),
    .i_err_rx_crc_cnt       ( o_err_rx_crc_cnt                ),
    .i_err_rx_frame_cnt     ( o_err_rx_frame_cnt              ),
    .i_err_fragment_cnt     ( o_err_fragment_cnt              ),
    .i_err_verify_cnt       ( o_err_verify_cnt                ),
    .i_tx_frames_cnt        ( o_tx_frames_cnt                 ),
    .i_rx_frames_cnt        ( o_rx_frames_cnt                 ),
    .i_preempt_success_cnt  ( o_preempt_success_cnt           ),
    .i_tx_timeout           ( o_tx_timeout                    ),
    .i_frag_next_rx         ( o_frag_next_rx                  ),
    .i_frag_next_tx         ( o_frag_next_tx                  ),
    .i_frame_seq            ( o_frame_seq                     ),

    .o_verify_enabled       ( i_verify_enabled                ),
    .o_min_frag_size        ( i_min_frag_size                 ),
    .o_min_frag_size_valid  ( i_min_frag_size_vld             ),
    .o_verify_timer         ( i_verify_timer                  ),
    .o_verify_timer_valid   ( i_verify_timer_vld              ),
    .o_ipg_timer            ( i_ipg_timer                     ),
    .o_ipg_timer_valid      ( i_ipg_timer_vld                 ),
    .o_reset                ( i_reset                         ),
    .o_start_verify         ( i_start_verify                  ),
    .o_clear_verify         ( i_clear_verify                  ),
    .o_watchdog_timer       ( i_watchdog_timer                ),
    .o_watchdog_timer_valid ( i_watchdog_timer_vld            )
);


    // Test sequence
    initial begin
        // Reset
        // rst = 1;
        bus_we = 0;
        bus_rd = 0;
        wait(rst == 0);
        // rst = 0;

        // Initialize inputs to DUT
        // tb_i_rx_busy              = 0;
        // tb_i_tx_busy              = 0;
        // tb_i_tx_fragment_cnt      = 16'h1234;
        // tb_i_rx_fragment_cnt      = 16'hABCD;
        // tb_i_rx_fragment_mismatch = 1;
        // tb_i_preemptable_frame    = 0;
        // tb_i_preempt_active       = 1;
        // tb_i_err_rx_crc_cnt       = 16'h0001;
        // tb_i_err_rx_frame_cnt     = 16'h0002;
        // tb_i_err_fragment_cnt     = 16'h0003;
        // tb_i_err_verify_cnt       = 16'h0004;
        // tb_i_tx_frames_cnt        = 16'h00AA;
        // tb_i_rx_frames_cnt        = 16'h00BB;
        // tb_i_preempt_success_cnt  = 16'h00CC;
        // tb_i_frag_next_rx         = 8'h11;
        // tb_i_frag_next_tx         = 8'h22;
        // tb_i_frame_seq            = 8'h33;

        // Write config registers
        write_reg(8'h01,16'h0001); // verify_enable
        write_reg(8'h0B,16'd0046); // min_frag_size
        write_reg(8'h0C,16'd10); // verify_timer
        write_reg(8'h0D,16'd12); // ipg_timer
        write_reg(8'h0E,16'h0); // reset
        write_reg(8'h0F,16'd2); //start_verify clear_verify
        write_reg(8'h13,16'he848); // watchdog L
        write_reg(8'h14,16'h1); // watchdog H
        // wait for outputs to be valid at DUT outputs
        #2000;

        // Now read back status registers
        read_reg(8'h00);
        read_reg(8'h01);
        read_reg(8'h02);
        read_reg(8'h03);
        read_reg(8'h04);
        read_reg(8'h05);
        read_reg(8'h06);
        read_reg(8'h07);
        read_reg(8'h08);
        read_reg(8'h0D);
        read_reg(8'h0E);
        read_reg(8'h0F);
        read_reg(8'h12);
        read_reg(8'h13);
        read_reg(8'h14);

        read_reg(8'h00);
        read_reg(8'h01);
        read_reg(8'h02);
        read_reg(8'h03);
        read_reg(8'h04);
        read_reg(8'h05);
        read_reg(8'h06);
        read_reg(8'h07);
        read_reg(8'h08);
        read_reg(8'h0D);
        read_reg(8'h0E);
        read_reg(8'h0F);
        read_reg(8'h12);
        read_reg(8'h13);
        read_reg(8'h14);
        #100;
        // $finish;
    end

    // Task: write register
    task write_reg(input [7:0] addr, input [15:0] data);
    begin
        @(posedge clk);
        qbu_reg_bus_addr  <= addr;
        qbu_reg_bus_din <= data;
        qbu_reg_bus_we    <= 1;
        qbu_reg_bus_rd    <= 0;
        @(posedge clk);
        qbu_reg_bus_we    <= 0;
    end
    endtask

    // Task: read register and display
    task read_reg(input [7:0] addr);
    begin
        @(posedge clk);
        qbu_reg_bus_addr <= addr;
        qbu_reg_bus_rd   <= 1;
        qbu_reg_bus_we   <= 0;
        @(posedge clk);
        $display("RTN [0x%0h] = 0x%0h", addr, qbu_reg_bus_dout);
        qbu_reg_bus_rd <= 0;
    end
    endtask


 
initial begin

	// #200
    // i_verify_enabled = 1; 
    // #10 @(posedge clk); 
    // i_start_verify = 1;
    // #200 @(posedge clk);
    // i_start_verify = 0;
    i_top_Emac_axis_tx_data  = 0;
	i_top_Emac_axis_tx_user  = 0;
	i_top_Emac_axis_tx_last  = 0; 
	i_top_Emac_axis_tx_valid = 0; 
    wait(u_qbu_send.inst_verified.o_verify_succ);
    repeat(54)@(posedge clk);
    data_input_Emac(12);
    repeat(56)@(posedge clk);
    data_input_Emac(59);
    // repeat(300)@(posedge clk);
    // data_input_Emac(121);
    // repeat(140)@(posedge clk);
    // data_input_Emac(124);
    // repeat(140)@(posedge clk);
    // data_input_Emac(126);
    // repeat(140)@(posedge clk);
    // data_input_Emac(64);
    // repeat(140)@(posedge clk);
    // data_input_Emac(46);

    repeat(56)@(posedge clk);
    data_input_Emac(70);
    repeat(160)@(posedge clk);
    data_input_Emac(50);
    repeat(160)@(posedge clk);
    data_input_Emac(800);
    repeat(100)@(posedge clk);
    data_input_Emac(500);
    repeat(300)@(posedge clk);
    data_input_Emac(200);

end

reg [7:0] ch = 0;


initial begin
    i_top_Pmac_axis_tx_data  = 0;
	i_top_Pmac_axis_tx_user  = 0;
	i_top_Pmac_axis_tx_last  = 0; 
	i_top_Pmac_axis_tx_valid = 0; 
    // #200
    // i_verify_enabled = 1; 
    // #10 @(posedge clk); 
    // i_start_verify = 1;
    // #200 @(posedge clk);
    // i_start_verify = 0;

    // i_top_Emac_axis_tx_data  = 0;
    // i_top_Emac_axis_tx_user  = 0;
    // i_top_Emac_axis_tx_last  = 0; 
    // i_top_Emac_axis_tx_valid = 0; 

    wait(u_qbu_send.inst_verified.o_verify_succ);
    repeat(10)@(posedge clk);
    data_input_Pmac(300);

    repeat(20)@(posedge clk);
    data_input_Pmac(600);

    repeat(20)@(posedge clk);
    data_input_Pmac(44);

    repeat(20)@(posedge clk);
    data_input_Pmac(50);

    repeat(20)@(posedge clk);
    data_input_Pmac(400);

    // repeat(20)@(posedge clk);
    // data_input_Pmac(400);

    // repeat(20)@(posedge clk);
    // data_input_Pmac(400);

    // repeat(20)@(posedge clk);
    // data_input_Pmac(400);

    
    // repeat(10)@(posedge clk);
    // data_input_Pmac(100);
    // repeat(10)@(posedge clk);
    // data_input(300);
    // repeat(10)@(posedge clk);
    // data_input(400);
    // repeat(10)@(posedge clk);
    // data_input(500);
    // repeat(10)@(posedge clk);


end



// Task to input data from PMAC, with channel selection from 0 to 7 in sequence
task data_input_Emac(input [15:0] len);
    integer i ;
begin
    // ch = 0;
    i_top_Emac_axis_tx_data  <= 'd0;
    i_top_Emac_axis_tx_user  <= 'd0;
    i_top_Emac_axis_tx_last  <= 'd0;
    i_top_Emac_axis_tx_valid <= 'd0;
    // i_tx_mac_forward_info    <= 'd0;
    // i_tx_mac_forward_info_vld<= 1'b0;
    @(posedge clk);
    wait(o_emac_tx_axis_ready);
    for(i = 0 ; i < len ; i = i + 1) begin
        i_top_Emac_axis_tx_data  <= i;
        i_top_Emac_axis_tx_user  <= len;
        if(i == len - 1)
            i_top_Emac_axis_tx_last  <= 1'b1;
        else
            i_top_Emac_axis_tx_last  <= 1'b0;
        i_top_Emac_axis_tx_valid <= 1'b1;

        // Set channel info: only one bit is 1, others are 0
        // i_tx_mac_forward_info    <= (1 << ch);
        // i_tx_mac_forward_info_vld<= 1'b1;

        @(posedge clk);

        // // Move to next channel after each packet
        // if(i_top_Pmac_axis_tx_last) begin
        //     ch = (ch + 1) % QUEUE_NUM;
        // end

    end
    i_top_Emac_axis_tx_data  <= 'd0;
    i_top_Emac_axis_tx_user  <= 'd0;
    i_top_Emac_axis_tx_last  <= 'd0;
    i_top_Emac_axis_tx_valid <= 'd0;
    // i_tx_mac_forward_info    <= 'd0;
    // i_tx_mac_forward_info_vld<= 1'b0;
    @(posedge clk);
end
endtask

task data_input_Pmac(input [15:0] len);
begin:data_input_task1
    integer i;
    i_top_Pmac_axis_tx_data  <= 'd0;
    i_top_Pmac_axis_tx_user  <= 'd0;
    i_top_Pmac_axis_tx_last  <= 'd0;
    i_top_Pmac_axis_tx_valid <= 'd0;
    @(posedge clk);
    wait(o_pmac_tx_axis_ready);
    for(i = 0 ; i < len ; i = i + 1)
    begin
        i_top_Pmac_axis_tx_data  <= i;
        i_top_Pmac_axis_tx_user  <= len;
        if(i == len - 1)i_top_Pmac_axis_tx_last  <= 'd1;
        else i_top_Pmac_axis_tx_last  <= 'd0;
        i_top_Pmac_axis_tx_valid <= 'd1;
        @(posedge clk);
    end

    i_top_Pmac_axis_tx_data  <= 'd0;
    i_top_Pmac_axis_tx_user  <= 'd0;
    i_top_Pmac_axis_tx_last  <= 'd0;
    i_top_Pmac_axis_tx_valid <= 'd0;
    @(posedge clk);
end
endtask


// top_send #(
// 		.AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
// 	) inst_top_send (
// 		.clk                      		(clk),
// 		.rst                      		(rst),
// 		.i_top_Emac_tx_axis_data  		(i_top_Emac_axis_tx_data ),
// 		.i_top_Emac_tx_axis_user  		(i_top_Emac_axis_tx_user ),
// 		.i_top_Emac_tx_axis_keep  		(i_top_Emac_axis_tx_keep ),
// 		.i_top_Emac_tx_axis_last  		(i_top_Emac_axis_tx_last ),
// 		.i_top_Emac_tx_axis_valid 		(i_top_Emac_axis_tx_valid),
// 		.i_top_Emac_tx_axis_type  		(i_top_Emac_axis_tx_type ),
// 		.i_V_rx_axis_valid        		(Data_o_V_rx_axis_valid),
// 		.i_R_rx_axis_valid        		(Data_o_R_rx_axis_valid),
// 		.o_verify_succ            		(o_verify_succ),
// 		.o_verify_succ_val        		(o_verify_succ_val),
// 		.i_top_Pmac_tx_axis_data  		(i_top_Pmac_axis_tx_data ),
// 		.i_top_Pmac_tx_axis_user  		(i_top_Pmac_axis_tx_user ),
// 		.i_top_Pmac_tx_axis_keep  		(i_top_Pmac_axis_tx_keep ),
// 		.i_top_Pmac_tx_axis_last  		(i_top_Pmac_axis_tx_last ),
// 		.i_top_Pmac_tx_axis_valid 		(i_top_Pmac_axis_tx_valid),
// 		.i_top_Pmac_tx_axis_type  		(i_top_Pmac_axis_tx_type ),
// 		.i_mux_axis_data    	   		(o_mux_axis_data    		),
// 		.i_mux_axis_user    	   		(o_mux_axis_user    		),
// 		.i_mux_axis_keep    	   		(o_mux_axis_keep    		),
// 		.i_mux_axis_last    	   		(o_mux_axis_last    		),
// 		.i_mux_axis_valid   	   		(o_mux_axis_valid   		),
// 		.i_mux_smd 		 	   		    (o_mux_smd 		   		  	),
// 		.i_mux_smd_val      	   		(o_mux_smd_val      		),
// 		.o_mux_axis_ready				(o_mux_axis_ready           ),
		
			
// 		.o_GMII_data              (o_GMII_data ),
// 		.o_GMII_valid             (o_GMII_valid)
// 	);





top_rec #(
    .DWIDTH                    (AXIS_DATA_WIDTH),
    .P_SOURCE_MAC              ({8'h00,8'h00,8'h00,8'hff,8'hff,8'hff})
) u_top_rec (
    .i_clk                     (clk                     ),
    .i_rst                     (rst                     ),

    .i_mac_axi_data            (o_mac_axi_data          ), 
    .i_mac_axi_data_keep       (o_mac_axi_data_keep     ), 
    .i_mac_axi_data_valid      (o_mac_axi_data_valid    ), 
    .o_mac_axi_data_ready      (i_mac_axi_data_ready    ), 
    .i_mac_axi_data_last       (o_mac_axi_data_last     ), 
 
    .o_qbu_verify_valid        (o_qbu_verify_valid      ),
    .o_qbu_response_valid      (o_qbu_response_valid    ),

    .o_qbu_rx_axis_data        (o_qbu_rx_axis_data      ),
    .o_qbu_rx_axis_user        (o_qbu_rx_axis_user      ),
    .o_qbu_rx_axis_keep        (o_qbu_rx_axis_keep      ),
    .o_qbu_rx_axis_last        (o_qbu_rx_axis_last      ),
    .o_qbu_rx_axis_valid       (o_qbu_rx_axis_valid     ),
    .i_qbu_rx_axis_ready       (1     ),
    
    .o_rx_busy                 (o_rx_busy               ), 
    .o_rx_fragment_cnt         (o_rx_fragment_cnt       ), 
    .o_rx_fragment_mismatch    (o_rx_fragment_mismatch  ), 
    .o_err_rx_crc_cnt          (o_err_rx_crc_cnt        ), 
    .o_err_rx_frame_cnt        (o_err_rx_frame_cnt      ), 
    .o_err_fragment_cnt        (o_err_fragment_cnt      ), 
    .o_rx_frames_cnt           (o_rx_frames_cnt         ), 
    .o_frag_next_rx            (o_frag_next_rx          ), 
    .o_frame_seq               (o_frame_seq             )  
 
    
);

qbu_send #(
    .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
    .QUEUE_NUM(8)
) u_qbu_send (
    .i_clk                       (clk                       ),
    .i_rst                       (rst                       ),
    //pmac通道数据
    .i_pmac_tx_axis_data         (i_top_Pmac_axis_tx_data   ), 
    .i_pmac_tx_axis_user         (i_top_Pmac_axis_tx_user   ), 
    .i_pmac_tx_axis_keep         (i_top_Pmac_axis_tx_keep   ), 
    .i_pmac_tx_axis_last         (i_top_Pmac_axis_tx_last   ), 
    .i_pmac_tx_axis_valid        (i_top_Pmac_axis_tx_valid  ), 
    .i_pmac_ethertype            ('h8086                    ),
    .o_pmac_tx_axis_ready        (o_pmac_tx_axis_ready       ),
    //emac通道数据
    .i_emac_tx_axis_data         (i_top_Emac_axis_tx_data   ), 
    .i_emac_tx_axis_user         (i_top_Emac_axis_tx_user   ), 
    .i_emac_tx_axis_keep         (i_top_Emac_axis_tx_keep   ), 
    .i_emac_tx_axis_last         (i_top_Emac_axis_tx_last   ), 
    .i_emac_tx_axis_valid        (i_top_Emac_axis_tx_valid  ), 
    .i_emac_ethertype            ('h8086                    ),
    .o_emac_tx_axis_ready        (o_emac_tx_axis_ready       ),

    // .i_emac_channel_cfg         (8'b0010_1100               ),
    // .i_tx_mac_forward_info      (i_tx_mac_forward_info      ),
    // .i_tx_mac_forward_info_vld  (i_tx_mac_forward_info_vld  ),
 
    .i_qbu_verify_valid         (o_qbu_verify_valid         ),
    .i_qbu_response_valid       (o_qbu_response_valid       ),
 
    .o_mac_axi_data             (o_mac_axi_data             ),
    .o_mac_axi_data_keep        (o_mac_axi_data_keep        ),
    .o_mac_axi_data_valid       (o_mac_axi_data_valid       ),
    .o_mac_axi_data_user        (o_mac_axi_data_user        ),
    .i_mac_axi_data_ready       (i_mac_axi_data_ready       ),
    .o_mac_axi_data_last        (o_mac_axi_data_last        ),
 
    .o_frag_next_tx             (o_frag_next_tx             ),
    .o_tx_timeout               (o_tx_timeout               ),
    .o_preempt_success_cnt      (o_preempt_success_cnt      ),
    .o_preempt_active           (o_preempt_active           ),
    .o_preemptable_frame        (o_preemptable_frame        ),
    .o_tx_frames_cnt            (o_tx_frames_cnt            ),
    .o_tx_fragment_cnt          (o_tx_fragment_cnt          ),
    .o_tx_busy                  (o_tx_busy                  ),
    .i_watchdog_timer           (i_watchdog_timer           ),
    .i_watchdog_timer_vld       (i_watchdog_timer_vld       ),
    .i_min_frag_size            (i_min_frag_size            ),
    .i_min_frag_size_vld        (i_min_frag_size_vld        ),
    .i_ipg_timer                (i_ipg_timer                ),
    .i_ipg_timer_vld            (i_ipg_timer_vld            ),

    .i_verify_enabled           (i_verify_enabled           ),
    .i_start_verify             (i_start_verify             ),
    .i_clear_verify             (0                          ),
    .o_verify_succ              (o_verify_succ              ),
    .o_verify_succ_val          (o_verify_succ_val          ),
    .i_verify_timer             (i_verify_timer             ),
    .i_verify_timer_vld         (i_verify_timer_vld         ),
    .o_err_verify_cnt           (o_err_verify_cnt           ),
    .o_preempt_enable           (o_preempt_enable           ) 
);

// axis_to_gmii #(
//     .AXIS_DATA_WIDTH (AXIS_DATA_WIDTH)
// ) u_axis_to_gmii (
//     .clk_125                (clk                  ),
//     .sys_rst_n              (~rst                 ),
//     // GMII to AXIS (接收)
//     .o_mac_axi_data         (), // 需要连接
//     .o_mac_axi_data_keep    (), // 需要连接
//     .o_mac_axi_data_valid   (), // 需要连接
//     .i_mac_axi_data_ready   (), // 需要连接
//     .o_mac_axi_data_last    (), // 需要连接
//     // AXIS to GMII (发送)
//     .i_mac_axi_data         (), // 需要连接
//     .i_mac_axi_data_keep    (), // 需要连接
//     .i_mac_axi_data_valid   (), // 需要连接
//     .o_mac_axi_data_ready   (), // 需要连接
//     .i_mac_axi_data_last    (), // 需要连接
//     // 原始 GMII 数据接口
//     .o_qbu_din              (), // 需要连接
//     .o_qbu_dvld             (), // 需要连接
//     .i_qbu_data             (), // 需要连接
//     .i_qbu_valid            ()  // 需要连接
// );

// 	fifo_to_qbu   	#(
//     .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
// )   inst_fifo_to_qbu(
//     .clk_125                            (clk                            ),
//     .rst                                (~rst                           ),   
// 	.gmii_rx_clk 						(gmii_rx_clk     				),    
// 	.gmii_tx_clk 						(gmii_tx_clk     				),        
// 	.o_gmii_tx_en						(o_gmii_tx_en  					),  	
// 	.o_gmii_txd  						(o_gmii_txd    					),  	
// 	.i_gmii_rx_dv						(i_gmii_rx_dv  					),  	
// 	.i_gmii_rxd  						(i_gmii_rxd    					),  	
// 	.o_qbu_din 							(o_qbu_din 						),	
// 	.o_qbu_dvld 						(o_qbu_dvld 					),		
// 	.i_qbu_data  						(i_qbu_data  					),	
// 	.i_qbu_valid 						(i_qbu_valid 					)	
        
//     );

// respon  #(
//           .AXIS_DATA_WIDTH  (AXIS_DATA_WIDTH)
//     )
//     inst_verified(
//          .clk                      		( clk                       ),
//          .rst                      		( rst                       ),
//          .i_verify_enabled              (i_verify_enabled           ),
//          .i_start_verify                (i_start_verify             ),
//          .i_clear_verify                (o_clear_verify             ),
//          .i_R_rx_axis_data   	   		(Data_o_R_rx_axis_data  	),
// 		 .i_R_rx_axis_user   	   		(Data_o_R_rx_axis_user  	),
// 		 .i_R_rx_axis_keep   	   		(Data_o_R_rx_axis_keep  	),
// 		 .i_R_rx_axis_last   	   		(Data_o_R_rx_axis_last  	),
// 		 .i_R_rx_axis_valid  	   		(Data_o_R_rx_axis_valid 	),
// 		 .o_R_rx_axis_ready  	   		(o_R_rx_axis_ready  		),
// 		 .i_V_rx_axis_data   	   		(Data_o_V_rx_axis_data 	  	),
// 		 .i_V_rx_axis_user   	   		(Data_o_V_rx_axis_user 	  	),
// 		 .i_V_rx_axis_keep   	   		(Data_o_V_rx_axis_keep 	  	),
// 		 .i_V_rx_axis_last   	   		(Data_o_V_rx_axis_last 	  	),
// 		 .i_V_rx_axis_valid  	   		(Data_o_V_rx_axis_valid	  	),
// 		 .o_V_rx_axis_ready  	   		(o_V_rx_axis_ready  		),
// 		 // .i_verify_again     	   		(i_verify_again     		),
// 		 // .i_verify_again_val 	   		(i_verify_again_val 		),
// 		 .o_mux_axis_data    	   		(o_mux_axis_data    		),
// 		 .o_mux_axis_user    	   		(o_mux_axis_user    		),
// 		 .o_mux_axis_keep    	   		(o_mux_axis_keep    		),
// 		 .o_mux_axis_last    	   		(o_mux_axis_last    		),
// 		 .o_mux_axis_valid   	   		(o_mux_axis_valid   		),
// 		 .i_mux_axis_ready   	   		(o_mux_axis_ready   		),
// 		 .o_mux_smd 		 	   		(o_mux_smd 		   		  	), 
// 		 .o_mux_smd_val      	   		(o_mux_smd_val      		),
// 		 .o_verify_succ 	 	   		(o_verify_succ 		  	  	),
// 		 .o_verify_succ_val  	   		(o_verify_succ_val  		),
//          .o_err_verify_cnt              (),   
//          .o_preempt_enable              (           o_preempt_enabled)   
// 		 // .i_qbu_verify_open				(i_qbu_verify_open			)  
// );

// top_rec  #(
//         .DWIDTH(AXIS_DATA_WIDTH)
//     ) inst_top_rec (
// 	.clk                       (clk),
// 	.rst                       (rst),
// 	.p_i_din                   (o_GMII_data ),// (o_GMII_data),
// 	.p_i_dvld                  (o_GMII_valid),// (o_GMII_valid),
// 	.p_i_source_mac            (p_i_source_mac),
// 	.p_i_source_mac_valid      (p_i_source_mac_valid),
// 	.Data_o_Emac_rx_axis_data  (Data_o_Emac_rx_axis_data ),
// 	.Data_o_Emac_rx_axis_user  (Data_o_Emac_rx_axis_user ),
// 	.Data_o_Emac_rx_axis_keep  (Data_o_Emac_rx_axis_keep ),
// 	.Data_o_Emac_rx_axis_last  (Data_o_Emac_rx_axis_last ),
// 	.Data_o_Emac_rx_axis_valid (Data_o_Emac_rx_axis_valid),
// 	.Data_o_R_rx_axis_data     (Data_o_R_rx_axis_data	),
// 	.Data_o_R_rx_axis_user     (Data_o_R_rx_axis_user	),
// 	.Data_o_R_rx_axis_keep     (Data_o_R_rx_axis_keep	),
// 	.Data_o_R_rx_axis_last     (Data_o_R_rx_axis_last	),
// 	.Data_o_R_rx_axis_valid    (Data_o_R_rx_axis_valid	),
// 	.Data_o_V_rx_axis_data     (Data_o_V_rx_axis_data),
// 	.Data_o_V_rx_axis_user     (Data_o_V_rx_axis_user),
// 	.Data_o_V_rx_axis_keep     (Data_o_V_rx_axis_keep),
// 	.Data_o_V_rx_axis_last     (Data_o_V_rx_axis_last),
// 	.Data_o_V_rx_axis_valid    (Data_o_V_rx_axis_valid),
// 	.fast_ram_o_rx_axis_data   (fast_ram_o_rx_axis_data ),
// 	.fast_ram_o_rx_axis_user   (fast_ram_o_rx_axis_user ),
// 	.fast_ram_o_rx_axis_keep   (fast_ram_o_rx_axis_keep ),
// 	.fast_ram_o_rx_axis_last   (fast_ram_o_rx_axis_last ),
// 	.fast_ram_o_rx_axis_valid  (fast_ram_o_rx_axis_valid)
// );
endmodule
