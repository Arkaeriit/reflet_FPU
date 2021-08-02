/*----------------------------------------\
|This module is a reflet FPU arithmetic   |
|unit. It combines the various computation|
|primitive to operate on numbers.         |
\----------------------------------------*/

`include "reflet_fpu.vh"

module reflet_float_au #(
    parameter float_size = 32
    )(
    //ctrl signals
    input clk,
    input enable,
    input [5:0] opcode,
    output ready,
    //data signals
    input [float_size-1:0] flt_in1,
    input [float_size-1:0] flt_in2,
    input [float_size-1:0] flt_in3,
    output [float_size-1:0] flt_out,
    output flag_out
    );

    //fisqrt module
    wire [float_size-1:0] fisqrt_in, fisqrt_out;
    wire fisqrt_en, fisqrt_rdy;
    reflet_float_fisqrt #(float_size) fisqrt (
        .clk(clk),
        .enable(enable & fisqrt_en),
        .in(fisqrt_in),
        .out(fisqrt_out),
        .ready(fisqrt_rdy));

    //Multiplication modules
    wire [float_size-1:0] mult_1_flt_in1, mult_1_flt_in2, mult_2_flt_in1, mult_2_flt_in2, mult_1_out, mult_2_out;
    wire mult_1_en, mult_2_en, mult_1_rdy, mult_2_rdy;
    reflet_float_mult #(float_size) mult_1 (
        .clk(clk),
        .enable(enable & mult_1_en),
        .ready(mult_1_rdy),
        .in1(mult_1_flt_in1),
        .in2(mult_1_flt_in2),
        .mult(mult_1_out));
    reflet_float_mult #(float_size) mult_2 (
        .clk(clk),
        .enable(enable & mult_2_en),
        .ready(mult_2_rdy),
        .in1(mult_2_flt_in1),
        .in2(mult_2_flt_in2),
        .mult(mult_2_out));

    //Addition module
    wire [float_size-1:0] add_flt_in1, add_flt_in2, add_out;
    wire add_en, sub_en;
    reflet_float_add #(float_size) add (
        .in1(add_flt_in1),
        .in2(add_flt_in2),
        .sum(add_out),
        .enable_add(enable & add_en),
        .enable_sub(enable & sub_en));

    //Interconect
    //fisqrt inputs
    assign fisqrt_en = opcode == `OPP_FISQRT || opcode == `OPP_DIV || opcode == `OPP_INV;
    assign fisqrt_in = ( opcode == `OPP_DIV ? flt_in2 : flt_in1 ); //In most case we take flt_in1 as input inless we are dividing. In the other case the module is not enabled

    //add inputs
    assign add_en = opcode == `OPP_ADD || (opcode == `OPP_MULTADD && mult_1_rdy);
    assign sub_en = opcode == `OPP_SUB;
    assign add_flt_in1 = ( opcode == `OPP_MULTADD ? mult_2_out : flt_in1 );
    assign add_flt_in2 = ( opcode == `OPP_MULTADD ? flt_in3 : flt_in2 );

    //mult1 input
    assign mult_1_en = opcode == `OPP_MUL || opcode == `OPP_CUBE || opcode == `OPP_TESSERACT || opcode == `OPP_TRIMULT || ((opcode == `OPP_DIV || opcode == `OPP_INV) && fisqrt_rdy);
    assign mult_1_flt_in1 = ( (opcode == `OPP_MUL || opcode == `OPP_CUBE || opcode == `OPP_TESSERACT || opcode == `OPP_TRIMULT) ? flt_in1 : fisqrt_out);
    assign mult_1_flt_in2 = ( (opcode == `OPP_MUL || opcode == `OPP_TRIMULT) ? flt_in2 :
                                ( opcode == `OPP_CUBE || opcode == `OPP_TESSERACT ? flt_in1 : fisqrt_out));

    //mult2 input
    assign mult_2_en = opcode == `OPP_DIV || opcode == `OPP_CUBE || opcode == `OPP_TESSERACT || ( opcode == `OPP_TRIMULT ? mult_1_rdy : opcode == `OPP_MULTADD );
    assign mult_2_flt_in1 = ( opcode == `OPP_DIV || opcode == `OPP_CUBE || opcode == `OPP_TESSERACT || opcode == `OPP_TESSERACT ? mult_1_out : flt_in1 );
    assign mult_2_flt_in2 = ( (opcode == `OPP_CUBE || opcode == `OPP_MULTADD) ? flt_in2 : 
                              ( opcode == `OPP_TRIMULT ? flt_in3 :
                                ( opcode == `OPP_DIV ? flt_in1 : mult_1_out )));

    //Global outputs
    assign flt_out = ( opcode == `OPP_MULTADD || opcode == `OPP_ADD || opcode == `OPP_SUB ? add_out :
                   ( opcode == `OPP_DIV || opcode == `OPP_CUBE || opcode == `OPP_TESSERACT || opcode == `OPP_TRIMULT ? mult_2_out :
                     ( opcode == `OPP_MUL || opcode == `OPP_INV ? mult_1_out : fisqrt_out )));
    assign ready = ( opcode == `OPP_ADD || opcode == `OPP_SUB ? enable :
                   ( opcode == `OPP_DIV || opcode == `OPP_CUBE || opcode == `OPP_TESSERACT || opcode == `OPP_TRIMULT || opcode == `OPP_MULTADD ? mult_2_rdy :
                     ( opcode == `OPP_MUL || opcode == `OPP_INV ? mult_1_rdy : 
                       ( opcode == `OPP_FISQRT ? fisqrt_out : 0 ))));

endmodule

