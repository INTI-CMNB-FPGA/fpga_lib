--
-- LoopCheck
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2016-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LoopCheck is
   generic (
      DWIDTH : positive:=8  -- Data width
   );
   port (
      -- TX side
      tx_clk_i     : in  std_logic;
      tx_rst_i     : in  std_logic;
      tx_stb_i     : in  std_logic;
      tx_data_i    : in  std_logic_vector(DWIDTH-1 downto 0);
      tx_data_o    : out std_logic_vector(DWIDTH-1 downto 0);
      -- RX side
      rx_clk_i     : in  std_logic;
      rx_rst_i     : in  std_logic;
      rx_stb_i     : in  std_logic;
      rx_data_i    : in  std_logic_vector(DWIDTH-1 downto 0);
      rx_errors_o  : out std_logic_vector(4 downto 0)
   );
end entity LoopCheck;

architecture RTL of LoopCheck is
   constant NOT_RECEIVED  : natural:=0;
   constant VAL_MISSMATCH : natural:=1;
   constant QTY_MISSMATCH : natural:=2;
   constant QTY_LESS      : natural:=3;
   constant QTY_MORE      : natural:=4;
   signal tx_qty, rx_qty  : unsigned(DWIDTH downto 0);
   signal errors          : std_logic_vector(4 downto 0);
begin

   tx_side: process(tx_clk_i)
   begin
      if rising_edge(tx_clk_i) then
         if tx_rst_i='1' then
            tx_data_o <= tx_data_i;
            tx_qty    <= '0' & unsigned(tx_data_i);
         elsif tx_stb_i='1' then
            tx_data_o <= std_logic_vector(tx_qty(DWIDTH-1 downto 0) + 1);
            tx_qty    <= tx_qty + 1;
         end if;
      end if;
   end process;

   rx_side: process(rx_clk_i)
   begin
      if rising_edge(rx_clk_i) then
         if rx_rst_i='1' then
            rx_qty <= '0' & unsigned(tx_data_i);
            errors <= "00001";
         elsif rx_stb_i='1' then
            errors(NOT_RECEIVED) <= '0';
            if rx_data_i /= std_logic_vector(rx_qty(DWIDTH-1 downto 0)) then
               errors(VAL_MISSMATCH) <= '1';
            end if;
            if tx_qty=rx_qty+1 then
               errors(QTY_MISSMATCH) <= '0';
               errors(QTY_LESS)      <= '0';
               errors(QTY_MORE)      <= '0';
            elsif tx_qty>rx_qty+1 then
               errors(QTY_MISSMATCH) <= '1';
               errors(QTY_LESS)      <= '1';
               errors(QTY_MORE)      <= '0';
            else -- tx_qty<rx_qty+1
               errors(QTY_MISSMATCH) <= '1';
               errors(QTY_LESS)      <= '0';
               errors(QTY_MORE)      <= '1';
            end if;
            rx_qty <= rx_qty + 1;
         end if;
      end if;
   end process;
   rx_errors_o <= errors;

end architecture RTL;
