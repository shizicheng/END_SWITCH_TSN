module qbu_reg_list (
    input             i_clk,
    input             i_rst_n,
    input             i_qbu_bus_we,
    input   [7:0]     i_qbu_bus_addr,
    input   [15:0]    i_qbu_bus_din,
    input             i_qbu_bus_rd,

    // Read-only fields for trs_busy
    input             i_rx_busy,
    input             i_tx_busy,

    // Read-only fields for preempt_state
    input             i_preemptable_frame,
    input             i_preempt_active,

    // Read-only registers from external IP
    input             i_preempt_enable,       // 1-bit, bit0 of 8-bit register
    input   [15:0]    i_tx_fragment_cnt,
    input   [15:0]    i_rx_fragment_cnt,
    input             i_rx_fragment_mismatch, // 1-bit, bit0 of 8-bit register
    input   [15:0]    i_err_rx_crc_cnt,
    input   [15:0]    i_err_rx_frame_cnt,
    input   [15:0]    i_err_fragment_cnt,
    input   [15:0]    i_err_verify_cnt,
    input   [15:0]    i_tx_frames_cnt,
    input   [15:0]    i_rx_frames_cnt,
    input   [15:0]    i_preempt_success_cnt,
    input             i_tx_timeout,
    input   [7:0]     i_frag_next_rx,
    input   [7:0]     i_frag_next_tx,
    input   [7:0]     i_frame_seq,

    // Read-write outputs (wired, driven by internal regs)
    output            o_verify_enabled,
    output            o_verify_enabled_valid,
    output  [7:0]     o_min_frag_size,
    output            o_min_frag_size_valid,
    output  [7:0]     o_verify_timer,
    output            o_verify_timer_valid,
    output  [7:0]     o_ipg_timer,
    output            o_ipg_timer_valid,
    output            o_reset,                // self-clearing, no valid
    output            o_start_verify,
    output            o_clear_verify,
    output  [23:0]    o_watchdog_timer,
    output            o_watchdog_timer_valid,

    // Bus read data
    output  [15:0]    o_qbu_bus_dout
);

    // Registered versions of all inputs (ri_ prefix)
    reg         ri_preempt_enable;           // 1 bit
    reg         ri_rx_busy;
    reg         ri_tx_busy;
    reg         ri_preemptable_frame;
    reg         ri_preempt_active;
    reg [15:0]  ri_tx_fragment_cnt;
    reg [15:0]  ri_rx_fragment_cnt;
    reg         ri_rx_fragment_mismatch;     // 1 bit
    reg [15:0]  ri_err_rx_crc_cnt;
    reg [15:0]  ri_err_rx_frame_cnt;
    reg [15:0]  ri_err_fragment_cnt;
    reg [15:0]  ri_err_verify_cnt;
    reg [15:0]  ri_tx_frames_cnt;
    reg [15:0]  ri_rx_frames_cnt;
    reg [15:0]  ri_preempt_success_cnt;
    reg         ri_tx_timeout;
    reg [7:0]   ri_frag_next_rx;
    reg [7:0]   ri_frag_next_tx;
    reg [7:0]   ri_frame_seq;

    // Internal writable registers (ro_ prefix) driving outputs
    reg         ro_verify_enabled;
    // reg         ro_verify_enabled_valid;
    reg [7:0]   ro_min_frag_size;
    reg         ro_min_frag_size_valid;
    reg [7:0]   ro_verify_timer;
    reg         ro_verify_timer_valid;
    reg [7:0]   ro_ipg_timer;
    reg         ro_ipg_timer_valid;
    reg         ro_reset;                    // self-clearing, no valid reg
    reg         ro_start_verify;
    // reg         ro_start_verify_valid;
    reg         ro_clear_verify;
    // reg         ro_clear_verify_valid;
    reg [15:0]  ro_watchdog_timer_l;
    reg         ro_watchdog_timer_l_valid;
    reg [7:0]   ro_watchdog_timer_h;
    reg         ro_watchdog_timer_h_valid;

    // Registered bus read data
    reg [15:0]  ro_qbu_bus_dout;

    // Assign internal regs to output wires
    assign o_verify_enabled         = ro_verify_enabled;
    // assign o_verify_enabled_valid   = ro_verify_enabled_valid;
    assign o_min_frag_size          = ro_min_frag_size;
    assign o_min_frag_size_valid    = ro_min_frag_size_valid;
    assign o_verify_timer           = ro_verify_timer;
    assign o_verify_timer_valid     = ro_verify_timer_valid;
    assign o_ipg_timer              = ro_ipg_timer;
    assign o_ipg_timer_valid        = ro_ipg_timer_valid;
    assign o_reset                  = ro_reset;
    assign o_start_verify           = ro_start_verify;
    // assign o_start_verify_valid     = ro_start_verify_valid;
    assign o_clear_verify           = ro_clear_verify;
    // assign o_clear_verify_valid     = ro_clear_verify_valid;
    // assign o_watchdog_timer_l       = ro_watchdog_timer_l;
    // assign o_watchdog_timer_l_valid = ro_watchdog_timer_l_valid;
    // assign o_watchdog_timer_h       = ro_watchdog_timer_h;
    // assign o_watchdog_timer_h_valid = ro_watchdog_timer_h_valid;
    assign o_watchdog_timer       = {ro_watchdog_timer_h,ro_watchdog_timer_l};
    assign o_watchdog_timer_valid = ro_watchdog_timer_l_valid;
    assign o_qbu_bus_dout           = ro_qbu_bus_dout;

    // Synchronous process: register inputs & handle writes
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset all registered inputs
            ri_preempt_enable        <= 1'b0;
            ri_rx_busy               <= 1'b0;
            ri_tx_busy               <= 1'b0;
            ri_preemptable_frame     <= 1'b0;
            ri_preempt_active        <= 1'b0;
            ri_tx_fragment_cnt       <= 16'd0;
            ri_rx_fragment_cnt       <= 16'd0;
            ri_rx_fragment_mismatch  <= 1'b0;
            ri_err_rx_crc_cnt        <= 16'd0;
            ri_err_rx_frame_cnt      <= 16'd0;
            ri_err_fragment_cnt      <= 16'd0;
            ri_err_verify_cnt        <= 16'd0;
            ri_tx_frames_cnt         <= 16'd0;
            ri_rx_frames_cnt         <= 16'd0;
            ri_preempt_success_cnt   <= 16'd0;
            ri_tx_timeout            <= 1'b0;
            ri_frag_next_rx          <= 16'd0;
            ri_frag_next_tx          <= 16'd0;
            ri_frame_seq             <= 16'd0;

            // Initialize writable registers to defaults
            ro_verify_enabled        <= 1'b1;
            ro_min_frag_size         <= 8'd46;
            ro_verify_timer          <= 8'd10;
            ro_ipg_timer             <= 8'd12;
            ro_watchdog_timer_l      <= 16'he848;
            ro_watchdog_timer_h      <= 8'd1;
            ro_reset                 <= 1'b0;
            ro_start_verify          <= 1'b0;
            ro_clear_verify          <= 1'b0;

            // Initialize valid flags low
            // ro_verify_enabled_valid  <= 1'b0;
            ro_min_frag_size_valid   <= 1'b0;
            ro_verify_timer_valid    <= 1'b0;
            ro_ipg_timer_valid       <= 1'b0;
            // ro_start_verify_valid    <= 1'b0;
            // ro_clear_verify_valid    <= 1'b0;
            ro_watchdog_timer_l_valid<= 1'b0;
            ro_watchdog_timer_h_valid<= 1'b0;

            // Clear bus read data
            ro_qbu_bus_dout          <= 16'h0;
        end else begin
            // Register all inputs on each clock
            ri_preempt_enable        <= i_preempt_enable;
            ri_rx_busy               <= i_rx_busy;
            ri_tx_busy               <= i_tx_busy;
            ri_preemptable_frame     <= i_preemptable_frame;
            ri_preempt_active        <= i_preempt_active;
            ri_tx_fragment_cnt       <= i_tx_fragment_cnt;
            ri_rx_fragment_cnt       <= i_rx_fragment_cnt;
            ri_rx_fragment_mismatch  <= i_rx_fragment_mismatch;
            ri_err_rx_crc_cnt        <= i_err_rx_crc_cnt;
            ri_err_rx_frame_cnt      <= i_err_rx_frame_cnt;
            ri_err_fragment_cnt      <= i_err_fragment_cnt;
            ri_err_verify_cnt        <= i_err_verify_cnt;
            ri_tx_frames_cnt         <= i_tx_frames_cnt;
            ri_rx_frames_cnt         <= i_rx_frames_cnt;
            ri_preempt_success_cnt   <= i_preempt_success_cnt;
            ri_tx_timeout            <= i_tx_timeout;
            ri_frag_next_rx          <= i_frag_next_rx;
            ri_frag_next_tx          <= i_frag_next_tx;
            ri_frame_seq             <= i_frame_seq;

            // Default: clear valid pulses & self-clear outputs
            // ro_verify_enabled_valid  <= 1'b0;
            ro_min_frag_size_valid   <= 1'b0;
            ro_verify_timer_valid    <= 1'b0;
            ro_ipg_timer_valid       <= 1'b0;
            // ro_start_verify_valid    <= 1'b0;
            // ro_clear_verify_valid    <= 1'b0;
            ro_watchdog_timer_l_valid<= 1'b0;
            ro_watchdog_timer_h_valid<= 1'b0;
            ro_reset                 <= 1'b0;
            ro_start_verify          <= 1'b0;
            ro_clear_verify          <= 1'b0;

            // Handle write enable from bus
           if (i_qbu_bus_we) begin
                case (i_qbu_bus_addr)
                    8'h01: begin
                        ro_verify_enabled        <= i_qbu_bus_din[0];
                        // ro_verify_enabled_valid  <= 1'b1;
                    end
                    8'h0B: begin
                        ro_min_frag_size         <= i_qbu_bus_din[7:0];
                        ro_min_frag_size_valid   <= 1'b1;
                    end
                    8'h0C: begin
                        ro_verify_timer          <= i_qbu_bus_din[7:0];
                        ro_verify_timer_valid    <= 1'b1;
                    end
                    8'h0D: begin
                        ro_ipg_timer             <= i_qbu_bus_din[7:0];
                        ro_ipg_timer_valid       <= 1'b1;
                    end
                    8'h0E: begin
                        ro_reset                 <= i_qbu_bus_din[0];
                    end
                    8'h0F: begin
                        ro_clear_verify          <= i_qbu_bus_din[0];
                        // ro_clear_verify_valid    <= 1'b1;
                        ro_start_verify          <= i_qbu_bus_din[1];
                        // ro_start_verify_valid    <= 1'b1;
                    end
                    8'h13: begin
                        ro_watchdog_timer_l      <= i_qbu_bus_din;
                        ro_watchdog_timer_l_valid<= 1'b1;
                    end
                    8'h14: begin
                        ro_watchdog_timer_h      <= i_qbu_bus_din[7:0];
                        ro_watchdog_timer_h_valid<= 1'b1;
                    end
                    default: ;
                endcase
            end

            // Bus read: register read data
            if (i_qbu_bus_rd) begin
                case (i_qbu_bus_addr)
                    8'h00: ro_qbu_bus_dout = {15'h0,  ri_preempt_enable};
                    8'h01: ro_qbu_bus_dout = {15'h0,  ro_verify_enabled};
                    8'h02: ro_qbu_bus_dout = {14'h0,  ri_rx_busy, ri_tx_busy};
                    8'h03: ro_qbu_bus_dout = ri_tx_fragment_cnt;
                    8'h04: ro_qbu_bus_dout = ri_rx_fragment_cnt;
                    8'h05: ro_qbu_bus_dout = {15'h0,  ri_rx_fragment_mismatch};
                    8'h06: ro_qbu_bus_dout = {14'h0,  ri_preemptable_frame, ri_preempt_active};
                    8'h07: ro_qbu_bus_dout = ri_err_rx_crc_cnt;
                    8'h08: ro_qbu_bus_dout = ri_err_rx_frame_cnt;
                    8'h09: ro_qbu_bus_dout = ri_err_fragment_cnt;
                    8'h0A: ro_qbu_bus_dout = ri_err_verify_cnt;
                    8'h0B: ro_qbu_bus_dout = {8'h0,   ro_min_frag_size};
                    8'h0C: ro_qbu_bus_dout = {8'h0,   ro_verify_timer};
                    8'h0D: ro_qbu_bus_dout = {8'h0,   ro_ipg_timer};
                    8'h0E: ro_qbu_bus_dout = 16'h0;  // reset self-clearing
                    8'h0F: ro_qbu_bus_dout = 16'h0;  // verify_ctrl self-clearing
                    8'h10: ro_qbu_bus_dout = ri_tx_frames_cnt;
                    8'h11: ro_qbu_bus_dout = ri_rx_frames_cnt;
                    8'h12: ro_qbu_bus_dout = ri_preempt_success_cnt;
                    8'h13: ro_qbu_bus_dout = ro_watchdog_timer_l;
                    8'h14: ro_qbu_bus_dout = {8'h0,   ro_watchdog_timer_h};
                    8'h15: ro_qbu_bus_dout = {15'h0,  ri_tx_timeout};
                    8'h16: ro_qbu_bus_dout = {8'h0,   ri_frag_next_rx};
                    8'h17: ro_qbu_bus_dout = {8'h0,   ri_frag_next_tx};
                    8'h18: ro_qbu_bus_dout = {8'h0,   ri_frame_seq};
                    default: ro_qbu_bus_dout = 16'h0;
                endcase
            end else begin
                ro_qbu_bus_dout = 16'h0;
            end
        end
    end

endmodule





