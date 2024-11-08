global main
%include "../macros/macros.asm"

section .data
    stMovements db "Direcciones", 10, 10, 0
    movements db '7', '0', '1', '6', ' ', '2', '5', '4', '3', '3', 0
    mBoxLine db "+---+---+---+", 10, 0
    mBoxFormat db "| %c | %c | %c |", 10, 0
    mBoxOffset dq 0
    mCounter db 3
    stTitle db "Estadísticas de los oficiales:", 10, 10, 0
    saltoLinea db 10, 0
    mOfficerTitle db "Oficial %hhi:", 10, 0
    officerIndex db 1
    mOfficerMovementFormat db "Dirección %hhi: %hhi movimientos", 10, 0
    ; movs db 0,1,2,3,4,5,6,7
    ; totalMovs equ $-movs
    ; offset dq 0
    ; arrow db "Flecha: %hhi", 10, 0
    officerOne db 5,2,5,6,72,1,2,2,8
    officerTwo db 0,1,2,3,4,5,6,7,8
section .bss
    ;officerOne resb 9
    ;officerTwo resb 9
    officerAux resb 9
section .text
main:
    ;mov [officerOne], rdi
    ;mov [officerTwo], rsi

    print stMovements
    sub rsp, 8
    call printMovementsBox
    add rsp, 8

    print stTitle

    mov rdi, [officerOne]
    sub rsp, 8
    call printOfficerStats
    add rsp, 8

    mov rdi, [officerTwo]
    sub rsp, 8
    call printOfficerStats
    add rsp, 8

    ret

printMovementsBox:
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
    jmp printMovementsBox
finBoxLoop:
    print mBoxLine
    print saltoLinea
    ret

printOfficerStats:
    mov [officerAux], rdi
    mov rsi, 0

    mov rdi, mOfficerTitle
    mov rsi, [officerIndex]
    sub rsp, 8
    call printf
    add rsp, 8
    mov byte [mCounter], 0
loopOfficerMovements:

    mov rbx, 0
    mov bl, [mCounter]
    cmp bl, 8
    jge finOfficerMovementsLoop

    mov rdi, mOfficerMovementFormat
    mov rsi, rbx
    mov rdx, [officerAux + rbx]
    sub rsp, 8
    call printf
    add rsp, 8
    inc byte [mCounter]
    jmp loopOfficerMovements

finOfficerMovementsLoop:
    inc byte [officerIndex]
    print saltoLinea
    ret


; 7 0 1
; 6   2
; 5 4 3
