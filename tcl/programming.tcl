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
catch {get_environment_info -operating_system;  set FPGA_TOOL "quartus"}
catch {defvar_set -name "FORMAT" -value "VHDL"; set FPGA_TOOL "libero"}

if { $FPGA_TOOL=="Unknown" } {
   puts "ERROR: undetected vendor tool.\n"
   exit 1
}

set TEMPDIR "temp-$FPGA_TOOL"

###############################################################################
# Parsing the command line
###############################################################################

if { $FPGA_TOOL=="libero" } {
   # See synthesis.tcl for an explanation about that.
   lappend auto_path [info library]/../../../Model/modeltech/tcl/tcllib1.12/cmdline
}

package require cmdline

set parameters {
    {bit.arg  "BITSTREAM" "BitStream File"}
    {dev.arg  "fpga"      "DEVice [fpga, spi, bpi, xcf]"}
}

set usage "- A Tcl script to run programming with a supported Vendor Tool"
if {[catch {array set options [cmdline::getoptions ::argv $parameters $usage]}]} {
   puts [cmdline::usage $parameters $usage]
   exit 1
}

set ERROR ""

if {
    $options(dev)!="fpga"   && $options(dev)!="spi"    &&
    $options(dev)!="bpi"    && $options(dev)!="xcf"    &&
    $options(dev)!="detect" && $options(dev)!="unlock"
   } {
   append ERROR "<$options(dev)> is not a supported DEVice.\n"
}

if {$ERROR != ""} {
   puts $ERROR
   puts "Use -help to see available options.\n"
   exit 1
}

set DEV $options(dev)

set bitstream $options(bit)
set name      [file rootname [file tail $bitstream]]

###############################################################################
# Functions
###############################################################################

# Dummy functions (appears on options.tcl)
proc fpga_device {FPGA {KEY ""} {VALUE ""}} {}
proc fpga_file   {FILE {KEY ""} {VALUE ""}} {}

#
# writeFile
#
proc writeFile {PATH DATA} {set fp [open $PATH w];puts $fp $DATA;close $fp}

###############################################################################
# Getting data from options.tcl
###############################################################################

set fpga_pos  1
set spi_width 1
set spi_name  "SPINAME"
set bpi_width 8
set bpi_name  "BPINAME"
set xcf_name  "XCFNAME"

if {[catch { source options.tcl } ERRMSG]} {
   puts "ERROR: there was a problem openning options.tcl.\n"
   puts $ERRMSG
   exit 1
}

###############################################################################
# Text for files
###############################################################################

# Impact (ISE)

set impact_fpga "setMode -bs
setCable -port auto
Identify -inferir
assignFile -p $fpga_pos -file $bitstream
Program -p $fpga_pos"

set impact_spi "setMode -bs
setCable -port auto
Identify
attachflash -position $fpga_pos -spi $spi_name
assignfiletoattachedflash -position $fpga_pos -file $TEMPDIR/$name.mcs
Program -p $fpga_pos -dataWidth $spi_width -spionly -e -v -loadfpga"

set impact_spi_mcs "setMode -pff
addConfigDevice -name $name -path $TEMPDIR
setSubmode -pffspi
addDesign -version 0 -name 0
addDeviceChain -index 0
addDevice -p 1 -file $bitstream
generate -generic"

set impact_bpi "setMode -bs
setCable -port auto
Identify
attachflash -position $fpga_pos -bpi $bpi_name
assignfiletoattachedflash -position $fpga_pos -file $TEMPDIR/$name.mcs
Program -p $fpga_pos -dataWidth $bpi_width -rs1 NONE -rs0 NONE -bpionly -e -v -loadfpga"

set impact_bpi_mcs "setMode -pff
addConfigDevice -name $name -path $TEMPDIR
setSubmode -pffbpi
addDesign -version 0 -name 0
addDeviceChain -index 0
setAttribute -configdevice -attr flashDataWidth -value $bpi_width
addDevice -p 1 -file $bitstream
generate -generic"

set impact_xcf_mcs "setMode -pff
addConfigDevice -name $name -path $TEMPDIR
setSubmode -pffversion
addDesign -version 0 -name 0
addDeviceChain -index 0
addPromDevice -p 1 -name $xcf_name
addDevice -p 1 -file $bitstream
generate"

set impact_detect "setMode -bs
setCable -port auto
Identify -inferir"

set impact_unlock "cleancablelock"

# FlashPro (Microsemi)

set flashpro_fpga "open_project -file {$TEMPDIR/libero.prjx}
run_tool -name {CONFIGURE_CHAIN} -script {$TEMPDIR/flashpro.tcl}
run_tool -name {PROGRAMDEVICE}"

set mode spi_slave
set flashpro_programmer "configure_flashpro5_prg -vpump {ON} \
-clk_mode {free_running_clk} -programming_method {$mode} \
-force_freq {OFF} -freq {4000000}"

###############################################################################
# Programming
###############################################################################

puts "Starting Programming.
This operation may take several minutes, please be patient.
Final result will be displayed when process ended."

if {[catch {
   file mkdir $TEMPDIR
   switch $FPGA_TOOL {
      "ise" { # ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE
         writeFile $TEMPDIR/fpga   "$impact_fpga\nquit"
         writeFile $TEMPDIR/spi    "$impact_spi_mcs\n$impact_spi\nquit"
         writeFile $TEMPDIR/bpi    "$impact_bpi_mcs\n$impact_bpi\nquit"
         writeFile $TEMPDIR/xcf    "$impact_xcf_mcs\nquit"
         writeFile $TEMPDIR/detect "$impact_detect\nquit"
         writeFile $TEMPDIR/unlock "$impact_unlock\nquit"
         #
         set lib "/usr/lib/libusb-driver.so"
         if { [ file exists $lib ] } {
            set ::env(LD_PRELOAD) $lib
         }
         exec impact -batch $TEMPDIR/$DEV &
      }
      "vivado" { # Vivado Vivado Vivado Vivado Vivado Vivado Vivado Vivado
         open_hw
         connect_hw_server
         open_hw_target
         set obj [lindex [get_hw_devices [current_hw_device]] 0]
         set_property PROGRAM.FILE $bitstream $obj
         program_hw_devices $obj
      }
      "quartus" { # Quartus Quartus Quartus Quartus Quartus Quartus Quartus
         exec jtagconfig
         exec quartus_pgm -c USB-blaster --mode jtag -o "p;$bitstream@$fpga_pos"
      }
      "libero" { # Libero Libero Libero Libero Libero Libero Libero Libero
         writeFile $TEMPDIR/fpga.tcl     "$flashpro_fpga"
         writeFile $TEMPDIR/flashpro.tcl "$flashpro_programmer"
         #
         exec libero SCRIPT:$TEMPDIR/fpga.tcl
      }
   }
} ERRMSG]} {
   puts $ERRMSG
}
