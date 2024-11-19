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
    sub rsp, 8
    call statCounterSet
    add rsp, 8
    sub rsp, 8
    call statCounterPrint
    add rsp, 8
    ret
