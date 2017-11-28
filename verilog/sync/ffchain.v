//
// FF Chain
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2015-2017 Authors and INTI
// Distributed under the BSD 3-Clause License
//
// no timescale needed

module FFchain(
input wire clk_i,
input wire rst_i,
input wire ena_i,
input wire [WIDTH - 1:0] data_i,
output wire [WIDTH - 1:0] data_o
);

parameter [31:0] WIDTH=8;
parameter [31:0] DEPTH=2;




reg [WIDTH - 1:0] data_r[0:DEPTH - 1] = 1'b0;

  always @(posedge clk_i) begin
    if(rst_i == 1'b1) begin
      data_r <= {(((WIDTH - 1))-((0))+1){1'b0}};
    end
    else if(ena_i == 1'b1) begin
      for (i=0; i <= DEPTH - 1; i = i + 1) begin
        if(i == 0) begin
          data_r[0] <= data_i;
        end
        else begin
          data_r[i] <= data_r[i - 1];
        end
      end
    end
  end

  assign data_o = data_r[DEPTH - 1];

endmodule
