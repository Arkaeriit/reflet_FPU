#ifndef HALF_FLOAT_H
#define HALF_FLOAT_H

#include <stdint.h>
#include <stdbool.h>

typedef struct {
    bool sign;         //True if negative
    int8_t exponent;  //Biased exponent
    uint16_t mantissa; //Mantissa, including the starting 1
} half_float_t;

//Constrict the value of a half float by masking its fields
void half_float_comply(half_float_t* hf);

//Conversions
void float_to_half(float f, half_float_t* hf);
float half_to_float(const half_float_t* hf);

#endif


