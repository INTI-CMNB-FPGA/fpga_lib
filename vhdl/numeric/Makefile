#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: numeric_pkg.o
test: run_numeric_tb

simul_pkg.o:
	make -C ../simul bin

numeric_tb.o: simul_pkg.o numeric_pkg.o
run_numeric_tb: numeric_tb
