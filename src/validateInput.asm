%include "macros.asm"
global validateInput
global validatePieceInput

section .data
  minValue     dw  1
  maxValue     dw  7
  row          dw  0
  col          dw  0
  offset       dw  0
  invalidInputMsg           db "Posicion invalida, intente de nuevo", 10, 0
  invalidNoPieceMsg         db "No hay una pieza en la posicion ingresada", 10, 0
  invalidNotYourPieceMsg    db "La pieza no te pertenece", 10, 0
  invalidDestinationMsg     db "La casilla de destino no esta vacia", 10, 0


section .text
  ;PRE-COND:
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 2 ELEMENTOS (DE 2 BYTES CADA UNO)
  ;POST-COND: DEVUELVE EN RAX 0 SI LA POSICIÓN ES INVÁLIDA, 1 SI ES VALIDA
  ;NOTAS:     COMO EL TABLERO ES DE 7x7, LAS POSICIONES VÁLIDAS SON DE 1 A 7 SIN IMPORTAR SI ES FILA O COLUMNA

  validateInput:
    mov     rax,    1
    mov     si,    word[rdi]
    mov     dx,    word[rdi + 2]

    cmp     si,    word[minValue]
    jl      invalidInput

    cmp     si,    word[maxValue]
    jg      invalidInput

    cmp     dx,    word[minValue]
    jl      invalidInput

    cmp     dx,    word[maxValue]
    jg      invalidInput

    ret

  ;PRE-COND:
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 2 ELEMENTOS (DE 2 BYTES CADA UNO)
  ;     RECIBE EN RDX UN NUMERO QUE INDICA TIPO DE JUGADOR 0 (Soldados) O 1 (Oficiales)
  ;POST-COND: DEVUELVE EN RAX 0 SI NO HAY UNA PIEZA EN LA POSICIÓN INGRESADA O SI LA PIEZA NO PERTENECE AL JUGADOR
  validatePieceInput:
    validatePieceExists:
      ; CONSIGUE NUMEROS INGRESADOS
      mov     ax,    word[rsi]
      mov     word[row],    ax
      mov     ax,    word[rsi + 2]
      mov     word[col],    ax
      ; CALCULA EL OFFSET SEGUN LA FILA
      mov     ax,     word[row]
      sub     ax,    1
      imul    ax,    7                 ; row = (row - 1) * 7 (Se multiplica por 7 porque cada elemento de la matriz es un byte)
      mov     word[offset], ax

      ; CALCULA EL OFFSET SEGUN LA COLUMNA
      mov     ax,    word[col]
      sub     ax,    1     
      add     ax,    word[offset]
      mov     word[offset], ax

      ; SE OBTIENE EL VALOR DE LA POSICIÓN EN LA MATRIZ DEL TABLERO
      add     di,     word[offset]
      mov     al,     byte[rdi]    
      cmp     al,     0
      jle     invalidNoPiece    ; Si no hay una pieza lanza un error

    validatePieceOwnership:
      cmp     dl,     0
      je      playerIsSoldier

      playerIsOfficer:
        cmp   al,     2
        jl    invalidNotYourPiece
        jmp   piecePositionIsValid

      playerIsSoldier:
        cmp   al,     1
        jne    invalidNotYourPiece
        jmp   piecePositionIsValid

    piecePositionIsValid:
      mov     rax, 1
      ret
    
    ; TODO: Crear metodo para verificar que la pieza ingresada tenga movimientos posibles (Varia segun soldado y oficial)

  validateDestinationInput:
    validateDestinationIsFree:
    ret


  invalidNoPiece:
    print   invalidNoPieceMsg
    mov     rax,    0
    ret

  invalidInput:
    print   invalidInputMsg
    mov     rax,    0
    ret

  invalidNotYourPiece:
    print   invalidNotYourPieceMsg
    mov     rax,    0
    ret
    






