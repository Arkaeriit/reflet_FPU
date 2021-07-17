
module mult_tb();

    reg clk = 0;
    always #1 clk <= !clk;
    reg enable = 1'b0;

    reg signed [31:0] in1;
    reg signed [31:0] in2;

    wire [31:0] flt1;
    wire [31:0] flt2;
    wire signed [31:0] int1;
    wire signed [31:0] int2;
    wire [31:0] fltPrd;
    wire signed [31:0] convPrd;
    wire signed [31:0] rawPrd = in1 * in2;
    wire signed [63:0] bigPrd = in1 * in2;

    wire produc_ok = convPrd == rawPrd;
    wire ready;

    //Conversion
    reflet_int_to_float #(.int_size(32)) itf1 (
        .int_in(in1),
        .float_out(flt1));
    reflet_int_to_float #(.int_size(32)) itf2 (
        .int_in(in2),
        .float_out(flt2));
    reflet_float_to_int #(.int_size(32)) fti_prod (
        .float_in(fltPrd),
        .int_out(convPrd));

    //Conversion monitor
    reflet_float_to_int #(.int_size(32)) fti_in1 (
        .float_in(flt1),
        .int_out(int1));
    reflet_float_to_int #(.int_size(32)) fti_in2 (
        .float_in(flt2),
        .int_out(int2));

    //Multiplication
    reflet_float_mult mult (
        .clk(clk),
        .ready(ready),
        .in1(flt1),
        .in2(flt2),
        .enable(enable),
        .mult(fltPrd));

    initial
    begin
        $dumpfile("mult_tb.vcd");
        $dumpvars(0, mult_tb);
        #1;
        in1 <= 5;
        in2 <= 15;
        #10;
        enable <= 1'b1;
        #10;
        in1 <= 28;
        in2 <= -15;
        #10;
        in1 <= 28;
        in2 <= 15;
        #10;
        in1 <= 1398;
        in2 <= -1230;
        #10;
        in1 <= 0;
        in2 <= 0;
        #10;
        in1 <= -12;
        in2 <= 12;
        #10;
        in1 <= -12;
        in2 <= -12;
        #10;
        in1 <= 0;
        in2 <= 100;
        #10;
        in1 <= 7658;
        in2 <= 9875;
        #10;
        in1 <= 456453;
        in2 <= 8088911;
        #10;
        in1 <= 125;
        in2 <= 985;
        #10;
        in1 <= 1133;
        in2 <= 7755;
        #10;
        in1 <= 2378;
        in2 <= 8866;
        #10;
        in1 <= 512;
        in2 <= 512;
        #10;
        $finish;
    end

endmodule

