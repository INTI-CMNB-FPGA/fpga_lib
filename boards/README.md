# Board support files

YAML files in this directory are used to:
* Generates constraints files using scripts/boardfiles.py
* As preconfigured values to use with fpga_helpers

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
NET "clk" TNM_NET = "clk";
TIMESPEC "TS_clk" = PERIOD "clk" 6.67;
```

Examples of net constraint:
```
NET signal_name    LOC=P53;
NET signal_name    LOC=P53 | IOSTANDARD=LVPECL33 | SLEW=FAST | DRIVE=12 | PULLUP ;
NET signal_name[0] LOC=P53 | IOSTANDARD=LVPECL33 | SLEW=FAST | DRIVE=12;
```
