; RSI: Puntero con el array contador
; RDI: Stat que se quiere modificar
; DL: Cantidad añadir
; 0: Capturas, 1-8: Direcciones (Notes)

section .data

section .bss

section .text
    global statCounterAdd
    statCounterAdd:
        add rsi, rdi ; Aumenta RSI la cantidad de bytes indicada por DIL
        add byte[rsi], dl ; Le suma al contenido de RSI (Debería ser el elemento del array) DL
        ret