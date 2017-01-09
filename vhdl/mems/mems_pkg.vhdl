--
-- Mems Package
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (C) 2016 Authors and INTI
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
