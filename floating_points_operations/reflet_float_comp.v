/*----------------------------------------------------------\
|This module is ment to compare two floating point numbers. |
|The comparaison choosed depends on the order input. If the |
|order is 2'b00, the output stays on 0. If it is is 2'b01,  |
|the output is 1 if both input are equal. If the output is  |
|2'b10, the output is 1 if the input 1 is strictly less than|
|the output 2. If the output is 2'b11, the output is 1 is   |
|the input 1 is less or equal to the input 2.               |
\----------------------------------------------------------*/

`define ORDER_OFF      2'b00
`define ORDER_EQUAL    2'b01
`define ORDER_LESS     2'b10
`define ORDER_LESS_EQ  2'b11

module reflet_float_comp #(
    parameter float_size = 32
    )(
    input [1:0] order,
    input [float_size-1:0] in1,
    input [float_size-1:0] in2,
    output out
    );


    wire equal = in1 == in2 
                    | (in1[float_size-2:0] == 0 && in2[float_size-2:0] == 0);
    wire strict_less = !equal &&
                       ( in1[float_size-1] ? //in1 is negative
                          ( !in2[float_size-1] ? 1'b1 : //in2 is positive so in1 is smaller
                            in1[float_size-2:0] > in2[float_size-2:0] )
                         : //in1 is positive
                           ( in2[float_size-1] ? 1'b0 :
                             ( in1[float_size-2:0] < in2[float_size-2:0] )));

    wire less_or_equal = strict_less | equal;

    assign out = (order == `ORDER_OFF     ? 0 :
                 (order == `ORDER_EQUAL   ? equal :
                 (order == `ORDER_LESS    ? strict_less :
                 (order == `ORDER_LESS_EQ ? less_or_equal : 0))));

endmodule

