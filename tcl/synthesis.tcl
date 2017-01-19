#
# Synthesis
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
# Description: Tcl script to do synthesis, implementation and bitstream
# generation in a vendor independent way.
#
# To support a new tool:
# 1. Add detection.
# 2. Add support on fpga_device and fpga_files.
# 3. Add creation of a default project.
# 4. Add synthesis, implementation and bitstream generation commands.
#

###############################################################################
# Detecting the vendor tool
###############################################################################

global FPGA_TOOL
set FPGA_TOOL "Unknown"

# Strategy: set the value after catch a command only supported in the desired
# vendor tool.
catch {globals get display_type;                set FPGA_TOOL "ise"}
catch {list_features;                           set FPGA_TOOL "vivado"}
catch {get_environment_info -operating_system;  set FPGA_TOOL "quartus"}
catch {defvar_set -name "FORMAT" -value "VHDL"; set FPGA_TOOL "libero"}

if { $FPGA_TOOL=="Unknown" } {
   puts "ERROR: undetected vendor tool.\n"
   exit 1
}

###############################################################################
# Parsing the command line
###############################################################################

if { $FPGA_TOOL=="libero" } {
   # The package cmdline is not in the library directory of Libero-SoC's Tcl
   # interpreter (<LIBERO_ROOT_PATH>/Model/modeltech/tcl/tcllib1.12/cmdline)
   # info library: returns the name of the library directory in which standard
   # Tcl scripts are stored (<LIBERO_ROOT_PATH>/Libero/lib/tcl8.5)
   # $auto_path: is a list of directories used by package to find packages
   lappend auto_path [info library]/../../../Model/modeltech/tcl/tcllib1.12/cmdline
}

package require cmdline

set parameters {
    {task.arg "bit"    "TASK         [syn, imp, bit]"}
    {opt.arg  "user"   "OPTimization [user, area, power, speed]"}
}

set usage "- A Tcl script to run synthesis with a supported Vendor Tool"
if {[catch {array set options [cmdline::getoptions ::argv $parameters $usage]}]} {
   puts [cmdline::usage $parameters $usage]
   exit 1
}

set ERROR ""

if { $options(task)!="syn" && $options(task)!="imp" && $options(task)!="bit" } {
   append ERROR "<$options(task)> is not a supported TASK.\n"
}

if {
    $options(opt)!="user"  && $options(opt)!="area" &&
    $options(opt)!="power" && $options(opt)!="speed"
   } {
   append ERROR "<$options(opt)> is not a supported OPTimization.\n"
}

if {$ERROR != ""} {
   puts $ERROR
   puts "Use -help to see available options.\n"
   exit 1
}

set TASK $options(task)
set OPT  $options(opt)

###############################################################################
# Functions to use in options.tcl
###############################################################################

#
# fpga_device
#

