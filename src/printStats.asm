%include "macros.asm"
section .data
    stMovements db "Direcciones", 10, 0
    movements db '8', '1', '2', '7', ' ', '3', '6', '5', '4'
    mBoxLine db "+---+---+---+", 10, 0
    mBoxFormat db "| %c | %c | %c |", 10, 0
    mBoxOffset dq 0
    mCounter db 3
    stTitle db "Estadísticas de los oficiales:", 10, 0
    mBoxOfficersLine db "+-----------+-----------+-----------+", 10, 0
    mBoxOfficersTitle db "|           | ",27,"[32mOficial 1",27,"[0m | ",27,"[34mOficial 2",27,"[0m |", 10, 0
    mBoxOfficersFormat db "| DIR - %-3d | %-9hhi | %-9hhi |", 10, 0
    mBoxOfficersKillsFormat db "| CAPTURAS  | %-9hhi | %-9hhi |", 10, 0
    newLine db 10, 0

section .bss
    movementsOOne resb 8
    capturesOOne resb 1
    movementsOTwo resb 8
    capturesOTwo resb 1
section .text
    global printStats

printStats:
    mov [movementsOOne], rdi
    mov [capturesOOne], sil

    mov [movementsOTwo], rdx
    mov [capturesOTwo], cl

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
    jle doneBoxLoop

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

doneBoxLoop:
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
    jge doneOfficerMovementsLoop

    mov rdi, mBoxOfficersFormat
    inc rbx
    mov rsi, rbx
    dec rbx
    mov rdx, [movementsOOne + rbx]
    mov rcx, [movementsOTwo + rbx]
    sub rsp, 8
    call printf
    add rsp, 8
    inc byte [mCounter]
    jmp loopOfficerMovements

doneOfficerMovementsLoop:
    print mBoxOfficersLine
    mov rdi, mBoxOfficersKillsFormat
    mov rsi, [capturesOOne]
    mov rdx, [capturesOTwo]
    sub rsp, 8
    call printf
    add rsp, 8
    print mBoxOfficersLine

    ret
