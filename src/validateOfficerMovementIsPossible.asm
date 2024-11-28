global validateOfficerMovementIsPossible
extern getBoardItem
extern returnDirection
extern removePiece
extern statCounterAdd

%include "macros.asm"


section .data
  errorMsg                                  dq    0
  noPathToDestinationMsg                    db    "No hay un camino para llegar a la casilla de destino", 10, 0
  obstaclesInTheWayMsg                      db    "Hay obstaculos en el camino", 10, 0
  unexpectedErrorMsg                        db    "Error inesperado", 10, 0
  positionAfterSoldierMustBeDestinationMsg  db    "La casilla despues del soldado debe ser la de destino", 10, 0
  direction                                 db    0     
  difference                                dw    0    

section .bss
  board                                     resq  1

  startPosition                             times 2   resw   1
  endPosition                               times 2   resw   1

  nextPosition                              times 2   resw   1

  previousPosition                          times 2   resw   1

  positions                                 times 4   resb   1    ; Solo se usa para "returnDirection"

  officerToLookFor                          resb 1                ; 2 si es el oficial 1, 3 si es el oficial 2

  currentOfficer                            resb 1                ; Para aumentar stat

  validatingIdleOfficer                     resb 1                ; 0 si es la primera busqueda (Oficial que se movio), 1 si es la segunda (Oficial que no se movio)



