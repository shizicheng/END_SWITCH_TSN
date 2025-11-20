`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/22 22:30:39
// Design Name: 
// Module Name: flow_ctrl
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
// 后级模块 ready 信号情况可能还需要考虑
//////////////////////////////////////////////////////////////////////////////////
module flow_ctrl#(
    parameter                                       SIM_MODE            = "TRUE"                    ,//仿真加速： "TRUE"  正常运行 �??? "FALSE" 
    parameter                                       REG_DATA_WIDTH      = 32                        ,
    parameter                                       PORT_MNG_DATA_WIDTH = 128                       ,
    parameter                                       CLOCK_PERIOD        = 100_000_000           
)                                           
(                                           
    input                                           i_sys_clk                                       ,
    input                                           i_sys_rst                                       ,

    input                                           i_pluse_clk                                     ,//50 100 200 250 
    input                                           i_pluse_rst                                     ,

    input                                           i_pluse_valid                                  ,
    output                                          o_pluse_ready                                  ,

    input   [REG_DATA_WIDTH -1:0]                   i_port_rate                                     ,//00-100M 01-1000M  10-2500M  10-10G
    input   [REG_DATA_WIDTH -1:0]                   i_flow_ctrl_select                              ,//0:100 1:50 2:25  

    output  [31:0]                                  o_recive_package                                ,//接收数据包数 
    output  [31:0]                                  o_recive_package_multi                          ,//接收数据包数  乘数
    output  [31:0]                                  o_send_package                                  ,//发送数据包数量
    output  [31:0]                                  o_send_package_multi                            ,//发送数据包数量 乘数

    input  [PORT_MNG_DATA_WIDTH - 1:0]              i_flow_data                                     ,//端口数据 
    input  [(PORT_MNG_DATA_WIDTH/8) - 1:0]          i_flow_data_keep                                ,//端口数据掩码信号
    input                                           i_flow_valid                                    ,//端口数据有效
    output                                          o_flow_ready                                    ,//端口数据就绪信号,表示当前模块准备好接收数 
    input                                           i_flow_last                                     ,// 数据流结束标     

    output  [PORT_MNG_DATA_WIDTH - 1:0]             o_flow_data                                     ,//端口数据 
    output  [(PORT_MNG_DATA_WIDTH/8) - 1:0]         o_flow_data_keep                                ,//端口数据掩码信号
    output                                          o_flow_valid                                    ,//端口数据有效
    input                                           i_flow_ready                                    ,//端口数据就绪信号,表示当前模块准备好接收数 
    output                                          o_flow_last                                     // 数据流结束标    

);
    localparam   CNT_WIDTH       = (SIM_MODE == "TRUE") ?              8        :  32               ;
    localparam   SPEED_100M      = (SIM_MODE == "TRUE") ?              4000     :  12_500_000       ; 
    localparam   SPEED_1G        = (SIM_MODE == "TRUE") ?              8000     :  125_000_000      ; 
    localparam   SPEED_2_5G      = (SIM_MODE == "TRUE") ?              16000    :  312_500_000      ; 
    localparam   SPEED_10G       = (SIM_MODE == "TRUE") ?              32000    :  1250_000_000     ; 
    

    reg [PORT_MNG_DATA_WIDTH - 1:0]                     ri_flow_data                                ;  
    reg [(PORT_MNG_DATA_WIDTH/8) - 1:0]                 ri_flow_data_keep                           ;
    reg                                                 ri_flow_valid                               ;   
    reg                                                 ri_flow_last                                ;
    reg                                                 ri_second_pluse                             ;
    reg                                                 r_pluse_run                                 ;
    reg     [2:0]                                       r_power_up                                  ;
    reg     [2:0]                                       r_flow_ctrl_select                          ;

    reg     [15:0]                                      r_speed_byte_LSB                            ;
    reg     [15:0]                                      r_speed_byte_MSB                            ;

    reg     [15:0]                                      r_flow_ctrl_num_LSB                         ;
    reg     [15:0]                                      r_flow_ctrl_num_MSB                         ;
    // reg     [15:0]                                      r_recive_byte_LSB                           ; 
    // reg     [15:0]                                      r_recive_byte_MSB                           ;

    reg                                                 r_send_data_stop                            ;//停止发送数 
    reg                                                 r_send_data_stop_valid                      ;
    reg                                                 r_send_data_stop_valid_1d                   ;
    reg                                                 r_data_run                                  ;

    reg     [CNT_WIDTH -1:0]                            ro_recive_package                           ;//接收包数
    reg     [CNT_WIDTH -1:0]                            ro_recive_package_multi                     ;//接收包数 乘积
    reg     [CNT_WIDTH -1:0]                            ro_send_package                             ;//发送包
    reg     [CNT_WIDTH -1:0]                            ro_send_package_multi                       ;//发送包  乘积
    reg     [PORT_MNG_DATA_WIDTH - 1:0]                 ro_flow_data                                ;    
    reg     [(PORT_MNG_DATA_WIDTH/8) - 1:0]             ro_flow_data_keep                           ;  
    reg                                                 ro_flow_valid                               ;   
    reg                                                 ro_flow_last                                ;  
    reg                                                 ro_pluse_ready                              ;
    reg     [31:0]                                      r_recive_byte                               ;
    wire                                                w_rec_byte_lsb_valid                        ; 

    wire                                                w_flow_run                                  ;
    wire    [2 :0]                                      w_flow_ctrl_select                          ;
    wire                                                w_flow_ctrl_select_update                   ;
    wire                                                w_data_sned_run                             ;
    wire                                                w_pluse_neg                                 ;
    wire                                                w_valid_pos                                 ;
    assign o_flow_ready                 =               i_flow_ready                                ;
    assign o_recive_package             =               ro_recive_package                           ;                  
    assign o_recive_package_multi       =               ro_recive_package_multi                     ;                  
    assign o_send_package               =               ro_send_package                             ;                  
    assign o_send_package_multi         =               ro_send_package_multi                       ;                  
    assign o_flow_data                  =               ro_flow_data                                ;                  
    assign o_flow_data_keep             =               ro_flow_data_keep                           ;                  
    assign o_flow_valid                 =               ro_flow_valid                               ;                  
    assign o_flow_last                  =               ro_flow_last                                ;     
    assign o_pluse_ready                =               ro_pluse_ready                              ;

    assign w_rec_byte_lsb_valid         =               i_flow_valid & (|i_flow_data_keep) & i_flow_ready ; 
    assign w_pluse_neg                  =               !i_pluse_valid & ri_second_pluse           ;
    assign w_valid_pos                  =               i_flow_valid & !ri_flow_valid               ;
    assign w_flow_run                   =               i_flow_ctrl_select[12]                      ;
    assign w_flow_ctrl_select           =               i_flow_ctrl_select[2:0]                     ;
    assign w_flow_ctrl_select_update    =               w_flow_ctrl_select != r_flow_ctrl_select    ;
    assign w_data_sned_run              =               !i_pluse_valid                             ;
    localparam  SPEED_100M_num          =               2'b00                                       ;//12.5M字节
    localparam  SPEED_1G_num            =               2'b01                                       ;//125M字节
    localparam  SPEED_2_5G_num          =               2'b10                                       ;//312.5M字节
    localparam  SPEED_10G_num           =               2'b11                                       ;//1250M字节
    localparam  AXI_BYTE                =               PORT_MNG_DATA_WIDTH / 8                     ;

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)begin 
            ri_second_pluse   <= 1'd0;
            ri_flow_valid     <= 1'd0;
            ri_flow_data      <= {PORT_MNG_DATA_WIDTH{1'b0}};
            ri_flow_data_keep <= {PORT_MNG_DATA_WIDTH/8{1'b0}};
            ri_flow_valid     <= 1'd0;
            ri_flow_last      <= 1'd0;
        end else begin
            ri_second_pluse   <= i_pluse_valid  ;
            ri_flow_valid     <= i_flow_valid    ;
            ri_flow_data      <= i_flow_data     ;
            ri_flow_data_keep <= i_flow_data_keep;
            ri_flow_valid     <= i_flow_valid    ;
            ri_flow_last      <= i_flow_last     ;
        end 
    end 
    
    always @(posedge i_sys_clk) 
    begin
        if(i_sys_rst)
            ro_pluse_ready <= 1'b0;
        else 
            ro_pluse_ready <= i_pluse_valid == 1'b1 && ro_flow_valid == 1'b0 ? 1'b1 : 
                              1'b0;
    end 


    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_data_run <= 1'd0;
        else if(i_flow_valid & !ri_flow_valid )
            r_data_run <= 1'd0;
        else if(!w_data_sned_run & !i_flow_valid)
            r_data_run <= 1'd1;
        else 
            r_data_run <= r_data_run;
        end 

    //by the speed assign the byte num 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_speed_byte_LSB <= 16'd0;
        else case(i_port_rate[1:0])
            SPEED_100M_num : r_speed_byte_LSB <= SPEED_100M[15:0];
            SPEED_1G_num   : r_speed_byte_LSB <= SPEED_1G  [15:0];
            SPEED_2_5G_num : r_speed_byte_LSB <= SPEED_2_5G[15:0];
            SPEED_10G_num  : r_speed_byte_LSB <= SPEED_10G [15:0];
            default        : r_speed_byte_LSB <= SPEED_100M[15:0];
        endcase 
      
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst) 
            r_speed_byte_MSB <= 16'd0;
        else case(i_port_rate[1:0])
            SPEED_100M_num : r_speed_byte_MSB <= SPEED_100M[31:16];
            SPEED_1G_num   : r_speed_byte_MSB <= SPEED_1G  [31:16];
            SPEED_2_5G_num : r_speed_byte_MSB <= SPEED_2_5G[31:16];
            SPEED_10G_num  : r_speed_byte_MSB <= SPEED_10G [31:16];
            default        : r_speed_byte_MSB <= SPEED_100M[31:16];
        endcase 
    end 
    
    //用于判断 是否修改流控等级
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_flow_ctrl_select <= 1'd0;
        else 
            r_flow_ctrl_select <= w_flow_ctrl_select;
    end 
    //流控 后的  最大通过字节
    
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_flow_ctrl_num_LSB <= 16'd0;
        else begin 
            r_flow_ctrl_num_LSB <=  r_power_up == 3'b011 || w_flow_ctrl_select_update == 1'b1 ? r_speed_byte_LSB >> w_flow_ctrl_select: 
                                    r_flow_ctrl_num_LSB;
        end 
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_flow_ctrl_num_MSB <= 16'd0;
        else begin 
            r_flow_ctrl_num_MSB <=  r_power_up == 3'b011 || w_flow_ctrl_select_update == 1'b1 ? r_speed_byte_MSB >> w_flow_ctrl_select: 
                                    r_flow_ctrl_num_MSB;
        end 
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_power_up <= 'd0;
        else 
            r_power_up <= {r_power_up[1:0],1'b1};
    end 



    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_recive_byte <= 32'd0;
        else begin 
            r_recive_byte <= (w_data_sned_run == 1'b0 || r_send_data_stop_valid == 1'b1 || r_data_run == 1'b1) ? 32'd0 : 
                            //  r_recive_byte [31:16] == r_flow_ctrl_num_MSB && r_recive_byte [15:0] >= r_flow_ctrl_num_LSB ? 32'd0 : 
                             w_rec_byte_lsb_valid == 1'b1 ? r_recive_byte + AXI_BYTE    : 
                             r_recive_byte;
        end 
    end 

    //  发送已达到流控阈�? 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_data_stop <= 1'd0;
        else begin 
            r_send_data_stop <= w_data_sned_run == 1'b0 ? 1'd0 : 
                                r_power_up == 3'b111 && r_recive_byte[31:16] == r_flow_ctrl_num_MSB && r_recive_byte[15:0] >= r_flow_ctrl_num_LSB ? 1'd1 : 
                                r_send_data_stop;
        end 
    end 

    // 流控停止信号 有效信号 (防止 数据传输时被截断 )
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_data_stop_valid <= 1'd0;
        else begin 
            r_send_data_stop_valid <=   w_data_sned_run == 1'b0 ? 1'd0 : 
                                        r_send_data_stop == 1'b1 && i_flow_valid == 1'b0 ? 1'd1: 
                                        r_send_data_stop_valid;
        end 
    end 
    
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_data_stop_valid_1d <= 1'd0;
        else 
            r_send_data_stop_valid_1d <= r_send_data_stop_valid;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_flow_data <= {PORT_MNG_DATA_WIDTH{1'b0}};
        else 
            ro_flow_data <= ri_flow_data;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst) 
            ro_flow_data_keep <= {PORT_MNG_DATA_WIDTH/8{1'b0}};
        else begin 
            ro_flow_data_keep <=    r_send_data_stop_valid == 1'b0 && i_flow_ready == 1'b1 ? ri_flow_data_keep : 
                                    {PORT_MNG_DATA_WIDTH/8{1'b0}};
        end 
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_flow_valid <= 1'd0;   
        else begin 
            ro_flow_valid <=    r_send_data_stop_valid  == 1'b0 && i_flow_ready == 1'b1 && r_data_run == 1'b0 ? ri_flow_valid : 
                                1'd0;
        end 
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_flow_last <= 1'd0;
        else begin 
            ro_flow_last <= ro_flow_valid == 1'b1 ? ri_flow_last : 
                            1'd0;
        end 
    end 

wire [0:0]      w_recive_package_LSB      ;
wire [0:0]      w_recive_package_MSB      ;
reg             r_recive_package          ;
assign w_recive_package_LSB = &ro_recive_package[CNT_WIDTH/2-1:0 ];
assign w_recive_package_MSB = &ro_recive_package[CNT_WIDTH-1:CNT_WIDTH/2];
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_recive_package <= 1'd0;
        else 
            r_recive_package <= w_recive_package_LSB == 1'b1 && w_recive_package_MSB == 1'b1;
    end 
    //32bit 计数
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_recive_package <= {CNT_WIDTH{1'b0}};
        else if(r_recive_package == 1'b1 && ri_flow_last == 1'b1)
            ro_recive_package <= {CNT_WIDTH{1'b0}};
        else if(ri_flow_last)
            ro_recive_package <= ro_recive_package + 'd1;
        else 
            ro_recive_package <= ro_recive_package;
    end   



wire [0:0]      w_recive_package_multi_LSB; 
wire [0:0]      w_recive_package_multi_MSB;  
reg             r_recive_package_multi    ;

assign w_recive_package_multi_LSB =  &ro_recive_package_multi[CNT_WIDTH/2-1:0 ];
assign w_recive_package_multi_MSB =  &ro_recive_package_multi[CNT_WIDTH-1:CNT_WIDTH/2];


    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_recive_package_multi <= 1'd0;
        else 
            r_recive_package_multi <= w_recive_package_multi_LSB == 1'b1 && w_recive_package_multi_MSB == 1'b1;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_recive_package_multi <= {CNT_WIDTH{1'b0}};
        else if((r_recive_package == 1'b1) && (r_recive_package_multi == 1'b1) && ri_flow_last == 1'b1)
            ro_recive_package_multi <={CNT_WIDTH{1'b0}};
        else if((r_recive_package == 1'b1) && ri_flow_last == 1'b1)
            ro_recive_package_multi <= ro_recive_package_multi + 'd1;
        else 
            ro_recive_package_multi <= ro_recive_package_multi;
    end 
    
//o_flow_last 可能需要打一�?
wire [0:0]  w_send_package_LSB      ; 
wire [0:0]  w_send_package_MSB      ; 
reg         r_send_package_AND_gate ;
assign w_send_package_LSB = &ro_send_package[CNT_WIDTH/2-1:0 ];
assign w_send_package_MSB = &ro_send_package[CNT_WIDTH-1:CNT_WIDTH/2];

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_package_AND_gate <= 1'b0;
        else begin 
            r_send_package_AND_gate <=  w_send_package_LSB == 1'b1 && w_send_package_MSB == 1'b1 ? 1'b1 : 
                                        1'b0;
        end     
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_send_package <= {CNT_WIDTH{1'b0}};
        else if(r_send_package_AND_gate == 1'b1 && o_flow_last == 1'b1)
            ro_send_package <= {CNT_WIDTH{1'b0}};
        else if(o_flow_last == 1'b1)
            ro_send_package <= ro_send_package + 'd1;
        else 
            ro_send_package <= ro_send_package;
    end 

wire [0:0]  w_send_package_multi_LSB      ; 
wire [0:0]  w_send_package_multi_MSB      ; 
reg         r_send_package_multi_AND_gate ;
assign w_send_package_multi_LSB = &ro_send_package_multi[CNT_WIDTH/2-1:0 ];
assign w_send_package_multi_MSB = &ro_send_package_multi[CNT_WIDTH-1:CNT_WIDTH/2];

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_package_multi_AND_gate <= 1'b0;
        else begin 
            r_send_package_multi_AND_gate <=  w_send_package_multi_LSB == 1'b1 && w_send_package_multi_MSB == 1'b1 ? 1'b1 : 
                                              1'b0;
        end     
    end 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_send_package_multi <= {CNT_WIDTH{1'b0}};
        else if(r_send_package_multi_AND_gate == 1'b1 && (r_send_package_AND_gate == 1'b1) && o_flow_last == 1'b1)
            ro_send_package_multi <= {CNT_WIDTH{1'b0}};
        else if((r_send_package_AND_gate == 1'b1) && o_flow_last == 1'b1)
            ro_send_package_multi <= ro_send_package_multi + 'd1;
        else 
            ro_send_package_multi <= ro_send_package_multi;
    end 

endmodule 