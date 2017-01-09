--
-- Mems testbench
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
use FPGALIB.MEMs.all;
use FPGALIB.Simul.all;

entity Mems_tb is
end entity Mems_tb;

architecture TestBench of Mems_tb is

   constant AWIDTH: positive:=3;
   constant DWIDTH: positive:=8;
   constant DEPTH : natural:=5;

   signal rst  : std_logic;
   signal stop : boolean;

   signal clk1, clk2     : std_logic;
   signal wen1, wen2     : std_logic;
   signal addr1, addr2   : std_logic_vector(AWIDTH-1 downto 0):=(others => '0');
   signal data1, data2   : std_logic_vector(DWIDTH-1 downto 0);
   signal s_out, d_out   : std_logic_vector(DWIDTH-1 downto 0);
   signal t_out1, t_out2 : std_logic_vector(DWIDTH-1 downto 0);

begin

   clock1 : Clock
      generic map(FREQUENCY => 2)
      port map(clk_o => clk1, rst_o => rst, stop_i => stop);

   clock2 : Clock
      generic map(FREQUENCY => 3)
      port map(clk_o => clk2, rst_o => open, stop_i => stop);

   SingleRAM: SinglePortRAM
      generic map(AWIDTH => AWIDTH, DWIDTH => DWIDTH, DEPTH => DEPTH)
      port map(
         clk_i => clk1, wen_i  => wen1, addr_i => addr1, data_i => data1, data_o => s_out);

   DualRAM: SimpleDualPortRAM
      generic map(AWIDTH => AWIDTH, DWIDTH => DWIDTH, DEPTH => DEPTH)
      port map(clk1_i => clk1, clk2_i => clk2, wen1_i => wen1,
               addr1_i => addr1, addr2_i => addr2, data1_i => data1, data2_o => d_out);

   TrueDualRAM: TrueDualPortRAM
      generic map(AWIDTH => AWIDTH, DWIDTH => DWIDTH, DEPTH => DEPTH)
      port map(clk1_i => clk1, clk2_i => clk2, wen1_i => wen1, wen2_i => wen2,
               addr1_i => addr1, addr2_i => addr2,
               data1_i => data1, data2_i => data2, data1_o => t_out1, data2_o  => t_out2);

   side1: process
   begin
      print("* Start of Test");
      wait until rising_edge(clk1) and rst = '0';
      print("* Writing Side 1");
      wen1  <= '1';
      addr1 <= "000";
      data1 <= x"CA";
      wait until rising_edge(clk1);
      addr1 <= "001";
      data1 <= x"FE";
      wait until rising_edge(clk1);
      wen1  <= '0';
      print("* Reading Side 1");
      addr1 <= "000";
      wait until rising_edge(clk1);
      addr1 <= "001";
      wait until rising_edge(clk1);
      assert s_out=x"CA" report "ERROR in SinglePortRAM" severity failure;
      assert t_out1=x"CA" report "ERROR in TrueDualPortRAM" severity failure;
      wait until rising_edge(clk1);
      assert s_out=x"FE" report "ERROR in SinglePortRAM" severity failure;
      assert t_out1=x"FE" report "ERROR in TrueDualPortRAM" severity failure;
      wait until rising_edge(clk1);
      print("* Side 1 is OK in SinglePortRAM and TrueDualPortRAM");
      wait;
   end process side1;

   side2: process
   begin
      wait until rising_edge(clk2) and rst = '0';
      wait until rising_edge(clk2);
      wait until rising_edge(clk2);
      wait until rising_edge(clk2);
      wait until rising_edge(clk2);
      wait until rising_edge(clk2);
      wait until rising_edge(clk2);
      print("* Reading Side 2");
      addr2 <= "000";
      wait until rising_edge(clk2);
      addr2 <= "001";
      wait until rising_edge(clk2);
      assert d_out=x"CA" report "ERROR in DualPortRAM" severity failure;
      wait until rising_edge(clk2);
      assert d_out=x"FE" report "ERROR in DualPortRAM" severity failure;
      wait until rising_edge(clk2);
      print("* Writing Side 2");
      wen2  <= '1';
      addr2 <= "000";
      data2 <= x"B0";
      wait until rising_edge(clk2);
      addr2 <= "001";
      data2 <= x"CA";
      wait until rising_edge(clk2);
      wen2  <= '0';
      print("* Reading Side 2");
      addr2 <= "000";
      wait until rising_edge(clk2);
      addr2 <= "001";
      wait until rising_edge(clk2);
      assert t_out2=x"B0" report "ERROR in TrueDualPortRAM" severity failure;
      wait until rising_edge(clk1);
      assert t_out2=x"CA" report "ERROR in TrueDualPortRAM" severity failure;
      wait until rising_edge(clk1);
      print("* Side 2 is OK in DualPortRAM and TrueDualPortRAM");
      print("* End of Test");
      stop <= TRUE;
      wait;
   end process side2;

end architecture TestBench;
