#include <stdio.h>
#include <inttypes.h>

float hex_to_float(uint32_t number){
	union {
		float f;
		uint32_t i;
	} conv  = { .i = number };
	return conv.f;
}

int main(int argc, char** argv){
    if(argc <= 1){
        printf("Usage: hex_to_float <input1> <intput2> ...\n"
               "   print each hexadecimal number as a floating point number.\n");
        return 1;
    }
    for(int i=1; i<argc; i++){
        uint32_t input;
        sscanf(argv[i], "%" PRIx32, &input);
        printf("Hex: %" PRIx32 " -> float: %f\n", input, hex_to_float(input));
    }
    return 0;
}

