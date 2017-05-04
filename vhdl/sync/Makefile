#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: sync_pkg.o delay.o divider.o boundary.o debounce.o syncClockDomains.o
test: run_delay_tb run_boundary_tb

pre:
	make -C ../simul bin

delay_tb.o: pre sync_pkg.o delay.o
syncClockDomains.o: sync_pkg.o
boundary_tb.o: sync_pkg.o boundary.o

run_delay_tb: delay_tb
run_boundary_tb: boundary_tb
