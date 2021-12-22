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

## reflet\_set\_sign
This module is used to change the sign of a floating-point number. The effect on the sign is controlled by the input `order`.

* If `order` is set to `2'b00`, `out` will be set to 0.
* If `order` is set to `2'b01`, `out` will be the opposite of `in`.
* If `order` is set to `2'b10`, `out` will have the same absolute value as `in` but will be positive.
* If `order` is set to `2'b11`, `out` will have the same absolute value as `in` but will be negative.

## reflet\_float\_mult\_mult
The 4 previously described modules only contain combinatory logic. But, the fast inverse square root module and the multiplication module need to perform integer multiplication. The integer multiplication might or might not use sequential logic. You need to adapt the module so that it fit your design. You also need to adapt the value of the macro `multilication_time` so that it is equal to the number of clock cycles needed to perform the integer multiplication.

## reflet\_float\_mult
This module can multiply two floating-point numbers together. When enable is set to one, the output `mult` contains the product of the inputs `in1` and `in2`. When the integer multiplication needs at least a clock cycle to complete, the output `ready` sets itself to one when the product is calculated.

## reflet\_float\_fisqrt
This module computes the fast inverse square root of a floating-point number. If the input is a negative number, the output will be the opposite of the fast inverse square root of the opposite of the input.

# Aritmetic unit
The arithmetic unit combines the basic operation to perform various computations. This module is at the heart of the Reflet FPU but it could be used on its own in a design. 

The AU (arithmetic unit) takes tree floating-point numbers as input (`flt_in1`, `flt_in2`, and `flt_in3`) and transforms them into the output `flt_out`. The AU also got a additional input `ctrl_flag` that is used as the order input for the `reflet_float_set_sign` module and the `reflet_float_comp` module. If some operation needs a clock cycle or more to be performed the `ready` output is set to 0 until the output is stable and usable. The AU is also capable of doing conversion between floating-point numbers and integers. To do so, the input `int_out` and the output `int_out`. Lastly, if the integer multiplier needs sequential logic, there's is a clock input. To shut down the AU, set the `enable` output to 0 and set it to 1 to run it.

## Opcodes
The operation made by the AU is chosen by the `opcode` input. 

Here is the list of available operations:

| Mnemonic  | Opcode  | Effect                                            |
|-----------|---------|---------------------------------------------------|
| NOP       | `6'h00` | No effects                                        |
| ADD       | `6'h01` | Set the output to `flt_in1 + flt_in2`             |
| SUB       | `6'h02` | Set the output to `flt_in1 - flt_in 2`            |
| MUL       | `6'h03` | Set the output to `flt_in1 * flt_in 2`            |
| FISQRT    | `6'h04` | Set the output to `1/sqrt(flt_in1)`               |
| SET\_SIGN | `6'h05` | Set the output to the output of the set\_sign module. The input of this module is `flt_in1` and its order is `ctrl_flag`. |
| CMP       | `6'h06` | Put `flt_in1` and `flt_in3` into the comparaison module. The order is set by `ctrl_flag` and the result will be on `cmp_flag`. |
| F\_T\_I   | `6'h07` | Set the `int_out` to the conversion of `flt_in1`. |
| I\_T\_F   | `6'h08` | Set the output to the conversion of `int_in`.     |
| INV       | `6'h09` | Set the output to `1/flt_in1`.                    |
| DIV       | `6'h0A` | Set the output to `flt_in1/flt_in2`.              |
| TRIMULT   | `6'h0B` | Set the output to `flt_in1 * flt_in2 * flt_in3`.  |
| CUBE      | `6'h0C` | Set the output to `flt_in1 ^ 3`.                  |
| TESSERACT | `6'h0D` | Set the output to `flt_in1 ^ 4`.                  |
| MULTADD   | `6'h0E` | Set the output to `flt_in1 * flt_in2 + flt_in3`.  |

The `INV` and `DIV` operations are using the fast inverse square root module. Thus, the result might be slightly inaccurate sometimes.

# Floating point CPU
TODO

