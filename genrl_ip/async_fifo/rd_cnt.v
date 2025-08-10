module rd_cnt#(
    parameter   PTR_WIDTH = 5
)(
input                   rstn_i,
//rd clk domain
input                   rd_clk_i,

input   [PTR_WIDTH:0]   rptr_bin_i,
//wr clk domain
input   [PTR_WIDTH:0]   wp2rp_gray_i,

output  [PTR_WIDTH:0]   rd_cnt_o
);
 


wire    [PTR_WIDTH:0]   wptr_bin;

assign  rd_cnt_o[PTR_WIDTH:0] = wptr_bin[PTR_WIDTH:0] - rptr_bin_i[PTR_WIDTH:0];
//=======================gray_2_bin=============================
assign  wptr_bin[PTR_WIDTH] = wp2rp_gray_i[PTR_WIDTH];

generate
    genvar  j;   
    for(j=0;j<PTR_WIDTH;j=j+1)begin
        assign wptr_bin[j] = wp2rp_gray_i[j] ^ wptr_bin[j+1];
    end
endgenerate






endmodule 
