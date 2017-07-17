--
-- FIFO
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--
-- Description:
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library FPGALIB;
use FPGALIB.MEMS.all;
use FPGALIB.Numeric.all;
use FPGALIB.Sync.all;

entity FIFO is
   generic (
      DWIDTH       : positive:=8;     -- Data width
      DEPTH        : positive:=8;     -- FIFO depth (even)
      OUTREG       : boolean :=FALSE; -- Optional Output Register
      AFULLOFFSET  : positive:=1;     -- Almost FULL OFFSET
      AEMPTYOFFSET : positive:=1;     -- Almost EMPTY OFFSET
      ASYNC        : boolean :=TRUE   -- Asynchronous FIFO
   );
   port (
      -- write side
      wr_clk_i     : in  std_logic; -- Write Clock
      wr_rst_i     : in  std_logic; -- Write Reset
      wr_en_i      : in  std_logic; -- Write Enable
      data_i       : in  std_logic_vector(DWIDTH-1 downto 0); -- Data Input
      full_o       : out std_logic; -- Full Flag
      afull_o      : out std_logic; -- Almost Full Flag
      overflow_o   : out std_logic; -- Overflow Flag
      -- read side
      rd_clk_i     : in  std_logic; -- Read Clock
      rd_rst_i     : in  std_logic; -- Read Reset
      rd_en_i      : in  std_logic; -- Read enable
      data_o       : out std_logic_vector(DWIDTH-1 downto 0); -- Data Output
      empty_o      : out std_logic; -- Empty flag
      aempty_o     : out std_logic; -- Almost Empty flag
      underflow_o  : out std_logic; -- Underflow Flag
      valid_o      : out std_logic  -- Read Valid
   );
end entity FIFO;

