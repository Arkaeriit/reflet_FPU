#include "half_float.h"

/*---------------------------------\
|Manipulating 16 bits float numbers|
|as a struct for opperations.      |
\---------------------------------*/

#include <stdbool.h>

typedef struct {
    bool sign;         //True if negative
    int8_t exponent;   //Biased exponent
    uint16_t mantissa; //Mantissa, including the starting 1
} half_float_s;

//Functions
static void half_float_comply(half_float_s* hf);
static void float_to_half_s(float f, half_float_s* hf);
static float half_s_to_float(const half_float_s* hf);


#define EXPONENT_SIZE      5
#define MANTISSA_SIZE      10// Note: this size does not take into account the first 1 in the struct
#define EXPONENT_BIAIS     15
#define MANTISSA_MASK      0x7FF
#define CUT_MANTISSA_MASK  0x3FF
#define EXPONENT_MASK      0x1F

#define F_32_EXPONENT_BIAIS 127
#define F_32_MANTISSA_SIZE  23
#define F_32_MANTISSA_MASK  0x7FFFFF
#define F_32_EXPONENT_MASK  0xFF

//use mask to constrain the value of a half_float
static void half_float_comply(half_float_s* hf){
    //Check exponent value
    int8_t unbiased_exponent = hf->exponent - EXPONENT_BIAIS;
    if(unbiased_exponent < -14){ //Set number to 0
        hf->exponent = -15 + EXPONENT_BIAIS;
        hf->mantissa = 0;
        return;
    }
    if(unbiased_exponent > 15){ //Set number to the max value
        hf->exponent = 15 + EXPONENT_BIAIS;
        hf->mantissa = ~0 & MANTISSA_MASK;
        return;
    }
    //Check mantissa value
    if(hf->mantissa & (uint16_t) ~MANTISSA_MASK){ //Mantissa too big
        uint16_t exccess_bits = hf->mantissa >> (MANTISSA_SIZE + 1);
        while(exccess_bits){
            exccess_bits = exccess_bits >> 1;
            hf->mantissa = hf->mantissa >> 1;
            hf->exponent++;
        }
    }
    while(!(hf->mantissa & (1 << MANTISSA_SIZE))){ //Mantissa too small
        hf->mantissa = hf->mantissa << 1;
        hf->exponent--;
    }
}

//Convert a float into an half float
static void float_to_half_s(float f, half_float_s* hf){
    union {
        uint32_t i;
        float f;
    } u;
    u.f = f;
    if(u.i & (1 << 31)){
        hf->sign = true;
    }else{
        hf->sign = false;
    }
    uint32_t mantissa = (u.i & F_32_MANTISSA_MASK) >> (F_32_MANTISSA_SIZE - MANTISSA_SIZE); //Mantissa without first 1, as in a float number
    hf->mantissa = mantissa | (1 << (MANTISSA_SIZE));
    int32_t exponent = ((u.i >> F_32_MANTISSA_SIZE) & F_32_EXPONENT_MASK) - F_32_EXPONENT_BIAIS;
    hf->exponent = exponent + EXPONENT_BIAIS;
    half_float_comply(hf);
}

//Convert a half_float into a float
static float half_s_to_float(const half_float_s* hf){
    int8_t unbiased_exponent = hf->exponent - EXPONENT_BIAIS;
    int16_t full_mantissa = hf->mantissa;
    float ret = full_mantissa;
    int16_t factor_power = unbiased_exponent - MANTISSA_SIZE + 1;
    if(factor_power <= 0){
        int64_t dividend_to_mantissa = 2 << -factor_power;
        ret /= dividend_to_mantissa;
    }else if(factor_power >= 2){
        int64_t factor_to_mantissa = 2 << (factor_power - 2);
        ret *= factor_to_mantissa;
    }
    if(hf->sign){
        ret *= -1;
    }
    return ret;
}

//Add two half floats
static void half_s_add(const half_float_s* in1, const half_float_s* in2, half_float_s* out){
    int64_t raw1 = (int64_t) in1->mantissa << (int64_t) in1->exponent;
    if(in1->sign) raw1 *= -1;
    int64_t raw2 = (int64_t) in2->mantissa << (int64_t) in2->exponent;
    if(in2->sign) raw2 *= -1;
    int64_t raw_res = raw1 + raw2;
    if(raw_res < 0){
        out->sign = true;
        raw_res *= -1;
    }else{
        out->sign = false;
    }
    out->exponent = 0;
    while(raw_res & (~MANTISSA_MASK)){
        out->exponent++;
        raw_res = raw_res >> 1;
    }
    out->mantissa = raw_res;
    half_float_comply(out);
}

/*--------------------------\
|Converting 16 bits number  |
|from the convinient struct.|
\--------------------------*/

//Convert the struct into 16 bits
static half_float_t struct_to_num(half_float_s* s){
    half_float_t ret = 0;
    ret |= s->mantissa & CUT_MANTISSA_MASK;
    ret |= (s->exponent & EXPONENT_MASK) << MANTISSA_SIZE;
    if(s->sign){
        ret |= 1 << 15;
    }
    return ret;
}

//Convert 16 bit number into the struct
static void num_to_struct(half_float_t num, half_float_s* s){
    if(num & (1 << 15)){
        s->sign = true;
    }else{
        s->sign = false;
    }
    if(!(num & (CUT_MANTISSA_MASK | (EXPONENT_MASK << MANTISSA_SIZE)))){
        s->exponent = 0;
        s->mantissa = 0;
        return;
    }
    s->mantissa = (num & CUT_MANTISSA_MASK) | (1 << MANTISSA_SIZE);
    s->exponent = (num >> MANTISSA_SIZE) & EXPONENT_MASK;
}

/*----------------------\
|Public API manipulating|
|the 16 bit numbers.    |
\----------------------*/

//Convert 32 bits floats into 16 bits ones
half_float_t float_to_half(float f){
    half_float_s s;
    float_to_half_s(f, &s);
    return struct_to_num(&s);
}

//Convert 16 bits floats into 32 bits ones
float half_to_float(half_float_t f){
    half_float_s s;
    num_to_struct(f, &s);
    return half_s_to_float(&s);
}

//Add two 16 bit floats
half_float_t half_float_add(half_float_t h1, half_float_t h2){
    half_float_s s1, s2, sRes;
    num_to_struct(h1, &s1);
    num_to_struct(h2, &s2);
    half_s_add(&s1, &s2, &sRes);
    return struct_to_num(&sRes);
}

//
// Some testing
//

#include "stdio.h"

void test_conv(float f){
    half_float_t hf = float_to_half(f);
    float conv = half_to_float(hf);
    printf("f: %f, conv: %f.\n", f, conv);
}

void test_add(float f1, float f2){
    half_float_t h1 = float_to_half(f1);
    half_float_t h2 = float_to_half(f2);
    half_float_t hRes = half_float_add(h1, h2);
    float fRes = half_to_float(hRes);
    printf("%f + %f = %f -> %f + %f = %f\n", f1, f2, f1+f2, half_to_float(h1), half_to_float(h2), fRes);  
}

int main(void){
    test_conv(1.5);
    test_conv(8.3);
    test_conv(3.3);
    test_conv(12.5);
    test_conv(120.2);
    test_conv(0.02);
    test_conv(0.0003);
    test_conv(25000.7);
    test_conv(750000.3);

    test_add(1.0, 2.0);
    test_add(1.82, 12.89);
    test_add(-30.0, 12.5);
    test_add(1000, -3000);
    test_add(1000, 0);

    return 0;
}

