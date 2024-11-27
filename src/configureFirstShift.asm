global configureFirstShift

extern printf
extern system
%include "macros.asm"

section .data
    cmd_clear db "clear", 0
    menuMessage db "Seleccione el jugador que iniciará la partida: ", 10, 10,\
                 "1 - Soldado", 10, \
                 "2 - Oficial", 10, 10, \
                 "0 - Cancelar", 10, 10, \
                 "Ingrese el numero correspondiente: ", 0
    newLine db 10,0

section .bss
    shiftDir resq 1
    currentShift resb 1

section .text

configureFirstShift:
    mov [shiftDir], rdi

    sub rsp, 8
    call printShiftsOptions
    add rsp, 8

    ret

setNewShift:
    mov byte [currentShift], 0
    mov rax, [shiftDir]
    mov bl, [currentShift]
    mov byte [rax], bl
    ret

printShiftsOptions:
    
    command cmd_clear
    print menuMessage
    
    ; print newLine
    ; print stShifts
    ; print newLine
    ; print stShiftsOptions
    ; print newLine
    ret