/*------------------------- \
|This module compute the    |
|fast inverse square root   |
|of a floating point number.|
\--------------------------*/

module reflet_float_fisqrt #(
    parameter float_size = 32
    )(
    input clk,
    input enable,
    input [float_size-1:0] in,
    output [float_size-1:0] out,
    output ready
    );

    `include "reflet_float_functions.vh"

    function automatic [float_size-1:0] magic_number(input integer float_size);
        case(float_size)
            16: magic_number = 0; //Todo
            32: magic_number = 32'h5F375A86;
            64: magic_number = 64'h5FE6EB50C7B537A9;
        endcase
    endfunction

    function automatic [float_size-1:0] tree_halfs(input integer float_size);
        case(float_size)
            16: tree_halfs = 16'h3E00;
            32: tree_halfs = 32'h3FC00000;
            64: tree_halfs = 64'h3FF8000000000000;
        endcase
    endfunction

    wire [float_size-1:0] masked_shifted = magic_number(float_size) - ( in >> 1);
    wire [float_size-1:0] squared_shift;
    wire ready_1;
    reflet_float_square #(float_size) square1 (
        .clk(clk),
        .enable(enable),
        .ready(ready_1),
        .in(masked_shifted),
        .out(squared_shift));

    wire [float_size-1:0] half_in;
    reflet_float_half #(float_size) half (.in(in), .out(half_in));

    wire ready_2;
    wire [float_size-1:0] first_product;
    reflet_float_mult #(float_size) mult1 (
        .clk(clk),
        .enable(ready_1),
        .ready(ready_2),
        .in1(half_in),
        .in2(squared_shift),
        .mult(first_product));

    wire [float_size-1:0] substraction_result;
    reflet_float_add #(float_size) sub (
        .in1(tree_halfs(float_size)),
        .in2(first_product),
        .enable_add(1'b0),
        .enable_sub(enable),
        .sum(substraction_result));

    wire [float_size-1:0] low_prescision_output;
    reflet_float_mult #(float_size) mult2 (
        .clk(clk),
        .enable(ready_2),
        .ready(ready),
        .in1(masked_shifted),
        .in2(substraction_result),
        .mult(low_prescision_output)); //TODO: enable optional better prescision

    assign out = ( enable ? low_prescision_output : 0 );

endmodule


/*----------------------------------\
|Square a floating point number.    |
|I used the floationg point         |
|multiplication but I fell like     |
|there is some beter way to do this.|
\----------------------------------*/

module reflet_float_square #(
    parameter float_size = 32
    )(
    input clk,
    input enable,
    input [float_size-1:0] in,
    output [float_size-1:0] out,
    output ready
    );

    reflet_float_mult #(float_size) m (
        .clk(clk),
        .enable(enable),
        .ready(ready),
        .in1(in),
        .in2(in),
        .mult(out));

endmodule


/*----------------------------\
|Halve a floating point number|
|without using a multiplier.  |
\----------------------------*/

module reflet_float_half #(
    parameter float_size = 32
    )(
    input [float_size-1:0] in,
    output [float_size-1:0] out
    );
    
    `include "reflet_float_functions.vh"

    wire [mantissa_size(float_size)-1:0] mantissa = in[mantissa_size(float_size)-1:0];
    wire [exponent_size(float_size)-1:0] exponent_half = in[float_size-2:mantissa_size(float_size)] - 1;

    assign out = {in[float_size-1], exponent_half, mantissa};

endmodule

