;         +---+---+---+        
;         | X | X | X |        
;         +---+---+---+        
;         |   |   |   |        
; +---+---+---+---+---+---+---+
; |   |   |   |   |   |   |   |
; +---+---+---+---+---+---+---+
; |   |   |   |   |   |   |   |
; +---+---+---+---+---+---+---+
; |   |   |   |   |   |   |   |
; +---+---+---+---+---+---+---+
;         |   |   | O |        
;         +---+---+---+        
;         | O |   |   |        
;         +---+---+---+        

extern printf
%include "../macros/macros.asm"
global main

section .data
    ; board db -1,-1,0,0,0,-1,-1, \
    ;          -1,-1,0,0,0,-1,-1, \
    ;            0,0,0,0,0,0,0, \
    ;            0,0,0,1,0,0,0, \
    ;            0,0,0,0,0,0,0, \
    ;          -1,-1,0,0,0,-1,-1, \
    ;          -1,-1,0,0,0,-1,-1
    ; bRows db 7
    ; bCols db 7
    board db 0,0,0,0,0,0,0,0,0
    bRows db 3
    bCols db 3
    bCountRows db 0
    bCountCols db 0

    bUpDown db "---", 0
    bLeftRight db "|", 0
    bCross db "+", 0
    bData db " %-1hhi ", 0
    bUpDownE db "   ", 0
    bLeftRightE db " ", 0
    bCrossE db " ", 0
    bDataE db "   ", 0
    newLine db 10,0

    cRed db 27,"[31m",0
    cGreen db 27,"[32m",0
    cReset db 27,"[0m",0

    repeatFlag db 1
section .bss
    bOffsetRows resb 1
    bTotalOffset resb 1
    vect resb 4
section .text

main:

loopRows:
    xor rax, rax
    mov al, [bCountRows]
    cmp al, [bRows]
    jge doneLoopRows

    xor rbx,rbx
    mov rcx, rax
    mov bl, [bCols]
    imul rcx, rbx

    mov [bOffsetRows], rcx
    sub rsp, 8
    call loopCols
    add rsp, 8

    cmp byte [repeatFlag], 1
    je skipIncrementRows
    inc byte [bCountRows]

skipIncrementRows:
    not byte [repeatFlag]
    jmp loopRows

doneLoopRows:
    ret

loopCols:
    xor rax, rax
    mov al, [bCountCols]
    cmp al, [bCols]
    jge doneLoopCols
    mov rcx, [bOffsetRows]
    add rcx, rax
    mov [bTotalOffset], rcx

    cmp byte [repeatFlag], 1
    je printCrossAndUp
    jne printLeftAndData
continueLoop:
    inc byte [bCountCols]
    jmp loopCols
    ret

doneLoopCols:
    mov byte [bCountCols], 0
    print newLine
    ret

printCrossAndUp:
    mov rcx, 4
loopResetVect:
    mov byte [vect+rcx], -1
    loop loopResetVect

    mov rcx, 0
    mov bl, [bTotalOffset]
    mov al, [board + rbx]
    mov byte [vect+rcx], al
    mov al, [bCountRows]
    cmp al, 0
    jle skipUp
    mov bl, [bTotalOffset]
    sub bl, [bCols]
    inc rcx
    mov al, [board + rbx]
    mov byte [vect+rcx], al
skipUp:
    mov al, [bCountCols]
    cmp al, 0
    jle skipPrevious
    dec rbx
    inc rcx
    mov al, [board + rbx]
    mov byte [vect+rcx], al
skipPrevious:
    mov al, [bCountRows]
    cmp al, 0
    jle skipPreviousUp
    mov al, [bCountCols]
    cmp al, 0
    jle skipPreviousUp
    inc rcx
    mov bl, [bTotalOffset]
    sub bl, 8
    mov al, [board + rbx]
    mov byte [vect+rcx], al
skipPreviousUp:
    lea rdi, [vect]
    mov rsi, 4
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8

    mov rdi, rax
    sub rsp, 8
    call printCross
    add rsp, 8

    lea rdi, [vect]
    mov rsi, 2
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8

    mov rdi, rax
    sub rsp, 8
    call printUp
    add rsp, 8

    jmp continueLoop

printCross:
    cmp rdi, 0
    je printCrossNormal
    jg printCrossEmpty
    jl printCrossFortress
printCrossEmpty:
    print cReset
    print bCrossE
    ret
printCrossNormal:
    print cReset
    print bCross
    ret

printCrossFortress:
    print cRed
    print bCross
    ret

printUp:
    cmp rdi, 0
    jl printUpEmpty
    jg printUpFortress
    je printUpNormal
printUpEmpty:
    print cReset
    print bUpDownE
    ret
printUpNormal:
    print cReset
    print bUpDown
    ret
printUpFortress:
    print cRed
    print bUpDown
    ret

printLeftAndData:
       mov rcx, 4
loopResetVect2:
    mov byte [vect+rcx], -1
    loop loopResetVect2

    mov rcx, 0
    mov bl, [bTotalOffset]
    mov al, [board + rbx]
    mov byte [vect+rcx], al

    mov al, [bCountCols]
    cmp al, 0
    jle skipPrevious2
    dec rbx
    inc rcx
    mov al, [board + rbx]
    mov byte [vect+rcx], al
skipPrevious2:
    lea rdi, [vect]
    mov rsi, 2
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8

    mov rdi, rax
    sub rsp, 8
    call printLeft
    add rsp, 8

    lea rdi, [vect]
    mov rsi, 1
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8

    mov rdi, rax
    sub rsp, 8
    call printData
    add rsp, 8

    jmp continueLoop

printLeft:
    cmp rdi, 0
    jl printLeftEmpty
    jg printLeftFortress
    je printLeftNormal
printLeftEmpty:
    print bLeftRightE
    ret
printLeftNormal:
    print bLeftRight
    ret
printLeftFortress:
    print cRed
    print bLeftRight
    ret
printData:
    cmp rdi, 0
    jg printDataEmpty
    jle printDataFully
printDataEmpty:
    printArg bDataE, vect
    ret
printDataFully:
    printArg bData, vect
    ret

getMaxOfVector:
    mov rcx, rsi
    mov al, [rdi]
    inc rdi
maxLoop:
    cmp rcx, 1
    je doneMaxLoop

    mov bl, [rdi]
    inc rdi
    dec rcx

    cmp al, bl
    jge maxLoop

    mov al, bl
    jmp maxLoop

doneMaxLoop:
    ret