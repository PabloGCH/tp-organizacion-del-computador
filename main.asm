
global main
%include "macros.asm"
%include "getUserPositionInput.asm"


section .text
main:
    sub     rsp,    8
    call    getUserPositionInput
    add     rsp,    8
    ret
    
