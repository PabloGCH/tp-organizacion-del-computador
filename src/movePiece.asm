global movePiece

section     .bss
  board                   resq    1
  initialPositionPiece    resb    1
  playerType              resb    1

section     .text
  ;PRE-COND:
  ;           RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;           RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO)
  ;           RECIBE EN RDX UN NUMERO QUE INDICA TIPO DE JUGADOR 0 (Soldados) O 1 (Oficiales)
  ;POST-COND: SIEMPRE RETORNA 0
  ;           MUEVE UNA PIEZA DE UN JUGADOR A UNA POSICIÓN VÁLIDA
  ;           LA POSICION INICIAL SE SETEA A 0
  ;           LA POSICION FINAL SE SETEA EL VALOR DE LA POSICION INICIAL
  movePiece:
    ; TODO: FALTA AGREGAR LA VALIDACION DE MOVIMIENTO SIN CAPTURA DEL OFICIAL

    mov     qword[board], rdi
    mov     byte[playerType], dl
    
    ; CONSIGUE LA POSICION INICIAL DE LA PIEZA Y SETEA LA POSICION INICIAL COMO 0
    mov    ax, word[rsi]
    sub    ax, 1
    imul   ax, 7

    mov    di, word[rsi + 2]
    sub    di, 1

    add    ax, di

    mov    rdx, qword[board]
    add    dx, ax
    
    mov    al,  byte[rdx]
    mov    byte[initialPositionPiece], al

    mov    byte[rdx], 0

    ; SETEA LA POSICION FINAL EL VALOR DE LA POSICION INICIAL
    
    mov    ax, word[rsi + 4]
    sub    ax, 1
    imul   ax, 7

    mov    di, word[rsi + 6]
    sub    di, 1
    
    add    ax, di

    mov    rdx, qword[board]
    add    dx, ax

    mov    al,  byte[initialPositionPiece]

    mov    byte[rdx], al
   
    ret






