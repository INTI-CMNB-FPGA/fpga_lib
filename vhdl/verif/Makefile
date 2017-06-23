#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: blink.o transloop.o
test: run_loopcheck_tb run_transloop_tb

simul_pkg.o:
	make -C ../simul bin

transloop.o: verif_pkg.o loopcheck.o

loopcheck_tb.o: simul_pkg.o verif_pkg.o loopcheck.o
transloop_tb.o: simul_pkg.o transloop.o

run_loopcheck_tb: loopcheck_tb
run_transloop_tb: transloop_tb
