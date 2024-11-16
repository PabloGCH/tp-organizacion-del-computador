global main
%include "macros.asm"

extern statCounterGet
extern statCounterSet

section .data
    msg db "The value is: %li.", 10, 0
    array db 1,2,3,4,5,6,7,8,9 ; Array de 9 elementos, todos contienen 1

section .bss
    result resb 1

section .text

    main:
        lea rsi, array
        mov rdi, 2
        mov dl, 116
        call statCounterSet
        lea rsi, array
        mov rdi, 2
        call statCounterGet
        mov byte[result], al
        printArg msg, result

