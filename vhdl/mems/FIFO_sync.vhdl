--
-- Synchronous FIFO
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

entity FIFO_sync is
   generic (
      DWIDTH       : positive:=8;     -- Data width
      DEPTH        : positive:=8;     -- FIFO depth
      OUTREG       : boolean :=FALSE; -- Optional Output Register
      AFULLOFFSET  : positive:=1;     -- Almost FULL OFFSET
      AEMPTYOFFSET : positive:=1      -- Almost EMPTY OFFSET
   );
   port (
      clk_i        : in  std_logic; -- Clock
      rst_i        : in  std_logic; -- Reset
      -- write side
      wr_en_i      : in  std_logic; -- Write Enable
      data_i       : in  std_logic_vector(DWIDTH-1 downto 0); -- Data Input
      full_o       : out std_logic; -- Full Flag
      afull_o      : out std_logic; -- Almost Full Flag
      overflow_o   : out std_logic; -- Overflow Flag
      -- read side
      rd_en_i      : in  std_logic; -- Read enable
      data_o       : out std_logic_vector(DWIDTH-1 downto 0); -- Data Output
      empty_o      : out std_logic; -- Empty flag
      aempty_o     : out std_logic; -- Almost Empty flag
      underflow_o  : out std_logic; -- Underflow Flag
      valid_o      : out std_logic  -- Read Valid
   );
end entity FIFO_sync;

architecture RTL of FIFO_sync is
   constant AWIDTH : positive:=clog2(DEPTH);
   signal wr_ptr,  rd_ptr   : std_logic_vector(AWIDTH-1 downto 0):=(others => '0');
   signal diff_r            : unsigned(AWIDTH-1 downto 0);
   signal wr_en,   rd_en    : std_logic;
   signal empty_r1, full_r1 : std_logic;
   signal empty_r2, full_r2 : std_logic;
   signal valid_r           : std_logic_vector(1 downto 0);
begin

   memory_i: SimpleDualPortRAM
   generic map (
      AWIDTH  => AWIDTH,
      DWIDTH  => DWIDTH,
      DEPTH   => DEPTH,
      OUTREG  => OUTREG
   )
   port map (
      clk1_i  => clk_i,
      clk2_i  => clk_i,
      wen1_i  => wr_en,
      addr1_i => wr_ptr,
      addr2_i => rd_ptr,
      data1_i => data_i,
      data2_o => data_o
   );

   wr_ptr_i: counter
   generic map (DEPTH => DEPTH)
   port map (clk_i => clk_i, rst_i => rst_i, ena_i => wr_en, count_o => wr_ptr, last_o => open);

   rd_ptr_i: counter
   generic map (DEPTH => DEPTH)
   port map (clk_i => clk_i, rst_i => rst_i, ena_i => rd_en, count_o => rd_ptr, last_o => open);

   diff_p:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         empty_r2   <= empty_r1;
         full_r2    <= full_r1;
         valid_r(0) <= rd_en;
         valid_r(1) <= valid_r(0);
         if rst_i='1' then
            diff_r   <= (others => '0');
            valid_r  <= (others => '0');
            empty_r1 <= '1';
            full_r1  <= '0';
            afull_o  <= '0';
            aempty_o <= '1';
         else
            if wr_en_i='1' and rd_en_i/='1' and full_r2/='1' then
               diff_r <= diff_r + 1;
               empty_r1 <= '0';
               if diff_r+1=DEPTH-1 then
                  full_r1 <= '1';
               end if;
               if diff_r+1=DEPTH-1-AFULLOFFSET then
                  afull_o <= '1';
               end if;
               if diff_r+1=1+AEMPTYOFFSET then
                  aempty_o <= '0';
               end if;
            elsif wr_en_i/='1' and rd_en_i='1' and empty_r2/='1' then
               diff_r <= diff_r - 1;
               full_r1 <= '0';
               if diff_r-1=1 then
                  empty_r1 <= '1';
               end if;
               if diff_r-1=DEPTH-1-AFULLOFFSET then
                  afull_o <= '0';
               end if;
               if diff_r-1=1+AEMPTYOFFSET then
                  aempty_o <= '1';
               end if;
            end if;
         end if;
      end if;
   end process diff_p;

   wr_en       <= '1' when wr_en_i='1' and full_r2/='1'  else '0';
   rd_en       <= '1' when rd_en_i='1' and empty_r2/='1' else '0';
   overflow_o  <= '1' when wr_en_i='1' and full_r2='1'   else '0';
   underflow_o <= '1' when rd_en_i='1' and empty_r2='1'  else '0';
   empty_o     <= empty_r1;
   full_o      <= full_r1;
   valid_o     <= valid_r(1) when OUTREG else valid_r(0);

end architecture RTL;
