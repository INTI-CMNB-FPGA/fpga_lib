#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: sync_pkg.o ffchain.o divider.o boundary.o debounce.o syncClockDomains.o
test: run_ffchain_tb run_boundary_tb

pre:
	make -C ../simul bin

ffchain_tb.o: pre sync_pkg.o ffchain.o
syncClockDomains.o: sync_pkg.o
boundary_tb.o: sync_pkg.o boundary.o

run_ffchain_tb: ffchain_tb
run_boundary_tb: boundary_tb
