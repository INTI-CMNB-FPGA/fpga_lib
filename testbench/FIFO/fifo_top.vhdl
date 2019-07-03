library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.MEMs.all;

entity FIFO_top is
   port (
      async_i      : in  std_logic; -- Test the ASYNC version
      -- write side
      wclk_i       : in  std_logic; -- Write Clock
      wrst_i       : in  std_logic; -- Write Reset
      wen_i        : in  std_logic; -- Write Enable
      data_i       : in  std_logic_vector(7 downto 0); -- Data Input
      full_o       : out std_logic; -- Full Flag
      afull_o      : out std_logic; -- Almost Full Flag
      overflow_o   : out std_logic; -- Overflow Flag
      -- read side
      rclk_i       : in  std_logic; -- Read Clock
      rrst_i       : in  std_logic; -- Read Reset
      ren_i        : in  std_logic; -- Read enable
      data_o       : out std_logic_vector(7 downto 0); -- Data Output
      empty_o      : out std_logic; -- Empty flag
      aempty_o     : out std_logic; -- Almost Empty flag
      underflow_o  : out std_logic; -- Underflow Flag
      valid_o      : out std_logic  -- Read Valid
   );
end entity FIFO_top;

architecture Structural of FIFO_top is

   signal full_s, afull_s, over_s             : std_logic;
   signal empty_s, aempty_s, under_s, valid_s : std_logic;
   signal data_s, data_a                      : std_logic_vector(7 downto 0);
   signal full_a, afull_a, over_a             : std_logic;
   signal empty_a, aempty_a, under_a, valid_a : std_logic;

begin

   full_o      <= full_a   when async_i='1' else full_s;
   afull_o     <= afull_a  when async_i='1' else afull_s;
   overflow_o  <= over_a   when async_i='1' else over_s;
   data_o      <= data_a   when async_i='1' else data_s;
   empty_o     <= empty_a  when async_i='1' else empty_s;
   aempty_o    <= aempty_a when async_i='1' else aempty_s;
   underflow_o <= under_a  when async_i='1' else under_s;
   valid_o     <= valid_a  when async_i='1' else valid_s;

   fifo_sync_inst: fifo
   generic map (DEPTH => 4, ASYNC => FALSE)
   port map (
      -- write side
      wclk_i => wclk_i, wrst_i => wrst_i, wen_i => wen_i, data_i => data_i,
      full_o => full_s, afull_o => afull_s, overflow_o => over_s,
      -- read side
      rclk_i => wclk_i, rrst_i => wrst_i, ren_i => ren_i, data_o => data_s,
      empty_o => empty_s, aempty_o => aempty_s, underflow_o => under_s, valid_o => valid_s
   );

   fifo_async_inst: fifo
   generic map (DEPTH => 4, ASYNC => TRUE)
   port map (
      -- write side
      wclk_i => wclk_i, wrst_i => wrst_i, wen_i => wen_i, data_i => data_i,
      full_o => full_a, afull_o => afull_a, overflow_o => over_a,
      -- read side
      rclk_i => rclk_i, rrst_i => rrst_i, ren_i => ren_i, data_o => data_a,
      empty_o => empty_a, aempty_o => aempty_a, underflow_o => under_a, valid_o => valid_a
   );

end architecture Structural;
