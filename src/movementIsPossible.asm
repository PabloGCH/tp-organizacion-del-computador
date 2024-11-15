global movementIsPossible
%include "macros.asm"

section .data
  strongholdDir                         db    0           ;  0 = Up, 1 = Right, 2 = Down, 3 = Left
  strongholdPointOfReference            dw    0, 0        ;  Fila y columna fuera del tablero que sirve como punto de referencia para saber si una pieza se esta moviendo hacia la fortaleza o no.
  canOnlyMoveTowardsStrongholdMsg       db    "Solo se puede mover hacia la fortaleza", 10, 0
  cannotMoveMoreThanOnePositionMsg      db    "No se puede mover mas de una posicion", 10, 0
  errorMsg                              dq    0

  distanceFromPieceToStronghold         dw    0
  distanceFromDestinationToStronghold   dw    0

  rowDistance                           dw    0
  colDistance                           dw    0



section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ;     RECIBE EN RDX UN NUMERO QUE INDICA TIPO DE JUGADOR 0 (Soldados) O 1 (Oficiales)
  ;     RECIBE EN RCX LA DIRECCIÓN EN LA QUE SE ENCUENTRA LA FORTALEZA (0 = Up, 1 = Right, 2 = Down, 3 = Left)
  ; POST-COND: RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE

  movementIsPossible:
    cmp     dl,    0
    je      validateSoldierMovementIsPossible
    
    validateOfficerMovementIsPossible:
      jmp     valid
      
    validateSoldierMovementIsPossible:
      mov     byte[strongholdDir],    cl
      ; Validar que solo se este moviendo 1 posicion
  
      sub     rsp,    8
      call    validateMovementIsOnePosition
      add     rsp,    8
      
      cmp     rax,    0
      je      invalid

      ; Validar que se este moviendo hacia la fortaleza

      sub     rsp,    8
      call    initStrongholdPointOfReference
      add     rsp,    8

      sub     rsp,    8
      call    validateGettingCloserToStronghold
      add     rsp,    8

      cmp     rax,    0
      je      invalid

      jmp     valid

    valid:
      mov     rax,    1
      ret

    invalid:
      print   qword[errorMsg]
      mov     rax,    0
      ret





  ; RETORNA 0 SI SE ESTA INTENTANDO MOVER MÁS DE UNA POSICION
  validateMovementIsOnePosition:
    ; CALCULAR DISTANCIA ENTRE FILAS
    mov     ax,    word[rsi]
    sub     ax,    word[rsi + 4]

    sub     rsp,    8
    call    calculateModule           ; Se calcula el modulo de la diferencia
    add     rsp,    8

    cmp     ax,    1
    jg      tryingToMoveMoreThanOnePosition
    
    ; CALCULAR DISTANCIA ENTRE COLUMNAS
    mov     ax,    word[rsi + 2]
    sub     ax,    word[rsi + 6]
    
    sub     rsp,    8
    call    calculateModule           ; Se calcula el modulo de la diferencia
    add     rsp,    8

    cmp     ax,    1
    jg      tryingToMoveMoreThanOnePosition

    mov     ax,    1
    ret

    tryingToMoveMoreThanOnePosition:
      mov     qword[errorMsg],    cannotMoveMoreThanOnePositionMsg
      mov     rax,    0
      ret


  calculateModule:
    cmp     ax,    0
    jl      negative
    ret
    negative:
      neg     ax
      ret


  ; RETORNA 0 SI NO SE ESTA ACERCANDO A LA FORTALEZA
  ; SE USA EL METODO MANHATTAN PARA CALCULAR LA DISTANCIA ENTRE DOS PUNTOS

  validateGettingCloserToStronghold:
    xor     rax,    rax
    mov     word[distanceFromPieceToStronghold],    0
    mov     word[distanceFromDestinationToStronghold],    0

    ; CALCULAR DISTANCIA ENTRE FILA DE PIEZA Y PUNTO DE REFERENCIA
    mov     ax,    word[rsi]
    sub     ax,    word[strongholdPointOfReference]

    sub     rsp,    8
    call    calculateModule           ; Se calcula el modulo de la diferencia
    add     rsp,    8

    add     word[distanceFromPieceToStronghold],    ax

    ; CALCULAR DISTANCIA ENTRE COLUMNA DE PIEZA Y PUNTO DE REFERENCIA
    mov     ax,    word[rsi + 2]
    sub     ax,    word[strongholdPointOfReference + 2]

    sub     rsp,    8
    call    calculateModule           ; Se calcula el modulo de la diferencia
    add     rsp,    8

    add     word[distanceFromPieceToStronghold],    ax

    ; CALCULAR DISTANCIA ENTRE FILA DE DESTINO Y PUNTO DE REFERENCIA
    mov     ax,    word[rsi + 4]
    sub     ax,    word[strongholdPointOfReference]
    
    sub     rsp,    8
    call    calculateModule           ; Se calcula el modulo de la diferencia
    add     rsp,    8

    add     word[distanceFromDestinationToStronghold],    ax
    
    ; CALCULAR DISTANCIA ENTRE COLUMNA DE DESTINO Y PUNTO DE REFERENCIA
    mov     ax,    word[rsi + 6]
    sub     ax,    word[strongholdPointOfReference + 2]
  
    sub     rsp,    8
    call    calculateModule           ; Se calcula el modulo de la diferencia
    add     rsp,    8

    add     word[distanceFromDestinationToStronghold],    ax
    
    mov     ax,    word[distanceFromPieceToStronghold]
    cmp     ax,    word[distanceFromDestinationToStronghold]
    jle     notGettingCloserToStronghold
    mov     rax,    1
    ret
    
    notGettingCloserToStronghold:
      mov     qword[errorMsg],    canOnlyMoveTowardsStrongholdMsg
      mov     rax,    0
      ret


  initStrongholdPointOfReference:
    mov     byte[strongholdDir],    cl
    cmp     cl,    0
    je      strongholdIsUp
    cmp     cl,    1
    je      strongholdIsRight
    cmp     cl,    2
    je      strongholdIsDown
    cmp     cl,    3
    je      strongholdIsLeft
    ret

    strongholdIsUp:
      mov     word[strongholdPointOfReference],    0
      mov     word[strongholdPointOfReference + 2],    4
      ret

    strongholdIsRight:
      mov     word[strongholdPointOfReference],    4
      mov     word[strongholdPointOfReference + 2],    8
      ret
      
    strongholdIsDown:
      mov     word[strongholdPointOfReference],    8
      mov     word[strongholdPointOfReference + 2],    4
      ret

    strongholdIsLeft:
      mov     word[strongholdPointOfReference],    4
      mov     word[strongholdPointOfReference + 2],    0
      ret








