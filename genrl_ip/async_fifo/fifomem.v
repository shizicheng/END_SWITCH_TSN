module fifomem#(    
    parameter   DATA_WIDTH  = 8,
                FIFO_DEPTH  = 16,
                DATA_FLOAT_OUT = 1'b0
)(
    rstn_wr_i,
    wr_clk_i,
    wr_en_i,
    wr_addr_i,
    wr_data_i,
    rstn_rd_i,
    rd_clk_i,
    rd_en_i,
    rd_addr_i,
    rd_data_o
); 

`include "functions.vh"
parameter   ADDR_WIDTH  = clog2s(FIFO_DEPTH);

input                           rstn_wr_i;
input                           wr_clk_i;
input                           wr_en_i;
input       [ADDR_WIDTH-1:0]    wr_addr_i;
input       [DATA_WIDTH-1:0]    wr_data_i;
input                           rstn_rd_i;
input                           rd_clk_i;
input                           rd_en_i;
input       [ADDR_WIDTH-1:0]    rd_addr_i;
output      [DATA_WIDTH-1:0]    rd_data_o;


(* ram_style = "block" *) reg [DATA_WIDTH-1:0]    mem [FIFO_DEPTH-1:0];

reg [DATA_WIDTH-1:0]    rd_data_o = 'd0;   

integer i;
always @(posedge wr_clk_i )begin 
    if(wr_en_i)
        mem[wr_addr_i] <= wr_data_i;
end

always @(posedge rd_clk_i )begin 
   if(rd_en_i)
        rd_data_o <= mem[rd_addr_i];
end

endmodule


