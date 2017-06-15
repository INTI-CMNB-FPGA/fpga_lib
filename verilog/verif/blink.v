//
// Blink
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2015 Authors and INTI
// Distributed under the BSD 3-Clause License
//

module Blink(
   input  wire clk_i,
   input  wire rst_i,
   output wire blink_o
);

parameter [31:0] FREQUENCY=25E6;
parameter [31:0] SECONDS=1;

parameter DIV = FREQUENCY * SECONDS;
reg blink;
reg [$clog2(DIV)-1:0] cnt = 0;

always @(posedge clk_i) begin : P1
   if (rst_i == 1'b1) begin
      cnt = 0;
      blink <= 1'b0;
   end else begin
      if (cnt == DIV) begin
         cnt = 0;
         blink <=  ~((blink));
      end else begin
        cnt = cnt + 1;
      end
   end
end

assign blink_o = blink;

endmodule
