/*------------------------------------\
|This very simple module sets the sign|
|bit of a number to the desired value.|
\------------------------------------*/

`define ORDER_OFF    2'b00
`define ORDER_TOGGLE 2'b01
`define ORDER_POS    2'b10
`define ORDER_NEG    2'b11

module reflet_float_set_sign #(
    parameter float_size = 32
    )(
    input [1:0] order,
    input [float_size-1:0] in,
    output [float_size-1:0] out
    );

    wire sign = ( order == `ORDER_TOGGLE ? !in[float_size-1] : order[0] );

    assign out = ( order == `ORDER_OFF ? 0 : {sign, in[float_size-2:0]} );

endmodule

