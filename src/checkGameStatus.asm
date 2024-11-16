global checkGameStatus
%include "macros.asm"

section .data
    bRows db 7
    bCols db 7

section .bss
    board resq 1
    bOffsetRows resb 1
    bTotalOffset resb 1
    bCountRows resb 1
    bCountCols resb 1
    currentNumber resb 1
    soldiersCount resb 1
    soldiersInStrongholdCount resb 1
    officersCount resb 1
    drownedOfficers resb 1
    stronghold resb 1

section .text

checkGameStatus:
    mov [board], rdi
    mov [stronghold], esi
    mov byte [bOffsetRows], 0
    mov byte [bTotalOffset],0
    mov byte [bCountRows], 0
    mov byte [bCountCols], 0
    mov byte [soldiersCount], 0
    mov byte [soldiersInStrongholdCount], 0
    mov byte [officersCount], 0
    mov byte [drownedOfficers], 1

loopRows:
    xor al, al
    mov al, [bCountRows]
    cmp al, [bRows]
    jge doneLoopRows

    xor bl, bl
    mov cl, al
    mov bl, [bCols]
    imul rcx, rbx
    mov [bOffsetRows], cl

    sub rsp, 8
    call loopCols
    add rsp, 8

    inc byte [bCountRows]
    jmp loopRows
doneLoopRows:
    cmp byte [soldiersCount], 9
    jl officersWin
    cmp byte [officersCount], 0
    je soldiersWin
    cmp byte [soldiersInStrongholdCount], 9
    je soldiersWin

    jmp gameContinue

loopCols:
    xor al, al
    mov al, [bCountCols]
    cmp al, [bCols]
    jge doneLoopCols

    mov cl, [bOffsetRows]
    add cl, al
    mov [bTotalOffset], cl

    sub rsp, 8
    call processCell
    add rsp, 8

    inc byte [bCountCols]
    jmp loopCols

doneLoopCols:
    mov byte [bCountCols], 0
    ret

processCell:
    xor rax, rax
    xor rbx, rbx
    xor r8, r8
    mov bl, [bTotalOffset]
    mov r8, [board]
    mov al, [r8 + rbx]
    mov byte [currentNumber], al

    cmp byte [currentNumber], 1
    je incrementSoldier
    cmp byte [currentNumber], 2
    je incrementOfficer
    cmp byte [currentNumber], 3
    je incrementOfficer
    ret

incrementSoldier:
    inc byte [soldiersCount]
    sub rsp, 8
    call verifySoldierInStronghold
    add rsp, 8
    ret

verifySoldierInStronghold:
    mov bl, [bCountCols]
    cmp bl, [stronghold]
    jl skipStrongholdCount
    cmp bl, [stronghold + 1]
    jg skipStrongholdCount
    mov bl, [bCountRows]
    cmp bl, [stronghold + 2]
    jl skipStrongholdCount
    cmp bl, [stronghold + 3]
    jg skipStrongholdCount
    inc byte [soldiersInStrongholdCount]
skipStrongholdCount:
    ret

incrementOfficer:
    inc byte [officersCount]
    sub rsp, 8
    call verifyDrownedOfficer
    add rsp, 8
    ret

verifyDrownedOfficer:
    mov dil, [bCountRows]
    mov sil, [bCountCols]

    dec sil
    dec dil
    sub rsp, 8
    call checkPosition
    add rsp, 8

    inc sil
    sub rsp, 8
    call checkPosition
    add rsp, 8

    inc sil
    sub rsp, 8
    call checkPosition
    add rsp, 8
    inc dil
    dec sil

    dec sil
    sub rsp, 8
    call checkPosition
    add rsp, 8

    inc sil
    inc sil
    sub rsp, 8
    call checkPosition
    add rsp, 8
    dec cl

    dec sil
    inc dil
    sub rsp, 8
    call checkPosition
    add rsp, 8

    inc sil
    sub rsp, 8
    call checkPosition
    add rsp, 8

    inc sil
    sub rsp, 8
    call checkPosition
    add rsp, 8

    ret

checkPosition:
    cmp dil, 0
    jl noMove
    cmp dil, [bRows]
    jg noMove
    cmp sil, 0
    jl noMove
    cmp sil, [bCols]
    jg noMove

    mov r8, [board]
    xor r9,r9
    mov dl, [bCols]
    mov r9b, dil
    imul r9, rdx

    add r9b, sil
    mov dl, [r8 + r9]
    cmp dl, 0
    je movementFound

    ret

noMove:
    ret

movementFound:
    mov byte [drownedOfficers], 0
    ret

soldiersWin:
    mov al, 0
    ret

officersWin:
    mov al, 1
    ret

gameContinue:
    mov al, -1
    ret