#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: cores_pkg.o delay.o divider.o
test: run_delay_tb

pre:
	make -C ../simul bin

delay_tb.o: pre cores_pkg.o delay.o
run_delay_tb: delay_tb
