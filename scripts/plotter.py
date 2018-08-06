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

options = parser.parse_args()

## Parsing the command line ###################################################

plot.xlabel(options.xlabel)
plot.ylabel(options.ylabel)

for file in options.filename:
    data = np.loadtxt(file)
    if options.points:
       plot.plot(data, linestyle='', marker='.')
    elif options.circles:
       plot.plot(data, linestyle='', marker='o')
    else:
       plot.plot(data)

plot.show()
