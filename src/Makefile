UUT = TopController

.phony: all verilate build sim clean clean.all

all: build

verilate:
	@verilator -Wall --trace --cc TopController.sv --exe tb_TopController.cpp

obj_dir/VTopController.mk: verilate

build: obj_dir/VTopController.mk
	@make -s -C obj_dir -j -f VTopController.mk

sim: build
	@obj_dir/VTopController

clean:
	@rm -rf obj_dir

clean.all: clean
	@rm -rf wave.vcd
