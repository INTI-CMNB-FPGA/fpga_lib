#!/usr/bin/python
#
# Randomize
#
# Author: Rodrigo A. Melo
#
# Copyright (c) 2016 Author and INTI
# Distributed under the BSD 3-Clause License
#

import argparse, random

## Parsing the command line ###################################################

version = 'Randomize v1.0'

parser = argparse.ArgumentParser(
   description='Generate random binaries with configurable number of lines, ' +
               'columns and their widths.'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   '-l', '--lines',
   metavar='NUM_OF_LINES',
   type=int,
   default=1000,
   help='Number of lines to be generated [1000].'
)

parser.add_argument(
   '-w', '--width',
   metavar='NUM_OF_BITS',
   action='append',
   help='Number of bits of each column [8]. Can be used several times to ' +
        'specify more than one column.'
)

parser.add_argument(
   '-s', '--seed',
   metavar='SEED',
   type=int,
   default=0,
   help='Seed for the random number generator [0].'
)
options = parser.parse_args()

if options.width is None:
   options.width = ['8']

## Randomize ##################################################################

random.seed(options.seed)
for line in range(0,options.lines):
    aux = []
    for width in options.width:
        aux.append("".join(str(random.randint(0,1)) for i in range(0,int(width))))
    print (" ".join(aux))

