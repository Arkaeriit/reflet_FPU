/*---------------------------------------------------------------\
|This module waits for a certain amount of certain amont of clock|
|clicle after it's input changed before outputing a ready signal.|
|This is needed to wait for modules using opperation this mignt  |
|need a clock cycle to complete such as some multiplications.    |
\---------------------------------------------------------------*/

module reflet_float_wait_ready #(
    parameter time_to_wait = 2,
    input_size = 16
    )(
    input clk,
    input enable,
    input [input_size-1:0] in,
    output ready
    );

    reg [$clog2(time_to_wait):0] counter;
    reg [input_size-1:0] previous_input;

    always @ (posedge clk)
    begin
        previous_input <= in;
        if(!enable)
            counter <= 0;
        else if(previous_input != in)
            counter <= 1; //1 clock cycle wasted to swith previous_input
        else
        begin
            if(counter < time_to_wait)
                counter <= counter + 1;
        end
    end

    assign ready = counter >= time_to_wait; //The -1 commes from the fact that a clock cycle has been wasted to reset the counter

endmodule

