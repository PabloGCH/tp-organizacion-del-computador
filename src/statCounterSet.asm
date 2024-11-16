; RSI: Puntero con el array contador
; RDI: Stat que se quiere modificar
; DL: Cantidad set
; 0: Capturas, 1-8: Direcciones (Notes)

section .data

section .bss

section .text
    global statCounterSet
    statCounterSet:
        add rsi, rdi ; Aumenta RSI la cantidad de bytes indicada por DIL
        mov byte[rsi], dl ; Le cambia al contenido de RSI (Debería ser el elemento del array) por DL
        ret