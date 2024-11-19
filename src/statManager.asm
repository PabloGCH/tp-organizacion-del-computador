; RDI: Posicion deseada
; RSI: Oficial a modificar. (0, 1)
; DL : Cantidad a modificar
; 0-8 Primer Oficial | 9-17 Segundo oficial
; 0/9 Capturas. 2-8/10-17 Direcciones 

extern printStats
section .data
        statCounter times 18 db 0
section .bss
        value resb 1
section .text

    global statCounterGet
    ; Mueve a AL el valor del array en la posicion dil
    statCounterGet:
        imul rsi, 9
        add rdi, rsi ; Posicion del array deseada
        mov al, byte[statCounter + rdi] ; Mueve el contenido deseado a AL
        ret

    global statCounterAdd
    ; Le agrega al contenido del array en la posicion dil el contenido de SIL 
    statCounterAdd:
        imul rsi, 9
        add rdi, rsi ; Posicion del array deseada
        add byte[statCounter + rdi], dl ; Le suma al contenido de RSI (Debería ser el elemento del array) DL
        ret

    global statCounterSet
    ; Reemplaza al contenido del array en la posicion dil por el contenido de SIL
    statCounterSet:
        imul rsi, 9
        add rdi, rsi ; Posicion del array deseada
        mov byte[statCounter + rdi], dl ; Le cambia al contenido deseado al contenido de DL
        ret

    global statCounterPrint
    ; Le envia todos los datos a printStats y la llama
    statCounterPrint:
    mov rdi, qword[statCounter + 1] ; statCounter + 1  -> Movimientos Oficial I  [2,3,4,5,6,7,8,9]
    mov sil, byte[statCounter]      ; statcounter + 0  -> Capturas    Oficial I  [1]
    mov rdx, qword[statCounter + 10]; statCounter + 10 -> Movimientos Oficial II [11,12,13,14,15,16,17,18]
    mov cl, byte[statCounter + 9]   ; statCounter + 9  -> Capturas    Oficial II [10]
    call printStats
    ret