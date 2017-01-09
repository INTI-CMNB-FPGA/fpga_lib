--
-- Verif Package
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

package Verif is

   component Blink is
      generic (
         FREQUENCY : positive:=25e6;
         SECONDS   : positive:=1
      );
      port (
         clk_i   :  in std_logic;
         rst_i   :  in std_logic;
         blink_o : out std_logic
      );
   end component Blink;

   component LoopCheck is
      generic (
         DWIDTH : positive:=8
      );
      port (
         -- Producer side
         tx_clk_i     : in  std_logic;
         tx_rst_i     : in  std_logic;
         tx_stb_i     : in  std_logic;
         tx_data_i    : in  std_logic_vector(DWIDTH-1 downto 0);
         tx_data_o    : out std_logic_vector(DWIDTH-1 downto 0);
         -- Consumer side
         rx_clk_i     : in  std_logic;
         rx_rst_i     : in  std_logic;
         rx_stb_i     : in  std_logic;
         rx_data_i    : in  std_logic_vector(DWIDTH-1 downto 0);
         rx_errors_o  : out std_logic_vector(4 downto 0)
      );
   end component LoopCheck;

   component TransLoop is
      generic (
         DBYTES : positive:=4;   -- Data bytes
         TSIZE  : positive:=1e4; -- Total size
         FSIZE  : positive:=2048 -- Frame size
      );
      port (
         -- TX side
         tx_clk_i     : in  std_logic;
         tx_rst_i     : in  std_logic;
         tx_data_i    : in  std_logic_vector(DBYTES*8-1 downto 0);
         tx_data_o    : out std_logic_vector(DBYTES*8-1 downto 0);
         tx_isk_o     : out std_logic_vector(DBYTES-1 downto 0);
         tx_ready_i   : in  std_logic;
         -- RX side
         rx_clk_i     : in  std_logic;
         rx_rst_i     : in  std_logic;
         rx_data_i    : in  std_logic_vector(DBYTES*8-1 downto 0);
         rx_isk_i     : in  std_logic_vector(DBYTES-1 downto 0);
         rx_errors_o  : out std_logic_vector(4 downto 0);
         rx_finish_o  : out std_logic;
         rx_cycles_o  : out std_logic_vector(31 downto 0)
      );
   end component TransLoop;

end package Verif;
