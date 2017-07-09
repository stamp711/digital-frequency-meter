UUT = Toplevel

.phony: all verilate build sim clean clean.all

all: build

verilate:
	@verilator -Wall --trace --cc Toplevel.sv --exe tb_Toplevel.cpp

obj_dir/VToplevel.mk: verilate

build: obj_dir/VToplevel.mk
	@make -s -C obj_dir -j -f VToplevel.mk

sim: build
	@obj_dir/VToplevel

clean:
	@rm -rf obj_dir

clean.all: clean
	@rm -rf wave.vcd
