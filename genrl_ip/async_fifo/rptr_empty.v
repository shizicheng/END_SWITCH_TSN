module  rptr_empty#(
    parameter   PTR_WIDTH       =   5,
                DATA_FLOAT_OUT  =   1'b0
)
(
input                      rd_clk_i,
input                      rstn_i,
input                      rd_en_i,
input   [PTR_WIDTH:0]      wptr_gray_i,      
output reg                 rd_empty_o,
output reg [PTR_WIDTH-1:0] rd_addr_o,
output reg [PTR_WIDTH:0]   rptr_gray_o,
output reg [PTR_WIDTH:0]   rptr_bin_o
);

wire    [PTR_WIDTH:0]   rptr_bin_nxt;
wire    [PTR_WIDTH:0]   rptr_gray_nxt;
wire    [PTR_WIDTH-1:0] rd_addr_nxt;
wire                    rd_empty_nxt;

// 二进制指针递增逻辑
assign  rptr_bin_nxt[PTR_WIDTH:0] = (rd_en_i & ~rd_empty_o)? rptr_bin_o[PTR_WIDTH:0]+1'b1 : rptr_bin_o[PTR_WIDTH:0];

// 格雷码转换逻辑
assign  rptr_gray_nxt[PTR_WIDTH:0] = rptr_bin_nxt[PTR_WIDTH:0] ^ (rptr_bin_nxt[PTR_WIDTH:0]>>1);

// 读地址生成逻辑
assign  rd_addr_nxt[PTR_WIDTH-1:0] = rptr_bin_nxt[PTR_WIDTH-1:0];//(DATA_FLOAT_OUT)? rptr_bin_nxt[PTR_WIDTH-1:0] : rptr_bin_o[PTR_WIDTH-1:0];

// 空标志生成逻辑
assign  rd_empty_nxt = (wptr_gray_i[PTR_WIDTH:0] == rptr_gray_nxt[PTR_WIDTH:0]);

// 二进制指针寄存器
always @(posedge rd_clk_i)begin
    if(!rstn_i)
        rptr_bin_o[PTR_WIDTH:0] <= {(PTR_WIDTH+1){1'b0}};
    else
        rptr_bin_o[PTR_WIDTH:0] <= rptr_bin_nxt[PTR_WIDTH:0];
end

// 格雷码指针寄存器
always @(posedge rd_clk_i)begin
    if(!rstn_i)
        rptr_gray_o[PTR_WIDTH:0] <= {(PTR_WIDTH+1){1'b0}};
    else
        rptr_gray_o[PTR_WIDTH:0] <= rptr_gray_nxt[PTR_WIDTH:0];
end

// 读地址寄存器
always @(posedge rd_clk_i)begin
    if(!rstn_i)
        rd_addr_o[PTR_WIDTH-1:0] <= {PTR_WIDTH{1'b0}};
    else
        rd_addr_o[PTR_WIDTH-1:0] <= rd_addr_nxt[PTR_WIDTH-1:0];
end

// 空标志寄存器
always @(posedge rd_clk_i)begin
    if(!rstn_i)
        rd_empty_o <= 1'b1;  // 复位时为空
    else
        rd_empty_o <= rd_empty_nxt;
end    

endmodule

