# Synthesis test

* The content of this directory is useful to test if the memories are synthesizable and its results.
* It uses fpga_helpers, so it which must be present at the same level of fpga_lib.
* Vendor tools must be ready to use (added to the system path and with a valid license well
configured).
* Use ```make``` to do synthesis with each vendor tool. A *TOOL_report* file is generated.
* Delete reports with ```make clean-report```.
