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
   constant DEPTH       : positive:=3;

   signal stop          : boolean;

   signal clk,   rst    : std_logic;
   signal wr_en, rd_en  : std_logic;
   signal datai, datao  : std_logic_vector(DWIDTH-1 downto 0);
   signal full,  empty  : std_logic;
   signal afull, aempty : std_logic;
   signal over,  under  : std_logic;
   signal ack,   valid  : std_logic;

   procedure wr_check(
      num:    natural;
      full:   in std_logic; vfull:  in std_logic;
      afull:  in std_logic; vafull: in std_logic;
      over:   in std_logic; vover:  in std_logic;
      ack:    in std_logic; vack:   in std_logic
   ) is
   begin
      assert full=vfull   report "Wrong Full Flag in "     & integer'image(num) severity failure;
      assert afull=vafull report "Wrong Almost Flag in "   & integer'image(num) severity failure;
      assert over=vover   report "Wrong Overflow Flag in " & integer'image(num) severity failure;
      assert ack=vack     report "Wrong ACK in "           & integer'image(num) severity failure;
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
      ack_o        => ack,
      -- read side
      rd_en_i      => rd_en,
      data_o       => datao,
      empty_o      => empty,
      aempty_o     => aempty,
      underflow_o  => under,
      valid_o      => valid
   );

   write_p : process
   begin
      wr_en <= '0';
      datai <= (others => '0');
      print("* Start of Test");
      wait until rising_edge(clk) and rst = '0';
      print("* Writing");
      wr_check(1,full,'0',afull,'0',over,'0',ack,'0');
      wr_en <= '1';
      datai <= x"12";
      wait until rising_edge(clk);
      wr_check(2,full,'0',afull,'0',over,'0',ack,'1');
      datai <= x"34";
      wait until rising_edge(clk);
      wr_check(3,full,'0',afull,'0',over,'0',ack,'1');
      datai <= x"56";
      wait until rising_edge(clk);
      wr_check(4,full,'0',afull,'1',over,'0',ack,'1');
      wr_en <= '0';
      datai <= x"78";
      wait until rising_edge(clk);
      wr_check(5,full,'1',afull,'1',over,'0',ack,'0');
      wait until rising_edge(clk);
      wr_check(6,full,'1',afull,'1',over,'0',ack,'0');
      wr_en <= '1';
      datai <= x"9A";
      wait until rising_edge(clk);
      wr_check(7,full,'1',afull,'1',over,'1',ack,'0');
      wr_en <= '0';
      wait until rising_edge(clk);
      wr_check(7,full,'1',afull,'1',over,'0',ack,'0');
      wait;
   end process write_p;

   read_p : process
   begin
      rd_en <= '0';
      wait until rising_edge(clk) and rst = '0';
      rd_check(1,empty,'1',aempty,'1',under,'0',valid,'0');
      wait until rising_edge(clk);
      rd_check(2,empty,'1',aempty,'1',under,'0',valid,'0');
      wait until rising_edge(clk);
      rd_check(3,empty,'0',aempty,'1',under,'0',valid,'0');
      wait until rising_edge(clk);
      rd_check(4,empty,'0',aempty,'1',under,'0',valid,'0');
      wait until rising_edge(clk);
      rd_check(5,empty,'0',aempty,'0',under,'0',valid,'0');
      wait until rising_edge(clk) and over='1';
      print("* Reading");
      rd_en <= '1';
      wait until rising_edge(clk);
      rd_check(6,empty,'0',aempty,'0',under,'0',valid,'0');
      wait until rising_edge(clk);
      rd_check(7,empty,'0',aempty,'1',under,'0',valid,'1');
      assert datao=x"12" report "Wrong data 1" severity failure;
      wait until rising_edge(clk);
      rd_check(8,empty,'0',aempty,'1',under,'0',valid,'1');
      assert datao=x"34" report "Wrong data 2" severity failure;
      rd_en <= '0';
      wait until rising_edge(clk);
      rd_check(9,empty,'1',aempty,'1',under,'0',valid,'1');
      assert datao=x"56" report "Wrong data 3" severity failure;
      wait until rising_edge(clk);
      rd_check(10,empty,'1',aempty,'1',under,'0',valid,'0');
      rd_en <= '1';
      wait until rising_edge(clk);
      rd_check(11,empty,'1',aempty,'1',under,'1',valid,'0');
      rd_en <= '0';
      wait until rising_edge(clk);
      rd_check(12,empty,'1',aempty,'1',under,'0',valid,'0');
      wait until rising_edge(clk);
      print("* End of Test");
      stop <= TRUE;
      wait;
   end process read_p;

end architecture TestBench;
