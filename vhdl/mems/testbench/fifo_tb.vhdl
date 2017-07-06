--
-- FIFO testbench
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.MEMs.all;
use FPGALIB.Simul.all;

entity FIFO_tb is
end entity FIFO_tb;

architecture TestBench of FIFO_tb is

   constant DWIDTH      : positive:=8;
   constant DEPTH       : positive:=5;

   signal stop          : boolean;

   signal clk,   rst    : std_logic;
   signal wr_en, rd_en  : std_logic;
   signal datai, datao  : std_logic_vector(DWIDTH-1 downto 0);
   signal full,  empty  : std_logic;
   signal afull, aempty : std_logic;
   signal over,  under  : std_logic;
   signal valid         : std_logic;

   procedure wr_check(
      num:    natural;
      full:   in std_logic; vfull:  in std_logic;
      afull:  in std_logic; vafull: in std_logic;
      over:   in std_logic; vover:  in std_logic
   ) is
   begin
      assert full=vfull   report "Wrong Full Flag in "     & integer'image(num) severity failure;
      assert afull=vafull report "Wrong Almost Flag in "   & integer'image(num) severity failure;
      assert over=vover   report "Wrong Overflow Flag in " & integer'image(num) severity failure;
   end procedure wr_check;

   procedure rd_check(
      num:    natural;
      empty:  in std_logic; vempty:  in std_logic;
      aempty: in std_logic; vaempty: in std_logic;
      under:  in std_logic; vunder:  in std_logic;
      valid:  in std_logic; vvalid:  in std_logic
   ) is
   begin
      assert empty=vempty   report "Wrong Empty Flag in "     & integer'image(num) severity failure;
      assert aempty=vaempty report "Wrong Almost Empty in "   & integer'image(num) severity failure;
      assert under=vunder   report "Wrong Underflow Flag in " & integer'image(num) severity failure;
      assert valid=vvalid   report "Wrong Valid in "          & integer'image(num) severity failure;
   end procedure rd_check;

   procedure ctrl(
      signal clk:       in  std_logic;
      signal wr_en:     out std_logic;
             wr_en_val: in  std_logic;
      signal rd_en:     out std_logic;
             rd_en_val: in  std_logic;
      signal data:      out std_logic_vector;
             data_val:  in  std_logic_vector;
             wr_num:    inout natural;
             rd_num:    inout natural
   ) is
   begin
      if wr_en_val='1' and rd_en_val='1' then
         print("Write "&to_str(wr_num)&" - Read "&to_str(rd_num));
         wr_num := wr_num + 1;
         rd_num := rd_num + 1;
      elsif wr_en_val='1' then
         print("Write "&to_str(wr_num));
         wr_num := wr_num + 1;
      elsif rd_en_val='1' then
         print("Read "&to_str(rd_num));
         rd_num := rd_num + 1;
      else
         print("Nop");
      end if;
      wr_en <= wr_en_val;
      rd_en <= rd_en_val;
      data  <= data_val;
      wait until rising_edge(clk);
   end procedure ctrl;

begin

   clock_i : Clock
      generic map(FREQUENCY => 2)
      port map(clk_o => clk, rst_o => rst, stop_i => stop);

   fifo_sync_i: fifo_sync
   generic map (
      DWIDTH       => DWIDTH,
      DEPTH        => DEPTH,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 2
   )
   port map (
      clk_i        => clk,
      rst_i        => rst,
      -- write side
      wr_en_i      => wr_en,
      data_i       => datai,
      full_o       => full,
      afull_o      => afull,
      overflow_o   => over,
      -- read side
      rd_en_i      => rd_en,
      data_o       => datao,
      empty_o      => empty,
      aempty_o     => aempty,
      underflow_o  => under,
      valid_o      => valid
   );

   test_p : process
      variable wr_num, rd_num: natural:=0;
   begin
      ctrl(clk, wr_en, '0', rd_en, '0', datai, x"00", wr_num, rd_num);
      print("* Start of Test (DEPTH="&to_str(DEPTH)&")");
      wait until rising_edge(clk) and rst = '0';
      print("* Testing Write");
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"11", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"22", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"33", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"44", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"55", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"66", wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num);
      print("* Testing Read");
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num);
      print("* Testing Write+Read");
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"77", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"88", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '1', datai, x"99", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"AA", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '1', datai, x"BB", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '1', datai, x"CC", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '1', datai, x"DD", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"EE", wr_num, rd_num);
      ctrl(clk, wr_en, '1', rd_en, '0', datai, x"FF", wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num);
      print("* End of Test");
      stop <= TRUE;
      wait;
   end process test_p;

end architecture TestBench;
