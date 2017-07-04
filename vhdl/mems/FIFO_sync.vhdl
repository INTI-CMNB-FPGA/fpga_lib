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
use FPGALIB.numeric.all;

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
      ack_o        : out std_logic; -- Write Acknowledge
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
   signal wr_ptr, rd_ptr : unsigned(AWIDTH-1 downto 0):=(others => '0');
   signal diff           : unsigned(AWIDTH-1 downto 0);
   signal wr_en, rd_en   : std_logic;
   signal empty, full    : std_logic;
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
      addr1_i => std_logic_vector(wr_ptr),
      addr2_i => std_logic_vector(rd_ptr),
      data1_i => data_i,
      data2_o => data_o
   );

   write_p:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         if rst_i='1' then
            wr_ptr <= (others => '0');
         else
            if wr_en='1' then
               if wr_ptr < DEPTH-1 then
                  wr_ptr <= wr_ptr + 1;
               else
                  wr_ptr <= (others => '0');
               end if;
            end if;
         end if;
      end if;
   end process write_p;

   read_p:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         valid_o     <= '0';
         if rst_i='1' then
            rd_ptr <= (others => '0');
         else
            if rd_en='1' then
               if rd_ptr < DEPTH-1 then
                  rd_ptr <= rd_ptr + 1;
               else
                  rd_ptr <= (others => '0');
               end if;
               valid_o <= '1';
            end if;
         end if;
      end if;
   end process read_p;

   diff_p:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         if rst_i='1' then
            diff <= (others => '0');
         else
            if wr_en_i='1' and rd_en_i/='1' and full='0' then
               diff <= diff + 1;
            elsif wr_en_i/='1' and rd_en_i='1' and empty='0' then
               diff <= diff - 1;
            end if;
         end if;
      end if;
   end process diff_p;

   empty       <= '1' when diff=0                     else '0';
   full        <= '1' when diff=DEPTH                 else '0';
   aempty_o    <= '1' when diff<=AEMPTYOFFSET         else '0';
   afull_o     <= '1' when diff>=DEPTH-AFULLOFFSET    else '0';

   overflow_o  <= '1' when wr_en_i='1' and full='1'   else '0';
   wr_en       <= '1' when wr_en_i='1' and full/='1'  else '0';
   underflow_o <= '1' when rd_en_i='1' and empty='1'  else '0';
   rd_en       <= '1' when rd_en_i='1' and empty/='1' else '0';

   empty_o     <= empty;
   full_o      <= full;
   ack_o       <= wr_en;

end architecture RTL;
