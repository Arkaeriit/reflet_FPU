# Flags
#FLAGS := -Wall -g
FLAGS := -Wall -O3

# Commands
CC := gcc
RM := rm -rf

%.o : %.c
	$(CC) -c $< $(FLAGS) -o $@

all: fisqrt_tb.bin hex_to_float.bin finding_16b_magic_word.bin

hex_to_float.bin: hex_to_float.o
	$(CC) $^ $(FLAGS) -o $@

fisqrt_tb.bin: fisqrt_tb.o
	$(CC) $^ $(FLAGS) -o $@

finding_16b_magic_word.bin: finding_16b_magic_word.o half_float.o
	$(CC) $^ $(FLAGS) -lm -lpthread -o $@

clean:
	rm -f *.o
	rm -f *.bin

