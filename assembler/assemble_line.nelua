--[[---------------------------------
|This file contains the code used to|
|assemble a line of assembly code.  |
-----------------------------------]]

--Constants definitions
local args_choice = @enum {
    void = 0,
    flag,
    reg
}

--Flags value
local flag_conversion = @record {name: string, value: byte}
local flag_value: []flag_conversion <comptime> = {
    --Comparaison flags
    {"NO_CPM", 0},
    {"EQ", 1},
    {"LESS", 2},
    {"LESS_OR_EQ", 3},
    --Set sign flags
    {"N0_SIGN", 0},
    {"OPPOSITE", 1},
    {"ABS", 2},
    {"NEG", 3},
}


--This is the list of all possible instructions
--and their arguments
local instruction = @record {opcode: string, arguments: [3]args_choice, opcode: byte, arithmetic: boolean}
local instruction_list: []instruction <comptime> = {
    --Primitive math operations
    {"NOP",       {args_choice.void, args_choice.void, args_choice.void}, 0x00, true},
    {"ADD",       {args_choice.reg, args_choice.reg, args_choice.reg},    0x01, true},
    {"SUB",       {args_choice.reg, args_choice.reg, args_choice.reg},    0x02, true},
    {"MUL",       {args_choice.reg, args_choice.reg, args_choice.reg},    0x03, true},
    {"FISQRT",    {args_choice.reg, args_choice.reg, args_choice.void},   0x04, true},
    {"SET_SIGN",  {args_choice.reg, args_choice.flag, args_choice.reg},   0x05, true},
    {"CMP",       {args_choice.reg, args_choice.flag, args_choice.reg},   0x06, true},
    {"F_TO_I",    {args_choice.reg, args_choice.void, args_choice.void},  0x07, true},
    {"I_TO_F",    {args_choice.reg, args_choice.void, args_choice.void},  0x08, true},
    --Composite math operations
    {"INV",       {args_choice.reg, args_choice.reg, args_choice.void},   0x09, true},
    {"DIV",       {args_choice.reg, args_choice.reg, args_choice.reg},    0x0A, true},
    {"TRIMULT",   {args_choice.reg, args_choice.reg, args_choice.reg},    0x0B, true},
    {"CUBE",      {args_choice.reg, args_choice.reg, args_choice.void},   0x0C, true},
    {"TESSERACT", {args_choice.reg, args_choice.reg, args_choice.void},   0x0D, true},
    {"MULTADD",   {args_choice.reg, args_choice.reg, args_choice.reg},    0x0D, true},
    --Control Unit instructions
    {"PUSH",      {args_choice.reg, args_choice.void, args_choice.void},  0x00, false},
    {"POP",       {args_choice.reg, args_choice.void, args_choice.void},  0x01, false},
    {"NOTIF",     {args_choice.flag, args_choice.void, args_choice.void}, 0x02, false},
    {"MOV",       {args_choice.reg, args_choice.reg, args_choice.void},   0x03, false},
    {"SET",       {args_choice.reg, args_choice.reg, args_choice.void},   0x04, false},
    {"JMP",       {args_choice.flag, args_choice.void, args_choice.void}, 0x05, false},
    {"CALL",      {args_choice.void, args_choice.void, args_choice.void}, 0x06, false},
    {"RET",       {args_choice.void, args_choice.void, args_choice.void}, 0x07, false},
}

print("Patate")
print(#flag_value)
print(#instruction_list)

