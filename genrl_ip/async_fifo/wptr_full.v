module wptr_full#(
    parameter   PTR_WIDTH = 5
)
(
input                   wr_clk_i,
input                   rstn_i,
input                   wr_en_i,
input   [PTR_WIDTH:0]   rptr_gray_i,
output  [PTR_WIDTH:0]   wptr_gray_o, //输出给读空模块
output  [PTR_WIDTH-1:0] wr_addr_o,   //输出给fifomem写地址
output                  wr_full_o,   //写满信号
output reg [PTR_WIDTH:0]   wptr_bin_o  //输出二进制编码，生成wr_cnt

);

wire    [PTR_WIDTH:0]   wptr_bin_nxt;


always@(posedge wr_clk_i)begin
    if(!rstn_i)
        wptr_bin_o[PTR_WIDTH:0] <= {(PTR_WIDTH+1){1'b0}};
    else
        wptr_bin_o[PTR_WIDTH:0] <= wptr_bin_nxt[PTR_WIDTH:0];
end

//当写使能且未写满时，写指针加一，否则不变
assign  wptr_bin_nxt[PTR_WIDTH:0] = (wr_en_i && ~wr_full_o)? wptr_bin_o[PTR_WIDTH:0]+1'b1 : wptr_bin_o[PTR_WIDTH:0]; 
//写指针转换成格雷码
assign  wptr_gray_o[PTR_WIDTH:0] = wptr_bin_o[PTR_WIDTH:0] ^ (wptr_bin_o[PTR_WIDTH:0]>>1);
//输出写地址
assign  wr_addr_o[PTR_WIDTH-1:0] = wptr_bin_o[PTR_WIDTH-1:0];

// wr_full_o is asserted when the read pointer equals the write pointer with the two MSBs inverted (Gray code full detection)
assign  wr_full_o = (rptr_gray_i[PTR_WIDTH:0] == {~wptr_gray_o[PTR_WIDTH-:2],wptr_gray_o[PTR_WIDTH-2:0]});


endmodule

