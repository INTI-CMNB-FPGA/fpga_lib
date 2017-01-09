--
-- Blink
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity Blink is
   generic (
      FREQUENCY : positive:=25e6;
      SECONDS   : positive:=1
   );
   port (
      clk_i   :  in std_logic;
      rst_i   :  in std_logic;
      blink_o : out std_logic
   );
end entity Blink;

architecture RTL of Blink is
   constant DIV   : positive:=FREQUENCY*SECONDS-1;
   signal   blink : std_logic;
begin
   do_blink:
   process (clk_i)
      variable cnt: natural range 0 to DIV:=0;
   begin
      if rising_edge(clk_i) then
         if rst_i='1' then
            cnt:=0;
            blink <= '0';
         else
            if cnt=DIV then
               cnt:=0;
               blink <= not(blink);
            else
               cnt:=cnt+1;
            end if;
         end if;
      end if;
   end process do_blink;
   blink_o <= blink;
end architecture RTL;
