#!/usr/bin/python
#
# BIN to HEX
#
# Author: Rodrigo A. Melo
#
# Copyright (c) 2018 Author and INTI
# Distributed under the BSD 3-Clause License
#

from __future__ import print_function
import argparse, re, sys

## Parsing the command line ###################################################

version = 'BIN to HEX v1.0'

parser = argparse.ArgumentParser(
   description='Converts between BIN and HEX.'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

options = parser.parse_args()

## Compute ####################################################################

file = sys.stdin.read()

file = re.sub('[^0123456789ABCDEF\n ]', '', file, 0, re.I)
is_hex = re.search('[23456789ABCDEF]', file, re.I)

if is_hex:
   for char in file:
       if char == ' ' or char == '\n':
          print(char, end="")
       else:
          print(format(int(char, 16), '0>4b'), end="")
else: # is_bin
   bin_val = ['0','0','0','0']
   bin_idx = 0
   row     = 1
   col     = 0
   for char in file:
       if char == ' ' or char == '\n':
          print(char, end="")
          if bin_idx != 0:
             print("ERROR detected (line %d, pos %d)" % (row, col))
             print("To convert BIN to HEX groups of 4 binary digits are needed (I found %d)" % (bin_idx))
             exit()
       else:
          bin_val[bin_idx] = char
          if bin_idx == 3:
             bin_idx = 0
             print(format(int("".join(bin_val), 2), '0>1X'), end="")
          else:
             bin_idx += 1
       if char == '\n':
          row += 1
          col  = 0
       else:
          col += 1
