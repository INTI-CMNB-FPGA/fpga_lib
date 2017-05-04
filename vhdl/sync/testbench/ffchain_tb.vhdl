--
-- Delay testbench
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.Sync.all;
use FPGALIB.Simul.all;

entity FFchain_tb is
end entity FFchain_tb;

architecture Testbench of FFchain_tb is
   constant TEST_DATA : std_logic_vector(7 downto 0) := "00000001";
   signal clk, rst : std_logic:='0';
   signal stop : boolean;
   signal di, do : std_logic_vector(7 downto 0):=(others => '0');
begin

   gen_clk : Clock
      generic map (RESET_CLKS => 5.0)
      port map(
         clk_o => clk, rst_o => rst, stop_i => stop);

   DUT: FFchain
      generic map(STAGES => 5)
      port map(clk_i => clk, rst_i => rst, ena_i => '1', d_i => di, d_o => do);

   test:
   process
   begin
      print("* Testing FF Chain with 5 stages");
      wait until rising_edge(clk) and rst='0';
      di <= TEST_DATA;
      wait until rising_edge(clk);
      di <= (others=>'0');
      assert do="00000000" report "ERROR: d_o must be '0' but is '1'" severity failure;
      wait until rising_edge(clk);
      assert do="00000000" report "ERROR: d_o must be '0' but is '1'" severity failure;
      wait until rising_edge(clk);
      assert do="00000000" report "ERROR: d_o must be '0' but is '1'" severity failure;
      wait until rising_edge(clk);
      assert do="00000000" report "ERROR: d_o must be '0' but is '1'" severity failure;
      wait until rising_edge(clk);
      assert do="00000000" report "ERROR: d_o must be '0' but is '1'" severity failure;
      wait until rising_edge(clk);
      assert do=TEST_DATA  report "ERROR: d_o must be '1' but is '0'" severity failure;
      wait until rising_edge(clk);
      assert do="00000000" report "ERROR: d_o must be '0' but is '1'" severity failure;
      wait until rising_edge(clk);
      print("* FF Chain Works fine");
      stop <= TRUE;
      wait;
   end process test;

end architecture Testbench;
