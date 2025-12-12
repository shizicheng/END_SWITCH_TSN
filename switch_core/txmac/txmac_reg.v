module  txmac_reg #(
    parameter                                                   PORT_NUM                =      8         ,                   // ½»»»»úµÄ¶Ë¿ÚÊý
    parameter                                                   PORT_FIFO_PRI_NUM       =      8         ,
    parameter                                                   REG_ADDR_BUS_WIDTH      =      10        ,
    parameter                                                   REG_DATA_BUS_WIDTH      =      32        
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
`ifdef CPU_MAC
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_0            ,  // ¶Ë¿Ú·¢ËÍ·½ÏòMAC¹Ø±ÕÊ¹ÄÜ
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_0       ,  // ¶Ë¿ÚÇ¿ÖÆ´æ´¢×ª·¢¹¦ÄÜÊ¹ÄÜ
    output             wire    [3:0]                            o_port_1g_interval_num_regs_0       ,  // ¶Ë¿ÚÇ§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
    output             wire    [3:0]                            o_port_100m_interval_num_regs_0     ,  // ¶Ë¿Ú0°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
    input              wire    [15:0]                           i_port_tx_byte_cnt_0                ,  // ¶Ë¿Ú·¢ËÍ×Ö½ÚÊý
    input              wire    [15:0]                           i_port_tx_frame_cnt_0               ,  // ¶Ë¿Ú·¢ËÍÖ¡¼ÆÊýÆ÷
    input              wire    [15:0]                           i_port_diag_state_0                 ,  // Õï¶Ï×´Ì¬
    //qbu_tx ¼Ä´æÆ÷                                                                                     
    input              wire                                     i_tx_busy_0                          ,  // ·¢ËÍÃ¦ÐÅºÅ
    input              wire                                     i_preemptable_frame_0                ,  // ¿ÉÇÀÕ¼Ö¡
    input              wire                                     i_preempt_active_0                   ,  // ÇÀÕ¼¼¤»î
    input              wire                                     i_preempt_enable_0                   ,  // ÇÀÕ¼Ê¹ÄÜ
    input              wire    [15:0]                           i_tx_fragment_cnt_0                  ,  // ·¢ËÍ·ÖÆ¬¼ÆÊý
    input              wire    [15:0]                           i_err_verify_cnt_0                   ,  // ÑéÖ¤´íÎó¼ÆÊý
    input              wire    [15:0]                           i_tx_frames_cnt_0                    ,  // ·¢ËÍÖ¡¼ÆÊý
    input              wire    [15:0]                           i_preempt_success_cnt_0              ,  // ÇÀÕ¼³É¹¦¼ÆÊý
    input              wire                                     i_tx_timeout_0                       ,  // ·¢ËÍ³¬Ê±
    input              wire    [7:0]                            i_frag_next_tx_0                     ,  // ÏÂÒ»¸ö·¢ËÍ·ÖÆ¬ºÅ
    output             wire    [19:0]                           o_watchdog_timer_0                   , 
	output             wire                                		o_watchdog_timer_vld_0        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_0             		 ,
    output             wire                                		o_min_frag_size_vld_0         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_0                 		 ,
    output             wire                                		o_ipg_timer_vld_0             		 ,
	output             wire                                		o_verify_enabled_0            		 ,
    output             wire                                		o_start_verify_0              		 ,
    output             wire                                		o_clear_verify_0  					 ,
    output             wire                                   	o_reset_0                            ,
	output             wire    [15:0]                    		o_verify_timer_0		        	 ,
    output  		   wire                           			o_verify_timer_vld_0          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p0q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p0q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p0q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p0q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p0q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p0q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q5              		 ,
    output             wire    [15:0]                           o_hithreshold_p0q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p0q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p0q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p0q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p0q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p0q7              	 ,
	output   		   wire                                     o_qav_en_0                 			 ,
	output   		   wire                                     o_config_vld_0             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_0              			 , 
    output             wire                                     o_Base_time_vld_0                    ,                    
	output   		   wire                                     o_ConfigChange_0           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_0            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_0        			 ,    
	output   		   wire                                     o_ControlList_vld_0        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_0             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_0   			 , 
	output   		   wire                                     o_qbv_en_0                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_0                          ,
	output   		   wire	                                 	o_qos_en_0                           ,  
`endif
`ifdef MAC1
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_1            ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_1       ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_1       ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_1     ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_1                ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_1               ,  
    input              wire    [15:0]                           i_port_diag_state_1                 ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                     i_tx_busy_1                          , 
    input              wire                                     i_preemptable_frame_1                , 
    input              wire                                     i_preempt_active_1                   , 
    input              wire                                     i_preempt_enable_1                   , 
    input              wire    [15:0]                           i_tx_fragment_cnt_1                  , 
    input              wire    [15:0]                           i_err_verify_cnt_1                   , 
    input              wire    [15:0]                           i_tx_frames_cnt_1                    , 
    input              wire    [15:0]                           i_preempt_success_cnt_1              , 
    input              wire                                     i_tx_timeout_1                       , 
    input              wire    [7:0]                            i_frag_next_tx_1                     , 
	output             wire    [19:0]                           o_watchdog_timer_1                   , 
	output             wire                                		o_watchdog_timer_vld_1        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_1             		 ,
    output             wire                                		o_min_frag_size_vld_1         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_1                 		 ,
    output             wire                                		o_ipg_timer_vld_1             		 ,
	output             wire                                		o_verify_enabled_1            		 ,
    output             wire                                		o_start_verify_1              		 ,
    output             wire                                		o_clear_verify_1  					 ,
    output             wire                                   	o_reset_1                            ,
	output             wire    [15:0]                    		o_verify_timer_1		        	 ,
    output  		   wire                           			o_verify_timer_vld_1          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p1q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p1q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p1q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p1q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p1q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p1q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q5              		 ,
    output             wire    [15:0]                           o_hithreshold_p1q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p1q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p1q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p1q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p1q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p1q7              	 ,
	output   		   wire                                     o_qav_en_1                 			 ,
	output   		   wire                                     o_config_vld_1             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_1              			 , 
    output             wire                                     o_Base_time_vld_1                    , 
	output   		   wire                                     o_ConfigChange_1           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_1            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_1        			 ,    
	output   		   wire                                     o_ControlList_vld_1        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_1             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_1   			 , 
	output   		   wire                                     o_qbv_en_1                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_1                          ,
	output   		   wire	                                 	o_qos_en_1                           ,  
`endif
`ifdef MAC2
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_2            ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_2       ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_2       ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_2     ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_2                ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_2               ,  
    input              wire    [15:0]                           i_port_diag_state_2                 ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                     i_tx_busy_2                          , 
    input              wire                                     i_preemptable_frame_2                , 
    input              wire                                     i_preempt_active_2                   , 
    input              wire                                     i_preempt_enable_2                   , 
    input              wire    [15:0]                           i_tx_fragment_cnt_2                  , 
    input              wire    [15:0]                           i_err_verify_cnt_2                   , 
    input              wire    [15:0]                           i_tx_frames_cnt_2                    , 
    input              wire    [15:0]                           i_preempt_success_cnt_2              , 
    input              wire                                     i_tx_timeout_2                       , 
    input              wire    [7:0]                            i_frag_next_tx_2                     , 
    output             wire    [19:0]                           o_watchdog_timer_2                   , 
	output             wire                                		o_watchdog_timer_vld_2        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_2             		 ,
    output             wire                                		o_min_frag_size_vld_2         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_2                 		 ,
    output             wire                                		o_ipg_timer_vld_2             		 ,
	output             wire                                		o_verify_enabled_2            		 ,
    output             wire                                		o_start_verify_2              		 ,
    output             wire                                		o_clear_verify_2  					 ,
    output             wire                                   	o_reset_2                            ,
	output             wire    [15:0]                    		o_verify_timer_2		        	 ,
    output  		   wire                           			o_verify_timer_vld_2          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p2q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p2q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q5              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p2q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p2q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p2q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p2q7              	 ,
	output   		   wire                                     o_qav_en_2                 			 ,
	output   		   wire                                     o_config_vld_2             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_2              			 , 
    output             wire                                     o_Base_time_vld_2                    , 
	output   		   wire                                     o_ConfigChange_2           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_2            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_2        			 ,    
	output   		   wire                                     o_ControlList_vld_2        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_2             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_2   			 , 
	output   		   wire                                     o_qbv_en_2                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_2                          ,
	output   		   wire	                                 	o_qos_en_2                           ,  
`endif
`ifdef MAC3
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_3             ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_3        ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_3        ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_3      ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_3                 ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_3                ,  
    input              wire    [15:0]                           i_port_diag_state_3                  ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                     i_tx_busy_3                          ,  
    input              wire                                     i_preemptable_frame_3                ,  
    input              wire                                     i_preempt_active_3                   ,  
    input              wire                                     i_preempt_enable_3                   ,  
    input              wire    [15:0]                           i_tx_fragment_cnt_3                  ,  
    input              wire    [15:0]                           i_err_verify_cnt_3                   ,  
    input              wire    [15:0]                           i_tx_frames_cnt_3                    ,  
    input              wire    [15:0]                           i_preempt_success_cnt_3              ,  
    input              wire                                     i_tx_timeout_3                       ,  
    input              wire    [7:0]                            i_frag_next_tx_3                     ,  
	output             wire    [19:0]                           o_watchdog_timer_3                   , 
	output             wire                                	    o_watchdog_timer_vld_3        		 ,
    output             wire    [ 7:0]                      	    o_min_frag_size_3             		 ,
    output             wire                                	    o_min_frag_size_vld_3         		 ,
    output             wire    [ 7:0]                      	    o_ipg_timer_3                 		 ,
    output             wire                                	    o_ipg_timer_vld_3             		 ,
	output             wire                                	    o_verify_enabled_3            		 ,
    output             wire                                	    o_start_verify_3              		 ,
    output             wire                                	    o_clear_verify_3  					 ,
    output             wire                                   	o_reset_3                            ,
	output             wire    [15:0]                    		o_verify_timer_3		        	 ,
    output  		   wire                           			o_verify_timer_vld_3          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p3q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p3q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p3q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p3q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p3q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p3q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q5              		 ,
    output             wire    [15:0]                           o_hithreshold_p3q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p3q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p3q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p3q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p3q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p3q7              	 ,
	output   		   wire                                     o_qav_en_3                 			 ,
	output   		   wire                                     o_config_vld_3             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_3              			 ,
    output             wire                                     o_Base_time_vld_3                    ,  
	output   		   wire                                     o_ConfigChange_3           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_3            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_3        			 ,    
	output   		   wire                                     o_ControlList_vld_3        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_3             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_3   			 , 
	output   		   wire                                     o_qbv_en_3                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_3                          ,
	output   		   wire	                                 	o_qos_en_3                           ,    
`endif
`ifdef MAC4
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_4             ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_4        ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_4        ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_4      ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_4                 ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_4                ,  
    input              wire    [15:0]                           i_port_diag_state_4                  ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                   	i_tx_busy_4                          ,  
    input              wire                                   	i_preemptable_frame_4                ,  
    input              wire                                   	i_preempt_active_4                   ,  
    input              wire                                   	i_preempt_enable_4                   ,  
    input              wire    [15:0]                         	i_tx_fragment_cnt_4                  ,  
    input              wire    [15:0]                         	i_err_verify_cnt_4                   ,  
    input              wire    [15:0]                         	i_tx_frames_cnt_4                    ,  
    input              wire    [15:0]                         	i_preempt_success_cnt_4              ,  
    input              wire                                   	i_tx_timeout_4                       ,  
    input              wire    [7:0]                          	i_frag_next_tx_4                     ,  
	output             wire    [19:0]                         	o_watchdog_timer_4                   , 
	output             wire                                		o_watchdog_timer_vld_4        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_4             		 ,
    output             wire                                		o_min_frag_size_vld_4         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_4                 		 ,
    output             wire                                		o_ipg_timer_vld_4             		 ,
	output             wire                                		o_verify_enabled_4            		 ,
    output             wire                                		o_start_verify_4              		 ,
    output             wire                                		o_clear_verify_4  					 ,
    output             wire                                   	o_reset_4                            ,
	output             wire    [15:0]                    		o_verify_timer_4		        	 ,
    output  		   wire                           			o_verify_timer_vld_4          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p4q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p4q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q5              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p4q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p4q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p4q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p4q7              	 ,
	output   		   wire                                     o_qav_en_4                 			 ,
	output   		   wire                                     o_config_vld_4             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_4              			 , 
    output             wire                                     o_Base_time_vld_4                    , 
	output   		   wire                                     o_ConfigChange_4           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_4            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_4        			 ,    
	output   		   wire                                     o_ControlList_vld_4        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_4             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_4   			 , 
	output   		   wire                                     o_qbv_en_4                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_4                          ,
	output   		   wire	                                 	o_qos_en_4                           ,  
`endif
`ifdef MAC5
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_5            ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_5       ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_5       ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_5     ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_5                ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_5               ,  
    input              wire    [15:0]                           i_port_diag_state_5                 ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                   	i_tx_busy_5                          , 
    input              wire                                   	i_preemptable_frame_5                , 
    input              wire                                   	i_preempt_active_5                   , 
    input              wire                                   	i_preempt_enable_5                   , 
    input              wire    [15:0]                         	i_tx_fragment_cnt_5                  , 
    input              wire    [15:0]                         	i_err_verify_cnt_5                   , 
    input              wire    [15:0]                         	i_tx_frames_cnt_5                    , 
    input              wire    [15:0]                         	i_preempt_success_cnt_5              , 
    input              wire                                   	i_tx_timeout_5                       , 
    input              wire    [7:0]                          	i_frag_next_tx_5                     , 
	output             wire    [19:0]                         	o_watchdog_timer_5                   , 
	output             wire                                		o_watchdog_timer_vld_5        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_5             		 ,
    output             wire                                		o_min_frag_size_vld_5         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_5                 		 ,
    output             wire                                		o_ipg_timer_vld_5             		 ,
	output             wire                                		o_verify_enabled_5            		 ,
    output             wire                                		o_start_verify_5              		 ,
    output             wire                                		o_clear_verify_5  					 ,
    output             wire                                   	o_reset_5                            ,
	output             wire    [15:0]                    		o_verify_timer_5		        	 ,
    output  		   wire                           			o_verify_timer_vld_5          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p5q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p5q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p5q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p5q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p5q3              	 ,
	output   		   wire    [15:0]                           o_lothreshold_p5q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p5q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q5              		 ,
    output             wire    [15:0]                           o_hithreshold_p5q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p5q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p5q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p5q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p5q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p5q7              	 ,
	output   		   wire                                     o_qav_en_5                 			 ,
	output   		   wire                                     o_config_vld_5             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_5              			 , 
    output             wire                                     o_Base_time_vld_5                    , 
	output   		   wire                                     o_ConfigChange_5           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_5            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_5        			 ,    
	output   		   wire                                     o_ControlList_vld_5        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_5             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_5   			 , 
	output   		   wire                                     o_qbv_en_5                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_5                          ,
	output   		   wire	                                 	o_qos_en_5                           ,  
`endif
`ifdef MAC6
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_6            ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_6       ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_6       ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_6     ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_6                ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_6               ,  
    input              wire    [15:0]                           i_port_diag_state_6                 ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                     i_tx_busy_6                          , 
    input              wire                                     i_preemptable_frame_6                , 
    input              wire                                     i_preempt_active_6                   , 
    input              wire                                     i_preempt_enable_6                   , 
    input              wire    [15:0]                           i_tx_fragment_cnt_6                  , 
    input              wire    [15:0]                           i_err_verify_cnt_6                   , 
    input              wire    [15:0]                           i_tx_frames_cnt_6                    , 
    input              wire    [15:0]                           i_preempt_success_cnt_6              , 
    input              wire                                     i_tx_timeout_6                       , 
    input              wire    [7:0]                            i_frag_next_tx_6                     , 
	output             wire    [19:0]                           o_watchdog_timer_6                   , 
	output             wire                                		o_watchdog_timer_vld_6        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_6             		 ,
    output             wire                                		o_min_frag_size_vld_6         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_6                 		 ,
    output             wire                                		o_ipg_timer_vld_6             		 ,
	output             wire                                		o_verify_enabled_6            		 ,
    output             wire                                		o_start_verify_6              		 ,
    output             wire                                		o_clear_verify_6  					 ,
    output             wire                                   	o_reset_6                            ,
	output             wire    [15:0]                    		o_verify_timer_6		        	 ,
    output  		   wire                           			o_verify_timer_vld_6          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p6q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p6q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p6q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p6q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q3              		 ,
    output             wire    [15:0]                           o_hithreshold_p6q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q4              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p6q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q5              		 ,
    output             wire    [15:0]                           o_hithreshold_p6q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p6q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p6q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p6q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p6q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p6q7              	 ,
	output   		   wire                                     o_qav_en_6                 			 ,
	output   		   wire                                     o_config_vld_6             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_6              			 , 
    output             wire                                     o_Base_time_vld_6                    , 
	output   		   wire                                     o_ConfigChange_6           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_6            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_6        			 ,    
	output   		   wire                                     o_ControlList_vld_6        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_6             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_6   			 , 
	output   		   wire                                     o_qbv_en_6                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_6                          ,
	output   		   wire	                                 	o_qos_en_6                           ,  
`endif
`ifdef MAC7
    //txmac ¼Ä´æÆ÷
    output             wire    [PORT_NUM-1:0]                   o_port_txmac_down_regs_7            ,  
    output             wire    [PORT_NUM-1:0]                   o_store_forward_enable_regs_7       ,  
    output             wire    [3:0]                            o_port_1g_interval_num_regs_7       ,  
    output             wire    [3:0]                            o_port_100m_interval_num_regs_7     ,  
    input              wire    [15:0]                           i_port_tx_byte_cnt_7                ,  
    input              wire    [15:0]                           i_port_tx_frame_cnt_7               ,  
    input              wire    [15:0]                           i_port_diag_state_7                 ,  
    //qbu_tx ¼Ä´æÆ÷
    input              wire                                   	i_tx_busy_7                          , 
    input              wire                                   	i_preemptable_frame_7                , 
    input              wire                                   	i_preempt_active_7                   , 
    input              wire                                   	i_preempt_enable_7                   , 
    input              wire    [15:0]                         	i_tx_fragment_cnt_7                  , 
    input              wire    [15:0]                         	i_err_verify_cnt_7                   , 
    input              wire    [15:0]                         	i_tx_frames_cnt_7                    , 
    input              wire    [15:0]                         	i_preempt_success_cnt_7              , 
    input              wire                                   	i_tx_timeout_7                       , 
    input              wire    [7:0]                          	i_frag_next_tx_7                     , 
	output             wire    [19:0]                         	o_watchdog_timer_7                   , 
	output             wire                                		o_watchdog_timer_vld_7        		 ,
    output             wire    [ 7:0]                      		o_min_frag_size_7             		 ,
    output             wire                                		o_min_frag_size_vld_7         		 ,
    output             wire    [ 7:0]                      		o_ipg_timer_7                 		 ,
    output             wire                                		o_ipg_timer_vld_7             		 ,
	output             wire                                		o_verify_enabled_7            		 ,
    output             wire                                		o_start_verify_7              		 ,
    output             wire                                		o_clear_verify_7  					 ,
    output             wire                                   	o_reset_7                            ,
	output             wire    [15:0]                    		o_verify_timer_7		        	 ,
    output  		   wire                           			o_verify_timer_vld_7          		 ,
    //sche_top ¼Ä´æÆ÷
    output             wire    [7:0]                            o_idleSlope_p7q0                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q0              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q0              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q0              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q1                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q1              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q1              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q1              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q2                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q2              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q2              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q2              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q3                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q3              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q3              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q3              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q4                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q4              		 ,
    output             wire    [15:0]                           o_hithreshold_p7q4              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q4              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q5                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q5              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q5              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q5              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q6                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q6              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q6              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q6              	 ,
    output             wire    [7:0]                            o_idleSlope_p7q7                     ,
	output   		   wire    [7:0]                            o_sendslope_p7q7              		 ,
	output   		   wire    [15:0]                           o_hithreshold_p7q7              	 ,
    output             wire    [15:0]                           o_lothreshold_p7q7              	 ,
	output   		   wire                                     o_qav_en_7                 			 ,
	output   		   wire                                     o_config_vld_7             			 ,																								 
	output   		   wire    [79:0]                           o_Base_time_7              			 , 
    output             wire                                     o_Base_time_vld_7                    , 
	output   		   wire                                     o_ConfigChange_7           			 ,
	output   		   wire    [PORT_FIFO_PRI_NUM:0]            o_ControlList_7            			 ,     
	output   		   wire    [7:0]                            o_ControlList_len_7        			 ,    
	output   		   wire                                     o_ControlList_vld_7        			 ,     
	output   		   wire    [15:0]                           o_cycle_time_7             			 ,    
	output   		   wire    [79:0]                           o_cycle_time_extension_7   			 , 
	output   		   wire                                     o_qbv_en_7                 			 ,       																									 
	output   		   wire    [3:0]                            o_qos_sch_7                          ,
	output   		   wire	                                 	o_qos_en_7                           ,  
`endif
    /*---------------------------------------- ¼Ä´æÆ÷ÅäÖÃ½Ó¿Ú -------------------------------------------*/
    // ¼Ä´æÆ÷¿ØÖÆÐÅºÅ                     
    input               wire                                    i_refresh_list_pulse                , // Ë¢ÐÂ¼Ä´æÆ÷ÁÐ±í£¨×´Ì¬¼Ä´æÆ÷ºÍ¿ØÖÆ¼Ä´æÆ÷£©
    input               wire                                    i_switch_err_cnt_clr                , // Ë¢ÐÂ´íÎó¼ÆÊýÆ÷
    input               wire                                    i_switch_err_cnt_stat               , // Ë¢ÐÂ´íÎó×´Ì¬¼Ä´æÆ÷
    // ¼Ä´æÆ÷Ð´¿ØÖÆ½Ó¿Ú     
    input               wire                                    i_switch_reg_bus_we                 , // ¼Ä´æÆ÷Ð´Ê¹ÄÜ
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr            , // ¼Ä´æÆ÷Ð´µØÖ·
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din             , // ¼Ä´æÆ÷Ð´Êý¾Ý
    input               wire                                    i_switch_reg_bus_we_din_v           , // ¼Ä´æÆ÷Ð´Êý¾ÝÊ¹ÄÜ
    // ¼Ä´æÆ÷¶Á¿ØÖÆ½Ó¿Ú     
    input               wire                                    i_switch_reg_bus_rd                 , // ¼Ä´æÆ÷¶ÁÊ¹ÄÜ
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr            , // ¼Ä´æÆ÷¶ÁµØÖ·
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_rd_dout            , // ¶Á³ö¼Ä´æÆ÷Êý¾Ý
    output              wire                                    o_switch_reg_bus_rd_dout_v            // ¶ÁÊý¾ÝÓÐÐ§Ê¹ÄÜ
);

