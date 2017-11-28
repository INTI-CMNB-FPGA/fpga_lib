//
// Boundary
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2016 Authors and INTI
// Distributed under the BSD 3-Clause License
//
// no timescale needed

module Boundary(
input wire clk_i,
input wire [BYTES - 1:0] pattern_i,
input wire [BYTES - 1:0] comma_i,
input wire [BYTES * 8 - 1:0] data_i,
output wire [BYTES - 1:0] comma_o,
output wire [BYTES * 8 - 1:0] data_o
);

parameter [31:0] BYTES=4;



parameter BYTES2 = BYTES * 2;
parameter BYTES3 = BYTES * 3;
parameter WIDTH = BYTES * 8;
parameter WIDTH2 = WIDTH * 2;
parameter WIDTH3 = WIDTH * 3;
reg [BYTES - 1:0] comma_r1; reg [BYTES - 1:0] comma_r2;
wire [BYTES3 - 1:0] comma;
reg [WIDTH - 1:0] data_r1; reg [WIDTH - 1:0] data_r2;
wire [WIDTH3 - 1:0] data;
reg [31:0] index = 0;

  always @(posedge clk_i) begin
    comma_r1 <= comma_i;
    comma_r2 <= comma_r1;
    data_r1 <= data_i;
    data_r2 <= data_r1;
  end

  assign comma = {comma_i,comma_r1,comma_r2};
  assign data = {data_i,data_r1,data_r2};
  always @(posedge clk_i) begin
    for (i=0; i <= BYTES - 1; i = i + 1) begin
      if(comma[BYTES2 + i - 1:BYTES + i] == pattern_i) begin
        index <= i;
      end
    end
  end

  assign comma_o = comma[BYTES + index - 1:index];
  assign data_o = data[WIDTH + index * 8 - 1:index * 8];

endmodule
