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


