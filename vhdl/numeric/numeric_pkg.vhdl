--
-- Numeric Package
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2017 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Numeric is

   -- Conversion Functions
   --- To Integer
   function to_integer(arg: std_logic) return integer;
   function to_integer(arg: std_logic_vector) return integer;
   function to_natural(arg: std_logic_vector) return natural;
   --- To Std Logic
   function to_logic(arg: integer) return std_logic;
   function to_vector(arg: integer; size: positive; sign: boolean:=FALSE) return std_logic_vector;
   --- Binary <-> Gray
   function bin2gray(arg: unsigned) return unsigned;
   function bin2gray(arg: std_logic_vector) return std_logic_vector;
   function gray2bin(arg: unsigned) return unsigned;
   function gray2bin(arg: std_logic_vector) return std_logic_vector;
   -- Math Functions
   function minimum(left, right: in integer) return integer;
   function maximum(left, right: in integer) return integer;
   function clog2(arg: natural) return natural;

   component Counter is
      generic (
         DEPTH   : positive:=8
      );
      port (
         clk_i   : in  std_logic; -- Clock
         rst_i   : in  std_logic; -- Reset
         ena_i   : in  std_logic; -- Input Enable
         count_o : out std_logic_vector(clog2(DEPTH)-1 downto 0); -- Counter value
         last_o  : out std_logic  -- Last value
      );
   end component Counter;

end package Numeric;

package body Numeric is
   ----------------------------------------------------------------------------
   -- Conversions to integer
   ----------------------------------------------------------------------------
   function to_integer(arg: std_logic) return integer is
   begin
      if arg='1' then
         return 1;
      end if;
      return 0;
   end to_integer;

   function to_integer(arg: std_logic_vector) return integer is
   begin
      return to_integer(signed(arg));
   end to_integer;

   function to_natural(arg: std_logic_vector) return natural is
   begin
      return to_integer(unsigned(arg));
   end to_natural;
   ----------------------------------------------------------------------------
   -- Conversions to standard logic
   ----------------------------------------------------------------------------
   function to_logic(arg: integer) return std_logic is
   begin
      if arg=1 then
         return '1';
      end if;
      return '0';
   end to_logic;

   function to_vector(arg: integer; size: positive; sign: boolean:=FALSE) return std_logic_vector is
   begin
      if not(sign) then
         return std_logic_vector(to_unsigned(arg,size));
      end if;
      return std_logic_vector(to_signed(arg,size));
   end function to_vector;
   ----------------------------------------------------------------------------
   -- Conversions betwenn Binary and Gray codes
   ----------------------------------------------------------------------------
   function bin2gray(arg: unsigned) return unsigned is
   begin
      return shift_right(arg, 1) xor arg;
   end bin2gray;

   function bin2gray(arg: std_logic_vector) return std_logic_vector is
   begin
      return std_logic_vector(bin2gray(unsigned(arg)));
   end bin2gray;

   function gray2bin(arg: unsigned) return unsigned is
      variable gray, bin : unsigned(arg'high downto 0);
   begin
      gray := arg;
      bin(bin'high):=gray(gray'high);
      for i in gray'high-1 downto 0 loop
          bin(i):=bin(i+1) xor gray(i);
      end loop;
      return bin;
   end gray2bin;

   function gray2bin(arg: std_logic_vector) return std_logic_vector is
   begin
      return std_logic_vector(gray2bin(unsigned(arg)));
   end gray2bin;
   ----------------------------------------------------------------------------
   -- Math Functions
   ----------------------------------------------------------------------------
   function minimum (left, right: in integer) return integer is
   begin
      if left < right then return left;
      else return right;
      end if;
   end function minimum;

   function maximum (left, right: in integer) return integer is
   begin
      if left > right then return left;
      else return right;
      end if;
   end function maximum;

   function clog2 (arg : natural) return natural is
   begin
      for i in 0 to 31 loop
          if arg <= 2**i then
             return i;
          end if;
      end loop;
      return 32;
   end function clog2;
   ----------------------------------------------------------------------------
end package body Numeric;
