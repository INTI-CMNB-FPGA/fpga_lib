--
-- Single Port RAM
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

entity SinglePortRAM is
   generic (
      AWIDTH    : positive:=8;             -- Address width
      DWIDTH    : positive:=8;             -- Data width
      DEPTH     : natural:=0;              -- Memory depth
      SYNCMODE  : syncmode_t:=WRITE_FIRST; -- Synchronization Mode
      OUTREG    : boolean :=FALSE          -- Optional Output Register
   );
   port (
      clk_i     : in  std_logic;
      wen_i     : in  std_logic;
      addr_i    : in  std_logic_vector(AWIDTH-1 downto 0);
      data_i    : in  std_logic_vector(DWIDTH-1 downto 0);
      data_o    : out std_logic_vector(DWIDTH-1 downto 0)
   );
end entity SinglePortRAM;

architecture RTL of SinglePortRAM is
    constant SIZE : positive:=getMemorySize(DEPTH,AWIDTH);
    type ram_type is array(SIZE-1 downto 0) of std_logic_vector (DWIDTH-1 downto 0);
    signal ram    : ram_type;
    signal data   : std_logic_vector(DWIDTH-1 downto 0);
begin
   ram_p:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         case SYNCMODE is
              when READ_FIRST =>
                   if OUTREG then
                      data   <= ram(to_integer(unsigned(addr_i)));
                      data_o <= data;
                   else
                      data_o <= ram(to_integer(unsigned(addr_i)));
                   end if;
                   if wen_i='1' then
                      ram(to_integer(unsigned(addr_i))) <= data_i;
                   end if;
              when WRITE_FIRST =>
                   if wen_i='1' then
                      ram(to_integer(unsigned(addr_i))) <= data_i;
                      if OUTREG then
                         data   <= data_i;
                         data_o <= data;
                      else
                         data_o <= data_i;
                      end if;
                   else
                      if OUTREG then
                         data   <= ram(to_integer(unsigned(addr_i)));
                         data_o <= data;
                      else
                         data_o <= ram(to_integer(unsigned(addr_i)));
                      end if;
                   end if;
              when NO_CHANGE =>
                   if wen_i='1' then
                      ram(to_integer(unsigned(addr_i))) <= data_i;
                   else
                      if OUTREG then
                         data   <= ram(to_integer(unsigned(addr_i)));
                         data_o <= data;
                      else
                         data_o <= ram(to_integer(unsigned(addr_i)));
                      end if;
                   end if;
         end case;
      end if;
   end process ram_p;
end architecture RTL;
