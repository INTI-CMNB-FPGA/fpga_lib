--
-- Mems Package
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (C) 2016-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Mems is

   type syncmode_t is (READ_FIRST, WRITE_FIRST, NO_CHANGE);

   function getMemorySize(depth: natural; awidth: positive) return positive;

   component SinglePortRAM is
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
   end component SinglePortRAM;

   component SimpleDualPortRAM is
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
   end component SimpleDualPortRAM;

   component TrueDualPortRAM is
      generic (
         AWIDTH    : positive:=8;             -- Address width
         DWIDTH    : positive:=8;             -- Data width
         DEPTH     : natural:=0;              -- Memory depth
         SYNCMODE  : syncmode_t:=WRITE_FIRST; -- Synchronization Mode
         OUTREG    : boolean :=FALSE          -- Optional Output Register
      );
      port (
         clk1_i    : in  std_logic;
         clk2_i    : in  std_logic;
         wen1_i    : in  std_logic;
         wen2_i    : in  std_logic;
         addr1_i   : in  std_logic_vector(AWIDTH-1 downto 0);
         addr2_i   : in  std_logic_vector(AWIDTH-1 downto 0);
         data1_i   : in  std_logic_vector(DWIDTH-1 downto 0);
         data2_i   : in  std_logic_vector(DWIDTH-1 downto 0);
         data1_o   : out std_logic_vector(DWIDTH-1 downto 0);
         data2_o   : out std_logic_vector(DWIDTH-1 downto 0)
      );
   end component TrueDualPortRAM;

   component FIFO_sync is
      generic (
         DWIDTH       : positive:=8;     -- Data width
         DEPTH        : positive:=8;     -- FIFO depth
         OUTREG       : boolean :=FALSE; -- Optional Output Register
         AFULLOFFSET  : positive:=1;     -- Almost FULL OFFSET
         AEMPTYOFFSET : positive:=1      -- Almost EMPTY OFFSET
      );
      port (
         clk_i        : in  std_logic;
         rst_i        : in  std_logic;
         -- write side
         wr_en_i      : in  std_logic;
         data_i       : in  std_logic_vector(DWIDTH-1 downto 0);
         full_o       : out std_logic;
         afull_o      : out std_logic;
         overflow_o   : out std_logic;
         -- read side
         rd_en_i      : in  std_logic;
         data_o       : out std_logic_vector(DWIDTH-1 downto 0);
         empty_o      : out std_logic;
         aempty_o     : out std_logic;
         underflow_o  : out std_logic;
         valid_o      : out std_logic
      );
   end component FIFO_sync;

   component FIFO_async is
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
   end component FIFO_async;

   component FIFO is
      generic (
         DWIDTH       : positive:=8;     -- Data width
         DEPTH        : positive:=8;     -- FIFO depth
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
   end component FIFO;

end package Mems;

package body Mems is

   function getMemorySize(depth: natural; awidth: positive) return positive is
   begin
      if depth=0 then
         return 2**awidth;
      else
         return depth;
      end if;
   end function getMemorySize;

end package body Mems;
