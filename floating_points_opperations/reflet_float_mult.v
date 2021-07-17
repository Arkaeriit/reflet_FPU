/*---------------------------\
|This module let multiply two|
|floating point numbers.     |
\---------------------------*/

`include "reflet_float_opperations.vh"

module reflet_float_mult #(
    parameter float_size = 32
    )(
    input clk,
    input enable,
    input [float_size-1:0] in1,
    input [float_size-1:0] in2,
    output [float_size-1:0] mult,
    output ready
    );

    `include "reflet_float_functions.vh"

    //Separating various parts of numbers
    wire [mantissa_size(float_size)-1:0] mnt1 = in1[mantissa_size(float_size)-1:0];
    wire [exponent_size(float_size)-1:0] exp1 = in1[exponent_size(float_size)+mantissa_size(float_size)-1:mantissa_size(float_size)];
    wire sign1 = in1[float_size-1];
    wire [mantissa_size(float_size)-1:0] mnt2 = in2[mantissa_size(float_size)-1:0];
    wire [exponent_size(float_size)-1:0] exp2 = in2[exponent_size(float_size)+mantissa_size(float_size)-1:mantissa_size(float_size)];
    wire sign2 = in2[float_size-1];

    //Doing the computaion
    wire [2*mantissa_size(float_size)+1:0] mnt_product;
    reflet_float_mult_mult #(.size(mantissa_size(float_size)+1)) mult_hard (clk, {1'b1, mnt1}, {1'b1, mnt2}, mnt_product);
    wire [mantissa_size(float_size)-1:0] mnt_ret = ( mnt_product[2*mantissa_size(float_size)+1]
                                                      ?  mnt_product[2*mantissa_size(float_size):mantissa_size(float_size)+1]
                                                      :  mnt_product[2*mantissa_size(float_size)-1:mantissa_size(float_size)]);
    wire [exponent_size(float_size)-1:0] exp_sum = exp1 + exp2 - exponent_bias(float_size) + mnt_product[2*mantissa_size(float_size)+1]; 
    wire sign_ret = sign1 ^ sign2;

    //Merging the result
    wire [float_size-2:0] mult_abs = ( in1[float_size-2:0] == 0 || in2[float_size-2:0] == 0 ? 0 :
                                       {exp_sum, mnt_ret} );
    wire [float_size-1:0] mult_ret = {sign_ret, mult_abs};

    //Exporting result
    assign mult = ( enable ? mult_ret : 0 );

    //Waiting for the result to be calculated
    reflet_float_wait_ready #(
        .time_to_wait(`multiplication_time),
        .input_size(float_size * 2)
    ) wait_ready (
        .clk(clk),
        .enable(enable),
        .in({in1, in2}),
        .ready(ready));

endmodule

