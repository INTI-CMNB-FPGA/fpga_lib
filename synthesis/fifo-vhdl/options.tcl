fpga_device   xc7a100t-3-csg324                      -tool vivado
fpga_device   XC6SLX9-2-CSG324                       -tool ise
fpga_device   5CGXFC7C7F23C8                         -tool quartus
fpga_device   M2S090TS-1-fg484                       -tool libero

fpga_file     ../../vhdl/numeric/numeric_pkg.vhdl    -lib FPGALIB
fpga_file     ../../vhdl/sync/sync_pkg.vhdl          -lib FPGALIB
fpga_file     ../../vhdl/sync/ffchain.vhdl           -lib FPGALIB
fpga_file     ../../vhdl/sync/gray_sync.vhdl         -lib FPGALIB
fpga_file     ../../vhdl/mems/mems_pkg.vhdl          -lib FPGALIB
fpga_file     ../../vhdl/mems/SimpleDualPortRAM.vhdl -lib FPGALIB
fpga_file     ../../vhdl/mems/FIFO.vhdl              -lib FPGALIB
fpga_file     top.vhdl                               -top Top