/*---------------------------------------- TXMAC¼Ä´æÆ÷µØÖ·¶¨Òå -------------------------------------------*/
localparam  REG_PORT_TXMAC_DOWN             =   9'h000                   ;
localparam  REG_STORE_FORWARD_ENABLE        =   9'h001                   ;
localparam  REG_PORT_1G_INTEVAL_NUM0        =   9'h010                   ;
localparam  REG_PORT_100M_INTERVAL_NUM0     =   9'h011                   ;
localparam  REG_PORT_1G_INTEVAL_NUM1        =   9'h012                   ;
localparam  REG_PORT_100M_INTERVAL_NUM1     =   9'h013                   ;
localparam  REG_PORT_1G_INTEVAL_NUM2        =   9'h014                   ;
localparam  REG_PORT_100M_INTERVAL_NUM2     =   9'h015                   ;
localparam  REG_PORT_1G_INTEVAL_NUM3        =   9'h016                   ;
localparam  REG_PORT_100M_INTERVAL_NUM3     =   9'h017                   ;
localparam  REG_PORT_1G_INTEVAL_NUM4        =   9'h018                   ;
localparam  REG_PORT_100M_INTERVAL_NUM4     =   9'h019                   ;
localparam  REG_PORT_1G_INTEVAL_NUM5        =   9'h01A                   ;
localparam  REG_PORT_100M_INTERVAL_NUM5     =   9'h01B                   ;
localparam  REG_PORT_1G_INTEVAL_NUM6        =   9'h01C                   ;
localparam  REG_PORT_100M_INTERVAL_NUM6     =   9'h01D                   ;
localparam  REG_PORT_1G_INTEVAL_NUM7        =   9'h01E                   ;
localparam  REG_PORT_100M_INTERVAL_NUM7     =   9'h01F                   ;
localparam  REG_PORT_TX_BYTE_CNT0           =   9'h020                   ;
localparam  REG_PORT_TX_FRAME_CNT0          =   9'h021                   ;
localparam  REG_PORT_DIAG_STATE0            =   9'h022                   ;
localparam  REG_PORT_TX_BYTE_CNT1           =   9'h030                   ;
localparam  REG_PORT_TX_FRAME_CNT1          =   9'h031                   ;
localparam  REG_PORT_DIAG_STATE1            =   9'h032                   ;
localparam  REG_PORT_TX_BYTE_CNT2           =   9'h040                   ;
localparam  REG_PORT_TX_FRAME_CNT2          =   9'h041                   ;
localparam  REG_PORT_DIAG_STATE2            =   9'h042                   ;
localparam  REG_PORT_TX_BYTE_CNT3           =   9'h050                   ;
localparam  REG_PORT_TX_FRAME_CNT3          =   9'h051                   ;
localparam  REG_PORT_DIAG_STATE3            =   9'h052                   ;
localparam  REG_PORT_TX_BYTE_CNT4           =   9'h060                   ;
localparam  REG_PORT_TX_FRAME_CNT4          =   9'h061                   ;
localparam  REG_PORT_DIAG_STATE4            =   9'h062                   ;
localparam  REG_PORT_TX_BYTE_CNT5           =   9'h070                   ;
localparam  REG_PORT_TX_FRAME_CNT5          =   9'h071                   ;
localparam  REG_PORT_DIAG_STATE5            =   9'h072                   ;
localparam  REG_PORT_TX_BYTE_CNT6           =   9'h080                   ;
localparam  REG_PORT_TX_FRAME_CNT6          =   9'h081                   ;
localparam  REG_PORT_DIAG_STATE6            =   9'h082                   ;
localparam  REG_PORT_TX_BYTE_CNT7           =   9'h090                   ;
localparam  REG_PORT_TX_FRAME_CNT7          =   9'h091                   ;
localparam  REG_PORT_DIAG_STATE7            =   9'h092                   ;
/*--------------------------------------- Schedule¼Ä´æÆ÷µØÖ·¶¨Òå -----------------------------------------*/ 

localparam  REG_QBV_ENABLE                  =   9'h0A0                   ;
localparam  REG_BASETIME_VLD                =   9'h0A1                   ;
// MAC0
localparam  REG_QBV_BASETIME0_0             =   9'h0A2                   ;
localparam  REG_QBV_BASETIME1_0             =   9'h0A3                   ;
localparam  REG_QBV_BASETIME2_0             =   9'h0A4                   ;
localparam  REG_QBV_BASETIME3_0             =   9'h0A5                   ;
localparam  REG_QBV_BASETIME4_0             =   9'h0A6                   ;
localparam  REG_QBV_CYCLTIME_0              =   9'h0A7                   ;
localparam  REG_QBV_CYCLTIME_EX0_0          =   9'h0A8                   ;
localparam  REG_QBV_CYCLTIME_EX1_0          =   9'h0A9                   ;
localparam  REG_QBV_CYCLTIME_EX2_0          =   9'h0AA                   ;
localparam  REG_QBV_CYCLTIME_EX3_0          =   9'h0AB                   ;
localparam  REG_QBV_CYCLTIME_EX4_0          =   9'h0AC                   ;
localparam  REG_QBV_CONTROLIST_LEN_0        =   9'h0AD                   ;
localparam  REG_QBV_CONTROLIST_VALUE_0      =   9'h0AE                   ;
// MAC1
localparam  REG_QBV_BASETIME0_1             =   9'h0B1                   ;
localparam  REG_QBV_BASETIME1_1             =   9'h0B2                   ;
localparam  REG_QBV_BASETIME2_1             =   9'h0B3                   ;
localparam  REG_QBV_BASETIME3_1             =   9'h0B4                   ;
localparam  REG_QBV_BASETIME4_1             =   9'h0B5                   ;
localparam  REG_QBV_CYCLTIME_1              =   9'h0B6                   ;
localparam  REG_QBV_CYCLTIME_EX0_1          =   9'h0B7                   ;
localparam  REG_QBV_CYCLTIME_EX1_1          =   9'h0B8                   ;
localparam  REG_QBV_CYCLTIME_EX2_1          =   9'h0B9                   ;
localparam  REG_QBV_CYCLTIME_EX3_1          =   9'h0BA                   ;
localparam  REG_QBV_CYCLTIME_EX4_1          =   9'h0BB                   ;
localparam  REG_QBV_CONTROLIST_LEN_1        =   9'h0BC                   ;
localparam  REG_QBV_CONTROLIST_VALUE_1      =   9'h0BD                   ;
//MAC2
localparam  REG_QBV_BASETIME0_2             =   9'h0C1                   ;
localparam  REG_QBV_BASETIME1_2             =   9'h0C2                   ;
localparam  REG_QBV_BASETIME2_2             =   9'h0C3                   ;
localparam  REG_QBV_BASETIME3_2             =   9'h0C4                   ;
localparam  REG_QBV_BASETIME4_2             =   9'h0C5                   ;
localparam  REG_QBV_CYCLTIME_2             	=   9'h0C6                   ;
localparam  REG_QBV_CYCLTIME_EX0_2          =   9'h0C7                   ;
localparam  REG_QBV_CYCLTIME_EX1_2          =   9'h0C8                   ;
localparam  REG_QBV_CYCLTIME_EX2_2          =   9'h0C9                   ;
localparam  REG_QBV_CYCLTIME_EX3_2          =   9'h0CA                   ;
localparam  REG_QBV_CYCLTIME_EX4_2          =   9'h0CB                   ;
localparam  REG_QBV_CONTROLIST_LEN_2        =   9'h0CC                   ;
localparam  REG_QBV_CONTROLIST_VALUE_2      =   9'h0CD                   ;
//MAC3                                         
localparam  REG_QBV_BASETIME0_3             =   9'h0D1                   ;
localparam  REG_QBV_BASETIME1_3             =   9'h0D2                   ;
localparam  REG_QBV_BASETIME2_3             =   9'h0D3                   ;
localparam  REG_QBV_BASETIME3_3             =   9'h0D4                   ;
localparam  REG_QBV_BASETIME4_3             =   9'h0D5                   ;
localparam  REG_QBV_CYCLTIME_3             	=   9'h0D6                   ;
localparam  REG_QBV_CYCLTIME_EX0_3          =   9'h0D7                   ;
localparam  REG_QBV_CYCLTIME_EX1_3          =   9'h0D8                   ;
localparam  REG_QBV_CYCLTIME_EX2_3          =   9'h0D9                   ;
localparam  REG_QBV_CYCLTIME_EX3_3          =   9'h0DA                   ;
localparam  REG_QBV_CYCLTIME_EX4_3          =   9'h0DB                   ;
localparam  REG_QBV_CONTROLIST_LEN_3        =   9'h0DC                   ;
localparam  REG_QBV_CONTROLIST_VALUE_3      =   9'h0DD                   ;
//MAC4
localparam  REG_QBV_BASETIME0_4             =   9'h0E1                   ;
localparam  REG_QBV_BASETIME1_4             =   9'h0E2                   ;
localparam  REG_QBV_BASETIME2_4             =   9'h0E3                   ;
localparam  REG_QBV_BASETIME3_4             =   9'h0E4                   ;
localparam  REG_QBV_BASETIME4_4             =   9'h0E5                   ;
localparam  REG_QBV_CYCLTIME_4             	=   9'h0E6                   ;
localparam  REG_QBV_CYCLTIME_EX0_4          =   9'h0E7                   ;
localparam  REG_QBV_CYCLTIME_EX1_4          =   9'h0E8                   ;
localparam  REG_QBV_CYCLTIME_EX2_4          =   9'h0E9                   ;
localparam  REG_QBV_CYCLTIME_EX3_4          =   9'h0EA                   ;
localparam  REG_QBV_CYCLTIME_EX4_4          =   9'h0EB                   ;
localparam  REG_QBV_CONTROLIST_LEN_4        =   9'h0EC                   ;
localparam  REG_QBV_CONTROLIST_VALUE_4      =   9'h0ED                   ;
//MAC5                                          
localparam  REG_QBV_BASETIME0_5             =   9'h0F1                   ;
localparam  REG_QBV_BASETIME1_5             =   9'h0F2                   ;
localparam  REG_QBV_BASETIME2_5             =   9'h0F3                   ;
localparam  REG_QBV_BASETIME3_5             =   9'h0F4                   ;
localparam  REG_QBV_BASETIME4_5             =   9'h0F5                   ;
localparam  REG_QBV_CYCLTIME_5             	=   9'h0F6                   ;
localparam  REG_QBV_CYCLTIME_EX0_5          =   9'h0F7                   ;
localparam  REG_QBV_CYCLTIME_EX1_5          =   9'h0F8                   ;
localparam  REG_QBV_CYCLTIME_EX2_5          =   9'h0F9                   ;
localparam  REG_QBV_CYCLTIME_EX3_5          =   9'h0FA                   ;
localparam  REG_QBV_CYCLTIME_EX4_5          =   9'h0FB                   ;
localparam  REG_QBV_CONTROLIST_LEN_5        =   9'h0FC                   ;
localparam  REG_QBV_CONTROLIST_VALUE_5      =   9'h0FD                   ;
//MAC6
localparam  REG_QBV_BASETIME0_6             =   9'h101                   ;
localparam  REG_QBV_BASETIME1_6             =   9'h102                   ;
localparam  REG_QBV_BASETIME2_6             =   9'h103                   ;
localparam  REG_QBV_BASETIME3_6             =   9'h104                   ;
localparam  REG_QBV_BASETIME4_6             =   9'h105                   ;
localparam  REG_QBV_CYCLTIME_6             	=   9'h106                   ;
localparam  REG_QBV_CYCLTIME_EX0_6          =   9'h107                   ;
localparam  REG_QBV_CYCLTIME_EX1_6          =   9'h108                   ;
localparam  REG_QBV_CYCLTIME_EX2_6          =   9'h109                   ;
localparam  REG_QBV_CYCLTIME_EX3_6          =   9'h10A                   ;
localparam  REG_QBV_CYCLTIME_EX4_6          =   9'h10B                   ;
localparam  REG_QBV_CONTROLIST_LEN_6        =   9'h10C                   ;
localparam  REG_QBV_CONTROLIST_VALUE_6      =   9'h10D                   ;
//MAC7
localparam  REG_QBV_BASETIME0_7             =   9'h111                   ;
localparam  REG_QBV_BASETIME1_7             =   9'h112                   ;
localparam  REG_QBV_BASETIME2_7             =   9'h113                   ;
localparam  REG_QBV_BASETIME3_7             =   9'h114                   ;
localparam  REG_QBV_BASETIME4_7             =   9'h115                   ;
localparam  REG_QBV_CYCLTIME_7             	=   9'h117                   ;
localparam  REG_QBV_CYCLTIME_EX0_7          =   9'h117                   ;
localparam  REG_QBV_CYCLTIME_EX1_7          =   9'h118                   ;
localparam  REG_QBV_CYCLTIME_EX2_7          =   9'h119                   ;
localparam  REG_QBV_CYCLTIME_EX3_7          =   9'h11A                   ;
localparam  REG_QBV_CYCLTIME_EX4_7          =   9'h11B                   ;
localparam  REG_QBV_CONTROLIST_LEN_7        =   9'h11C                   ;
localparam  REG_QBV_CONTROLIST_VALUE_7      =   9'h11D                   ;
// QAV¼Ä´æÆ÷µØÖ·¶¨Òå
localparam  REG_QAV_ENABLE                  =   9'h120                   ;
//MAC0
localparam  REG_QAV_IDLESLOPE_P0Q0          =   9'h121                   ;
localparam  REG_QAV_SENDSLOPE_P0Q0          =   9'h122                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q0         =   9'h123                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q0         =   9'h124                   ;
localparam  REG_QAV_IDLESLOPE_P0Q1          =   9'h125                   ;
localparam  REG_QAV_SENDSLOPE_P0Q1          =   9'h126                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q1         =   9'h127                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q1         =   9'h128                   ;
localparam  REG_QAV_IDLESLOPE_P0Q2          =   9'h129                   ;
localparam  REG_QAV_SENDSLOPE_P0Q2          =   9'h12A                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q2         =   9'h12B                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q2         =   9'h12C                   ;
localparam  REG_QAV_IDLESLOPE_P0Q3          =   9'h12D                   ;
localparam  REG_QAV_SENDSLOPE_P0Q3          =   9'h12E                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q3         =   9'h12F                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q3         =   9'h130                   ;
localparam  REG_QAV_IDLESLOPE_P0Q4          =   9'h131                   ;
localparam  REG_QAV_SENDSLOPE_P0Q4          =   9'h132                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q4         =   9'h133                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q4         =   9'h134                   ;
localparam  REG_QAV_IDLESLOPE_P0Q5          =   9'h135                   ;
localparam  REG_QAV_SENDSLOPE_P0Q5          =   9'h136                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q5         =   9'h137                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q5         =   9'h138                   ;
localparam  REG_QAV_IDLESLOPE_P0Q6          =   9'h139                   ;
localparam  REG_QAV_SENDSLOPE_P0Q6          =   9'h13A                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q6         =   9'h13B                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q6         =   9'h13C                   ;
localparam  REG_QAV_IDLESLOPE_P0Q7          =   9'h13D                   ;
localparam  REG_QAV_SENDSLOPE_P0Q7          =   9'h13E                   ;
localparam  REG_QAV_HTHRESHOLD_P0Q7         =   9'h13F                   ;
localparam  REG_QAV_LTHRESHOLD_P0Q7         =   9'h140                   ;
//MAC1
localparam  REG_QAV_IDLESLOPE_P1Q0          =   9'h141                   ;
localparam  REG_QAV_SENDSLOPE_P1Q0          =   9'h142                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q0         =   9'h143					 ;
localparam  REG_QAV_LTHRESHOLD_P1Q0         =   9'h144                   ;
localparam  REG_QAV_IDLESLOPE_P1Q1          =   9'h145                   ;
localparam  REG_QAV_SENDSLOPE_P1Q1          =   9'h146                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q1         =   9'h147                   ;
localparam  REG_QAV_LTHRESHOLD_P1Q1         =   9'h148					 ;
localparam  REG_QAV_IDLESLOPE_P1Q2          =   9'h149                   ;
localparam  REG_QAV_SENDSLOPE_P1Q2          =   9'h14A                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q2			=	9'h14B					 ;
localparam  REG_QAV_LTHRESHOLD_P1Q2			=	9'h14C					 ;
localparam  REG_QAV_IDLESLOPE_P1Q3          =   9'h14D                   ;
localparam  REG_QAV_SENDSLOPE_P1Q3          =   9'h14E                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q3         =   9'h14F                   ;
localparam  REG_QAV_LTHRESHOLD_P1Q3         =   9'h150                   ;
localparam  REG_QAV_IDLESLOPE_P1Q4          =   9'h151                   ;
localparam  REG_QAV_SENDSLOPE_P1Q4          =   9'h152                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q4         =   9'h153                   ;
localparam	REG_QAV_LTHRESHOLD_P1Q4         =   9'h154                   ;
localparam  REG_QAV_IDLESLOPE_P1Q5          =   9'h155                   ;
localparam  REG_QAV_SENDSLOPE_P1Q5          =   9'h156                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q5         =   9'h157                   ;
localparam  REG_QAV_LTHRESHOLD_P1Q5         =   9'h158                   ;
localparam  REG_QAV_IDLESLOPE_P1Q6          =   9'h159                   ;
localparam  REG_QAV_SENDSLOPE_P1Q6          =   9'h15A                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q6         =   9'h15B                   ;
localparam  REG_QAV_LTHRESHOLD_P1Q6         =   9'h15C                   ;
localparam  REG_QAV_IDLESLOPE_P1Q7          =   9'h15D                   ;
localparam  REG_QAV_SENDSLOPE_P1Q7          =   9'h15E                   ;
localparam  REG_QAV_HTHRESHOLD_P1Q7         =   9'h15F                   ;
localparam  REG_QAV_LTHRESHOLD_P1Q7         =   9'h160                   ;
//MAC2
localparam  REG_QAV_IDLESLOPE_P2Q0          =   9'h161                   ;
localparam  REG_QAV_SENDSLOPE_P2Q0          =   9'h162                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q0         =   9'h163                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q0         =   9'h164                   ;
localparam  REG_QAV_IDLESLOPE_P2Q1          =   9'h165                   ;
localparam  REG_QAV_SENDSLOPE_P2Q1          =   9'h166                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q1         =   9'h167                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q1			=	9'h168                   ;
localparam  REG_QAV_IDLESLOPE_P2Q2          =   9'h169                   ;
localparam  REG_QAV_SENDSLOPE_P2Q2          =   9'h16A                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q2         =   9'h16B                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q2         =   9'h16C                   ;
localparam  REG_QAV_IDLESLOPE_P2Q3          =   9'h16D                   ;
localparam  REG_QAV_SENDSLOPE_P2Q3          =   9'h16E                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q3         =   9'h16F                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q3         =   9'h170                   ;
localparam  REG_QAV_IDLESLOPE_P2Q4          =   9'h171                   ;
localparam  REG_QAV_SENDSLOPE_P2Q4          =   9'h172                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q4         =   9'h173                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q4         =   9'h174                   ;
localparam  REG_QAV_IDLESLOPE_P2Q5          =   9'h175                   ;
localparam  REG_QAV_SENDSLOPE_P2Q5          =   9'h176                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q5         =   9'h177                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q5         =   9'h178                   ;
localparam  REG_QAV_IDLESLOPE_P2Q6          =   9'h179                   ;
localparam  REG_QAV_SENDSLOPE_P2Q6          =   9'h17A                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q6         =   9'h17B                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q6         =   9'h17C                   ;
localparam  REG_QAV_IDLESLOPE_P2Q7          =   9'h17D                   ;
localparam  REG_QAV_SENDSLOPE_P2Q7          =   9'h17E                   ;
localparam  REG_QAV_HTHRESHOLD_P2Q7         =   9'h17F                   ;
localparam  REG_QAV_LTHRESHOLD_P2Q7         =   9'h180                   ;
//MAC3
localparam  REG_QAV_IDLESLOPE_P3Q0          =   9'h181                   ;
localparam  REG_QAV_SENDSLOPE_P3Q0          =   9'h182                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q0         =   9'h183                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q0         =   9'h184                   ;
localparam  REG_QAV_IDLESLOPE_P3Q1          =   9'h185                   ;
localparam  REG_QAV_SENDSLOPE_P3Q1          =   9'h186                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q1         =   9'h187                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q1			=	9'h188                   ;
localparam  REG_QAV_IDLESLOPE_P3Q2          =   9'h189                   ;
localparam  REG_QAV_SENDSLOPE_P3Q2          =   9'h18A                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q2         =   9'h18B                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q2         =   9'h18C                   ;
localparam  REG_QAV_IDLESLOPE_P3Q3          =   9'h18D                   ;
localparam  REG_QAV_SENDSLOPE_P3Q3          =   9'h18E                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q3         =   9'h18F                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q3         =   9'h190                   ;
localparam  REG_QAV_IDLESLOPE_P3Q4          =   9'h191                   ;
localparam  REG_QAV_SENDSLOPE_P3Q4          =   9'h192                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q4         =   9'h193                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q4         =   9'h194                   ;
localparam  REG_QAV_IDLESLOPE_P3Q5          =   9'h195                   ;
localparam  REG_QAV_SENDSLOPE_P3Q5          =   9'h196                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q5         =   9'h197                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q5         =   9'h198                   ;
localparam  REG_QAV_IDLESLOPE_P3Q6          =   9'h199                   ;
localparam  REG_QAV_SENDSLOPE_P3Q6          =   9'h19A                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q6         =   9'h19B                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q6         =   9'h19C                   ;
localparam  REG_QAV_IDLESLOPE_P3Q7          =   9'h19D                   ;
localparam  REG_QAV_SENDSLOPE_P3Q7          =   9'h19E                   ;
localparam  REG_QAV_HTHRESHOLD_P3Q7         =   9'h19F                   ;
localparam  REG_QAV_LTHRESHOLD_P3Q7         =   9'h1A0                   ;
//MAC4
localparam  REG_QAV_IDLESLOPE_P4Q0          =   9'h1A1                   ;
localparam  REG_QAV_SENDSLOPE_P4Q0          =   9'h1A2                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q0         =   9'h1A3                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q0         =   9'h1A4                   ;
localparam  REG_QAV_IDLESLOPE_P4Q1          =   9'h1A5                   ;
localparam  REG_QAV_SENDSLOPE_P4Q1          =   9'h1A6                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q1         =   9'h1A7                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q1			=	9'h1A8                   ;
localparam  REG_QAV_IDLESLOPE_P4Q2          =   9'h1A9                   ;
localparam  REG_QAV_SENDSLOPE_P4Q2          =   9'h1AA                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q2         =   9'h1AB                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q2         =   9'h1AC                   ;
localparam  REG_QAV_IDLESLOPE_P4Q3          =   9'h1AD                   ;
localparam  REG_QAV_SENDSLOPE_P4Q3          =   9'h1AE                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q3         =   9'h1AF                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q3         =   9'h1B0                   ;
localparam  REG_QAV_IDLESLOPE_P4Q4          =   9'h1B1                   ;
localparam  REG_QAV_SENDSLOPE_P4Q4          =   9'h1B2                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q4         =   9'h1B3                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q4         =   9'h1B4                   ;
localparam  REG_QAV_IDLESLOPE_P4Q5          =   9'h1B5                   ;
localparam  REG_QAV_SENDSLOPE_P4Q5          =   9'h1B6                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q5         =   9'h1B7                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q5         =   9'h1B8                   ;
localparam  REG_QAV_IDLESLOPE_P4Q6          =   9'h1B9                   ;
localparam  REG_QAV_SENDSLOPE_P4Q6          =   9'h1BA                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q6         =   9'h1BB                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q6         =   9'h1BC                   ;
localparam  REG_QAV_IDLESLOPE_P4Q7          =   9'h1BD                   ;
localparam  REG_QAV_SENDSLOPE_P4Q7          =   9'h1BE                   ;
localparam  REG_QAV_HTHRESHOLD_P4Q7         =   9'h1BF                   ;
localparam  REG_QAV_LTHRESHOLD_P4Q7         =   9'h1C0                   ;
//MAC5
localparam  REG_QAV_IDLESLOPE_P5Q0          =   9'h1C1                   ;
localparam  REG_QAV_SENDSLOPE_P5Q0          =   9'h1C2                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q0         =   9'h1C3                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q0         =   9'h1C4                   ;
localparam  REG_QAV_IDLESLOPE_P5Q1          =   9'h1C5                   ;
localparam  REG_QAV_SENDSLOPE_P5Q1          =   9'h1C6                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q1         =   9'h1C7                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q1			=	9'h1C8                   ;
localparam  REG_QAV_IDLESLOPE_P5Q2          =   9'h1C9                   ;
localparam  REG_QAV_SENDSLOPE_P5Q2          =   9'h1CA                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q2         =   9'h1CB                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q2         =   9'h1CC                   ;
localparam  REG_QAV_IDLESLOPE_P5Q3          =   9'h1CD                   ;
localparam  REG_QAV_SENDSLOPE_P5Q3          =   9'h1CE                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q3         =   9'h1CF                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q3         =   9'h1D0                   ;
localparam  REG_QAV_IDLESLOPE_P5Q4          =   9'h1D1                   ;
localparam  REG_QAV_SENDSLOPE_P5Q4          =   9'h1D2                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q4         =   9'h1D3                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q4         =   9'h1D4                   ;
localparam  REG_QAV_IDLESLOPE_P5Q5          =   9'h1D5                   ;
localparam  REG_QAV_SENDSLOPE_P5Q5          =   9'h1D6                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q5         =   9'h1D7                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q5         =   9'h1D8                   ;
localparam  REG_QAV_IDLESLOPE_P5Q6          =   9'h1D9                   ;
localparam  REG_QAV_SENDSLOPE_P5Q6          =   9'h1DA                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q6         =   9'h1DB                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q6         =   9'h1DC                   ;
localparam  REG_QAV_IDLESLOPE_P5Q7          =   9'h1DD                   ;
localparam  REG_QAV_SENDSLOPE_P5Q7          =   9'h1DE                   ;
localparam  REG_QAV_HTHRESHOLD_P5Q7         =   9'h1DF                   ;
localparam  REG_QAV_LTHRESHOLD_P5Q7         =   9'h1E0                   ;
//MAC6
localparam  REG_QAV_IDLESLOPE_P6Q0          =   9'h1E1                   ;
localparam  REG_QAV_SENDSLOPE_P6Q0          =   9'h1E2                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q0         =   9'h1E3                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q0         =   9'h1E4                   ;
localparam  REG_QAV_IDLESLOPE_P6Q1          =   9'h1E5                   ;
localparam  REG_QAV_SENDSLOPE_P6Q1          =   9'h1E6                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q1         =   9'h1E7                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q1			=	9'h1E8                   ;
localparam  REG_QAV_IDLESLOPE_P6Q2          =   9'h1E9                   ;
localparam  REG_QAV_SENDSLOPE_P6Q2          =   9'h1EA                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q2         =   9'h1EB                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q2         =   9'h1EC                   ;
localparam  REG_QAV_IDLESLOPE_P6Q3          =   9'h1ED                   ;
localparam  REG_QAV_SENDSLOPE_P6Q3          =   9'h1EE                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q3         =   9'h1EF                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q3         =   9'h1F0                   ;
localparam  REG_QAV_IDLESLOPE_P6Q4          =   9'h1F1                   ;
localparam  REG_QAV_SENDSLOPE_P6Q4          =   9'h1F2                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q4         =   9'h1F3                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q4         =   9'h1F4                   ;
localparam  REG_QAV_IDLESLOPE_P6Q5          =   9'h1F5                   ;
localparam  REG_QAV_SENDSLOPE_P6Q5          =   9'h1F6                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q5         =   9'h1F7                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q5			=	9'h1F8                   ;
localparam  REG_QAV_IDLESLOPE_P6Q6          =   9'h1F9                   ;
localparam  REG_QAV_SENDSLOPE_P6Q6          =   9'h1FA                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q6         =   9'h1FB                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q6         =   9'h1FC                   ;
localparam  REG_QAV_IDLESLOPE_P6Q7          =   9'h1FD                   ;
localparam  REG_QAV_SENDSLOPE_P6Q7          =   9'h1FE                   ;
localparam  REG_QAV_HTHRESHOLD_P6Q7         =   9'h1FF                   ;
localparam  REG_QAV_LTHRESHOLD_P6Q7         =   10'h200                  ;
//MAC7
localparam  REG_QAV_IDLESLOPE_P7Q0          =   10'h201                   ;
localparam  REG_QAV_SENDSLOPE_P7Q0          =   10'h202                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q0         =   10'h203                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q0         =   10'h204                   ;
localparam  REG_QAV_IDLESLOPE_P7Q1          =   10'h205                   ;
localparam  REG_QAV_SENDSLOPE_P7Q1          =   10'h206                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q1         =   10'h207                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q1			=	10'h208                   ;
localparam  REG_QAV_IDLESLOPE_P7Q2          =   10'h209                   ;
localparam  REG_QAV_SENDSLOPE_P7Q2          =   10'h20A                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q2         =   10'h20B                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q2         =   10'h20C                   ;
localparam  REG_QAV_IDLESLOPE_P7Q3          =   10'h20D                   ;
localparam  REG_QAV_SENDSLOPE_P7Q3          =   10'h20E                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q3         =   10'h20F                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q3         =   10'h210                   ;
localparam  REG_QAV_IDLESLOPE_P7Q4          =   10'h211                   ;
localparam  REG_QAV_SENDSLOPE_P7Q4          =   10'h212                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q4         =   10'h213                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q4         =   10'h214                   ;
localparam  REG_QAV_IDLESLOPE_P7Q5          =   10'h215                   ;
localparam  REG_QAV_SENDSLOPE_P7Q5          =   10'h216                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q5         =   10'h217                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q5         =   10'h218                   ;
localparam  REG_QAV_IDLESLOPE_P7Q6          =   10'h219                   ;
localparam  REG_QAV_SENDSLOPE_P7Q6          =   10'h21A                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q6         =   10'h21B                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q6         =   10'h21C                   ;
localparam  REG_QAV_IDLESLOPE_P7Q7          =   10'h21D                   ;
localparam  REG_QAV_SENDSLOPE_P7Q7          =   10'h21E                   ;
localparam  REG_QAV_HTHRESHOLD_P7Q7         =   10'h220                   ;
localparam  REG_QAV_LTHRESHOLD_P7Q7         =   10'h221                   ;
localparam  REG_QAV_CONFIG_VLD              =   10'h222                   ;
// QOS¼Ä´æÆ÷µØÖ·¶¨Òå
localparam  REG_QOS_ENABLE                  =   10'h223                   ;
localparam  REG_QOS_SCHMODE_0               =   10'h224                   ;
localparam  REG_QOS_SCHMODE_1               =   10'h225                   ;
localparam  REG_QOS_SCHMODE_2               =   10'h226                   ;
localparam  REG_QOS_SCHMODE_3               =   10'h227                   ;
localparam  REG_QOS_SCHMODE_4               =   10'h228                   ;
localparam  REG_QOS_SCHMODE_5               =   10'h229                   ;
localparam  REG_QOS_SCHMODE_6               =   10'h22A                   ;
localparam  REG_QOS_SCHMODE_7               =   10'h22B                   ;
/*---------------------------------------- Qbu_tx¼Ä´æÆ÷µØÖ·¶¨Òå ------------------------------------------*/
//MAC0                                          
localparam  REG_QBU_RESET_0                 =   10'h230                   ;
localparam  REG_PREEMPT_ENABLE_0            =   10'h231                   ;
localparam  REG_VERIFY_ENABLE_0             =   10'h232                   ;
localparam  REG_TRANS_BUSY_0                =   10'h233                   ;
localparam  REG_TX_FRAGMENT_CNT_0           =   10'h234                   ;
localparam  REG_PREEMPT_STATE_0             =   10'h235                   ;
localparam  REG_MIN_FRAG_SIZE_0             =   10'h236                   ;
localparam  REG_VERIFY_TIMER_0              =   10'h237                   ;
localparam  REG_IPG_TIMER_0                 =   10'h238                   ;
localparam  REG_VERIFY_CTRL_0               =   10'h239                   ;
localparam  REG_TX_FRAMES_CNT_0             =   10'h23A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_0       =   10'h23B                   ;
localparam  REG_WATCHDOG_TIMER_L_0          =   10'h23C                   ;
localparam  REG_WATCHDOG_TIMER_H_0          =   10'h23D                   ;
localparam  REG_TX_TIMEOUT_0                =   10'h23E                   ;
localparam  REG_FRAG_NEXT_TX_0              =   10'h23F                   ;
//MAC1                                               
localparam  REG_QBU_RESET_1                 =   10'h240                   ;
localparam  REG_PREEMPT_ENABLE_1            =   10'h241                   ;
localparam  REG_VERIFY_ENABLE_1             =   10'h242                   ;
localparam  REG_TRANS_BUSY_1                =   10'h243                   ;
localparam  REG_TX_FRAGMENT_CNT_1           =   10'h244                   ;
localparam  REG_PREEMPT_STATE_1             =   10'h245                   ;
localparam  REG_MIN_FRAG_SIZE_1             =   10'h246                   ;
localparam  REG_VERIFY_TIMER_1              =   10'h247                   ;
localparam  REG_IPG_TIMER_1                 =   10'h248                   ;
localparam  REG_VERIFY_CTRL_1               =   10'h249                   ;
localparam  REG_TX_FRAMES_CNT_1             =   10'h24A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_1       =   10'h24B                   ;
localparam  REG_WATCHDOG_TIMER_L_1          =   10'h24C                   ;
localparam  REG_WATCHDOG_TIMER_H_1          =   10'h24D                   ;
localparam  REG_TX_TIMEOUT_1                =   10'h24E                   ;
localparam  REG_FRAG_NEXT_TX_1              =   10'h24F                   ;
//MAC2                                               
localparam  REG_QBU_RESET_2                 =   10'h250                   ;
localparam  REG_PREEMPT_ENABLE_2            =   10'h251                   ;
localparam  REG_VERIFY_ENABLE_2             =   10'h252                   ;
localparam  REG_TRANS_BUSY_2                =   10'h253                   ;
localparam  REG_TX_FRAGMENT_CNT_2           =   10'h254                   ;
localparam  REG_PREEMPT_STATE_2             =   10'h255                   ;
localparam  REG_MIN_FRAG_SIZE_2             =   10'h256                   ;
localparam  REG_VERIFY_TIMER_2              =   10'h257                   ;
localparam  REG_IPG_TIMER_2                 =   10'h258                   ;
localparam  REG_VERIFY_CTRL_2               =   10'h259                   ;
localparam  REG_TX_FRAMES_CNT_2             =   10'h25A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_2       =   10'h25B                   ;
localparam  REG_WATCHDOG_TIMER_L_2          =   10'h25C                   ;
localparam  REG_WATCHDOG_TIMER_H_2          =   10'h25D                   ;
localparam  REG_TX_TIMEOUT_2                =   10'h25E                   ;
localparam  REG_FRAG_NEXT_TX_2              =   10'h25F                   ;
//MAC3                                               
localparam  REG_QBU_RESET_3                 =   10'h260                   ;
localparam  REG_PREEMPT_ENABLE_3            =   10'h261                   ;
localparam  REG_VERIFY_ENABLE_3             =   10'h262                   ;
localparam  REG_TRANS_BUSY_3                =   10'h263                   ;
localparam  REG_TX_FRAGMENT_CNT_3           =   10'h264                   ;
localparam  REG_PREEMPT_STATE_3             =   10'h265                   ;
localparam  REG_MIN_FRAG_SIZE_3             =   10'h266                   ;
localparam  REG_VERIFY_TIMER_3              =   10'h267                   ;
localparam  REG_IPG_TIMER_3                 =   10'h268                   ;
localparam  REG_VERIFY_CTRL_3               =   10'h269                   ;
localparam  REG_TX_FRAMES_CNT_3             =   10'h26A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_3       =   10'h26B                   ;
localparam  REG_WATCHDOG_TIMER_L_3          =   10'h26C                   ;
localparam  REG_WATCHDOG_TIMER_H_3          =   10'h26D                   ;
localparam  REG_TX_TIMEOUT_3                =   10'h26E                   ;
localparam  REG_FRAG_NEXT_TX_3              =   10'h26F                   ;
//MAC4                                               
localparam  REG_QBU_RESET_4                 =   10'h270                   ;
localparam  REG_PREEMPT_ENABLE_4            =   10'h271                   ;
localparam  REG_VERIFY_ENABLE_4             =   10'h272                   ;
localparam  REG_TRANS_BUSY_4                =   10'h273                   ;
localparam  REG_TX_FRAGMENT_CNT_4           =   10'h274                   ;
localparam  REG_PREEMPT_STATE_4             =   10'h275                   ;
localparam  REG_MIN_FRAG_SIZE_4             =   10'h276                   ;
localparam  REG_VERIFY_TIMER_4              =   10'h277                   ;
localparam  REG_IPG_TIMER_4                 =   10'h278                   ;
localparam  REG_VERIFY_CTRL_4               =   10'h279                   ;
localparam  REG_TX_FRAMES_CNT_4             =   10'h27A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_4       =   10'h27B                   ;
localparam  REG_WATCHDOG_TIMER_L_4          =   10'h27C                   ;
localparam  REG_WATCHDOG_TIMER_H_4          =   10'h27D                   ;
localparam  REG_TX_TIMEOUT_4                =   10'h27E                   ;
localparam  REG_FRAG_NEXT_TX_4              =   10'h27F                   ;
//MAC5                                               
localparam  REG_QBU_RESET_5                 =   10'h280                   ;
localparam  REG_PREEMPT_ENABLE_5            =   10'h281                   ;
localparam  REG_VERIFY_ENABLE_5             =   10'h282                   ;
localparam  REG_TRANS_BUSY_5                =   10'h283                   ;
localparam  REG_TX_FRAGMENT_CNT_5           =   10'h284                   ;
localparam  REG_PREEMPT_STATE_5             =   10'h285                   ;
localparam  REG_MIN_FRAG_SIZE_5             =   10'h286                   ;
localparam  REG_VERIFY_TIMER_5              =   10'h287                   ;
localparam  REG_IPG_TIMER_5                 =   10'h288                   ;
localparam  REG_VERIFY_CTRL_5               =   10'h289                   ;
localparam  REG_TX_FRAMES_CNT_5             =   10'h28A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_5       =   10'h28B                   ;
localparam  REG_WATCHDOG_TIMER_L_5          =   10'h28C                   ;
localparam  REG_WATCHDOG_TIMER_H_5          =   10'h28D                   ;
localparam  REG_TX_TIMEOUT_5                =   10'h28E                   ;
localparam  REG_FRAG_NEXT_TX_5              =   10'h28F                   ;
//MAC6                                               
localparam  REG_QBU_RESET_6                 =   10'h290                   ;
localparam  REG_PREEMPT_ENABLE_6            =   10'h291                   ;
localparam  REG_VERIFY_ENABLE_6             =   10'h292                   ;
localparam  REG_TRANS_BUSY_6                =   10'h293                   ;
localparam  REG_TX_FRAGMENT_CNT_6           =   10'h294                   ;
localparam  REG_PREEMPT_STATE_6             =   10'h295                   ;
localparam  REG_MIN_FRAG_SIZE_6             =   10'h296                   ;
localparam  REG_VERIFY_TIMER_6              =   10'h297                   ;
localparam  REG_IPG_TIMER_6                 =   10'h298                   ;
localparam  REG_VERIFY_CTRL_6               =   10'h299                   ;
localparam  REG_TX_FRAMES_CNT_6             =   10'h29A                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_6       =   10'h29B                   ;
localparam  REG_WATCHDOG_TIMER_L_6          =   10'h29C                   ;
localparam  REG_WATCHDOG_TIMER_H_6          =   10'h29D                   ;
localparam  REG_TX_TIMEOUT_6                =   10'h29E                   ;
localparam  REG_FRAG_NEXT_TX_6              =   10'h29F                   ;
//MAC7
localparam  REG_QBU_RESET_7                 =   10'h2A0                   ;
localparam  REG_PREEMPT_ENABLE_7            =   10'h2A1                   ;
localparam  REG_VERIFY_ENABLE_7             =   10'h2A2                   ;
localparam  REG_TRANS_BUSY_7                =   10'h2A3                   ;
localparam  REG_TX_FRAGMENT_CNT_7           =   10'h2A4                   ;
localparam  REG_PREEMPT_STATE_7             =   10'h2A5                   ;
localparam  REG_MIN_FRAG_SIZE_7             =   10'h2A6                   ;
localparam  REG_VERIFY_TIMER_7              =   10'h2A7                   ;
localparam  REG_IPG_TIMER_7                 =   10'h2A8                   ;
localparam  REG_VERIFY_CTRL_7               =   10'h2A9                   ;
localparam  REG_TX_FRAMES_CNT_7             =   10'h2AA                   ;
localparam  REG_PREEMPT_SUCCESS_CNT_7       =   10'h2AB                   ;
localparam  REG_WATCHDOG_TIMER_L_7          =   10'h2AC                   ;
localparam  REG_WATCHDOG_TIMER_H_7          =   10'h2AD                   ;
localparam  REG_TX_TIMEOUT_7                =   10'h2AE                   ;
localparam  REG_FRAG_NEXT_TX_7              =   10'h2AF                   ;

