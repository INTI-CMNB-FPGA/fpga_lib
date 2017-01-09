#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: simul_pkg.o clock.o
test: run_simul_tb

simul_tb.o: simul_pkg.o
run_simul_tb: simul_tb
