/*---------------------------------------------------------------\
|This module waits for a certain amount of certain amont of clock|
|clicle after it's input changed before outputing a ready signal.|
|This is needed to wait for modules using opperation this mignt  |
|need a clock cycle to complete such as some multiplications.    |
\---------------------------------------------------------------*/

// Note: I am not very happy with the way this module works.
// I slows the au too much. I need to find a way to make it
// more efficient.

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

    wire n_reset = enable && (previous_input == in);

    always @ (posedge clk)
        previous_input <= in;

    always @ (posedge clk)
    begin
        if(!n_reset)
            counter <= 0;
        else
        begin
            if(counter < time_to_wait)
                counter <= counter + 1;
        end
    end

    assign ready = counter >= time_to_wait;

endmodule

