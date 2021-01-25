/*--------------------------------\
|This module is ment to add or    |
|substract floating point numbers.|
\--------------------------------*/

// If enable_sub is set to 1, sum will contain in1 - in2
// If not, if enable_add is set to 1, sum will contain in1 + in2
// If both enable_sub and enable_add are set 0, sum will contain 0

module reflet_float_add #(
    parameter float_size = 32
    )(
    input [float_size-1:0] in1,
    input [float_size-1:0] in2,
    input enable_add,
    input enable_sub,
    output [float_size-1:0] sum
    );

    `include "reflet_float.vh"

    wire [float_size-1:0] in2_fixed = (enable_sub ? {!in2[float_size-1], in2[float_size-2:0]} : in2); //negating in2 if we need to substract

    //Testing for the greater and smaller number in absolute value
    wire [mantissa_size(float_size)-1:0] mnt1 = in1[mantissa_size(float_size)-1:0];
    wire [mantissa_size(float_size)-1:0] mnt2 = in2_fixed[mantissa_size(float_size)-1:0];
    wire [exponent_size(float_size)-1:0] exp1 = in1[mantissa_size(float_size)+exponent_size(float_size)-1:mantissa_size(float_size)];
    wire [exponent_size(float_size)-1:0] exp2 = in2_fixed[mantissa_size(float_size)+exponent_size(float_size)-1:mantissa_size(float_size)];
    wire [float_size-1:0] max = ( exp1 > exp2 ? in1 :
                                  ( exp2 > exp1 ? in2_fixed :
                                    ( mnt1 > mnt2 ? in1 :
                                      ( in2_fixed ))));
    wire [float_size-1:0] min = ( exp1 > exp2 ? in2_fixed :
                                  ( exp2 > exp1 ? in1 :
                                    ( mnt1 > mnt2 ? in2_fixed :
                                      ( in1 ))));

    //Computing the mantissas to prepare for the opperation
    wire [exponent_size(float_size)-1:0] exp_max = max[mantissa_size(float_size)+exponent_size(float_size)-1:mantissa_size(float_size)];
    wire [exponent_size(float_size)-1:0] exp_min = min[mantissa_size(float_size)+exponent_size(float_size)-1:mantissa_size(float_size)];
    wire [mantissa_size(float_size)+1:0] value_max = {2'b01, max[mantissa_size(float_size):0]};
    wire [mantissa_size(float_size)+1:0] value_min = {2'b01, min[mantissa_size(float_size):0]} >> exp_max - exp_min;

    //Doing the computation
    wire sign_max = max[float_size-1];
    wire sign_min = min[float_size-1];
    wire [mantissa_size(float_size)+1:0] value_result = ( sign_max == sign_min ? value_max + value_min : value_max - value_min );

    //Getting the index of the highest 1 in the new mantissa
    wire [$clog2(mantissa_size(float_size)+1)-1:0] list_max_res [mantissa_size(float_size)+1:0];
    genvar i;
    generate //getting the index of the highest 1 bit
        for(i=0; i<=mantissa_size(float_size)+1; i=i+1)
            testBit #(.size(mantissa_size(float_size)+1), .index(i)) tb (value_result , list_max_res[i]);
    endgenerate
    wire [$clog2(mantissa_size(float_size)+1)-1:0] list_max_or [mantissa_size(float_size)+1:0];
    assign list_max_or[0] = list_max_res[0];
    genvar j;
    generate
        for(j=1; j<=mantissa_size(float_size)+1; j=j+1) //combining the index result to have only one
            assign list_max_or[j] = list_max_or[j-1] | list_max_res[j];
    endgenerate
    wire [$clog2(mantissa_size(float_size)+1)-1:0] max_index = list_max_or[mantissa_size(float_size)+1];

    //Computing new exponent and mantissa
    wire [exponent_size(float_size)-1:0] exp_ret = exp_max + (max_index - mantissa_size(float_size));
    wire [mantissa_size(float_size)-1:0] mnt_ret = value_result << (2 + max_index - mantissa_size(float_size));

    //merging the result
    assign sum = ( enable_add | enable_sub ? {sign_max, exp_ret, mnt_ret} : 0 );

endmodule
     
