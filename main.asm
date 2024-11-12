
global main
%include "macros.asm"
%include "receiveUserPositionInputs.asm"


section .text
main:
    sub     rsp,    8
    call    receiveUserPositionInputs
    add     rsp,    8
    ret
    
