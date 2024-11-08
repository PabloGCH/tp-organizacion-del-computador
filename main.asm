extern printStatistics

global main
%include "macros.asm"


section .data
  msg db "Hello, World!", 10, 0
  t1 db 0,1,2,3,4,5,6,7,8, 35
  t2 db 0,1,2,3,4,5,6,7,8, 35

section .text
main:
    mov rdi, t1
    mov rsi, t2
    call printStatistics
    ret

