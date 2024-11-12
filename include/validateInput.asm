global validateInput

section .data
  minValue     dw  1
  maxValue     dw  7
  invalidMsg   db  "Posicion invalida, intente de nuevo", 10, 0

section .text
  ;PRE-COND:  RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 2 ELEMENTOS (DE 2 BYTES CADA UNO)
  ;POST-COND: DEVUELVE EN RAX 0 SI LA POSICIÓN ES INVÁLIDA, 1 SI ES VALIDA
  ;NOTAS:     COMO EL TABLERO ES DE 7x7, LAS POSICIONES VÁLIDAS SON DE 1 A 7 SIN IMPORTAR SI ES FILA O COLUMNA

  validateInput:
    mov     rax,    1
    mov     si,    word[rdi]
    mov     dx,    word[rdi + 2]

    cmp     si,    word[minValue]
    jl      invalid

    cmp     si,    word[maxValue]
    jg      invalid
  
    cmp     dx,    word[minValue]
    jl      invalid

    cmp     dx,    word[maxValue]
    jg      invalid

    ret

  invalid:
    print   invalidMsg
    mov     rax,    0
    ret
    

