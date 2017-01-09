#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: SinglePortRAM.o SimpleDualPortRAM.o TrueDualPortRAM.o
test: run_mems_tb

pre:
	make -C ../simul bin

SinglePortRAM.o:     mems_pkg.o
SimpleDualPortRAM.o: mems_pkg.o
TrueDualPortRAM.o:   mems_pkg.o

mems_tb.o: pre SinglePortRAM.o SimpleDualPortRAM.o TrueDualPortRAM.o
run_mems_tb: mems_tb