proc fpga_device {FPGA {KEY ""} {VALUE ""}} {
   global FPGA_TOOL
   if {$KEY == "" || ($KEY=="-tool" && $VALUE==$FPGA_TOOL)} {
      switch $FPGA_TOOL {
         "ise" { # ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE
            regexp -nocase {(.*)(-.*)-(.*)} $FPGA -> device speed package
            set family "Unknown"
            if {[regexp -nocase {xc7a\d+l} $device]} {
               set family "artix7l"
            } elseif {[regexp -nocase {xc7a} $device]} {
               set family "artix7"
            } elseif {[regexp -nocase {xc7k\d+l} $device]} {
               set family "kintex7l"
            } elseif {[regexp -nocase {xc7k} $device]} {
               set family "kintex7"
            } elseif {[regexp -nocase {xc3sd\d+a} $device]} {
               set family "spartan3adsp"
            } elseif {[regexp -nocase {xc3s\d+a} $device]} {
               set family "spartan3a"
            } elseif {[regexp -nocase {xc3s\d+e} $device]} {
               set family "spartan3e"
            } elseif {[regexp -nocase {xc3s} $device]} {
               set family "spartan3"
            } elseif {[regexp -nocase {xc6s\d+l} $device]} {
               set family "spartan6l"
            } elseif {[regexp -nocase {xc6s} $device]} {
               set family "spartan6"
            } elseif {[regexp -nocase {xc4v} $device]} {
               set family "virtex4"
            } elseif {[regexp -nocase {xc5v} $device]} {
               set family "virtex5"
            } elseif {[regexp -nocase {xc6v\d+l} $device]} {
               set family "virtex6l"
            } elseif {[regexp -nocase {xc6v} $device]} {
               set family "virtex6"
            } elseif {[regexp -nocase {xc7v\d+l} $device]} {
               set family "virtex7l"
            } elseif {[regexp -nocase {xc7v} $device]} {
               set family "virtex7"
            } elseif {[regexp -nocase {xc7z} $device]} {
               set family "zynq"
            } else {
               puts "Family $family not supported."
               exit 1
            }
            project set family  $family
            project set device  $device
            project set package $package
            project set speed   $speed
         }
         "vivado" { # Vivado Vivado Vivado Vivado Vivado Vivado Vivado Vivado
            set_property "part" $FPGA [current_project]
         }
         "quartus" { # Quartus Quartus Quartus Quartus Quartus Quartus Quartus
            set_global_assignment -name DEVICE $FPGA
         }
         "libero" { # Libero Libero Libero Libero Libero Libero Libero Libero
            regexp -nocase {(.*)(-.*)-(.*)} $FPGA -> device speed package
            set family "Unknown"
            if {[regexp -nocase {m2s} $device]} {
               set family "SmartFusion2"
            } elseif {[regexp -nocase {m2gl} $device]} {
               set family "Igloo2"
            } elseif {[regexp -nocase {rt4g} $device]} {
               set family "RTG4"
            } elseif {[regexp -nocase {a2f} $device]} {
               set family "SmartFusion"
            } elseif {[regexp -nocase {afs} $device]} {
               set family "Fusion"
            } elseif {[regexp -nocase {aglp} $device]} {
               set family "IGLOO+"
            } elseif {[regexp -nocase {agle} $device]} {
               set family "IGLOOE"
            } elseif {[regexp -nocase {agl} $device]} {
               set family "IGLOO"
            } elseif {[regexp -nocase {a3p\d+l} $device]} {
               set family "ProAsic3L"
            } elseif {[regexp -nocase {a3pe} $device]} {
               set family "ProAsic3E"
            } elseif {[regexp -nocase {a3p} $device]} {
               set family "ProAsic3"
            } else {
               puts "Family $family not supported."
               exit 1
            }
            set_device -family $family -die $device -package $package -speed $speed
         }
      }
   }
}

#
# fpga_file
#

proc fpga_file {FILE {KEY ""} {VALUE ""}} {
   regexp -nocase {\.(\w*)$} $FILE -> ext
   if {$ext == "tcl"} {
      source $FILE
      return
   }
   if {$KEY!="" && $KEY!="-lib" && $KEY!="-top"} {
      puts "Valid options for fpga_file command are -lib and -top."
      exit 1
   }
   global FPGA_TOOL
   switch $FPGA_TOOL {
      "ise" { # ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE
         if {$KEY=="-lib"} {
            lib_vhdl new $VALUE
            xfile add $FILE -lib_vhdl $VALUE
         } else {
            xfile add $FILE
         }
         if {$KEY=="-top"} {
            project set top $VALUE
         }
      }
      "vivado" { # Vivado Vivado Vivado Vivado Vivado Vivado Vivado Vivado
         add_files $FILE
         if {$KEY=="-lib"} {
            set_property library $VALUE [get_files $FILE]
         }
         if {$KEY=="-top"} {
            set_property top $VALUE [current_fileset]
         }
      }
      "quartus" { # Quartus Quartus Quartus Quartus Quartus Quartus Quartus
         regexp -nocase {\.(\w*)$} $FILE -> ext
         if {$ext == "v"} {
            set TYPE VERILOG_FILE
         } elseif {$ext == "sv"} {
            set TYPE SYSTEMVERILOG_FILE
         } else {
            set TYPE VHDL_FILE
         }
         if {$KEY=="-lib"} {
            set_global_assignment -name $TYPE $FILE -library $VALUE
         } else {
            set_global_assignment -name $TYPE $FILE
         }
         if {$KEY=="-top"} {
            set_global_assignment -name TOP_LEVEL_ENTITY $VALUE
         }
      }
      "libero" { # Libero Libero Libero Libero Libero Libero Libero Libero
         regexp -nocase {\.(\w*)$} $FILE -> ext
         if {$ext == "pdc"} {
            create_links -io_pdc $FILE
            organize_tool_files -tool {PLACEROUTE} -file $FILE -input_type {constraint}
         } elseif {$ext == "sdc"} {
            create_links -sdc $FILE
            organize_tool_files -tool {SYNTHESIZE} -file $FILE -input_type {constraint} 
            organize_tool_files -tool {VERIFYTIMING} -file $FILE -input_type {constraint}
         } else {
            create_links -hdl_source $FILE
         }
         if {$KEY=="-lib"} {
            add_library -library $VALUE
            add_file_to_library -library $VALUE -file $FILE
         }
         if {$KEY=="-top"} {
            set_root $VALUE
         }
      }
   }
}

