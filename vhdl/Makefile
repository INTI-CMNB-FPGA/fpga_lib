#!/usr/bin/make

ODIR=../temp

bin:
	make -C cores    bin
	make -C mems     bin
	make -C numeric  bin
	make -C simul    bin
	make -C sync     bin
	make -C verif    bin

test:
	make -C cores    test
	make -C mems     test
	make -C numeric  test
	make -C simul    test
	make -C sync     test
	make -C verif    test

clean-all:
	rm -fr $(ODIR)
