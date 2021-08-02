
FPU := ../floating_points_operations/reflet_int_to_float.v ../floating_points_operations/reflet_float_to_int.v ../floating_points_operations/reflet_float_add.v ../floating_points_operations/reflet_float_mult.v ../floating_points_operations/reflet_float_mult_mult.v ../floating_points_operations/reflet_float_fisqrt.v ../floating_points_operations/reflet_float_wait_ready.v ../floating_points_operations/reflet_float_comp.v ../float_processing/reflet_float_au.v

HEADERS := ./reflet_float_functions.vh ./reflet_fpu.vh

TEST_BENCHES := conv_tb add_tb mult_tb fisqrt_tb comp_tb reflet_float_au_tb

all:

define test_bench_template
$(1).vvp: $$(FPU) $$(HEADERS) $(1).v
	iverilog $$(FPU) $(1).v -o $(1).vvp

$(1).vcd: $(1).vvp
	vvp $$<

.PHONY: $(1).vcd
$(1): $(1).vcd
	gtkwave $$<

ALL_VCD += $(1).vcd

$(1)_clean:
	rm -f $(1).vcd
	rm -f $(1).vvp

.PHONY: $(1)_clean
ALL_CLEAN += $(1)_clean

endef

$(foreach tb, $(TEST_BENCHES), $(eval $(call test_bench_template, $(tb))))

all: $(ALL_VCD)

clean : $(ALL_CLEAN)

