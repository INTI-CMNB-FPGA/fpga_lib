//
// LoopCheck
//
// Author(s):
// * Rodrigo A. Melo
//
// Copyright (c) 2016-2017 Authors and INTI
// Distributed under the BSD 3-Clause License
//
// no timescale needed

module LoopCheck(
input wire tx_clk_i,
input wire tx_rst_i,
input wire tx_stb_i,
input wire [DWIDTH - 1:0] tx_data_i,
output reg [DWIDTH - 1:0] tx_data_o,
input wire rx_clk_i,
input wire rx_rst_i,
input wire rx_stb_i,
input wire [DWIDTH - 1:0] rx_data_i,
output wire [4:0] rx_errors_o
);

parameter [31:0] DWIDTH=8;
// Data width
// TX side
// RX side



parameter NOT_RECEIVED = 0;
parameter VAL_MISSMATCH = 1;
parameter QTY_MISSMATCH = 2;
parameter QTY_LESS = 3;
parameter QTY_MORE = 4;
reg [DWIDTH:0] tx_qty; reg [DWIDTH:0] rx_qty;
reg [4:0] errors;

  always @(posedge tx_clk_i) begin
    if(tx_rst_i == 1'b1) begin
      tx_data_o <= tx_data_i;
      tx_qty <= {1'b0,tx_data_i};
    end
    else if(tx_stb_i == 1'b1) begin
      tx_data_o <= tx_qty[DWIDTH - 1:0] + 1;
      tx_qty <= tx_qty + 1;
    end
  end

  always @(posedge rx_clk_i) begin
    if(rx_rst_i == 1'b1) begin
      rx_qty <= {1'b0,tx_data_i};
      errors <= 5'b00001;
    end
    else if(rx_stb_i == 1'b1) begin
      errors[NOT_RECEIVED] <= 1'b0;
      if(rx_data_i != (rx_qty[DWIDTH - 1:0])) begin
        errors[VAL_MISSMATCH] <= 1'b1;
      end
      if(tx_qty == (rx_qty + 1)) begin
        errors[QTY_MISSMATCH] <= 1'b0;
        errors[QTY_LESS] <= 1'b0;
        errors[QTY_MORE] <= 1'b0;
      end
      else if(tx_qty > (rx_qty + 1)) begin
        errors[QTY_MISSMATCH] <= 1'b1;
        errors[QTY_LESS] <= 1'b1;
        errors[QTY_MORE] <= 1'b0;
      end
      else begin
        // tx_qty<rx_qty+1
        errors[QTY_MISSMATCH] <= 1'b1;
        errors[QTY_LESS] <= 1'b0;
        errors[QTY_MORE] <= 1'b1;
      end
      rx_qty <= rx_qty + 1;
    end
  end

  assign rx_errors_o = errors;

endmodule
