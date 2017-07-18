--
-- Mems top level
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.MEMS.all;

entity Top is
   port (
      clk1_i    : in  std_logic;
      clk2_i    : in  std_logic;
      wen1_i    : in  std_logic;
      wen2_i    : in  std_logic;
      addr1_i   : in  std_logic_vector(7 downto 0);
      addr2_i   : in  std_logic_vector(7 downto 0);
      data1_i   : in  std_logic_vector(7 downto 0);
      data2_i   : in  std_logic_vector(7 downto 0);
      data1_o   : out std_logic_vector(7 downto 0);
      data2_o   : out std_logic_vector(7 downto 0);
      --
      sel_i     : in  std_logic_vector(2 downto 0)
   );
end entity Top;

architecture Structural of Top is
   signal sp_nc_data1,  sp_wf_data1,  sp_rf_data1  : std_logic_vector(7 downto 0);
   signal sdp_latch_data2, sdp_reg_data2           : std_logic_vector(7 downto 0);
   signal tdp_nc_data1, tdp_wf_data1, tdp_rf_data1 : std_logic_vector(7 downto 0);
   signal tdp_nc_data2, tdp_wf_data2, tdp_rf_data2 : std_logic_vector(7 downto 0);

   constant isQuartus : std_logic := '1'
   -- altera translate_off
   and '0'
   -- altera translate_on
   ;

begin

   sp_nc_i : SinglePortRAM
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE, SYNCMODE => NO_CHANGE)
   port map (
      clk_i     => clk1_i,
      wen_i     => wen1_i,
      addr_i    => addr1_i,
      data_i    => data1_i,
      data_o    => sp_nc_data1
   );

   sp_wf_i : SinglePortRAM
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE, SYNCMODE => WRITE_FIRST)
   port map (
      clk_i     => clk1_i,
      wen_i     => wen1_i,
      addr_i    => addr1_i,
      data_i    => data1_i,
      data_o    => sp_wf_data1
   );

   sp_rf_i : SinglePortRAM
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE, SYNCMODE => READ_FIRST)
   port map (
      clk_i     => clk1_i,
      wen_i     => wen1_i,
      addr_i    => addr1_i,
      data_i    => data1_i,
      data_o    => sp_rf_data1
   );

   sdp_latch_i: SimpleDualPortRAM
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE)
   port map (
      clk1_i    => clk1_i,
      clk2_i    => clk2_i,
      wen1_i    => wen1_i,
      addr1_i   => addr1_i,
      addr2_i   => addr2_i,
      data1_i   => data1_i,
      data2_o   => sdp_latch_data2
   );

   sdp_reg_i: SimpleDualPortRAM
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => TRUE)
   port map (
      clk1_i    => clk1_i,
      clk2_i    => clk2_i,
      wen1_i    => wen1_i,
      addr1_i   => addr1_i,
      addr2_i   => addr2_i,
      data1_i   => data1_i,
      data2_o   => sdp_reg_data2
   );

   tdp_nc_i : TrueDualPortRAM 
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE, SYNCMODE => NO_CHANGE)
   port map (
      clk1_i    => clk1_i,
      clk2_i    => clk2_i,
      wen1_i    => wen1_i,
      wen2_i    => wen2_i,
      addr1_i   => addr1_i,
      addr2_i   => addr2_i,
      data1_i   => data1_i,
      data2_i   => data2_i,
      data1_o   => tdp_nc_data1,
      data2_o   => tdp_nc_data2
   );

   tdp_wf_i : TrueDualPortRAM 
   generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE, SYNCMODE => WRITE_FIRST)
   port map (
      clk1_i    => clk1_i,
      clk2_i    => clk2_i,
      wen1_i    => wen1_i,
      wen2_i    => wen2_i,
      addr1_i   => addr1_i,
      addr2_i   => addr2_i,
      data1_i   => data1_i,
      data2_i   => data2_i,
      data1_o   => tdp_wf_data1,
      data2_o   => tdp_wf_data2
   );

   tdp_rf_g: if isQuartus/='1' generate
      tdp_rf_i : TrueDualPortRAM 
      generic map (AWIDTH => 8, DWIDTH => 8, DEPTH => 0, OUTREG => FALSE, SYNCMODE => READ_FIRST)
      port map (
         clk1_i    => clk1_i,
         clk2_i    => clk2_i,
         wen1_i    => wen1_i,
         wen2_i    => wen2_i,
         addr1_i   => addr1_i,
         addr2_i   => addr2_i,
         data1_i   => data1_i,
         data2_i   => data2_i,
         data1_o   => tdp_rf_data1,
         data2_o   => tdp_rf_data2
      );
   end generate tdp_rf_g;

   data1_o <= sp_nc_data1  when sel_i="000" else
              sp_wf_data1  when sel_i="001" else
              sp_rf_data1  when sel_i="010" else
              tdp_nc_data1 when sel_i="011" else
              tdp_wf_data1 when sel_i="100" else
              tdp_rf_data1;

   data2_o <= sdp_latch_data2 when sel_i="000" else
              sdp_reg_data2   when sel_i="001" else
              tdp_nc_data2    when sel_i="010" else
              tdp_wf_data2    when sel_i="011" else
              tdp_rf_data2;

end architecture Structural;
