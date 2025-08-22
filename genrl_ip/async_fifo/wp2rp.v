module wp2rp#(
    parameter   PTR_WIDTH = 5
)
(
    input                   rd_clk_i,
    input                   rstn_i,
    input   [PTR_WIDTH:0]   wptr_gray_i,

    output  [PTR_WIDTH:0]   wp2rp_gray_o
    
);  
    
    reg [PTR_WIDTH:0]   wp_syn1,wp_syn2;
    
    always @(posedge rd_clk_i)begin
        if(!rstn_i)begin
            wp_syn1[PTR_WIDTH:0] <= {{PTR_WIDTH+1}{1'b0}};
            wp_syn2[PTR_WIDTH:0] <= {{PTR_WIDTH+1}{1'b0}};
        end
        else begin
            wp_syn1[PTR_WIDTH:0] <= wptr_gray_i[PTR_WIDTH:0];
            wp_syn2[PTR_WIDTH:0] <= wp_syn1[PTR_WIDTH:0];
        end
    end

    assign wp2rp_gray_o[PTR_WIDTH:0] = wp_syn2[PTR_WIDTH:0];



endmodule
