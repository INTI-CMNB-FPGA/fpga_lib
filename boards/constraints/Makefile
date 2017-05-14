#!/usr/bin/make

PYTHON=python3
SCRIPT=../../scripts/boardfiles.py

YAML=$(wildcard ../*.yaml)

all:
	@$(foreach FILE,$(YAML),$(PYTHON) $(SCRIPT) $(FILE);)
