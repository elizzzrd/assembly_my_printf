#!/bin/bash
set -e

nasm -f elf32 my_printf.asm -o my_printf.o
nasm -f elf32 test.asm -o test.o
nasm -f elf32 buffer.asm -o buffer.o
nasm -f elf32 handlers.asm -o handlers.o
ld -m elf_i386 test.o my_printf.o buffer.o handlers.o -o test

./test

