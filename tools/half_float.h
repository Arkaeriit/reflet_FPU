#ifndef HALF_FLOAT_H
#define HALF_FLOAT_H

#include <stdint.h>

typedef uint16_t half_float_t;

//Conversions
half_float_t float_to_half(float f);
float half_to_float(half_float_t hf);

//Opperations
half_float_t half_float_add(half_float_t h1, half_float_t h2);
half_float_t half_float_mult(half_float_t h1, half_float_t h2);

#endif


