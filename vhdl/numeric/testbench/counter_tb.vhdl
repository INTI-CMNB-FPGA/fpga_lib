--
-- Counter testbench
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
use FPGALIB.Numeric.all;
use FPGALIB.Simul.all;

entity Counter_tb is
end entity Counter_tb;

architecture TestBench of Counter_tb is

   constant DEPTH   : positive:=5;

   signal stop      : boolean;

   signal clk, rst  : std_logic;
   signal ena, last : std_logic;
   signal count     : std_logic_vector(clog2(DEPTH)-1 downto 0);

begin

   clock_i : Clock
      generic map(FREQUENCY => 2)
      port map(clk_o => clk, rst_o => rst, stop_i => stop);

   counter_i: counter
   generic map (
      DEPTH   => DEPTH
   )
   port map (
      clk_i   => clk,
      rst_i   => rst,
      ena_i   => ena,
      count_o => count,
      last_o  => last
   );

   test_p : process
   begin
      ena <= '0';
      print("* Start of Test (DEPTH=5)");
      wait until rising_edge(clk) and rst = '0';
      assert count="000" report "Counter value is not 0" severity failure;
      assert last='0'    report "Wrong last value indication" severity failure;
      print("Ena 1");
      ena <= '1';
      wait until rising_edge(clk);
      print("Ena 2");
      ena <= '1';
      assert count="000" report "Counter value is not 0" severity failure;
      assert last='0'    report "Wrong last value indication" severity failure;
      wait until rising_edge(clk);
      assert count="001" report "Counter value is not 1" severity failure;
      assert last='0'    report "Wrong last value indication" severity failure;
      ena <= '0';
      wait until rising_edge(clk);
      print("Ena 3");
      ena <= '1';
      wait until rising_edge(clk);
      assert count="010" report "Counter value is not 2" severity failure;
      assert last='0'    report "Wrong last value indication" severity failure;
      ena <= '0';
      wait until rising_edge(clk);
      print("Ena 4");
      ena <= '1';
      wait until rising_edge(clk);
      assert count="011" report "Counter value is not 3" severity failure;
      assert last='0'    report "Wrong last value indication" severity failure;
      print("Ena 5");
      ena <= '1';
      wait until rising_edge(clk);
      assert count="100" report "Counter value is not 4" severity failure;
      assert last='1'    report "Wrong last value indication" severity failure;
      print("Ena 6");
      ena <= '1';
      wait until rising_edge(clk);
      assert count="000" report "Counter value is not 0" severity failure;
      assert last='0'    report "Wrong last value indication" severity failure;
      ena <= '0';
      wait until rising_edge(clk);
      print("* End of Test");
      stop <= TRUE;
      wait;
   end process test_p;

end architecture TestBench;
