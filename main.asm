global main
%include "macros.asm"


;TEST DE PRINT STATS
;=================
;%include "printStats.asm"
;section .data
;  t1 db 10,20,30,40,50,60,70,80, 35
;  t2 db 0,1,2,3,4,5,6,7, 20
;
;section .text
;
;main:
;    mov rdi, [t1]
;    mov sil, [t1+8]
;
;    mov rdx, [t2]
;    mov cl, [t2+8]
;    call printStats

;TEST DE GET INPUT
;=================
;%include "getUserPositionInput.asm"


;section .text
    ;main:
    ;    sub     rsp,    8
    ;    call    getUserPositionInput
    ;    add     rsp,    8
;    ret

section .data
  msg db "Hello, World!", 10, 0

section .text
  print msg


