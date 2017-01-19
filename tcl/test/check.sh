#!/bin/sh
echo "Checking cores with ghdl"
mkdir -p temp
ghdl -a --work=LIB_NAME --workdir=temp core_file.vhdl
ghdl -a --work=LIB_NAME --workdir=temp package_file.vhdl
ghdl -a -Ptemp          --workdir=temp top_file.vhdl
echo "Done"

echo "Checking ISE"
make TOOL=ise run > ise_output

echo "Checking Vivado"
make TOOL=vivado run > vivado_output

echo "Checking Quartus"
make TOOL=quartus run > quartus_output

echo "Checking Libero"
make TOOL=libero run > libero_output

echo "Deleting generated files"
rm -fr temp
make clean-multi

echo "Done"
