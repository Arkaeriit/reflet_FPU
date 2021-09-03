/*-------------------------------------\
|This is the control unit of the reflet|
|floating point CPU. It is in charge of|
|controlling the access to the memory  |
|and other non-math operations.        |
\-------------------------------------*/

`include "reflet_fpu.vh"

`define state_fetch_instruction 0
`define state_exec_swift        1
`define state_exec_long_2       2
`define state_exec_long_1       3

module reflet_float_cu_core #(
    parameter float_size = 32,
    addr_size = 32,
    stack_depth = 128
    )(
    //Ctrl IO
    input clk,
    input enable_instruction_fetching,
    input enable_execution,
    input reset,
    input cmp_flag,
    input [2:0] ctrl_flag,
    output reg [15:0] instruction,
    output ready,
    output [2:0] notification,
    //Instruction memory interface
    output [addr_size-1:0] inst_addr,
    input [float_size-1:0] inst_data_in,
    //Data memory interface
    output [$clog2(stack_depth)-1:0] stack_addr,
    output [float_size-1:0] stack_data_out,
    input [float_size-1:0] stack_data_in,
    output stack_write_en,
    //Register IO
    input [float_size-1:0] flt_in,
    output reg [float_size-1:0] flt_out
    );

    //The CU is represented with a finite state machine
    wire [5:0] opcode = instruction[14:];
    reg [addr_size-1:0] program_counter;
    reg [$clog2(stack_depth)-1:0] stack_pointer;
    always @ (posedge clk)
        if(!reset)
        begin
            state <= state_exec_swift;
            program_counter <= 0;
            instruction <= 0; //This is a nop instruction
            flt_out <= 0;
        end
        else
            case(state)
                `state_fetch_instruction: begin
                    if(enable_instruction_fetching)
                    begin
                        program_counter <= program_counter + 2; //Note: +2 as each instruction is on 2 bytes
                        instruction <= inst_data_in[15:0];
                        if(enable_execution && opcode == `OPP_SET)
                            state <= `state_exec_long_2;
                        else
                            state <= `state_exec_swift
                    end
                end
                `state_exec_swift: begin
                    if(enable_execution)
                    begin
                        case(opcode)
                            `OPP_PUSH: stack_pointer <= stack_pointer + 1; //Note: the writing in the stack is handled bellow
                            `OPP_POP: begin
                                flt_out <= stack_data_in;
                                stack_pointer <= stack_pointer - 1;
                            end
                            `OPP_JMP: program_counter <= inst_data_in; //TODO: conditional jump
                            `OPP_MOV: flt_out <= flt_in;
                            `OPP_CALL: begin
                                stack_pointer <= stack_pointer + 1;
                                program_counter <= inst_data_in;
                            end
                            `OPP_RET: begin
                                program_counter <= stack_data_in;
                                stack_pointer <= stack_pointer - 1;
                            end
                        endcase
                    end
                    state <= `state_fetch_instruction;
                end
                `state_exec_long_2: begin
                    state <= `state_exec_long_1;
                end
            endcase

    //Processing instructions
    //Notification
    wire notification_enabled = enable_execution && state == `state_exec_swift && opcode == `OPP_NOTIF;
    assign notification = ( notification_enabled ? ctrl_flag : 3'b0 );
    //Stack-related instructions
    wire write_in_stack = opcode == `OPP_PUSH || opcode == `OPP_CALL;
    assign stack_addr = ( write_in_stack ? stack_pointer + 1 : stack_pointer );
    assign stack_write_en = enable_execution && write_in_stack && state == `state_exec_swift;
    assign stack_data_out = ( opcode == `OPP_PUSH ? flt_in : program_counter + 2 );

endmodule



/*-----------------------------------\
|This is the core of the CU with some|
|memory and way to init the memory.  |
\-----------------------------------*/

module reflet_float_cu_core #(
    parameter float_size = 32,
    addr_size = 32,
    stack_depth = 128
    )(
    //Ctrl IO
    input clk,
    input enable_instruction_fetching,
    input enable_execution,
    input reset,
    input cmp_flag,
    input [2:0] ctrl_flag,
    output reg [15:0] instruction,
    output ready,
    output [2:0] notification,
    //Register IO
    input [float_size-1:0] flt_in,
    output reg [float_size-1:0] flt_out
    );

    module reflet_float_cu_core #(
        parameter float_size = 32,
        addr_size = 32,
        stack_depth = 128
        )(
        //Ctrl IO
        input clk,
        input enable_instruction_fetching,
        input enable_execution,
        input reset,
        input cmp_flag,
        input [2:0] ctrl_flag,
        output reg [15:0] instruction,
        output ready,
        output [2:0] notification,
        //Instruction memory interface
        output [addr_size-1:0] inst_addr,
        input [float_size-1:0] inst_data_in,
        //Data memory interface
        output [$clog2(stack_depth)-1:0] stack_addr,
        output [float_size-1:0] stack_data_out,
        input [float_size-1:0] stack_data_in,
        output stack_write_en,
        //Register IO
        input [float_size-1:0] flt_in,
        output reg [float_size-1:0] flt_out
        );
