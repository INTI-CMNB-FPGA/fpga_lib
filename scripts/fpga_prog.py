#!/usr/bin/python
#
# FPGA Prog, transfers a BitStream to a device
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

import argparse, yaml, os, sys, shutil

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

version = 'FPGA Prog (FPGA Helpers) v' + getVersion(share_dir)

boards = []
getBoards(boards, share_dir)

parser = argparse.ArgumentParser(
   prog='fpga_prog',
   description='Transfers a BitStream to a device.',
   epilog="Supported boards: " + ', '.join(boards)
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)
parser.add_argument(
   'bit',
   default="",
   nargs='?',
   metavar='BITSTREAM',
   help='BitStream to be transferred'
)
parser.add_argument(
   '-t', '--tool',
   metavar='TOOLNAME',
   choices=['ise','quartus2','libero-soc'],
   help='Name of the vendor tool to be used [ise |quartus2|libero-soc]'
)

devices = parser.add_argument_group('device arguments')
devices.add_argument(
   '-d', '--device',
   metavar='DEVICE',
   default='fpga',
   choices=['fpga', 'spi', 'bpi', 'xcf', 'detect', 'unlock'],
   help='Type of the target device [fpga(default)|spi|bpi|xcf|detect|unlock]'
)
devices.add_argument(
   '-p', '--position',
   metavar='POSITION',
   type=int,
   default=1,
   help='positive number which represents the POSITION of the device in the ' +
        'JTAG chain [1]'
)
devices.add_argument(
   '-m', '--memname',
   metavar='MEMNAME',
   default='UNDEFINED',
   help='Name of the target memory (when applicable) [UNDEFINED]'
)
devices.add_argument(
   '-w', '--width',
   metavar='WIDTH',
   type=int,
   default=1,
   choices=[1, 4, 8, 16, 32],
   help='positive number which representes the WIDTH of bits of the target ' +
        'memory (when applicable) [1]'
)
devices.add_argument(
   '-b', '--board',
   metavar='BOARDNAME|BOARDFILE',
   help='Name of a supported board or file (.yaml) of a new/custom board ' +
        '(note: if you use the board option, -p, -m, -w and -t will be ' +
        'overwritten) []'
)

options = parser.parse_args()
options.output_dir = '/tmp/fpga_prog'

## Processing the options #####################################################

print ('fpga_prog (INFO): ' + version)

if options.tool is None:
   print ("fpga_prog (INFO): you did not select tool to use. Choose one:")
   print ("1. ISE (Xilinx)")
   print ("2. Quartus2 (INTEL/Altera)")
   print ("3. Libero-SoC (Microsemi)")
   option = sys.stdin.read(1)
   if option == "1":
      options.tool = "ise"
   elif option == "2":
      options.tool = "quartus2"
   elif option == "3":
      options.tool = "libero-soc"
   else:
      sys.exit('fpga_prog (ERROR): invalid option.')

if not os.path.exists(options.bit) and options.device != "detect" and options.device != "unlock" and options.tool != 'libero-soc':
   sys.exit('fpga_prog (ERROR): bitstream not found.')

if options.board is not None:
   if options.board.endswith(".yaml"):
      path = options.board
   else:
      path = share_dir + '/data/boards/' + options.board + '.yaml'
   if os.path.exists(path):
      board = yaml.load(open(path, 'r'))
   else:
      sys.exit('fpga_prog (ERROR): board <' + options.board + '> not exists.')
   if options.device not in board:
      sys.exit('fpga_prog (ERROR): the device <' + options.device + '> is not ' +
                          'supported in the board <' + options.board + '>.')
   if 'position' in board[options.device][0]:
      print ('fpga_prog (INFO): <position> was taken from the board file.')
      options.position = board[options.device][0]['position']
   if 'name' in board[options.device][0]:
      print ('fpga_prog (INFO): <memname> was taken from the board file.')
      options.memname = board[options.device][0]['name']
   if 'width' in board[options.device][0]:
      print ('fpga_prog (INFO): <width> was taken from the board file.')
      options.width = board[options.device][0]['width']

if not os.path.exists(options.output_dir):
   os.makedirs(options.output_dir)
   print ('fpga_prog (INFO): <' + options.output_dir + '> was created.')

## Creating batch file [when nedded] ##########################################

if options.tool == 'ise':
   text = ""
   path = share_dir + '/data/tools/program/impact/'
   if options.device == 'fpga':
      text += getTextProg(options, path + 'fpga')
   if options.device == 'spi':
      text += getTextProg(options, path + 'mcs_spi') + getTextProg(options, path + 'spi')
   if options.device == 'bpi':
      text += getTextProg(options, path + 'mcs_bpi') + getTextProg(options, path + 'bpi')
   if options.device == 'xcf':
      text += getTextProg(options, path + 'mcs_xcf')
   if options.device == 'detect':
      text += getTextProg(options, path + 'detect')
   if options.device == 'unlock':
      text += getTextProg(options, path + 'unlock')
   text += "quit\n"
   text += '# Generated by ' + version + '\n'
   batch = options.output_dir + '/impact.cmd'
   open(batch, 'w').write(text)
   print ('fpga_prog (INFO): <' + batch + '> was generated.')
if options.tool == 'libero-soc':
   path = share_dir + '/data/tools/program/flashpro/'
   if options.device == 'fpga':
      shutil.copy(path + 'flashpro5_fpga.tcl', 'libero-soc/flashpro5.tcl')
   if options.device == 'spi':
      shutil.copy(path + 'flashpro5_spi.tcl', 'libero-soc/flashpro5.tcl')
   shutil.copy(path + 'program.tcl', 'libero-soc/program.tcl')
   print ('fpga_prog (INFO): files were generated.')

## Running the tool ###########################################################

if options.tool == 'ise':
   lib = "/usr/lib/libusb-driver.so";
   if os.path.exists(lib):
      os.environ['LD_PRELOAD'] = str(lib)
      print ('fpga_prog (INFO): <' + lib + '> exists and was loaded.')
   command = 'impact -batch ' + batch
if options.tool == 'quartus2':
   command  = "jtagconfig; "
   command += "quartus_pgm -c USB-blaster --mode jtag -o "
   command += "'p;" + options.bit + "@" + str(options.position) + "'"
if options.tool == 'libero-soc':
   command  = "libero SCRIPT:libero-soc/program.tcl"
os.system(command)
