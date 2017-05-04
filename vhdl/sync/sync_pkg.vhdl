--
-- Sync Package
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

package Sync is

   component FFchain is
      generic(
         WIDTH  : positive:=8;
         STAGES : positive:=1
      );
      port(
         clk_i : in  std_logic;
         rst_i : in  std_logic;
         ena_i : in  std_logic;
         d_i   : in  std_logic_vector(WIDTH-1 downto 0);
         d_o   : out std_logic_vector(WIDTH-1 downto 0)
      );
   end component FFchain;

   component Divider is
      generic(
         DIV : positive range 2 to positive'high:=2
      );
      port(
         clk_i : in  std_logic;
         rst_i : in  std_logic;
         ena_i : in  std_logic:='1';
         ena_o : out std_logic
      );
   end component Divider;

   component Debounce is
      generic(
         FREQUENCY : positive:=50e6;
         DEB_TIME  : real:=50.0e-3
      );
      port(
         clk_i : in  std_logic;
         deb_i : in  std_logic;
         deb_o : out std_logic
      );
   end component Debounce;

   component SyncClockDomainsBase is
      generic(
         INBYLEVEL : boolean:=FALSE;
         FFSTAGES  : natural:= 2
      );
      port(
         rst_i  : in  std_logic;
         clka_i : in  std_logic;
         clkb_i : in  std_logic;
         a_i    : in  std_logic;
         b_o    : out std_logic;
         ack_o  : out std_logic
      );
   end component SyncClockDomainsBase;

   component SyncClockDomains is
      generic(
         INBYLEVEL : boolean:=FALSE;
         FFSTAGES  : natural:= 2;
         CHANNELS  : positive:= 1
      );
      port(
         rst_i  : in  std_logic;
         clkA_i : in  std_logic;
         clkB_i : in  std_logic;
         a_i    : in  std_logic_vector(CHANNELS-1 downto 0);
         b_o    : out std_logic_vector(CHANNELS-1 downto 0);
         ack_o  : out std_logic_vector(CHANNELS-1 downto 0));
   end component SyncClockDomains;

   component Boundary is
      generic(
         BYTES : positive:=4
      );
      port(
         clk_i     : in  std_logic;
         pattern_i : in  std_logic_vector(BYTES-1 downto 0);
         comma_i   : in  std_logic_vector(BYTES-1 downto 0);
         data_i    : in  std_logic_vector(BYTES*8-1 downto 0);
         comma_o   : out std_logic_vector(BYTES-1 downto 0);
         data_o    : out std_logic_vector(BYTES*8-1 downto 0)
      );
   end component Boundary;

end package Sync;
