global validateOfficerMovementIsPossible
extern returnDirection


section .data
  board                                     resq  1

  start                                     times 2   resw   1
  end                                       times 2   resw   1

  nextPosition                              times 2   resw   1

  positions                                 times 4   resb   1    ; Solo se usa para "returnDirection"

  errorMsg                                  dq    0
  noPathToDestinationMsg                    db    "No hay un camino para llegar a la casilla de destino", 10, 0
  obstackesInTheWayMsg                      db    "Hay obstaculos en el camino", 10, 0
  unexpectedErrorMsg                        db    "Error inesperado", 10, 0
  cellAfterSoldierMustBeEmptyMsg            db    "La casilla despues del soldado debe estar vacia", 10, 0
  direction                                 db    0     


section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ; POST-COND: RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE
  validateOfficerMovementIsPossible:

    init:
      mov  word[board],  rdi
      mov  word[start],  word[rsi]
      mov  word[start + 2],  word[rsi + 2]
      mov  word[end],  word[rsi + 4]
      mov  word[end + 2],  word[rsi + 6]
      mov  word[nextPosition],  word[start]
      mov  word[nextPosition + 2],  word[start + 2]

    convertPositions:
      ; TRANSFORMA LAS POSICIONES QUE SE RECIBEN AL FORMATO REQUERIDO POR "returnDirection"
      mov  ax,  word[rsi]
      mov  byte[positions],  al
      mov  ax,  word[rsi + 2]
      mov  byte[positions + 1],  al
      mov  ax,  word[rsi + 4]
      mov  byte[positions + 2],  al
      mov  ax,  word[rsi + 6]
      mov  byte[positions + 3],  al

    getDirection:
      mov  dil,  byte[positions]
      mov  sil,  byte[positions + 1]
      mov  dh,  byte[positions + 2]
      mov  dl,  byte[positions + 3]

      sub  rsp,  8
      call  returnDirection
      add  rsp,  8

      cmp  rax,  0
      je  noPathToDestination

      mov  byte[direction],  al
      
    checkForSoldiersOnPath:
      ; Se va incrementando la posición hasta llegar a la posición de destino
      ; Si no se encuentra ninguno es valido. Si se encuentra uno y la posicion siguiente no es el destino, es invalido. Si se encuentra uno y la posicion siguiente es el destino, es valido.
      ; No se verifica si esta fuera o no porque ya hay una validación previa que lo hace

      mov  eax,  dword[nextPosition]
      cmp  eax,  dword[end]
      je  valid                         ; SI LLEGO AL DESTINO ES VALIDO
      
      sub  rsp,  8
      call  incrementPosition
      add  rsp,  8

      mov  rdi,  word[board]
      mov  rsi,  word[nextPosition]

      sub  rsp,  8
      call  getBoardItem
      add  rsp,  8

      ; SI ES UN ESPACIO LIBRE REPITE EL LOOP
      cmp  al,  0
      je  checkForSoldiersOnPath

      ; SI NO EXISTE UNA CELDA EN EL CAMINO ES INVALIDO
      cmp  al,  -1
      je  noPathToDestination

      ; SI ES UN OFICIAL ES INVALIDO
      cmp  al,  2
      je  obstaclesInTheWay
      cmp  al,  3
      je  obstaclesInTheWay

      ; SI HAY UN SOLDADO EN EL CAMINO REVISA QUE LA SIGUIENTE POSICION SEA EL DESTINO
      cmp  al,  1
      je  checkPositionNextToSoldier
      
      ; DEBERIA SER IMPOSIBLE LLEGAR A ESTE PUNTO PERO SE MANEJA POR SI ACASO
      jmp  unexpectedError

    
    checkPositionNextToSoldier:
      sub  rsp,  8
      call  incrementPosition
      add  rsp,  8
      
      mov  rdi,  nextPosition
    
      sub  rsp,  8
      call  getBoardItem
      add  rsp,  8
      
      cmp  al,  0
      je  valid

      mov    errorMsg,    cellAfterSoldierMustBeEmptyMsg
      jmp    invalid
    
    obstaclesInTheWay:
      mov    errorMsg,    obstackesInTheWayMsg
      jmp    invalid

    noPathToDestinationMsg:
      mov    errorMsg,    noPathToDestinationMsg
      jmp    invalid

    unexpectedError:
      mov    errorMsg,    unexpectedErrorMsg
      jmp    invalid

    valid:
      mov    rax,    1
      ret

    invalid:   
      print  errorMsg
      mov    rax,    0
      ret

  ; INCREMENTA "nextPosition" SEGÚN EL MOVIMIENTO RECIBIDO
  incrementPosition:
    cmp     byte[direction],    1
    je      incrementUp
    cmp     byte[direction],    2
    je      incrementUpRight
    cmp     byte[direction],    3
    je      incrementRight
    cmp     byte[direction],    4
    je      incrementDownRight
    cmp     byte[direction],    5
    je      incrementDown
    cmp     byte[direction],    6
    je      incrementDownLeft
    cmp     byte[direction],    7
    je      incrementLeft
    cmp     byte[direction],    8
    je      incrementUpLeft
    ret
    incrementUp:
      inc     word[nextPosition]
      ret
    incrementUpRight:
      inc     word[nextPosition]
      inc     word[nextPosition + 1]
      ret
    incrementRight:
      inc     word[nextPosition + 1]
      ret
    incrementDownRight:
      inc     word[nextPosition]
      inc     word[nextPosition + 1]
      ret
    incrementDown:
      inc     word[nextPosition]
      ret
    incrementDownLeft:
      inc     word[nextPosition]
      dec     word[nextPosition + 1]
      ret
    incrementLeft:
      dec     word[nextPosition + 1]
      ret
    incrementUpLeft:
      dec     word[nextPosition]
      dec     word[nextPosition + 1]
      ret

  calculateModuleOfAx:
    cmp     ax,    0
    jl      negative
    ret
    negative:
      neg     ax
      ret

















