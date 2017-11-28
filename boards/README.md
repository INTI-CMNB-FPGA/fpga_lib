# Board support files

YAML files in this directory are used to generates constraints files using scripts/boardfiles.py.

There is a commented example in template.txt.

## ISE - User Constraints File (UCF)

Features:
* Case sensitive.
* Each statement is terminated by a semicolon (;).
* Begin each comment line with a pound (#) sign.
* Statements need not be placed in any particular order.
* Enclose NET and INST names in double quotes (recommended but not mandatory).
* Enclose inverted signal names that contain a tilde (for example, ~OUTSIG1) in double quotes (mandatory).
* You can enter multiple constraints for a given instance.

Example of clock constraint:
```
NET "port" TNM_NET = "port";
TIMESPEC "TS_port" = PERIOD "port" period;
```

Examples of location constraint:
```
NET "port" LOC="pin" | IOSTANDARD=standard | SLEW=slew | DRIVE=drive | pull ;
```

Where:
* port: port name in the source code. It could be also "port[x]" for a particular bit in a vector.
* period: value expresed in nano seconds with up to three decimals.
* pin: pin name.
* standard: standard name.
* slew: FAST|SLOW
* drive: 2, 4, 6, 8, 12 (default), 16, 24
* pull: PULLUP | PULLDOWN

## Vivado - Xilinx Design Constraints (XDC)

Features:
* Tcl commands that the Vivado Tcl interpreter sequentially reads and parses.
* Begin each comment line with a pound (#) sign.
* Are based on the standard Synopsys Design Constraints (SDC) format.
* The clocks must be created before they can be used by any subsequent constraints.

Example of clock constraint:
```
create_clock -period period [get_ports port]
```

Examples of location constraint:
```
set_property PACKAGE_PIN pin [get_ports port]
set_property PULLTYPE pull [get_ports port]
set_property IOSTANDARD standard [get_ports port]
set_property SLEW slew [get_ports port]
set_property DRIVE drive [get_ports port]
```

See **where** in UCF.

## Quartus

* Timing constraints used in analysis by the Quartus II TimeQuest Timing Analyzer are stored in .sdc files.
* Locate pins in .qsf file.

Example of clock constraint:
```
create_clock -period period port
```

Examples of location constraint:
```
set_location_assignment PIN_G21 -to eth_tx_q[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to eth_rx_c
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to e[0]
set_instance_assignment -name SLEW_RATE 2 -to e[0]
```
