#!/usr/bin/python
#
# Plotter
#
# Authors:
# * Bruno Valinoti
# * Rodrigo A. Melo
#
# Copyright (c) 2018 Authors and INTI
# Distributed under the BSD 3-Clause License
#

import numpy as np
import matplotlib.pyplot as plot
import matplotlib as mpl
import argparse, sys

## Parsing the command line ###################################################

version = 'Plotter v1.0'

parser = argparse.ArgumentParser(
   description='A simple data plotter.'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   'filename',
   metavar='FILENAME',
   nargs='+',
   help=''
)

parser.add_argument(
   '-x','--xlabel',
   metavar='XLABEL',
   default='Sample'
)

parser.add_argument(
   '-y','--ylabel',
   metavar='YLABEL',
   default='Value'
)

parser.add_argument(
   '-p','--points',
   action='store_true'
)

parser.add_argument(
   '-c','--circles',
   action='store_true'
)

parser.add_argument(
   '-l','--linewidth',
   metavar='1',
   default='1',
   type=int
)

options = parser.parse_args()

## Parsing the command line ###################################################

plot.xlabel(options.xlabel)
plot.ylabel(options.ylabel)

#print(mpl.rcParams.keys())
mpl.rcParams['lines.linewidth'] = options.linewidth
if options.points or options.circles:
   mpl.rcParams['lines.linestyle'] = None
if options.points:
   mpl.rcParams['lines.marker'] = '.'
if options.circles:
   mpl.rcParams['lines.marker'] = 'o'

for file in options.filename:
    data = np.loadtxt(file)
    plot.plot(data)

plot.show()
