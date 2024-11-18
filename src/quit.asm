global quit
global printQuitMessage
extern printf
section .data
    msgQuit db 27,'[90mIngrese "Quit" para salir',27,"[0m", 10, 0
section .text
quit:
    mov rdi, 0
    mov rax, 60 ; sys_exit
    syscall
    ret

printQuitMessage:
    mov rdi, msgQuit
    sub rsp, 8
    call printf
    add rsp, 8
    ret