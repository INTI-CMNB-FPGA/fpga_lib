--
-- Boundary Testbench
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
use FPGALIB.Simul.all;
use FPGALIB.Sync.all;

entity Boundary_Tb is
end entity Boundary_Tb;

architecture Test of Boundary_Tb is
   constant FREQUENCY : positive:=150e6;
   signal clk, rst    : std_logic;
   signal stop        : boolean;
   -- dut
   constant PATTERN   : std_logic_vector(3 downto 0):="1111";
   type comma_t is array(0 to 23) of std_logic_vector (3 downto 0);
   signal comma_in : comma_t:=(
      "0000", -- aligned
      "0000", -- aligned
      "0000", -- aligned
      "1000", -- 3
      "0111", -- 3
      "0000", -- 3
      "1100", -- 2
      "0011", -- 2
      "0000", -- 2
      "0000", -- 2
      "1110", -- 1
      "0001", -- 1
      "0000", -- 1
      "0000", -- 1
      "1111", -- aligned
      "0000", -- aligned
      "0110", -- aligned
      "1001", -- aligned
      "0100", -- aligned
      "0100", -- aligned
      others => "0000"
   );
   signal index : natural:=0;
   signal comma_aux, comma_out : std_logic_vector (3 downto 0);
   signal data_out             : std_logic_vector (31 downto 0);
begin

   do_clk: Clock
      generic map(FREQUENCY => FREQUENCY)
      port map(clk_o => clk, rst_o => rst, stop_i => stop);

   dut: Boundary
   port map(
      clk_i     => clk,
      pattern_i => PATTERN,
      comma_i   => comma_aux,
      data_i    => x"01234567",
      comma_o   => comma_out,
      data_o    => data_out
   );

   feeder: process
   begin
      wait until rising_edge(clk) and rst='0';
      for i in 0 to 20 loop
          comma_aux <= comma_in(i);
          wait until rising_edge(clk);
      end loop;
      wait;
   end process feeder;

   checker: process
   begin
      wait until rising_edge(clk) and rst='0';
      wait until rising_edge(clk) and comma_out="1111";
      assert data_out=x"23456701";
      wait until rising_edge(clk) and comma_out="1111";
      assert data_out=x"45670123";
      wait until rising_edge(clk) and comma_out="1111";
      assert data_out=x"67012345";
      wait until rising_edge(clk) and comma_out="1111";
      assert data_out=x"01234567";
      stop <= TRUE;
      wait;
   end process checker;
end architecture Test;
