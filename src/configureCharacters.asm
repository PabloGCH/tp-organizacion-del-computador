global configureCharacters

extern printf
extern scanf
%include "macros.asm"

section .data
    cmd_clear db "clear", 0
    title db "Configuración de jugadores", 10, 0
    soldier db "Soldado", 0
    officer db "Oficial", 0
    inputMessage db "Ingrese el símbolo para el %s (%c): ", 0
    inputFormat db "%c", 0
    inputErrorMessage db "Error: El dato ingresado no es válido.", 0
    newLine db 10, 0

section .bss
    charactersDir resq 1
    input resb 100
    character resb 1
    currentCharacter resw 1
    printCharacter resw 8

section .text

; Precondiciones:
; - rdi debe contener la dirección de memoria donde se almacenará la representación de las fichas en el tablero.
;
; Postcondiciones:
; - Se solicitará al usuario que ingrese los símbolos para el soldado y el oficial.
; - Los símbolos ingresados se almacenarán en las direcciones de memoria proporcionadas.
configureCharacters:
    mov [charactersDir], rdi
    command cmd_clear
    print title

    sub rsp, 8
    call configureSoldier
    add rsp, 8

    sub rsp, 8
    call configureOfficer
    add rsp, 8

    ret

configureSoldier:
    mov r8, [charactersDir]
    mov r9, [r8]
    mov [currentCharacter], r9w

    mov rdi, [soldier]

    sub rsp, 8
    call requestCharacter
    add rsp, 8

    mov r8, [charactersDir]
    mov [r8], al

    ret
configureOfficer:
    mov r8, [charactersDir]
    inc r8
    mov r9, [r8]
    mov [currentCharacter], r9w

    mov rdi, [officer]

    sub rsp, 8
    call requestCharacter
    add rsp, 8

    mov r8, [charactersDir]
    inc r8
    mov [r8], al
    ret
requestCharacter:
    mov [printCharacter], rdi
requestCharacterLoop:
    print newLine
    mov rdi, inputMessage
    mov dl, [currentCharacter]
    mov rsi, printCharacter

    sub rsp, 8
    call printf
    add rsp, 8

    mov     rdi,    input
    sub     rsp,    8
    call    gets
    add     rsp,    8

    cmp byte [input + 1 ], 0
    jne inputError

    cmp byte [input], 0
    je skipConfig

    mov     rdi,    input
    mov     rsi,    inputFormat

    mov     rdx,    character

    sub     rsp,    8
    call    sscanf
    add     rsp,    8

    cmp al, 1
    jne inputError

    mov al, [character]
    ret

inputError:
    print inputErrorMessage
    jmp requestCharacterLoop

skipConfig:
    mov al, [currentCharacter]
    ret

returnToMainMenu:
    ret