; NOTA PARA EL FUTURO: FREAD GUARDA LA POSICION!
; SAVE/LOAD Game Subroutines

; Inputs (Punteros)
; RDI: Matriz       7  x 7
; RSI: Stats        18 x 1
; RDX: FortalezaLoc 4  x 1
; RCX: FortalezaDir 1  x 1
; R8 : Turno        1  x 1
; R9 : Caracteres   2  x 1
; R10: Archivo, abierto en modo deseado (R/W)

%include "macros.asm"

extern fopen
extern fwrite
extern fread
extern fclose

section .data

section .bss
    saveFile          resq 1  ; "Puntero" al archivo

    ; Pointers
    pGameBoard         resq 1  ; Tablero
    pStatScoreboard    resq 1  ; Stats
    pFortressLocation  resq 1  ; Ubicacion Fortaleza
    pFortressDirection resq 1  ; Direccion Fortaleza
    pCurrentTurn       resq 1  ; Turno Actual
    pCharacters        resq 1  ; Caracter Soldado/Oficial

    ; Data Storage
    dGameBoard         times 49 resb 1 ; Tablero
    dStatScoreboard    times 18 resb 1 ; Stats
    dFortressLocation  times 4  resb 1 ; Ubicacion Fortaleza
    dFortressDirection times 1  resb 1 ; Direccion Fortaleza  
    dCurrentTurn       times 1  resb 1 ; Turno Actual
    dCharacters        times 2  resb 1 ; Caracter Soldado/Oficial

section .text

    global saveGame
    saveGame:

        ; Guardamos inputs en variables para no pisarlos

        mov qword[pGameBoard]          , rdi
        mov qword[pStatScoreboard]     , rsi
        mov qword[pFortressLocation]   , rdx
        mov qword[pFortressDirection]  , rcx
        mov qword[pCurrentTurn]        , r8
        mov qword[pCharacters]         , r9

        mov qword[saveFile], r10

        ; Gameboard 7x7
        saveBoard:
            mov rdi, [pGameBoard]    ; Input
            mov rsi, 1              ; Tamaño de los elementos
            mov rdx, 49             ; Cantidad de elementos
            mov rcx, [saveFile]     ; Archivo destino
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Scoreboard 18x1
        saveStats:
            mov rdi, [pStatScoreboard]
            mov rsi, 1
            mov rdx, 18
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8
        
        ; Fortress Location 4x1
        saveFortressL:
            mov rdi, [pFortressLocation]
            mov rsi, 1
            mov rdx, 4
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Fortress Direction 1x1
        saveFortressD:
            mov rdi, [pFortressDirection]
            mov rsi, 1
            mov rdx, 1
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Current Turn 1x1
        saveTurn:
            mov rdi, [pCurrentTurn]
            mov rsi, 1
            mov rdx, 1
            mov rcx, [saveFile]
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Game Pieces 2x1
        saveCharacters:
            mov rdi, [pCharacters]
            mov rsi, 1
            mov rdx, 2
            mov rcx, [saveFile]
            sub rsp, 8
            call fwrite
            add rsp, 8
        
        saveEnd:
            mov rdi, [saveFile]
            sub rsp, 8
            call fclose
            add rsp, 8
            ret 

    global loadGame
    loadGame:

        ; Guardamos inputs en variables para no pisarlos

        mov qword[pGameBoard]          , rdi
        mov qword[pStatScoreboard]     , rsi
        mov qword[pFortressLocation]   , rdx
        mov qword[pFortressDirection]  , rcx
        mov qword[pCurrentTurn]        , r8
        mov qword[pCharacters]         , r9

        mov qword[saveFile], r10

        load:
            loadBoard:
                mov rdi, dGameBoard   ; Destination
                mov rsi, 1            ; Size
                mov rdx, 49           ; Count
                mov rcx, [saveFile]   ; File
                sub rsp, 8
                call fread
                add rsp, 8

            loadStats:
                mov rdi, dStatScoreboard
                mov rsi, 1
                mov rdx, 18
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8
            
            loadFortressL:
                mov rdi, dFortressLocation
                mov rsi, 1
                mov rdx, 4
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

            loadFortressD:
                mov rdi, dFortressDirection
                mov rsi, 1
                mov rdx, 1
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

            loadTurn:
                mov rdi, dCurrentTurn
                mov rsi, 1
                mov rdx, 1
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

            loadCharacters:
                mov rdi, dCharacters
                mov rsi, 1
                mov rdx, 2
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

        replace:

            replaceBoard:
                mov rsi,  dGameBoard  ; Source
                mov rdi, [pGameBoard] ; Destination
                mov rcx, 49           ; Count
                rep movsb             ; Copies RCX bytes from [RSI] to [RDI]

            replaceStats:
                mov rsi,  dStatScoreboard
                mov rdi, [pStatScoreboard]
                mov rcx, 18
                rep movsb

            replaceFortressL:
                mov rsi,  dFortressLocation
                mov rdi, [pFortressLocation]
                mov rcx, 4
                rep movsb

            replaceFortressD:
                mov rsi,  dFortressDirection
                mov rdi, [pFortressDirection]
                mov rcx, 1
                movsb

            replaceTurn:
                mov rsi,  dCurrentTurn
                mov rdi, [pCurrentTurn]
                mov rcx, 1
                movsb

            replaceCharacters:
                mov rsi,  dCharacters
                mov rdi, [pCharacters]
                mov rcx, 2
                rep movsb
        
        loadEnd:
            mov rdi, [saveFile]
            sub rsp, 8
            call fclose
            add rsp, 8
            ret 