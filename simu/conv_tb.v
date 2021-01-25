
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
        //0xFFFA; sign = 1; exponent = 2; biased exponent = -125; mantissa = b1000000.. Expected float: 0xC1C00000
        int_in = -6; 
        #1;
        //sign = 0; exponent = 7; biased exponent = -120; mantissa = 00001100000.....  expected float = 0x44060000
        int_in = 134; 
        #1;
        //sign = 1; exponent = 11; baised exponent = -116; mantissa = 10110000000100000....  expected float = 0xC6581000
        int_in = -3457; 
        #1;
        $finish;
    end

endmodule

