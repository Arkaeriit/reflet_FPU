#include "half_float.h"
#include <math.h>
#include <stdio.h>

//Compute the fast inverse square root of a 16 bit floating point number, given a specific magic word
half_float_t fisqrt16(half_float_t number, uint16_t magic_number){	
	const half_float_t x2 = half_float_mult(number, float_to_half(0.5));
	const float threehalfs = float_to_half(1.5);
	half_float_t shift = magic_number - ( number >> 1 );
	return half_float_sub(threehalfs, half_float_mult(x2, half_float_mult(shift, shift)));
}

//This function compute the error in the computation of the fisqrt of a 16 bit float
double fisqrt_error(half_float_t number, uint16_t magic_number){
    double d_equiv = (double) half_to_float(number);
    double d_isqrt = 1/sqrt(d_equiv);
    half_float_t h_fisqrt = fisqrt16(number, magic_number);
    double d_fisqrt = (double) half_to_float(h_fisqrt);
    return fabs(d_isqrt - d_fisqrt);
}

//This function computes the average error of the fisqrt given a magic number
double average_error(uint16_t magic_number){
    double ret = 0;
    for(half_float_t number=0x400; number<=0x7FFF; number++){ //List all the valid positive floats
        double error = fisqrt_error(number, magic_number);
        ret += error;
        /*printf("Number: %04X Error: %f total: %f\n", number, error, ret);*/
    }
    return ret / (0x7FFF - 0x400);
}

//This function compute the magic number with the minimal average  error for the fisqrt
uint16_t best_magic_number(void){
    uint16_t magic = 0;
    uint16_t best_magic = 0;
    double min_error = average_error(magic);
    magic++;
    while(magic){
        printf("%04X\n", magic);
        double error = average_error(magic);
        if(error < min_error){
            min_error = error;
            best_magic = magic;
        }
        magic++;
    }
    return best_magic;
}

int main(void){
    printf("The best magic number for the 16 bits fisqrt is %X.\n", best_magic_number());
    return 0;
}

