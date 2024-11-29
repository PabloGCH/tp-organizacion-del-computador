global quit
global printQuitMessage
extern printf
extern statCounterPrint

section .data
    msgQuit db 27,'[90mIngrese "Quit" para salir',27,"[0m", 10, 0
section .text
quit:
    sub rsp, 8
    call statCounterPrint
    add rsp, 8
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