global configureFirstShift

extern printf
extern system
%include "macros.asm"

section .data
    cmd_clear db "clear", 0
    menuText db "Seleccione el jugador que iniciará la partida: ", 10, 10,\
                 "[1] - Soldado", 10, \
                 "[2] - Oficial", 10, 10, \
                 "[0] - Cancelar", 10, 0
    inputMessage db "Ingrese el numero correspondiente: ", 0
    inputFormat db "%hhd", 0
    inputErrorMessage db "Error: El dato ingresado no es válido.", 0
    newLine db 10,0

section .bss
    shiftDir resq 1
    currentShift resb 1
    input resb 100
    optionSelected resb 1

section .text

 ; Precondiciones:
 ; - rdi debe contener la dirección de memoria donde se almacenará el turno.
 ;
 ; Postcondiciones:
 ; - Se mostrará el menú de opciones para seleccionar el turno.
 ; - La dirección de memoria apuntada por rdi contendrá el valor elegido por el usuario (en caso de hacerlo).

configureFirstShift:
    mov [shiftDir], rdi

    sub rsp, 8
    call printShiftsOptions
    add rsp, 8

menuLoop:

    print newLine
    print inputMessage

    mov     rdi,    input
    sub     rsp,    8
    call    gets
    add     rsp,    8

    mov     rdi,    input
    mov     rsi,    inputFormat

    mov     rdx,    optionSelected

    sub     rsp,    8
    call    sscanf
    add     rsp,    8

    cmp al, 1
    jne inputError

    cmp byte [optionSelected], 0
    jl inputError
    je returnToMainMenu

    cmp byte [optionSelected], 2
    jg inputError

    mov dil, [optionSelected]
    sub dil, 1
    sub rsp, 8
    call setNewShift
    add rsp, 8

    jmp returnToMainMenu
printShiftsOptions:
    command cmd_clear
    print menuText
    ret

inputError:
    print inputErrorMessage
    jmp menuLoop

setNewShift:
    mov rax, [shiftDir]
    mov byte [rax], dil
    ret

returnToMainMenu:
    ret