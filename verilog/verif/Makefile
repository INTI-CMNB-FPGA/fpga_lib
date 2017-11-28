#!/usr/bin/make

ODIR=../../temp

bin:
	mkdir -p $(ODIR)
	iverilog -o $(ODIR)/blink.o blink.v
	iverilog -o $(ODIR)/loopcheck.o loopcheck.v
