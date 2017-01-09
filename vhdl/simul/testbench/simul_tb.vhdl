--
-- Simul testbench
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library STD;
use STD.textio.all;
library FPGALIB;
use FPGALIB.Simul.all;

entity Simul_tb is
end entity Simul_tb;

architecture Testbench of Simul_tb is
begin
   test:
   process
      variable l: line;
      variable ok: boolean;
      variable slv_wr, slv_rd : std_logic_vector(7 downto 0);
      variable slv : std_logic_vector(7 downto 0):="10011010";
      --variable str : string(1 to 5);
   begin
      --str:=to_str(9);
      --print(str);
      print("*",80);
      print("Testing print function");
      print("*",80);
      print("*");
      print("**");
      print("*",3);
      print("**",2);
      print("*",80);
      print("Testing conversion functions");
      print("*",80);
      print(bin2hex("1100101011111110"));
      print(hex2bin("CAFE"));
      print("* to_hex");
      print(to_str(slv,'H'));
      print(to_str(unsigned(slv),'h'));
      print(to_str(signed(slv),'H'));
      print("* to_str");
      print(to_str(slv));
      print(to_str(unsigned(slv)));
      print(to_str(signed(slv)));
      print("* to_char");
      print(to_char('0'));
      print(to_char('1'));
      print(to_char('X'));
      print(to_char('Z'));
      print(to_char(to_vector("01000001")));
      print(to_char(66));
      print(to_char(x"42"));
      print("* to_logic");
      print(to_char(to_logic('L')));
      print(to_char(to_logic('H')));
      print(to_char(to_logic('U')));
      print(to_char(to_logic('-')));
      print(to_char(to_logic('l')));
      print(to_char(to_logic('h')));
      print(to_char(to_logic('u')));
      print("* to_vector");
      print(to_str(to_vector("01LHZXUW-2")));
      print("*",80);
      print("Testing read/write procedures");
      print("*",80);
      slv_wr:="10011010";
      print("* Write and read of STD_LOGIC_VECTOR");
      write(l,slv_wr);
      read(l,slv_rd);
      print(to_str(slv_rd));
      write(l,slv_wr);
      read(l,slv_rd,ok);
      print(to_str(slv_rd));
      print("* Write and read of STD_LOGIC");
      write(l,slv_wr(0));
      read(l,slv_rd(0));
      print(to_char(slv_rd(0)));
      write(l,slv_wr(1));
      read(l,slv_rd(1),ok);
      print(to_char(slv_rd(1)));
      print("*",80);
      print("End of test");
      wait;
   end process test;
end architecture Testbench;
