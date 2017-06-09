#!/usr/bin/python
#
# FPGA Synt, generates files to make a Synthesis
# Copyright (C) 2015-2017 INTI, Rodrigo A. Melo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import argparse, yaml, os, sys, shutil, glob

bin_dir = os.path.dirname(os.path.abspath(__file__))
if os.path.exists(bin_dir + '/../data'):
   share_dir = bin_dir + '/..'
   lib_dir   = bin_dir
else:
   share_dir = bin_dir + '/../share/fpga-helpers'
   lib_dir   = share_dir

sys.path.insert(0, lib_dir)
from fpga_lib import *

## Parsing the command line ###################################################

version = 'FPGA Synt (FPGA Helpers) v' + getVersion(share_dir)

boards = []
getBoards(boards, share_dir)

parser = argparse.ArgumentParser(
   prog='fpga_synt',
   description='Generates files to make a Synthesis.',
   epilog='Supported boards: ' + ', '.join(boards)
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   'tool',
   metavar='TOOLNAME',
   nargs='?',
   choices=['ise','vivado','quartus2','libero-soc','all'],
   help='Name of the vendor tool to be used [ise|vivado|quartus2|libero-soc|all]'
)

parser.add_argument(
   '-b', '--board',
   metavar='BOARDNAME|BOARDFILE',
   help='Name of a supported board or file (.yaml) of a new/custom board '
)

options = parser.parse_args()

## Processing the options #####################################################

print ('fpga_synt (INFO): ' + version)

if options.tool is None:
   print ("fpga_synt (INFO): you did not select tool to use. Choose one:")
   print ("0. All")
   print ("1. ISE (Xilinx)")
   print ("2. Vivado (Xilinx)")
   print ("3. Quartus2 (Altera)")
   print ("4. Libero-SoC (Microsemi)")
   option = sys.stdin.read(1)
   if option == "0":
      options.tool = "all"
   elif option == "1":
      options.tool = "ise"
   elif option == "2":
      options.tool = "vivado"
   elif option == "3":
      options.tool = "quartus2"
   elif option == "4":
      options.tool = "libero-soc"
   else:
      sys.exit('fpga_synt (ERROR): invalid option.')

fpga_prog_text = "ifneq ($(shell which fpga_prog),)\n\n";
if options.board is None:
   fpga_prog_text += 'prog-fpga:\n\tfpga_prog --tool=$(TOOL)' + \
                     ' --device=fpga --position=1 $(firstword $(BIT_FILE))\n'
else:
   if options.board.endswith(".yaml"):
      path = options.board
   else:
      path = share_dir + '/data/boards/' + options.board + '.yaml'
   if os.path.exists(path):
      board = yaml.load(open(path, 'r'))
   else:
      sys.exit('fpga_synt (ERROR): <board> ' + options.board + ' not exists.')
   # fpga_prog alternatives
   if options.tool != 'all':
      for device in sorted(board):
          if device == 'fpga':
             fpga_prog_text += 'prog-fpga:\n\tfpga_prog --tool=$(TOOL) --board=' + \
                               options.board + ' --device=fpga $(firstword $(BIT_FILE))\n'
          if device == 'spi':
             fpga_prog_text += 'prog-spi:\n\tfpga_prog --tool=$(TOOL) --board=' + \
                               options.board + ' --device=spi  $(firstword $(BIT_FILE))\n'
          if device == 'bpi':
             fpga_prog_text += 'prog-bpi:\n\tfpga_prog --tool=$(TOOL) --board=' + \
                               options.board + ' --device=bpi  $(firstword $(BIT_FILE))\n'
fpga_prog_text += "\nendif\n";

## Generating files ###########################################################

if options.tool != 'all':
   shutil.copy(share_dir + '/data/tools/synthesis/options.tcl', '.')
   shutil.copy(share_dir + '/data/tools/synthesis/' + options.tool + '.tcl', '.')
   open(options.tool + '.tcl','a').write("\n# Generated with " + version)
else:
   for filename in glob.glob(share_dir + '/data/tools/synthesis/*.tcl'):
       shutil.copy(filename, '.')
       open(os.path.basename(filename),'a').write("\n# Generated with " + version)
shutil.copy(share_dir + '/data/tools/synthesis/Makefile', '.')
open('Makefile','a').write(fpga_prog_text)
open('Makefile','a').write("\n# Generated with " + version)

print ('fpga_synt (INFO): files were generated.')
