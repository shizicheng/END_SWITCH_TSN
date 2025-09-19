//-----------------------------------------------------------------------------
// Copyright (C) 2009 OutputLogic.com
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//-----------------------------------------------------------------------------
// CRC module for data[59:0] ,   crc[14:0]=1+x^2+x^3+x^4+x^7+x^8+x^9+x^11+x^13+x^15;
//-----------------------------------------------------------------------------
module hash_cacl(
  input [59:0] i_data_in,
  input i_crc_en,
  output [14:0] o_crc_out,
  input i_rst,
  input i_clk);

  reg [14:0] lfsr_q,lfsr_c;

  assign o_crc_out = lfsr_q;

  always @(*) begin
    lfsr_c[0] = lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[7] ^ i_data_in[0] ^ i_data_in[2] ^ i_data_in[7] ^ i_data_in[10] ^ i_data_in[13] ^ i_data_in[14] ^ i_data_in[17] ^ i_data_in[18] ^ i_data_in[19] ^ i_data_in[21] ^ i_data_in[24] ^ i_data_in[25] ^ i_data_in[26] ^ i_data_in[28] ^ i_data_in[29] ^ i_data_in[31] ^ i_data_in[32] ^ i_data_in[34] ^ i_data_in[36] ^ i_data_in[37] ^ i_data_in[41] ^ i_data_in[44] ^ i_data_in[46] ^ i_data_in[48] ^ i_data_in[52];
    lfsr_c[1] = lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[8] ^ i_data_in[1] ^ i_data_in[3] ^ i_data_in[8] ^ i_data_in[11] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[18] ^ i_data_in[19] ^ i_data_in[20] ^ i_data_in[22] ^ i_data_in[25] ^ i_data_in[26] ^ i_data_in[27] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[32] ^ i_data_in[33] ^ i_data_in[35] ^ i_data_in[37] ^ i_data_in[38] ^ i_data_in[42] ^ i_data_in[45] ^ i_data_in[47] ^ i_data_in[49] ^ i_data_in[53];
    lfsr_c[2] = lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[9] ^ i_data_in[0] ^ i_data_in[4] ^ i_data_in[7] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[12] ^ i_data_in[13] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[17] ^ i_data_in[18] ^ i_data_in[20] ^ i_data_in[23] ^ i_data_in[24] ^ i_data_in[25] ^ i_data_in[27] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[32] ^ i_data_in[33] ^ i_data_in[37] ^ i_data_in[38] ^ i_data_in[39] ^ i_data_in[41] ^ i_data_in[43] ^ i_data_in[44] ^ i_data_in[50] ^ i_data_in[52] ^ i_data_in[54];
    lfsr_c[3] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[10] ^ i_data_in[0] ^ i_data_in[1] ^ i_data_in[2] ^ i_data_in[5] ^ i_data_in[7] ^ i_data_in[8] ^ i_data_in[11] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[32] ^ i_data_in[33] ^ i_data_in[36] ^ i_data_in[37] ^ i_data_in[38] ^ i_data_in[39] ^ i_data_in[40] ^ i_data_in[41] ^ i_data_in[42] ^ i_data_in[45] ^ i_data_in[46] ^ i_data_in[48] ^ i_data_in[51] ^ i_data_in[52] ^ i_data_in[53] ^ i_data_in[55];
    lfsr_c[4] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[11] ^ i_data_in[0] ^ i_data_in[1] ^ i_data_in[3] ^ i_data_in[6] ^ i_data_in[7] ^ i_data_in[8] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[12] ^ i_data_in[13] ^ i_data_in[14] ^ i_data_in[16] ^ i_data_in[18] ^ i_data_in[19] ^ i_data_in[21] ^ i_data_in[24] ^ i_data_in[25] ^ i_data_in[26] ^ i_data_in[28] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[32] ^ i_data_in[33] ^ i_data_in[36] ^ i_data_in[38] ^ i_data_in[39] ^ i_data_in[40] ^ i_data_in[42] ^ i_data_in[43] ^ i_data_in[44] ^ i_data_in[47] ^ i_data_in[48] ^ i_data_in[49] ^ i_data_in[53] ^ i_data_in[54] ^ i_data_in[56];
    lfsr_c[5] = lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[12] ^ i_data_in[1] ^ i_data_in[2] ^ i_data_in[4] ^ i_data_in[7] ^ i_data_in[8] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[11] ^ i_data_in[13] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[17] ^ i_data_in[19] ^ i_data_in[20] ^ i_data_in[22] ^ i_data_in[25] ^ i_data_in[26] ^ i_data_in[27] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[31] ^ i_data_in[33] ^ i_data_in[34] ^ i_data_in[37] ^ i_data_in[39] ^ i_data_in[40] ^ i_data_in[41] ^ i_data_in[43] ^ i_data_in[44] ^ i_data_in[45] ^ i_data_in[48] ^ i_data_in[49] ^ i_data_in[50] ^ i_data_in[54] ^ i_data_in[55] ^ i_data_in[57];
    lfsr_c[6] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[13] ^ i_data_in[2] ^ i_data_in[3] ^ i_data_in[5] ^ i_data_in[8] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[11] ^ i_data_in[12] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[18] ^ i_data_in[20] ^ i_data_in[21] ^ i_data_in[23] ^ i_data_in[26] ^ i_data_in[27] ^ i_data_in[28] ^ i_data_in[30] ^ i_data_in[31] ^ i_data_in[32] ^ i_data_in[34] ^ i_data_in[35] ^ i_data_in[38] ^ i_data_in[40] ^ i_data_in[41] ^ i_data_in[42] ^ i_data_in[44] ^ i_data_in[45] ^ i_data_in[46] ^ i_data_in[49] ^ i_data_in[50] ^ i_data_in[51] ^ i_data_in[55] ^ i_data_in[56] ^ i_data_in[58];
    lfsr_c[7] = lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[14] ^ i_data_in[0] ^ i_data_in[2] ^ i_data_in[3] ^ i_data_in[4] ^ i_data_in[6] ^ i_data_in[7] ^ i_data_in[9] ^ i_data_in[11] ^ i_data_in[12] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[18] ^ i_data_in[22] ^ i_data_in[25] ^ i_data_in[26] ^ i_data_in[27] ^ i_data_in[33] ^ i_data_in[34] ^ i_data_in[35] ^ i_data_in[37] ^ i_data_in[39] ^ i_data_in[42] ^ i_data_in[43] ^ i_data_in[44] ^ i_data_in[45] ^ i_data_in[47] ^ i_data_in[48] ^ i_data_in[50] ^ i_data_in[51] ^ i_data_in[56] ^ i_data_in[57] ^ i_data_in[59];
    lfsr_c[8] = lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[12] ^ lfsr_q[13] ^ i_data_in[0] ^ i_data_in[1] ^ i_data_in[2] ^ i_data_in[3] ^ i_data_in[4] ^ i_data_in[5] ^ i_data_in[8] ^ i_data_in[12] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[18] ^ i_data_in[21] ^ i_data_in[23] ^ i_data_in[24] ^ i_data_in[25] ^ i_data_in[27] ^ i_data_in[29] ^ i_data_in[31] ^ i_data_in[32] ^ i_data_in[35] ^ i_data_in[37] ^ i_data_in[38] ^ i_data_in[40] ^ i_data_in[41] ^ i_data_in[43] ^ i_data_in[45] ^ i_data_in[49] ^ i_data_in[51] ^ i_data_in[57] ^ i_data_in[58];
    lfsr_c[9] = lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[13] ^ lfsr_q[14] ^ i_data_in[0] ^ i_data_in[1] ^ i_data_in[3] ^ i_data_in[4] ^ i_data_in[5] ^ i_data_in[6] ^ i_data_in[7] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[18] ^ i_data_in[21] ^ i_data_in[22] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[31] ^ i_data_in[33] ^ i_data_in[34] ^ i_data_in[37] ^ i_data_in[38] ^ i_data_in[39] ^ i_data_in[42] ^ i_data_in[48] ^ i_data_in[50] ^ i_data_in[58] ^ i_data_in[59];
    lfsr_c[10] = lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[14] ^ i_data_in[1] ^ i_data_in[2] ^ i_data_in[4] ^ i_data_in[5] ^ i_data_in[6] ^ i_data_in[7] ^ i_data_in[8] ^ i_data_in[10] ^ i_data_in[11] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[17] ^ i_data_in[19] ^ i_data_in[22] ^ i_data_in[23] ^ i_data_in[30] ^ i_data_in[31] ^ i_data_in[32] ^ i_data_in[34] ^ i_data_in[35] ^ i_data_in[38] ^ i_data_in[39] ^ i_data_in[40] ^ i_data_in[43] ^ i_data_in[49] ^ i_data_in[51] ^ i_data_in[59];
    lfsr_c[11] = lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[5] ^ i_data_in[0] ^ i_data_in[3] ^ i_data_in[5] ^ i_data_in[6] ^ i_data_in[8] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[11] ^ i_data_in[12] ^ i_data_in[13] ^ i_data_in[14] ^ i_data_in[16] ^ i_data_in[19] ^ i_data_in[20] ^ i_data_in[21] ^ i_data_in[23] ^ i_data_in[25] ^ i_data_in[26] ^ i_data_in[28] ^ i_data_in[29] ^ i_data_in[33] ^ i_data_in[34] ^ i_data_in[35] ^ i_data_in[37] ^ i_data_in[39] ^ i_data_in[40] ^ i_data_in[46] ^ i_data_in[48] ^ i_data_in[50];
    lfsr_c[12] = lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[6] ^ i_data_in[1] ^ i_data_in[4] ^ i_data_in[6] ^ i_data_in[7] ^ i_data_in[9] ^ i_data_in[10] ^ i_data_in[11] ^ i_data_in[12] ^ i_data_in[13] ^ i_data_in[14] ^ i_data_in[15] ^ i_data_in[17] ^ i_data_in[20] ^ i_data_in[21] ^ i_data_in[22] ^ i_data_in[24] ^ i_data_in[26] ^ i_data_in[27] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[34] ^ i_data_in[35] ^ i_data_in[36] ^ i_data_in[38] ^ i_data_in[40] ^ i_data_in[41] ^ i_data_in[47] ^ i_data_in[49] ^ i_data_in[51];
    lfsr_c[13] = lfsr_q[1] ^ lfsr_q[5] ^ i_data_in[0] ^ i_data_in[5] ^ i_data_in[8] ^ i_data_in[11] ^ i_data_in[12] ^ i_data_in[15] ^ i_data_in[16] ^ i_data_in[17] ^ i_data_in[19] ^ i_data_in[22] ^ i_data_in[23] ^ i_data_in[24] ^ i_data_in[26] ^ i_data_in[27] ^ i_data_in[29] ^ i_data_in[30] ^ i_data_in[32] ^ i_data_in[34] ^ i_data_in[35] ^ i_data_in[39] ^ i_data_in[42] ^ i_data_in[44] ^ i_data_in[46] ^ i_data_in[50];
    lfsr_c[14] = lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[6] ^ i_data_in[1] ^ i_data_in[6] ^ i_data_in[9] ^ i_data_in[12] ^ i_data_in[13] ^ i_data_in[16] ^ i_data_in[17] ^ i_data_in[18] ^ i_data_in[20] ^ i_data_in[23] ^ i_data_in[24] ^ i_data_in[25] ^ i_data_in[27] ^ i_data_in[28] ^ i_data_in[30] ^ i_data_in[31] ^ i_data_in[33] ^ i_data_in[35] ^ i_data_in[36] ^ i_data_in[40] ^ i_data_in[43] ^ i_data_in[45] ^ i_data_in[47] ^ i_data_in[51];

  end // always

  always @(posedge i_clk, posedge i_rst) begin
    if(i_rst) begin
      lfsr_q <= {15{1'b1}};
    end
    else begin
      lfsr_q <= i_crc_en ? lfsr_c : lfsr_q;
    end
  end // always
endmodule // crc