/*------------------------------------------- ÄÚ²¿ÐÅºÅ¶¨Òå  -----------------------------------------------*/
// ¼Ä´æÆ÷Ë¢ÐÂ¿ØÖÆÐÅºÅ  
reg                                         r_refresh_list_pulse                ; // ?????????????????????????????????
reg                                         r_switch_err_cnt_clr                ; // ???????????
reg                                         r_switch_err_cnt_stat               ; // ???????????????
/*---------------------------------------- TXMAC¼Ä´æÆ÷ÐÅºÅ¶¨Òå ------------------------------------------*/
// ¼Ä´æÆ÷Ð´¿ØÖÆÐÅºÅ  
reg                                         r_reg_bus_we                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_addr                      ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_data                      ;
reg                                         r_reg_bus_data_vld                  ;
// ¼Ä´æÆ÷¶Á¿ØÖÆÐÅºÅ
reg                                         r_reg_bus_re                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_raddr                     ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_rdata                     ;
reg                                         r_reg_bus_rdata_vld                 ;
// ¶Ë¿Ú1¼Ä´æÆ÷
reg    			[PORT_NUM-1:0]              r_port_txmac_down_regs              ;  // ¶Ë¿Ú·¢ËÍ·½ÏòMAC¹Ø±ÕÊ¹ÄÜ
reg    			[PORT_NUM-1:0]              r_store_forward_enable_regs         ;  // ¶Ë¿ÚÇ¿ÖÆ´æ´¢×ª·¢¹¦ÄÜÊ¹ÄÜ
reg    			[3:0]                       r_port_1g_interval_num_regs_0       ;  // ¶Ë¿Ú1Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_0     ;  // ¶Ë¿Ú1°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú2¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_1       ;  // ¶Ë¿Ú2Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_1     ;  // ¶Ë¿Ú2°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú3¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_2       ;  // ¶Ë¿Ú3Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_2     ;  // ¶Ë¿Ú3°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú4¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_3       ;  // ¶Ë¿Ú4Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_3     ;  // ¶Ë¿Ú4°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú5¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_4       ;  // ¶Ë¿Ú5Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_4     ;  // ¶Ë¿Ú5°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú6¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_5       ;  // ¶Ë¿Ú6Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_5     ;  // ¶Ë¿Ú6°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú7¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_6       ;  // ¶Ë¿Ú7Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_6     ;  // ¶Ë¿Ú7°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
// ¶Ë¿Ú8¼Ä´æÆ÷
reg    			[3:0]                       r_port_1g_interval_num_regs_7       ;  // ¶Ë¿Ú8Ç§Õ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
reg    			[3:0]                       r_port_100m_interval_num_regs_7     ;  // ¶Ë¿Ú8°ÙÕ×Ä£Ê½·¢ËÍÖ¡¼ä¸ô×Ö½ÚÊýÅäÖÃÖµ
/*---------------------------------------- Qbv¼Ä´æÆ÷ÐÅºÅ¶¨Òå ------------------------------------------*/
reg             [8-1:0]              		r_qbv_enable                      ;
reg             [8-1:0]              		r_base_time_vld                   ;
// ¶Ë¿Ú1¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_0                    ;
reg             [15:0]                      r_base_time1_0                    ;
reg             [15:0]                      r_base_time2_0                    ;
reg             [15:0]                      r_base_time3_0                    ;
reg             [15:0]                      r_base_time4_0                    ;
reg             [15:0]                      r_cycle_time_0                    ;
reg             [7:0]                       r_controllist_len_0               ;
reg             [7:0]                       r_controllist_val_0               ;
//reg                                       r_configchange_0                  ;
reg                                         r_controllist_vld_0               ;
//reg 			[7:0] 						r_controllist_cnt_0				  ;
// ¶Ë¿Ú2¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_1                    ;
reg             [15:0]                      r_base_time1_1                    ;
reg             [15:0]                      r_base_time2_1                    ;
reg             [15:0]                      r_base_time3_1                    ;
reg             [15:0]                      r_base_time4_1                    ;
reg             [15:0]                      r_cycle_time_1                    ;
reg             [7:0]                       r_controllist_len_1               ;
reg             [7:0]                       r_controllist_val_1               ;
//reg                                       r_configchange_1                  ;
reg                                         r_controllist_vld_1               ;
//reg 			[7:0] 						r_controllist_cnt_1				  ;
// ¶Ë¿Ú3¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_2                    ;
reg             [15:0]                      r_base_time1_2                    ;
reg             [15:0]                      r_base_time2_2                    ;
reg             [15:0]                      r_base_time3_2                    ;
reg             [15:0]                      r_base_time4_2                    ;
reg             [15:0]                      r_cycle_time_2                    ;
reg             [7:0]                       r_controllist_len_2               ;
reg             [7:0]                       r_controllist_val_2               ;
reg                                         r_controllist_vld_2               ;
//reg 			[7:0] 						r_controllist_cnt_2				  ;
// ¶Ë¿Ú4¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_3                    ;
reg             [15:0]                      r_base_time1_3                    ;
reg             [15:0]                      r_base_time2_3                    ;
reg             [15:0]                      r_base_time3_3                    ;
reg             [15:0]                      r_base_time4_3                    ;
reg             [15:0]                      r_cycle_time_3                    ;
reg             [7:0]                       r_controllist_len_3               ;
reg             [7:0]                       r_controllist_val_3               ;
reg                                         r_controllist_vld_3               ;
//reg 			[7:0] 						r_controllist_cnt_3				  ;
// ¶Ë¿Ú5¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_4                    ;
reg             [15:0]                      r_base_time1_4                    ;
reg             [15:0]                      r_base_time2_4                    ;
reg             [15:0]                      r_base_time3_4                    ;
reg             [15:0]                      r_base_time4_4                    ;
reg             [15:0]                      r_cycle_time_4                    ;
reg             [7:0]                       r_controllist_len_4               ;
reg             [7:0]                       r_controllist_val_4               ;
reg                                         r_controllist_vld_4               ;
//reg 			[7:0] 						r_controllist_cnt_4				  ;
// ¶Ë¿Ú6¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_5                    ;
reg             [15:0]                      r_base_time1_5                    ;
reg             [15:0]                      r_base_time2_5                    ;
reg             [15:0]                      r_base_time3_5                    ;
reg             [15:0]                      r_base_time4_5                    ;
reg             [15:0]                      r_cycle_time_5                    ;
reg             [7:0]                       r_controllist_len_5               ;
reg             [7:0]                       r_controllist_val_5               ;
reg                                         r_controllist_vld_5               ;
//reg 			[7:0] 						r_controllist_cnt_5				  ;
// ¶Ë¿Ú7¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_6                    ;
reg             [15:0]                      r_base_time1_6                    ;
reg             [15:0]                      r_base_time2_6                    ;
reg             [15:0]                      r_base_time3_6                    ;
reg             [15:0]                      r_base_time4_6                    ;
reg             [15:0]                      r_cycle_time_6                    ;
reg             [7:0]                       r_controllist_len_6               ;
reg             [7:0]                       r_controllist_val_6               ;
reg                                         r_controllist_vld_6               ;
//reg 			[7:0] 						r_controllist_cnt_6				  ;
// ¶Ë¿Ú8¼Ä´æÆ÷
reg             [15:0]                      r_base_time0_7                    ;
reg             [15:0]                      r_base_time1_7                    ;
reg             [15:0]                      r_base_time2_7                    ;
reg             [15:0]                      r_base_time3_7                    ;
reg             [15:0]                      r_base_time4_7                    ;
reg             [15:0]                      r_cycle_time_7                    ;
reg             [7:0]                       r_controllist_len_7               ;
reg             [7:0]                       r_controllist_val_7               ;
reg                                         r_controllist_vld_7               ;
//reg 			[7:0] 						r_controllist_cnt_7				  ;
/*---------------------------------------- Qav¼Ä´æÆ÷ÐÅºÅ¶¨Òå ------------------------------------------*/
reg             [PORT_NUM-1:0]              r_qav_enable                      ;
// ¶Ë¿Ú1¼Ä´æÆ÷
reg             [8-1:0]                     r_qav_idleslope_0[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_0[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_0[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_0[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú2¼Ä´æÆ÷                                               
reg             [8-1:0]                     r_qav_idleslope_1[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_1[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_1[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_1[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú3¼Ä´æÆ÷                                               
reg             [8-1:0]                     r_qav_idleslope_2[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_2[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_2[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_2[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú4¼Ä´æÆ÷                                               
reg             [8-1:0]                     r_qav_idleslope_3[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_3[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_3[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_3[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú5¼Ä´æÆ÷                                              
reg             [8-1:0]                     r_qav_idleslope_4[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_4[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_4[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_4[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú6¼Ä´æÆ÷                                               
reg             [8-1:0]                     r_qav_idleslope_5[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_5[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_5[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_5[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú7¼Ä´æÆ÷                                                
reg             [8-1:0]                     r_qav_idleslope_6[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_6[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_6[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_6[0:PORT_FIFO_PRI_NUM-1];
// ¶Ë¿Ú8¼Ä´æÆ÷                                                
reg             [8-1:0]                     r_qav_idleslope_7[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_sendslope_7[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_hthreshold_7[0:PORT_FIFO_PRI_NUM-1];
reg             [16-1:0]                    r_qav_lthreshold_7[0:PORT_FIFO_PRI_NUM-1];
reg             [8-1:0]                     r_qav_config_vld                  ;
/*---------------------------------------- Qav¼Ä´æÆ÷ÐÅºÅ¶¨Òå ------------------------------------------*/
reg             [8-1:0]              		r_qos_enable                      ;
reg             [3:0]                       r_qos_sche_0                      ;
reg             [3:0]                       r_qos_sche_1                      ;
reg             [3:0]                       r_qos_sche_2                      ;
reg             [3:0]                       r_qos_sche_3                      ;
reg             [3:0]                       r_qos_sche_4                      ;
reg             [3:0]                       r_qos_sche_5                      ;
reg             [3:0]                       r_qos_sche_6                      ;
reg             [3:0]                       r_qos_sche_7                      ;
/*--------------------------------------- Qbu_tx¼Ä´æÆ÷ÐÅºÅ¶¨Òå ----------------------------------------*/
//¶Ë¿Ú1                                                              
reg 			        					r_verify_enabled_0				  	;
reg 			[7:0]   					r_min_frag_size_0					;
reg 			        					r_min_frag_size_valid_0			  	;
reg 			[7:0]   					r_verify_timer_0					;
reg 			        					r_verify_timer_valid_0			  	;
reg 			[7:0]   					r_ipg_timer_0						;
reg 			        					r_ipg_timer_valid_0				  	;
reg 			        					r_reset_0							;
reg 			        					r_start_verify_0					;
reg 			        					r_clear_verify_0					;
reg 			[15:0]  					r_watchdog_timer_l_0				;
reg 			        					r_watchdog_timer_l_valid_0		  	;
reg 			[7:0]   					r_watchdog_timer_h_0				;
reg 			        					r_watchdog_timer_h_valid_0		  	;
//¶Ë¿Ú2                                             
reg 			        					r_verify_enabled_1				  	;
reg 			[7:0]   					r_min_frag_size_1					;
reg 			        					r_min_frag_size_valid_1			  	;
reg 			[7:0]   					r_verify_timer_1					;
reg 			        					r_verify_timer_valid_1			  	;
reg 			[7:0]   					r_ipg_timer_1						;
reg 			        					r_ipg_timer_valid_1				  	;
reg 			        					r_reset_1							;
reg 			        					r_start_verify_1					;
reg 			        					r_clear_verify_1					;
reg 			[15:0]  					r_watchdog_timer_l_1				;
reg 			        					r_watchdog_timer_l_valid_1		  	;
reg 			[7:0]   					r_watchdog_timer_h_1				;
reg 			        					r_watchdog_timer_h_valid_1		  	;
//¶Ë¿Ú3                                                           
reg 			        					r_verify_enabled_2				  	;
reg 			[7:0]   					r_min_frag_size_2					;
reg 			        					r_min_frag_size_valid_2			  	;
reg 			[7:0]   					r_verify_timer_2					;
reg 			        					r_verify_timer_valid_2			  	;
reg 			[7:0]   					r_ipg_timer_2						;
reg 			        					r_ipg_timer_valid_2				  	;
reg 			        					r_reset_2							;
reg 			        					r_start_verify_2					;
reg 			        					r_clear_verify_2					;
reg 			[15:0]  					r_watchdog_timer_l_2				;
reg 			        					r_watchdog_timer_l_valid_2		  	;
reg 			[7:0]   					r_watchdog_timer_h_2				;
reg 			        					r_watchdog_timer_h_valid_2		  	;
//¶Ë¿Ú4                                                        
reg 			        					r_verify_enabled_3				  	;
reg 			[7:0]   					r_min_frag_size_3					;
reg 			        					r_min_frag_size_valid_3			  	;
reg 			[7:0]   					r_verify_timer_3					;
reg 			        					r_verify_timer_valid_3			  	;
reg 			[7:0]   					r_ipg_timer_3						;
reg 			        					r_ipg_timer_valid_3				  	;
reg 			        					r_reset_3							;
reg 			        					r_start_verify_3					;
reg 			        					r_clear_verify_3					;
reg 			[15:0]  					r_watchdog_timer_l_3				;
reg 			        					r_watchdog_timer_l_valid_3		  	;
reg 			[7:0]   					r_watchdog_timer_h_3				;
reg 			        					r_watchdog_timer_h_valid_3		  	;
//¶Ë¿Ú5                                                              
reg 			        					r_verify_enabled_4				  	;
reg 			[7:0]   					r_min_frag_size_4					;
reg 			        					r_min_frag_size_valid_4			  	;
reg 			[7:0]   					r_verify_timer_4					;
reg 			        					r_verify_timer_valid_4			  	;
reg 			[7:0]   					r_ipg_timer_4						;
reg 			        					r_ipg_timer_valid_4				  	;
reg 			        					r_reset_4							;
reg 			        					r_start_verify_4					;
reg 			        					r_clear_verify_4					;
reg 			[15:0]  					r_watchdog_timer_l_4				;
reg 			        					r_watchdog_timer_l_valid_4		  	;
reg 			[7:0]   					r_watchdog_timer_h_4				;
reg 			        					r_watchdog_timer_h_valid_4		  	;
//¶Ë¿Ú6                                                              
reg 			        					r_verify_enabled_5				  	;
reg 			[7:0]   					r_min_frag_size_5					;
reg 			        					r_min_frag_size_valid_5			  	;
reg 			[7:0]   					r_verify_timer_5					;
reg 			        					r_verify_timer_valid_5			  	;
reg 			[7:0]   					r_ipg_timer_5						;
reg 			        					r_ipg_timer_valid_5				  	;
reg 			        					r_reset_5							;
reg 			        					r_start_verify_5					;
reg 			        					r_clear_verify_5					;
reg 			[15:0]  					r_watchdog_timer_l_5				;
reg 			        					r_watchdog_timer_l_valid_5		  	;
reg 			[7:0]   					r_watchdog_timer_h_5				;
reg 			        					r_watchdog_timer_h_valid_5		  	;
//¶Ë¿Ú7                                                             
reg 			        					r_verify_enabled_6				  	;
reg 			[7:0]   					r_min_frag_size_6					;
reg 			        					r_min_frag_size_valid_6			  	;
reg 			[7:0]   					r_verify_timer_6					;
reg 			        					r_verify_timer_valid_6			  	;
reg 			[7:0]   					r_ipg_timer_6						;
reg 			        					r_ipg_timer_valid_6				  	;
reg 			        					r_reset_6							;
reg 			        					r_start_verify_6					;
reg 			        					r_clear_verify_6					;
reg 			[15:0]  					r_watchdog_timer_l_6				;
reg 			        					r_watchdog_timer_l_valid_6		  	;
reg 			[7:0]   					r_watchdog_timer_h_6				;
reg 			        					r_watchdog_timer_h_valid_6		  	;
//¶Ë¿Ú8                                                             
reg 			        					r_verify_enabled_7				  	;
reg 			[7:0]   					r_min_frag_size_7					;
reg 			        					r_min_frag_size_valid_7			  	;
reg 			[7:0]   					r_verify_timer_7					;
reg 			        					r_verify_timer_valid_7			  	;
reg 			[7:0]   					r_ipg_timer_7						;
reg 			        					r_ipg_timer_valid_7				  	;
reg 			        					r_reset_7							;
reg 			        					r_start_verify_7					;
reg 			        					r_clear_verify_7					;
reg 			[15:0]  					r_watchdog_timer_l_7				;
reg 			        					r_watchdog_timer_l_valid_7		  	;
reg 			[7:0]   					r_watchdog_timer_h_7				;
reg 			        					r_watchdog_timer_h_valid_7		  	;
/*========================================  Í¨ÓÃ¼Ä´æÆ÷¿ØÖÆÐÅºÅ¹ÜÀí ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_refresh_list_pulse        <= 1'b0;
        r_switch_err_cnt_clr        <= 1'b0;
        r_switch_err_cnt_stat       <= 1'b0;
    end else begin
        r_refresh_list_pulse        <= i_refresh_list_pulse;
        r_switch_err_cnt_clr        <= i_switch_err_cnt_clr;
        r_switch_err_cnt_stat       <= i_switch_err_cnt_stat;
    end
end
/*========================================  ¼Ä´æÆ÷¶ÁÐ´¿ØÖÆÐÅºÅ ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_we          <= 1'b0;
        r_reg_bus_addr        <= {REG_ADDR_BUS_WIDTH{1'b0}};
        r_reg_bus_data        <= {REG_DATA_BUS_WIDTH{1'b0}};
        r_reg_bus_data_vld    <= 1'b0;
        r_reg_bus_re          <= 1'b0;
        r_reg_bus_raddr       <= {REG_ADDR_BUS_WIDTH{1'b0}};
    end else begin
        r_reg_bus_we          <= i_switch_reg_bus_we;
        r_reg_bus_addr        <= i_switch_reg_bus_we_addr;
        r_reg_bus_data        <= i_switch_reg_bus_we_din;
        r_reg_bus_data_vld    <= i_switch_reg_bus_we_din_v;
        r_reg_bus_re          <= i_switch_reg_bus_rd;
        r_reg_bus_raddr       <= i_switch_reg_bus_rd_addr;
    end
end
/*======================================= ¶Ë¿ÚMAC¹Ø±ÕÊ¹ÄÜ =======================================*/
assign o_port_txmac_down_regs_0       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_0   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_1       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_1   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_2       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_2   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_3       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_3   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_4       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_4   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_5       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_5   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_6       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_6   	=   r_store_forward_enable_regs         ;
assign o_port_txmac_down_regs_7       	=	r_port_txmac_down_regs       		;
assign o_store_forward_enable_regs_7   	=   r_store_forward_enable_regs         ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_txmac_down_regs          <=  {PORT_NUM{1'b1}};
        r_store_forward_enable_regs     <=  {PORT_NUM{1'b0}};
    end else begin
        r_port_txmac_down_regs          <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_TXMAC_DOWN ? r_reg_bus_data : r_port_txmac_down_regs;
        r_store_forward_enable_regs     <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_STORE_FORWARD_ENABLE ? r_reg_bus_data : r_store_forward_enable_regs;
    end
end
/*======================================= MAC0¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_0   	=   r_port_1g_interval_num_regs_0       ;
assign o_port_100m_interval_num_regs_0 	=   r_port_100m_interval_num_regs_0     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_0   <=  4'h0;
        r_port_100m_interval_num_regs_0 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_0   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM0 ? r_reg_bus_data : r_port_1g_interval_num_regs_0;
        r_port_100m_interval_num_regs_0 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM0 ? r_reg_bus_data : r_port_100m_interval_num_regs_0;
    end
end

/*======================================= MAC1¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_1   	=   r_port_1g_interval_num_regs_1       ;
assign o_port_100m_interval_num_regs_1 	=   r_port_100m_interval_num_regs_1     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_1   <=  4'h0;
        r_port_100m_interval_num_regs_1 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_1   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM1 ? r_reg_bus_data : r_port_1g_interval_num_regs_1;
        r_port_100m_interval_num_regs_1 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM1 ? r_reg_bus_data : r_port_100m_interval_num_regs_1;
    end
end

/*======================================= MAC2¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_2   	=   r_port_1g_interval_num_regs_2       ;
assign o_port_100m_interval_num_regs_2 	=   r_port_100m_interval_num_regs_2     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_2   <=  4'h0;
        r_port_100m_interval_num_regs_2 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_2   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM2 ? r_reg_bus_data : r_port_1g_interval_num_regs_2;
        r_port_100m_interval_num_regs_2 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM2 ? r_reg_bus_data : r_port_100m_interval_num_regs_2;
    end
end
/*======================================= MAC3¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_3   	=   r_port_1g_interval_num_regs_3       ;
assign o_port_100m_interval_num_regs_3 	=   r_port_100m_interval_num_regs_3     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_3   <=  4'h0;
        r_port_100m_interval_num_regs_3 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_3   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM3 ? r_reg_bus_data : r_port_1g_interval_num_regs_3;
        r_port_100m_interval_num_regs_3 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM3 ? r_reg_bus_data : r_port_100m_interval_num_regs_3;
    end
end
/*======================================= MAC4¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_4   	=   r_port_1g_interval_num_regs_4       ;
assign o_port_100m_interval_num_regs_4 	=   r_port_100m_interval_num_regs_4     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_4   <=  4'h0;
        r_port_100m_interval_num_regs_4 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_4   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM4 ? r_reg_bus_data : r_port_1g_interval_num_regs_4;
        r_port_100m_interval_num_regs_4 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM4 ? r_reg_bus_data : r_port_100m_interval_num_regs_4;
    end
end
/*======================================= MAC5¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_5   	=   r_port_1g_interval_num_regs_5       ;
assign o_port_100m_interval_num_regs_5 	=   r_port_100m_interval_num_regs_5     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_5   <=  4'h0;
        r_port_100m_interval_num_regs_5 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_5   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM5 ? r_reg_bus_data : r_port_1g_interval_num_regs_5;
        r_port_100m_interval_num_regs_5 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM5 ? r_reg_bus_data : r_port_100m_interval_num_regs_5;
    end
end

/*======================================= MAC6¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_6   	=   r_port_1g_interval_num_regs_6       ;
assign o_port_100m_interval_num_regs_6 	=   r_port_100m_interval_num_regs_6     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_6   <=  4'h0;
        r_port_100m_interval_num_regs_6 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_6   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM6 ? r_reg_bus_data : r_port_1g_interval_num_regs_6;
        r_port_100m_interval_num_regs_6 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM6 ? r_reg_bus_data : r_port_100m_interval_num_regs_6;
    end
end

/*======================================= MAC7¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ =======================================*/
assign o_port_1g_interval_num_regs_7   	=   r_port_1g_interval_num_regs_7       ;
assign o_port_100m_interval_num_regs_7 	=   r_port_100m_interval_num_regs_7     ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_port_1g_interval_num_regs_7   <=  4'h0;
        r_port_100m_interval_num_regs_7 <=  4'h0;
    end else begin
        r_port_1g_interval_num_regs_7   <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_1G_INTEVAL_NUM7 ? r_reg_bus_data : r_port_1g_interval_num_regs_7;
        r_port_100m_interval_num_regs_7 <=  r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_PORT_100M_INTERVAL_NUM7 ? r_reg_bus_data : r_port_100m_interval_num_regs_7;
    end
end

/*========================================  qbv¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_qbv_enable          <= {8{1'b0}};
        r_base_time_vld       <= {8{1'b0}};  
    end else begin
        r_qbv_enable          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_ENABLE ? r_reg_bus_data[7:0] : r_qbv_enable;
        r_base_time_vld[0]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[0] : 
								 r_reg_bus_data[0] == 1'b1 ? 1'b0 : r_base_time_vld[0];
		r_base_time_vld[1]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[1] : 
								 r_reg_bus_data[1] == 1'b1 ? 1'b0 : r_base_time_vld[1];
		r_base_time_vld[2]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[2] : 
								 r_reg_bus_data[2] == 1'b1 ? 1'b0 : r_base_time_vld[2];
		r_base_time_vld[3]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[3] : 
								 r_reg_bus_data[3] == 1'b1 ? 1'b0 : r_base_time_vld[3];                                                    
		r_base_time_vld[4]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[4] : 
								 r_reg_bus_data[4] == 1'b1 ? 1'b0 : r_base_time_vld[4];                                                    
		r_base_time_vld[5]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[5] : 
								 r_reg_bus_data[5] == 1'b1 ? 1'b0 : r_base_time_vld[5];                                                    
		r_base_time_vld[6]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[6] : 
								 r_reg_bus_data[6] == 1'b1 ? 1'b0 : r_base_time_vld[6];                                                    
		r_base_time_vld[7]    <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_BASETIME_VLD ? r_reg_bus_data[7] : 
								 r_reg_bus_data[7] == 1'b1 ? 1'b0 : r_base_time_vld[7];
    end
end

assign o_qbv_en_0 			= 	r_qbv_enable[0];
assign o_qbv_en_1 			= 	r_qbv_enable[1];
assign o_qbv_en_2 			= 	r_qbv_enable[2];
assign o_qbv_en_3 			= 	r_qbv_enable[3];
assign o_qbv_en_4 			= 	r_qbv_enable[4];
assign o_qbv_en_5 			= 	r_qbv_enable[5];
assign o_qbv_en_6 			= 	r_qbv_enable[6];
assign o_qbv_en_7 			= 	r_qbv_enable[7];
assign o_Base_time_vld_0    =   r_base_time_vld[0];
assign o_Base_time_vld_1    =   r_base_time_vld[1];
assign o_Base_time_vld_2    =   r_base_time_vld[2];
assign o_Base_time_vld_3    =   r_base_time_vld[3];
assign o_Base_time_vld_4    =   r_base_time_vld[4];
assign o_Base_time_vld_5    =   r_base_time_vld[5];
assign o_Base_time_vld_6	=   r_base_time_vld[6];
assign o_Base_time_vld_7    =   r_base_time_vld[7];


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_0     		<= 16'b0;
		r_base_time1_0          <= 16'b0;
		r_base_time2_0          <= 16'b0;
		r_base_time3_0          <= 16'b0;
		r_base_time4_0          <= 16'b0;
		r_cycle_time_0          <= 16'b0;
		r_controllist_len_0     <= 8'b0;
		r_controllist_val_0     <= 8'b0;
    end else begin
        r_base_time0_0     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_0	? r_reg_bus_data : r_base_time0_0;    
		r_base_time1_0          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_0	? r_reg_bus_data : r_base_time1_0;    
		r_base_time2_0          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_0	? r_reg_bus_data : r_base_time2_0;    
		r_base_time3_0          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_0	? r_reg_bus_data : r_base_time3_0;    
		r_base_time4_0          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_0	? r_reg_bus_data : r_base_time4_0;    
		r_cycle_time_0          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_0 	? r_reg_bus_data : r_cycle_time_0;    
		r_controllist_len_0     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_0  ? r_reg_bus_data : r_controllist_len_0;
		r_controllist_val_0     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_0? r_reg_bus_data : r_controllist_val_0;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_0 <= 1'b0;
    end else begin
        r_controllist_vld_0 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_0  ? 1'b1 : 1'b0 ;
	end
end


assign o_Base_time_0        = {r_base_time4_0,r_base_time3_0,r_base_time2_0,r_base_time1_0,r_base_time0_0};
assign o_cycle_time_0       = r_cycle_time_0;
assign o_ControlList_0      = r_controllist_val_0;
assign o_ControlList_len_0  = r_controllist_len_0; 
assign o_ControlList_vld_0  = r_controllist_vld_0;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_1     		<= 16'b0;
		r_base_time1_1          <= 16'b0;
		r_base_time2_1          <= 16'b0;
		r_base_time3_1          <= 16'b0;
		r_base_time4_1          <= 16'b0;
		r_cycle_time_1          <= 16'b0;
		r_controllist_len_1     <= 8'b0;
		r_controllist_val_1     <= 8'b0;
    end else begin
        r_base_time0_1     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_1	? r_reg_bus_data : r_base_time0_1;    
		r_base_time1_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_1	? r_reg_bus_data : r_base_time1_1;    
		r_base_time2_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_1	? r_reg_bus_data : r_base_time2_1;    
		r_base_time3_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_1	? r_reg_bus_data : r_base_time3_1;    
		r_base_time4_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_1	? r_reg_bus_data : r_base_time4_1;    
		r_cycle_time_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_1 	? r_reg_bus_data : r_cycle_time_1;    
		r_controllist_len_1     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_1  ? r_reg_bus_data : r_controllist_len_1;
		r_controllist_val_1     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_1? r_reg_bus_data : r_controllist_val_1;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_1 <= 1'b0;
    end else begin
        r_controllist_vld_1 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_1 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_1 <= 8'b0;
    end else begin
        r_controllist_cnt_1 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_1 && (r_controllist_cnt_1 != r_controllist_len_1 - 1'b1) ? r_controllist_cnt_1 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_1 && (r_controllist_cnt_1 == r_controllist_len_1 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_1;
	end
end
*/

assign o_Base_time_1        = {r_base_time4_1,r_base_time3_1,r_base_time2_1,r_base_time1_1,r_base_time0_1};
assign o_cycle_time_1       = r_cycle_time_1;
assign o_ControlList_1      = r_controllist_val_1;
assign o_ControlList_len_1  = r_controllist_len_1; 
assign o_ControlList_vld_1  = r_controllist_vld_1;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_2     		<= 16'b0;
		r_base_time1_2          <= 16'b0;
		r_base_time2_2          <= 16'b0;
		r_base_time3_2          <= 16'b0;
		r_base_time4_2          <= 16'b0;
		r_cycle_time_2          <= 16'b0;
		r_controllist_len_2     <= 8'b0;
		r_controllist_val_2     <= 8'b0;
    end else begin
        r_base_time0_2     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_2	? r_reg_bus_data : r_base_time0_2;    
		r_base_time1_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_2	? r_reg_bus_data : r_base_time1_2;    
		r_base_time2_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_2	? r_reg_bus_data : r_base_time2_2;    
		r_base_time3_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_2	? r_reg_bus_data : r_base_time3_2;    
		r_base_time4_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_2	? r_reg_bus_data : r_base_time4_2;    
		r_cycle_time_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_2 	? r_reg_bus_data : r_cycle_time_2;    
		r_controllist_len_2     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_2  ? r_reg_bus_data : r_controllist_len_2;
		r_controllist_val_2     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_2? r_reg_bus_data : r_controllist_val_2;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_2 <= 1'b0;
    end else begin
        r_controllist_vld_2 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_2 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_2 <= 8'b0;
    end else begin
        r_controllist_cnt_2 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_2 && (r_controllist_cnt_2 != r_controllist_len_2 - 1'b1) ? r_controllist_cnt_2 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_2 && (r_controllist_cnt_2 == r_controllist_len_2 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_2;
	end
end
*/

assign o_Base_time_2        = {r_base_time4_2,r_base_time3_2,r_base_time2_2,r_base_time1_2,r_base_time0_2};
assign o_cycle_time_2       = r_cycle_time_2;
assign o_ControlList_2      = r_controllist_val_2;
assign o_ControlList_len_2  = r_controllist_len_2; 
assign o_ControlList_vld_2  = r_controllist_vld_2;


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_3     		<= 16'b0;
		r_base_time1_3          <= 16'b0;
		r_base_time2_3          <= 16'b0;
		r_base_time3_3          <= 16'b0;
		r_base_time4_3          <= 16'b0;
		r_cycle_time_3          <= 16'b0;
		r_controllist_len_3     <= 8'b0;
		r_controllist_val_3     <= 8'b0;
    end else begin
        r_base_time0_3     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_3	? r_reg_bus_data : r_base_time0_3;    
		r_base_time1_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_3	? r_reg_bus_data : r_base_time1_3;    
		r_base_time2_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_3	? r_reg_bus_data : r_base_time2_3;    
		r_base_time3_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_3	? r_reg_bus_data : r_base_time3_3;    
		r_base_time4_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_3	? r_reg_bus_data : r_base_time4_3;    
		r_cycle_time_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_3 	? r_reg_bus_data : r_cycle_time_3;    
		r_controllist_len_3     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_3  ? r_reg_bus_data : r_controllist_len_3;
		r_controllist_val_3     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_3? r_reg_bus_data : r_controllist_val_3;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_3 <= 1'b0;
    end else begin
        r_controllist_vld_3 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_3 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_2 <= 8'b0;
    end else begin
        r_controllist_cnt_2 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_2 && (r_controllist_cnt_2 != r_controllist_len_2 - 1'b1) ? r_controllist_cnt_2 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_2 && (r_controllist_cnt_2 == r_controllist_len_2 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_2;
	end
end
*/

assign o_Base_time_3        = {r_base_time4_3,r_base_time3_3,r_base_time2_3,r_base_time1_3,r_base_time0_3};
assign o_cycle_time_3       = r_cycle_time_3;
assign o_ControlList_3      = r_controllist_val_3;
assign o_ControlList_len_3  = r_controllist_len_3; 
assign o_ControlList_vld_3  = r_controllist_vld_3;


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_4     		<= 16'b0;
		r_base_time1_4          <= 16'b0;
		r_base_time2_4          <= 16'b0;
		r_base_time3_4          <= 16'b0;
		r_base_time4_4          <= 16'b0;
		r_cycle_time_4          <= 16'b0;
		r_controllist_len_4     <= 8'b0;
		r_controllist_val_4     <= 8'b0;
    end else begin
        r_base_time0_4     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_4	? r_reg_bus_data : r_base_time0_4;    
		r_base_time1_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_4	? r_reg_bus_data : r_base_time1_4;    
		r_base_time2_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_4	? r_reg_bus_data : r_base_time2_4;    
		r_base_time3_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_4	? r_reg_bus_data : r_base_time3_4;    
		r_base_time4_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_4	? r_reg_bus_data : r_base_time4_4;    
		r_cycle_time_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_4 	? r_reg_bus_data : r_cycle_time_4;    
		r_controllist_len_4     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_4  ? r_reg_bus_data : r_controllist_len_4;
		r_controllist_val_4     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_4? r_reg_bus_data : r_controllist_val_4;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_4 <= 1'b0;
    end else begin
        r_controllist_vld_4 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_4 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_4 <= 8'b0;
    end else begin
        r_controllist_cnt_4 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_4 && (r_controllist_cnt_4 != r_controllist_len_4 - 1'b1) ? r_controllist_cnt_4 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_4 && (r_controllist_cnt_4 == r_controllist_len_4 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_4;
	end
end
*/

assign o_Base_time_4        = {r_base_time4_4,r_base_time3_4,r_base_time2_4,r_base_time1_4,r_base_time0_4};
assign o_cycle_time_4       = r_cycle_time_4;
assign o_ControlList_4      = r_controllist_val_4;
assign o_ControlList_len_4  = r_controllist_len_4; 
assign o_ControlList_vld_4  = r_controllist_vld_4;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_5     		<= 16'b0;
		r_base_time1_5          <= 16'b0;
		r_base_time2_5          <= 16'b0;
		r_base_time3_5          <= 16'b0;
		r_base_time4_5          <= 16'b0;
		r_cycle_time_5          <= 16'b0;
		r_controllist_len_5     <= 8'b0;
		r_controllist_val_5     <= 8'b0;
    end else begin
        r_base_time0_5     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_5	? r_reg_bus_data : r_base_time0_5;    
		r_base_time1_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_5	? r_reg_bus_data : r_base_time1_5;    
		r_base_time2_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_5	? r_reg_bus_data : r_base_time2_5;    
		r_base_time3_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_5	? r_reg_bus_data : r_base_time3_5;    
		r_base_time4_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_5	? r_reg_bus_data : r_base_time4_5;    
		r_cycle_time_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_5 	? r_reg_bus_data : r_cycle_time_5;    
		r_controllist_len_5     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_5  ? r_reg_bus_data : r_controllist_len_5;
		r_controllist_val_5     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_5? r_reg_bus_data : r_controllist_val_5;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_5 <= 1'b0;
    end else begin
        r_controllist_vld_5 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_5 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_5 <= 8'b0;
    end else begin
        r_controllist_cnt_5 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_5 && (r_controllist_cnt_5 != r_controllist_len_5 - 1'b1) ? r_controllist_cnt_5 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_5 && (r_controllist_cnt_5 == r_controllist_len_5 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_5;
	end
end
*/

assign o_Base_time_5        = {r_base_time4_5,r_base_time3_5,r_base_time2_5,r_base_time1_5,r_base_time0_5};
assign o_cycle_time_5       = r_cycle_time_5;
assign o_ControlList_5      = r_controllist_val_5;
assign o_ControlList_len_5  = r_controllist_len_5; 
assign o_ControlList_vld_5  = r_controllist_vld_5;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_6     		<= 16'b0;
		r_base_time1_6          <= 16'b0;
		r_base_time2_6          <= 16'b0;
		r_base_time3_6          <= 16'b0;
		r_base_time4_6          <= 16'b0;
		r_cycle_time_6          <= 16'b0;
		r_controllist_len_6     <= 8'b0;
		r_controllist_val_6     <= 8'b0;
    end else begin
        r_base_time0_6     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_6	? r_reg_bus_data : r_base_time0_6;    
		r_base_time1_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_6	? r_reg_bus_data : r_base_time1_6;    
		r_base_time2_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_6	? r_reg_bus_data : r_base_time2_6;    
		r_base_time3_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_6	? r_reg_bus_data : r_base_time3_6;    
		r_base_time4_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_6	? r_reg_bus_data : r_base_time4_6;    
		r_cycle_time_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_6 	? r_reg_bus_data : r_cycle_time_6;    
		r_controllist_len_6     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_6  ? r_reg_bus_data : r_controllist_len_6;
		r_controllist_val_6     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_6? r_reg_bus_data : r_controllist_val_6;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_6 <= 1'b0;
    end else begin
        r_controllist_vld_6 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_6 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_6 <= 8'b0;
    end else begin
        r_controllist_cnt_6 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_6 && (r_controllist_cnt_6 != r_controllist_len_6 - 1'b1) ? r_controllist_cnt_6 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_6 && (r_controllist_cnt_6 == r_controllist_len_6 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_6;
	end
end
*/

assign o_Base_time_6        = {r_base_time4_6,r_base_time3_6,r_base_time2_6,r_base_time1_6,r_base_time0_6};
assign o_cycle_time_6       = r_cycle_time_6;
assign o_ControlList_6      = r_controllist_val_6;
assign o_ControlList_len_6  = r_controllist_len_6; 
assign o_ControlList_vld_6  = r_controllist_vld_6;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_base_time0_7     		<= 16'b0;
		r_base_time1_7          <= 16'b0;
		r_base_time2_7          <= 16'b0;
		r_base_time3_7          <= 16'b0;
		r_base_time4_7          <= 16'b0;
		r_cycle_time_7          <= 16'b0;
		r_controllist_len_7     <= 8'b0;
		r_controllist_val_7     <= 8'b0;
    end else begin
        r_base_time0_7     		<= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME0_7	? r_reg_bus_data : r_base_time0_7;    
		r_base_time1_7          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME1_7	? r_reg_bus_data : r_base_time1_7;    
		r_base_time2_7          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME2_7	? r_reg_bus_data : r_base_time2_7;    
		r_base_time3_7          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME3_7	? r_reg_bus_data : r_base_time3_7;    
		r_base_time4_7          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_BASETIME4_7	? r_reg_bus_data : r_base_time4_7;    
		r_cycle_time_7          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CYCLTIME_7 	? r_reg_bus_data : r_cycle_time_7;    
		r_controllist_len_7     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_LEN_7  ? r_reg_bus_data : r_controllist_len_7;
		r_controllist_val_7     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_7? r_reg_bus_data : r_controllist_val_7;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_vld_7 <= 1'b0;
    end else begin
        r_controllist_vld_7 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_7 ? 1'b1 : 1'b0;
	end
end

/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_controllist_cnt_7 <= 8'b0;
    end else begin
        r_controllist_cnt_7 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_7 && (r_controllist_cnt_7 != r_controllist_len_7 - 1'b1) ? r_controllist_cnt_7 + 1'b1 : 
							   r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBV_CONTROLIST_VALUE_7 && (r_controllist_cnt_7 == r_controllist_len_7 - 1'b1) ? 8'b0 :
							   r_controllist_cnt_7;
	end
end
*/

assign o_Base_time_7        = {r_base_time4_7,r_base_time3_7,r_base_time2_7,r_base_time1_7,r_base_time0_7};
assign o_cycle_time_7       = r_cycle_time_7;
assign o_ControlList_7      = r_controllist_val_7;
assign o_ControlList_len_7  = r_controllist_len_7; 
assign o_ControlList_vld_7  = r_controllist_vld_7;

/*========================================  qav¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_qav_enable        <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else begin
        r_qav_enable        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_ENABLE ? r_reg_bus_data : r_qav_enable;
    end
end

`ifdef CPU_MAC
    assign o_qav_en_0   =   r_qav_enable[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[0]	<=	8'h00;
            r_qav_sendslope_0[0]	<=	8'h00;
            r_qav_hthreshold_0[0]	<=	16'h00;
            r_qav_lthreshold_0[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[0];
            r_qav_sendslope_0[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[0];
            r_qav_hthreshold_0[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[0];
            r_qav_lthreshold_0[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[0];
        end
    end

    assign o_idleSlope_p0q0	    =	r_qav_idleslope_0[0];
    assign o_sendslope_p0q0	    =	r_qav_sendslope_0[0];
    assign o_hithreshold_p0q0	=	r_qav_hthreshold_0[0];
    assign o_lothreshold_p0q0	=	r_qav_lthreshold_0[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[1]	<=	8'h00;
            r_qav_sendslope_0[1]	<=	8'h00;
            r_qav_hthreshold_0[1]	<=	16'h00;
            r_qav_lthreshold_0[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[1];
            r_qav_sendslope_0[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[1];
            r_qav_hthreshold_0[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[1];
            r_qav_lthreshold_0[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[1];
        end
    end

    assign o_idleSlope_p0q1	    =	r_qav_idleslope_0[1];
    assign o_sendslope_p0q1	    =	r_qav_sendslope_0[1];
    assign o_hithreshold_p0q1	=	r_qav_hthreshold_0[1];
    assign o_lothreshold_p0q1	=	r_qav_lthreshold_0[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[2]	<=	8'h00;
            r_qav_sendslope_0[2]	<=	8'h00;
            r_qav_hthreshold_0[2]	<=	16'h00;
            r_qav_lthreshold_0[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[2];
            r_qav_sendslope_0[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[2];
            r_qav_hthreshold_0[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[2];
            r_qav_lthreshold_0[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[2];
        end
    end

    assign o_idleSlope_p0q2	    =	r_qav_idleslope_0[2];
    assign o_sendslope_p0q2	    =	r_qav_sendslope_0[2];
    assign o_hithreshold_p0q2	=	r_qav_hthreshold_0[2];
    assign o_lothreshold_p0q2	=	r_qav_lthreshold_0[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[3]	<=	8'h00;
            r_qav_sendslope_0[3]	<=	8'h00;
            r_qav_hthreshold_0[3]	<=	16'h00;
            r_qav_lthreshold_0[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[3];
            r_qav_sendslope_0[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[3];
            r_qav_hthreshold_0[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[3];
            r_qav_lthreshold_0[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[3];
        end
    end

    assign o_idleSlope_p0q3	    =	r_qav_idleslope_0[3];
    assign o_sendslope_p0q3	    =	r_qav_sendslope_0[3];
    assign o_hithreshold_p0q3	=	r_qav_hthreshold_0[3];
    assign o_lothreshold_p0q3	=	r_qav_lthreshold_0[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[4]	<=	8'h00;
            r_qav_sendslope_0[4]	<=	8'h00;
            r_qav_hthreshold_0[4]	<=	16'h00;
            r_qav_lthreshold_0[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[4];
            r_qav_sendslope_0[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[4];
            r_qav_hthreshold_0[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[4];
            r_qav_lthreshold_0[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[4];
        end
    end

    assign o_idleSlope_p0q4	    =	r_qav_idleslope_0[4];
    assign o_sendslope_p0q4	    =	r_qav_sendslope_0[4];
    assign o_hithreshold_p0q4	=	r_qav_hthreshold_0[4];
    assign o_lothreshold_p0q4	=	r_qav_lthreshold_0[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[5]	<=	8'h00;
            r_qav_sendslope_0[5]	<=	8'h00;
            r_qav_hthreshold_0[5]	<=	16'h00;
            r_qav_lthreshold_0[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[5];
            r_qav_sendslope_0[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[5];
            r_qav_hthreshold_0[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[5];
            r_qav_lthreshold_0[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[5];
        end
    end

    assign o_idleSlope_p0q5	    =	r_qav_idleslope_0[5];
    assign o_sendslope_p0q5	    =	r_qav_sendslope_0[5];
    assign o_hithreshold_p0q5	=	r_qav_hthreshold_0[5];
    assign o_lothreshold_p0q5	=	r_qav_lthreshold_0[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[6]	<=	8'h00;
            r_qav_sendslope_0[6]	<=	8'h00;
            r_qav_hthreshold_0[6]	<=	16'h00;
            r_qav_lthreshold_0[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[6];
            r_qav_sendslope_0[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[6];
            r_qav_hthreshold_0[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[6];
            r_qav_lthreshold_0[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[6];
        end
    end

    assign o_idleSlope_p0q6	    =	r_qav_idleslope_0[6];
    assign o_sendslope_p0q6	    =	r_qav_sendslope_0[6];
    assign o_hithreshold_p0q6	=	r_qav_hthreshold_0[6];
    assign o_lothreshold_p0q6	=	r_qav_lthreshold_0[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_0[7]	<=	8'h00;
            r_qav_sendslope_0[7]	<=	8'h00;
            r_qav_hthreshold_0[7]	<=	16'h00;
            r_qav_lthreshold_0[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_0[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P0Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_0[7];
            r_qav_sendslope_0[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P0Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_0[7];
            r_qav_hthreshold_0[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P0Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_0[7];
            r_qav_lthreshold_0[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P0Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_0[7];
        end
    end

    assign o_idleSlope_p0q7	    =	r_qav_idleslope_0[7];
    assign o_sendslope_p0q7	    =	r_qav_sendslope_0[7];
    assign o_hithreshold_p0q7	=	r_qav_hthreshold_0[7];
    assign o_lothreshold_p0q7	=	r_qav_lthreshold_0[7];
`endif

`ifdef MAC1
    assign o_qav_en_1   =   r_qav_enable[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[0]	<=	8'h00;
            r_qav_sendslope_1[0]	<=	8'h00;
            r_qav_hthreshold_1[0]	<=	16'h00;
            r_qav_lthreshold_1[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[0];
            r_qav_sendslope_1[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[0];
            r_qav_hthreshold_1[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[0];
            r_qav_lthreshold_1[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[0];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q0	    =	r_qav_idleslope_1[0];
    assign o_sendslope_p1q0	    =	r_qav_sendslope_1[0];
    assign o_hithreshold_p1q0	=	r_qav_hthreshold_1[0];
    assign o_lothreshold_p1q0	=	r_qav_lthreshold_1[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[1]	<=	8'h00;
            r_qav_sendslope_1[1]	<=	8'h00;
            r_qav_hthreshold_1[1]	<=	16'h00;
            r_qav_lthreshold_1[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[1];
            r_qav_sendslope_1[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[1];
            r_qav_hthreshold_1[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[1];
            r_qav_lthreshold_1[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[1];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q1	    =	r_qav_idleslope_1[1];
    assign o_sendslope_p1q1	    =	r_qav_sendslope_1[1];
    assign o_hithreshold_p1q1	=	r_qav_hthreshold_1[1];
    assign o_lothreshold_p1q1	=	r_qav_lthreshold_1[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[2]	<=	8'h00;
            r_qav_sendslope_1[2]	<=	8'h00;
            r_qav_hthreshold_1[2]	<=	16'h00;
            r_qav_lthreshold_1[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[2];
            r_qav_sendslope_1[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[2];
            r_qav_hthreshold_1[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[2];
            r_qav_lthreshold_1[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[2];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q2	    =	r_qav_idleslope_1[2];
    assign o_sendslope_p1q2	    =	r_qav_sendslope_1[2];
    assign o_hithreshold_p1q2	=	r_qav_hthreshold_1[2];
    assign o_lothreshold_p1q2	=	r_qav_lthreshold_1[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[3]	<=	8'h00;
            r_qav_sendslope_1[3]	<=	8'h00;
            r_qav_hthreshold_1[3]	<=	16'h00;
            r_qav_lthreshold_1[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[3];
            r_qav_sendslope_1[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[3];
            r_qav_hthreshold_1[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[3];
            r_qav_lthreshold_1[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[3];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q3	    =	r_qav_idleslope_1[3];
    assign o_sendslope_p1q3	    =	r_qav_sendslope_1[3];
    assign o_hithreshold_p1q3	=	r_qav_hthreshold_1[3];
    assign o_lothreshold_p1q3	=	r_qav_lthreshold_1[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[4]	<=	8'h00;
            r_qav_sendslope_1[4]	<=	8'h00;
            r_qav_hthreshold_1[4]	<=	16'h00;
            r_qav_lthreshold_1[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[4];
            r_qav_sendslope_1[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[4];
            r_qav_hthreshold_1[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[4];
            r_qav_lthreshold_1[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[4];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q4	    =	r_qav_idleslope_1[4];
    assign o_sendslope_p1q4	    =	r_qav_sendslope_1[4];
    assign o_hithreshold_p1q4	=	r_qav_hthreshold_1[4];
    assign o_lothreshold_p1q4	=	r_qav_lthreshold_1[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[5]	<=	8'h00;
            r_qav_sendslope_1[5]	<=	8'h00;
            r_qav_hthreshold_1[5]	<=	16'h00;
            r_qav_lthreshold_1[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[5];
            r_qav_sendslope_1[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[5];
            r_qav_hthreshold_1[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[5];
            r_qav_lthreshold_1[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[5];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q5	    =	r_qav_idleslope_1[5];
    assign o_sendslope_p1q5	    =	r_qav_sendslope_1[5];
    assign o_hithreshold_p1q5	=	r_qav_hthreshold_1[5];
    assign o_lothreshold_p1q5	=	r_qav_lthreshold_1[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[6]	<=	8'h00;
            r_qav_sendslope_1[6]	<=	8'h00;
            r_qav_hthreshold_1[6]	<=	16'h00;
            r_qav_lthreshold_1[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[6];
            r_qav_sendslope_1[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[6];
            r_qav_hthreshold_1[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[6];
            r_qav_lthreshold_1[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[6];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q6	    =	r_qav_idleslope_1[6];
    assign o_sendslope_p1q6	    =	r_qav_sendslope_1[6];
    assign o_hithreshold_p1q6	=	r_qav_hthreshold_1[6];
    assign o_lothreshold_p1q6	=	r_qav_lthreshold_1[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_1[7]	<=	8'h00;
            r_qav_sendslope_1[7]	<=	8'h00;
            r_qav_hthreshold_1[7]	<=	16'h00;
            r_qav_lthreshold_1[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_1[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P1Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_1[7];
            r_qav_sendslope_1[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P1Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_1[7];
            r_qav_hthreshold_1[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P1Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_1[7];
            r_qav_lthreshold_1[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P1Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_1[7];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p1q7	    =	r_qav_idleslope_1[7];
    assign o_sendslope_p1q7	    =	r_qav_sendslope_1[7];
    assign o_hithreshold_p1q7	=	r_qav_hthreshold_1[7];
    assign o_lothreshold_p1q7	=	r_qav_lthreshold_1[7];
`endif

`ifdef MAC2
    assign o_qav_en_2   =   r_qav_enable[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[0]	<=	8'h00;
            r_qav_sendslope_2[0]	<=	8'h00;
            r_qav_hthreshold_2[0]	<=	16'h00;
            r_qav_lthreshold_2[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[0];
            r_qav_sendslope_2[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[0];
            r_qav_hthreshold_2[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[0];
            r_qav_lthreshold_2[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[0];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q0	    =	r_qav_idleslope_2[0];
    assign o_sendslope_p2q0	    =	r_qav_sendslope_2[0];
    assign o_hithreshold_p2q0	=	r_qav_hthreshold_2[0];
    assign o_lothreshold_p2q0	=	r_qav_lthreshold_2[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[1]	<=	8'h00;
            r_qav_sendslope_2[1]	<=	8'h00;
            r_qav_hthreshold_2[1]	<=	16'h00;
            r_qav_lthreshold_2[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[1];
            r_qav_sendslope_2[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[1];
            r_qav_hthreshold_2[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[1];
            r_qav_lthreshold_2[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[1];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q1	    =	r_qav_idleslope_2[1];
    assign o_sendslope_p2q1	    =	r_qav_sendslope_2[1];
    assign o_hithreshold_p2q1	=	r_qav_hthreshold_2[1];
    assign o_lothreshold_p2q1	=	r_qav_lthreshold_2[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[2]	<=	8'h00;
            r_qav_sendslope_2[2]	<=	8'h00;
            r_qav_hthreshold_2[2]	<=	16'h00;
            r_qav_lthreshold_2[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[2];
            r_qav_sendslope_2[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[2];
            r_qav_hthreshold_2[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[2];
            r_qav_lthreshold_2[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[2];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q2	    =	r_qav_idleslope_2[2];
    assign o_sendslope_p2q2	    =	r_qav_sendslope_2[2];
    assign o_hithreshold_p2q2	=	r_qav_hthreshold_2[2];
    assign o_lothreshold_p2q2	=	r_qav_lthreshold_2[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[3]	<=	8'h00;
            r_qav_sendslope_2[3]	<=	8'h00;
            r_qav_hthreshold_2[3]	<=	16'h00;
            r_qav_lthreshold_2[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[3];
            r_qav_sendslope_2[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[3];
            r_qav_hthreshold_2[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[3];
            r_qav_lthreshold_2[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[3];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q3	    =	r_qav_idleslope_2[3];
    assign o_sendslope_p2q3	    =	r_qav_sendslope_2[3];
    assign o_hithreshold_p2q3	=	r_qav_hthreshold_2[3];
    assign o_lothreshold_p2q3	=	r_qav_lthreshold_2[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[4]	<=	8'h00;
            r_qav_sendslope_2[4]	<=	8'h00;
            r_qav_hthreshold_2[4]	<=	16'h00;
            r_qav_lthreshold_2[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[4];
            r_qav_sendslope_2[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[4];
            r_qav_hthreshold_2[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[4];
            r_qav_lthreshold_2[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[4];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q4	    =	r_qav_idleslope_2[4];
    assign o_sendslope_p2q4	    =	r_qav_sendslope_2[4];
    assign o_hithreshold_p2q4	=	r_qav_hthreshold_2[4];
    assign o_lothreshold_p2q4	=	r_qav_lthreshold_2[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[5]	<=	8'h00;
            r_qav_sendslope_2[5]	<=	8'h00;
            r_qav_hthreshold_2[5]	<=	16'h00;
            r_qav_lthreshold_2[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[5];
            r_qav_sendslope_2[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[5];
            r_qav_hthreshold_2[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[5];
            r_qav_lthreshold_2[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[5];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q5	    =	r_qav_idleslope_2[5];
    assign o_sendslope_p2q5	    =	r_qav_sendslope_2[5];
    assign o_hithreshold_p2q5	=	r_qav_hthreshold_2[5];
    assign o_lothreshold_p2q5	=	r_qav_lthreshold_2[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[6]	<=	8'h00;
            r_qav_sendslope_2[6]	<=	8'h00;
            r_qav_hthreshold_2[6]	<=	16'h00;
            r_qav_lthreshold_2[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[6];
            r_qav_sendslope_2[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[6];
            r_qav_hthreshold_2[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[6];
            r_qav_lthreshold_2[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[6];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q6	    =	r_qav_idleslope_2[6];
    assign o_sendslope_p2q6	    =	r_qav_sendslope_2[6];
    assign o_hithreshold_p2q6	=	r_qav_hthreshold_2[6];
    assign o_lothreshold_p2q6	=	r_qav_lthreshold_2[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_2[7]	<=	8'h00;
            r_qav_sendslope_2[7]	<=	8'h00;
            r_qav_hthreshold_2[7]	<=	16'h00;
            r_qav_lthreshold_2[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_2[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P2Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_2[7];
            r_qav_sendslope_2[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P2Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_2[7];
            r_qav_hthreshold_2[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P2Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_2[7];
            r_qav_lthreshold_2[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P2Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_2[7];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p2q7	    =	r_qav_idleslope_2[7];
    assign o_sendslope_p2q7	    =	r_qav_sendslope_2[7];
    assign o_hithreshold_p2q7	=	r_qav_hthreshold_2[7];
    assign o_lothreshold_p2q7	=	r_qav_lthreshold_2[7];
`endif

`ifdef MAC3
    assign o_qav_en_3   =   r_qav_enable[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[0]	<=	8'h00;
            r_qav_sendslope_3[0]	<=	8'h00;
            r_qav_hthreshold_3[0]	<=	16'h00;
            r_qav_lthreshold_3[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[0];
            r_qav_sendslope_3[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[0];
            r_qav_hthreshold_3[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[0];
            r_qav_lthreshold_3[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[0];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q0	    =	r_qav_idleslope_3[0];
    assign o_sendslope_p3q0	    =	r_qav_sendslope_3[0];
    assign o_hthreshold_p3q0	=	r_qav_hthreshold_3[0];
    assign o_lothreshold_p3q0	=	r_qav_lthreshold_3[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[1]	<=	8'h00;
            r_qav_sendslope_3[1]	<=	8'h00;
            r_qav_hthreshold_3[1]	<=	16'h00;
            r_qav_lthreshold_3[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[1];
            r_qav_sendslope_3[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[1];
            r_qav_hthreshold_3[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[1];
            r_qav_lthreshold_3[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[1];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q1	    =	r_qav_idleslope_3[1];
    assign o_sendslope_p3q1	    =	r_qav_sendslope_3[1];
    assign o_hthreshold_p3q1	=	r_qav_hthreshold_3[1];
    assign o_lothreshold_p3q1	=	r_qav_lthreshold_3[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[2]	<=	8'h00;
            r_qav_sendslope_3[2]	<=	8'h00;
            r_qav_hthreshold_3[2]	<=	16'h00;
            r_qav_lthreshold_3[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[2];
            r_qav_sendslope_3[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[2];
            r_qav_hthreshold_3[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[2];
            r_qav_lthreshold_3[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[2];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q2	    =	r_qav_idleslope_3[2];
    assign o_sendslope_p3q2	    =	r_qav_sendslope_3[2];
    assign o_hthreshold_p3q2	=	r_qav_hthreshold_3[2];
    assign o_lothreshold_p3q2	=	r_qav_lthreshold_3[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[3]	<=	8'h00;
            r_qav_sendslope_3[3]	<=	8'h00;
            r_qav_hthreshold_3[3]	<=	16'h00;
            r_qav_lthreshold_3[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[3];
            r_qav_sendslope_3[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[3];
            r_qav_hthreshold_3[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[3];
            r_qav_lthreshold_3[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[3];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q3	    =	r_qav_idleslope_3[3];
    assign o_sendslope_p3q3	    =	r_qav_sendslope_3[3];
    assign o_hthreshold_p3q3	=	r_qav_hthreshold_3[3];
    assign o_lothreshold_p3q3	=	r_qav_lthreshold_3[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[4]	<=	8'h00;
            r_qav_sendslope_3[4]	<=	8'h00;
            r_qav_hthreshold_3[4]	<=	16'h00;
            r_qav_lthreshold_3[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[4];
            r_qav_sendslope_3[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[4];
            r_qav_hthreshold_3[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[4];
            r_qav_lthreshold_3[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[4];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q4	    =	r_qav_idleslope_3[4];
    assign o_sendslope_p3q4	    =	r_qav_sendslope_3[4];
    assign o_hthreshold_p3q4	=	r_qav_hthreshold_3[4];
    assign o_lothreshold_p3q4	=	r_qav_lthreshold_3[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[5]	<=	8'h00;
            r_qav_sendslope_3[5]	<=	8'h00;
            r_qav_hthreshold_3[5]	<=	16'h00;
            r_qav_lthreshold_3[5]	<=	16'h00;
        end else begin  
            r_qav_idleslope_3[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[5];
            r_qav_sendslope_3[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[5];
            r_qav_hthreshold_3[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[5];
            r_qav_lthreshold_3[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[5];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q5	    =	r_qav_idleslope_3[5];
    assign o_sendslope_p3q5	    =	r_qav_sendslope_3[5];
    assign o_hthreshold_p3q5	=	r_qav_hthreshold_3[5];
    assign o_lothreshold_p3q5	=	r_qav_lthreshold_3[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[6]	<=	8'h00;
            r_qav_sendslope_3[6]	<=	8'h00;
            r_qav_hthreshold_3[6]	<=	16'h00;
            r_qav_lthreshold_3[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[6];
            r_qav_sendslope_3[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[6];
            r_qav_hthreshold_3[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[6];
            r_qav_lthreshold_3[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[6];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q6	    =	r_qav_idleslope_3[6];
    assign o_sendslope_p3q6	    =	r_qav_sendslope_3[6];
    assign o_hthreshold_p3q6	=	r_qav_hthreshold_3[6];
    assign o_lothreshold_p3q6	=	r_qav_lthreshold_3[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_3[7]	<=	8'h00;
            r_qav_sendslope_3[7]	<=	8'h00;
            r_qav_hthreshold_3[7]	<=	16'h00;
            r_qav_lthreshold_3[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_3[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P3Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_3[7];
            r_qav_sendslope_3[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P3Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_3[7];
            r_qav_hthreshold_3[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P3Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_3[7];
            r_qav_lthreshold_3[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P3Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_3[7];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p3q7	    =	r_qav_idleslope_3[7];
    assign o_sendslope_p3q7	    =	r_qav_sendslope_3[7];
    assign o_hthreshold_p3q7	=	r_qav_hthreshold_3[7];
    assign o_lothreshold_p3q7	=	r_qav_lthreshold_3[7];
`endif

`ifdef MAC4
    assign o_qav_en_4   =   r_qav_enable[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[0]	<=	8'h00;
            r_qav_sendslope_4[0]	<=	8'h00;
            r_qav_hthreshold_4[0]	<=	16'h00;
            r_qav_lthreshold_4[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[0];
            r_qav_sendslope_4[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[0];
            r_qav_hthreshold_4[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[0];
            r_qav_lthreshold_4[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[0];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q0	    =	r_qav_idleslope_4[0];
    assign o_sendslope_p4q0	    =	r_qav_sendslope_4[0];
    assign o_hthreshold_p4q0	=	r_qav_hthreshold_4[0];
    assign o_lothreshold_p4q0	=	r_qav_lthreshold_4[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[1]	<=	8'h00;
            r_qav_sendslope_4[1]	<=	8'h00;
            r_qav_hthreshold_4[1]	<=	16'h00;
            r_qav_lthreshold_4[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[1];
            r_qav_sendslope_4[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[1];
            r_qav_hthreshold_4[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[1];
            r_qav_lthreshold_4[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[1];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q1	    =	r_qav_idleslope_4[1];
    assign o_sendslope_p4q1	    =	r_qav_sendslope_4[1];
    assign o_hthreshold_p4q1	=	r_qav_hthreshold_4[1];
    assign o_lothreshold_p4q1	=	r_qav_lthreshold_4[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[2]	<=	8'h00;
            r_qav_sendslope_4[2]	<=	8'h00;
            r_qav_hthreshold_4[2]	<=	16'h00;
            r_qav_lthreshold_4[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[2];
            r_qav_sendslope_4[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[2];
            r_qav_hthreshold_4[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[2];
            r_qav_lthreshold_4[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[2];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q2	    =	r_qav_idleslope_4[2];
    assign o_sendslope_p4q2	    =	r_qav_sendslope_4[2];
    assign o_hthreshold_p4q2	=	r_qav_hthreshold_4[2];
    assign o_lothreshold_p4q2	=	r_qav_lthreshold_4[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[3]	<=	8'h00;
            r_qav_sendslope_4[3]	<=	8'h00;
            r_qav_hthreshold_4[3]	<=	16'h00;
            r_qav_lthreshold_4[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[3];
            r_qav_sendslope_4[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[3];
            r_qav_hthreshold_4[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[3];
            r_qav_lthreshold_4[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[3];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q3	    =	r_qav_idleslope_4[3];
    assign o_sendslope_p4q3	    =	r_qav_sendslope_4[3];
    assign o_hthreshold_p4q3	=	r_qav_hthreshold_4[3];
    assign o_lothreshold_p4q3	=	r_qav_lthreshold_4[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[4]	<=	8'h00;
            r_qav_sendslope_4[4]	<=	8'h00;
            r_qav_hthreshold_4[4]	<=	16'h00;
            r_qav_lthreshold_4[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[4];
            r_qav_sendslope_4[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[4];
            r_qav_hthreshold_4[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[4];
            r_qav_lthreshold_4[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[4];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q4	    =	r_qav_idleslope_4[4];
    assign o_sendslope_p4q4	    =	r_qav_sendslope_4[4];
    assign o_hthreshold_p4q4	=	r_qav_hthreshold_4[4];
    assign o_lothreshold_p4q4	=	r_qav_lthreshold_4[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[5]	<=	8'h00;
            r_qav_sendslope_4[5]	<=	8'h00;
            r_qav_hthreshold_4[5]	<=	16'h00;
            r_qav_lthreshold_4[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[5];
            r_qav_sendslope_4[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[5];
            r_qav_hthreshold_4[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[5];
            r_qav_lthreshold_4[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[5];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q5	    =	r_qav_idleslope_4[5];
    assign o_sendslope_p4q5	    =	r_qav_sendslope_4[5];
    assign o_hthreshold_p4q5	=	r_qav_hthreshold_4[5];
    assign o_lothreshold_p4q5	=	r_qav_lthreshold_4[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[6]	<=	8'h00;
            r_qav_sendslope_4[6]	<=	8'h00;
            r_qav_hthreshold_4[6]	<=	16'h00;
            r_qav_lthreshold_4[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[6];
            r_qav_sendslope_4[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[6];
            r_qav_hthreshold_4[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[6];
            r_qav_lthreshold_4[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[6];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q6	    =	r_qav_idleslope_4[6];
    assign o_sendslope_p4q6	    =	r_qav_sendslope_4[6];
    assign o_hthreshold_p4q6	=	r_qav_hthreshold_4[6];
    assign o_lothreshold_p4q6	=	r_qav_lthreshold_4[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_4[7]	<=	8'h00;
            r_qav_sendslope_4[7]	<=	8'h00;
            r_qav_hthreshold_4[7]	<=	16'h00;
            r_qav_lthreshold_4[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_4[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P4Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_4[7];
            r_qav_sendslope_4[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P4Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_4[7];
            r_qav_hthreshold_4[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P4Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_4[7];
            r_qav_lthreshold_4[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P4Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_4[7];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p4q7	    =	r_qav_idleslope_4[7];
    assign o_sendslope_p4q7	    =	r_qav_sendslope_4[7];
    assign o_hthreshold_p4q7	=	r_qav_hthreshold_4[7];
    assign o_lothreshold_p4q7	=	r_qav_lthreshold_4[7];
`endif

`ifdef MAC5
    assign o_qav_en_5   =   r_qav_enable[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[0]	<=	8'h00;
            r_qav_sendslope_5[0]	<=	8'h00;
            r_qav_hthreshold_5[0]	<=	16'h00;
            r_qav_lthreshold_5[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[0];
            r_qav_sendslope_5[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[0];
            r_qav_hthreshold_5[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[0];
            r_qav_lthreshold_5[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[0];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q0	    =	r_qav_idleslope_5[0];
    assign o_sendslope_p5q0	    =	r_qav_sendslope_5[0];
    assign o_hthreshold_p5q0	=	r_qav_hthreshold_5[0];
    assign o_lothreshold_p5q0	=	r_qav_lthreshold_5[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[1]	<=	8'h00;
            r_qav_sendslope_5[1]	<=	8'h00;
            r_qav_hthreshold_5[1]	<=	16'h00;
            r_qav_lthreshold_5[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[1];
            r_qav_sendslope_5[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[1];
            r_qav_hthreshold_5[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[1];
            r_qav_lthreshold_5[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[1];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q1	    =	r_qav_idleslope_5[1];
    assign o_sendslope_p5q1	    =	r_qav_sendslope_5[1];
    assign o_hthreshold_p5q1	=	r_qav_hthreshold_5[1];
    assign o_lothreshold_p5q1	=	r_qav_lthreshold_5[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[2]	<=	8'h00;
            r_qav_sendslope_5[2]	<=	8'h00;
            r_qav_hthreshold_5[2]	<=	16'h00;
            r_qav_lthreshold_5[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[2];
            r_qav_sendslope_5[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[2];
            r_qav_hthreshold_5[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[2];
            r_qav_lthreshold_5[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[2];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q2	    =	r_qav_idleslope_5[2];
    assign o_sendslope_p5q2	    =	r_qav_sendslope_5[2];
    assign o_hthreshold_p5q2	=	r_qav_hthreshold_5[2];
    assign o_lothreshold_p5q2	=	r_qav_lthreshold_5[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[3]	<=	8'h00;
            r_qav_sendslope_5[3]	<=	8'h00;
            r_qav_hthreshold_5[3]	<=	16'h00;
            r_qav_lthreshold_5[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[3];
            r_qav_sendslope_5[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[3];
            r_qav_hthreshold_5[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[3];
            r_qav_lthreshold_5[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[3];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q3	    =	r_qav_idleslope_5[3];
    assign o_sendslope_p5q3	    =	r_qav_sendslope_5[3];
    assign o_hthreshold_p5q3	=	r_qav_hthreshold_5[3];
    assign o_lothreshold_p5q3	=	r_qav_lthreshold_5[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[4]	<=	8'h00;
            r_qav_sendslope_5[4]	<=	8'h00;
            r_qav_hthreshold_5[4]	<=	16'h00;
            r_qav_lthreshold_5[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[4];
            r_qav_sendslope_5[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[4];
            r_qav_hthreshold_5[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[4];
            r_qav_lthreshold_5[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[4];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q4	    =	r_qav_idleslope_5[4];
    assign o_sendslope_p5q4	    =	r_qav_sendslope_5[4];
    assign o_hthreshold_p5q4	=	r_qav_hthreshold_5[4];
    assign o_lothreshold_p5q4	=	r_qav_lthreshold_5[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[5]	<=	8'h00;
            r_qav_sendslope_5[5]	<=	8'h00;
            r_qav_hthreshold_5[5]	<=	16'h00;
            r_qav_lthreshold_5[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[5];
            r_qav_sendslope_5[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[5];
            r_qav_hthreshold_5[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[5];
            r_qav_lthreshold_5[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[5];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q5	    =	r_qav_idleslope_5[5];
    assign o_sendslope_p5q5	    =	r_qav_sendslope_5[5];
    assign o_hthreshold_p5q5	=	r_qav_hthreshold_5[5];
    assign o_lothreshold_p5q5	=	r_qav_lthreshold_5[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[6]	<=	8'h00;
            r_qav_sendslope_5[6]	<=	8'h00;
            r_qav_hthreshold_5[6]	<=	16'h00;
            r_qav_lthreshold_5[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[6];
            r_qav_sendslope_5[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[6];
            r_qav_hthreshold_5[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[6];
            r_qav_lthreshold_5[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[6];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q6	    =	r_qav_idleslope_5[6];
    assign o_sendslope_p5q6	    =	r_qav_sendslope_5[6];
    assign o_hthreshold_p5q6	=	r_qav_hthreshold_5[6];
    assign o_lothreshold_p5q6	=	r_qav_lthreshold_5[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_5[7]	<=	8'h00;
            r_qav_sendslope_5[7]	<=	8'h00;
            r_qav_hthreshold_5[7]	<=	16'h00;
            r_qav_lthreshold_5[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_5[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P5Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_5[7];
            r_qav_sendslope_5[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P5Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_5[7];
            r_qav_hthreshold_5[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P5Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_5[7];
            r_qav_lthreshold_5[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P5Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_5[7];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p5q7	    =	r_qav_idleslope_5[7];
    assign o_sendslope_p5q7	    =	r_qav_sendslope_5[7];
    assign o_hthreshold_p5q7	=	r_qav_hthreshold_5[7];
    assign o_lothreshold_p5q7	=	r_qav_lthreshold_5[7];
`endif

`ifdef MAC6
    assign o_qav_en_6   =   r_qav_enable[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[0]	<=	8'h00;
            r_qav_sendslope_6[0]	<=	8'h00;
            r_qav_hthreshold_6[0]	<=	16'h00;
            r_qav_lthreshold_6[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[0];
            r_qav_sendslope_6[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[0];
            r_qav_hthreshold_6[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[0];
            r_qav_lthreshold_6[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[0];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q0	    =	r_qav_idleslope_6[0];
    assign o_sendslope_p6q0	    =	r_qav_sendslope_6[0];
    assign o_hthreshold_p6q0	=	r_qav_hthreshold_6[0];
    assign o_lothreshold_p6q0	=	r_qav_lthreshold_6[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[1]	<=	8'h00;
            r_qav_sendslope_6[1]	<=	8'h00;
            r_qav_hthreshold_6[1]	<=	16'h00;
            r_qav_lthreshold_6[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[1];
            r_qav_sendslope_6[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[1];
            r_qav_hthreshold_6[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[1];
            r_qav_lthreshold_6[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[1];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q1	    =	r_qav_idleslope_6[1];
    assign o_sendslope_p6q1	    =	r_qav_sendslope_6[1];
    assign o_hthreshold_p6q1	=	r_qav_hthreshold_6[1];
    assign o_lothreshold_p6q1	=	r_qav_lthreshold_6[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[2]	<=	8'h00;
            r_qav_sendslope_6[2]	<=	8'h00;
            r_qav_hthreshold_6[2]	<=	16'h00;
            r_qav_lthreshold_6[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[2];
            r_qav_sendslope_6[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[2];
            r_qav_hthreshold_6[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[2];
            r_qav_lthreshold_6[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[2];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q2	    =	r_qav_idleslope_6[2];
    assign o_sendslope_p6q2	    =	r_qav_sendslope_6[2];
    assign o_hthreshold_p6q2	=	r_qav_hthreshold_6[2];
    assign o_lothreshold_p6q2	=	r_qav_lthreshold_6[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[3]	<=	8'h00;
            r_qav_sendslope_6[3]	<=	8'h00;
            r_qav_hthreshold_6[3]	<=	16'h00;
            r_qav_lthreshold_6[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[3];
            r_qav_sendslope_6[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[3];
            r_qav_hthreshold_6[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[3];
            r_qav_lthreshold_6[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[3];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q3	    =	r_qav_idleslope_6[3];
    assign o_sendslope_p6q3	    =	r_qav_sendslope_6[3];
    assign o_hthreshold_p6q3	=	r_qav_hthreshold_6[3];
    assign o_lothreshold_p6q3	=	r_qav_lthreshold_6[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[4]	<=	8'h00;
            r_qav_sendslope_6[4]	<=	8'h00;
            r_qav_hthreshold_6[4]	<=	16'h00;
            r_qav_lthreshold_6[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[4];
            r_qav_sendslope_6[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[4];
            r_qav_hthreshold_6[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[4];
            r_qav_lthreshold_6[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[4];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q4	    =	r_qav_idleslope_6[4];
    assign o_sendslope_p6q4	    =	r_qav_sendslope_6[4];
    assign o_hthreshold_p6q4	=	r_qav_hthreshold_6[4];
    assign o_lothreshold_p6q4	=	r_qav_lthreshold_6[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[5]	<=	8'h00;
            r_qav_sendslope_6[5]	<=	8'h00;
            r_qav_hthreshold_6[5]	<=	16'h00;
            r_qav_lthreshold_6[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[5];
            r_qav_sendslope_6[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[5];
            r_qav_hthreshold_6[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[5];
            r_qav_lthreshold_6[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[5];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q5	    =	r_qav_idleslope_6[5];
    assign o_sendslope_p6q5	    =	r_qav_sendslope_6[5];
    assign o_hthreshold_p6q5	=	r_qav_hthreshold_6[5];
    assign o_lothreshold_p6q5	=	r_qav_lthreshold_6[5];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[6]	<=	8'h00;
            r_qav_sendslope_6[6]	<=	8'h00;
            r_qav_hthreshold_6[6]	<=	16'h00;
            r_qav_lthreshold_6[6]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[6];
            r_qav_sendslope_6[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[6];
            r_qav_hthreshold_6[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[6];
            r_qav_lthreshold_6[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[6];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q6	    =	r_qav_idleslope_6[6];
    assign o_sendslope_p6q6	    =	r_qav_sendslope_6[6];
    assign o_hthreshold_p6q6	=	r_qav_hthreshold_6[6];
    assign o_lothreshold_p6q6	=	r_qav_lthreshold_6[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_6[7]	<=	8'h00;
            r_qav_sendslope_6[7]	<=	8'h00;
            r_qav_hthreshold_6[7]	<=	16'h00;
            r_qav_lthreshold_6[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_6[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P6Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_6[7];
            r_qav_sendslope_6[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P6Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_6[7];
            r_qav_hthreshold_6[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P6Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_6[7];
            r_qav_lthreshold_6[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P6Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_6[7];
        end                                                                                                                                                                        
    end

    assign o_idleSlope_p6q7	    =	r_qav_idleslope_6[7];
    assign o_sendslope_p6q7	    =	r_qav_sendslope_6[7];
    assign o_hthreshold_p6q7	=	r_qav_hthreshold_6[7];
    assign o_lothreshold_p6q7	=	r_qav_lthreshold_6[7];
`endif

`ifdef MAC7
    assign o_qav_en_7   =   r_qav_enable[7];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[0]	<=	8'h00;
            r_qav_sendslope_7[0]	<=	8'h00;
            r_qav_hthreshold_7[0]	<=	16'h00;
            r_qav_lthreshold_7[0]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q0 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[0];
            r_qav_sendslope_7[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q0 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[0];
            r_qav_hthreshold_7[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q0 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[0];
            r_qav_lthreshold_7[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q0 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[0];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q0	    =	r_qav_idleslope_7[0];
    assign o_sendslope_p7q0	    =	r_qav_sendslope_7[0];
    assign o_hthreshold_p7q0	=	r_qav_hthreshold_7[0];
    assign o_lothreshold_p7q0	=	r_qav_lthreshold_7[0];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[1]	<=	8'h00;
            r_qav_sendslope_7[1]	<=	8'h00;
            r_qav_hthreshold_7[1]	<=	16'h00;
            r_qav_lthreshold_7[1]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q1 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[1];
            r_qav_sendslope_7[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q1 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[1];
            r_qav_hthreshold_7[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q1 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[1];
            r_qav_lthreshold_7[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q1 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[1];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q1	    =	r_qav_idleslope_7[1];
    assign o_sendslope_p7q1	    =	r_qav_sendslope_7[1];
    assign o_hthreshold_p7q1	=	r_qav_hthreshold_7[1];
    assign o_lothreshold_p7q1	=	r_qav_lthreshold_7[1];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[2]	<=	8'h00;
            r_qav_sendslope_7[2]	<=	8'h00;
            r_qav_hthreshold_7[2]	<=	16'h00;
            r_qav_lthreshold_7[2]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q2 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[2];
            r_qav_sendslope_7[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q2 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[2];
            r_qav_hthreshold_7[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q2 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[2];
            r_qav_lthreshold_7[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q2 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[2];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q2	    =	r_qav_idleslope_7[2];
    assign o_sendslope_p7q2	    =	r_qav_sendslope_7[2];
    assign o_hthreshold_p7q2	=	r_qav_hthreshold_7[2];
    assign o_lothreshold_p7q2	=	r_qav_lthreshold_7[2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[3]	<=	8'h00;
            r_qav_sendslope_7[3]	<=	8'h00;
            r_qav_hthreshold_7[3]	<=	16'h00;
            r_qav_lthreshold_7[3]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q3 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[3];
            r_qav_sendslope_7[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q3 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[3];
            r_qav_hthreshold_7[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q3 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[3];
            r_qav_lthreshold_7[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q3 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[3];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q3	    =	r_qav_idleslope_7[3];
    assign o_sendslope_p7q3	    =	r_qav_sendslope_7[3];
    assign o_hthreshold_p7q3	=	r_qav_hthreshold_7[3];
    assign o_lothreshold_p7q3	=	r_qav_lthreshold_7[3];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[4]	<=	8'h00;
            r_qav_sendslope_7[4]	<=	8'h00;
            r_qav_hthreshold_7[4]	<=	16'h00;
            r_qav_lthreshold_7[4]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q4 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[4];
            r_qav_sendslope_7[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q4 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[4];
            r_qav_hthreshold_7[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q4 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[4];
            r_qav_lthreshold_7[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q4 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[4];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q4	    =	r_qav_idleslope_7[4];
    assign o_sendslope_p7q4	    =	r_qav_sendslope_7[4];
    assign o_hthreshold_p7q4	=	r_qav_hthreshold_7[4];
    assign o_lothreshold_p7q4	=	r_qav_lthreshold_7[4];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[5]	<=	8'h00;
            r_qav_sendslope_7[5]	<=	8'h00;
            r_qav_hthreshold_7[5]	<=	16'h00;
            r_qav_lthreshold_7[5]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q5 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[5];
            r_qav_sendslope_7[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q5 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[5];
            r_qav_hthreshold_7[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q5 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[5];
            r_qav_lthreshold_7[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q5 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[5];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q5	    =	r_qav_idleslope_7[5];
    assign o_sendslope_p7q5	    =	r_qav_sendslope_7[5];
    assign o_hthreshold_p7q5	=	r_qav_hthreshold_7[5];
    assign o_lothreshold_p7q5	=	r_qav_lthreshold_7[5];

        always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[6]	<=	8'h00;
            r_qav_sendslope_7[6]	<=	8'h00;
            r_qav_hthreshold_7[6]	<=	16'h00;
            r_qav_lthreshold_7[6]	<=	16'h00;
        end else begin  
            r_qav_idleslope_7[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q6 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[6];
            r_qav_sendslope_7[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q6 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[6];
            r_qav_hthreshold_7[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q6 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[6];
            r_qav_lthreshold_7[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q6 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[6];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q6	    =	r_qav_idleslope_7[6];
    assign o_sendslope_p7q6	    =	r_qav_sendslope_7[6];
    assign o_hthreshold_p7q6	=	r_qav_hthreshold_7[6];
    assign o_lothreshold_p7q6	=	r_qav_lthreshold_7[6];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_qav_idleslope_7[7]	<=	8'h00;
            r_qav_sendslope_7[7]	<=	8'h00;
            r_qav_hthreshold_7[7]	<=	16'h00;
            r_qav_lthreshold_7[7]	<=	16'h00;
        end else begin
            r_qav_idleslope_7[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_IDLESLOPE_P7Q7 ? r_reg_bus_data[7:0] : r_qav_idleslope_7[7];
            r_qav_sendslope_7[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_SENDSLOPE_P7Q7 ? r_reg_bus_data[7:0] : r_qav_sendslope_7[7];
            r_qav_hthreshold_7[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_HTHRESHOLD_P7Q7 ? r_reg_bus_data[15:0] : r_qav_hthreshold_7[7];
            r_qav_lthreshold_7[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_LTHRESHOLD_P7Q7 ? r_reg_bus_data[15:0] : r_qav_lthreshold_7[7];
        end                                                                                                                                                                        
    end
    assign o_idleSlope_p7q7	    =	r_qav_idleslope_7[7];
    assign o_sendslope_p7q7	    =	r_qav_sendslope_7[7];
    assign o_hthreshold_p7q7	=	r_qav_hthreshold_7[7];
    assign o_lothreshold_p7q7	=	r_qav_lthreshold_7[7];
`endif

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_qav_config_vld	<=	8'h00;
    end else begin
        r_qav_config_vld[0]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[0] : 1'b0;
        r_qav_config_vld[1]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[1] : 1'b0;
        r_qav_config_vld[2]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[2] : 1'b0;
        r_qav_config_vld[3]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[3] : 1'b0;
        r_qav_config_vld[4]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[4] : 1'b0;
        r_qav_config_vld[5]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[5] : 1'b0;
        r_qav_config_vld[6]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[6] : 1'b0;
        r_qav_config_vld[7]	<=	r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QAV_CONFIG_VLD ? r_reg_bus_data[7] : 1'b0;
	end                                                                                                                                                                        
end

assign o_config_vld_0 = r_qav_config_vld[0];
assign o_config_vld_1 = r_qav_config_vld[1];
assign o_config_vld_2 = r_qav_config_vld[2];
assign o_config_vld_3 = r_qav_config_vld[3];
assign o_config_vld_4 = r_qav_config_vld[4];
assign o_config_vld_5 = r_qav_config_vld[5];
assign o_config_vld_6 = r_qav_config_vld[6];
assign o_config_vld_7 = r_qav_config_vld[7];
/*========================================  qav¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_qos_enable        <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else begin
        r_qos_enable        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_ENABLE ? r_reg_bus_data : r_qos_enable;
    end
end

assign o_qos_en_0 = r_qos_enable[0];
assign o_qos_en_1 = r_qos_enable[1];
assign o_qos_en_2 = r_qos_enable[2];
assign o_qos_en_3 = r_qos_enable[3];
assign o_qos_en_4 = r_qos_enable[4];
assign o_qos_en_5 = r_qos_enable[5];
assign o_qos_en_6 = r_qos_enable[6];
assign o_qos_en_7 = r_qos_enable[7];

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_qos_sche_0        <= 4'b0001;
		r_qos_sche_1        <= 4'b0001;
		r_qos_sche_2        <= 4'b0001;
		r_qos_sche_3        <= 4'b0001;
		r_qos_sche_4        <= 4'b0001;
		r_qos_sche_5        <= 4'b0001;
		r_qos_sche_6        <= 4'b0001;
		r_qos_sche_7        <= 4'b0001;
    end else begin
        r_qos_sche_0        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_0 ? r_reg_bus_data : r_qos_sche_0;
		r_qos_sche_1        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_1 ? r_reg_bus_data : r_qos_sche_1;
		r_qos_sche_2        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_2 ? r_reg_bus_data : r_qos_sche_2;
		r_qos_sche_3        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_3 ? r_reg_bus_data : r_qos_sche_3;
		r_qos_sche_4        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_4 ? r_reg_bus_data : r_qos_sche_4;
		r_qos_sche_5        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_5 ? r_reg_bus_data : r_qos_sche_5;
		r_qos_sche_6        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_6 ? r_reg_bus_data : r_qos_sche_6;
		r_qos_sche_7        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QOS_SCHMODE_7 ? r_reg_bus_data : r_qos_sche_7;
    end
end

assign o_qos_sch_0 = r_qos_sche_0;
assign o_qos_sch_1 = r_qos_sche_1;
assign o_qos_sch_2 = r_qos_sche_2;
assign o_qos_sch_3 = r_qos_sche_3;
assign o_qos_sch_4 = r_qos_sche_4;
assign o_qos_sch_5 = r_qos_sche_5;
assign o_qos_sch_6 = r_qos_sche_6;
assign o_qos_sch_7 = r_qos_sche_7;

/*======================================  qbu_tx¼Ä´æÆ÷Ð´¿ØÖÆÂß¼­ ======================================*/
// Assign internal regs to output wires
assign o_verify_enabled_0           = r_verify_enabled_0;
assign o_min_frag_size_0            = r_min_frag_size_0;
assign o_min_frag_size_vld_0        = r_min_frag_size_valid_0;
assign o_verify_timer_0             = r_verify_timer_0;
assign o_verify_timer_vld_0         = r_verify_timer_valid_0;
assign o_ipg_timer_0                = r_ipg_timer_0;
assign o_ipg_timer_vld_0            = r_ipg_timer_valid_0;
assign o_reset_0                    = r_reset_0;
assign o_start_verify_0             = r_start_verify_0;
assign o_clear_verify_0             = r_clear_verify_0;
assign o_watchdog_timer_0           = {r_watchdog_timer_h_0,r_watchdog_timer_l_0};
assign o_watchdog_timer_vld_0       = r_watchdog_timer_l_valid_0  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_0          <= 1'b1;
        r_min_frag_size_0           <= 8'd46;
        r_min_frag_size_valid_0     <= 1'b0;
        r_verify_timer_0            <= 8'd10;
        r_verify_timer_valid_0      <= 1'b0;
        r_ipg_timer_0               <= 8'h12;
        r_ipg_timer_valid_0         <= 1'b0;
        r_reset_0                   <= 1'b0;
        r_start_verify_0            <= 1'b1;
        r_clear_verify_0            <= 1'b0;
        r_watchdog_timer_l_0        <= 16'he848; 
        r_watchdog_timer_h_0        <= 8'd1;
        r_watchdog_timer_l_valid_0  <= 1'b0;
        r_watchdog_timer_h_valid_0  <= 1'b0;
    end else begin
        r_verify_enabled_0          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_0 ? r_reg_bus_data[0] : r_verify_enabled_0;
        r_min_frag_size_0           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_0 ? r_reg_bus_data[7:0] : r_min_frag_size_0;
        r_min_frag_size_valid_0     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_0 ? 1'b1 : 1'b0;
        r_verify_timer_0            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_0 ? r_reg_bus_data[7:0] : r_verify_timer_0;
        r_verify_timer_valid_0      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_0 ? 1'b1 : 1'b0;
        r_ipg_timer_0               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_0 ? r_reg_bus_data[7:0] : r_ipg_timer_0;
        r_ipg_timer_valid_0         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_0 ? 1'b1 : 1'b0;
        r_reset_0                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_0 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_0            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_0 ? r_reg_bus_data[0] : 
                                       r_start_verify_0 == 1'b1 ? 1'b0 : r_start_verify_0;
        r_clear_verify_0            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_0 ? r_reg_bus_data[1] : 
                                       r_clear_verify_0 == 1'b1 ? 1'b0 : r_clear_verify_0;
        r_watchdog_timer_l_0        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_0 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_0; 
        r_watchdog_timer_h_0        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_0 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_0; 
        r_watchdog_timer_l_valid_0  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_0 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_0  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_0 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_1           = r_verify_enabled_1;
assign o_min_frag_size_1            = r_min_frag_size_1;
assign o_min_frag_size_vld_1        = r_min_frag_size_valid_1;
assign o_verify_timer_1             = r_verify_timer_1;
assign o_verify_timer_vld_1         = r_verify_timer_valid_1;
assign o_ipg_timer_1                = r_ipg_timer_1;
assign o_ipg_timer_vld_1            = r_ipg_timer_valid_1;
assign o_reset_1                    = r_reset_1;
assign o_start_verify_1             = r_start_verify_1;
assign o_clear_verify_1             = r_clear_verify_1;
assign o_watchdog_timer_1           = {r_watchdog_timer_h_1,r_watchdog_timer_l_1};
assign o_watchdog_timer_vld_1       = r_watchdog_timer_l_valid_1  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_1          <= 1'b1;
        r_min_frag_size_1           <= 8'd46;
        r_min_frag_size_valid_1     <= 1'b0;
        r_verify_timer_1            <= 8'd10;
        r_verify_timer_valid_1      <= 1'b0;
        r_ipg_timer_1               <= 8'h12;
        r_ipg_timer_valid_1         <= 1'b0;
        r_reset_1                   <= 1'b0;
        r_start_verify_1            <= 1'b1;
        r_clear_verify_1            <= 1'b0;
        r_watchdog_timer_l_1        <= 16'he848; 
        r_watchdog_timer_h_1        <= 8'd1;
        r_watchdog_timer_l_valid_1  <= 1'b0;
        r_watchdog_timer_h_valid_1  <= 1'b0;
    end else begin
        r_verify_enabled_1          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_1 ? r_reg_bus_data[0] : r_verify_enabled_1;
        r_min_frag_size_1           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_1 ? r_reg_bus_data[7:0] : r_min_frag_size_1;
        r_min_frag_size_valid_1     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_1 ? 1'b1 : 1'b0;
        r_verify_timer_1            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_1 ? r_reg_bus_data[7:0] : r_verify_timer_1;
        r_verify_timer_valid_1      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_1 ? 1'b1 : 1'b0;
        r_ipg_timer_1               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_1 ? r_reg_bus_data[7:0] : r_ipg_timer_1;
        r_ipg_timer_valid_1         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_1 ? 1'b1 : 1'b0;
        r_reset_1                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_1 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_1            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_1 ? r_reg_bus_data[0] : 
                                       r_start_verify_1 == 1'b1 ? 1'b0 : r_start_verify_1;
        r_clear_verify_1            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_1 ? r_reg_bus_data[1] : 
                                       r_clear_verify_1 == 1'b1 ? 1'b0 : r_clear_verify_1;
        r_watchdog_timer_l_1        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_1 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_1; 
        r_watchdog_timer_h_1        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_1 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_1; 
        r_watchdog_timer_l_valid_1  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_1 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_1  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_1 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_2           = r_verify_enabled_2;
assign o_min_frag_size_2            = r_min_frag_size_2;
assign o_min_frag_size_vld_2        = r_min_frag_size_valid_2;
assign o_verify_timer_2             = r_verify_timer_2;
assign o_verify_timer_vld_2         = r_verify_timer_valid_2;
assign o_ipg_timer_2                = r_ipg_timer_2;
assign o_ipg_timer_vld_2            = r_ipg_timer_valid_2;
assign o_reset_2                    = r_reset_2;
assign o_start_verify_2             = r_start_verify_2;
assign o_clear_verify_2             = r_clear_verify_2;
assign o_watchdog_timer_2           = {r_watchdog_timer_h_2,r_watchdog_timer_l_2};
assign o_watchdog_timer_vld_2       = r_watchdog_timer_l_valid_2  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_2          <= 1'b1;
        r_min_frag_size_2           <= 8'd46;
        r_min_frag_size_valid_2     <= 1'b0;
        r_verify_timer_2            <= 8'd10;
        r_verify_timer_valid_2      <= 1'b0;
        r_ipg_timer_2               <= 8'h12;
        r_ipg_timer_valid_2         <= 1'b0;
        r_reset_2                   <= 1'b0;
        r_start_verify_2            <= 1'b1;
        r_clear_verify_2            <= 1'b0;
        r_watchdog_timer_l_2        <= 16'he848; 
        r_watchdog_timer_h_2        <= 8'd1;
        r_watchdog_timer_l_valid_2  <= 1'b0;
        r_watchdog_timer_h_valid_2  <= 1'b0;
    end else begin
        r_verify_enabled_2          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_2 ? r_reg_bus_data[0] : r_verify_enabled_2;
        r_min_frag_size_2           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_2 ? r_reg_bus_data[7:0] : r_min_frag_size_2;
        r_min_frag_size_valid_2     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_2 ? 1'b1 : 1'b0;
        r_verify_timer_2            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_2 ? r_reg_bus_data[7:0] : r_verify_timer_2;
        r_verify_timer_valid_2      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_2 ? 1'b1 : 1'b0;
        r_ipg_timer_2               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_2 ? r_reg_bus_data[7:0] : r_ipg_timer_2;
        r_ipg_timer_valid_2         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_2 ? 1'b1 : 1'b0;
        r_reset_2                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_2 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_2            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_2 ? r_reg_bus_data[0] : 
                                       r_start_verify_2 == 1'b1 ? 1'b0 : r_start_verify_2;
        r_clear_verify_2            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_2 ? r_reg_bus_data[1] : 
                                       r_clear_verify_2 == 1'b1 ? 1'b0 : r_clear_verify_2;
        r_watchdog_timer_l_2        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_2 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_2; 
        r_watchdog_timer_h_2        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_2 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_2; 
        r_watchdog_timer_l_valid_2  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_2 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_2  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_2 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_3           = r_verify_enabled_3;
assign o_min_frag_size_3            = r_min_frag_size_3;
assign o_min_frag_size_vld_3        = r_min_frag_size_valid_3;
assign o_verify_timer_3             = r_verify_timer_3;
assign o_verify_timer_vld_3         = r_verify_timer_valid_3;
assign o_ipg_timer_3                = r_ipg_timer_3;
assign o_ipg_timer_vld_3            = r_ipg_timer_valid_3;
assign o_reset_3                    = r_reset_3;
assign o_start_verify_3             = r_start_verify_3;
assign o_clear_verify_3             = r_clear_verify_3;
assign o_watchdog_timer_3           = {r_watchdog_timer_h_3,r_watchdog_timer_l_3};
assign o_watchdog_timer_vld_3       = r_watchdog_timer_l_valid_3  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_3          <= 1'b1;
        r_min_frag_size_3           <= 8'd46;
        r_min_frag_size_valid_3     <= 1'b0;
        r_verify_timer_3            <= 8'd10;
        r_verify_timer_valid_3      <= 1'b0;
        r_ipg_timer_3               <= 8'h12;
        r_ipg_timer_valid_3         <= 1'b0;
        r_reset_3                   <= 1'b0;
        r_start_verify_3            <= 1'b1;
        r_clear_verify_3            <= 1'b0;
        r_watchdog_timer_l_3        <= 16'he848; 
        r_watchdog_timer_h_3        <= 8'd1;
        r_watchdog_timer_l_valid_3  <= 1'b0;
        r_watchdog_timer_h_valid_3  <= 1'b0;
    end else begin
        r_verify_enabled_3          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_3 ? r_reg_bus_data[0] : r_verify_enabled_3;
        r_min_frag_size_3           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_3 ? r_reg_bus_data[7:0] : r_min_frag_size_3;
        r_min_frag_size_valid_3     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_3 ? 1'b1 : 1'b0;
        r_verify_timer_3            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_3 ? r_reg_bus_data[7:0] : r_verify_timer_3;
        r_verify_timer_valid_3      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_3 ? 1'b1 : 1'b0;
        r_ipg_timer_3               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_3 ? r_reg_bus_data[7:0] : r_ipg_timer_3;
        r_ipg_timer_valid_3         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_3 ? 1'b1 : 1'b0;
        r_reset_3                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_3 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_3            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_3 ? r_reg_bus_data[0] : 
                                       r_start_verify_3 == 1'b1 ? 1'b0 : r_start_verify_3;
        r_clear_verify_3            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_3 ? r_reg_bus_data[1] : 
                                       r_clear_verify_3 == 1'b1 ? 1'b0 : r_clear_verify_3;
        r_watchdog_timer_l_3        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_3 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_3; 
        r_watchdog_timer_h_3        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_3 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_3; 
        r_watchdog_timer_l_valid_3  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_3 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_3  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_3 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_4           = r_verify_enabled_4;
assign o_min_frag_size_4            = r_min_frag_size_4;
assign o_min_frag_size_vld_4        = r_min_frag_size_valid_4;
assign o_verify_timer_4             = r_verify_timer_4;
assign o_verify_timer_vld_4         = r_verify_timer_valid_4;
assign o_ipg_timer_4                = r_ipg_timer_4;
assign o_ipg_timer_vld_4            = r_ipg_timer_valid_4;
assign o_reset_4                    = r_reset_4;
assign o_start_verify_4             = r_start_verify_4;
assign o_clear_verify_4             = r_clear_verify_4;
assign o_watchdog_timer_4           = {r_watchdog_timer_h_4,r_watchdog_timer_l_4};
assign o_watchdog_timer_vld_4       = r_watchdog_timer_l_valid_4  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_4          <= 1'b1;
        r_min_frag_size_4           <= 8'd46;
        r_min_frag_size_valid_4     <= 1'b0;
        r_verify_timer_4            <= 8'd10;
        r_verify_timer_valid_4      <= 1'b0;
        r_ipg_timer_4               <= 8'h12;
        r_ipg_timer_valid_4         <= 1'b0;
        r_reset_4                   <= 1'b0;
        r_start_verify_4            <= 1'b1;
        r_clear_verify_4            <= 1'b0;
        r_watchdog_timer_l_4        <= 16'he848; 
        r_watchdog_timer_h_4        <= 8'd1;
        r_watchdog_timer_l_valid_4  <= 1'b0;
        r_watchdog_timer_h_valid_4  <= 1'b0;
    end else begin
        r_verify_enabled_4          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_4 ? r_reg_bus_data[0] : r_verify_enabled_4;
        r_min_frag_size_4           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_4 ? r_reg_bus_data[7:0] : r_min_frag_size_4;
        r_min_frag_size_valid_4     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_4 ? 1'b1 : 1'b0;
        r_verify_timer_4            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_4 ? r_reg_bus_data[7:0] : r_verify_timer_4;
        r_verify_timer_valid_4      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_4 ? 1'b1 : 1'b0;
        r_ipg_timer_4               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_4 ? r_reg_bus_data[7:0] : r_ipg_timer_4;
        r_ipg_timer_valid_4         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_4 ? 1'b1 : 1'b0;
        r_reset_4                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_4 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_4            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_4 ? r_reg_bus_data[0] : 
                                       r_start_verify_4 == 1'b1 ? 1'b0 : r_start_verify_4;
        r_clear_verify_4            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_4 ? r_reg_bus_data[1] : 
                                       r_clear_verify_4 == 1'b1 ? 1'b0 : r_clear_verify_4;
        r_watchdog_timer_l_4        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_4 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_4; 
        r_watchdog_timer_h_4        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_4 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_4; 
        r_watchdog_timer_l_valid_4  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_4 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_4  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_4 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_5           = r_verify_enabled_5;
assign o_min_frag_size_5            = r_min_frag_size_5;
assign o_min_frag_size_vld_5        = r_min_frag_size_valid_5;
assign o_verify_timer_5             = r_verify_timer_5;
assign o_verify_timer_vld_5         = r_verify_timer_valid_5;
assign o_ipg_timer_5                = r_ipg_timer_5;
assign o_ipg_timer_vld_5            = r_ipg_timer_valid_5;
assign o_reset_5                    = r_reset_5;
assign o_start_verify_5             = r_start_verify_5;
assign o_clear_verify_5             = r_clear_verify_5;
assign o_watchdog_timer_5           = {r_watchdog_timer_h_5,r_watchdog_timer_l_5};
assign o_watchdog_timer_vld_5       = r_watchdog_timer_l_valid_5  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_5          <= 1'b1;
        r_min_frag_size_5           <= 8'd46;
        r_min_frag_size_valid_5     <= 1'b0;
        r_verify_timer_5            <= 8'd10;
        r_verify_timer_valid_5      <= 1'b0;
        r_ipg_timer_5               <= 8'h12;
        r_ipg_timer_valid_5         <= 1'b0;
        r_reset_5                   <= 1'b0;
        r_start_verify_5            <= 1'b1;
        r_clear_verify_5            <= 1'b0;
        r_watchdog_timer_l_5        <= 16'he848; 
        r_watchdog_timer_h_5        <= 8'd1;
        r_watchdog_timer_l_valid_5  <= 1'b0;
        r_watchdog_timer_h_valid_5  <= 1'b0;
    end else begin
        r_verify_enabled_5          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_5 ? r_reg_bus_data[0] : r_verify_enabled_5;
        r_min_frag_size_5           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_5 ? r_reg_bus_data[7:0] : r_min_frag_size_5;
        r_min_frag_size_valid_5     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_5 ? 1'b1 : 1'b0;
        r_verify_timer_5            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_5 ? r_reg_bus_data[7:0] : r_verify_timer_5;
        r_verify_timer_valid_5      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_5 ? 1'b1 : 1'b0;
        r_ipg_timer_5               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_5 ? r_reg_bus_data[7:0] : r_ipg_timer_5;
        r_ipg_timer_valid_5         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_5 ? 1'b1 : 1'b0;
        r_reset_5                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_5 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_5            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_5 ? r_reg_bus_data[0] : 
                                       r_start_verify_5 == 1'b1 ? 1'b0 : r_start_verify_5;
        r_clear_verify_5            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_5 ? r_reg_bus_data[1] : 
                                       r_clear_verify_5 == 1'b1 ? 1'b0 : r_clear_verify_5;
        r_watchdog_timer_l_5        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_5 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_5; 
        r_watchdog_timer_h_5        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_5 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_5; 
        r_watchdog_timer_l_valid_5  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_5 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_5  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_5 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_6           = r_verify_enabled_6;
assign o_min_frag_size_6            = r_min_frag_size_6;
assign o_min_frag_size_vld_6        = r_min_frag_size_valid_6;
assign o_verify_timer_6             = r_verify_timer_6;
assign o_verify_timer_vld_6         = r_verify_timer_valid_6;
assign o_ipg_timer_6                = r_ipg_timer_6;
assign o_ipg_timer_vld_6            = r_ipg_timer_valid_6;
assign o_reset_6                    = r_reset_6;
assign o_start_verify_6             = r_start_verify_6;
assign o_clear_verify_6             = r_clear_verify_6;
assign o_watchdog_timer_6           = {r_watchdog_timer_h_6,r_watchdog_timer_l_6};
assign o_watchdog_timer_vld_6       = r_watchdog_timer_l_valid_6  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_6          <= 1'b1;
        r_min_frag_size_6           <= 8'd46;
        r_min_frag_size_valid_6     <= 1'b0;
        r_verify_timer_6            <= 8'd10;
        r_verify_timer_valid_6      <= 1'b0;
        r_ipg_timer_6               <= 8'h12;
        r_ipg_timer_valid_6         <= 1'b0;
        r_reset_6                   <= 1'b0;
        r_start_verify_6            <= 1'b1;
        r_clear_verify_6            <= 1'b0;
        r_watchdog_timer_l_6        <= 16'he848; 
        r_watchdog_timer_h_6        <= 8'd1;
        r_watchdog_timer_l_valid_6  <= 1'b0;
        r_watchdog_timer_h_valid_6  <= 1'b0;
    end else begin
        r_verify_enabled_6          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_6 ? r_reg_bus_data[0] : r_verify_enabled_6;
        r_min_frag_size_6           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_6 ? r_reg_bus_data[7:0] : r_min_frag_size_6;
        r_min_frag_size_valid_6     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_6 ? 1'b1 : 1'b0;
        r_verify_timer_6            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_6 ? r_reg_bus_data[7:0] : r_verify_timer_6;
        r_verify_timer_valid_6      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_6 ? 1'b1 : 1'b0;
        r_ipg_timer_6               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_6 ? r_reg_bus_data[7:0] : r_ipg_timer_6;
        r_ipg_timer_valid_6         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_6 ? 1'b1 : 1'b0;
        r_reset_6                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_6 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_6            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_6 ? r_reg_bus_data[0] : 
                                       r_start_verify_6 == 1'b1 ? 1'b0 : r_start_verify_6;
        r_clear_verify_6            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_6 ? r_reg_bus_data[1] : 
                                       r_clear_verify_6 == 1'b1 ? 1'b0 : r_clear_verify_6;
        r_watchdog_timer_l_6        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_6 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_6; 
        r_watchdog_timer_h_6        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_6 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_6; 
        r_watchdog_timer_l_valid_6  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_6 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_6  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_6 ? 1'b1 : 1'b0;
    end
end

// Assign internal regs to output wires
assign o_verify_enabled_7           = r_verify_enabled_7;
assign o_min_frag_size_7            = r_min_frag_size_7;
assign o_min_frag_size_vld_7        = r_min_frag_size_valid_7;
assign o_verify_timer_7             = r_verify_timer_7;
assign o_verify_timer_vld_7         = r_verify_timer_valid_7;
assign o_ipg_timer_7                = r_ipg_timer_7;
assign o_ipg_timer_vld_7            = r_ipg_timer_valid_7;
assign o_reset_7                    = r_reset_7;
assign o_start_verify_7             = r_start_verify_7;
assign o_clear_verify_7             = r_clear_verify_7;
assign o_watchdog_timer_7           = {r_watchdog_timer_h_7,r_watchdog_timer_l_7};
assign o_watchdog_timer_vld_7       = r_watchdog_timer_l_valid_7  ;

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_verify_enabled_7          <= 1'b1;
        r_min_frag_size_7           <= 8'd46;
        r_min_frag_size_valid_7     <= 1'b0;
        r_verify_timer_7            <= 8'd10;
        r_verify_timer_valid_7      <= 1'b0;
        r_ipg_timer_7               <= 8'h12;
        r_ipg_timer_valid_7         <= 1'b0;
        r_reset_7                   <= 1'b0;
        r_start_verify_7            <= 1'b1;
        r_clear_verify_7            <= 1'b0;
        r_watchdog_timer_l_7        <= 16'he848; 
        r_watchdog_timer_h_7        <= 8'd1;
        r_watchdog_timer_l_valid_7  <= 1'b0;
        r_watchdog_timer_h_valid_7  <= 1'b0;
    end else begin
        r_verify_enabled_7          <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_ENABLE_7 ? r_reg_bus_data[0] : r_verify_enabled_7;
        r_min_frag_size_7           <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_7 ? r_reg_bus_data[7:0] : r_min_frag_size_7;
        r_min_frag_size_valid_7     <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MIN_FRAG_SIZE_7 ? 1'b1 : 1'b0;
        r_verify_timer_7            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_7 ? r_reg_bus_data[7:0] : r_verify_timer_7;
        r_verify_timer_valid_7      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_VERIFY_TIMER_7 ? 1'b1 : 1'b0;
        r_ipg_timer_7               <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_7 ? r_reg_bus_data[7:0] : r_ipg_timer_7;
        r_ipg_timer_valid_7         <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_IPG_TIMER_7 ? 1'b1 : 1'b0;
        r_reset_7                   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_QBU_RESET_7 ? r_reg_bus_data[0] : 1'b0;
        r_start_verify_7            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_7 ? r_reg_bus_data[0] : 
                                       r_start_verify_7 == 1'b1 ? 1'b0 : r_start_verify_7;
        r_clear_verify_7            <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_VERIFY_CTRL_7 ? r_reg_bus_data[1] : 
                                       r_clear_verify_7 == 1'b1 ? 1'b0 : r_clear_verify_7;
        r_watchdog_timer_l_7        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_7 ? r_reg_bus_data[15:0] : r_watchdog_timer_l_7; 
        r_watchdog_timer_h_7        <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_7 ? r_reg_bus_data[15:0] : r_watchdog_timer_h_7; 
        r_watchdog_timer_l_valid_7  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_L_7 ? 1'b1 : 1'b0;
        r_watchdog_timer_h_valid_7  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr ==REG_WATCHDOG_TIMER_H_7 ? 1'b1 : 1'b0;
    end
end

/*========================================= ¼Ä´æÆ÷¶Á¿ØÖÆÂß¼­=========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else if (r_reg_bus_re) begin
        case (r_reg_bus_raddr)
            //TXMAC
			REG_PORT_TXMAC_DOWN  : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_txmac_down_regs[PORT_NUM-1:0];
			end			
			REG_STORE_FORWARD_ENABLE : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_store_forward_enable_regs[PORT_NUM-1:0];
			end			      
			REG_PORT_1G_INTEVAL_NUM0 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_0[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM0 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_0[3:0];
			end			               
			REG_PORT_1G_INTEVAL_NUM1 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_1[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM1 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_1[3:0];
			end			     
			REG_PORT_1G_INTEVAL_NUM2 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_2[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM2 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_2[3:0];
			end			     
			REG_PORT_1G_INTEVAL_NUM3 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_3[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM3 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_3[3:0];
			end			    
			REG_PORT_1G_INTEVAL_NUM4 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_4[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM4 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_4[3:0];
			end			      
			REG_PORT_1G_INTEVAL_NUM5 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_5[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM5 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_5[3:0];
			end			   
			REG_PORT_1G_INTEVAL_NUM6 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_6[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM6 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_6[3:0];
			end			     
			REG_PORT_1G_INTEVAL_NUM7 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_1g_interval_num_regs_7[3:0];
			end			           
			REG_PORT_100M_INTERVAL_NUM7 : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_port_100m_interval_num_regs_7[3:0];
			end			     
			REG_PORT_TX_BYTE_CNT0  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_0[15:0];
            end         
			REG_PORT_TX_FRAME_CNT0 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_0[15:0];  
            end 
			REG_PORT_DIAG_STATE0   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_0[15:0];  
            end          
			REG_PORT_TX_BYTE_CNT1  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_1[15:0];
            end         
			REG_PORT_TX_FRAME_CNT1 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_1[15:0];  
            end 
			REG_PORT_DIAG_STATE1   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_1[15:0];  
            end                 
			REG_PORT_TX_BYTE_CNT2  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_2[15:0];
            end         
			REG_PORT_TX_FRAME_CNT2 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_2[15:0];  
            end 
			REG_PORT_DIAG_STATE2   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_2[15:0];  
            end                
			REG_PORT_TX_BYTE_CNT3  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_3[15:0];
            end         
			REG_PORT_TX_FRAME_CNT3 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_3[15:0];  
            end 
			REG_PORT_DIAG_STATE3   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_3[15:0];  
            end                 
			REG_PORT_TX_BYTE_CNT4  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_4[15:0];
            end         
			REG_PORT_TX_FRAME_CNT4 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_4[15:0];  
            end 
			REG_PORT_DIAG_STATE4   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_4[15:0];  
            end                
			REG_PORT_TX_BYTE_CNT5  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_5[15:0];
            end         
			REG_PORT_TX_FRAME_CNT5 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_5[15:0];  
            end 
			REG_PORT_DIAG_STATE5   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_5[15:0];  
            end                
			REG_PORT_TX_BYTE_CNT6  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_6[15:0];
            end         
			REG_PORT_TX_FRAME_CNT6 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_6[15:0];  
            end 
			REG_PORT_DIAG_STATE6   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_6[15:0];  
            end                 
			REG_PORT_TX_BYTE_CNT7  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_byte_cnt_7[15:0];
            end         
			REG_PORT_TX_FRAME_CNT7 : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_tx_frame_cnt_7[15:0];  
            end 
			REG_PORT_DIAG_STATE7   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_port_diag_state_7[15:0];  
            end
            //QBV
			REG_QBV_ENABLE		   : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qbv_enable;  
            end           
			REG_BASETIME_VLD       : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time_vld;  
            end              
			REG_QBV_BASETIME0_0    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_0;  
            end                 
			REG_QBV_BASETIME1_0    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_0;  
            end                   
			REG_QBV_BASETIME2_0    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_0;  
            end                   
			REG_QBV_BASETIME3_0    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_0;  
            end                   
			REG_QBV_BASETIME4_0    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_0;  
            end                   
			REG_QBV_CYCLTIME_0     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_0;  
            end                    
			REG_QBV_CONTROLIST_LEN_0: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_0;  
            end 
			REG_QBV_CONTROLIST_VALUE_0:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_0;   
            end
			REG_QBV_BASETIME0_1    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_1;  
            end                 
			REG_QBV_BASETIME1_1    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_1;  
            end                   
			REG_QBV_BASETIME2_1    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_1;  
            end                   
			REG_QBV_BASETIME3_1    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_1;  
            end                   
			REG_QBV_BASETIME4_1    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_1;  
            end                   
			REG_QBV_CYCLTIME_1     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_1;  
            end                    
			REG_QBV_CONTROLIST_LEN_1: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_1;  
            end 
			REG_QBV_CONTROLIST_VALUE_1:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_1;   
            end
			REG_QBV_BASETIME0_2    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_2;  
            end                 
			REG_QBV_BASETIME1_2    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_2;  
            end                   
			REG_QBV_BASETIME2_2    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_2;  
            end                   
			REG_QBV_BASETIME3_2    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_2;  
            end                   
			REG_QBV_BASETIME4_2    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_2;  
            end                   
			REG_QBV_CYCLTIME_2     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_2;  
            end                    
			REG_QBV_CONTROLIST_LEN_2: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_2;  
            end 
			REG_QBV_CONTROLIST_VALUE_2:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_2;   
            end
			REG_QBV_BASETIME0_3    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_3;  
            end                 
			REG_QBV_BASETIME1_3    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_3;  
            end                   
			REG_QBV_BASETIME2_3    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_3;  
            end                   
			REG_QBV_BASETIME3_3    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_3;  
            end                   
			REG_QBV_BASETIME4_3    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_3;  
            end                   
			REG_QBV_CYCLTIME_3     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_3;  
            end                    
			REG_QBV_CONTROLIST_LEN_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_3;  
            end 
			REG_QBV_CONTROLIST_VALUE_3:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_3;   
            end
			REG_QBV_BASETIME0_4    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_4;  
            end                 
			REG_QBV_BASETIME1_4    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_4;  
            end                   
			REG_QBV_BASETIME2_4    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_4;  
            end                   
			REG_QBV_BASETIME3_4    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_4;  
            end                   
			REG_QBV_BASETIME4_4    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_4;  
            end                   
			REG_QBV_CYCLTIME_4     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_4;  
            end                    
			REG_QBV_CONTROLIST_LEN_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_4;  
            end 
			REG_QBV_CONTROLIST_VALUE_4:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_4;   
            end
			REG_QBV_BASETIME0_5    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_5;  
            end                 
			REG_QBV_BASETIME1_5    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_5;  
            end                   
			REG_QBV_BASETIME2_5    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_5;  
            end                   
			REG_QBV_BASETIME3_5    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_5;  
            end                   
			REG_QBV_BASETIME4_5    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_5;  
            end                   
			REG_QBV_CYCLTIME_5     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_5;  
            end                    
			REG_QBV_CONTROLIST_LEN_5: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_5;  
            end 
			REG_QBV_CONTROLIST_VALUE_5:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_5;   
            end
			REG_QBV_BASETIME0_6    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_6;  
            end                 
			REG_QBV_BASETIME1_6    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_6;  
            end                   
			REG_QBV_BASETIME2_6    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_6;  
            end                   
			REG_QBV_BASETIME3_6    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_6;  
            end                   
			REG_QBV_BASETIME4_6    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_6;  
            end                   
			REG_QBV_CYCLTIME_6     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_6;  
            end                    
			REG_QBV_CONTROLIST_LEN_6: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_6;  
            end 
			REG_QBV_CONTROLIST_VALUE_6:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_6;   
            end
			REG_QBV_BASETIME0_7    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time0_7;  
            end                 
			REG_QBV_BASETIME1_7    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time1_7;  
            end                   
			REG_QBV_BASETIME2_7    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time2_7;  
            end                   
			REG_QBV_BASETIME3_7    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time3_7;  
            end                   
			REG_QBV_BASETIME4_7    : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_base_time4_7;  
            end                   
			REG_QBV_CYCLTIME_7     : begin     
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_cycle_time_7;  
            end                    
			REG_QBV_CONTROLIST_LEN_7: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_len_7;  
            end 
			REG_QBV_CONTROLIST_VALUE_7:begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_controllist_val_7;   
            end
			REG_QAV_ENABLE      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_enable;
            end   


			REG_QAV_IDLESLOPE_P0Q0 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_idleslope_0[0];
            end           
			REG_QAV_SENDSLOPE_P0Q0 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_sendslope_0[0];
            end               
			REG_QAV_HTHRESHOLD_P0Q0 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_hthreshold_0[0];
            end  
            REG_QAV_LTHRESHOLD_P0Q0 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_lthreshold_0[0];
            end 

            REG_QAV_IDLESLOPE_P0Q1 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_idleslope_0[1];
            end           
			REG_QAV_SENDSLOPE_P0Q1 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_sendslope_0[1];
            end               
			REG_QAV_HTHRESHOLD_P0Q1 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_hthreshold_0[1];
            end  
            REG_QAV_LTHRESHOLD_P0Q1 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_lthreshold_0[1];
            end 

            REG_QAV_IDLESLOPE_P0Q2 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_idleslope_0[2];
            end           
			REG_QAV_SENDSLOPE_P0Q2 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_sendslope_0[2];
            end               
			REG_QAV_HTHRESHOLD_P0Q2 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_hthreshold_0[2];
            end  
            REG_QAV_LTHRESHOLD_P0Q2 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_lthreshold_0[2];
            end 

            REG_QAV_IDLESLOPE_P0Q3 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_idleslope_0[3];
            end           
			REG_QAV_SENDSLOPE_P0Q3 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_sendslope_0[3];
            end               
			REG_QAV_HTHRESHOLD_P0Q3 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_hthreshold_0[3];
            end  
            REG_QAV_LTHRESHOLD_P0Q3 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_qav_lthreshold_0[3];
            end 
            // Î´²¹È«      
			
            //QBU_TX
            REG_QBU_RESET_0     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_0};
            end   
            REG_PREEMPT_ENABLE_0:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_0};
            end    
            REG_VERIFY_ENABLE_0 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_0};
            end
            REG_TRANS_BUSY_0    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_0};
            end    
            REG_TX_FRAGMENT_CNT_0: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_0;
            end    
            REG_PREEMPT_STATE_0  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_0,i_preempt_active_0};
            end
            REG_MIN_FRAG_SIZE_0  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_0;
            end
            REG_VERIFY_TIMER_0   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_0;
            end
            REG_IPG_TIMER_0      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_0;
            end
            REG_VERIFY_CTRL_0    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_0,r_start_verify_0};
            end
            REG_TX_FRAMES_CNT_0  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_0;
            end
            REG_PREEMPT_SUCCESS_CNT_0: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_0;
            end
            REG_WATCHDOG_TIMER_L_0: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_0;
            end
            REG_WATCHDOG_TIMER_H_0: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_0;
            end
            REG_TX_TIMEOUT_0 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_0;
            end
            REG_FRAG_NEXT_TX_0: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_0;
            end
            REG_QBU_RESET_1     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_1};
            end   
            REG_PREEMPT_ENABLE_1:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_1};
            end    
            REG_VERIFY_ENABLE_1 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_1};
            end
            REG_TRANS_BUSY_1    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_1};
            end    
            REG_TX_FRAGMENT_CNT_1: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_1;
            end    
            REG_PREEMPT_STATE_1  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_1,i_preempt_active_1};
            end
            REG_MIN_FRAG_SIZE_1  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_1;
            end
            REG_VERIFY_TIMER_1   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_1;
            end
            REG_IPG_TIMER_1      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_1;
            end
            REG_VERIFY_CTRL_1    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_1,r_start_verify_1};
            end
            REG_TX_FRAMES_CNT_1  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_1;
            end
            REG_PREEMPT_SUCCESS_CNT_1: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_1;
            end
            REG_WATCHDOG_TIMER_L_1: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_1;
            end
            REG_WATCHDOG_TIMER_H_1: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_1;
            end
            REG_TX_TIMEOUT_1 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_1;
            end
            REG_FRAG_NEXT_TX_1: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_1;
            end
			REG_QBU_RESET_2     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_2};
            end   
            REG_PREEMPT_ENABLE_2:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_2};
            end    
            REG_VERIFY_ENABLE_2 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_2};
            end
            REG_TRANS_BUSY_2    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_2};
            end    
            REG_TX_FRAGMENT_CNT_2: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_2;
            end    
            REG_PREEMPT_STATE_2  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_2,i_preempt_active_2};
            end
            REG_MIN_FRAG_SIZE_2  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_2;
            end
            REG_VERIFY_TIMER_2   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_2;
            end
            REG_IPG_TIMER_2      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_2;
            end
            REG_VERIFY_CTRL_2    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_2,r_start_verify_2};
            end
            REG_TX_FRAMES_CNT_2  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_2;
            end
            REG_PREEMPT_SUCCESS_CNT_2: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_2;
            end
            REG_WATCHDOG_TIMER_L_2: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_2;
            end
            REG_WATCHDOG_TIMER_H_2: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_2;
            end
            REG_TX_TIMEOUT_2 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_2;
            end
            REG_FRAG_NEXT_TX_2: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_2;
            end
			REG_QBU_RESET_3     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_3};
            end   
            REG_PREEMPT_ENABLE_3:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_3};
            end    
            REG_VERIFY_ENABLE_3 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_3};
            end
            REG_TRANS_BUSY_3    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_3};
            end    
            REG_TX_FRAGMENT_CNT_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_3;
            end    
            REG_PREEMPT_STATE_3  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_3,i_preempt_active_3};
            end
            REG_MIN_FRAG_SIZE_3  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_3;
            end
            REG_VERIFY_TIMER_3   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_3;
            end
            REG_IPG_TIMER_3      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_3;
            end
            REG_VERIFY_CTRL_3    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_3,r_start_verify_3};
            end
            REG_TX_FRAMES_CNT_3  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_3;
            end
            REG_PREEMPT_SUCCESS_CNT_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_3;
            end
            REG_WATCHDOG_TIMER_L_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_3;
            end
            REG_WATCHDOG_TIMER_H_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_3;
            end
            REG_TX_TIMEOUT_3 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_3;
            end
            REG_FRAG_NEXT_TX_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_3;
            end
			REG_QBU_RESET_4     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_4};
            end   
            REG_PREEMPT_ENABLE_4:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_4};
            end    
            REG_VERIFY_ENABLE_4 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_4};
            end
            REG_TRANS_BUSY_4    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_4};
            end    
            REG_TX_FRAGMENT_CNT_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_4;
            end    
            REG_PREEMPT_STATE_4  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_4,i_preempt_active_4};
            end
            REG_MIN_FRAG_SIZE_4  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_4;
            end
            REG_VERIFY_TIMER_4   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_4;
            end
            REG_IPG_TIMER_4      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_4;
            end
            REG_VERIFY_CTRL_4    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_4,r_start_verify_4};
            end
            REG_TX_FRAMES_CNT_4  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_4;
            end
            REG_PREEMPT_SUCCESS_CNT_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_4;
            end
            REG_WATCHDOG_TIMER_L_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_4;
            end
            REG_WATCHDOG_TIMER_H_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_4;
            end
            REG_TX_TIMEOUT_4 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_4;
            end
            REG_FRAG_NEXT_TX_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_4;
            end
			REG_QBU_RESET_5     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_5};
            end   
            REG_PREEMPT_ENABLE_5:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_5};
            end    
            REG_VERIFY_ENABLE_5 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_5};
            end
            REG_TRANS_BUSY_5    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_5};
            end    
            REG_TX_FRAGMENT_CNT_5: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_5;
            end    
            REG_PREEMPT_STATE_5  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_5,i_preempt_active_5};
            end
            REG_MIN_FRAG_SIZE_5  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_5;
            end
            REG_VERIFY_TIMER_5   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_5;
            end
            REG_IPG_TIMER_5      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_5;
            end
            REG_VERIFY_CTRL_5    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_5,r_start_verify_5};
            end
            REG_TX_FRAMES_CNT_5  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_5;
            end
            REG_PREEMPT_SUCCESS_CNT_5: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_5;
            end
            REG_WATCHDOG_TIMER_L_5: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_5;
            end
            REG_WATCHDOG_TIMER_H_5: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_5;
            end
            REG_TX_TIMEOUT_5 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_5;
            end
            REG_FRAG_NEXT_TX_5: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_5;
            end
			REG_QBU_RESET_6     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_6};
            end   
            REG_PREEMPT_ENABLE_6:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_6};
            end    
            REG_VERIFY_ENABLE_6 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_6};
            end
            REG_TRANS_BUSY_6    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_6};
            end    
            REG_TX_FRAGMENT_CNT_6: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_6;
            end    
            REG_PREEMPT_STATE_6  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_6,i_preempt_active_6};
            end
            REG_MIN_FRAG_SIZE_6  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_6;
            end
            REG_VERIFY_TIMER_6   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_6;
            end
            REG_IPG_TIMER_6      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_6;
            end
            REG_VERIFY_CTRL_6    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_6,r_start_verify_6};
            end
            REG_TX_FRAMES_CNT_6  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_6;
            end
            REG_PREEMPT_SUCCESS_CNT_6: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_6;
            end
            REG_WATCHDOG_TIMER_L_6: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_6;
            end
            REG_WATCHDOG_TIMER_H_6: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_6;
            end
            REG_TX_TIMEOUT_6 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_6;
            end
            REG_FRAG_NEXT_TX_6: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_6;
            end
			REG_QBU_RESET_7     : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_reset_7};
            end   
            REG_PREEMPT_ENABLE_7:begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_preempt_enable_7};
            end    
            REG_VERIFY_ENABLE_7 : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},r_verify_enabled_7};
            end
            REG_TRANS_BUSY_7    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}},i_tx_busy_7};
            end    
            REG_TX_FRAGMENT_CNT_7: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_fragment_cnt_7;
            end    
            REG_PREEMPT_STATE_7  : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},i_preemptable_frame_7,i_preempt_active_7};
            end
            REG_MIN_FRAG_SIZE_7  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_min_frag_size_7;
            end
            REG_VERIFY_TIMER_7   : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_verify_timer_7;
            end
            REG_IPG_TIMER_7      : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_ipg_timer_7;
            end
            REG_VERIFY_CTRL_7    : begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-2){1'b0}},r_clear_verify_7,r_start_verify_7};
            end
            REG_TX_FRAMES_CNT_7  : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_frames_cnt_7;
            end
            REG_PREEMPT_SUCCESS_CNT_7: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_preempt_success_cnt_7;
            end
            REG_WATCHDOG_TIMER_L_7: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_l_7;
            end
            REG_WATCHDOG_TIMER_H_7: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_watchdog_timer_h_7;
            end
            REG_TX_TIMEOUT_7 : begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_tx_timeout_7;
            end
            REG_FRAG_NEXT_TX_7: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_frag_next_tx_7;
            end
            default: begin
                r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
            end
        endcase
    end else begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata_vld <= 1'b0;
    end else begin
        r_reg_bus_rdata_vld <= r_reg_bus_re;
    end
end

assign o_switch_reg_bus_rd_dout  = r_reg_bus_rdata;
assign o_switch_reg_bus_rd_dout_v= r_reg_bus_rdata_vld;

endmodule