module wr_cnt#(
    parameter   PTR_WIDTH = 5
)
(
input                   rstn_i,
//===============wr clk domain============
input                   wr_clk_i,
//input                   wr_en_i,
//input                   wr_full_i,
input   [PTR_WIDTH:0]   wptr_bin_i,

//==============rd clk domain============ 
input   [PTR_WIDTH:0]   rp2wp_gray_i,

//================rd output==============
output  [PTR_WIDTH:0]   wr_cnt_o

);


wire    [PTR_WIDTH:0]   rptr_bin;

assign  wr_cnt_o[PTR_WIDTH:0] = wptr_bin_i[PTR_WIDTH:0] - rptr_bin[PTR_WIDTH:0];

assign  rptr_bin[PTR_WIDTH] = rp2wp_gray_i[PTR_WIDTH];

generate
    genvar  i;   
    for(i=0;i<PTR_WIDTH;i=i+1)begin
        assign rptr_bin[i] = rp2wp_gray_i[i] ^ rptr_bin[i+1];
    end
endgenerate





endmodule 
