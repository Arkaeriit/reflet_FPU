/*------------------------------------\
|This file contains various constant  |
|used by the floating point processor.|
\------------------------------------*/

`ifndef reflet_fpu
`define reflet_fpu

//Arithmetic unit opcodes
//Primitives
`define OPP_NOP       6'h00
`define OPP_ADD       6'h01
`define OPP_SUB       6'h02
`define OPP_MUL       6'h03
`define OPP_FISQRT    6'h04
`define OPP_CMP       6'h05

//Combined operations
`define OPP_INV       6'h06
`define OPP_DIV       6'h07
`define OPP_TRIMULT   6'h08
`define OPP_CUBE      6'h09
`define OPP_TESSERACT 6'h0A
`define OPP_MULTADD   6'h0B

`endif
