--
-- Gray Synchronizer
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
use FPGALIB.Numeric.all;
use FPGALIB.Sync.all;

entity Gray_Sync is
   generic(
      WIDTH : positive:=8;
      DEPTH : positive:=2
   );
   port(
      clk_i  : in  std_logic;
      data_i : in  unsigned(WIDTH-1 downto 0);
      data_o : out unsigned(WIDTH-1 downto 0)
   );
end entity Gray_Sync;

architecture Structural of Gray_Sync is
   signal grayi, grayo : std_logic_vector(WIDTH-1 downto 0);
begin

   grayi <= std_logic_vector(bin2gray(data_i));

   sync_i: FFchain
   generic map(WIDTH => WIDTH, DEPTH => DEPTH)
   port map(clk_i => clk_i, rst_i => '0', ena_i => '1', data_i => grayi, data_o => grayo);

   data_o <= unsigned(gray2bin(grayo));

end architecture Structural;
