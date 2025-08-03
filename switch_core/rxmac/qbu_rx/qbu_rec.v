`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/16 09:40:20
// Design Name: 
// Module Name: top_rec
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


module qbu_rec#(
    parameter   DWIDTH          = 'd8                                   ,
                P_SOURCE_MAC    = {8'h00,8'h00,8'h00,8'hff,8'hff,8'hff} 
)(
    input       wire                        	i_clk                     ,
    input       wire                        	i_rst                     ,

	input       wire    [DWIDTH-1:0]            i_mac_axi_data            ,
	input       wire    [(DWIDTH/8)-1:0]        i_mac_axi_data_keep       ,
	input       wire                            i_mac_axi_data_valid      ,
	output      wire                            o_mac_axi_data_ready      ,
	input       wire                            i_mac_axi_data_last       ,

	output      wire                        	o_qbu_verify_valid        ,
    output      wire                        	o_qbu_response_valid      ,

    output 		wire 	[DWIDTH - 1:0]  		o_qbu_rx_axis_data        ,
	output 		wire 	[15:0]                  o_qbu_rx_axis_user        ,
	output 		wire 	[(DWIDTH/8)-1:0]		o_qbu_rx_axis_keep        ,
	output 		wire 							o_qbu_rx_axis_last        ,
	output 		wire 							o_qbu_rx_axis_valid       ,
    input       wire                            i_qbu_rx_axis_ready       ,
	//时间戳信号
	output     wire                             o_mac_time_irq            , // 打时间戳中断信号
    output     wire     [7:0]                   o_mac_frame_seq           , // 帧序列号
    output     wire     [7:0]                   o_timestamp_addr          , // 打时间戳存储的 RAM 地址

	//寄存器接口
	output 		wire 							o_rx_busy             	  ,
	output 		wire 	[15:0]   				o_rx_fragment_cnt     	  ,
	output 		wire 							o_rx_fragment_mismatch	  ,
	output 		wire 	[15:0]    				o_err_rx_crc_cnt      	  ,
	output 		wire 	[15:0]    				o_err_rx_frame_cnt    	  ,
	output 		wire 	[15:0]  				o_err_fragment_cnt    	  ,
	output 		wire 	[15:0]  				o_rx_frames_cnt       	  ,
	output 		wire 	[7:0]   				o_frag_next_rx        	  ,
	output 		wire 	[7:0]    				o_frame_seq           	  


);
             	
           
wire  	[47:0]					p_o_target_mac        			;
wire  							p_o_target_mac_valid  			;
wire  	[47:0]					p_o_source_mac        			;
wire  							p_o_source_mac_valid  			;
wire  	[15:0]					p_o_post_type         			;
wire  	      					p_o_post_type_valid   			;
wire  	[7:0] 					p_o_SMD_type          			;
wire  	      					p_o_SMD_type_vld      			;
wire  	[7:0] 					p_o_frag_cnt          			;
wire  	      					p_o_frag_cnt_vld      			;
wire  	[1:0] 					p_o_crc_vld           			;
wire  							p_o_crc_err           			;
wire  	[DWIDTH - 1:0] 			p_o_post_data         			;
wire  	      					p_o_post_last         			;
wire  	[15:0]					p_o_post_data_len     			;
wire  							p_o_post_data_len_vld 			;
wire  							p_o_post_data_vld     			;
wire 	[DWIDTH - 1:0]  		ram_o_Data_diver_axis_data  	;
wire 	[27:0]                  ram_o_Data_diver_axis_user  	;
wire 	[(DWIDTH/8)-1:0]		ram_o_Data_diver_axis_keep  	;
wire 							ram_o_Data_diver_axis_last  	;
wire 							ram_o_Data_diver_axis_valid 	;

wire 							Data_o_Sgram_rx_axis_ready 		;

wire 	[DWIDTH - 1:0]  		Data_o_Pmac_rx_axis_data  	 	;
wire 	[15:0]                  Data_o_Pmac_rx_axis_user  	 	;
wire 	[(DWIDTH/8)-1:0]		Data_o_Pmac_rx_axis_keep  	 	;
wire 							Data_o_Pmac_rx_axis_last  	 	;
wire 							Data_o_Pmac_rx_axis_valid 	 	;

wire 							fram_o_rx_axis_ready 			;	
wire 	[DWIDTH - 1:0]  		fram_o_sgram_rx_axis_data  		;
wire 	[15:0]                  fram_o_sgram_rx_axis_user  		;
wire 	[(DWIDTH/8)-1:0]		fram_o_sgram_rx_axis_keep  		;
wire 							fram_o_sgram_rx_axis_last  		;
wire 							fram_o_sgram_rx_axis_valid 		;						
wire 							fram_o_data_start    			;
wire 							fram_o_data_end      			;
wire 							fram_o_data_complete 			;
wire 							fast_ram_o_fram_rx_axis_ready 	;
wire     [11:0]					w_data_len						;
wire    [DWIDTH - 1:0]          Data_o_R_rx_axis_data         	;
wire    [15:0]                  Data_o_R_rx_axis_user         	;
wire    [(DWIDTH/8)-1:0]        Data_o_R_rx_axis_keep         	;
wire                            Data_o_R_rx_axis_last         	;
wire                            Data_o_R_rx_axis_valid        	;
wire                            o_R_rx_axis_ready      			;
wire    [DWIDTH - 1:0]          Data_o_V_rx_axis_data         	;
wire    [15:0]                  Data_o_V_rx_axis_user         	;
wire    [(DWIDTH/8)-1:0]        Data_o_V_rx_axis_keep         	;
wire                            Data_o_V_rx_axis_last         	;
wire                            Data_o_V_rx_axis_valid        	;
wire                            o_V_rx_axis_ready        		;
wire 	[DWIDTH - 1:0]  		fast_ram_o_rx_axis_data 		;     
wire 	[15:0]                  fast_ram_o_rx_axis_user 		;     
wire 	[(DWIDTH/8)-1:0]		fast_ram_o_rx_axis_keep 		;     
wire 							fast_ram_o_rx_axis_last 		;     
wire 							fast_ram_o_rx_axis_valid		;   
wire 	[DWIDTH - 1:0]  		Data_o_Emac_rx_axis_data  		;   
wire 	[15:0]                  Data_o_Emac_rx_axis_user  		;   
wire 	[(DWIDTH/8)-1:0]		Data_o_Emac_rx_axis_keep  		;   
wire 							Data_o_Emac_rx_axis_last  		;   
wire 							Data_o_Emac_rx_axis_valid 		;    

wire 	[DWIDTH - 1:0]  		o_emac_rx_axis_data  			;
wire 	[15:0]                  o_emac_rx_axis_user  			;
wire 	[(DWIDTH/8)-1:0]		o_emac_rx_axis_keep  			;
wire 							o_emac_rx_axis_last  			;
wire 							o_emac_rx_axis_valid 			;
wire 							i_emac_rx_axis_ready 			;

 P_detection #(
    .DWIDTH  								(DWIDTH		 		  ),
    .P_SOURCE_MAC 						    (P_SOURCE_MAC		  )
) inst_p_detection (				
	.i_clk                  				(i_clk                ),
	.i_rst                  				(i_rst                ),
	//由接口层输入数据				
	.i_mac_axi_data         				(i_mac_axi_data       ),
	.i_mac_axi_data_keep    				(i_mac_axi_data_keep  ),
	.i_mac_axi_data_valid   				(i_mac_axi_data_valid ),
	.o_mac_axi_data_ready   				(o_mac_axi_data_ready ),
	.i_mac_axi_data_last    				(i_mac_axi_data_last  ),
	//输出解析的报文信息				
    .o_target_mac           				(p_o_target_mac       ),
    .o_target_mac_valid     				(p_o_target_mac_valid ),
    .o_source_mac           				(p_o_source_mac       ),
    .o_source_mac_valid     				(p_o_source_mac_valid ),
    .o_post_type            				(p_o_post_type        ),
    .o_post_type_valid      				(p_o_post_type_valid  ),
    .o_SMD_type             				(p_o_SMD_type         ),
    .o_SMD_type_vld         				(p_o_SMD_type_vld     ),
    .o_frag_cnt             				(p_o_frag_cnt         ),
    .o_frag_cnt_vld         				(p_o_frag_cnt_vld     ),
    .o_crc_vld              				(p_o_crc_vld          ),
    .o_crc_err              				(p_o_crc_err          ),
    .o_post_data            				(p_o_post_data        ),
    .o_post_last            				(p_o_post_last        ),
    .o_post_data_len        				(p_o_post_data_len    ),
    .o_post_data_len_vld    				(p_o_post_data_len_vld),
    .o_post_data_vld        				(p_o_post_data_vld    ),
	//输出的寄存器信息				
    .o_rx_frames_cnt 						(o_rx_frames_cnt 	  ),
	.o_err_rx_crc_cnt						(o_err_rx_crc_cnt	  ),
	.o_rx_busy       						(o_rx_busy       	  )

    );

 ram_fifo #(
    .DWIDTH  								(DWIDTH		 				),
    .P_SOURCE_MAC   						(P_SOURCE_MAC				)
) inst_ram_fifo(						
	.i_clk									(i_clk						),
 	.i_rst									(i_rst						),	
	//报文的dMAC和sMAC
 	.i_target_mac           				(p_o_target_mac 			),
	.i_target_mac_valid     				(p_o_target_mac_valid		),
	.i_source_mac           				(p_o_source_mac      		),
	.i_source_mac_valid     				(p_o_source_mac_valid		),
	//p_detection模块输入的qbu报文信息，存储报文等待拼接
	.i_post_type            				(p_o_post_type       		),
	.i_post_type_valid      				(p_o_post_type_valid    	),
	.i_SMD_type             				(p_o_SMD_type        		),
	.i_SMD_type_vld         				(p_o_SMD_type_vld    		),
	.i_frag_cnt             				(p_o_frag_cnt        		),
	.i_frag_cnt_vld         				(p_o_frag_cnt_vld     		),
	.i_crc_vld              				(p_o_crc_vld          		),
	.i_crc_err              				(p_o_crc_err     			),
	//qbu报文数据
	.i_post_data            				(p_o_post_data        		),
	.i_post_last            				(p_o_post_last        		),
	.i_post_data_len        				(p_o_post_data_len    		),
	.i_post_data_len_vld    				(p_o_post_data_len_vld		),
	.i_post_data_vld        				(p_o_post_data_vld      	),
	//输出axi接口数据，给Data_dirver模块分类过滤
	.o_Data_diver_axis_data 				(ram_o_Data_diver_axis_data ),
	.o_Data_diver_axis_user 				(ram_o_Data_diver_axis_user ),
	.o_Data_diver_axis_keep 				(ram_o_Data_diver_axis_keep ),
	.o_Data_diver_axis_last 				(ram_o_Data_diver_axis_last ),
	.o_Data_diver_axis_valid				(ram_o_Data_diver_axis_valid),
	.o_Data_len								(w_data_len					),
	.i_Data_diver_axis_ready				(Data_o_Sgram_rx_axis_ready)
 	);


Data_diver #(
    .DWIDTH  								(DWIDTH						)
) inst_Data_diver (						
	.i_clk									(i_clk 						),
 	.i_rst									(i_rst 						),	
	//ram模块输出的axi源数据，到本模块进行分类
 	.i_Sgram_rx_axis_data  					(ram_o_Data_diver_axis_data ),
	.i_Sgram_rx_axis_user  					(ram_o_Data_diver_axis_user ), //携带长度信息
	.i_Sgram_rx_axis_keep  					(ram_o_Data_diver_axis_keep ),
	.i_Sgram_rx_axis_last  					(ram_o_Data_diver_axis_last ),
	.i_Sgram_rx_axis_valid 					(ram_o_Data_diver_axis_valid),
	.i_data_len								(w_data_len					),
	.o_Sgram_rx_axis_ready 					(Data_o_Sgram_rx_axis_ready ),
	//EMAC数据
	.o_Emac_rx_axis_data   					(Data_o_Emac_rx_axis_data  	),
	.o_Emac_rx_axis_user   					(Data_o_Emac_rx_axis_user  	), //携带长度信息
	.o_Emac_rx_axis_keep   					(Data_o_Emac_rx_axis_keep  	),
	.o_Emac_rx_axis_last   					(Data_o_Emac_rx_axis_last  	),
	.o_Emac_rx_axis_valid  					(Data_o_Emac_rx_axis_valid 	),
	.i_Emac_rx_axis_ready  					(o_emac_axis_ready 			),	
	//PMAC数据
	.o_Pmac_rx_axis_data   					(Data_o_Pmac_rx_axis_data  	),
	.o_Pmac_rx_axis_user   					(Data_o_Pmac_rx_axis_user  	), //携带长度信息
	.o_Pmac_rx_axis_keep   					(Data_o_Pmac_rx_axis_keep  	),
	.o_Pmac_rx_axis_last   					(Data_o_Pmac_rx_axis_last  	),
	.o_Pmac_rx_axis_valid  					(Data_o_Pmac_rx_axis_valid 	),
	.i_Pmac_rx_axis_ready  					(fram_o_rx_axis_ready		),	
	//Verify模块数据
	.o_R_rx_axis_data      					(Data_o_R_rx_axis_data     	),
	.o_R_rx_axis_user      					(Data_o_R_rx_axis_user     	), //携带长度信息
	.o_R_rx_axis_keep      					(Data_o_R_rx_axis_keep     	),
	.o_R_rx_axis_last      					(Data_o_R_rx_axis_last     	),
	.o_R_rx_axis_valid     					(Data_o_R_rx_axis_valid    	),
	.i_R_rx_axis_ready     					(o_R_rx_axis_ready          ),

	.o_V_rx_axis_data      					(Data_o_V_rx_axis_data     	),
	.o_V_rx_axis_user      					(Data_o_V_rx_axis_user     	), //携带长度信息
	.o_V_rx_axis_keep      					(Data_o_V_rx_axis_keep     	),
	.o_V_rx_axis_last      					(Data_o_V_rx_axis_last     	),
	.o_V_rx_axis_valid     					(Data_o_V_rx_axis_valid    	),
	.i_V_rx_axis_ready     					(o_V_rx_axis_ready   	   	)

 	);

respon #(
    .AXIS_DATA_WIDTH                        (DWIDTH                     )
) inst_respon (                             
    .i_clk                                  (i_clk                      ),
    .i_rst                                  (i_rst                      ),
    // R AXIS
    .i_R_rx_axis_data                       (Data_o_R_rx_axis_data      ),
    .i_R_rx_axis_user                       (Data_o_R_rx_axis_user      ),
    .i_R_rx_axis_keep                       (Data_o_R_rx_axis_keep      ),
    .i_R_rx_axis_last                       (Data_o_R_rx_axis_last      ),
    .i_R_rx_axis_valid                      (Data_o_R_rx_axis_valid     ),
    .o_R_rx_axis_ready                      (o_R_rx_axis_ready          ),
    // V AXIS
    .i_V_rx_axis_data                       (Data_o_V_rx_axis_data      ),
    .i_V_rx_axis_user                       (Data_o_V_rx_axis_user      ),
    .i_V_rx_axis_keep                       (Data_o_V_rx_axis_keep      ),
    .i_V_rx_axis_last                       (Data_o_V_rx_axis_last      ),
    .i_V_rx_axis_valid                      (Data_o_V_rx_axis_valid     ),
    .o_V_rx_axis_ready                      (o_V_rx_axis_ready          ),

	.o_qbu_verify_valid  					(o_qbu_verify_valid  		),
	.o_qbu_response_valid					(o_qbu_response_valid		),
    //寄存器信号
    .i_verify_enabled                       (i_verify_enabled           ),
    .i_start_verify                         (i_start_verify             ),
    .i_clear_verify                         (i_clear_verify             ),
    .o_verify_succ                          (o_verify_succ              ),
    .o_verify_succ_val                      (o_verify_succ_val          ),
    .i_verify_timer                         (i_verify_timer             ),
    .i_verify_timer_vld                     (i_verify_timer_vld         ),
    .o_err_verify_cnt                       (o_err_verify_cnt           ),
    .o_preempt_enable                       (o_preempt_enable           )
);

	fram #(
    .DWIDTH  								(DWIDTH						  )
) inst_fram (								
	.i_clk									(i_clk 						  ),
 	.i_rst									(i_rst 						  ),
	//上级模块pMAC输入数据
 	.i_rx_axis_data 						(Data_o_Pmac_rx_axis_data  	  ),								
	.i_rx_axis_user 						(Data_o_Pmac_rx_axis_user  	  ),								
	.i_rx_axis_keep 						(Data_o_Pmac_rx_axis_keep  	  ),		
	.i_rx_axis_last 						(Data_o_Pmac_rx_axis_last  	  ),		
	.i_rx_axis_valid 						(Data_o_Pmac_rx_axis_valid 	  ),			
	.o_rx_axis_ready 						(fram_o_rx_axis_ready 		  ),	
    //输出本次解析的pMAC数据，可能不是完整的pMAC数据，输出到下一级缓存
	.o_sgram_rx_axis_data 					(fram_o_sgram_rx_axis_data    ),			
	.o_sgram_rx_axis_user 					(fram_o_sgram_rx_axis_user    ),			
	.o_sgram_rx_axis_keep 					(fram_o_sgram_rx_axis_keep    ),			
	.o_sgram_rx_axis_last 					(fram_o_sgram_rx_axis_last    ),			
	.o_sgram_rx_axis_valid					(fram_o_sgram_rx_axis_valid   ),			
	.i_sgram_rx_axis_ready					(fast_ram_o_fram_rx_axis_ready),
    //pMAC是否是完成一帧数据的标志信号
	.o_data_start         					(fram_o_data_start    		  ),			
	.o_data_end           					(fram_o_data_end      		  ),			
	.o_data_complete      					(fram_o_data_complete 		  ),
    //寄存器数据信息
	.o_frag_next_rx        					(o_frag_next_rx        		  ),
	.o_rx_fragment_cnt     					(o_rx_fragment_cnt     		  ),
	.o_frame_seq           					(o_frame_seq           		  ),
	.o_err_rx_frame_cnt    					(o_err_rx_frame_cnt    		  ),
	.o_err_fragment_cnt    					(o_err_fragment_cnt    		  ),
	.o_rx_fragment_mismatch					(o_rx_fragment_mismatch		  )			
);
 		


 	FAST_RAM #(
    .DWIDTH  		                        (DWIDTH                        )
) inst_FAST_RAM (                      
 	.i_clk									(i_clk                         ),
 	.i_rst									(i_rst                         ),
    //不完整的pMAC报文在此拼接
	.i_fram_rx_axis_data  					(fram_o_sgram_rx_axis_data     ),				
	.i_fram_rx_axis_user  					(fram_o_sgram_rx_axis_user     ),				
	.i_fram_rx_axis_keep  					(fram_o_sgram_rx_axis_keep     ),				
	.i_fram_rx_axis_last  					(fram_o_sgram_rx_axis_last     ),				
	.i_fram_rx_axis_valid 					(fram_o_sgram_rx_axis_valid    ),				
	.o_fram_rx_axis_ready 					(fast_ram_o_fram_rx_axis_ready ),	

	.i_data_start         					(fram_o_data_start         	   ),				
	.i_data_end           					(fram_o_data_end           	   ),				
	.i_data_complete      					(fram_o_data_complete      	   ),
    //输出的完整的pMAC数据				
	.i_emac_no_empty						(o_emac_no_empty			   ),
	.o_rx_axis_data       					(fast_ram_o_rx_axis_data       ),				
	.o_rx_axis_user       					(fast_ram_o_rx_axis_user       ),				
	.o_rx_axis_keep       					(fast_ram_o_rx_axis_keep       ),				
	.o_rx_axis_last       					(fast_ram_o_rx_axis_last       ),				
	.o_rx_axis_valid      					(fast_ram_o_rx_axis_valid      ),				
	.i_rx_axis_ready      					(i_pmac_rx_axis_ready      	   )

 		);
emac_rx_ram #(
	.DWIDTH                                 (DWIDTH                        )
) inst_emac_rx_ram (
	.i_clk                                  (i_clk                         ),
	.i_rst                                  (i_rst                         ),

	.i_emac_rx_axis_data                    (Data_o_Emac_rx_axis_data      ),
	.i_emac_rx_axis_user                    (Data_o_Emac_rx_axis_user      ),
	.i_emac_rx_axis_keep                    (Data_o_Emac_rx_axis_keep      ),
	.i_emac_rx_axis_last                    (Data_o_Emac_rx_axis_last      ),
	.i_emac_rx_axis_valid                   (Data_o_Emac_rx_axis_valid     ),
	.o_emac_rx_axis_ready                   (o_emac_axis_ready             ),
	.o_emac_no_empty						(o_emac_no_empty			   ),

	.o_emac_rx_axis_data                    (o_emac_rx_axis_data           ),
	.o_emac_rx_axis_user                    (o_emac_rx_axis_user           ),
	.o_emac_rx_axis_keep                    (o_emac_rx_axis_keep           ),
	.o_emac_rx_axis_last                    (o_emac_rx_axis_last           ),
	.o_emac_rx_axis_valid                   (o_emac_rx_axis_valid          ),
	.i_emac_rx_axis_ready                   (i_emac_rx_axis_ready          )
);

qbu_rx_timestamp #(
	.DWIDTH                                 (DWIDTH                        )
) inst_qbu_rx_timestamp (
	.i_clk                                  (i_clk                         ),
	.i_rst                                  (i_rst                         ),

	.i_paket_ethertype                      (p_o_post_type                 ), // 需要根据实际信号连接
	.i_paket_ethertype_valid                (p_o_post_type_valid           ), // 需要根据实际信号连接

	.i_pmac_axis_data                       (fast_ram_o_rx_axis_data       ),
	.i_pmac_axis_valid                      (fast_ram_o_rx_axis_valid      ),

	.i_emac_axis_data                       (o_emac_rx_axis_data           ),
	.i_emac_axis_valid                      (o_emac_rx_axis_valid          ),

	.o_mac_time_irq                         (o_mac_time_irq                ),
	.o_mac_frame_seq                        (o_mac_frame_seq               ),
	.o_timestamp_addr                       (o_timestamp_addr              )
);

qbu_rx_output #(
    .DWIDTH                                 (DWIDTH                        )
) inst_qbu_rx_output (    
    .i_clk                                  (i_clk                         ),
    .i_rst                                  (i_rst                         ),
    
    .i_pmac_axis_data                       (fast_ram_o_rx_axis_data       ),
    .i_pmac_axis_user                       (fast_ram_o_rx_axis_user       ),
    .i_pmac_axis_keep                       (fast_ram_o_rx_axis_keep       ),
    .i_pmac_axis_last                       (fast_ram_o_rx_axis_last       ),
    .i_pmac_axis_valid                      (fast_ram_o_rx_axis_valid      ),
    .o_pmac_axis_ready                      (i_pmac_rx_axis_ready          ),
    
    .i_emac_axis_data                       (o_emac_rx_axis_data           ),
    .i_emac_axis_user                       (o_emac_rx_axis_user           ),
    .i_emac_axis_keep                       (o_emac_rx_axis_keep           ),
    .i_emac_axis_last                       (o_emac_rx_axis_last           ),
    .i_emac_axis_valid                      (o_emac_rx_axis_valid          ),
    .o_emac_axis_ready                      (i_emac_rx_axis_ready          ),
    
    .o_qbu_rx_axis_data                     (o_qbu_rx_axis_data            ),
    .o_qbu_rx_axis_user                     (o_qbu_rx_axis_user            ),
    .o_qbu_rx_axis_keep                     (o_qbu_rx_axis_keep            ),
    .o_qbu_rx_axis_last                     (o_qbu_rx_axis_last            ),
    .o_qbu_rx_axis_valid                    (o_qbu_rx_axis_valid           ),
    .i_qbu_rx_axis_ready                    (i_qbu_rx_axis_ready           )
);

endmodule
