--
-- Debounce
--
-- Author(s):
-- * Francisco Salomón
--
-- Copyright (c) 2012 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity Debounce is
   generic(
      FREQUENCY : positive:=50e6; -- Clock frequency [Hz]
      DEB_TIME  : real:=50.0e-3   -- Debounce time [s]
   );
   port(
      clk_i : in  std_logic;
      deb_i : in  std_logic;
      deb_o : out std_logic
   );
end entity Debounce;

architecture RTL of Debounce is
begin
   do_debounce:
   process (clk_i)
      variable cnt : natural:=0;
   begin
      if rising_edge(clk_i) then
         if deb_i='1' then
            if cnt=natural(real(FREQUENCY)*DEB_TIME) then
               deb_o <= '1';
               cnt:=0;
            else
               cnt:=cnt+1;
            end if;
         else
            deb_o <= '0';
            cnt:=0;
         end if;
      end if;
   end process do_debounce;
end architecture RTL;
