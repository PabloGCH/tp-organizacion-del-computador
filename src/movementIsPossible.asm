global movementIsPossible
extern validateSoldierMovementIsPossible
extern validateOfficerMovementIsPossible
%include "macros.asm"

section .data
  playerType     db  0


section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ;     RECIBE EN RDX UN NUMERO QUE INDICA TIPO DE JUGADOR 0 (Soldados) O 1 (Oficiales)
  ;     RECIBE EN RCX LA DIRECCIÓN EN LA QUE SE ENCUENTRA LA FORTALEZA (0 = Up, 1 = Right, 2 = Down, 3 = Left)
  ; POST-COND: RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE

  movementIsPossible:
    mov     byte[playerType],    dl
    mov     rdx,                 rcx
    cmp     byte[playerType],    0
    je      validateSoldierMovementIsPossible
    jne     validateOfficerMovementIsPossible
    ret



      















