# FPGA Lib

Library of HDL snippets (such as cores, procedures and functions) and Tcl scripts, commonly shared
between FPGA projects.
You can read [vhdl/README.md](vhdl/README.md) and [tcl/README.md](tcl/README.md) for more details.

This project is mainly developed and mantained by the *FPGA team* of the
*Centre of Nano and Microelectronics* [CMNB](http://www.inti.gob.ar/microynanoelectronica/)
of the *National Institute of Industrial Technology* [INTI](http://www.inti.gob.ar/).
Contributions are welcome.

* We try to develop portable code to be vendor independant.
* The main used HDL language is VHDL (93) and we use [GHDL](http://ghdl.free.fr/) to simulate.
* Verilog (2001) code and iVerilog (Icarus) support will be added.
* Instead of run a lot of different programs from command line, we prefer Tcl because is a
  programming language shared between vendors tools.
* Documentation is under construction.

## License

FPGA Lib as project and the Software part (Tcl and Python scripts) are licensed under the GPL 3.
HDL code is licensed under the BSD 3-clause.
See [LICENSE](LICENSE) and [LICENSE-BSD](LICENSE-BSD) for details.
