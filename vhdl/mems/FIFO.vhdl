--
-- FIFO
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
use FPGALIB.MEMS.all;
use FPGALIB.Numeric.all;

entity FIFO is
   generic (
      DWIDTH       : positive:=8;     -- Data width
      DEPTH        : positive:=8;     -- FIFO depth
      OUTREG       : boolean :=FALSE; -- Optional Output Register
      AFULLOFFSET  : positive:=1;     -- Almost FULL OFFSET
      AEMPTYOFFSET : positive:=1      -- Almost EMPTY OFFSET
   );
   port (
      -- write side
      wr_clk_i     : in  std_logic;
      wr_rst_i     : in  std_logic;
      wr_en_i      : in  std_logic;
      data_i       : in  std_logic_vector(DWIDTH-1 downto 0);
      full_o       : out std_logic;
      afull_o      : out std_logic;
      overflow_o   : out std_logic;
      -- read side
      rd_clk_i     : in  std_logic;
      rd_rst_i     : in  std_logic;
      rd_en_i      : in  std_logic;
      data_o       : out std_logic_vector(DWIDTH-1 downto 0);
      empty_o      : out std_logic;
      aempty_o     : out std_logic;
      underflow_o  : out std_logic
   );
end entity FIFO;

architecture RTL of FIFO is
   constant AWIDTH : positive:=clog2(DEPTH);
   signal wr_ptr, rd_ptr : unsigned(AWIDTH-1 downto 0);
begin

   memory_i: SimpleDualPortRAM
   generic map (
      AWIDTH  => AWIDTH,
      DWIDTH  => DWIDTH,
      DEPTH   => DEPTH,
      OUTREG  => OUTREG
   )
   port map (
      clk1_i  => wr_clk_i,
      clk2_i  => rd_clk_i,
      wen1_i  => wr_en_i,
      addr1_i => std_logic_vector(wr_ptr),
      addr2_i => std_logic_vector(rd_ptr),
      data1_i => data_i,
      data2_o => data_o
   );

   write_p:
   process (wr_clk_i)
   begin
      if rising_edge(wr_clk_i) then
         if wr_rst_i='1' then
            wr_ptr <= (others => '0');
         else
            -- Pointer
            if wr_en_i='1' then
               if wr_ptr < DEPTH then
                  wr_ptr <= wr_ptr + 1;
               else
                  wr_ptr <= (others => '0');
               end if;
            end if;
            -- Status
         end if;
      end if;
   end process write_p;

   read_p:
   process (rd_clk_i)
   begin
      if rising_edge(rd_clk_i) then
         if rd_rst_i='1' then
            rd_ptr <= (others => '0');
         else
            -- Pointer
            if rd_en_i='1' then
               if rd_ptr < DEPTH then
                  rd_ptr <= rd_ptr + 1;
               else
                  rd_ptr <= (others => '0');
               end if;
            end if;
            -- Status
         end if;
      end if;
   end process read_p;

end architecture RTL;
