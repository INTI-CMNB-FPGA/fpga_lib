#!/usr/bin/make

ODIR=../../temp
LIB=fpgalib
LIBS=../../temp
STANDALONE=1
include ../../makes/ghdl.mk

bin: boundary.o debounce.o syncClockDomains.o
test: run_boundary_tb

syncClockDomains.o: sync_pkg.o
boundary_tb.o: sync_pkg.o boundary.o

run_boundary_tb: boundary_tb
