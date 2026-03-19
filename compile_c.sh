#!/bin/bash

echo "Compiling C code for RV32I Bare-Metal..."

# 1. Compile C to ELF
# -march=rv32i: Only use basic 32-bit integer instructions
# -mabi=ilp32: 32-bit variable sizes
# -nostdlib -ffreestanding: Do not include OS libraries (like printf)
# -T link.ld: Use our custom memory map starting at 0x0
# 2. Convert ELF to Verilog Hex
riscv64-unknown-elf-gcc -O1 -fno-toplevel-reorder -march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -T link.ld -o program.elf main.c
# --verilog-data-width=4 groups bytes into 32-bit chunks for your INST_MEM
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 program.elf program.hex
sed -i '1{d}' program.hex
sed -i '${a FFFFFFFF
}' program.hex
sed -i 's/ /\n/g' program.hex
sed -i 's/@//g' program.hex
echo "Success! program.hex generated."
cat program.hex
