#!/bin/bash

nasm \
-i include/ \
-i macros/  \
main.asm -f elf64 -o output/main.o

gcc output/main.o -o output/main.out -no-pie
chmod +x output/main.out
./output/main.out
