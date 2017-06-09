#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# FPGA Deps collects the files of an HDL project
# Copyright (C) 2015-2016 INTI, Rodrigo A. Melo
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

# Assumptions:
# * Files are well formed.
# * VHDL:
#   * A file could have one or more packages and/or one or more entities.
#   * The architectures must be in the file where their entity is.
#   * Configurations are no supported.
# * Verilog:
#   * A file could have one or more modules.

import argparse, os, sys, re, mimetypes

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

version = 'FPGA Deps (FPGA Helpers) v' + getVersion(share_dir)

parser = argparse.ArgumentParser(
   prog='fpga_deps',
   description='Collects the files of an HDL project.'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   '--verbose',
   action='count'
)

parser.add_argument(
   'top',
   metavar='TOPFILE',
   nargs='?',
   help='Top Level File'
)

parser.add_argument(
   '-d', '--deep',
   metavar='DEEP',
   type=int,
   default=4,
   help='DEEP where to start to search [4]'
)

options = parser.parse_args()

if (options.verbose):
   print ("\nOptions: " + str(options))

if options.deep:
   dir = ""
   for i in range(0, options.deep):
       dir += "../"
else:
   dir = "."

## Collecting files ###########################################################

files_aux  = []
files_info = {}

if (options.verbose):
   print ("\nCollecting files..."),

for root, dirs, files in os.walk(dir):
    for file in files:
        filepath = root+'/'+file
        if file.endswith('.vhdl') or file.endswith('.vhd'):
           files_aux.append(filepath)
           files_info[filepath] = {"lan":"vhdl","lib":"work"}
        if file.endswith('.v') or file.endswith('.sv'):
           files_aux.append(filepath)
           files_info[filepath] = {"lan":"verilog","lib":"work"}
files = files_aux

qty = len(files)
if (qty < 1):
   sys.exit('fpga_deps (ERROR): no files were found.')

if (options.verbose):
   print ("%d files found" % (qty))
   for key in files_info.keys():
       print ("* [%s] %s" % (files_info[key]['lan'],key))
   print

## Collecting data from files #################################################

# Data to collect:
# * Inside of which LIBRARY is each PACKAGE.
# * Inside of which PACKAGE is each COMPONENT.
# * In which FILE is defined each COMPONENT and PACKAGE.
# * In which FILE is defined each MODULE.
# Warnings:
# * A file could contain more than a PACKAGE, COMPONENT or MODULE.
# * There may be repeated names!
#   * More than one LIBRARY can contain PACKAGEs with the same name (the same
#     PACKAGE name can be on more than one library).

knownlibs = ["ieee", "std", "unisim"]
cnt = 1

lib_pkg  = []
file_pkg = []
file_com = []
pkg_com  = []

todo     = []
done     = []

if (options.verbose):
   print ("Collecting data from files...")

for file in files:
    data = open(file, 'r').read()
    # Searching LIBRARYs and PACKAGEs on lines such as:
    # use LIBRARY.PACKAGE.xyz;
    match = re.findall('use\s+(.+)\.(.+)\..+;', data, re.IGNORECASE)
    for lib,pkg in match:
        if lib.lower() not in knownlibs:
           lib_pkg.append([lib, pkg])
    # Searching names of PACKAGEs and FILEs which include them:
    # package PACKAGE is
    match = re.findall('package\s+(.+)\s+is', data, re.IGNORECASE)
    for pkg in match:
        file_pkg.append([file,pkg])
        # Searching COMPONENTs inside PACKAGEs:
        # component COMPONENT is
        match = re.findall('component\s+(.+)\s+is', data, re.IGNORECASE)
        for com in match:
            pkg_com.append([pkg,com])
    # Searching names of ENTITYs and FILEs which include them:
    # entity ENTITY is
    match = re.findall('entity\s+(.+)\s+is', data, re.IGNORECASE)
    for ent in match:
        file_com.append([file,ent])
    #
    cnt+=1
    if cnt%5==0 and options.verbose:
       print ("%4d of %4d files were processed" % (cnt,qty))

lib_pkg_clean = []
for values in lib_pkg:
    if values not in lib_pkg_clean:
       lib_pkg_clean.append(values)
lib_pkg = lib_pkg_clean

if (options.verbose):
   print ("%4d of %4d files were processed" % (qty,qty))
   print ("lib_pkg:")
   for lib,pkg in lib_pkg:
      print ("* Package '%s' in library '%s'" % (pkg,lib))
   print ("file_pkg:")
   for file,pkg in file_pkg:
      print ("* Package '%s' in file '%s'" % (pkg,file))
   print ("pkg_com:")
   for pkg,com in pkg_com:
      print ("* Component '%s' in package '%s'" % (com,pkg))
   print ("file_com:")
   for file,com in file_com:
      print ("* Component '%s' in file '%s'" % (com,file))
   print

###############################################################################

def file_of_pkg(looking_for):
    #TODO: ask for help when PKG appears on more than a FILE
    for file,pkg in file_pkg:
        if looking_for.lower()==pkg.lower():
           return file

def file_of_com(looking_for):
    #TODO: ask for help when COM appears on more than a FILE
    for file,com in file_com:
        if looking_for.lower()==com.lower():
           return file

def check_if_processed(looking_for):
    if looking_for in todo or looking_for in done:
       return True
    else:
       return False

###############################################################################

if options.verbose:
   print ("Finding project files...")

## Using the TOP FILE to find all the involved FILES
todo.append(options.top)

while len(todo) > 0:
   file = todo.pop(0)
   done.append(file)
   if options.verbose:
      print ("Analyzing %s" %(file))
   data = open(file, 'r').read();
   #TODO: delete comments
   # Searching used PACKAGEs
   match = re.findall('use\s+(.+)\.(.+)\..+;', data, re.IGNORECASE)
   for lib,pkg in match:
       if lib.lower() not in knownlibs:
          file_next = file_of_pkg(pkg)
          if not check_if_processed(file_next):
             if options.verbose:
                print ("* pkg '" + pkg + "' in file '" + file_next + "'")
             todo.append(file_next)
   # Searching used ENTITYs
   # The instantiation line could be:
   # LABEL : ENTITY  or LABEL : entity library.ENTITY [(architecture)]
   # Next line must have generic or port map
   match = re.findall(':[\s\w]*\.(\w*)|:\s+(\w*)[\n\r\s\w]*map', data, re.IGNORECASE)
   for coms in match:
       for com in coms:
           if com:
             file_next = file_of_com(com)
             if not check_if_processed(file_next):
                if options.verbose:
                   print ("* com '" + com + "' in file '" + file_next + "'")
                todo.append(file_next)
#   undef $work;
#   $work = $pkg2lib{$file2some{$file}};
#   $work = $pkg2lib{$com2pkg{$file2some{$file}}} if (!$work);
#   $work = "work" if (!$work);
#   unshift(@prj_files,"vhdl $work $file") if ($tool eq 'ise');
#   unshift(@prj_files,"set_global_assignment -name VHDL_FILE $file -library $work")
#      if ($tool eq 'quartus2');
if options.verbose:
   print ("Done")
   print

done.reverse()
print done

#foreach $prj_file (@prj_files) {
#   $text .= "$prj_file\n";
#}

#($name = basename($top)) =~ s/\.[^.]+$//;
#$file  = "$name.prj";
#open(FILE, ">$file") or printError("Failed to create $file.");
#print FILE $text;
#close FILE;

#print join(" \\\n",@done);
