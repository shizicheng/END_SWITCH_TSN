module rx_mac_hash_calc#(  
    parameter           CWIDTH              =           15
)(
    input               wire                                    i_clk                   ,   // 250MHz
    input               wire                                    i_rst                   ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    input               wire   [15:0]                           i_hash_poly_regs        ,
    input               wire   [15:0]                           i_hash_init_val_regs    ,
    input               wire                                    i_hash_regs_vld         ,
    /*--------------------------------- 信息提取模块输入的 MAC 信息 -------------------------------------*/
    input               wire   [11:0]                           i_vlan_id               , // 输入报文的VLAN ID
    input               wire   [47:0]                           i_dmac_data             , // 目的 MAC 地址(48bit)
    input               wire                                    i_dmac_data_vld         , // DMAC数据有效
    input               wire   [47:0]                           i_smac_data             , // 源 MAC 地址(48bit)
    input               wire                                    i_smac_data_vld         , // SMAC数据有效
    /*--------------------------------- 输出 hash 的计算结果 -------------------------------------*/     
    output              wire   [11:0]                           o_vlan_id               ,
    output              wire   [CWIDTH - 1 : 0]                 o_dmac_hash_key         ,
    output              wire   [47 : 0]                         o_dmac                  ,
    output              wire                                    o_dmac_hash_vld         , 
    output              wire   [CWIDTH - 1 : 0]                 o_smac_hash_key         ,
    output              wire   [47 : 0]                         o_smac                  ,
    output              wire                                    o_smac_hash_vld               
);

// 输入信号打拍
reg     [47:0]                              ri_dmac_data                        ; // DMAC 数据打拍(48bit)
reg                                         ri_dmac_data_vld                    ; // DMAC 数据有效打拍
reg     [47:0]                              ri_smac_data                        ; // SMAC 数据打拍(48bit)
reg                                         ri_smac_data_vld                    ; // SMAC 数据有效打拍
reg     [11:0]                              ri_vlan_id                          ; // VLAN ID打拍

// 内部处理变量
reg                                         r_dmac_hash_en                      ; // DMAC HASH 使能
reg                                         r_smac_hash_en                      ; // SMAC HASH 使能
reg                                         r_dmac_hash_vld                     ; // DMAC HASH 有效
reg                                         r_smac_hash_vld                     ; // SMAC HASH 有效

// 输出寄存器
reg     [11:0]                              ro_vlan_id                          ; // VLAN ID 输出
reg     [CWIDTH-1:0]                        ro_dmac_hash_key                    ; // DMAC HASH KEY 输出
reg     [47:0]                              ro_dmac                             ; // DMAC 输出
// reg                                         ro_dmac_vld                         ; // DMAC 有效输出
reg     [CWIDTH-1:0]                        ro_smac_hash_key                    ; // SMAC HASH KEY 输出
reg     [47:0]                              ro_smac                             ; // SMAC 输出
// reg                                         ro_smac_vld                         ; // SMAC 有效输出
reg                                         r_hash_cacl_rst                     ;

// HASH 计算输出
wire    [CWIDTH-1:0]                        w_dmac_crc_out                      ; // DMAC CRC 输出
wire    [CWIDTH-1:0]                        w_smac_crc_out                      ; // SMAC CRC 输出

//---------- 输出信号赋值 ----------
assign  o_vlan_id                           =       ro_vlan_id                  ;
assign  o_dmac_hash_key                     =       ro_dmac_hash_key            ;
assign  o_dmac                              =       ro_dmac                     ;
assign  o_dmac_hash_vld                     =       r_dmac_hash_vld             ;
assign  o_smac_hash_key                     =       ro_smac_hash_key            ;
assign  o_smac                              =       ro_smac                     ;
assign  o_smac_hash_vld                     =       r_smac_hash_vld             ;
 
