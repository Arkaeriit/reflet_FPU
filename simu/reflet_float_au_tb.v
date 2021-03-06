
module reflet_float_au_tb();

    reg clk = 1;
    always #1 clk <= !clk;

    reg [5:0] opcode = 0;
    reg [1:0] ctrl_flag = 2'b01;
    wire ready;
    wire cmp_flag;
    wire [15:0] int_out;
    wire [15:0] int_in = 123;

    reg signed [15:0] in1 = 56;
    reg signed [15:0] in2 = -549;
    reg signed [15:0] in3 = 324;
    
    wire [31:0] flt1, flt2, flt3, flt_out;
    wire signed [31:0] out_int;

    //Conversion
    reflet_int_to_float #(.int_size(16), .float_size(32)) itf1 (.int_in(in1), .float_out(flt1));
    reflet_int_to_float #(.int_size(16), .float_size(32)) itf2 (.int_in(in2), .float_out(flt2));
    reflet_int_to_float #(.int_size(16), .float_size(32)) itf3 (.int_in(in3), .float_out(flt3));
    reflet_float_to_int #(.int_size(32), .float_size(32)) fti (.float_in(flt_out), .int_out(out_int));

    //Arithmetic unit
    reflet_float_au #(.float_size(32), .integer_size(16)) au (
        .clk(clk),
        .enable(1'b1),
        .ctrl_flag(ctrl_flag),
        .opcode(opcode),
        .ready(ready),
        .cmp_flag(cmp_flag),
        .flt_in1(flt1),
        .flt_in2(flt2),
        .flt_in3(flt3),
        .flt_out(flt_out),
        .int_in(int_in),
        .int_out(int_out));

    initial
    begin
        $dumpfile("reflet_float_au_tb.vcd");
        $dumpvars(0, reflet_float_au_tb);
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #50;
        ctrl_flag <= 2'b10;
        #50;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        #100;
        opcode <= opcode + 1;
        $finish;
    end


endmodule

