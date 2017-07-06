#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: counter.o
test: run_numeric_tb run_counter_tb

simul_pkg.o:
	make -C ../simul bin

counter.o: numeric_pkg.o

numeric_tb.o: simul_pkg.o numeric_pkg.o
counter_tb.o: simul_pkg.o numeric_pkg.o counter.o

run_numeric_tb: numeric_tb
run_counter_tb: counter_tb

see_ghw_counter_tb: counter_tb
