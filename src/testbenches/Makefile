# testbench makefile
MODULEPATH=..
WORKDIR=../work

inputs := $(wildcard *.v)
outputs := $(inputs:%.v=%)

.PHONY: all clean

all: $(outputs)
	@echo $^

clean:
	rm $(WORKDIR)/*

%_tb.v %: 
	iverilog -l $(MODULEPATH)/*.v -o $(WORKDIR)/$@ $@.v