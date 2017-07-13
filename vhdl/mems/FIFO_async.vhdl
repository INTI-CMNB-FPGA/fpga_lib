--
-- Asynchronous FIFO
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

entity FIFO_async is
   generic (
      DWIDTH       : positive:=8;     -- Data width
      DEPTH        : positive:=8;     -- FIFO depth
      OUTREG       : boolean :=FALSE; -- Optional Output Register
      AFULLOFFSET  : positive:=1;     -- Almost FULL OFFSET
      AEMPTYOFFSET : positive:=1      -- Almost EMPTY OFFSET
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
end entity FIFO_async;

architecture RTL of FIFO_async is
   constant AWIDTH : positive:=clog2(DEPTH);

   signal wr_en,   rd_en   : std_logic;
   signal full,    full_r  : std_logic;
   signal empty,   empty_r : std_logic;
   signal wr_addr, rd_addr : std_logic_vector(AWIDTH-1 downto 0);
   signal valid_r          : std_logic_vector(1 downto 0);

   -- Extra bit used for empty and full generation
   signal wr_ptr, wr_ptr_r, rd_in_wr_ptr : unsigned(AWIDTH downto 0):=(others => '0');
   signal rd_ptr, rd_ptr_r, wr_in_rd_ptr : unsigned(AWIDTH downto 0):=(others => '0');
   signal wr_gray, rd_in_wr_gray         : std_logic_vector(AWIDTH downto 0):=(others => '0');
   signal rd_gray, wr_in_rd_gray         : std_logic_vector(AWIDTH downto 0):=(others => '0');
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
      wen1_i  => wr_en,
      addr1_i => wr_addr,
      addr2_i => rd_addr,
      data1_i => data_i,
      data2_o => data_o
   );

   wr_addr <= std_logic_vector(wr_ptr_r(AWIDTH-1 downto 0));
   rd_addr <= std_logic_vector(rd_ptr_r(AWIDTH-1 downto 0));

   wr_en <= '1' when wr_en_i='1' and full_r/='1'  else '0';
   rd_en <= '1' when rd_en_i='1' and empty_r/='1' else '0';

   -- Pointer from Read to Write
   rd_gray <= std_logic_vector(bin2gray(rd_ptr_r));
   sync_rd2wr_i: FFchain
   generic map(WIDTH => AWIDTH+1, STAGES => 2)
   port map(
      clk_i => wr_clk_i, rst_i => wr_rst_i, ena_i => '1',
      d_i => rd_gray, d_o => rd_in_wr_gray
   );
   rd_in_wr_ptr <= unsigned(gray2bin(rd_in_wr_gray));

   -- Pointer from Write to Read
   wr_gray <= std_logic_vector(bin2gray(wr_ptr_r));
   sync_wr2rd_i: FFchain
   generic map(WIDTH => AWIDTH+1, STAGES => 2)
   port map(
      clk_i => rd_clk_i, rst_i => rd_rst_i, ena_i => '1',
      d_i => wr_gray, d_o => wr_in_rd_gray
   );
   wr_in_rd_ptr <= unsigned(gray2bin(wr_in_rd_gray));

   ------------------------------------------------------------------------------------------------
   -- Write Side
   ------------------------------------------------------------------------------------------------

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

   wr_ptr      <= wr_ptr_r + 1 when wr_en='1' else wr_ptr_r;
   full        <= '1' when not(wr_ptr(AWIDTH))&wr_ptr(AWIDTH-1 downto 0) = rd_in_wr_ptr else '0';
   full_o      <= full;
   afull_o     <= '1' when
                      (wr_ptr>=rd_in_wr_ptr and (wr_ptr-rd_in_wr_ptr) >= (DEPTH-AFULLOFFSET)) or
                      (wr_ptr<rd_in_wr_ptr  and (rd_in_wr_ptr-wr_ptr) >= (DEPTH-AFULLOFFSET))
                      else
                  '0';
   overflow_o  <= '1' when wr_en_i='1' and full_r='1' else '0';

   ------------------------------------------------------------------------------------------------
   -- Read Side
   ------------------------------------------------------------------------------------------------

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

   rd_ptr      <= rd_ptr_r + 1 when rd_en='1' else rd_ptr_r;
   empty       <= '1' when rd_ptr=wr_in_rd_ptr else '0';
   empty_o     <= empty;
   aempty_o    <= '1' when
                      (wr_in_rd_ptr>=rd_ptr and (wr_in_rd_ptr-rd_ptr) <= AEMPTYOFFSET) or
                      (wr_in_rd_ptr<rd_ptr  and (rd_ptr-wr_in_rd_ptr) <= AEMPTYOFFSET)
                      else
                  '0';
   underflow_o <= '1' when rd_en_i='1' and empty_r='1' else '0';
   valid_o     <= valid_r(1) when OUTREG else valid_r(0);

end architecture RTL;