architecture RTL of FIFO is

   ------------------------------------------------------------------------------------------------
   -- Constants
   ------------------------------------------------------------------------------------------------

   constant EVEN_DEPTH : positive := DEPTH + (DEPTH rem 2); -- To ensure only even values
   constant AWIDTH     : positive := clog2(EVEN_DEPTH);     -- Address width in bits
   constant DIFF_DEPTH : natural  := 2**AWIDTH-EVEN_DEPTH;

   ------------------------------------------------------------------------------------------------
   -- Signals
   ------------------------------------------------------------------------------------------------

   signal wr_en,   rd_en   : std_logic;
   signal full,    full_r  : std_logic;
   signal empty,   empty_r : std_logic;
   signal wr_addr, rd_addr : std_logic_vector(AWIDTH-1 downto 0);
   signal          valid_r : std_logic_vector(1 downto 0);

   -- Extra bit used for empty and full generation
   signal wr_ptr, wr_ptr_r, rd_in_wr_ptr : unsigned(AWIDTH downto 0):=(others => '0');
   signal rd_ptr, rd_ptr_r, wr_in_rd_ptr : unsigned(AWIDTH downto 0):=(others => '0');

   ------------------------------------------------------------------------------------------------
   -- Functions
   ------------------------------------------------------------------------------------------------

   function next_ptr(ena : std_logic; ptr: unsigned) return unsigned is
      variable ret : unsigned(ptr'range);
   begin
      if ena='1' and ptr(AWIDTH-1 downto 0)=EVEN_DEPTH-1 then
         ret := (not(ptr(AWIDTH)), others => '0');
      elsif ena='1' then
         ret := ptr + 1;
      else
         ret := ptr;
      end if;
      return ret;
   end next_ptr;

   function diff_ptr(wr_ptr, rd_ptr : unsigned) return unsigned is
      variable status : std_logic_vector(1 downto 0);
      variable wr_aux, rd_aux : unsigned(wr_ptr'range);
   begin
      status := wr_ptr(AWIDTH)&rd_ptr(AWIDTH);
      case status is
         when "00" | "11" =>
            return wr_ptr - rd_ptr;
         when "10" =>
            return wr_ptr - DIFF_DEPTH - rd_ptr;
         when "01" =>
            wr_aux := not(wr_ptr(AWIDTH))&wr_ptr(AWIDTH-1 downto 0);
            rd_aux := not(rd_ptr(AWIDTH))&rd_ptr(AWIDTH-1 downto 0);
            return wr_aux - DIFF_DEPTH - rd_aux;
         when others =>
            wr_aux := (others => '0');
      end case;
      return wr_aux;
   end diff_ptr;

begin

   memory_i: SimpleDualPortRAM
   generic map (
      AWIDTH  => AWIDTH,
      DWIDTH  => DWIDTH,
      DEPTH   => EVEN_DEPTH,
      OUTREG  => OUTREG
   )
   port map (
      clk1_i  => wr_clk_i, 
      clk2_i  => rd_clk_i,
      wen1_i  => wr_en,
      addr1_i => wr_addr,
      addr2_i => rd_addr,
      data1_i => data_i,
      data2_o => data_o
   );

   sync_g: if not(ASYNC) generate
      rd_in_wr_ptr <= rd_ptr_r;
      wr_in_rd_ptr <= wr_ptr_r;
   end generate sync_g;

   async_g: if ASYNC generate
      -- Pointer from Read to Write
      sync_rd2wr_i: gray_sync
      generic map(WIDTH => AWIDTH+1, DEPTH => 2)
      port map(clk_i => wr_clk_i, rst_i => wr_rst_i, data_i => rd_ptr_r, data_o => rd_in_wr_ptr);
      -- Pointer from Write to Read
      sync_wr2rd_i: gray_sync
      generic map(WIDTH => AWIDTH+1, DEPTH => 2)
      port map(clk_i => wr_clk_i, rst_i => wr_rst_i, data_i => wr_ptr_r, data_o => wr_in_rd_ptr);
   end generate async_g;

   ------------------------------------------------------------------------------------------------
   -- Write Side
   ------------------------------------------------------------------------------------------------

   wr_addr <= std_logic_vector(wr_ptr_r(AWIDTH-1 downto 0));
   wr_en   <= '1' when wr_en_i='1' and full_r/='1'  else '0';

   write_p:
   process(wr_clk_i)
   begin
      if rising_edge(wr_clk_i) then
         full_r <= '0';
         if wr_rst_i='1' then
            wr_ptr_r <= (others => '0');
         else
            wr_ptr_r <= wr_ptr;
            full_r   <= full;
         end if;
      end if;
   end process write_p;

   wr_ptr      <= next_ptr(wr_en, wr_ptr_r);
   full        <= '1' when diff_ptr(wr_ptr, rd_in_wr_ptr) = EVEN_DEPTH else '0';
   full_o      <= full;
   afull_o     <= '1' when diff_ptr(wr_ptr, rd_in_wr_ptr) >= EVEN_DEPTH-AFULLOFFSET else '0';
   overflow_o  <= '1' when wr_en_i='1' and full_r='1' else '0';

   ------------------------------------------------------------------------------------------------
   -- Read Side
   ------------------------------------------------------------------------------------------------

   rd_addr <= std_logic_vector(rd_ptr_r(AWIDTH-1 downto 0));
   rd_en   <= '1' when rd_en_i='1' and empty_r/='1' else '0';

   read_p:
   process(rd_clk_i)
   begin
      if rising_edge(rd_clk_i) then
         empty_r    <= '1';
         valid_r(0) <= rd_en;
         valid_r(1) <= valid_r(0);
         if rd_rst_i='1' then
            rd_ptr_r <= (others => '0');
            valid_r  <= (others => '0');
         else
            rd_ptr_r <= rd_ptr;
            empty_r  <= empty;
         end if;
      end if;
   end process read_p;

   rd_ptr      <= next_ptr(rd_en, rd_ptr_r);
   empty       <= '1' when diff_ptr(wr_in_rd_ptr, rd_ptr) = 0 else '0';
   empty_o     <= empty;
   aempty_o    <= '1' when diff_ptr(wr_in_rd_ptr, rd_ptr) <= AEMPTYOFFSET else '0';
   underflow_o <= '1' when rd_en_i='1' and empty_r='1' else '0';
   valid_o     <= valid_r(1) when OUTREG else valid_r(0);

end architecture RTL;
