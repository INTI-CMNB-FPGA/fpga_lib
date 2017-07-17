--
-- FF Chain
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity FFchain is
   generic(
      WIDTH  : positive:=8;
      DEPTH  : positive:=2
   );
   port(
      clk_i  : in  std_logic;
      rst_i  : in  std_logic;
      ena_i  : in  std_logic;
      data_i : in  std_logic_vector(WIDTH-1 downto 0);
      data_o : out std_logic_vector(WIDTH-1 downto 0)
   );
end entity FFchain;

architecture RTL of FFchain is
   type ff_array is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
   signal d_r : ff_array :=(others => (others => '0'));
begin
   do_chain:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         if rst_i='1' then
            d_r <= (others => (others => '0'));
         elsif ena_i='1' then
            for i in 0 to DEPTH-1 loop
               if i=0 then
                  d_r(0) <= data_i;
               else
                  d_r(i) <= d_r(i-1);
               end if;
            end loop;
         end if;
      end if;
   end process do_chain;
   data_o <= d_r(DEPTH-1);
end architecture RTL;
