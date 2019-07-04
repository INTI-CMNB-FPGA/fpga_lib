# VHDL Library

* To analyze and generate the library using ghdl: `$ make`
* To run tests: `$ make test`
* To delete generated files: `$ make clean-all`
* GHDL flag: `-P<PATH_TO_FPGALIB_TEMP_DIR>`
* To be used on VHDL descriptions (include only what you need):
```
library FPGALIB;
use FPGALIB.Mems.all;    -- Memories to be infered as hard blocks.
use FPGALIB.Numeric.all; -- Numerical conversions and mathematical functions.
use FPGALIB.Simul.all;   -- Cores, procedures and functions for simulation.
use FPGALIB.Sync.all;    -- Cores for synchronism.
use FPGALIB.Verif.all;   -- Cores for hardware verification.
```
