; SAVE/LOAD Game Subroutines
; RDI: Puntero a la matriz [7][7]
; RSI: Puntero a las stats [18]
; RDX: Puntero q apunta al vector con la ubicacion de la fortaleza [4]
; R8B: Dirección de la fortaleza
; CX : Caracter Soldado (CL) y Oficial (CH)


; NOTA PARA EL FUTURO: FREAD GUARDA LA POSICION!

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

    boardPointer      resq 1; Tablero
    statsPointer      resq 1; Stats
    fortressPointer   resq 1; Ubicacion fortaleza
    fortressDirection resb 1; Direccion fortaleza
    soldierCharacter  resb 1; Caracter Soldado
    officerCharacter  resb 1; Caracter Oficial

section .text

    global saveGame
    saveGame:

        ; Guardamos inputs en variables para no pisarlos

        mov qword[boardPointer],     rdi
        mov qword[statsPointer],     rsi
        mov qword[fortressPointer],  rdx
        mov byte[fortressDirection], r8b
        mov byte[soldierCharacter],  cl
        mov byte[officerCharacter],  ch

        ; read para pedir archivo a donde guardar
        read askSaveFilePath, savePath, saveFileFormat, savePath ; Es necesario validar que no sea mas de 16 caracteres?
        ; Abrimos el archivo en Write
        lea rdi, savePath 
        mov rsi, modeWrite
        call fopen
        mov qword[saveFile], rax ; Asumo que devuelve en rax como deberia

        ; Guardamos la matriz
        saveBoard:
            ; Guardamos una fila
            mov rdi, [boardPointer] ; Input
            mov rsi, 1              ; Tamaño de los elementos
            mov rdx, 49             ; Guardamos una fila
            mov rcx, [saveFile]     ; Archivo destino
            sub rsp, 8
            call fwrite
            add rsp, 8

        end:
            ret