###############################################################################
# Create a project, based on options.tcl, if a custom project do not exists
###############################################################################

if {[catch {
   switch $FPGA_TOOL {
      "ise" { # ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE
         if { [ file exists ise.xise ] } { file delete ise.xise }
         set project_file [glob -nocomplain *.xise]
         if { $project_file != "" } {
            puts "There is a ISE project ($project_file)"
         } else {
            puts "Creating a new ISE project (ise.xise)"
            project new ise.xise
            switch $OPT {
               "area"  {
                  project set "Optimization Goal" "Area"
               }
               "power" {
                  project set "Optimization Goal" "Area"
                  project set "Power Reduction"   "true" -process "Synthesize - XST"
                  project set "Power Reduction"   "high" -process "Map"
                  project set "Power Reduction"   "true" -process "Place & Route"
               }
               "speed" {
                  project set "Optimization Goal" "Speed"
               }
            }
            source options.tcl
            project close
         }
      }
      "vivado" { # Vivado Vivado Vivado Vivado Vivado Vivado Vivado Vivado
         if { [ file exists vivado.xpr ] } { file delete vivado.xpr }
         set project_file [glob -nocomplain *.xpr]
         if { $project_file != "" } {
            puts "There is a Vivado project ($project_file)"
         } else {
            puts "Creating a new Vivado project (vivado.xpr)"
            create_project -force vivado
            switch $OPT {
               "area"  {
                  set obj [get_runs synth_1]
                  set_property strategy "Flow_AreaOptimized_high"                       $obj
                  set_property "steps.synth_design.args.directive" "AreaOptimized_high" $obj
                  set_property "steps.synth_design.args.control_set_opt_threshold" "1"  $obj
                  set obj [get_runs impl_1]
                  set_property strategy "Area_Explore"                                  $obj
                  set_property "steps.opt_design.args.directive" "ExploreArea"          $obj
               }
               "power" {
                  #enable power_opt_design and phys_opt_design
                  set obj [get_runs synth_1]
                  set_property strategy "Vivado Synthesis Defaults"                     $obj
                  set obj [get_runs impl_1]
                  set_property strategy "Power_DefaultOpt"                              $obj
                  set_property "steps.power_opt_design.is_enabled" "1"                  $obj
                  set_property "steps.phys_opt_design.is_enabled" "1"                   $obj
               }
               "speed" {
                  #enable phys_opt_design
                  set obj [get_runs synth_1]
                  set_property strategy "Flow_PerfOptimized_high"                       $obj
                  set_property "steps.synth_design.args.fanout_limit" "400"             $obj
                  set_property "steps.synth_design.args.keep_equivalent_registers" "1"  $obj
                  set_property "steps.synth_design.args.resource_sharing" "off"         $obj
                  set_property "steps.synth_design.args.no_lc" "1"                      $obj
                  set_property "steps.synth_design.args.shreg_min_size" "5"             $obj
                  set obj [get_runs impl_1]
                  set_property strategy "Performance_Explore"                           $obj
                  set_property "steps.opt_design.args.directive" "Explore"              $obj
                  set_property "steps.place_design.args.directive" "Explore"            $obj
                  set_property "steps.phys_opt_design.is_enabled" "1"                   $obj
                  set_property "steps.phys_opt_design.args.directive" "Explore"         $obj
                  set_property "steps.route_design.args.directive" "Explore"            $obj
               }
            }
            source options.tcl
            close_project
         }
      }
      "quartus" { # Quartus Quartus Quartus Quartus Quartus Quartus Quartus
         package require ::quartus::project
         if { [ file exists quartus.qpf ] } {file delete quartus.qpf}
         if { [ file exists quartus.qsf ] } {file delete quartus.qsf}
         set project_file [glob -nocomplain *.qpf]
         if { $project_file != "" } {
            puts "There is a Quartus project ($project_file)"
         } else {
            puts "Creating a new Quartus project (quartus.qpf)"
            project_new quartus -overwrite
            switch $OPT {
               "area"  {
                  set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE AREA"
                  set_global_assignment -name OPTIMIZATION_TECHNIQUE AREA
               }
               "power" {
                  set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE POWER"
                  set_global_assignment -name OPTIMIZE_POWER_DURING_SYNTHESIS "EXTRA EFFORT"
                  set_global_assignment -name OPTIMIZE_POWER_DURING_FITTING "EXTRA EFFORT"
               }
               "speed" {
                  set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
                  set_global_assignment -name OPTIMIZATION_TECHNIQUE SPEED
               }
            }
            source options.tcl
            project_close
         }
      }
      "libero" { # Libero Libero Libero Libero Libero Libero Libero Libero
         if { [ file exists temp-libero ] } { file delete -force -- temp-libero }
         set project_file [glob -nocomplain *.prjx]
         if { $project_file != "" } {
            puts "There is a Libero project ($project_file)"
         } else {
            puts "Creating a new Libero project (libero.prjx)"
            new_project -name "libero" -location {temp-libero} -hdl {VHDL} -family {SmartFusion2}
            switch $OPT {
               "area"  {
                   configure_tool -name {SYNTHESIZE} -params {RAM_OPTIMIZED_FOR_POWER:true}
               }
               "power" {
                   configure_tool -name {SYNTHESIZE} -params {RAM_OPTIMIZED_FOR_POWER:true}
                   configure_tool -name {PLACEROUTE} -params {PDPR:true}
               }
               "speed" {
                   configure_tool -name {SYNTHESIZE} -params {RAM_OPTIMIZED_FOR_POWER:false}
                   configure_tool -name {PLACEROUTE} -params {EFFORT_LEVEL:true}
               }
            }
            configure_tool -name {PLACEROUTE} -params {REPAIR_MIN_DELAY:true}
            source options.tcl
            close_project
         }
      }
   }
} ERRMSG]} {
   puts "ERROR: there was a problem creating a new project.\n"
   puts $ERRMSG
   exit 1
}

