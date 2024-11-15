;         +---+---+---+        
;         | X | X | X |        
;         +---+---+---+        
;         | X | X | X |        
; +---+---+---+---+---+---+---+
; | X | X | X | X | X | X | X |
; +---+---+---+---+---+---+---+
; | X | X | X | X | X | X | X |
; +---+---+---+---+---+---+---+
; | X | X |   |   |   | X | X |
; +---+---+---+---+---+---+---+
;         |   |   | O |        
;         +---+---+---+        
;         | O |   |   |        
;         +---+---+---+        

extern printf
%include "macros.asm"
global printBoard

section .data
    bRows db 7
    bCols db 7
    bCountRows db 0
    bCountCols db 0

    colsIndex db "         1   2   3   4   5   6   7    ", 10,10, 0
    rowsIndex db "   %-1hhi   ", 0
    rowsIndexE db "       ", 0
    bUpDown db "---", 0
    bLeftRight db "|", 0
    bCross db "+", 0
    bData db " %-1c ", 0
    bUpDownE db "   ", 0
    bLeftRightE db " ", 0
    bCrossE db " ", 0
    bDataE db "   ", 0
    newLine db 10,0

    cStronghold db 27,"[31m",0
    cOfficerOne db 27,"[32m",0
    cOfficerTwo db 27,"[34m",0
    cReset db 27,"[0m",0

    repeatFlag db 1
section .bss
    bOffsetRows resb 1
    bTotalOffset resb 1
    vect resb 4
    maxValue resb 1
    board resq 1
    stronghold times 4 resb 1
    characters times 4 resb 1
    characterAux resb 1
section .text

printBoard:
    mov [board], rdi
    mov [stronghold], esi
    mov [characters], edx

    print newLine
    print colsIndex
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
    call printRowIndex
    add rsp, 8

    sub rsp, 8
    call loopCols
    add rsp, 8

    cmp byte [repeatFlag], 1
    je skipIncrementRows
    inc byte [bCountRows]

    mov al, [bCountRows]
    cmp al, [bRows]
    jge printDownCrossAndLine

skipIncrementRows:
    not byte [repeatFlag]
    jmp loopRows

doneLoopRows:
    ret

printRowIndex:
    cmp byte [repeatFlag], 1
    je printRowIndexEmpty
    inc byte [bCountRows]
    printArg rowsIndex, bCountRows
    dec byte [bCountRows]
    ret
printRowIndexEmpty:
    print rowsIndexE
    ret

printDownCrossAndLine:
    print rowsIndexE
    not byte [repeatFlag]
    sub rsp, 8
    call loopCols
    add rsp, 8
    jmp loopRows

loopCols:
    xor al, al
    mov al, [bCountCols]
    cmp al, [bCols]
    jge doneLoopCols
    mov cl, [bOffsetRows]
    add cl, al
    mov [bTotalOffset], cl

    cmp byte [repeatFlag], 1
    je processBoxLine
    jne processBoxData
continueLoop:
    inc byte [bCountCols]
    jmp loopCols
    ret

doneLoopCols:
    mov byte [bCountCols], 0
    print newLine
    ret

processBoxLine:
    resetVector vect
    xor rbx, rbx
    xor rcx, rcx
    mov bl, [bTotalOffset]
    mov r8, [board]
    mov al, [r8 + rbx]
    mov byte [vect+rcx], al
    inc rcx
    mov al, [bCountRows]
    cmp al, 0
    jle skipBoxUp
    mov bl, [bTotalOffset]
    sub bl, [bCols]
    mov al, [r8 + rbx]
    mov byte [vect+rcx], al

skipBoxUp:
    inc rcx
    mov bl, [bTotalOffset]
    mov al, [bCountCols]
    cmp al, 0
    jle skipBoxPrevious
    dec rbx
    mov r8, [board]
    mov al, [r8 + rbx]
    mov byte [vect + rcx], al
skipBoxPrevious:
    inc rcx
    mov al, [bCountRows]
    cmp al, 0
    jle skipBoxPreviousUp
    mov al, [bCountCols]
    cmp al, 0
    jle skipBoxPreviousUp
    mov bl, [bTotalOffset]
    sub bl, [bCols]
    dec bl
    mov al, [r8 + rbx]
    mov byte [vect + rcx], al
