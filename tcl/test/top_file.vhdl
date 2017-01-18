--
-- Small top level for test
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
library LIB_NAME;
use LIB_NAME.PACKAGE_NAME.all;

entity TOP_NAME is
   generic (
      FREQUENCY : positive:=25e6;
      SECONDS   : positive:=1
   );
   port (
      clk_i :  in std_logic;
      rst_i :  in std_logic;
      led_o : out std_logic
   );
end entity TOP_NAME;

architecture Structural of TOP_NAME is
begin

   dut: CORE_NAME
      generic map (FREQUENCY => FREQUENCY, SECONDS => SECONDS)
      port map (clk_i => clk_i, rst_i => rst_i, led_o => led_o);

end architecture Structural;
