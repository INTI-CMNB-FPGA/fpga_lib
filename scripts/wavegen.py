#!/usr/bin/python
#
# Waveforms generator
#
# Author: Rodrigo A. Melo
#
# Copyright (c) 2019 Author and INTI
# Distributed under the BSD 3-Clause License
#

import argparse
import numpy as np
import matplotlib.pyplot as plot
import sys

## Parsing the command line ###################################################

version = 'Waveforms generator v0.1'

parser = argparse.ArgumentParser(
   description='Generates values of a waveform (BIN, DEC).'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   '-w', '--width',
   metavar='BITS',
   type=int,
   default=8,
   help='BITS per ROW [8].'
)

parser.add_argument(
   '-f', '--function',
   metavar='FUNCTION',
   default='sin',
   choices=['sine'],
   help='Function used to generate the values [sin].'
)

parser.add_argument(
   '-s', '--samples',
   metavar='SAMPLES',
   type=int,
   default=50,
   help='Samples per cycle (fs/f for periodical functions) [50].'
)

parser.add_argument(
   '-c', '--cycles',
   metavar='CYCLES',
   type=int,
   default=1,
   help='Quantity of cycles.'
)

parser.add_argument(
   '-a', '--amplitude',
   metavar='AMPLITUDE',
   type=int,
   default=1,
   help='Peak-amplitude [1].'
)

parser.add_argument(
   '-o', '--offset',
   metavar='OFFSET',
   type=int,
   default=0,
   help='Offset [0].'
)

parser.add_argument(
   '-t', '--type',
   metavar='TYPE',
   default='bin',
   choices=['bin', 'dec'],
   help='Type of generated values [bin].'
)

options = parser.parse_args()

width     = options.width
function  = options.function
samples   = options.samples
cycles    = options.cycles
amplitude = options.amplitude
offset    = options.offset
type      = options.type

#if (amplitude + offset) > ((2**width)/2):
#   sys.exit("The amplitud can't be represented with the selected quantity of bits (%d)" % width)

get_sin = lambda x : amplitude * np.sin(2 * np.pi * x / samples) + offset
get_bin = lambda x : format(x, 'b').zfill(width)

x = np.linspace(0, samples * cycles, samples * cycles)

#plot.plot(x, get_sin(x))
#plot.show()

for value in x:
    y = int(get_sin(value))
    if type == 'dec':
       print("%d" % y)
    if type == 'bin':
       print("%s" % (get_bin(y)))
