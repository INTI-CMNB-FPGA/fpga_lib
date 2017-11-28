//
// Gray Synchronizer
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2017 Authors and INTI
// Distributed under the BSD 3-Clause License
//
// no timescale needed

module Gray_Sync(
input wire clk_i,
input wire [WIDTH - 1:0] data_i,
output wire [WIDTH - 1:0] data_o
);

parameter [31:0] WIDTH=8;
parameter [31:0] DEPTH=2;



wire [WIDTH - 1:0] grayi; wire [WIDTH - 1:0] grayo;

  assign grayi = bin2gray(data_i);
  FFchain #(
      .WIDTH(WIDTH),
    .DEPTH(DEPTH))
  i_sync(
      .clk_i(clk_i),
    .rst_i(1'b0),
    .ena_i(1'b1),
    .data_i(grayi),
    .data_o(grayo));

  assign data_o = gray2bin(grayo);

endmodule
