; RSI: Puntero con el array contador
; RDI: Stat que se quiere recibir
; 0: Capturas, 1-8: Direcciones (Notes)

section .data

section .bss
    value resb 1

section .text
    global statCounterGet
    statCounterGet:
    add rsi, rdi ; Aumenta RSI la cantidad de bytes indicada por DIL
    lea rdi, [value] ; RDI apunta a value
    mov rcx, 1 ; Cantidad de bytes a copiar (1)
    rep movsb ; Valor en el array -> value
    mov al, [value] ; Mueve el resultado a al
    ret