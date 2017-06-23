--
-- Numeric testbench
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.Numeric.all;
use FPGALIB.Simul.all;

entity Numeric_tb is
end entity Numeric_tb;

architecture Testbench of Numeric_tb is
begin

   test: process
   begin
      print("* Testing minimum and maximum");
      assert minimum(2,9)=2 report "minimum fail"    severity failure;
      assert maximum(2,9)=9 report "maximum fail"    severity failure;
      print("* Testing clog2");
      assert clog2(1)=0     report "clog2(1) fail"   severity failure;
      assert clog2(2)=1     report "clog2(2) fail"   severity failure;
      assert clog2(3)=2     report "clog2(3) fail"   severity failure;
      assert clog2(4)=2     report "clog2(4) fail"   severity failure;
      assert clog2(5)=3     report "clog2(5) fail"   severity failure;
      assert clog2(6)=3     report "clog2(6) fail"   severity failure;
      assert clog2(7)=3     report "clog2(7) fail"   severity failure;
      assert clog2(8)=3     report "clog2(8) fail"   severity failure;
      assert clog2(9)=4     report "clog2(9) fail"   severity failure;
      assert clog2(1e3)=10  report "clog2(1e3) fail" severity failure;
      assert clog2(1e4)=14  report "clog2(1e4) fail" severity failure;
      assert clog2(1e5)=17  report "clog2(1e5) fail" severity failure;
      assert clog2(1e9)=30  report "clog2(1e9) fail" severity failure;
      print("* Testing convesions");
      assert to_integer("00001001")=9  report "to_integer of 00001001 must be 9" severity failure;
      assert to_integer('1')=1         report "to_integer of 1 must be 1"        severity failure;
      assert to_natural("00001001")=9  report "to_natural of 00001001 must be 9" severity failure;
      assert to_logic(1)='1'           report "to_logic of 1 must be 1"          severity failure;
      assert to_vector(9,8)="00001001" report "to_vector of 9 must be 00001001"  severity failure;
      wait;
   end process test;

end architecture Testbench;
