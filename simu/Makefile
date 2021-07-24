
FPU = ../floating_points_opperations/reflet_int_to_float.v ../floating_points_opperations/reflet_float_to_int.v ../floating_points_opperations/reflet_float_add.v ../floating_points_opperations/reflet_float_mult.v ../floating_points_opperations/reflet_float_mult_mult.v ../floating_points_opperations/reflet_float_fisqrt.v ../floating_points_opperations/reflet_float_wait_ready.v ../floating_points_opperations/reflet_float_comp.v

all : conv_tb.vcd add_tb.vcd mult_tb.vcd fisqrt_tb.vcd comp_tb.vcd

conv_tb.vvp : $(FPU) conv_tb.v ../floating_points_opperations/reflet_float_functions.vh
	cp ../floating_points_opperations/reflet_float_functions.vh ./
	iverilog $(FPU) conv_tb.v -o conv_tb.vvp
	rm -f reflet_float_functions.vh  reflet_float_opperations.vh

conv_tb.vcd : conv_tb.vvp
	vvp conv_tb.vvp

conv_tb : conv_tb.vcd
	gtkwave conv_tb.vcd

add_tb.vvp : $(FPU) add_tb.v ../floating_points_opperations/reflet_float_functions.vh
	cp ../floating_points_opperations/reflet_float_functions.vh ./
	iverilog $(FPU) add_tb.v -o add_tb.vvp
	rm -f reflet_float_functions.vh 

add_tb.vcd : add_tb.vvp
	vvp add_tb.vvp

add_tb : add_tb.vcd
	gtkwave add_tb.vcd

mult_tb.vvp : $(FPU) mult_tb.v ../floating_points_opperations/reflet_float_functions.vh
	cp ../floating_points_opperations/reflet_float_functions.vh ./
	iverilog $(FPU) mult_tb.v -o mult_tb.vvp
	rm -f reflet_float_functions.vh 

mult_tb.vcd : mult_tb.vvp
	vvp mult_tb.vvp

mult_tb : mult_tb.vcd
	gtkwave mult_tb.vcd

fisqrt_tb.vvp : $(FPU) fisqrt_tb.v ../floating_points_opperations/reflet_float_functions.vh
	cp ../floating_points_opperations/reflet_float_functions.vh ./
	iverilog $(FPU) fisqrt_tb.v -o fisqrt_tb.vvp
	rm -f reflet_float_functions.vh 

fisqrt_tb.vcd : fisqrt_tb.vvp
	vvp fisqrt_tb.vvp

fisqrt_tb : fisqrt_tb.vcd
	gtkwave fisqrt_tb.vcd

comp_tb.vvp : $(FPU) comp_tb.v ../floating_points_opperations/reflet_float_functions.vh
	cp ../floating_points_opperations/reflet_float_functions.vh ./
	iverilog $(FPU) comp_tb.v -o comp_tb.vvp
	rm -f reflet_float_functions.vh 

comp_tb.vcd : comp_tb.vvp
	vvp comp_tb.vvp

comp_tb : comp_tb.vcd
	gtkwave comp_tb.vcd

clean :
	rm -f *.vcd
	rm -f *.vvp

