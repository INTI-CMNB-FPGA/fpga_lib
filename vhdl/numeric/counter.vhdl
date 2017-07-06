--
-- Counter
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library FPGALIB;
use FPGALIB.numeric.all;

entity Counter is
   generic (
      DEPTH   : positive:=8
   );
   port (
      clk_i   : in  std_logic; -- Clock
      rst_i   : in  std_logic; -- Reset
      ena_i   : in  std_logic; -- Input Enable
      count_o : out std_logic_vector(clog2(DEPTH)-1 downto 0); -- Counter value
      last_o  : out std_logic  -- Last value
   );
end entity Counter;

architecture RTL of Counter is
   constant AWIDTH : positive:=clog2(DEPTH);
   signal count : unsigned(AWIDTH-1 downto 0):=(others => '0');
begin

   count_p:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         last_o <= '0';
         if rst_i='1' then
            count <= (others => '0');
         else
            if ena_i='1' then
               if count < DEPTH-1 then
                  count <= count + 1;
                  if count = DEPTH-2 then
                     last_o <= '1';
                  end if;
               else
                  count  <= (others => '0');
               end if;
            end if;
         end if;
      end if;
   end process count_p;

  count_o <= std_logic_vector(count);

end architecture RTL;
