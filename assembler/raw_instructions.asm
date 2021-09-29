nop ;This file contains a list of alternating valid and invalid instructions
nop R1 ;Too much arg
add R2 R1 R0
add R2 R3 ;Not enought args
sub R5 R4 R3
sub R4 EQ R5 ;Flag instead of register
mul R3 R2 R1
mul R3 R4 R5 R6 ;Too much arg
fisqrt R2 R3
fisqrt R2 R9 ;Invalid register
