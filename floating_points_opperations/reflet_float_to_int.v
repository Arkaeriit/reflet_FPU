/*------------------------------------------\
|This module convert a floating point number|
|into a 2 complement signed integer.        |
\------------------------------------------*/

module reflet_float_to_int #(
    parameter int_size = 16,
    float_size = 32
    )(
    input [float_size-1:0] float_in,
    output signed [int_size-1:0] int_out
    );

    `include "reflet_float.vh"

    //Decoding exponent
    wire [exponent_size(float_size)-1:0] exponent_biased = float_in[exponent_size(float_size)+mantissa_size(float_size)-1:mantissa_size(float_size)];
    wire [exponent_size(float_size)-1:0] exponent = exponent_biased - exponent_bias(float_size);
    
    //Decoding mantissa
    wire [mantissa_size(float_size):0] value = {1'b1, float_in[mantissa_size(float_size)-1:0]};
    wire [int_size-2:0] ret_abs = value << exponent;

    //Solving edge cases
    wire [int_size-2:0] ret_spcs = ( exponent >= int_size ? ~0 : //Big number
                                     ( &exponent ? 1 : //exponent = -1
                                       ( exponent[exponent_size(float_size)-1] ? 0 : //small exponent 
                                         ( ret_abs )))); //normal case

    //Decoding sign
    wire sign = float_in[float_size-1];
    wire [int_size-2:0] ret_cc2 = ~ret_spcs[int_size-2:0] + 1;
    assign int_out = {sign, ( sign ? ret_cc2 : ret_spcs ) };

endmodule

