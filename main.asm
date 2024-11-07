
global main
%include "macros.asm"


section .data
  msg db "Hello, World!", 10, 0

section .text
main:
    print msg
    ret
    
