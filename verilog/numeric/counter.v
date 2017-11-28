//
// Counter
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2017 Authors and INTI
// Distributed under the BSD 3-Clause License
//
// no timescale needed

module Counter(
input wire clk_i,
input wire rst_i,
input wire ena_i,
output wire [$clog2(DEPTH) - 1:0] count_o,
output reg last_o
);

parameter [31:0] DEPTH=8;
// Clock
// Reset
// Input Enable
// Counter value
// Last value



parameter AWIDTH = $clog2(DEPTH);
reg [AWIDTH - 1:0] count = 1'b0;

  always @(posedge clk_i) begin
    last_o <= 1'b0;
    if(rst_i == 1'b1) begin
      count <= {(((AWIDTH - 1))-((0))+1){1'b0}};
    end
    else begin
      if(ena_i == 1'b1) begin
        if(count < (DEPTH - 1)) begin
          count <= count + 1;
          if(count == (DEPTH - 2)) begin
            last_o <= 1'b1;
          end
        end
        else begin
          count <= {(((AWIDTH - 1))-((0))+1){1'b0}};
        end
      end
    end
  end

  assign count_o = count;

endmodule
