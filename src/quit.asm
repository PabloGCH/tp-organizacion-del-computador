
section .data
    sys_exit db 60
section .text
global quit
quit:
    mov rdi, 0
    mov rax, [sys_exit]
    syscall