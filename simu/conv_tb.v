
module conv_tb ();

    reg signed [15:0] int_in;
    wire [31:0] float_out;

    reflet_int_to_float itf (
        .int_in(int_in),
        .float_out(float_out));

    initial
    begin
        $dumpfile("conv_tb.vcd");
        $dumpvars(0, conv_tb);
        //0xFFFA; sign = 1; exponent = 2; biased exponent = 129; mantissa = b1000000.. Expected float: 0xC0C00000
        int_in = -6; 
        #1;
        //sign = 0; exponent = 7; biased exponent = 134; mantissa = 00001100000.....  expected float = 0x4306000
        int_in = 134; 
        #1;
        //sign = 1; exponent = 11; biased exponent = 138; mantissa = 1011000000100000....  expected float = 0xC5581000
        int_in = -3457; 
        #1;
        //sign = 1, exponent = 0; biased exponent = 127; mantissa = 000...  expected float = 0xBF800000
        int_in = -1;
        #1;
        //sign = 0, exponent = 0; biased exponent = 127; mantissa = 000...  expected float = 0x3F800000
        int_in = +1;
        #1;
        //Special case, expected float = 0x00000000
        int_in = 0;
        #1;
        $finish;
    end

endmodule

