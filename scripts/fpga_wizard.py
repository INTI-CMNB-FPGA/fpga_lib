#!/usr/bin/python
#
# FPGA Wizard
# Copyright (C) 2017 INTI
# Copyright (C) 2017 Rodrigo A. Melo
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

import sys, os, readline, re, glob

readline.set_completer_delims(' \t\n;')
readline.parse_and_bind("tab: complete")

###################################################################################################
# Functions
###################################################################################################

def get_input():
    prompt = "[ENTER for default, TAB for autocomplete] > "
    try:    # Python2
       return raw_input(prompt)
    except: # Python3
       return input(prompt)

def complete(text, state):
    for opt in alternatives:
        if opt.startswith(text):
           if not state:
              return opt
           else:
              state -= 1

def get_part(text):
    text = re.sub(" *", "" , text)
    if not len(text):
       return None,None
    text = text.split(",")
    if len(text) != 2:
       sys.exit("fpga_wizard (ERROR): two parameters separated by ',' must be given")
    return text[0],text[1]

###################################################################################################
# Collect info
###################################################################################################

options = {}

alternatives = ['ise','vivado','quartus','libero']
readline.set_completer(complete)
default = 'vivado'
print("Select TOOL to use [%s]" % default)
options['tool'] = get_input() or default

if options['tool'] not in alternatives:
   sys.exit("fpga_wizard (ERROR): unsupported tool")

print("")

readline.set_completer() # browse filesystem
default = '../tcl'
print("Where to get (if exists) or put Tcl files? [%s]" % default)
options['tcl_path'] = get_input() or default

print("")

alternatives = glob.glob('*.v*') # vhdl, vhd, v (probably only one file)
readline.set_completer(complete)
default = alternatives[0]
print("Top Level file? [%s]" % default)
options['top_file'] = get_input() or default

if not os.path.exists(options['top_file']):
   sys.exit("fpga_wizard (ERROR): the specified top level does not exists")

print("")

readline.set_completer() # browse filesystem
print("Add files to the project in the form 'PATH[,library]' (ENTER without data to finish)")
files = []
aux = get_input()
while len(aux):
      files.append(aux)
      aux = get_input()
options['files'] = files

print("")

boards = glob.glob("../boards/*.yaml")
alternatives = []
for board in boards:
    alternatives.append(os.path.splitext(os.path.basename(board))[0])
readline.set_completer(complete) # available boards
print("Board to be used? [None]")
options['board'] = get_input()

if options['board'] and not os.path.exists("../boards/" + options['board'] + ".yaml"):
   sys.exit("fpga_wizard (ERROR): unsupported board")

print("")

alternatives = [] # no more options
readline.set_completer(complete)

if not options['board']:
   print("Specify a FPGA in the form 'PARTNAME,POSITION' [None]")
   options['fpga_name'],options['fpga_pos'] = get_part(get_input())

   if options['fpga_pos'] and int(options['fpga_pos']) not in [1, 2, 3, 4]:
      sys.exit("fpga_wizard (ERROR): FPGA position can be 1 to 4")

   print("")

   print("Specify a SPI in the form 'PARTNAME,DATAWIDTH' [None]")
   options['spi_name'],options['spi_width'] = get_part(get_input())

   if options['spi_width'] and int(options['spi_width']) not in [1, 2, 3, 4]:
      sys.exit("fpga_wizard (ERROR): SPI data width can be 1 to 4")

   print("")

   print("Specify a BPI in the form 'PARTNAME,DATAWIDTH' [None]")
   options['bpi_name'],options['bpi_width'] = get_part(get_input())

   if options['bpi_width'] and int(options['bpi_width']) not in [8, 16, 32, 64]:
      sys.exit("fpga_wizard (ERROR): BPI data width can be 8, 16, 32 or 64")

print (options)

###################################################################################################
# Generate the project
###################################################################################################

