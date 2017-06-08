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
from fpga_db import *

readline.set_completer_delims(' \t\n;')
readline.parse_and_bind("tab: complete")

###################################################################################################
# Functions
###################################################################################################

def get_input():
    prompt = "EMPTY for default option. TAB for autocomplete. Your selection here > "
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

def get_top(top_file):
    text = open(top_file).read()
    try:
       result = re.match(r"entity (.*) is",text) or re.match(r"module (.*)\(",text)
       if result.group(1):
          return result.group(1)
    except:
       sys.exit("fpga_wizard (ERROR): I had not found an entity/module declaration")

###################################################################################################
# Collect info
###################################################################################################

print("fpga_wizard is part of FPGA_Helpers v%s" % (fpga_db.version))

options = {}

print("") #----------------------------------------------------------------------------------------

alternatives = fpga_db.tools # available tools
readline.set_completer(complete)
default = alternatives[0]
print("Select TOOL to use [%s]" % default)
options['tool'] = get_input() or default

if options['tool'] not in alternatives:
   sys.exit("fpga_wizard (ERROR): unsupported tool")

print("") #----------------------------------------------------------------------------------------

readline.set_completer() # browse filesystem
default = '../tcl'
print("Where to get (if exists) or put Tcl files? [%s]" % default)
options['tcl_path'] = get_input() or default

print("") #----------------------------------------------------------------------------------------

alternatives = glob.glob('*.v*') # vhdl, vhd, v (probably only one file)
readline.set_completer(complete)
default = alternatives[0] if len(alternatives) else 'top.vhdl'
print("Top Level file? [%s]" % default)
options['top_file'] = get_input() or default

if not os.path.exists(options['top_file']):
   sys.exit("fpga_wizard (ERROR): the specified top level does not exists")

options['top_name'] = get_top(options['top_file'])

print("") #----------------------------------------------------------------------------------------

readline.set_completer() # browse filesystem
print("Add files to the project in the form 'PATH[,library]' [None]")
files = []
aux = get_input()
while len(aux):
      files.append(aux)
      aux = get_input()
options['files'] = files

print("") #----------------------------------------------------------------------------------------

alternatives = fpga_db.boards # available boards
readline.set_completer(complete)
print("Board to be used? [None]")
options['board'] = get_input()

if options['board'] and options['board'] not in alternatives:
   sys.exit("fpga_wizard (ERROR): unsupported board")

print("") #----------------------------------------------------------------------------------------

if options['board']:
   options.update(fpga_db.boards[options['board']])
else:
   alternatives = [] # no more options
   readline.set_completer(complete)

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

print("") #----------------------------------------------------------------------------------------

#print (options)

###################################################################################################
# Generate the project
###################################################################################################

# The Makefile

makefile  = "#!/usr/bin/make\n\n"
makefile += "TOOL    = %s\n" % (options['tool'])
makefile += "TCLPATH = %s\n" % (options['tcl_path'])
makefile += "include $(TCLPATH)/Makefile"

# options.tcl

optfile = ""

if 'fpga_name' in options and options['fpga_name'] is not None:
   optfile += "fpga_name   %s\n" % (options['fpga_name'])
if 'fpga_pos' in options and options['fpga_pos'] is not None:
   optfile += "fpga_pos    %s\n" % (options['fpga_pos'])
if 'spi_name' in options and options['spi_name'] is not None:
   optfile += "spi_name    %s\n" % (options['spi_name'])
if 'spi_width' in options and options['spi_width'] is not None:
   optfile += "spi_width   %s\n" % (options['spi_width'])
if 'bpi_name' in options and options['bpi_name'] is not None:
   optfile += "bpi_name    %s\n" % (options['bpi_name'])
if 'bpi_width' in options and options['bpi_width'] is not None:
   optfile += "bpi_width   %s\n" % (options['bpi_width'])
   
optfile += "\n"

if 'fpga_name' in options and options['fpga_name'] is not None:
   optfile += "fpga_device $fpga_name\n"

optfile += "\n"

for files in options['files']:
    file,lib = files.split(",")
    optfile += "fpga_file   %-30s -lib %s\n"%(file,lib)
if 'top_file' in options:
   optfile += "fpga_file   %-30s -top %s\n"%(options['top_file'],options['top_name'])

# Gen files

open("Makefile", 'w').write(makefile)
open("options.tcl", 'w').write(optfile)

print("fpga_wizard (INFO): Makefile and options.tcl were generated")
