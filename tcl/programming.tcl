#
# Programming
#
# Copyright (C) 2016-2017 INTI
# Copyright (C) 2016-2017 Rodrigo A. Melo <rmelo@inti.gob.ar>
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
# Description: Tcl script to do programming in a vendor independent way.
#
# To support a new tool:
# 1. Add detection.
# 2. Add support for a new kind of device if needed.
# 3. Add programming process.
#

###############################################################################
# Detecting the vendor tool
###############################################################################

global FPGA_TOOL
set FPGA_TOOL "Unknown"

# See synthesis.tcl for an explanation about that.
catch {globals get display_type;                set FPGA_TOOL "ise"}
catch {list_features;                           set FPGA_TOOL "vivado"}
catch {get_environment_info -operating_system;  set FPGA_TOOL "quartus2"}
catch {defvar_set -name "FORMAT" -value "VHDL"; set FPGA_TOOL "libero-soc"}

if { $FPGA_TOOL=="Unknown" } {
   puts "ERROR: undetected vendor tool.\n"
   exit 1
}

###############################################################################
# Parsing the command line
###############################################################################

if { $FPGA_TOOL=="libero-soc" } {
   # See synthesis.tcl for an explanation about that.
   lappend auto_path [info library]/../../../Model/modeltech/tcl/tcllib1.12/cmdline
}

package require cmdline

set parameters {
    {dev.arg  "fpga"   "DEVice       [fpga, spi, bpi, xcf]"}
}

set usage "- A Tcl script to run programming with a supported Vendor Tool"
if {[catch {array set options [cmdline::getoptions ::argv $parameters $usage]}]} {
   puts [cmdline::usage $parameters $usage]
   exit 1
}

set ERROR ""

if {
    $options(dev)!="fpga" && $options(dev)!="spi" &&
    $options(dev)!="bpi"  && $options(dev)!="xcf"
   } {
   append ERROR "<$options(dev)> is not a supported DEVice.\n"
}

if {$ERROR != ""} {
   puts $ERROR
   puts "Use -help to see available options.\n"
   exit 1
}

set DEV  $options(dev)

###############################################################################
# Dummy Functions (appears on options.tcl)
###############################################################################

proc fpga_device {FPGA {KEY ""} {VALUE ""}} {}
proc fpga_file   {FILE {KEY ""} {VALUE ""}} {}

###############################################################################
# Getting data from options.tcl
###############################################################################

if {[catch { source options.tcl } ERRMSG]} {
   puts "ERROR: there was a problem openning options.tcl.\n"
   puts $ERRMSG
   exit 1
}

###############################################################################
# Programming
###############################################################################

if {[catch {
   switch $FPGA_TOOL {
      "ise" { # ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE
         puts "Coming soon."
      }
      "vivado" { # Vivado Vivado Vivado Vivado Vivado Vivado Vivado Vivado
         puts "Coming soon."
      }
      "quartus2" { # Quartus2 Quartus2 Quartus2 Quartus2 Quartus2 Quartus2
         puts "Coming soon."
      }
      "libero-soc" { # Libero-SoC Libero-SoC Libero-SoC Libero-SoC Libero-SoC
         puts "Coming soon."
      }
   }
} ERRMSG]} {
   puts "ERROR: there was a problem running programming.\n"
   puts $ERRMSG
   exit 1
}
