#!/bin/bash
set -e

for file in *.asm; do
    nasm -f elf32 "$file" -o "${file%.asm}.o"
done


gcc -m32 -no-pie main.c *.o -o printf

#chmod +x build.sh

