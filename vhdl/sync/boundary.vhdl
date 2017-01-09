--
-- Boundary
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity Boundary is
   generic(
      BYTES : positive:=4
   );
   port(
      clk_i     : in  std_logic;
      pattern_i : in  std_logic_vector(BYTES-1 downto 0);
      comma_i   : in  std_logic_vector(BYTES-1 downto 0);
      data_i    : in  std_logic_vector(BYTES*8-1 downto 0);
      comma_o   : out std_logic_vector(BYTES-1 downto 0);
      data_o    : out std_logic_vector(BYTES*8-1 downto 0)
   );
end entity Boundary;

architecture RTL of Boundary is
   constant BYTES2 : positive:=BYTES*2;
   constant BYTES3 : positive:=BYTES*3;
   constant WIDTH  : positive:=BYTES*8;
   constant WIDTH2 : positive:=WIDTH*2;
   constant WIDTH3 : positive:=WIDTH*3;

   signal comma_r1, comma_r2 : std_logic_vector(BYTES-1  downto 0);
   signal comma              : std_logic_vector(BYTES3-1 downto 0);
   signal data_r1,  data_r2  : std_logic_vector(WIDTH-1  downto 0);
   signal data               : std_logic_vector(WIDTH3-1 downto 0);
   signal index              : natural range 0 to BYTES-1:=0;
begin

   do_reg: process (clk_i)
   begin
      if rising_edge(clk_i) then
         comma_r1 <= comma_i;
         comma_r2 <= comma_r1;
         data_r1  <= data_i;
         data_r2  <= data_r1;
      end if;
   end process;

   comma <= comma_i & comma_r1 & comma_r2;
   data  <= data_i  & data_r1  & data_r2;

   do_boundary: process (clk_i)
   begin
      if rising_edge(clk_i) then
         for i in 0 to BYTES-1 loop
             if comma(BYTES2+i-1 downto BYTES+i)=pattern_i then
                index <= i;
             end if;
         end loop;
      end if;
   end process;

   comma_o <= comma(BYTES+index-1 downto index);
   data_o  <= data(WIDTH+index*8-1 downto index*8);

end architecture RTL;
