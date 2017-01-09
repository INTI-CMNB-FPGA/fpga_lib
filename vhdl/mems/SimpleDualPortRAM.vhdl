--
-- Simple Dual-Port RAM
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library FPGALIB;
use FPGALIB.MEMS.all;

entity SimpleDualPortRAM is
   generic (
      AWIDTH    : positive:=8;        -- Address width
      DWIDTH    : positive:=8;        -- Data width
      DEPTH     : natural:=0;         -- Memory depth
      OUTREG    : boolean :=FALSE     -- Optional Output Register
   );
   port (
      clk1_i    : in  std_logic;
      clk2_i    : in  std_logic;
      wen1_i    : in  std_logic;
      addr1_i   : in  std_logic_vector(AWIDTH-1 downto 0);
      addr2_i   : in  std_logic_vector(AWIDTH-1 downto 0);
      data1_i   : in  std_logic_vector(DWIDTH-1 downto 0);
      data2_o   : out std_logic_vector(DWIDTH-1 downto 0)
   );
end entity SimpleDualPortRAM;

architecture RTL of SimpleDualPortRAM is
    constant SIZE : positive:=getMemorySize(DEPTH,AWIDTH);
    type ram_type is array(SIZE-1 downto 0) of std_logic_vector (DWIDTH-1 downto 0);
    signal ram    : ram_type;
    signal data2  : std_logic_vector(DWIDTH-1 downto 0);
begin
   ram1_p:
   process (clk1_i)
   begin
      if rising_edge(clk1_i) then
         if wen1_i='1' then
            ram(to_integer(unsigned(addr1_i))) <= data1_i;
         end if;
      end if;
   end process ram1_p;

   ram2_p:
   process (clk2_i)
   begin
      if rising_edge(clk2_i) then
         if OUTREG then
            data2   <= ram(to_integer(unsigned(addr2_i)));
            data2_o <= data2;
         else
            data2_o <= ram(to_integer(unsigned(addr2_i)));
         end if;
      end if;
   end process ram2_p;
end architecture RTL;
