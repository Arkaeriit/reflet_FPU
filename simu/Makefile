
FPU = ../floating_points_opperations/reflet_int_to_float.v

all : conv_tb.vcd

conv_tb.vvp : $(FPU) conv_tb.v ../floating_points_opperations/reflet_float.vh
	cp ../floating_points_opperations/reflet_float.vh ./
	iverilog $(FPU) conv_tb.v -o conv_tb.vvp
	rm -f reflet_float.vh

conv_tb.vcd : conv_tb.vvp
	vvp conv_tb.vvp

conv_tb : conv_tb.vcd
	gtkwave conv_tb.vcd

clean :
	rm -f *.vcd
	rm -f *.vvp

