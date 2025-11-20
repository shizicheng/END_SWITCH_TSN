`include "synth_cmd_define.vh"

module  Scheduling_top #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8    ,  // 支持端口优先级 FIFO 的数量
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8    ,
    parameter                                                   REG_DATA_BUS_WIDTH      =      16     
)(
    input               wire                                    i_clk                            , // 250MHz
    input               wire                                    i_rst                            ,
    /*----------- 寄存器配置接口 ------------*/
    // 寄存器控制信号                     
    //input               wire                                    i_refresh_list_pulse             , // 刷新寄存器列表（状态寄存器和控制寄存器）
    //input               wire                                    i_switch_err_cnt_clr             , // 刷新错误计数器
    //input               wire                                    i_switch_err_cnt_stat            , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    //input               wire                                    i_Sch_reg_bus_we                 , // 寄存器写使能
    //input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_Sch_reg_bus_we_addr            , // 寄存器写地址
    //input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_Sch_reg_bus_we_din             , // 寄存器写数据
    //input               wire                                    i_Sch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口     
    //input               wire                                    i_Sch_reg_bus_rd                 , // 寄存器读使能
    //input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_Sch_reg_bus_rd_addr            , // 寄存器读地址
    //output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_Sch_reg_bus_we_dout            , // 读出寄存器数据
    //output              wire                                    o_Sch_reg_bus_we_dout_v          , // 读数据有效使能
    /*------------------------------------ Schedule寄存器 ----------------------------------------*/
    input               wire   [7:0]                            i_idleSlope_q0             			,
    input               wire   [7:0]                            i_idleSlope_q1             			,
    input               wire   [7:0]                            i_idleSlope_q2             			,
    input               wire   [7:0]                            i_idleSlope_q3             			,
    input               wire   [7:0]                            i_idleSlope_q4             			,
    input               wire   [7:0]                            i_idleSlope_q5             			,
    input               wire   [7:0]                            i_idleSlope_q6             			,
    input               wire   [7:0]                            i_idleSlope_q7             			,
	input   			wire   [7:0]                            i_sendslope_q0             			,
    input               wire   [7:0]                            i_sendslope_q1             			,
    input               wire   [7:0]                            i_sendslope_q2             			,
    input               wire   [7:0]                            i_sendslope_q3             			,
    input               wire   [7:0]                            i_sendslope_q4             			,
    input               wire   [7:0]                            i_sendslope_q5             			,
    input               wire   [7:0]                            i_sendslope_q6             			,
    input               wire   [7:0]                            i_sendslope_q7             			,
	input   			wire                                    i_qav_en                 			,
	input   			wire   [15:0]                           i_lothreshold_q0             	    ,
    input               wire   [15:0]                           i_lothreshold_q1             		,
    input               wire   [15:0]                           i_lothreshold_q2             		,
    input               wire   [15:0]                           i_lothreshold_q3           			,
    input               wire   [15:0]                           i_lothreshold_q4           			,
    input               wire   [15:0]                           i_lothreshold_q5           			,
    input               wire   [15:0]                           i_lothreshold_q6           			,
    input               wire   [15:0]                           i_lothreshold_q7           			,
    input               wire   [15:0]                           i_hithreshold_q0           			,
    input               wire   [15:0]                           i_hithreshold_q1           			,
    input               wire   [15:0]                           i_hithreshold_q2           			,
    input               wire   [15:0]                           i_hithreshold_q3           			,
    input               wire   [15:0]                           i_hithreshold_q4           			,
    input               wire   [15:0]                           i_hithreshold_q5           			,
    input               wire   [15:0]                           i_hithreshold_q6           			,
    input               wire   [15:0]                           i_hithreshold_q7           			,
    
	input   			wire                                    i_config_vld             			,


    input               wire   [79:0]                           i_current_time                      ,
	input   			wire   [79:0]                           i_Base_time              			, 
	input   			wire                                    i_ConfigChange           			,
	input   			wire   [PORT_FIFO_PRI_NUM-1:0]          i_ControlList            			,     
	input   			wire   [7:0]                            i_ControlList_len        			,    
	input   			wire                                    i_ControlList_vld        			,     
	input   			wire   [15:0]                           i_cycle_time             			,    
	input   			wire   [79:0]                           i_cycle_time_extension   			, 
	input   			wire                                    i_qbv_en                 			,       
			  		  
	input   			wire   [3:0]                            i_qos_sch                           ,
	input   			wire	                                i_qos_en                            ,   

    /*------------------------------ 与CROSSBAR交换平面交互的调度信息 ------------------------------*/
    // 调度流水线调度信息交互
    input               wire  [PORT_FIFO_PRI_NUM-1:0]           i_fifoc_empty                       , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息 
    output              wire  [PORT_FIFO_PRI_NUM-1:0]           o_scheduing_rst                     , // 该端口调度流水线产生的调度结果
    output              wire                                    o_scheduing_rst_vld                 , // 该端口调度流水线产生的调度结果有效位
    // QBU 模块返回的信号
    input               wire                                    i_mac_tx_axis_valid                 , // 用于管理每个优先级队列的信用值
    input               wire                                    i_mac_tx_axis_last                  ,  // 数据流 last 信号，用于使能调度流水线计算  
    input               wire  [15:0]                            i_mac_tx_axis_user
);

/*------------ wire -----------*/
wire   [PORT_FIFO_PRI_NUM-1:0]          w_queque                 ;
wire                                    w_queque_vld             ;
 
wire   [PORT_FIFO_PRI_NUM-1:0]          w_ControlList_state      ;
wire                                    w_ControlList_state_vld  ;
 
wire   [PORT_FIFO_PRI_NUM-1:0]          w_qos_scheduing_res      ;
wire                                    w_qos_scheduing_rst_vld  ;
/*
wire   [7:0]                            w_idleSlope              ;
wire   [7:0]                            w_sendslope              ;
wire                                    w_qav_en                 ;
wire   [15:0]                           w_threshold              ;
wire                                    w_config_vld             ;

wire   [79:0]                           w_Base_time              ; 
wire                                    w_ConfigChange           ;
wire   [PORT_FIFO_PRI_NUM:0]            w_ControlList            ;     
wire   [7:0]                            w_ControlList_len        ;    
wire                                    w_ControlList_vld        ;     
wire   [15:0]                           w_cycle_time             ;    
wire   [79:0]                           w_cycle_time_extension   ; 
wire                                    w_qbv_en                 ;       
 
wire   [3:0]                            w_qos_sch                ;
wire                                    w_qos_en                 ;                         
*/
tsn_qav_mng #(
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM       )      // 支持端口优先级 FIFO 的数量
) tsn_qav_mng_inst ( 
    .i_clk                   ( i_clk                   ) , // 250MHz
    .i_rst                   ( i_rst                   ) ,
    /*------------------------------ 寄存器配置接口 ----------------------------*/
    .i_idleSlope_q0           ( i_idleSlope_q0            ) ,
    .i_idleSlope_q1           ( i_idleSlope_q1            ) ,
    .i_idleSlope_q2           ( i_idleSlope_q2            ) ,
    .i_idleSlope_q3           ( i_idleSlope_q3            ) ,
    .i_idleSlope_q4           ( i_idleSlope_q4            ) ,
    .i_idleSlope_q5           ( i_idleSlope_q5            ) ,
    .i_idleSlope_q6           ( i_idleSlope_q6            ) ,
    .i_idleSlope_q7           ( i_idleSlope_q7            ) ,
    .i_sendslope_q0           ( i_sendslope_q0          ) ,
    .i_sendslope_q1           ( i_sendslope_q1          ) ,
    .i_sendslope_q2           ( i_sendslope_q2          ) ,
    .i_sendslope_q3           ( i_sendslope_q3          ) ,
    .i_sendslope_q4           ( i_sendslope_q4          ) ,
    .i_sendslope_q5           ( i_sendslope_q5          ) ,
    .i_sendslope_q6           ( i_sendslope_q6          ) ,
    .i_sendslope_q7           ( i_sendslope_q7          ) ,
    .i_hithreshold_q0           ( i_hithreshold_q0          ) ,
    .i_hithreshold_q1           ( i_hithreshold_q1          ) ,
    .i_hithreshold_q2           ( i_hithreshold_q2          ) ,
    .i_hithreshold_q3           ( i_hithreshold_q3          ) ,
    .i_hithreshold_q4           ( i_hithreshold_q4          ) ,
    .i_hithreshold_q5           ( i_hithreshold_q5          ) ,
    .i_hithreshold_q6           ( i_hithreshold_q6          ) ,
    .i_hithreshold_q7           ( i_hithreshold_q7          ) ,
    .i_lothreshold_q0           ( i_lothreshold_q0          ) ,
    .i_lothreshold_q1           ( i_lothreshold_q1          ) ,
    .i_lothreshold_q2           ( i_lothreshold_q2          ) ,
    .i_lothreshold_q3           ( i_lothreshold_q3          ) ,
    .i_lothreshold_q4           ( i_lothreshold_q4          ) ,
    .i_lothreshold_q5           ( i_lothreshold_q5          ) ,
    .i_lothreshold_q6           ( i_lothreshold_q6          ) ,
    .i_lothreshold_q7           ( i_lothreshold_q7          ) ,
    
    .i_config_vld            ( i_config_vld            ) ,
    .i_qav_en                ( i_qav_en                ) ,
    /*------------------------------ 调度信息输入 ------------------------------*/
    .i_fifoc_empty           ( i_fifoc_empty           ) , // 实时检测该端口对应 CROSSBAR 交换平面优先级 FIFO 信息
    .i_scheduing_rst         ( w_qos_scheduing_res     ) , // 该端口调度流水线产生的调度结果
    .i_scheduing_rst_vld     ( w_qos_scheduing_rst_vld ) , // 该端口调度流水线产生的调度结果有效位
    .i_mac_tx_axis_valid     ( i_mac_tx_axis_valid     ) , // 用于管理每个优先级队列的信用值
    .i_mac_tx_axis_last      ( i_mac_tx_axis_last      ) , // 
    .i_mac_tx_axis_user      ( i_mac_tx_axis_user      ) ,
    /*---------------- 将信用值满足调度需求的优先级队列信息输出 ------------------*/
    .o_queue                ( w_queque                ) , // 输出满足信用值的队列结果向量
    .o_queue_vld            ( w_queque_vld            ) 
);

tsn_qbv_mng #(
    .PORT_FIFO_PRI_NUM       (PORT_FIFO_PRI_NUM       )      // 支持端口优先级 FIFO 的数量
) tsn_qbv_mng_inst ( 
    .i_clk                   ( i_clk                  ) , // 250MHz
    .i_rst                   ( i_rst                  ) ,
    /*---------------------------------------- 寄存器配置接口 --------------------------------------*/
    .i_current_time          ( i_current_time         ) ,
    .i_Base_time             ( i_Base_time            ) ,
    .i_Base_time_vld         ( 1'b0                   ),
    .i_ConfigChange          ( i_ConfigChange         ) ,
    .i_ControlList           ( i_ControlList          ) ,   
    .i_ControlList_len       ( i_ControlList_len      ) , 
    .i_ControlList_vld       ( i_ControlList_vld      ) ,   
    .i_cycle_time            ( i_cycle_time           ) ,      
    .i_cycle_time_extension  ( i_cycle_time_extension ) ,
    .i_qbv_en                ( i_qbv_en               ) ,  
    /*---------------------------------- Qav 输入满足信用条件的队列向量结果 -------------------------*/ 
    .i_queque                ( w_queque               ) , // 输出满足信用值的队列结果向量
    .i_queque_vld            ( w_queque_vld           ) ,
    /*---------------------------------- 输出门控状态至 QOS 调度模块 ------------------------------*/ 
    .o_ControlList_state     ( w_ControlList_state    ) , // 门控列表的状态
    .o_ControlList_state_vld ( w_ControlList_state_vld) 
);

tx_qos_mng #(
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM       )                       // 支持端口优先级 FIFO 的数量
)tx_qos_mng_inst(   
    .i_clk                   ( i_clk                   ) ,   // 250MHz
    .i_rst                   ( i_rst                   ) ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    .i_qos_sch               ( i_qos_sch               ) ,
    .i_qos_en                ( i_qos_en                ) ,
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    .i_ControlList_state     ( w_ControlList_state     ) ,  // 门控列表的状态
    .i_qos_req               ( w_ControlList_state_vld ) ,
    .o_qos_scheduing_res     ( w_qos_scheduing_res     ) ,
    .o_qos_scheduing_rst_vld ( w_qos_scheduing_rst_vld )                 
);

assign o_scheduing_rst     = w_qos_scheduing_res;
assign o_scheduing_rst_vld = w_qos_scheduing_rst_vld;

/*
Schduling_regs #(
    .PORT_FIFO_PRI_NUM       ( PORT_FIFO_PRI_NUM  )  ,  // 支持端口优先级 FIFO 的数量
    .REG_ADDR_BUS_WIDTH      ( REG_ADDR_BUS_WIDTH )  ,
    .REG_DATA_BUS_WIDTH      ( REG_DATA_BUS_WIDTH )    
) Schduling_regs_inst (
    .i_clk                   ( i_clk                   )        ,
    .i_rst                   ( i_rst                   )        ,
    // 寄存器配置接口
    // 寄存器控制信号                     
    .i_refresh_list_pulse    ( i_refresh_list_pulse    )        , // 刷新寄存器列表（状态寄存器和控制寄存器）
    .i_switch_err_cnt_clr    ( i_switch_err_cnt_clr    )        , // 刷新错误计数器
    .i_switch_err_cnt_stat   ( i_switch_err_cnt_stat   )        , // 刷新错误状态寄存器
    // 寄存器写控制接口     
    .i_Sch_reg_bus_we        ( i_Sch_reg_bus_we        )        , // 寄存器写使能
    .i_Sch_reg_bus_we_addr   ( i_Sch_reg_bus_we_addr   )        , // 寄存器写地址
    .i_Sch_reg_bus_we_din    ( i_Sch_reg_bus_we_din    )        , // 寄存器写数据
    .i_Sch_reg_bus_we_din_v  ( i_Sch_reg_bus_we_din_v  )        , // 寄存器写数据使能
    // 寄存器读控制接口     
    .i_Sch_reg_bus_rd        ( i_Sch_reg_bus_rd        )         , // 寄存器读使能
    .i_Sch_reg_bus_rd_addr   ( i_Sch_reg_bus_rd_addr   )         , // 寄存器读地址
    .o_Sch_reg_bus_we_dout   ( o_Sch_reg_bus_we_dout   )         , // 读出寄存器数据
    .o_Sch_reg_bus_we_dout_v ( o_Sch_reg_bus_we_dout_v )         , // 读数据有效使能
    // IP核相关配置信息
    // qav
    .o_idleSlope             ( w_idleSlope            )         ,
    .o_sendslope             ( w_sendslope            )         ,
    .o_qav_en                ( w_qav_en               )         ,
    .o_threshold             ( w_threshold            )         ,  
    .o_av_config_vld         ( w_config_vld           )         ,
    // qbv
    .o_Base_time             ( w_Base_time            )         ,
    .o_ConfigChange          ( w_ConfigChange         )         ,
    .o_ControlList           ( w_ControlList          )         ,   
    .o_ControlList_len       ( w_ControlList_len      )         ,  
    .o_ControlList_vld       ( w_ControlList_vld      )         ,
    .o_cycle_time            ( w_cycle_time           )         ,      
    .o_cycle_time_extension  ( w_cycle_time_extension )         ,
    .o_qbv_en                ( w_qbv_en               )         ,       
    // qos 
    .o_qos_sch               ( w_qos_sch              )         ,
    .o_qos_en                ( w_qos_en               )                                  
);
*/
endmodule