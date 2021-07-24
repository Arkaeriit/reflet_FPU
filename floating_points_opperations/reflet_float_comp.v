/*-----------------------------\
This module is ment to compare |
|two floating points number and|
|tell which is greater.        |
\-----------------------------*/

module reflet_float_comp #(
    parameter float_size = 32
    )(
    input enable,
    input [float_size-1:0] in1,
    input [float_size-1:0] in2,
    output equal,
    output strict_less,
    output less_or_equal
    );

    assign equal = (enable ? in1 == in2 : 0);

    wire cmp1 = {!in1[float_size-1]; in1[float_size-2:0]};
    wire cmp2 = {!in2[float_size-1]; in2[float_size-2:0]};

    assign strict_less = (enable ? cmp1 < cmp2 : 0);
    assign less_or_equal = strict_less | equal;

endmodule

