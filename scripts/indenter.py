#!/usr/bin/python
#
# Indenter
#
# Author: Rodrigo A. Melo
#
# Copyright (c) 2019 Author and INTI
# Distributed under the BSD 3-Clause License
#

from __future__ import print_function
import argparse, re, sys

## Parsing the command line ###################################################

version = 'Indenter v0.1 (WIP)'

parser = argparse.ArgumentParser(
   description='Indents an HDL file.'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

options = parser.parse_args()

## Compute ####################################################################

file = sys.stdin.read()

file = re.sub('\t'     ,'   ' , file, 0)      # Replaces a tab by three spaces
file = re.sub(' +$'    ,''    , file, 0,re.M) # Removes trailing spaces
file = re.sub('\n\n\n+','\n\n', file, 0)      # Replaces two or more empty lines by one
file = re.sub('\n*$'   ,''    , file, 0)      # Removes new-lines at the end of the file

print(file)
