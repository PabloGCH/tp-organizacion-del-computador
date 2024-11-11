#!/bin/bash

nasm \
-i include/ \
-i macros/  \
include/printBoard.asm -f elf64 -o output/main.o -g

gcc output/main.o -o output/main.out -no-pie
chmod +x output/main.out
./output/main.out
