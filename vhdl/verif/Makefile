#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: blink.o transloop.o
test: run_loopcheck_tb run_transloop_tb

pre:
	make -C ../simul bin

transloop.o: verif_pkg.o loopcheck.o

loopcheck_tb.o: pre verif_pkg.o loopcheck.o
transloop_tb.o: pre transloop.o

run_loopcheck_tb: loopcheck_tb
run_transloop_tb: transloop_tb
