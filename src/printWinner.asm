global printWinner

extern printf

section .data
    officer db "Oficiales", 0
    soldier db "Soldados", 0
    newLine db 10, 0
    winnerMessage db "+----------------------------+", 10, \
                     "|      Juego finalizado      |", 10, \
                     "+----------------------------+", 10, \
                     "|                            |", 10, \
                     "|     Ganan los %-9s    |", 10, \
                     "|                            |", 10, \
                     "+----------------------------+", 10, 0

section .bss
    character resb 1
section .text

printWinner:
    mov byte [character], dil
    mov rsi, soldier
    cmp byte [character], 0
    je skipOfficer
    mov rsi, officer
skipOfficer:
    mov rdi, winnerMessage
    sub rsp, 8
    call printf
    add rsp, 8
    ret