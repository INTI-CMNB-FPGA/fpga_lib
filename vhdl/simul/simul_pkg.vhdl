--
-- Simul Package
-- Package of Simul, with additional procedures and functions only for simulations.
--
-- Author(s):
-- * Rodrigo A. Melo
--
-- Copyright (c) 2015-2016 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library STD;
use STD.textio.all;

package Simul is
   ----------------------------------------------------------------------------
   -- Print
   ----------------------------------------------------------------------------
   procedure print(message: character; reps: positive:=1);
   procedure print(message: string; reps: positive:=1);
   ----------------------------------------------------------------------------
   -- Convertions
   ----------------------------------------------------------------------------
   function hex2bin(arg: string) return string;
   function bin2hex(arg: string) return string;

   function to_str(arg: std_logic_vector; format: character:='B') return string;
   function to_str(arg: unsigned; format: character:='B') return string;
   function to_str(arg: signed; format: character:='B') return string;
   function to_str(arg: integer) return string;

   function to_char(arg: integer) return character;
   function to_char(arg: std_logic) return character;
   function to_char(arg: std_logic_vector(7 downto 0)) return character;

   function to_logic(arg: character) return std_logic;
   function to_vector(arg: string) return std_logic_vector;
   ----------------------------------------------------------------------------
   -- Read/Write
   ----------------------------------------------------------------------------
   procedure read(l: inout line; value: out std_logic);
   procedure read(l: inout line; value: out std_logic; good: out boolean);

   procedure read(l: inout line; value: out std_logic_vector);
   procedure read(l: inout line; value: out std_logic_vector; good: out boolean);

   procedure write(l: inout line; value: in std_logic);
   procedure write(l: inout line; value: in std_logic_vector);
   ----------------------------------------------------------------------------
   -- Components
   ----------------------------------------------------------------------------
   component Clock is
      generic(
         FREQUENCY  : positive:=25e6; -- Hz
         PERIOD     : time:=0 sec;    -- Used insted of FREQUENCY when greater than 0 sec
         RESET_CLKS : real:=1.5       -- Reset duration expresed in clocks
      );
      port(
         clk_o  : out std_logic;
         rst_o  : out std_logic;
         stop_i :  in boolean:=FALSE -- Stop clock generation
      );
   end component Clock;
   ----------------------------------------------------------------------------
end package Simul;

