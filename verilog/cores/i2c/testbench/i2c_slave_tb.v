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

   localparam SYS_PERIOD = 20;    //    20 ns -> 50 MHz
   localparam I2C_PERIOD = 10000; // 10000 ns -> 10 0KHz

   reg clk, rst;
   reg scl, sda;

   initial begin // Clock ans reset generation
      $dumpfile ("i2c_slave_tb.vcd"); 
      $dumpvars;
      clk = 1'b1;
      rst = 1'b1;
      repeat(5) #(SYS_PERIOD/2) clk = !clk;
      rst = 1'b0;
      forever   #(SYS_PERIOD/2) clk = !clk;
   end

   initial begin
      $display("* Start");
      prepare();
      wait (rst == 0);
      #(5*I2C_PERIOD);
      $display("Write REG0 and REG1 with 0xCAFE");
      start();
      write(8'b10100110);
      write(8'b0);
      write(8'hCA);
      write(8'hFE);
      stop();
      #(5*I2C_PERIOD);
      $display("Read REG0 and REG1");
      start();
      write(8'b10100110);
      write(8'b0);
      start();
      write(8'b10100111);
      read(1'b0);
      read(1'b1);
      stop();
      $display("* End");
      #(5*I2C_PERIOD);
      $finish;
   end

   // I2C related tasks

   integer i;

   task prepare;
   begin
      sda = 1;
      scl = 1;
   end
   endtask

   task start;
   begin
      sda = 1;
      scl = 1;
      #(I2C_PERIOD / 2);
      sda = 0;
      #(I2C_PERIOD / 4);
      scl = 0;
      #(I2C_PERIOD / 4);
   end
   endtask

   task stop;
   begin
      sda = 0;
      scl = 0;
      #(I2C_PERIOD / 4);
      scl = 1;
      #(I2C_PERIOD / 4);
      sda = 1;
      #(I2C_PERIOD / 2);
   end
   endtask

   task drive(input val);
   begin
      sda = val;
      scl = 0;
      #(I2C_PERIOD / 4);
      scl = 1;
      #(I2C_PERIOD / 2);
      scl = 0;
      #(I2C_PERIOD / 4);
   end
   endtask

   task write(input [7:0] data);
   begin
      for (i = 7; i >= 0; i--) drive(data[i]);
      drive(1'bz); // ACK
   end
   endtask

   task read(input ack);
   begin
      for (i = 7; i >= 0; i--) drive(1'bz);
      drive(ack);
   end
   endtask

endmodule
