
module comp_tb();

    reg signed [31:0] in1;
    reg signed [31:0] in2;

    wire [31:0] flt1;
    wire [31:0] flt2;

    wire out;

    reg [1:0] order = 0;
    always #1 order <= order + 1;


    //Conversion
    reflet_int_to_float #(.int_size(32)) itf1 (
        .int_in(in1),
        .float_out(flt1));
    reflet_int_to_float #(.int_size(32)) itf2 (
        .int_in(in2),
        .float_out(flt2));

    //Comparaison
    reflet_float_comp comp (
        .order(order),
        .in1(flt1),
        .in2(flt2),
        .out(out));

    initial
    begin
        $dumpfile("comp_tb.vcd");
        $dumpvars(0, comp_tb);
        in1 <= 512;
        in2 <= 512;
        #4;
        in1 <= -23;
        in2 <= -8;
        #4;
        in1 <= -30;
        in2 <= 25;
        #4;
        in1 <= -5;
        in2 <= -5;
        #4;
        in1 <= 100;
        in2 <= 2000;
        #4;
        in1 <= -100;
        in2 <= -2000;
        #4;
        in1 <= 300;
        in2 <= 200;
        #4;
        in1 <= 0;
        in2 <= 0;
        #4;
        $finish;
    end

endmodule

