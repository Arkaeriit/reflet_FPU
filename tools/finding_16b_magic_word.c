#include "half_float.h"
#include <math.h>
#include <stdio.h>
#include <threads.h>

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

//This function compute the magic number with the minimal average  error for the fisqrt in the given interval
//The minimal error can be aquiered from the pointer in the argument
uint16_t best_magic_number_range(uint16_t start, uint16_t stop, double* min_error_ret){
    uint16_t magic = start;
    uint16_t best_magic = start;
    double min_error = average_error(magic);
    magic++;
    while(magic && magic <= stop){
        /*printf("%04X\n", magic);*/
        double error = average_error(magic);
        if(error < min_error){
            min_error = error;
            best_magic = magic;
        }
        magic++;
    }
    *min_error_ret = min_error;
    return best_magic;
}

//This is a wraper over best_magic_number_range threadable
struct best_magic_thread_s {
    volatile double ret_err;
    volatile uint16_t ret_number;
    uint16_t start;
    uint16_t stop;
};
int best_magic_thread(void* arg_void){
    struct best_magic_thread_s* arg = arg_void;
    double ret_err;
    arg->ret_number = best_magic_number_range(arg->start, arg->stop, &ret_err);
    arg->ret_err = ret_err;
    return 0;
}

//This function runs a bunch of threads to find the best magic number
uint16_t best_magic_number(int thread_count){
    //Launchng threads
    struct best_magic_thread_s arg_list[thread_count];
    thrd_t thread_list[thread_count];
    for(int i=0; i<thread_count-1; i++){
        printf("Launched thread %i/%i.\n", i+1, thread_count);
        arg_list[i].start = ((uint64_t) 0xFFFF / (uint64_t) thread_count) * i;
        arg_list[i].stop = ((uint64_t) 0xFFFF / (uint64_t) thread_count) * (i+1) - 1;
        thrd_create(&thread_list[i], best_magic_thread, &arg_list[i]); 
    }
    arg_list[thread_count-1].start = ((uint64_t) 0xFFFF / (uint64_t) thread_count) * (thread_count - 1);
    arg_list[thread_count-1].stop = 0xFFFF;
    thrd_create(&thread_list[thread_count-1], best_magic_thread, &arg_list[thread_count-1]); 
    printf("Launched thread %i/%i.\n", thread_count, thread_count);
    //Getting the result
    thrd_join(thread_list[1], NULL);
    printf("Joined thread %i/%i.\n", 1, thread_count);
    uint16_t best_magic = arg_list[1].ret_number;
    double min_error = arg_list[1].ret_err;
    for(int i=1; i<thread_count; i++){
        thrd_join(thread_list[i], NULL);
        printf("Joined thread %i/%i.\n", i+1, thread_count);
        uint16_t magic = arg_list[i].ret_number;
        double error = arg_list[i].ret_err;
        if(error < min_error){
            best_magic = magic;
            min_error = error;
        }
    }
    return best_magic;
}

#define THREAD_NUMBER 4
int main(void){
    printf("The best magic number for the 16 bits fisqrt is %X.\n", best_magic_number(THREAD_NUMBER));
    return 0;
}

