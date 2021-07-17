/*----------------------------------------------\
|This file contain various function to compute  |
|size-variable constants for IEEE 754 floating  |
|points number. Currentely, only half-precision,|
|single-precision and double-precision.         |
\----------------------------------------------*/

function automatic integer exponent_size(input integer float_size);
    case(float_size)
        16 : exponent_size = 5;
        32 : exponent_size = 8;
        64 : exponent_size = 11;
        default : exponent_size = 8;
    endcase
endfunction

function automatic integer mantissa_size(input integer float_size);
    mantissa_size = float_size - 1 - exponent_size(float_size);
endfunction

function automatic integer exponent_bias(input integer float_size);
    exponent_bias = 2 ** (exponent_size(float_size)-1) - 1;
endfunction

