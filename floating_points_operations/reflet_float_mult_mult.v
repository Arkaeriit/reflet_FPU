/*-----------------------------------\
|This module handle a multiplication.|
|I separated it to addapted to the   |
|target material if needed.          |
\-----------------------------------*/

//Replace with the time used by the multiplication
`define multiplication_time 2

module reflet_float_mult_mult #(
    parameter size = 10
    )(
    input clk,
    input enable,
    input [size-1:0] in1,
    input [size-1:0] in2,
    output [2*size-1:0] mult,
    output ready
    );

    //assign mult = in1 * in2;
    reg [2*size-1:0] mult1;
    reg [2*size-1:0] mult2;
    always @ (posedge clk)
        if(enable)
        begin
            mult1 <= in1 * in2;
            mult2 <= mult1;
        end

    assign mult = mult2;

    //Waiting for the result to be calculated
    reflet_float_wait_ready #(
        .time_to_wait(`multiplication_time),
        .input_size(size * 2)
    ) wait_ready (
        .clk(clk),
        .enable(enable),
        .in({in1, in2}),
        .ready(ready));
    
endmodule

