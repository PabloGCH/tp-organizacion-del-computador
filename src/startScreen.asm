extern printf
extern gets
extern sscanf

extern system

%include "macros.asm"

section .data

    cmd_clear         db      "clear", 0

    startMessageOne   db 27, '[4mEl Asalto', 27, "[0m", 10, 10, 10,0
    startMessageTwo   db '[1] - Nueva Partida', 10, 0
    startMessageThree db '[2] - Cargar Partida', 10, 0
    startMessageFour  db '[3] - Opciones', 10, 0
    startMessageFive  db '[0] - Salir', 10, 0
    startMessageInput db 10, 'Ingrese el numero de su opcion deseada: ', 0
    startMessageError db 'Input invalido, por favor ingrese un numero valido', 10, 0

    startFormatInput db "%d"

section .bss

    startUserChoiceString resq 1 ; Qword por si acaso, pero con byte deberia alcanzar
    startUserChoiceNumber resb 1


section .text

    global startScreen
    startScreen:
        ;command cmd_clear
        mov rdi, startMessageOne
        sub rsp, 8
        call printf

        mov rdi, startMessageTwo
        call printf

        mov rdi, startMessageThree
        call printf

        mov rdi, startMessageFour
        call printf

        mov rdi, startMessageFive
        call printf

        startScreenInput:
            mov rdi, startMessageInput
            call printf
            mov rdi, startUserChoiceString
            call gets

            mov rdi, startUserChoiceString
            mov rsi, startFormatInput
            mov rdx, startUserChoiceNumber
            call sscanf

            cmp byte[startUserChoiceNumber], 0
            jl startScreenError
            cmp byte[startUserChoiceNumber], 3
            jg startScreenError
            mov al, byte[startUserChoiceNumber]
            add rsp, 8
            ret
            

        startScreenError:
            mov rdi, startMessageError
            call printf
            jmp startScreenInput
