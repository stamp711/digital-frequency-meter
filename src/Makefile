UUT = FMeasureTop

.phony: all verilate build sim clean clean.all

all: build

verilate:
	@verilator -Wall --trace --cc FMeasureTop.sv --exe tb_FMeasureTop.cpp

obj_dir/VFMeasureTop.mk: verilate

build: obj_dir/VFMeasureTop.mk
	@make -s -C obj_dir -j -f VFMeasureTop.mk

sim: build
	@obj_dir/VFMeasureTop

clean:
	@rm -rf obj_dir

clean.all: clean
	@rm -rf wave.vcd
