/*
*  I2C Slave Testbench
*
*  Author(s):
*  * Rodrigo A. Melo
*
*  Copyright (c) 2019 Authors and INTI
*  Distributed under the BSD 3-Clause License
*/

`timescale 1ns/100ps

module I2C_Slave_Tb;

   localparam SYS_FREQ    = 40e6;
   localparam SEMI_PERIOD = 1e9 / ( SYS_FREQ * 2 );

   reg clk, rst;
   reg scl, sda;

   // Clock ans reset generation
   initial begin
      clk = 1'b1;
      rst = 1'b1;
      repeat(5) #SEMI_PERIOD clk = !clk;
      rst = 1'b0;
      forever   #SEMI_PERIOD clk = !clk;
   end

   initial begin
      $dumpfile ("i2c_slave_tb.vcd"); 
      $dumpvars;
      //
      scl <= 1;
      sda <= 1;
      @(negedge rst);
      #50;
      // Start
      sda <= 0;
      #(SEMI_PERIOD / 4);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 1
      sda <= 1;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 2
      sda <= 0;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 3
      sda <= 1;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 4
      sda <= 0;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 5
      sda <= 0;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 6
      sda <= 1;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Bit 7
      sda <= 1;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // OP = Write
      sda <= 0;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Wait ACK
      sda <= 1'bz;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 2);
      scl <= 0;
      #(SEMI_PERIOD / 4);
      // Stop
      sda <= 0;
      #(SEMI_PERIOD / 4);
      scl <= 1;
      #(SEMI_PERIOD / 4);
      sda <= 1;
      //
      #50 $finish;
   end

endmodule
