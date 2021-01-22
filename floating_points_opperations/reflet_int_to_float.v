
module int_to_float #(
    parameter int_size = 16,
    float_size = 32
    )(
    input [int_size-1:0] int_in,
    output [float_size-1:0] float_out
    );

    //reading sign
    wire sign = int_in[int_size-1];

    //computing exponant
    wire [$clog2(int_size)-1:0] list_max_int [int_size-1:0];
    genvar i;
    generate
        for(i=0; i<int_size; i=i+1)
            testBit #(.size(int_size), .index(i)) tb (int_in, list_max_int[i]);
    endgenerate
    wire [$clog2(int_size)-2:0] list_max_or [int_size-1:0];
    assign list_max_or[0] = list_max_int[0];
    genvar j;
    generate
        for(j=1; j<int_size; j=j+1)
            assign list_max_or[j] = list_max_or[j-1] | list_max_int[j];
    endgenerate
    wire [$clog2(int_size)-1:0] exponent = list_max_or[int_size-1];


    assign float_out = exponent;

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

