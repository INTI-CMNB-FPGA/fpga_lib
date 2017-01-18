#!/usr/bin/python
#
# Randomize
# Copyright (C) 2016 INTI
# Copyright (C) 2016 Rodrigo A. Melo <rmelo@inti.gob.ar>
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

