--
-- Numeric Package
--
-- Author(s):
-- * Rodrigo A. Melo
-- * Francisco Salomón
--
-- Copyright (c) 2015-2016 Authors and INTI
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
   -- Math Functions
   function minimum(left, right: in integer) return integer;
   function maximum(left, right: in integer) return integer;
   function log2(a: integer) return integer;

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

   function log2 (a : integer) return integer is
   begin
     if    (a <= 1)                   then return 0;
     elsif (a > 1 and a <= 2)         then return 1;
     elsif (a > 2 and a <= 4)         then return 2;
     elsif (a > 4 and a <= 8)         then return 3;
     elsif (a > 8 and a <= 16)        then return 4;
     elsif (a > 16 and a <= 32)       then return 5;
     elsif (a > 32 and a <= 64)       then return 6;
     elsif (a > 64 and a <= 128)      then return 7;
     elsif (a > 128 and a <= 256)     then return 8;
     elsif (a > 256 and a <= 512)     then return 9;
     elsif (a > 512 and a <= 1024)    then return 10;
     elsif (a > 1024 and a <= 2048)   then return 11;
     elsif (a > 2048 and a <= 4096)   then return 12;
     elsif (a > 4096 and a <= 8192)   then return 13;
     elsif (a > 8192 and a <= 16384)  then return 14;
     elsif (a > 16384 and a <= 32768) then return 15;
     else                                  return 16;
     end if;
   end function log2;
   ----------------------------------------------------------------------------
end package body Numeric;
