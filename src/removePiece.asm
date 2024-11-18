global removePiece


section .bss
  board     resq    1


section .text
  ;PRE-COND:
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 2 ELEMENTOS (DE 2 BYTES CADA UNO) INDICANDO LA POSICION DE LA PIEZA A CAPTURAR
  removePiece:
    mov qword[board], rdi

    mov     ax,     word[rsi]
    sub     ax,     1
    imul    ax,     7

    mov     cx,     word[rsi + 2]
    sub     cx,     1

    add     ax,     cx

    mov     rdx,    qword[board]
    add     dx,     ax

    mov     byte[rdx], 0
    ret
