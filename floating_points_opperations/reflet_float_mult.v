/*---------------------------\
|This module let multiply two|
|floating point numbers.     |
\---------------------------*/

module reflet_float_mult #(
    parameter float_size = 32
    )(
    input clk,
    input enable,
    input [float_size-1:0] in1,
    input [float_size-1:0] in2,
    output [float_size-1:0] mult
    );

    `include "reflet_float.vh"

    //Separating various parts of numbers
    wire [mantissa_size(float_size)-1:0] mnt1 = in1[mantissa_size(float_size)-1:0];
    wire [exponent_size(float_size)-1:0] exp1 = in1[exponent_size(float_size)+mantissa_size(float_size)-1:mantissa_size(float_size)];
    wire sign1 = in1[float_size-1];
    wire [mantissa_size(float_size)-1:0] mnt2 = in2[mantissa_size(float_size)-1:0];
    wire [exponent_size(float_size)-1:0] exp2 = in2[exponent_size(float_size)+mantissa_size(float_size)-1:mantissa_size(float_size)];
    wire sign2 = in2[float_size-1];

    //Doing the computaion
    wire [exponent_size(float_size)-1:0] exp_sum = exp1 + exp2 - exponent_bias(float_size); 
    wire [2*mantissa_size(float_size)+1:0] mnt_product;
    reflet_float_mult_mult #(.size(mantissa_size(float_size)+1)) mult_hard (clk, {1'b1, mnt1}, {1'b1, mnt2}, mnt_product);
    wire [mantissa_size(float_size)-1:0] mnt_ret = mnt_product[2*mantissa_size(float_size)-1:mantissa_size(float_size)];
    wire sign_ret = sign1 ^ sign2;

    //Merging the result
    assign mult = {sign_ret, exp_sum ,mnt_ret};

endmodule



/*-----------------------------------\
|This module handle a multiplication.|
|I separated it to addapted to the   |
|target material if needed.          |
\-----------------------------------*/

module reflet_float_mult_mult #(
    parameter size = 10
    )(
    input clk,
    input [size-1:0] in1,
    input [size-1:0] in2,
    output [2*size-1:0] mult
    );

    assign mult = in1 * in2;

endmodule

