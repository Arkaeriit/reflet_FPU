#include <stdio.h>
#include <inttypes.h>

uint32_t float_to_hex(float number){
	union {
		float f;
		uint32_t i;
	} conv  = { .f = number };
	return conv.i;
}

float fisqrt( float number )
{	
	const float x2 = number * 0.5F;
    printf("Half: %" PRIX32 ".\n", float_to_hex(x2));
	const float threehalfs = 1.5F;
    printf("Treehalfs: %" PRIX32 ".\n", float_to_hex(threehalfs));

	union {
		float f;
		uint32_t i;
	} conv  = { .f = number };
	conv.i  = 0x5F375A86 - ( conv.i >> 1 );
    printf("Shifted masked: %" PRIX32 ".\n", float_to_hex(conv.f));
    float square = conv.f * conv.f;
    printf("Square: %" PRIX32 ".\n", float_to_hex(square));
    float product = x2 * square;
    printf("Product: %" PRIX32 ".\n", float_to_hex(product));
    float sub = threehalfs - product;
    printf("Sub: %" PRIX32 ".\n", float_to_hex(sub));
    float ret = conv.f * sub;
    printf("Ret: %" PRIX32 ".\n\n", float_to_hex(ret));
    return ret;
}

void fisqrt_tb(int32_t in){
    float flt_in = (float) in;
    float flt_tmp = fisqrt(flt_in);
    float flt_out = fisqrt(flt_tmp);
    uint32_t out = (int32_t) flt_out;
    printf("In: %" PRId32 "; out: %" PRId32 "; flt_in: %" PRIX32 "; flt_tmp %" PRIX32 "; flt_out %" PRIX32 ".\n", in, out, float_to_hex(flt_in), float_to_hex(flt_tmp), float_to_hex(flt_out));
}

int main(void){
    fisqrt_tb(654);
    return 0;
    fisqrt_tb(897);
    fisqrt_tb(7654);
    fisqrt_tb(1245);
    fisqrt_tb(8765);
    fisqrt_tb(98456);
    fisqrt_tb(87642);
    fisqrt_tb(54329);
    fisqrt_tb(876389);
    fisqrt_tb(235975);
    return 0;
}

