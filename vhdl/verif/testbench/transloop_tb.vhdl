--
-- Transceiver Loop Testbench
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.Verif.all;
use FPGALIB.Simul.all;

entity TransLoop_Tb is
end entity TransLoop_Tb;

architecture Test of TransLoop_Tb is
   constant FREQUENCY         : positive:=150e6;
   signal clk, rst            : std_logic;
   signal stop                : boolean;
   -- dut
   signal ready               : std_logic;
   signal data                : std_logic_vector(31 downto 0);
   signal isk                 : std_logic_vector(3 downto 0);
   signal errors              : std_logic_vector(4 downto 0);
   signal finish              : std_logic;
begin

   do_clk: Clock
      generic map(FREQUENCY => FREQUENCY)
      port map(clk_o => clk, rst_o => rst, stop_i => stop);

   dut: TransLoop
      port map(
         -- TX side
         tx_clk_i     => clk,
         tx_rst_i     => rst,
         tx_data_i    => (others => '0'),
         tx_data_o    => data,
         tx_isk_o     => isk,
         tx_ready_i   => ready,
         -- RX side
         rx_clk_i     => clk,
         rx_rst_i     => rst,
         rx_data_i    => data,
         rx_isk_i     => isk,
         rx_errors_o  => errors,
         rx_finish_o  => finish,
         rx_cycles_o  => open
      );

   do_run: process
   begin
      ready <= '0';
      wait until rising_edge(clk) and rst='0';
      ready <= '1';
      wait until rising_edge(clk);
      ready <= '0';
      wait until rising_edge(clk) and finish='1';
      assert errors="00000"
         report "ERROR: there were errors ("&to_str(errors)&")." severity failure;
      stop <= TRUE;
      wait;
   end process do_run;

end architecture Test;
