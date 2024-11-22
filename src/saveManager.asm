; NOTA PARA EL FUTURO: FREAD GUARDA LA POSICION!
; SAVE/LOAD Game Subroutines

; Inputs (Punteros)
; RDI: Matriz       7  x 7
; RSI: Stats        18 x 1
; RDX: FortalezaLoc 4  x 1
; RCX: FortalezaDir 1  x 1
; R8 : Turno        1  x 1
; R9 : Caracteres   2  x 1 

%include "macros.asm"

extern fopen
extern fwrite
extern fputs
extern fclose

section .data

    modeWrite db "w"
    modeRead db "r"

    askSaveFilePath db "Ingrese el nombre (Maximo 16 caracteres) del archivo de guardado: ", 10, 0 ; Ambiguo para poder usarlo en save Y load :)
    saveFileFormat db "%c"
    newLine db 10,0

    boardCounter db 0

section .bss
    savePath          resb 16; TODO validar input, si es posible
    saveFile          resq 1; "Puntero" al archivo

    ; Pointers
    gameBoard         resq 1 ; Tablero
    statScoreboard    resq 1 ; Stats
    fortressLocation  resq 1 ; Ubicacion fortaleza
    fortressDirection resq 1 ; Direccion fortaleza
    currentTurn       resq 1 ; Turno actual
    characters        resq 1 ; Caracter soldado/oficial

section .text

    global saveGame
    saveGame:

        ; Guardamos inputs en variables para no pisarlos

        mov qword[gameBoard]          , rdi
        mov qword[statScoreboard]     , rsi
        mov qword[fortressLocation]   , rdx
        mov qword[fortressDirection]  , rcx
        mov qword[currentTurn]        , r8
        mov qword[characters]         , r9

        ; read para pedir archivo a donde guardar
        read askSaveFilePath, savePath, saveFileFormat, savePath ; Es necesario validar que no sea mas de 16 caracteres?
        ; Abrimos el archivo en Write
        lea rdi, savePath 
        mov rsi, modeWrite
        call fopen
        mov qword[saveFile], rax ; Asumo que devuelve en rax como deberia

        ; Gameboard 7x7
        saveBoard:
            mov rdi, [gameBoard]    ; Input
            mov rsi, 1              ; Tamaño de los elementos
            mov rdx, 49             ; Cantidad de elementos
            mov rcx, [saveFile]     ; Archivo destino
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Scoreboard 18x1
        saveStats:
            mov rdi, [statScoreboard]
            mov rsi, 1
            mov rdx, 18
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8
        
        ; Fortress Location 4x1
        saveFortressL:
            mov rdi, [fortressLocation]
            mov rsi, 1
            mov rdx, 4
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Fortress Direction 1x1
        saveFortressD:
            mov rdi, [fortressDirection]
            mov rsi, 1
            mov rdx, 1
            mov rcx, [saveFile] 
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Current Turn 1x1
        saveTurn:
            mov rdi, [currentTurn]
            mov rsi, 1
            mov rdx, 1
            mov rcx, [saveFile]
            sub rsp, 8
            call fwrite
            add rsp, 8

        ; Game Pieces 2x1
        saveCharacters:
            mov rdi, [characters]
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
        ; TODO