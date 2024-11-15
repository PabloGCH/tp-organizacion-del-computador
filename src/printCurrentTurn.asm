
global printCurrentTurn
%include "macros.asm"

section .data
    msg db "Turno de: %s", 10, 0
    officer db "Oficial", 0
    soldier db "Soldado", 0
    newLine db 10, 0

section .bss
    playerType resb 1
section .text
printCurrentTurn:
    mov byte [playerType], dil
    print newLine
    mov rsi, soldier
    cmp byte [playerType], 0
    je printSoldier
    mov rsi, officer
printSoldier:
    mov rdi, msg
    sub rsp, 8
    call printf
    add rsp, 8
    ret