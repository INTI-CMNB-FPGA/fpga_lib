--
-- FIFOs Top Level
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
      wr_clk_i     : in  std_logic;
      wr_rst_i     : in  std_logic;
      wr_en_i      : in  std_logic;
      data_i       : in  std_logic_vector(7 downto 0);
      full_o       : out std_logic;
      afull_o      : out std_logic;
      overflow_o   : out std_logic;
      -- read side
      rd_clk_i     : in  std_logic;
      rd_rst_i     : in  std_logic;
      rd_en_i      : in  std_logic;
      data_o       : out std_logic_vector(7 downto 0);
      empty_o      : out std_logic;
      aempty_o     : out std_logic;
      underflow_o  : out std_logic;
      valid_o      : out std_logic;
      --
      sel_i        : in  std_logic_vector(1 downto 0)
   );
end entity Top;

architecture Structural of Top is

   -- sp: sync_partial
   -- sf: sync full
   -- ap: async partial
   -- af: async full

   -- Write side
   signal sp_full,   sf_full,   ap_full,   af_full   : std_logic;
   signal sp_afull,  sf_afull,  ap_afull,  af_afull  : std_logic;
   signal sp_over,   sf_over,   ap_over,   af_over   : std_logic;
   -- Read side
   signal sp_data,   sf_data,   ap_data,   af_data   : std_logic_vector(7 downto 0);
   signal sp_empty,  sf_empty,  ap_empty,  af_empty  : std_logic;
   signal sp_aempty, sf_aempty, ap_aempty, af_aempty : std_logic;
   signal sp_under,  sf_under,  ap_under,  af_under  : std_logic;
   signal sp_valid,  sf_valid,  ap_valid,  af_valid  : std_logic;

begin

   i_sync_partial : FIFO
   generic map (
      DWIDTH       => 8,
      DEPTH        => 6*1024,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 1,
      ASYNC        => FALSE
   )
   port map (
      -- write side
      wr_clk_i     => wr_clk_i,
      wr_rst_i     => wr_rst_i,
      wr_en_i      => wr_en_i,
      data_i       => data_i,
      full_o       => sp_full,
      afull_o      => sp_afull,
      overflow_o   => sp_over,
      -- read side
      rd_clk_i     => wr_clk_i,
      rd_rst_i     => wr_rst_i,
      rd_en_i      => rd_en_i,
      data_o       => sp_data,
      empty_o      => sp_empty,
      aempty_o     => sp_aempty,
      underflow_o  => sp_under,
      valid_o      => sp_valid
   );

   i_sync_full : FIFO
   generic map (
      DWIDTH       => 8,
      DEPTH        => 8*1024,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 1,
      ASYNC        => FALSE
   )
   port map (
      -- write side
      wr_clk_i     => wr_clk_i,
      wr_rst_i     => wr_rst_i,
      wr_en_i      => wr_en_i,
      data_i       => data_i,
      full_o       => sf_full,
      afull_o      => sf_afull,
      overflow_o   => sf_over,
      -- read side
      rd_clk_i     => wr_clk_i,
      rd_rst_i     => wr_rst_i,
      rd_en_i      => rd_en_i,
      data_o       => sf_data,
      empty_o      => sf_empty,
      aempty_o     => sf_aempty,
      underflow_o  => sf_under,
      valid_o      => sf_valid
   );

   i_async_partial : FIFO
   generic map (
      DWIDTH       => 8,
      DEPTH        => 6*1024,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 1,
      ASYNC        => TRUE
   )
   port map (
      -- write side
      wr_clk_i     => wr_clk_i,
      wr_rst_i     => wr_rst_i,
      wr_en_i      => wr_en_i,
      data_i       => data_i,
      full_o       => ap_full,
      afull_o      => ap_afull,
      overflow_o   => ap_over,
      -- read side
      rd_clk_i     => rd_clk_i,
      rd_rst_i     => rd_rst_i,
      rd_en_i      => rd_en_i,
      data_o       => ap_data,
      empty_o      => ap_empty,
      aempty_o     => ap_aempty,
      underflow_o  => ap_under,
      valid_o      => ap_valid
   );

   i_async_full : FIFO
   generic map (
      DWIDTH       => 8,
      DEPTH        => 8*1024,
      OUTREG       => FALSE,
      AFULLOFFSET  => 1,
      AEMPTYOFFSET => 1,
      ASYNC        => TRUE
   )
   port map (
      -- write side
      wr_clk_i     => wr_clk_i,
      wr_rst_i     => wr_rst_i,
      wr_en_i      => wr_en_i,
      data_i       => data_i,
      full_o       => af_full,
      afull_o      => af_afull,
      overflow_o   => af_over,
      -- read side
      rd_clk_i     => rd_clk_i,
      rd_rst_i     => rd_rst_i,
      rd_en_i      => rd_en_i,
      data_o       => af_data,
      empty_o      => af_empty,
      aempty_o     => af_aempty,
      underflow_o  => af_under,
      valid_o      => af_valid
   );

   full_o      <= sp_full when sel_i="00" else
                  sf_full when sel_i="01" else
                  ap_full when sel_i="10" else
                  af_full;

   afull_o     <= sp_afull when sel_i="00" else
                  sf_afull when sel_i="01" else
                  ap_afull when sel_i="10" else
                  af_afull;

   overflow_o  <= sp_over when sel_i="00" else
                  sf_over when sel_i="01" else
                  ap_over when sel_i="10" else
                  af_over;

   data_o      <= sp_data when sel_i="00" else
                  sf_data when sel_i="01" else
                  ap_data when sel_i="10" else
                  af_data;

   empty_o     <= sp_empty when sel_i="00" else
                  sf_empty when sel_i="01" else
                  ap_empty when sel_i="10" else
                  af_empty;

   aempty_o    <= sp_aempty when sel_i="00" else
                  sf_aempty when sel_i="01" else
                  ap_aempty when sel_i="10" else
                  af_aempty;

   underflow_o <= sp_under when sel_i="00" else
                  sf_under when sel_i="01" else
                  ap_under when sel_i="10" else
                  af_under;

   valid_o     <= sp_valid when sel_i="00" else
                  sf_valid when sel_i="01" else
                  ap_valid when sel_i="10" else
                  af_valid;

end architecture Structural;
