extern saveGame
extern loadGame

section .data
    ;matriz      times 49 db 1
    ;stats       times 18 db 2
    ;fortressL   times 4  db 3
    ;fortressD   times 1  db 4
    ;currentTurn times 1  db 5
    ;character   times 1  db "AB ", 0

section .bss

    matriz      resb 49
    stats       resb 18
    fortressL   resb 4
    fortressD   resb 1
    currentTurn resb 1
    character   resb 2

section .text

    global main
    main:
        mov rdi, matriz
        mov rsi, stats
        mov rdx, fortressL
        mov rcx, fortressD
        mov r8, currentTurn
        mov r9,  character
        sub rsp, 8
        call loadGame
    finalDeTodo:
        add rsp, 8
        ret