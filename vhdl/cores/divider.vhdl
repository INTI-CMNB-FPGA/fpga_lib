--
-- Divider
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity Divider is
   generic(
      DIV : positive range 2 to positive'high:=2
   );
   port(
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      ena_i : in  std_logic:='1';
      ena_o : out std_logic
   );
end entity Divider;

architecture RTL of Divider is
   signal cnt_r : integer range 0 to DIV-1;
begin
   do_div: process (clk_i)
   begin
      if rising_edge(clk_i) then
         ena_o <= '0';
         if rst_i='1' then
            cnt_r <= 0;
         elsif ena_i='1' then
            if cnt_r=DIV-1 then
               cnt_r <= 0;
               ena_o <= '1';
            else
               cnt_r <= cnt_r+1;
            end if;
         end if;
      end if;
   end process do_div;
end architecture RTL;