###############################################################################
# Synthesis, implementation and bitstream generation
###############################################################################

if {[catch {
   switch $FPGA_TOOL {
      "ise" { # ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE ISE
         project open [glob -nocomplain *.xise]
         if { $TASK=="syn" || $TASK=="imp" || $TASK=="bit" } {
            process run "Synthesize"                -force rerun
         }
         if { $TASK=="imp" || $TASK=="bit" } {
            process run "Translate"                 -force rerun
            process run "Map"                       -force rerun
            process run "Place & Route"             -force rerun
         }
         if { $TASK=="bit" } {
            process run "Generate Programming File" -force rerun
         }
         project close
      }
      "vivado" { # Vivado Vivado Vivado Vivado Vivado Vivado Vivado Vivado
         open_project [glob -nocomplain *.xpr]
         if { $TASK=="syn" || $TASK=="imp" || $TASK=="bit" } {
            reset_run synth_1
            launch_runs synth_1
            wait_on_run synth_1
         }
         if { $TASK=="imp" || $TASK=="bit" } {
            open_run synth_1
            launch_runs impl_1
            wait_on_run impl_1
         }
         if { $TASK=="bit" } {
            open_run impl_1
            launch_run impl_1 -to_step write_bitstream
            wait_on_run impl_1
         }
         close_project
      }
      "quartus" { # Quartus Quartus Quartus Quartus Quartus Quartus Quartus
         package require ::quartus::flow
         project_open -force [glob -nocomplain *.qpf]
         if { $TASK=="syn" || $TASK=="imp" || $TASK=="bit" } {
            execute_module -tool map
         }
         if { $TASK=="imp" || $TASK=="bit" } {
            execute_module -tool fit
            execute_module -tool sta
         }
         if { $TASK=="bit" } {
            execute_module -tool asm
         }
         project_close
      }
      "libero" { # Libero Libero Libero Libero Libero Libero Libero Libero
         set project_file [glob -nocomplain *.prjx]
         if { $project_file=="" } { set project_file [glob -nocomplain temp-libero/*.prjx] }
         open_project $project_file
         if { $TASK=="syn" || $TASK=="imp" || $TASK=="bit" } {
            run_tool -name {COMPILE}
         }
         if { $TASK=="imp" || $TASK=="bit" } {
            run_tool -name {PLACEROUTE}
            run_tool -name {VERIFYTIMING}
         }
         if { $TASK=="bit" } {
            run_tool -name {GENERATEPROGRAMMINGFILE}
         }
         close_project
      }
   }
} ERRMSG]} {
   puts "ERROR: there was a problem running $TASK.\n"
   puts $ERRMSG
   exit 1
}
