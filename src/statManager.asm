; RDI: Posicion deseada
; SIL: Cantidad a modificar
; 0: Capturas, 1-8: Direcciones (Notes)

section .data
        statcounter times 9 db 0
section .bss
        value resb 1
section .text

    global statCounterGet
    ; Mueve a AL el valor del array en la posicion RDI
    statCounterGet:
        mov al, [statCounter + rdi] ; Mueve el contenido deseado a AL
        ret

    global statCounterAdd
    ; Le agrega al contenido del array en la posicion RDI el contenido de SIL 
    statCounterAdd:
        add byte[statCounter + rdi], sil ; Le suma al contenido de RSI (Debería ser el elemento del array) DL
        ret

    global statCounterSet
    ; Reemplaza al contenido del array en la posicion RDI por el contenido de SIL
    statCounterSet:
        mov byte[statcounter + rdi], sil ; Le cambia al contenido deseado al contenido de DL
        ret