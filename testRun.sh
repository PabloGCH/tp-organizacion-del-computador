#!/bin/bash


for filename in src/*.asm; do
  basename="${filename%.*}"
  nasm -g -i macros/ $filename -f elf64 -o output/$basename.o
done

nasm -g -i macros/ testMain.asm -f elf64 -o output/main.o

gcc output/src/*.o output/main.o -o output/main.out -no-pie

chmod +x output/main.out
./output/main.out
