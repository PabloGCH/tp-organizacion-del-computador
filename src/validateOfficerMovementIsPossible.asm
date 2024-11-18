global validateOfficerMovementIsPossible
extern getBoardItem
extern returnDirection

%include "macros.asm"


section .data
  errorMsg                                  dq    0
  noPathToDestinationMsg                    db    "No hay un camino para llegar a la casilla de destino", 10, 0
  obstaclesInTheWayMsg                      db    "Hay obstaculos en el camino", 10, 0
  unexpectedErrorMsg                        db    "Error inesperado", 10, 0
  cellAfterSoldierMustBeEmptyMsg            db    "La casilla despues del soldado debe estar vacia", 10, 0
  direction                                 db    0     
  difference                                dw    0    

section .bss
  board                                     resq  1

  startPosition                                     times 2   resw   1
  endPosition                                       times 2   resw   1

  nextPosition                              times 2   resw   1

  positions                                 times 4   resb   1    ; Solo se usa para "returnDirection"



section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ; POST-COND: RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE
  validateOfficerMovementIsPossible:

    init:
      mov  qword[board],  rdi

      mov  ax,  word[rsi]
      mov  word[startPosition],  ax
  
      mov  ax,  word[rsi + 2]
      mov  word[startPosition + 2],  ax

      mov  ax,  word[rsi + 4]
      mov  word[endPosition],  ax

      mov  ax,  word[rsi + 6]
      mov  word[endPosition + 2],  ax

      mov  ax,  word[startPosition]
      mov  word[nextPosition],  ax

      mov  ax,  word[startPosition + 2]
      mov  word[nextPosition + 2],  ax


    ; NO NECESITA CHEQUEAR QUE NO SEAN LAS DOS DIFERENCIAS 0 PORQUE EL DESTINO NUNCA SERA IGUAL A LA POSICION ACTUAL
    ; PORQUE SE VERIFICA QUE EL DESTINO ESTE VACIO EN UNA VALIDACION PREVIA
    checkIfDirectPathIsPossible:
      ; Se verifica la diferencia entre filas
      mov ax, word[startPosition]
      sub ax, word[endPosition]

      sub rsp, 8
      call calculateModuleOfAx
      add rsp, 8

      cmp ax, 0                     ; Si no hubo diferencia es un movimiento horizontal
      je convertPositions

      mov word[difference], ax

      ; Se verifica la diferencia entre columnas
      mov ax, word[startPosition + 2]
      sub ax, word[endPosition + 2]

      sub rsp, 8
      call calculateModuleOfAx
      add rsp, 8

      cmp ax, 0                     ; Si no hubo diferencia es un movimiento vertical
      je convertPositions

      ; Se comparan las diferencias
      cmp ax, word[difference]      ; Si la diferencia en x es igual a la diferencia en y es un movimiento diagonal
      je convertPositions

      jmp noPathToDestination

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
      mov  dil,  byte[positions + 1]    ; Columna (x)
      mov  sil,  byte[positions]         ; Fila (y)
      mov  dh,  byte[positions + 3]      ; Columna (x)
      mov  dl,  byte[positions + 2]      ; Fila (y)

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

      sub  rsp,  8
      call  incrementPosition
      add  rsp,  8

      mov  eax,  dword[nextPosition]
      cmp  eax,  dword[endPosition]
      je  valid                         ; SI LLEGO AL DESTINO ES VALIDO

      mov  rdi,  qword[board]
      mov  rsi,  nextPosition

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
      
      mov  rdi,  qword[board]
      mov  rsi,  nextPosition
    
      sub  rsp,  8
      call  getBoardItem
      add  rsp,  8
      
      cmp  al,  0
      je  valid
    
      mov    qword[errorMsg],    cellAfterSoldierMustBeEmptyMsg
      jmp    invalid
    
    obstaclesInTheWay:
      mov    qword[errorMsg],    obstaclesInTheWayMsg
      jmp    invalid

    noPathToDestination:
      mov    qword[errorMsg],    noPathToDestinationMsg
      jmp    invalid

    unexpectedError:
      mov    qword[errorMsg],    unexpectedErrorMsg
      jmp    invalid

    valid:
      mov    rax,    1
      ret

    invalid:   
      xor     rdi,    rdi
      xor     rsi,    rsi
      xor     rdx,    rdx
      
      print   qword[errorMsg]
      mov     rax,    0
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
      inc     word[nextPosition + 2]
      ret
    incrementRight:
      inc     word[nextPosition + 2]
      ret
    incrementDownRight:
      inc     word[nextPosition]
      inc     word[nextPosition + 2]
      ret
    incrementDown:
      inc     word[nextPosition]
      ret
    incrementDownLeft:
      inc     word[nextPosition]
      dec     word[nextPosition + 2]
      ret
    incrementLeft:
      dec     word[nextPosition + 2]
      ret
    incrementUpLeft:
      dec     word[nextPosition]
      dec     word[nextPosition + 2]
      ret




    calculateModuleOfAx:
      cmp     ax,    0
      jl      negative
      ret
      negative:
        neg     ax
        ret
