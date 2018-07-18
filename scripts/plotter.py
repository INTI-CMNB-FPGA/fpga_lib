#!/usr/bin/python
#
# Graph
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

options = parser.parse_args()

## Parsing the command line ###################################################

data = np.loadtxt(options.filename)

plot.plot(data)

plot.xlabel(options.xlabel)
plot.ylabel(options.ylabel)

plot.show()