// 输入信号打拍
always @(posedge i_clk) begin
    if (i_rst) begin
        ri_dmac_data     <= 48'd0;
        ri_dmac_data_vld <= 1'b0;
        ri_smac_data     <= 48'd0;
        ri_smac_data_vld <= 1'b0;
        ri_vlan_id       <= 12'd0;
    end else begin
        ri_dmac_data     <= i_dmac_data_vld ? i_dmac_data : ri_dmac_data;
        ri_dmac_data_vld <= i_dmac_data_vld;
        ri_smac_data     <= i_smac_data_vld ? i_smac_data : ri_smac_data;
        ri_smac_data_vld <= i_smac_data_vld;
        ri_vlan_id       <= i_smac_data_vld ? i_vlan_id : ri_vlan_id;
    end
end

// DMAC HASH 使能逻辑（直接使用输入有效信号）
always @(posedge i_clk) begin
    if (i_rst) begin
        r_dmac_hash_en  <= 1'b0;
    end else begin
        r_dmac_hash_en  <= i_dmac_data_vld;
    end
end

// SMAC HASH 使能逻辑（直接使用输入有效信号）
always @(posedge i_clk) begin
    if (i_rst) begin
        r_smac_hash_en  <= 1'b0;
    end else begin
        r_smac_hash_en  <= i_smac_data_vld;
    end
end

// DMAC HASH 有效
always @(posedge i_clk) begin
    if (i_rst) begin
        r_dmac_hash_vld <= 1'b0;
    end else begin
        r_dmac_hash_vld <= r_dmac_hash_en;
    end
end

// SMAC HASH 有效
always @(posedge i_clk) begin
    if (i_rst) begin
        r_smac_hash_vld <= 1'b0;
    end else begin
        r_smac_hash_vld <= r_smac_hash_en;
    end
end

always@(posedge i_clk or posedge i_rst ) begin
    if(i_rst) begin
        r_hash_cacl_rst <= 1'd1;
    end else begin
        r_hash_cacl_rst <= r_smac_hash_vld ? 1'd1 : 1'd0;
    end


end

// VLAN ID 输出（使用打拍后的VLAN ID）
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_vlan_id  <= 12'd0;
    end else begin
        ro_vlan_id  <= r_smac_hash_en ? ri_vlan_id : ro_vlan_id;
    end
end

// DMAC 输出（直接输出打拍后的DMAC）
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_dmac     <= 48'd0;
    end else begin
        ro_dmac     <= r_dmac_hash_en ? ri_dmac_data : ro_dmac;
    end
end

// // DMAC 有效输出
// always @(posedge i_clk) begin
//     if (i_rst) begin
//         ro_dmac_vld <= 1'b0;
//     end else begin
//         ro_dmac_vld <= r_dmac_hash_vld;
//     end
// end

// DMAC HASH KEY 输出
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_dmac_hash_key <= 15'd0;
    end else begin
        ro_dmac_hash_key <= w_dmac_crc_out;
    end
end

// SMAC 输出（直接输出打拍后的SMAC）
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_smac     <= 48'd0;
    end else begin
        ro_smac     <= r_smac_hash_en ? ri_smac_data : ro_smac;
    end
end

// // SMAC 有效输出
// always @(posedge i_clk) begin
//     if (i_rst) begin
//         ro_smac_vld <= 1'b0;
//     end else begin
//         ro_smac_vld <= r_smac_hash_vld;
//     end
// end

// SMAC HASH KEY 输出
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_smac_hash_key <= 15'd0;
    end else begin
        ro_smac_hash_key <= w_smac_crc_out;
    end
end

//---------- HASH 计算模块实例化 ----------
// DMAC HASH计算：使用打拍后的DMAC和VLAN ID
hash_cacl hash_cacl_u1 (
    .i_data_in      ({i_dmac_data, i_vlan_id}  ),
    .i_crc_en       (i_dmac_data_vld           ),
    .o_crc_out      (w_dmac_crc_out            ),
    .i_rst          (r_hash_cacl_rst           ),
    .i_clk          (i_clk                     )
);

// SMAC HASH计算：使用打拍后的SMAC和VLAN ID
hash_cacl hash_cacl_u2 (
    .i_data_in      ({i_smac_data, i_vlan_id}  ),
    .i_crc_en       (i_smac_data_vld           ),
    .o_crc_out      (w_smac_crc_out            ),
    .i_rst          (r_hash_cacl_rst           ),
    .i_clk          (i_clk                     )
);

endmodule