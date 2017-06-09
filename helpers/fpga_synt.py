#!/usr/bin/python
#
# FPGA Synt, do synthesis based on the project file of the vendor's tool
# Copyright (C) 2017 INTI, Rodrigo A. Melo
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

import argparse, glob, sys, os, tempfile
from fpga_db import *

###################################################################################################
# Parsing the command line
###################################################################################################

version = "fpga_synt is a member of FPGA Helpers v%s" % (fpga_db.version)

parser = argparse.ArgumentParser(
   prog="fpga_synt",
   description="Do synthesis based on the project file of the vendor's tool"
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   '-t', '--task',
   metavar = 'TASK',
   choices = ['syn','imp','bit'],
   default = 'bit',
   help    = 'TASK to be executed (syn|imp|bit) [bit]'
)

parser.add_argument(
   'file',
   nargs   = '?',
   metavar = 'PROJECT_FILE',
   help    = 'PROJECT_FILE to be used [auto detected]'
)

options = parser.parse_args()

###################################################################################################
# Collecting information
###################################################################################################

# Detecting file project

if options.file is None:
   options.file = \
      glob.glob("*.xise") + \
      glob.glob("*.xpr")  + \
      glob.glob("*.qpf")  + \
      glob.glob("*.prjx")
   try:
      options.file = options.file[0]
   except:
      sys.exit("fpga_synt (ERROR): project file not auto detected")

if not os.path.exists(options.file):
   sys.exit("fpga_synt (ERROR): file %s do not exists" % options.file)

# Setting vendor's tool

options.tool = None
if options.file.endswith('.xise'):
   options.tool = 'ise'
elif options.file.endswith('.xpr'):
   options.tool = 'vivado'
elif options.file.endswith('.qpf'):
   options.tool = 'quartus'
elif options.file.endswith('.prjx'):
   options.tool = 'libero'
else:
   sys.exit("fpga_synt (ERROR): unsupported vendor's tool")

###################################################################################################
# Running
###################################################################################################

# Preparing a temporary Makefile
temp = tempfile.NamedTemporaryFile()
temp.write("#!/usr/bin/make\n")
temp.write("TOOL=%s\n" % options.tool)
temp.write("TASK=%s\n" % options.task)
temp.write("TCLPATH=%s\n" % (os.path.dirname(os.path.abspath(__file__)) + "/../tcl"))
temp.write("include $(TCLPATH)/Makefile")
temp.flush()

# Executing the Makefile
try:
   os.system("make -f %s run" % temp.name)
except:
   print("fpga_synt (ERROR): failed when run %s" % options.task)

# The Makefile was destroyed
temp.close()
