extern statCounterGet
extern statCounterAdd
extern statCounterSet
extern statCounterPrint

section .data

section .bss

section .text

global main
main:
    mov rdi, 0
    mov rsi, 0
    mov dl, 10
    call statCounterSet
    call statCounterPrint