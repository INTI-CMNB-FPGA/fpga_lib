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

parameter FREQUENCY = 25e6;
parameter SECONDS   = 1;

parameter DIV = FREQUENCY * SECONDS - 1;
reg blink;
reg [$clog2(DIV):0] cnt = 0;

always @(posedge clk_i) begin : P1
   if (rst_i == 1'b1) begin
      cnt = 0;
      blink <= 1'b0;
   end else begin
      if (cnt == DIV) begin
         cnt = 0;
         blink <=  ~(blink);
      end else begin
         cnt = cnt + 1;
      end
   end
end

assign blink_o = blink;

endmodule
