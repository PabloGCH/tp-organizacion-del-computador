global main
%include "../macros/macros.asm"

section .data
    stMovements db "Direcciones", 10, 10, 0
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

    officerOne db 5,2,5,6,72,1,2,2,8
    officerTwo db 0,1,2,3,4,5,6,7,8
    saltoLinea db 10, 0
section .bss
    ;officerOne resb 9
    ;officerTwo resb 9
    officerAux resb 9
section .text
main:
    ;mov [officerOne], rdi
    ;mov [officerTwo], rsi

    sub rsp, 8
    call printMovementsBox
    add rsp, 8

    sub rsp, 8
    call printOfficerStats
    add rsp, 8

    ret

printMovementsBox:
    print saltoLinea
    print stMovements
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
    print saltoLinea
    print stTitle
    print saltoLinea
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
