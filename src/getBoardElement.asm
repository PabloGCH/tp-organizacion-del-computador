global getBoardItem

section .data
  board resq 1
  position resq 1


; PRE-COND:
;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 2 ELEMENTOS (DE 2 BYTES CADA UNO)
; POST-COND: 
;     DEVUELVE EN RAX EL VALOR DE LA POSICIÓN EN LA MATRIZ DEL TABLERO

section .text
  getBoardItem:
    mov rdi, [board]
    mov rsi, [position]

    mov     ax,     word[rsi]
    sub     ax,     1
    imul    ax,     7

    mov     cx,     word[rsi + 2]
    sub     cx,     1

    add     ax,     cx

    mov     rdx,    qword[board]
    add     dx,     ax

    xor     rax,    rax
    
    mov     al,     byte[rdx]

    ret




