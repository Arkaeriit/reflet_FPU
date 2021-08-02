# Reflet FPU
Tools to handle floating-point numbers in synthesizable Verilog.

This repository contains basic blocs to so simple floating points operations, an arithmetic unit combining those blocs to do more complex operations (WIP), and a complete processor manipulating floating points numbers (TODO).

The various modules in this repository are designed to work with IEEE 754 floating-point numbers. The supported formats are half-precision, single-precision, and double-precision. All modules have a parameter named `float_size` that should be set to 16, 32, or 64 depending on the desired number type.

# Basic blocs
The modules doing simple floating points operation are in the `floating_points_operations` folder. The available operations are the following:
* Conversion from integer to floating-point number
* Conversion from floating-point number to integer
* Addition and subtraction
* Multiplication
* Fast inverse square root
* Comparison

## reflet\_int\_to\_float
This module takes as its input `int_in` a signed integer and converts it as a floating-point number `float_out`. The width of the integer `int_in` is defined by the parameter `int_size`.

## reflet\_float\_to int
This module is the opposite of `reflet float to int`. It takes as input the floating-point number `float_in` and converts it to a signed integer `int_out`. The size of the integer is controlled by the parameter `int_size`.

## reflet\_float\_add
This module can either add or subtract two floating-point numbers. The operation is chosen by two control signals, `enable_add` and `enable_sub`. If `enable_sub` is set to one, the output `sum` will contain the subtraction of `in1` by `in2`. If `enable_add` is set to on and `enable_sub` is set to 0, the output `sum` will contain the sum of `in1` and `in2`. If neither `enable_add` nor `enable_sub` are set to 1, the output `sum` will be set to 0.

## reflet\_float\_comp
This module is used to compare two floating-point numbers `in1` and `in2`. The result of the comparison is written on the port `out`. The comparison made depends on the input `order`.
* If `order` is set to `2'b00`, `out` will stay at 0.
* If `order` is set to `2'b01`, `out` will be set to 1 if both inputs are equals.
* If `order` is set to `2'b10`, `out` will be set to 1 if `in1` is strictly smaller than `in2`.
* If `order` is set to `2'b11`, `out` will be set to 1 if `in1` is smaller than or equal to `in2`.

## reflet\_float\_mult\_mult
The 4 previously described modules only contain combinatory logic. But, the fast inverse square root module and the multiplication module need to perform integer multiplication. The integer multiplication might or might not use sequential logic. You need to adapt the module so that it fit your design. You also need to adapt the value of the macro `multilication_time` so that it is equal to the number of clock cycles needed to perform the integer multiplication.

## reflet\_float\_mult
This module can multiply two floating-point numbers together. When enable is set to one, the output `mult` contains the product of the inputs `in1` and `in2`. When the integer multiplication needs at least a clock cycle to complete, the output `ready` sets itself to one when the product is calculated.

## reflet\_float\_fisqrt
This module computes the fast inverse square root of a floating-point number. If the input is a negative number, the output will be the opposite of the fast inverse square root of the opposite of the input.

# Aritmetic unit
WPI

# Floating point CPU
TODO

