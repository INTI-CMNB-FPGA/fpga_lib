// File ../temp/blink_tmp.vhdl translated with vhd2vl v2.5 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002, 2005, 2008-2010, 2015 Larry Doolittle - LBNL
//     http://doolittle.icarus.com/~larry/vhd2vl/
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//
// Blink
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2015 Authors and INTI
// Distributed under the BSD 3-Clause License
//
// no timescale needed

module Blink(
input wire clk_i,
input wire rst_i,
output wire blink_o
);

parameter [31:0] FREQUENCY=25E6;
parameter [31:0] SECONDS=1;



parameter DIV = FREQUENCY * SECONDS - 1;
reg blink;
reg [$clog2(DIV):0] cnt = 0;

  always @(posedge clk_i) begin : P1

    if(rst_i == 1'b 1) begin
      cnt = 0;
      blink <= 1'b 0;
    end
    else begin
      if(cnt == DIV) begin
        cnt = 0;
        blink <=  ~((blink));
      end
      else begin
        cnt = cnt + 1;
      end
    end
  end

  assign blink_o = blink;

endmodule
