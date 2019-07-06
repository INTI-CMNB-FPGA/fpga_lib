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

--! Description of memory blocks to be inferred

package Mems is

   --! Read-During-Write Behavior
   type syncmode_t is (READ_FIRST, WRITE_FIRST, NO_CHANGE);

   --! Returns the max memory depth based on the AWIDTH generic when the DEPTH
   --! generic is zero or the DEPTH value in other cases.
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
         wclk_i       : in  std_logic; -- Write Clock
         wrst_i       : in  std_logic; -- Write Reset
         wen_i        : in  std_logic; -- Write Enable
         data_i       : in  std_logic_vector(DWIDTH-1 downto 0); -- Data Input
         full_o       : out std_logic; -- Full Flag
         afull_o      : out std_logic; -- Almost Full Flag
         overflow_o   : out std_logic; -- Overflow Flag
         -- read side
         rclk_i       : in  std_logic; -- Read Clock
         rrst_i       : in  std_logic; -- Read Reset
         ren_i        : in  std_logic; -- Read enable
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
