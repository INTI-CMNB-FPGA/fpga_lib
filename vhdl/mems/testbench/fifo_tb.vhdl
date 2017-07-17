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

   constant DWIDTH       : positive:=8;
   constant DEPTH        : positive:=5;

   signal stop           : boolean;

   signal wr_clk, rd_clk : std_logic;
   signal wr_rst, rd_rst : std_logic;
   signal wr_en,  rd_en  : std_logic;
   signal datai,  datao  : std_logic_vector(DWIDTH-1 downto 0);
   signal full,   empty  : std_logic;
   signal afull,  aempty : std_logic;
   signal over,   under  : std_logic;
   signal         valid  : std_logic;

   procedure wr_check(
      full:   in std_logic; vfull:  in std_logic;
      afull:  in std_logic; vafull: in std_logic;
      over:   in std_logic; vover:  in std_logic
   ) is
   begin
      assert full=vfull   report "Wrong Full Flag"           severity failure;
      assert afull=vafull report "Wrong Almost Full Flag"    severity failure;
      assert over=vover   report "Wrong Overflow Flag"       severity failure;
   end procedure wr_check;

   procedure rd_check(
      empty:  in std_logic; vempty:  in std_logic;
      aempty: in std_logic; vaempty: in std_logic;
      under:  in std_logic; vunder:  in std_logic
   ) is
   begin
      assert empty=vempty   report "Wrong Empty Flag"        severity failure;
      assert aempty=vaempty report "Wrong Almost Empty Flag" severity failure;
      assert under=vunder   report "Wrong Underflow Flag"    severity failure;
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

   wr_clock_i : Clock
      generic map(FREQUENCY => 2)
      port map(clk_o => wr_clk, rst_o => wr_rst, stop_i => stop);

   rd_clock_i : Clock
      generic map(FREQUENCY => 3)
      port map(clk_o => rd_clk, rst_o => rd_rst, stop_i => stop);

   fifo_sync_i: fifo
   generic map (
      DWIDTH       => DWIDTH,
      DEPTH        => DEPTH,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 2,
      ASYNC        => FALSE
   )
   port map (
      -- write side
      wr_clk_i     => wr_clk,
      wr_rst_i     => wr_rst,
      wr_en_i      => wr_en,
      data_i       => datai,
      full_o       => full,
      afull_o      => afull,
      overflow_o   => over,
      -- read side
      rd_clk_i     => wr_clk,
      rd_rst_i     => wr_rst,
      rd_en_i      => rd_en,
      data_o       => datao,
      empty_o      => empty,
      aempty_o     => aempty,
      underflow_o  => under,
      valid_o      => valid
   );

   fifo_async_i: fifo
   generic map (
      DWIDTH       => DWIDTH,
      DEPTH        => DEPTH,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 2,
      ASYNC        => TRUE
   )
   port map (
      -- write side
      wr_clk_i     => wr_clk,
      wr_rst_i     => wr_rst,
      wr_en_i      => wr_en,
      data_i       => datai,
      full_o       => open,--full,
      afull_o      => open,--afull,
      overflow_o   => open,--over,
      -- read side
      rd_clk_i     => rd_clk,
      rd_rst_i     => rd_rst,
      rd_en_i      => rd_en,
      data_o       => open,--datao,
      empty_o      => open,--empty,
      aempty_o     => open,--aempty,
      underflow_o  => open,--under,
      valid_o      => open --valid
   );


   test_p : process
      variable wr_num, rd_num: natural:=1;
   begin
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, x"00", wr_num, rd_num);
      print("* Start of Test (DEPTH="&to_str(DEPTH)&")");
      wait until rising_edge(wr_clk) and wr_rst = '0';
      wr_check(full, '0', afull, '0', over, '0');
      print("* Testing Write");
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"11", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"22", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"33", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"44", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"55", wr_num, rd_num); wr_check(full, '0', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"66", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"77", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '1');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      print("* Testing Read");
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '1');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      print("* Testing Write");
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"88", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"99", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"AA", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"BB", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"CC", wr_num, rd_num); wr_check(full, '0', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"DD", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"EE", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '1');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      print("* Testing Read");
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '1');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      print("* Testing Write");
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"FF", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"00", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"11", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"22", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"33", wr_num, rd_num); wr_check(full, '0', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"44", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"55", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '1');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      print("* Testing Read");
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '1');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      print("* Testing Write+Read");
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"66", wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"77", wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '1', datai, x"88", wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"99", wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '1', datai, x"AA", wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '1', datai, x"BB", wr_num, rd_num);
      ctrl(wr_clk, wr_en, '1', rd_en, '1', datai, x"CC", wr_num, rd_num);
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"DD", wr_num, rd_num); wr_check(full, '0', afull, '0', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"EE", wr_num, rd_num); wr_check(full, '0', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '1', rd_en, '0', datai, x"FF", wr_num, rd_num); wr_check(full, '1', afull, '1', over, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num);
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '0', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '0', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '1', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      ctrl(wr_clk, wr_en, '0', rd_en, '0', datai, datai, wr_num, rd_num); rd_check(empty, '1', aempty, '1', under, '0');
      print("* End of Test");
      stop <= TRUE;
      wait;
   end process test_p;

   read_p : process
   begin
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"11" report "Received 0x"&to_str(datao,'H')&" but 0x11 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"22" report "Received 0x"&to_str(datao,'H')&" but 0x22 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"33" report "Received 0x"&to_str(datao,'H')&" but 0x33 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"44" report "Received 0x"&to_str(datao,'H')&" but 0x44 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"55" report "Received 0x"&to_str(datao,'H')&" but 0x55 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"66" report "Received 0x"&to_str(datao,'H')&" but 0x77 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      -- x"77" was overflow
      assert datao=x"88" report "Received 0x"&to_str(datao,'H')&" but 0x88 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"99" report "Received 0x"&to_str(datao,'H')&" but 0x99 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"AA" report "Received 0x"&to_str(datao,'H')&" but 0xAA awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"BB" report "Received 0x"&to_str(datao,'H')&" but 0xBB awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"CC" report "Received 0x"&to_str(datao,'H')&" but 0xDD awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"DD" report "Received 0x"&to_str(datao,'H')&" but 0xEE awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      -- x"CC" was overflow
      assert datao=x"FF" report "Received 0x"&to_str(datao,'H')&" but 0xFF awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"00" report "Received 0x"&to_str(datao,'H')&" but 0x00 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"11" report "Received 0x"&to_str(datao,'H')&" but 0x11 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"22" report "Received 0x"&to_str(datao,'H')&" but 0x33 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"33" report "Received 0x"&to_str(datao,'H')&" but 0x33 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"44" report "Received 0x"&to_str(datao,'H')&" but 0x44 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      -- x"55" was overflow
      assert datao=x"66" report "Received 0x"&to_str(datao,'H')&" but 0x66 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"77" report "Received 0x"&to_str(datao,'H')&" but 0x77 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"88" report "Received 0x"&to_str(datao,'H')&" but 0x88 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"99" report "Received 0x"&to_str(datao,'H')&" but 0x99 awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"AA" report "Received 0x"&to_str(datao,'H')&" but 0xAA awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"BB" report "Received 0x"&to_str(datao,'H')&" but 0xBB awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"CC" report "Received 0x"&to_str(datao,'H')&" but 0xBB awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"DD" report "Received 0x"&to_str(datao,'H')&" but 0xBB awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"EE" report "Received 0x"&to_str(datao,'H')&" but 0xBB awaited" severity failure;
      wait until rising_edge(wr_clk) and valid = '1';
      assert datao=x"FF" report "Received 0x"&to_str(datao,'H')&" but 0xBB awaited" severity failure;
      wait;
   end process read_p;

end architecture TestBench;
