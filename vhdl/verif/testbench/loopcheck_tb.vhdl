--
-- LoopCheck Testbench
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

entity LoopCheck_Tb is
end entity LoopCheck_Tb;

architecture Test of LoopCheck_Tb is
   constant FREQUENCY1  : positive:=10;
   constant FREQUENCY2  : positive:=9;
   signal clk1, rst1    : std_logic;
   signal clk2, rst2    : std_logic;
   signal stop          : boolean;
   -- dut
   constant DWIDTH      : positive:=8;
   signal data1i, data1o: std_logic_vector(DWIDTH-1 downto 0);
   signal data2i        : std_logic_vector(DWIDTH-1 downto 0);
   signal stb1, stb2    : std_logic;
   signal errors        : std_logic_vector(4 downto 0);
   -- mem
   constant TOVAL       : positive:=(2**DWIDTH)-1;
   type mem_type is array(0 to TOVAL) of std_logic_vector (DWIDTH-1 downto 0);
   signal ram : mem_type;
begin

   do_clk1: Clock
      generic map(FREQUENCY => FREQUENCY1)
      port map(clk_o => clk1, rst_o => rst1, stop_i => stop);

   do_clk2: Clock
      generic map(FREQUENCY => FREQUENCY2)
      port map(clk_o => clk2, rst_o => rst2, stop_i => stop);

   dut: LoopCheck
      generic map(DWIDTH => DWIDTH)
      port map(
         -- Tx side
         tx_clk_i     => clk1,
         tx_rst_i     => rst1,
         tx_stb_i     => stb1,
         tx_data_i    => data1i,
         tx_data_o    => data1o,
         -- Rx side
         rx_clk_i     => clk2,
         rx_rst_i     => rst2,
         rx_stb_i     => stb2,
         rx_data_i    => data2i,
         rx_errors_o  => errors
      );

   do_read: process
   begin
      stb1 <= '0';
      data1i <= (others => '0');
      wait until rising_edge(clk1) and rst1='0';
      for i in 0 to 255 loop
         stb1 <= '1';
         wait until rising_edge(clk1);
         ram(i) <= data1o;
         stb1 <= '0';
      end loop;
      wait;
   end process do_read;

   do_write: process
   begin
      stb2 <= '0';
      wait until rising_edge(clk2) and rst2='0';
      for i in 0 to 4 loop
          wait until rising_edge(clk2);
      end loop;
      assert errors(0)='1' report "Not consumed must be '1' but is '0'" severity failure;
      for i in 0 to 255 loop
         stb2   <= '1';
         if i=200 then
            data2i <= (others => '1');
         else
            data2i <= ram(i);
         end if;
         wait until rising_edge(clk2);
         if i <= 200 then
            assert errors(1)='0' report "Value Missmatch must be '0' but is '1'" severity failure;
         else
            assert errors(1)='1' report "Value Missmatch must be '1' but is '0'" severity failure;
         end if;
         if i>0 then
            assert errors(2)='1' report "Quantity Missmatch must be '1' but is '0'" severity failure;
            assert errors(3)='1' report "Less must be '1' but is '0'("&to_str(errors)&")";-- severity failure;
         end if;
      end loop;
      stb2 <= '0';
      wait until rising_edge(clk2);
      assert errors(0)='0' report "Not consumed must be '0' but is '1'" severity failure;
      assert errors(2)='0' report "Quantity Missmatch must be '0' but is '1'" severity failure;
      assert errors(3)='0' report "Less must be '0' but is '1'" severity failure;
      stb2 <= '1';
      wait until rising_edge(clk2);
      stb2 <= '0';
      assert errors(4)='0' report "Less must be '0' but is '1'" severity failure;
      wait until rising_edge(clk2);
      assert errors(4)='1' report "Less must be '1' but is '0'" severity failure;
      stop <= TRUE;
      wait;
   end process do_write;

end architecture Test;
