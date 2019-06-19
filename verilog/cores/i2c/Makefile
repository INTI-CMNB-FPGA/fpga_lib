#!/usr/bin/make

ODIR=../../../temp
SDIR=.
TDIR=testbench
FLAGS= -I$(SDIR) -y$(SDIR) -I$(TDIR) -y$(TDIR)

vpath %.o $(ODIR)
vpath %.v $(SDIR)
vpath %.v $(TDIR)
vpath %.vcd $(ODIR)

%.o: %.v

%: %.v
	@mkdir -p $(ODIR)
	iverilog $(FLAGS) -o $(ODIR)/$@ $<
	./$(ODIR)/$@ #-lxt2
	@mv *.vcd $(ODIR)
	gtkwave $(ODIR)/$@.vcd

view_%: %.vcd
	gtkwave $< &

bin:
test: i2c_slave_tb

clean:
	@rm -fr $(ODIR)/*.o $(ODIR)/*.vcd
