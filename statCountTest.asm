global main
%include "macros.asm"

extern statCounterGet
extern statCounterSet

extern statCounterAdd

section .data

section .bss
    result resq 1

section .text

    main:
        mov rdi, 0
        mov rsi, 0
        mov dl, 5
        call statCounterSet
        mov rdi, 0
        mov rsi, 0
        call statCounterGet