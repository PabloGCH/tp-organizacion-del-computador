; RDI: Posicion deseada
; RSI: Oficial a modificar. (0, 1)
; DL : Cantidad a modificar
; 0-8 Primer Oficial | 9-17 Segundo oficial
; 0/9 Capturas. 2-8/10-17 Direcciones 

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