package body Simul is
   ----------------------------------------------------------------------------
   -- Print
   ----------------------------------------------------------------------------
   procedure print(message: character; reps: positive:=1) is
      variable l : line;
   begin
      for i in 1 to reps loop
          write(l,message);
      end loop;
      writeline(output,l);
   end procedure print;

   procedure print(message: string; reps: positive:=1) is
      variable l : line;
   begin
      for i in 1 to reps loop
          write(l,message);
      end loop;
      writeline(output,l);
   end procedure print;
   ----------------------------------------------------------------------------
   -- Conversions bin <> hex
   ----------------------------------------------------------------------------
   function hex2bin(arg: string) return string is
      variable bin   : string(1 to (arg'length * 4));
      variable index : integer;
      variable char  : character;
   begin
      index := 1;
      for i in arg'range loop
          char := arg(i);
          case char is
               when '0'     => bin(index to index+3) := "0000";
               when '1'     => bin(index to index+3) := "0001";
               when '2'     => bin(index to index+3) := "0010";
               when '3'     => bin(index to index+3) := "0011";
               when '4'     => bin(index to index+3) := "0100";
               when '5'     => bin(index to index+3) := "0101";
               when '6'     => bin(index to index+3) := "0110";
               when '7'     => bin(index to index+3) := "0111";
               when '8'     => bin(index to index+3) := "1000";
               when '9'     => bin(index to index+3) := "1001";
               when 'A'|'a' => bin(index to index+3) := "1010";
               when 'B'|'b' => bin(index to index+3) := "1011";
               when 'C'|'c' => bin(index to index+3) := "1100";
               when 'D'|'d' => bin(index to index+3) := "1101";
               when 'E'|'e' => bin(index to index+3) := "1110";
               when 'F'|'f' => bin(index to index+3) := "1111";
               --
               when 'Z'|'z' => bin(index to index+3) := "ZZZZ";
               when 'L'|'l' => bin(index to index+3) := "LLLL";
               when 'H'|'h' => bin(index to index+3) := "HHHH";
               when 'U'|'u' => bin(index to index+3) := "UUUU";
               when 'W'|'w' => bin(index to index+3) := "WWWW";
               when others => bin(index to index+3) := "XXXX";
          end case;
          index := index + 4;
      end loop;
      return bin;
   end hex2bin;

   function bin2hex(arg: string) return string is
      constant high  : positive:=arg'length/4;
      variable hex   : string(1 to high);
      variable index : integer;
      variable str   : string(1 to 4);
   begin
      index := 0;
      for i in 1 to high loop
          str := arg((i*4-3) to (i*4));
          case str is
               when "0000" => hex(index+1):='0';
               when "0001" => hex(index+1):='1';
               when "0010" => hex(index+1):='2';
               when "0011" => hex(index+1):='3';
               when "0100" => hex(index+1):='4';
               when "0101" => hex(index+1):='5';
               when "0110" => hex(index+1):='6';
               when "0111" => hex(index+1):='7';
               when "1000" => hex(index+1):='8';
               when "1001" => hex(index+1):='9';
               when "1010" => hex(index+1):='A';
               when "1011" => hex(index+1):='B';
               when "1100" => hex(index+1):='C';
               when "1101" => hex(index+1):='D';
               when "1110" => hex(index+1):='E';
               when "1111" => hex(index+1):='F';
               --
               when "ZZZZ" => hex(index+1):='Z';
               when "LLLL" => hex(index+1):='L';
               when "HHHH" => hex(index+1):='H';
               when "UUUU" => hex(index+1):='U';
               when "WWWW" => hex(index+1):='W';
               when others => hex(index+1):='X';
          end case;
          index := index + 1;
      end loop;
      return hex;
   end function bin2hex;
   ----------------------------------------------------------------------------
   -- Conversions to string
   ----------------------------------------------------------------------------
   function to_str(arg: std_logic_vector; format: character:='B') return string is
      variable str   : string (1 to arg'length);
      variable index : integer;
   begin
      index := 1;
      for i in arg'range loop
          str(index) := to_char(arg(i));
          index := index + 1;
      end loop;
      if format='B' or format='b' then
         return str;
      end if;
      if format='H' or format='h' then
         return bin2hex(str);
      end if;
      report "to_str: unsupported format parameter ("&format&")" severity failure;
      return str;
   end to_str;

   function to_str(arg: unsigned; format: character:='B') return string is
   begin
      return to_str(std_logic_vector(arg), format);
   end function to_str;

   function to_str(arg: signed; format: character:='B') return string is
   begin
      return to_str(std_logic_vector(arg), format);
   end function to_str;

   function to_str(arg: integer) return string is
   begin
      return integer'image(arg);
   end function to_str;
   ----------------------------------------------------------------------------
   -- Conversions to char
   ----------------------------------------------------------------------------
   function to_char(arg: integer) return character is
   begin
      return character'val(arg);
   end to_char;

   function to_char(arg: std_logic) return character is
      variable str : string(1 to 3);
   begin
      str:=std_logic'image(arg);
      return str(2);
   end to_char;

   function to_char(arg: std_logic_vector(7 downto 0)) return character is
   begin
      return character'val(to_integer(unsigned(arg)));
   end function to_char;
   ----------------------------------------------------------------------------
   -- Conversions to standard logic
   ----------------------------------------------------------------------------
   function to_logic(arg: character) return std_logic is
      variable sl: std_logic;
   begin
      case arg is
           when '0'     => sl := '0';
           when '1'     => sl := '1';
           when '-'     => sl := '-';
           when 'U'|'u' => sl := 'U'; 
           when 'X'|'x' => sl := 'X';
           when 'Z'|'z' => sl := 'Z';
           when 'W'|'w' => sl := 'W';
           when 'L'|'l' => sl := 'L';
           when 'H'|'h' => sl := 'H';
           when others  => sl := 'X'; 
      end case;
      return sl;
   end to_logic;

   function to_vector(arg: string) return std_logic_vector is
      variable slv   : std_logic_vector(arg'length-1 downto 0);
      variable index : integer;
   begin
      index := arg'length-1;
      for i in arg'range loop
          slv(index) := to_logic(arg(i));
          index      := index - 1;
      end loop;
      return slv;
   end to_vector;
   ----------------------------------------------------------------------------
   -- Read/Write
   ----------------------------------------------------------------------------
   procedure read(l: inout line; value: out std_logic) is
      variable str : string(1 downto 1);
   begin
      read(l,str);
      value:=to_logic(str(1));
   end procedure read;

   procedure read(l: inout line; value: out std_logic; good: out boolean) is
      variable str : string(1 downto 1);
      variable ok  : boolean;
   begin
      read(l,str,ok);
      good:=ok;
      if ok then
         value:=to_logic(str(1));
      end if;
   end procedure read;

   procedure read(l: inout line; value: out std_logic_vector) is
      variable str : string(value'length downto 1);
   begin
      read(l,str);
      value:=to_vector(str);
   end procedure read;

   procedure read(l: inout line; value: out std_logic_vector; good: out boolean) is
      variable str : string(value'length downto 1);
      variable ok  : boolean;
   begin
      read(l,str,ok);
      good:=ok;
      if ok then
         value:=to_vector(str);
      end if;
   end procedure read;

   procedure write(l: inout line; value: in std_logic) is
      variable str : string(3 downto 1);
   begin
      str:=std_logic'image(value);
      write(l,str(2));
   end procedure write;

   procedure write(l: inout line; value: in std_logic_vector) is
      variable str : string(3 downto 1);
   begin
      for i in value'range loop
          str:=std_logic'image(value(i));
          write(l,str(2));
      end loop;
   end procedure write;
   ----------------------------------------------------------------------------
end package body Simul;
