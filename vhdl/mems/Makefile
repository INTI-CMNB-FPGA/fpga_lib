#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: SinglePortRAM.o SimpleDualPortRAM.o TrueDualPortRAM.o FIFO_sync.o
test: run_mems_tb run_fifo_tb

numeric_pkg.o:
	make -C ../numeric bin

simul_pkg.o:
	make -C ../simul bin

SinglePortRAM.o:     mems_pkg.o
SimpleDualPortRAM.o: mems_pkg.o
TrueDualPortRAM.o:   mems_pkg.o
FIFO_sync.o:         mems_pkg.o numeric_pkg.o SimpleDualPortRAM.o

mems_tb.o: simul_pkg.o SinglePortRAM.o SimpleDualPortRAM.o TrueDualPortRAM.o
run_mems_tb: mems_tb

fifo_tb.o: simul_pkg.o FIFO_sync.o
run_fifo_tb: fifo_tb
see_ghw_fifo_tb: fifo_tb
