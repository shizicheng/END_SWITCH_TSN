//  FPGA开发组 - Simple Dual Port 2 Clock RAM 程序模板

//  Xilinx Simple Dual Port 2 Clock RAM
//  This code implements a parameterizable SDP dual clock memory.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.
module ram_simple2port #(
parameter RAM_WIDTH = 32,                  // Specify RAM data width
parameter RAM_DEPTH = 16,                  // Specify RAM depth (number of entries)
parameter RAM_PERFORMANCE = "LOW_LATENCY", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
parameter INIT_FILE = ""                   // Specify name/location of RAM initialization file if using one (leave blank if not)
)(
  addra   ,    // Write address bus, width determined from RAM_DEPTH
  addrb   ,    // Read address bus, width determined from RAM_DEPTH
  dina    ,    // RAM input data
  clka    ,    // Write clock
  clkb    ,    // Read clock
  wea     ,    // Write enable
  enb     ,    // Read Enable, for additional power savings, disable when not in use
  rstb    ,    // Output reset (does not affect memory contents)
  regceb  ,    // Output register enable
  doutb        // RAM output data
);

input [clogb2(RAM_DEPTH-1)-1:0] addra; // Write address bus, width determined from RAM_DEPTH
input [clogb2(RAM_DEPTH-1)-1:0] addrb; // Read address bus, width determined from RAM_DEPTH
input [RAM_WIDTH-1:0] dina;          // RAM input data
input clka;                          // Write clock
input clkb;                          // Read clock
input wea;                           // Write enable
input enb;                           // Read Enable, for additional power savings, disable when not in use
input rstb;                          // Output reset (does not affect memory contents)
input regceb;                        // Output register enable
output [RAM_WIDTH-1:0] doutb;                  // RAM output data

wire [clogb2(RAM_DEPTH-1)-1:0] addra; // Write address bus, width determined from RAM_DEPTH
wire [clogb2(RAM_DEPTH-1)-1:0] addrb; // Read address bus, width determined from RAM_DEPTH
wire [RAM_WIDTH-1:0] dina;          // RAM input data
wire clka;                          // Write clock
wire clkb;                          // Read clock
wire wea;                           // Write enable
wire enb;                           // Read Enable, for additional power savings, disable when not in use
wire rstb;                          // Output reset (does not affect memory contents)
wire regceb;                        // Output register enable
wire [RAM_WIDTH-1:0] doutb;                  // RAM output data

reg [RAM_WIDTH-1:0] ram_2port [RAM_DEPTH-1:0];
reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};

// The following code either initializes the memory values to a specified file or to all zeros to match hardware
generate
if (INIT_FILE != "") begin: use_init_file
  initial
    $readmemh(INIT_FILE, ram_2port, 0, RAM_DEPTH-1);
end else begin: init_bram_to_zero
  integer ram_index;
  initial
    for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
      ram_2port[ram_index] = {RAM_WIDTH{1'b0}};
end
endgenerate

integer i;

always @(posedge clka) begin
 if (wea) begin
    ram_2port[addra] <= dina;
 end
end


always @(posedge clkb)
if (enb)
  ram_data <= ram_2port[addrb];

//  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
generate
if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

  // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
   assign doutb = ram_data;

end else begin: output_register

  // The following is a 2 clock cycle read latency with improve clock-to-out timing

  reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

  always @(posedge clkb)
    if (rstb)
      doutb_reg <= {RAM_WIDTH{1'b0}};
    else if (regceb)
      doutb_reg <= ram_data;

  assign doutb = doutb_reg;

end
endgenerate

//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
input integer depth;
  for (clogb2=0; depth>0; clogb2=clogb2+1)
    depth = depth >> 1;
endfunction
                    
endmodule 