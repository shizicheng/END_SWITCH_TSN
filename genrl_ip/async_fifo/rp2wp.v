
module rp2wp#(
    parameter   PTR_WIDTH = 5
)
(
    input                   wr_clk_i,
    input                   rstn_i,
    input   [PTR_WIDTH:0]   rptr_gray_i,

    output  [PTR_WIDTH:0]   rp2wp_gray_o
    
);  
    
    reg [PTR_WIDTH:0]   rp_syn1,rp_syn2;
    
    always @(posedge wr_clk_i )begin
        if(!rstn_i)begin
            rp_syn1[PTR_WIDTH:0] <= {{PTR_WIDTH+1}{1'b0}};
            rp_syn2[PTR_WIDTH:0] <= {{PTR_WIDTH+1}{1'b0}};
        end
        else begin
            rp_syn1[PTR_WIDTH:0] <= rptr_gray_i[PTR_WIDTH:0];
            rp_syn2[PTR_WIDTH:0] <= rp_syn1[PTR_WIDTH:0];
        end
    end

    assign rp2wp_gray_o[PTR_WIDTH:0] = rp_syn2[PTR_WIDTH:0];



endmodule
