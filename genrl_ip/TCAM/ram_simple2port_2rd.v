//  FPGA开发组 - Simple Dual Port 2 Clock RAM 程序模板 - 双读通道版本

//  Xilinx Simple Dual Port 2 Clock RAM with Dual Read Ports
//  This code implements a parameterizable SDP dual clock memory with two independent read channels.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.
module ram_simple2port #(
parameter RAM_WIDTH = 32,                  // Specify RAM data width
parameter RAM_DEPTH = 16,                  // Specify RAM depth (number of entries)
parameter RAM_PERFORMANCE = "LOW_LATENCY", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
parameter INIT_FILE = ""                   // Specify name/location of RAM initialization file if using one (leave blank if not)
)(
  addra   ,    // Write address bus, width determined from RAM_DEPTH
  addrb   ,    // Read address bus channel B, width determined from RAM_DEPTH
  addrc   ,    // Read address bus channel C, width determined from RAM_DEPTH
  dina    ,    // RAM input data
  clka    ,    // Write clock
  clkb    ,    // Read clock channel B
  clkc    ,    // Read clock channel C
  wea     ,    // Write enable
  enb     ,    // Read Enable channel B, for additional power savings, disable when not in use
  enc     ,    // Read Enable channel C, for additional power savings, disable when not in use
  rstb    ,    // Output reset channel B (does not affect memory contents)
  rstc    ,    // Output reset channel C (does not affect memory contents)
  regceb  ,    // Output register enable channel B
  regcec  ,    // Output register enable channel C
  doutb   ,    // RAM output data channel B
  doutc        // RAM output data channel C
);

input [clogb2(RAM_DEPTH-1)-1:0] addra; // Write address bus, width determined from RAM_DEPTH
input [clogb2(RAM_DEPTH-1)-1:0] addrb; // Read address bus channel B, width determined from RAM_DEPTH
input [clogb2(RAM_DEPTH-1)-1:0] addrc; // Read address bus channel C, width determined from RAM_DEPTH
input [RAM_WIDTH-1:0] dina;          // RAM input data
input clka;                          // Write clock
input clkb;                          // Read clock channel B
input clkc;                          // Read clock channel C
input wea;                           // Write enable
input enb;                           // Read Enable channel B, for additional power savings, disable when not in use
input enc;                           // Read Enable channel C, for additional power savings, disable when not in use
input rstb;                          // Output reset channel B (does not affect memory contents)
input rstc;                          // Output reset channel C (does not affect memory contents)
input regceb;                        // Output register enable channel B
input regcec;                        // Output register enable channel C
output [RAM_WIDTH-1:0] doutb;        // RAM output data channel B
output [RAM_WIDTH-1:0] doutc;        // RAM output data channel C

wire [clogb2(RAM_DEPTH-1)-1:0] addra; // Write address bus, width determined from RAM_DEPTH
wire [clogb2(RAM_DEPTH-1)-1:0] addrb; // Read address bus channel B, width determined from RAM_DEPTH
wire [clogb2(RAM_DEPTH-1)-1:0] addrc; // Read address bus channel C, width determined from RAM_DEPTH
wire [RAM_WIDTH-1:0] dina;          // RAM input data
wire clka;                          // Write clock
wire clkb;                          // Read clock channel B
wire clkc;                          // Read clock channel C
wire wea;                           // Write enable
wire enb;                           // Read Enable channel B, for additional power savings, disable when not in use
wire enc;                           // Read Enable channel C, for additional power savings, disable when not in use
wire rstb;                          // Output reset channel B (does not affect memory contents)
wire rstc;                          // Output reset channel C (does not affect memory contents)
wire regceb;                        // Output register enable channel B
wire regcec;                        // Output register enable channel C
wire [RAM_WIDTH-1:0] doutb;         // RAM output data channel B
wire [RAM_WIDTH-1:0] doutc;         // RAM output data channel C

reg [RAM_WIDTH-1:0] ram_2port [RAM_DEPTH-1:0];
reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};  // Read data register for channel B
reg [RAM_WIDTH-1:0] ram_data_c = {RAM_WIDTH{1'b0}};  // Read data register for channel C

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

// Read channel B
always @(posedge clkb)
if (enb)
  ram_data_b <= ram_2port[addrb];

// Read channel C  
always @(posedge clkc)
if (enc)
  ram_data_c <= ram_2port[addrc];

//  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
generate
if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

  // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
   assign doutb = ram_data_b;
   assign doutc = ram_data_c;

end else begin: output_register

  // The following is a 2 clock cycle read latency with improve clock-to-out timing

  reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] doutc_reg = {RAM_WIDTH{1'b0}};

  always @(posedge clkb)
    if (rstb)
      doutb_reg <= {RAM_WIDTH{1'b0}};
    else if (regceb)
      doutb_reg <= ram_data_b;

  always @(posedge clkc)
    if (rstc)
      doutc_reg <= {RAM_WIDTH{1'b0}};
    else if (regcec)
      doutc_reg <= ram_data_c;

  assign doutb = doutb_reg;
  assign doutc = doutc_reg;

end
endgenerate

//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
input integer depth;
  for (clogb2=0; depth>0; clogb2=clogb2+1)
    depth = depth >> 1;
endfunction
                    
endmodule 