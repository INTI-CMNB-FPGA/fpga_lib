#!/usr/bin/make

update:
	@rm -fr html/*
	doxygen Doxyfile

firefox:
	$@ html/index.html

chrome:
	google-chrome html/index.html
