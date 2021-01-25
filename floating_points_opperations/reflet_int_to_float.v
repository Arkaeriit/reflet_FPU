/*-------------------------------------------\
|This module can convert a 2 complement      |
|signed integer into a floating point number.|
\-------------------------------------------*/

module reflet_int_to_float #(
    parameter int_size = 16,
    float_size = 32
    )(
    input signed [int_size-1:0] int_in,
    output [float_size-1:0] float_out
    );

    `include "reflet_float.vh"

    //reading sign
    wire sign = int_in[int_size-1];

    //Compuning int absolute value
    wire [int_size-2:0] int_cc2 = ~int_in[int_size-2:0] + 1;
    wire [int_size-2:0] int_abs = (sign ? int_cc2 : int_in[int_size-2:0]);

    //computing exponant
    wire [$clog2(int_size-1)-1:0] list_max_int [int_size-2:0];
    genvar i;
    generate //getting the index of the highest 1 bit
        for(i=0; i<int_size-1; i=i+1)
            testBit #(.size(int_size-1), .index(i)) tb (int_abs, list_max_int[i]);
    endgenerate
    wire [$clog2(int_size-1)-1:0] list_max_or [int_size-2:0];
    assign list_max_or[0] = list_max_int[0];
    genvar j;
    generate
        for(j=1; j<int_size-1; j=j+1) //combining the index result to have only one
            assign list_max_or[j] = list_max_or[j-1] | list_max_int[j];
    endgenerate
    wire [$clog2(int_size-1)-1:0] exponent = list_max_or[int_size-2];
    wire [exponent_size(float_size)-1:0] exp_ret = exponent + exponent_bias(float_size);

    //computing mantissa
    wire [mantissa_size(float_size)-1:0] mantissa = int_abs << (mantissa_size(float_size) - exponent);

    //Cancaneting values to get the result
    assign float_out = ( int_in == 0 ? 0 : {sign, exp_ret, mantissa});

endmodule



/*----------------------------------\
|This module read a bit of a number |
|and if this bit is the higest one, |
|it returns the index of the number.|
\----------------------------------*/

module testBit #(
    parameter size = 16,
    index = 0
    )(
    input [size-1:0] in,
    output [$clog2(size)-1:0] out
    );

    generate
        if(index == size-1)
            assign out = (in[index] ? index : 0);
        else
            assign out = (in[index] && !(|(in[size-1:index+1])) ? index : 0);
    endgenerate

endmodule

