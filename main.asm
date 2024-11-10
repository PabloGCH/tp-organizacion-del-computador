
global main
%include "macros.asm"
%include "printStats.asm"

section .data
  msg db "Hello, World!", 10, 0
  t1 db 10,20,30,40,50,60,70,80, 35
  t2 db 0,1,2,3,4,5,6,7, 20

section .text
main:
    mov rdi, [t1]
    mov sil, [t1+8]

    mov rdx, [t2]
    mov cl, [t2+8]
    call printStats
    ret
