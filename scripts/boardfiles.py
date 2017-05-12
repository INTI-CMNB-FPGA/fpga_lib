#!/usr/bin/python
#
# BoardFiles
# Copyright (C) 2015-2017 INTI
# Copyright (C) 2015-2017 Rodrigo A. Melo <rmelo@inti.gob.ar>
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

import argparse, yaml, os, sys

## Parsing the command line ###################################################

version = 'BoardFiles v1.0'

parser = argparse.ArgumentParser(
   description='Creates Constraints and Top Level HDL files based on a YAML file.'
)

parser.add_argument(
   '-v', '--version',
   action='version',
   version=version
)

parser.add_argument(
   'file',
   metavar='BOARDNAME.yaml',
   help='Input YAML file'
)

options = parser.parse_args()

## Processing the options #####################################################

if os.path.exists(options.file):
   board = yaml.load(open(options.file, 'r'))
else:
   sys.exit('BoardFiles (ERROR): file <' + options.file + '> not exists.')

filename = os.path.basename(options.file)
basename = os.path.splitext(filename)[0]
outdir   = basename
outfile  = outdir + "/" + basename + ".ucf"

pads     = board['pads']

comment  = "#"

## Functions ##################################################################

def put_comment(comment, data):
    text = ""
    if data:
       if type(data) is not list:
          data = [data]
       for doc in data:
           if doc:
              text += comment + " " + doc + "\n"
           else:
              text += comment + "\n"
    return text

def put_pad(comment, pad):
    return "%s%-20s : %s\n" % (comment, 'PAD_' + pad.upper(), str(pads[group][pad]))

## Main #######################################################################

text  = comment + "\n"
text += comment + " " + board['name'] + "\n"
text += comment + "\n"
text += put_comment(comment, pads['doc'])
text += comment + "\n"
text += put_comment(comment, "Note: uncomment what you want to use.")
text += comment + "\n"

for group in sorted(pads):
    if group != 'doc':
       text += comment + "\n"
       text += "%s %s:\n" % (comment, group)
       text += put_comment(comment,pads[group]['doc'])
       text += comment + "\n"
       for pad in sorted(pads[group]):
           if pad != 'doc':
              text += put_pad(comment, pad)

if not os.path.exists(outdir):
   os.makedirs(outdir)
open(outfile, 'w').write(text)

print ('BoardFiles (INFO): <' + outfile + '> was generated.')
