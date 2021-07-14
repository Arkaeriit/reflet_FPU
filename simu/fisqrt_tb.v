
module fisqrt_tb();

    reg signed [31:0] in;
    wire [31:0] flt_in;
    wire [31:0] flt_tmp;
    wire [31:0] flt_out;
    wire signed [31:0] out;

    //Conversion
    reflet_int_to_float #(.int_size(32)) itf (
        .int_in(in),
        .float_out(flt_in));
    reflet_float_to_int #(.int_size(32)) fti (
        .float_in(flt_out),
        .int_out(out));

    //Two consequtives fisqrt
    reflet_float_fisqrt #(32) fisqrt_1 (
        .enable(1'b1),
        .in(flt_in),
        .out(flt_tmp));
    reflet_float_fisqrt #(32) fisqrt_2 (
        .enable(1'b1),
        .in(flt_tmp),
        .out(flt_out));

    initial
    begin
        $dumpfile("fisqrt_tb.vcd");
        $dumpvars(0, fisqrt_tb);
        in = 654;
        #1;
        in = 897;
        #1;
        in = 7654;
        #1;
        in = 1245;
        #1;
        in = 8765;
        #1;
        in = 98456;
        #1;
        in = 87642;
        #1;
        in = 54329;
        #1;
        in = 876389;
        #1;
        in = 235975;
        #1;
        $finish;
    end

endmodule