section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ; POST-COND:
  ;   - RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE
  ;   - RETORNA 1 SI EL MOVIMIENTO ES POSIBLE
  validateOfficerMovementIsPossible:

    init:
      mov  byte[validatingIdleOfficer],  0

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

    ; Ya se validó que se pueda hacer movimiento, asi que se incrementa el contador
    increaseDirection:

      mov rdi, qword[board]
      mov rsi, startPosition
      sub rsp, 8
      call getBoardItem
      add rsp, 8
      mov byte[currentOfficer], al

      xor rdi, rdi ; Zero RDI so it only has the single byte
      mov dil, byte[direction]
      xor rsi, rsi ; Zero RSI so it only has the single byte
      mov sil, byte[currentOfficer]
      sub rsi, 2 ; Stat Counter Add usa 0/1 para oficiales en lugar de 2/3
      mov dl, 1 ; 1 Movimiento
      sub rsp, 8
      call statCounterAdd
      add rsp, 8

      
    checkForSoldiersOnPath:
      ; Se va incrementando la posición hasta llegar a la posición de destino
      ; Si no se encuentra ninguno es valido. Si se encuentra uno y la posicion siguiente no es el destino, es invalido. Si se encuentra uno y la posicion siguiente es el destino, es valido.
      ; No se verifica si esta fuera o no porque ya hay una validación previa que lo hace

      sub  rsp,  8
      call  incrementPosition
      add  rsp,  8

      mov  eax,  dword[nextPosition]
      cmp  eax,  dword[endPosition]
      je   validMovementWithoutCapture

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
  
    
    validMovementWithoutCapture:
      ; SE VERIFICA QUE NO HUBIERAN CAPTURAS POSIBLES AL REALIZAR EL MOVIMIENTO
      mov byte[direction], 1
      mov eax,                    dword[startPosition]
      mov dword[nextPosition],    eax

      checkForCapture:

        sub rsp, 8
        call incrementPosition
        add rsp, 8

        sub rsp, 8
        call nextPositionOutOfBounds
        add rsp, 8

        cmp rax, 1                    ; SI LA POSICION ESTA FUERA DEL TABLERO SE PRUEBA CON LA SIGUIENTE DIRECCIÓN
        je checkNextDirection
        

        mov rdi, qword[board]
        mov rsi, nextPosition
        
        sub rsp, 8
        call getBoardItem
        add rsp, 8

        cmp al, 2                     ; SI HAY UN OFICIAL EN EL CAMINO SALTEAR A LA SIGUIENTE DIRECCIÓN
        je  checkNextDirection
        cmp al, 3                     ; IDEM DE COMENTARIO ANTERIOR
        je  checkNextDirection
        cmp al, -1                    ; SI LA CELDA NO EXISTE SALTEAR A LA SIGUIENTE DIRECCIÓN
        je  checkNextDirection
        cmp al, 1                     ; SI HAY UN SOLDADO EN EL CAMINO SE REVISA SI SE PUEDE CAPTURAR
        je  verifyCaptureOfSoldierOnPath

        jmp checkForCapture           ; SI NO HAY NADA EN EL CAMINO SE REPITE EL LOOP PARA REVISAR LA SIGUIENTE CELDA


        verifyCaptureOfSoldierOnPath:
          ; SI HAY UNA CELDA VACIA DESPUES DEL SOLDADO, EL OFICIAL MUERE PORQUE HABIA UNA CAPTURA POSIBLE
          sub   rsp, 8
          call  incrementPosition
          add   rsp, 8
    
          sub   rsp, 8
          call  nextPositionOutOfBounds
          add   rsp, 8
        
          cmp   rax, 1
          je    checkNextDirection      ; SI DESPUES DEL SOLDADO NO HAY MÁS CELDAS SE PRUEBA CON LA SIGUIENTE DIRECCIÓN

          mov   rdi, qword[board]
          mov   rsi, nextPosition
          
          sub   rsp, 8
          call  getBoardItem
          add   rsp, 8

          cmp   al, 0
          je    officerDiesByMissedCapture
          jmp   checkNextDirection
          
          
        checkNextDirection:
          ; SE PRUEBA CON LA SIGUIENTE DIRECCIÓN Y SE RESETEA LA SIGUIENTE POSICION
          ; SI NO QUEDAN DIRECCIÓNES POR PROBAR, EL OFICIAL NO MUERE
          inc byte[direction]
          mov eax, dword[startPosition]
          mov dword[nextPosition], eax
          cmp byte[direction], 9
          je officerDoesNotDie
          jmp checkForCapture

        officerDiesByMissedCapture:
          mov rdi, qword[board]
          mov rsi, startPosition

          sub rsp, 8
          call removePiece
          add rsp, 8
    
          cmp byte[validatingIdleOfficer], 1
          je idleOfficerDies

          movingOfficerDies:
            mov rax, 2
            ret

          idleOfficerDies:
            mov rax, 1
            ret

        officerDoesNotDie:
          cmp byte[validatingIdleOfficer], 1               ; SI ESTE ES EL "OTRO" OFICIAL Y NO MURIO NO HAY NADA MAS QUE HACER
          je officerDoesNotDieAndThereIsNoOtherOfficer

          sub rsp, 8
          call getPositionOfTheOtherOffice                 ; SETEA "startPosition" CON LA POSICIÓN DEL OTRO OFICIAL
          add rsp, 8

          cmp rax, 0
          je officerDoesNotDieAndThereIsNoOtherOfficer

          mov byte[validatingIdleOfficer], 1               ; SE SETEA COMO "true" QUE SE ESTA BUSCANDO EL OTRO OFICIAL

          jmp checkForCapture                              ; SE REPITE LA VALIDACIÓN PARA EL OTRO OFICIAL
          
          officerDoesNotDieAndThereIsNoOtherOfficer:
            mov rax, 1
            ret
        
    checkPositionNextToSoldier:
      mov  eax, dword[nextPosition]
      mov  dword[previousPosition], eax

      sub  rsp,  8
      call  incrementPosition
      add  rsp,  8
      
      mov  rdi,  qword[board]
      mov  rsi,  nextPosition
    
      sub  rsp,  8
      call  getBoardItem
      add  rsp,  8
      
      cmp  al,  0
      je  positionAfterSoldierMustBeDestination
    
      mov    qword[errorMsg],    obstaclesInTheWayMsg
      jmp    invalid

      positionAfterSoldierMustBeDestination:
        mov  eax,  dword[nextPosition]
        cmp  eax,  dword[endPosition]
        je   captureSoldier

        mov    qword[errorMsg],  positionAfterSoldierMustBeDestinationMsg
        jmp    invalid

        
        captureSoldier:
          ; SE CONSIGUE LA PIEZA DEL OFICIAL QUE REALIZO LA CAPTURA
          mov  rdi,  qword[board]
          mov  rsi,  startPosition

          sub  rsp,  8
          call  getBoardItem
          add  rsp,  8
          
          ; TODO: EN RAX QUEDA EL NUMERO DEL OFICIAl (2 o 3) AQUI HABRIA QUE AGREGAR EL INCREMENTO DEL CONTADOR DE PIEZAS CAPTURADAS
          ;       DE ESE OFICIAL

          mov rsi, rax
          sub rsi, 2  ; statManager usa 0/1 en vez de 2/3
          mov rdi, 0  ; Captura -> 0
          mov dl , 1  ; Cantidad de capturas
          sub rsp, 8
          call statCounterAdd
          add rsp, 8


          mov  rdi,  qword[board]
          mov  rsi,  previousPosition

          sub  rsp,  8
          call removePiece
          add  rsp,  8
          
          jmp   valid
        
    
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
      mov rax,    1
      ret

    invalid:   
      print   qword[errorMsg]
      mov     rax,    0
      ret




  nextPositionOutOfBounds:
    ; SI LA POSICION ESTA FUERA DEL TABLERO SE PRUEBA CON LA SIGUIENTE DIRECCIÓN
    cmp word[nextPosition], 0
    jle outOfBounds
    cmp word[nextPosition + 2], 0
    jle outOfBounds
    cmp word[nextPosition], 8
    jge outOfBounds
    cmp word[nextPosition + 2], 8
    jge outOfBounds
    mov rax, 0
    ret
    outOfBounds:
      mov rax, 1
      ret
    
  ; Setea startPosition con la posición del otro oficial
  ; Retorna 0 si no se encuentra el oficial
  getPositionOfTheOtherOffice:
    mov rdi, qword[board]
    mov rsi, startPosition

    sub rsp, 8
    call getBoardItem
    add rsp, 8

    cmp al, 2
    je lookingForOfficerTwo

    cmp al, 3
    je lookingForOfficerOne

    lookingForOfficerOne:
      mov byte[officerToLookFor], 2
      jmp findPositionOfTheOtherOfficer

    lookingForOfficerTwo:
      mov byte[officerToLookFor], 3
      jmp findPositionOfTheOtherOfficer

    findPositionOfTheOtherOfficer:
      ; INICIALIZA LA POSICIÓN DE BÚSQUEDA
      mov word[startPosition],  1
      lookForOfficerInRow:
        mov word[startPosition + 2], 1
        lookForOfficerInColumn:
          mov rdi, qword[board]
          mov rsi, startPosition

          sub rsp, 8
          call getBoardItem               ; CONSIGUE EL ELEMENTO DE LA MATRIZ
          add rsp, 8

          cmp al, byte[officerToLookFor]  ; COMPARA CON EL OFICIAL QUE SE BUSCA
          je foundOfficer

          inc word[startPosition + 2]
          cmp word[startPosition + 2], 8
          jl lookForOfficerInColumn

          inc word[startPosition]
          cmp word[startPosition], 8
          jl lookForOfficerInRow

      officerNotFound:
        mov rax, 0
        ret

      foundOfficer:
        mov rax, 1
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
      dec     word[nextPosition]
      ret
    incrementUpRight:
      dec     word[nextPosition]
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
