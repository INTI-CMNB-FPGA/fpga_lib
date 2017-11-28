#!/usr/bin/make

ODIR=../temp

bin:
	make -C mems     bin
	make -C numeric  bin
	make -C simul    bin
	make -C sync     bin
	make -C verif    bin

clean-all:
	rm -fr $(ODIR)

VHDLS  = $(wildcard              \
          ../vhdl/mems/*.vhdl    \
          ../vhdl/numeric/*.vhdl \
          ../vhdl/simul/*.vhdl   \
          ../vhdl/sync/*.vhdl    \
          ../vhdl/verif/*.vhdl)
FILES  = $(subst ../vhdl/,,$(VHDLS))
FILES := $(basename $(FILES))

vhd2vl:
	@mkdir -p mems numeric simul sync verif
	@$(foreach FILE,$(FILES), echo "##### FROM ../vhdl/$(FILE).vhdl TO $(FILE).v"; \
	vhd2vl --quiet ../vhdl/$(FILE).vhdl $(FILE).v;iverilog -Wall -t null $(FILE).v;)
