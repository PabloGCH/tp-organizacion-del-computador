
section .data
    stMovements db "Direcciones", 10, 0
    movements db '7', '0', '1', '6', ' ', '2', '5', '4', '3', '3', 0
    mBoxLine db "+---+---+---+", 10, 0
    mBoxFormat db "| %c | %c | %c |", 10, 0
    mBoxOffset dq 0
    mCounter db 3
    stTitle db "Estadísticas de los oficiales:", 10, 0
    mBoxOfficersLine db "+-----------+-----------+-----------+", 10, 0
    mBoxOfficersTitle db "|           | Oficial 1 | Oficial 2 |", 10, 0
    mBoxOfficersFormat db "| DIR - %-3d | %-9hhi | %-9hhi |", 10, 0
    mBoxOfficersKillsFormat db "| CAPTURAS  | %-9hhi | %-9hhi |", 10, 0
    newLine db 10, 0

section .bss
    officerOne resb 9
    officerTwo resb 9
section .text
    global printStats

printStats:
    ;Guarda los valores de los oficiales
    mov rax, [rdi]
    mov [officerOne], rax
    mov al, [rdi+8]
    mov [officerOne+8], al

    mov rax, [rsi]
    mov [officerTwo], rax
    mov al, [rsi+8]
    mov [officerTwo+8], al
    ;Fin de guardar los valores de los oficiales

    call printMovementsBox

    call printOfficerStats

    ret

printMovementsBox:
    print newLine
    print stMovements
    print newLine

printMovementsBoxLoop:
    mov bl, [mCounter]
    cmp bl, 0
    jle finBoxLoop

    mov rbx, [mBoxOffset]
    print mBoxLine

    mov rdi, mBoxFormat
    mov rsi, [movements + rbx]
    inc rbx
    mov rdx, [movements + rbx]
    inc rbx
    mov rcx, [movements + rbx]
    inc rbx
    mov [mBoxOffset], rbx
    sub rsp, 8
    call printf
    add rsp, 8

    dec byte [mCounter]
    jmp printMovementsBoxLoop

finBoxLoop:
    print mBoxLine
    ret

printOfficerStats:
    print newLine
    print stTitle
    print newLine
    print mBoxOfficersLine
    print mBoxOfficersTitle
    print mBoxOfficersLine
    mov byte [mCounter], 0

loopOfficerMovements:
    mov rbx, 0
    mov bl, [mCounter]
    cmp bl, 8
    jge finOfficerMovementsLoop

    mov rdi, mBoxOfficersFormat
    mov rsi, rbx
    mov rdx, [officerOne + rbx]
    mov rcx, [officerTwo + rbx]
    sub rsp, 8
    call printf
    add rsp, 8
    inc byte [mCounter]
    jmp loopOfficerMovements

finOfficerMovementsLoop:
    print mBoxOfficersLine
    mov rbx, 0
    mov bl, [mCounter]
    cmp bl, 8
    mov rdi, mBoxOfficersKillsFormat
    mov rsi, rbx
    mov rdx, [officerOne + rbx]
    mov rcx, [officerTwo + rbx]
    sub rsp, 8
    call printf
    add rsp, 8
    print mBoxOfficersLine

    ret
