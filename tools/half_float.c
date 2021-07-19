#include "half_float.h"

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
void half_float_comply(half_float_t* hf){
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
void float_to_half(float f, half_float_t* hf){
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
float half_to_float(const half_float_t* hf){
    int8_t unbiased_exponent = hf->exponent - EXPONENT_BIAIS;
    int16_t full_mantissa = hf->mantissa;
    float ret = full_mantissa;
    int16_t factor_power = unbiased_exponent - MANTISSA_SIZE + 1;
    if(factor_power > 0){
        int64_t factor_to_mantissa = 2 << factor_power;
        ret *= factor_to_mantissa;
    }else{
        int64_t dividend_to_mantissa = 2 << -factor_power;
        ret /= dividend_to_mantissa;
    }
    if(hf->sign){
        ret *= -1;
    }
    return ret;
}

#include "stdio.h"
void test(float f){
    half_float_t hf;
    float_to_half(f, &hf);
    float conv = half_to_float(&hf);
    printf("f: %f, conv: %f.\n", f, conv);
}

int main(void){
    test(1.5);
    test(8.3);
    test(3.3);
    test(12.5);
    test(120.2);
    test(0.02);
    return 0;
}

