# Tcl scripts to use in a vendor independent way

All the vendors tools supports Tcl (*Tool Command Language*) scripting, with additional own commands.
Here we try to provide scripts for synthesis, implementation, bitstream generation and programming
in a vendor independent way.

Additionally, we provides a Makefile to invoke the Tcl interpreter in the manner and with the
arguments needed.

## Supported tools:

| Tool                   | Newest version where tested | Supported target devices | Supported cables            |
|------------------------|-----------------------------|--------------------------|-----------------------------|
| ISE (Xilinx)           | 14.7 <sup>*</sup>           | fpga, spi, bpi           | auto detected by Impact     |
| Vivado (Xilinx)        | 2016.4                      | fpga                     | auto detected by HW manager |
| Quartus (Intel/Altera) | 15.0                        | fpga                     | Usb-Blaster                 |
| Libero-SoC (Microsemi) | 11.7                        | fpga                     | FlashPro5 in spi_slave mode |

<sup>*</sup> The last version of the tool. It was discontinued.

## Files

### synthesis.tcl

* It automatically detect the vendor Tcl interpreter.
* The task to be executed can be specified with the `-task` argument. Possible values are:
  * `syn`: for logical synthesis.
  * `imp`: for implementation (technology mapping, place & route, timing verification).
  * `bit`: [default] for bitstream generation.
* If a vendor tool project file exists, it is used.
  * You can make the project with the graphical interface of the vendor tool and use this script for synthesis.
* If a vendor tool project file does not exists:
  * File options.tcl is used to create a new project.
  * Functions *fpga_device* and *fpga_file* are provided to be used on options.tcl.
  * Predefined optimizations can be specified with the `-opt` argument.
    Possible values are: user (default, no optimization is used), area, power and speed.

### programming.tcl

* Most tool has not Tcl support for programming. We prepare text files and command to execute
  with Tcl and finnaly use `exec`.
* It automatically detect the vendor Tcl interpreter.
* The device to be programmed can be specified with the `-dev` argument. Possible values are:
  `fpga` (default), `spi` and `bpi`.
* Additional device options can be specified in options.tcl.
* The bistream *path/name* is specified with the `-bit` argument. **NOTE:** Libero uses the project file to find it.

### Makefile

* Each interpreter:
  * Has its own name and location.
  * Is called with different arguments.
  * Pass arguments to the Tcl script in a different form.
* The Makefile provides:
  * Calls to synthesis.tcl and programming.tcl, independently of the interpreter.
  * Targets to clean generated files.
  * Targets to run the interpreter console or open the GUI.
* The tool to use can be specified in the variable TOOL.
  Possible values are: ise, vivado, quartus and libero.
* The task to run can be specified in the variable TASK.
  For possible values see `-task` argument of synthesis.tcl.
* The optimization to use can be specified in the variable OPT.
  For possible values see `-opt` argument of synthesis.tcl.
* The device to be programmed can be specified in the variable DEV.
  For possible values see `-dev` argument of programming.tcl.
* The bitstream file is auto detected (when was generated).
* **NOTE:** the Makefile suppose that the vendor tool is well configured and ready to run
  (tool and dependencies installed, license enabled and tool added to the system path).

## How to use

* If you do not want a lot of copies of synthesis.tcl, programming.tcl and Makefile, you can create
  a simple Makefile to point where files are.
  Add *fpga_lib* as git submodule and point to *fpga_lib/tcl* to use the original and updated
  version, or make a local copy in your project. Example *Makefile*:
```Makefile
#!/usr/bin/make

# You can set here variables such as TOOL, TASK, OPT and DEV if you
# want to change the predefined values. Do it before the include.
TCLPATH=../../fpga_lib/tcl
include $(TCLPATH)/Makefile

# You can add here extra targets if you need.
```
* If you have plans to customize the Tcl scripts, make a local copy where you want to run it.
  Use the provided Makefile to add extra targets at the end.
* In both cases, if you want to create a new project instead of an existing, you need a file
  called options.tcl.

### Example of options.tcl

Simple version:
```
fpga_device "xc7a100t-3-csg324"

fpga_file "core_file.vhdl"      -lib "LIB_NAME"
fpga_file "package_file.vhdl"   -lib "LIB_NAME"
fpga_file "top_file.vhdl"       -top "TOP_NAME"

set fpga_pos  1
set spi_width 4
set spi_name  SPI_NAME
```

[Here](test/options.tcl) you have a full documented version to use as boilerplate.

### Examples

* Obtain help with:
```
make help
```
* Run synthesis with predefined values on variables:
```
make run
```
* Run synthesis changing values on variables:
```
make TOOL=vivado TASK=imp OPT=speed run
```
* Run programming with predefined values on variables:
```
make prog
```
* Run programming changing values on variables:
```
make TOOL=vivado DEV=spi prog
```
* To clean (```make help``` to see differences):
```
make clean
make clean-all
make clean-multi
```
