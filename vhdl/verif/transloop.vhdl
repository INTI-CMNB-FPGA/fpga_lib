--
-- Transceiver Loop
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
library FPGALIB;
use FPGALIB.verif.all;

entity TransLoop is
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
end entity TransLoop;

architecture RTL of TransLoop is

   constant K28_5 : std_logic_vector(7 downto 0):=x"BC";
   constant K28_1 : std_logic_vector(7 downto 0):=x"3C";

   constant DWIDTH                   : positive:=DBYTES*8;
   signal   rx_data, tx_data         : std_logic_vector(DWIDTH-1 downto 0);
   signal   rx_stb, tx_stb           : std_logic;
   signal   rx_cnt, tx_cnt           : unsigned(DWIDTH-1 downto 0);
   signal   rx_cycles                : unsigned(31 downto 0);

   type state_t is (IDLE, STROBE, ACK, TRANSFER, GAP, FINISH);
   signal   tx_state, rx_state : state_t:=IDLE;

   function repeat (value: std_logic_vector; num: positive) return std_logic_vector is
      variable retval : std_logic_vector(num*8-1 downto 0);
   begin
      for i in 1 to num loop
          retval(i*8-1 downto (i-1)*8):=value;
      end loop;
      return retval;
   end repeat;

   constant tied_to_vcc : std_logic_vector(DWIDTH-1 downto 0):=(others => '1');
   constant tied_to_gnd : std_logic_vector(DWIDTH-1 downto 0):=(others => '0');
begin

   loop_i: LoopCheck
   generic map (DWIDTH => DWIDTH)
   port map(
      -- TX side
      tx_clk_i    => tx_clk_i,
      tx_rst_i    => tx_rst_i,
      tx_stb_i    => tx_stb,
      tx_data_i   => tx_data_i,
      tx_data_o   => tx_data,
      -- RX side
      rx_clk_i    => rx_clk_i,
      rx_rst_i    => rx_rst_i,
      rx_stb_i    => rx_stb,
      rx_data_i   => rx_data,
      rx_errors_o => rx_errors_o
   );

   tx_fsm: process(tx_clk_i) is
   begin
      if rising_edge(tx_clk_i) then
         if tx_rst_i='1' then
            tx_state  <= IDLE;
            tx_isk_o  <= (others => '0');
            tx_data_o <= (others => '0');
            tx_cnt    <= (others => '0');
            tx_stb    <= '0';
         else
            case tx_state is
                 when IDLE =>
                      if tx_ready_i='1' then
                         tx_state <= STROBE;
                      end if;
                 when STROBE =>
                      tx_isk_o  <= (others => '1');
                      tx_data_o <= repeat(K28_5,DBYTES);
                      tx_state  <= ACK;
                 when ACK =>
                      if rx_data_i=repeat(K28_5,DBYTES) and rx_isk_i=tied_to_vcc(DBYTES-1 downto 0) then
                         tx_state   <= TRANSFER;
                         tx_stb     <= '1';
                      end if;
                 when TRANSFER =>
                      tx_isk_o  <= (others => '0');
                      tx_data_o <= tx_data;
                      tx_cnt   <= tx_cnt+1;
                      if tx_cnt=TSIZE-1 then
                         tx_stb   <= '0';
                         tx_state <= FINISH;
                      elsif (tx_cnt mod FSIZE = FSIZE-1) then
                         tx_state <= GAP;
                         tx_stb   <= '0';
                      end if;
                 when GAP =>
                      tx_isk_o  <= (others => '1');
                      tx_data_o <= repeat(K28_1,DBYTES);
                      tx_state  <= TRANSFER;
                      tx_stb    <= '1';
                 when FINISH =>
                      tx_isk_o  <= (others => '1');
                      tx_data_o <= repeat(K28_5,DBYTES);
                 when others =>
                      tx_state <= IDLE;
            end case;
         end if;
      end if;
   end process tx_fsm;

   rx_fsm: process(rx_clk_i) is
   begin
      if rising_edge(rx_clk_i) then
         rx_finish_o <= '0';
         if rx_rst_i='1' then
            rx_state  <= IDLE;
            rx_cnt    <= (others => '0');
         else
            case rx_state is
                 when IDLE =>
                      if rx_data_i=repeat(K28_5,DBYTES) and rx_isk_i=tied_to_vcc(DBYTES-1 downto 0) then
                         rx_state <= ACK;
                      end if;
                 when ACK =>
                      rx_state  <= TRANSFER;
                      rx_cycles <= (others => '0');
                 when TRANSFER =>
                      rx_cycles <= rx_cycles + 1;
                      if rx_isk_i=tied_to_gnd(DBYTES-1 downto 0) then
                         rx_data <= rx_data_i;
                         rx_stb  <= '1';
                         rx_cnt  <= rx_cnt + 1;
                      else
                         rx_stb  <= '0';
                         if rx_cnt>0 and rx_data_i=repeat(K28_5,DBYTES) then
                            rx_state <= FINISH;
                            rx_finish_o <= '1';
                         end if;
                      end if;
                 when FINISH =>
                      rx_finish_o <= '1';
                 when others =>
                      rx_state <= IDLE;
            end case;
         end if;
      end if;
   end process rx_fsm;
   rx_cycles_o <= std_logic_vector(rx_cycles);

end architecture RTL;