skipBoxPreviousUp:
    lea rdi, [vect]
    mov rsi, 4
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8
    mov [maxValue], al

    mov dil, [maxValue]
    sub rsp, 8
    call printCross
    add rsp, 8

    lea rdi, [vect]
    mov rsi, 2
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8
    mov [maxValue], al

    mov dil, [maxValue]
    sub rsp, 8
    call printBoxLine
    add rsp, 8

    mov al, [bCountCols]
    inc al
    cmp al, [bCols]
    je printBoxCrossEnd

    jmp continueLoop

printCross:
    cmp dil, 0
    jl printCrossEmpty

    print cReset
    mov r8B, [bCountCols]
    cmp r8B, [stronghold]
    jl skipCrossRed
    dec r8B
    cmp r8B, [stronghold + 1]
    jg skipCrossRed

    mov r8B, [bCountRows]
    cmp r8B, [stronghold + 2]
    jl skipCrossRed
    dec r8B
    cmp r8B, [stronghold + 3]
    jg skipCrossRed

    print cStronghold
skipCrossRed:
    print bCross
    ret
printCrossEmpty:
    print cReset
    print bCrossE
    ret

printBoxLine:
    cmp dil, 0
    jl printLineEmpty
    print cReset
    mov r8B, [bCountCols]
    cmp r8B, [stronghold]
    jl skipLineRed
    cmp r8B, [stronghold + 1]
    jg skipLineRed

    mov r8B, [bCountRows]
    cmp r8B, [stronghold + 2]
    jl skipLineRed
    dec r8B
    cmp r8B, [stronghold + 3]
    jg skipLineRed

    print cStronghold
skipLineRed:
    print bUpDown
    ret

printLineEmpty:
    print cReset
    print bUpDownE
    ret

printBoxCrossEnd:
    mov dil, [maxValue]
    sub rsp, 8
    call printCross
    add rsp, 8
    jmp continueLoop

processBoxData:
    resetVector vect
    mov rcx, 0
    mov bl, [bTotalOffset]
    mov r8, [board]
    mov al, [r8 + rbx]
    mov byte [vect + rcx], al

    mov al, [bCountCols]
    cmp al, 0
    jle skipBoxDataPrevious
    dec rbx
    inc rcx
    mov al, [r8 + rbx]
    mov byte [vect + rcx], al
skipBoxDataPrevious:
    lea rdi, [vect]
    mov rsi, 2
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8
    mov [maxValue], al

    mov dil, al
    sub rsp, 8
    call printBoxLeft
    add rsp, 8

    lea rdi, [vect]
    mov rsi, 1
    sub rsp, 8
    call getMaxOfVector
    add rsp, 8
    mov [maxValue], al

    mov dil, al
    sub rsp, 8
    call printData
    add rsp, 8

    mov al, [bCountCols]
    inc al
    cmp al, [bCols]
    je printBoxLineEnd
    jmp continueLoop

printBoxLeft:
    cmp dil, 0
    jl printLeftEmpty

    print cReset

    mov r8B, [bCountCols]
    cmp r8B, [stronghold]
    jl skipBoxLeftRed
    dec r8B
    cmp r8B, [stronghold + 1]
    jg skipBoxLeftRed

    mov r8B, [bCountRows]
    cmp r8B, [stronghold + 2]
    jl skipBoxLeftRed
    cmp r8B, [stronghold + 3]
    jg skipBoxLeftRed

    print cStronghold
skipBoxLeftRed:
    print bLeftRight
    ret

printLeftEmpty:
    print cReset
    print bLeftRightE
    ret

printData:
    cmp dil, 0
    jl printDataEmpty
    print cReset

    mov dil, [vect]
    sub rsp, 8
    call getCharacter
    add rsp, 8
    mov [characterAux], rax
    printArg bData, characterAux
    ret

printDataEmpty:
    print cReset
    print bDataE
    ret

printBoxLineEnd:
    mov dil, [maxValue]
    sub rsp, 8
    call printBoxLeft
    add rsp, 8

    jmp continueLoop

getCharacter:
    xor rax, rax
    cmp dil,0
    je isEmpty
    cmp dil, 1
    je isSoldier
    cmp dil, 2
    je isOfficerOne
    cmp dil, 3
    je isOfficerTwo

isSoldier:
    mov al, [characters]
    ret

isOfficerOne:
    print cOfficerOne
    mov al, [characters + 1]
    ret

isOfficerTwo:
    print cOfficerTwo
    mov al, [characters + 1]
    ret

isEmpty:
    mov al, [characters + 2]
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