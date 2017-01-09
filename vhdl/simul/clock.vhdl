--
-- Clock
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;

entity Clock is
   generic(
      FREQUENCY  : positive:=25e6; -- Hz
      PERIOD     : time:=0 sec;    -- Used insted of FREQUENCY when greater than 0 sec
      RESET_CLKS : real:=1.5       -- Reset duration expresed in clocks
   );
   port(
      clk_o  : out std_logic;
      rst_o  : out std_logic;
      stop_i :  in boolean:=FALSE  -- Stop clock generation
   );
end entity Clock;

architecture Simulator of Clock is

   function get_clock_time(per: time; freq: positive) return time is
   begin
      if per > 0 sec then
         return per;
      end if;
      return 1 sec/(real(FREQUENCY));
   end function get_clock_time;

   signal clk : std_logic:='1';
   constant CLOCK_TIME: time:=get_clock_time(PERIOD,FREQUENCY);
   constant RESET_TIME: time:=CLOCK_TIME*RESET_CLKS;
begin

   do_clock: process
   begin
      while not stop_i loop
         wait for CLOCK_time/2;
         clk <= not clk;
      end loop;
      wait;
   end process do_clock;
   clk_o  <= clk;

   rst_o <= '1', '0' after RESET_TIME;

end architecture Simulator; -- Entity: Clock
