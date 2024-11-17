; DIL: Posicion deseada
; SIL: Cantidad a modificar
; DL : Oficial a modificar. (0, 1)
; 0-8 Primer Oficial | 9-17 Segundo oficial
; 0/9 Capturas. 2-8/10-17 Direcciones 

section .data
        statcounter times 18 db 0
section .bss
        value resb 1
section .text

    global statCounterGet
    ; Mueve a AL el valor del array en la posicion dil
    statCounterGet:
        mul dl, 9
        mov al, [statCounter + dil + dl] ; Mueve el contenido deseado a AL
        ret

    global statCounterAdd
    ; Le agrega al contenido del array en la posicion dil el contenido de SIL 
    statCounterAdd:
        mul dl, 9
        add byte[statCounter + dil + dl], sil ; Le suma al contenido de RSI (Debería ser el elemento del array) DL
        ret

    global statCounterSet
    ; Reemplaza al contenido del array en la posicion dil por el contenido de SIL
    statCounterSet:
        mul dl, 9
        mov byte[statcounter + dil + dl], sil ; Le cambia al contenido deseado al contenido de DL
        ret