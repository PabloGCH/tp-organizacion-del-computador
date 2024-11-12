#!/bin/bash

nasm \
-i include/ \
-i macros/  \
main.asm -f elf64 \
-g -F dwarf -l output/main.lst \
-o output/main.o

gcc output/main.o -o output/main.out -no-pie

chmod +x output/main.out
gdb -q output/main.out
