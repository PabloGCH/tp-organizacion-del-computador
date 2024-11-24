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
extern printf

section .data

    msgSave  db 27,'[90mIngrese "Save" para guardar la partida',27,"[0m", 10, 0
    msgSaved db "Guardado!", 10, 0

section .bss
    saveFile          resq 1  ; "Puntero" al archivo

    ; Pointers
    pointerBoard             resq 1  ; Tablero
    pointerScore             resq 1  ; Stats
    pointerStrongholdL       resq 1  ; Ubicacion Fortaleza
    pointerStrongholdD       resq 1  ; Direccion Fortaleza
    pointerCurrentTurn       resq 1  ; Turno Actual
    pointerCharacters        resq 1  ; Caracter Soldado/Oficial

    ; Data Storage
    dataBoard             times 49 resb 1 ; Tablero
    dataScore             times 18 resb 1 ; Stats
    dataStrongholdL       times 4  resb 1 ; Ubicacion Fortaleza
    dataStrongholdD       times 1  resb 1 ; Direccion Fortaleza  
    dataCurrentTurn       times 1  resb 1 ; Turno Actual
    dataCharacters        times 2  resb 1 ; Caracter Soldado/Oficial

section .text

    global saveGame
    saveGame:

        ; Guardamos inputs en variables para no pisarlos

        mov qword[pointerBoard],       rdi
        mov qword[pointerScore],       rsi
        mov qword[pointerStrongholdL], rdx
        mov qword[pointerStrongholdD], rcx
        mov qword[pointerCurrentTurn], r8
        mov qword[pointerCharacters],  r9

        mov qword[saveFile],           r10

        ; Gameboard 7x7
        saveBoard:
            mov rdi, [pointerBoard]    ; Input
            mov rsi, 1              ; Tamaño de los elementos
            mov rdx, 49             ; Cantidad de elementos
            mov rcx, [saveFile]     ; Archivo destino
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Scoreboard 18x1
        saveStats:
            mov rdi, [pointerScore]
            mov rsi, 1
            mov rdx, 18
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8
        
        ; Fortress Location 4x1
        saveFortressL:
            mov rdi, [pointerStrongholdL]
            mov rsi, 1
            mov rdx, 4
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Fortress Direction 1x1
        saveFortressD:
            mov rdi, [pointerStrongholdD]
            mov rsi, 1
            mov rdx, 1
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Current Turn 1x1
        saveTurn:
            mov rdi, [pointerCurrentTurn]
            mov rsi, 1
            mov rdx, 1
            mov rcx, [saveFile]
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Game Pieces 2x1
        saveCharacters:
            mov rdi, [pointerCharacters]
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
            sub rsp, 8
            mov rdi, msgSaved
            call printf
            add rsp, 8
            ret 

    global loadGame
    loadGame:

        ; Guardamos inputs en variables para no pisarlos

        mov qword[pointerBoard]          , rdi
        mov qword[pointerScore]     , rsi
        mov qword[pointerStrongholdL]   , rdx
        mov qword[pointerStrongholdD]  , rcx
        mov qword[pointerCurrentTurn]        , r8
        mov qword[pointerCharacters]         , r9

        mov qword[saveFile], r10

        load:
            loadBoard:
                mov rdi, dataBoard   ; Destination
                mov rsi, 1            ; Size
                mov rdx, 49           ; Count
                mov rcx, [saveFile]   ; File
                sub rsp, 8
                call fread
                add rsp, 8

            loadStats:
                mov rdi, dataScore
                mov rsi, 1
                mov rdx, 18
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8
            
            loadFortressL:
                mov rdi, dataStrongholdL
                mov rsi, 1
                mov rdx, 4
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

            loadFortressD:
                mov rdi, dataStrongholdD
                mov rsi, 1
                mov rdx, 1
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

            loadTurn:
                mov rdi, dataCurrentTurn
                mov rsi, 1
                mov rdx, 1
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

            loadCharacters:
                mov rdi, dataCharacters
                mov rsi, 1
                mov rdx, 2
                mov rcx, [saveFile]
                sub rsp, 8
                call fread
                add rsp, 8

        replace:

            replaceBoard:
                mov rsi,  dataBoard  ; Source
                mov rdi, [pointerBoard] ; Destination
                mov rcx, 49           ; Count
                rep movsb             ; Copies RCX bytes from [RSI] to [RDI]

            replaceStats:
                mov rsi,  dataScore
                mov rdi, [pointerScore]
                mov rcx, 18
                rep movsb

            replaceFortressL:
                mov rsi,  dataStrongholdL
                mov rdi, [pointerStrongholdL]
                mov rcx, 4
                rep movsb

            replaceFortressD:
                mov rsi,  dataStrongholdD
                mov rdi, [pointerStrongholdD]
                mov rcx, 1
                movsb

            replaceTurn:
                mov rsi,  dataCurrentTurn
                mov rdi, [pointerCurrentTurn]
                mov rcx, 1
                movsb

            replaceCharacters:
                mov rsi,  dataCharacters
                mov rdi, [pointerCharacters]
                mov rcx, 2
                rep movsb
        
        loadEnd:
            mov rdi, [saveFile]
            sub rsp, 8
            call fclose
            add rsp, 8
            ret 

    global printSaveMessage
    printSaveMessage:
        mov rdi, msgSave
        sub rsp, 8
        call printf
        add rsp, 8
        ret