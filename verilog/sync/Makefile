#!/usr/bin/make

ODIR=../../temp

bin:
	mkdir -p $(ODIR)
	iverilog -o $(ODIR)/boundary.o boundary.v
	iverilog -o $(ODIR)/ffchain.o ffchain.v
	iverilog -o $(ODIR)/gray_sync.o gray_sync.v
