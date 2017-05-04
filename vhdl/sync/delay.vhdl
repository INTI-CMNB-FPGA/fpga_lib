--
-- Delay
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity Delay is
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
end entity Delay;

architecture RTL of Delay is
   type delay_array is array (0 to STAGES-1) of std_logic_vector(WIDTH-1 downto 0);
   signal d_r : delay_array :=(others => (others => '0'));
begin
   do_delay:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         if rst_i='1' then
            d_r <= (others => (others => '0'));
         elsif ena_i='1' then
            for i in 0 to STAGES-1 loop
               if i=0 then
                  d_r(0) <= d_i;
               else
                  d_r(i) <= d_r(i-1);
               end if;
            end loop;
         end if;
      end if;
   end process do_delay;
   d_o <= d_r(STAGES-1);
end architecture RTL;
