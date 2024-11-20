extern saveGame

section .data
    matriz    times 49 db 1
    stats     times 18 db 2
    fortress  times 4  db 3
    fortressD times 1  db 4
    character times 1  db "AB ", 0

section .bss


section .text

    global main
    main:
        mov rdi, matriz
        mov rsi, stats
        mov rdx, fortress
        mov r8b, byte[fortressD]
        mov CX,  word[character]
        sub rsp, 8
        call saveGame
        add rsp, 8