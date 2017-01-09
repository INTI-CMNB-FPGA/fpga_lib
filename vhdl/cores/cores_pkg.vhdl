--
-- Package of a collection of useful cores
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

package Cores is

   component Delay is
      generic(
         WIDTH  : positive:=8;
         STAGES : positive:=1
      );
      port(
         clk_i : in  std_logic;
         rst_i : in  std_logic;
         ena_i : in  std_logic;
         d_i   : in  std_logic_vector(WIDTH-1 downto 0);
         d_o   : out std_logic_vector(WIDTH-1 downto 0)
      );
   end component Delay;

   component Divider is
      generic(
         DIV : positive range 2 to positive'high:=2
      );
      port(
         clk_i : in  std_logic;
         rst_i : in  std_logic;
         ena_i : in  std_logic:='1';
         ena_o : out std_logic
      );
   end component Divider;

end package Cores;
