
global main
%include "macros.asm"
%include "returnDirection.asm"

section .data
  msg db "The direction is: %li.", 10, 0

section .bss
  printNum resb 1

section .text
main:
    mov dil, 1
    mov sil, 1

    mov dh, 2
    mov dl, 1

    call returnDirection
    mov byte[printNum], al
    printArg msg, printNum
