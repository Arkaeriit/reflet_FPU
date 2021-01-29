
module add_tb();

    reg signed [31:0] in1;
    reg signed [31:0] in2;

    wire [31:0] flt1;
    wire [31:0] flt2;
    wire signed [31:0] int1;
    wire signed [31:0] int2;
    wire [31:0] fltSum;
    wire signed [31:0] convSum;
    wire signed [31:0] rawSum = in1 + in2;

    //Conversion
    reflet_int_to_float #(.int_size(32)) itf1 (
        .int_in(in1),
        .float_out(flt1));
    reflet_int_to_float #(.int_size(32)) itf2 (
        .int_in(in2),
        .float_out(flt2));
    reflet_float_to_int #(.int_size(32)) fti1 (
        .float_in(fltSum),
        .int_out(convSum));

    //Conversion monitor
    reflet_float_to_int #(.int_size(32)) fti2 (
        .float_in(flt1),
        .int_out(int1));
    reflet_float_to_int #(.int_size(32)) fti3 (
        .float_in(flt2),
        .int_out(int2));

    //Addition
    reflet_float_add add (
        .in1(flt1),
        .in2(flt2),
        .enable_add(1'b1),
        .enable_sub(1'b0),
        .sum(fltSum));

    initial
    begin
        $dumpfile("add_tb.vcd");
        $dumpvars(0, add_tb);
        in1 = 5;
        in2 = 15;
        #1;
        in1 = 28;
        in2 = -15;
        #1;
        in1 = 28;
        in2 = 15;
        #1;
        in1 = 65489;
        in2 = 173949;
        #1;
        in1 = 1398;
        in2 = -12300;
        #1;
        in1 = 0;
        in2 = 0;
        #1;
        in1 = -12;
        in2 = 12;
        #1;
        in1 = -12;
        in2 = -12;
        #1;
        in1 = 0;
        in2 = 100;
        #1;
        $finish;
        $finish;
        $finish;
        $finish;
    end

endmodule

