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
    stack_addr_size = 32,
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
    output [float_size-1:0] inst_addr,
    input [float_size-1:0] inst_data_in,
    //Data memory interface
    output [stack_addr_size-1:0] stack_addr,
    output [float_size-1:0] stack_data_out,
    input [float_size-1:0] stack_data_in,
    output stack_write_en,
    //Register IO
    input [float_size-1:0] flt_in,
    output reg [float_size-1:0] flt_out
    );

    //The CU is represented with a finite state machine
    reg [3:0] state;
    wire [5:0] opcode = instruction[14:9];
    reg [float_size-1:0] program_counter;
    reg [$clog2(stack_depth)-1:0] stack_pointer;
    always @ (posedge clk)
        if(!reset)
        begin
            state <= `state_exec_swift;
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
                            state <= `state_exec_swift;
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

module reflet_float_cu #(
    parameter float_size = 32,
    data_depth = 128,
    instruction_depth = 128
    )(
    //Ctrl IO
    input clk,
    input enable_instruction_fetching,
    input enable_execution,
    input reset,
    input cmp_flag,
    input [2:0] ctrl_flag,
    output [15:0] instruction,
    output ready,
    output [2:0] notification,
    //Register IO
    input [float_size-1:0] flt_in,
    output [float_size-1:0] flt_out,
    //Writing the instructions from the outside
    input writing_instructions,
    input [15:0] instruction_feed,
    input instruction_write_en
    );

    localparam byte_in_float = float_size / 8;
    localparam addr_size = float_size - (byte_in_float-1);

    //Core module
    //Instruction memory interface
    wire [float_size-1:0] inst_addr;
    wire [float_size-1:0] inst_data_in;
    //Data memory interface
    wire [addr_size-1:0] stack_addr;
    wire [float_size-1:0] stack_data_out;
    wire [float_size-1:0] stack_data_in;
    wire stack_write_en;
    reflet_float_cu_core #(
        .float_size(float_size),
        .stack_addr_size(addr_size),
        .stack_depth(data_depth)
    ) core (
        //Ctrl IO
        .clk(clk),
        .enable_instruction_fetching(enable_instruction_fetching),
        .enable_execution(enable_execution),
        .reset(reset),
        .cmp_flag(cmp_flag),
        .ctrl_flag(ctrl_flag),
        .instruction(instruction),
        .ready(ready),
        .notification(notification),
        //Instruction memory interface
        .inst_addr(inst_addr),
        .inst_data_in(inst_data_in),
        //Data memory interface
        .stack_addr(stack_addr),
        .stack_data_out(stack_data_out),
        .stack_data_in(stack_data_in),
        .stack_write_en(stack_write_en),
        //Register IO
        .flt_in(flt_in),
        .flt_out(flt_out));

    //Data memory
    reflet_ram #(
        .addrSize(addr_size),
        .dataSize(float_size),
        .size(data_depth),
        .resetable(0)
    ) data_ram (
        .clk(clk),
        .reset(reset),
        .enable(1'b1), //TODO: enable??
        .addr(stack_addr),
        .data_in(stack_data_out),
        .data_out(stack_data_in),
        .write_en(stack_write_en));

    //Instruction writting machine
    reg [float_size-1:0] instruction_write_addr;
    always @ (posedge clk)
        if(!writing_instructions)
            instruction_write_addr <= 0;
        else
            if(instruction_write_en)
                instruction_write_addr <= instruction_write_addr + 2; //Note: +2 as the instructions are 2 byte wide

    //Instrucion data connections
    wire [float_size-1:0] used_instruction_addr = ( writing_instructions ? instruction_write_addr : inst_addr );
    wire [float_size-1:0] fixed_instruction_addr;
    wire [float_size-1:0] fixed_instruction_feed;
    wire [float_size-1:0] raw_instruction_in;
    wire fixed_instruction_write_en;
    reflet_alignement_fixer #(
        .word_size(float_size),
        .addr_size(float_size)
    ) alignement_fixer (
        .clk(clk),
        .size_used(0 /*TODO*/),
        .ready(), //Unused for now...
        .alignement_error(), //Unused for now...
        //CU/outside bus
        .cpu_addr(used_instruction_addr),
        .cpu_data_out(instruction_feed),
        .cpu_data_in(inst_data_in),
        .cpu_write_en(instruction_write_en),
        //RAM bus
        .ram_addr(fixed_instruction_addr),
        .ram_data_out(fixed_instruction_feed),
        .ram_data_in(raw_instruction_in),
        .ram_write_en(fixed_instruction_write_en));

    //Instruction RAM
    reflet_ram #(
        .addrSize(addr_size),
        .dataSize(float_size),
        .size(instruction_depth),
        .resetable(0)
    ) inst_ram (
        .clk(clk),
        .reset(reset),
        .enable(1'b1), //TODO: enable???
        .addr(fixed_instruction_addr[float_size-1:byte_in_float-1]), //TODO: cut unused bits
        .data_in(fixed_instruction_feed),
        .data_out(raw_instruction_in),
        .write_en(fixed_instruction_write_en));

endmodule

