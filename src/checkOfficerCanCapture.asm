global checkOfficerCanCapture
section .data
    bCols db 7
    bRows db 7
    newLine db 10, 0
section .bss
    board resq 1
    cRow resb 1
    cCol resb 1
    captureFound resb 1

section .text
checkOfficerCanCapture:
    mov byte [captureFound], 0
    mov [board], rdi
    mov [cRow], sil
    mov [cCol], dl

    dec byte[cRow]
    dec byte[cCol]


    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipUpLeft

    dec byte[cRow]
    dec byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    inc byte[cRow]
    inc byte[cCol]

skipUpLeft:

    inc byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipUp

    dec byte[cRow]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    inc byte[cRow]

skipUp:

    inc byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipUpRight

    inc byte[cCol]
    dec byte[cRow]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    inc byte[cRow]
    dec byte[cCol]

skipUpRight:

    inc byte[cRow]
    dec byte[cCol]

    dec byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipLeft

    dec byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    inc byte[cCol]

skipLeft:

    inc byte[cCol]
    inc byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipRight

    inc byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    dec byte[cCol]

skipRight:

    dec byte[cCol]

    dec byte[cCol]
    inc byte[cRow]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipDownLeft

    dec byte[cCol]
    inc byte[cRow]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    inc byte[cCol]
    dec byte[cRow]

skipDownLeft:

    inc byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipDown

    inc byte[cRow]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8
    dec byte[cRow]

skipDown:

    inc byte[cCol]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isSoldier
    add rsp, 8
    cmp al, 1
    jne skipDownRight

    inc byte[cCol]
    inc byte[cRow]
    mov dil, [cRow]
    mov sil, [cCol]
    sub rsp, 8
    call isPositionAvailable
    add rsp, 8

skipDownRight:

    xor rax, rax
    mov al, [captureFound]

    ret

isSoldier:
    cmp dil, 0
    jl noSoldier
    cmp dil, [bRows]
    jg noSoldier
    cmp sil, 0
    jl noSoldier
    cmp sil, [bCols]
    jg noSoldier

    mov r8, [board]
    xor r9,r9
    mov dl, [bCols]
    mov r9b, dil
    imul r9, rdx

    add r9b, sil
    mov dl, [r8 + r9]

    cmp dl, 1
    je soldierFound

noSoldier:
    mov al, 0
    ret

soldierFound:
    mov al, 1
    ret

isPositionAvailable:
    cmp dil, 0
    jl notAvailable
    cmp dil, [bRows]
    jg notAvailable
    cmp sil, 0
    jl notAvailable
    cmp sil, [bCols]
    jg notAvailable

    mov r8, [board]
    xor r9,r9
    mov dl, [bCols]
    mov r9b, dil
    imul r9, rdx

    add r9b, sil
    mov dl, [r8 + r9]

    cmp dl, 0
    je positionAvailable

notAvailable:
    ret

positionAvailable:
    mov byte [captureFound], 1
    ret