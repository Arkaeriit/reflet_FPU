
module fisqrt_tb();

    reg clk = 0;
    always #1 clk <= !clk;
    reg enable = 1'b0;

    reg signed [31:0] in;
    wire [31:0] flt_in;
    wire [31:0] flt_tmp;
    wire [31:0] flt_out;
    wire signed [31:0] out;
    wire ready_tmp;
    wire ready;

    //Conversion
    reflet_int_to_float #(.int_size(32)) itf (
        .int_in(in),
        .float_out(flt_in));
    reflet_float_to_int #(.int_size(32)) fti (
        .float_in(flt_out),
        .int_out(out));

    //Two consequtives fisqrt
    reflet_float_fisqrt #(32) fisqrt_1 (
        .clk(clk),
        .enable(enable),
        .ready(ready_tmp),
        .in(flt_in),
        .out(flt_tmp));
    reflet_float_fisqrt #(32) fisqrt_2 (
        .clk(clk),
        .enable(ready_tmp),
        .ready(ready),
        .in(flt_tmp),
        .out(flt_out));

    initial
    begin
        $dumpfile("fisqrt_tb.vcd");
        $dumpvars(0, fisqrt_tb);
        #1;
        in <= 654;
        #100;
        enable <= 1'b1;
        #100;
        in <= 897;
        #100;
        in <= 7654;
        #100;
        in <= 1245;
        #100;
        in <= 8765;
        #100;
        in <= 98456;
        #100;
        in <= 87642;
        #100;
        in <= 54329;
        #100;
        in <= 876389;
        #100;
        in <= 235975;
        #100;
        $finish;
    end

endmodule

