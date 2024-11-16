global movementIsPossible
%include "macros.asm"

section .data
  strongholdDir                             db    0           ;  0 = Up, 1 = Right, 2 = Down, 3 = Left
  strongholdPointOfReference                dw    0, 0        ;  Fila y columna fuera del tablero que sirve como punto de referencia para saber si una pieza se esta moviendo hacia la fortaleza o no.
  canOnlyMoveTowardsStrongholdMsg           db    "Solo se puede mover hacia la fortaleza",   10,     0
  cannotMoveMoreThanOnePositionMsg          db    "No se puede mover mas de una celda",       10,     0
  cannotMoveSidewaysMsg                     db    "No se puede mover hacia los costados",     10,     0
  fromThatPositionCanOnlyMoveSideWaysMsg    db    "Desde esa posicion solo se puede mover hacia los costados", 10, 0
  errorMsg                                  dq    0

  distanceFromPieceToStronghold             dw    0
  distanceFromDestinationToStronghold       dw    0

  rowDistance                               dw    0
  colDistance                               dw    0



section .bss
  board                                 resq  1
  movingSideWays                        resb  1



section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ;     RECIBE EN RDX UN NUMERO QUE INDICA TIPO DE JUGADOR 0 (Soldados) O 1 (Oficiales)
  ;     RECIBE EN RCX LA DIRECCIÓN EN LA QUE SE ENCUENTRA LA FORTALEZA (0 = Up, 1 = Right, 2 = Down, 3 = Left)
  ; POST-COND: RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE

  movementIsPossible:
    mov     qword[board],    rdi
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

      ; Validar que no se este moviendo hacia "los costados"
      
      sub     rsp,    8
      call    validateNotMovingSideways
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

  validateNotMovingSideways:
    mov     byte[movingSideWays],    0

    cmp     byte[strongholdDir],    0  
    je      validateNotMovingSidewaysWithStrongholdUp

    cmp     byte[strongholdDir],    1
    je      validateNotMovingSidewaysWithStrongholdRight

    cmp     byte[strongholdDir],    2
    je      validateNotMovingSidewaysWithStrongholdDown

    cmp     byte[strongholdDir],    3
    je      validateNotMovingSidewaysWithStrongholdLeft
    
    ret
    
    validateNotMovingSidewaysWithStrongholdDown:
      ; SE VERIFICA SI ESTA INTENTANDO MOVERSE A LOS COSTADOS
      mov     ax,    word[rsi]
      sub     ax,    word[rsi + 4]

      cmp     ax,    0
      je      movingSideWaysWithStrongholdDown

      notMovingSideWaysWithStrongholdDown:
        ; SI NO SE ESTA MOVIENDO HACIA LOS COSTADOS SE VERIFICA QUE ABAJO NO HAYA UN -1
        ; YA QUE DESDE ESA POSICION SOLO SE PUEDE MOVER HACIA LOS COSTADOS
        mov     ax,    word[rsi]
        imul    ax,    7                  ; No se le resta 1 porque queremos la fila de siguiente, no la actual
        mov     di,    word[rsi + 2]
        sub     di,    1
        add     ax,    di
        mov     rdx,    qword[board]
        add     dx,    ax
        mov     al,    byte[rdx]
        cmp     al,    -1
        je      canOnlyMoveSideWays
      
      movingSideWaysWithStrongholdDown:
        ; SI ESTA EN LA ULTIMA FILA NO HAY NADA ABAJO. POR LO TANTO NO SE PUEDE MOVER HACIA LOS COSTADOS
        mov     ax,    word[rsi]
        cmp     ax,    8
        je      cannotMoveSideways

        ; SI NO ESTA EN LA ULTIMA FILA, SE VALIDA SI HAY UN -1 EN LA CELDA DE ABAJO, EN CASO DE QUE SEA ASI PUEDE MOVER HACIA LOS COSTADOS, SINO NO
        mov     ax,    word[rsi]
        imul    ax,    7                  ; No se le resta 1 porque queremos la fila de siguiente, no la actual
        mov     di,    word[rsi + 2]
        sub     di,    1

        add     ax,    di

        mov     rdx,    qword[board]
        add     dx,    ax
        
        mov     al,    byte[rdx]

        cmp     al,    -1
        je      sideWaysMovementValidationPassed

        jmp     cannotMoveSideways
      

    validateNotMovingSidewaysWithStrongholdLeft:
      ; INICIO Y DESTINO NO PUEDEN COMPARTIR COLUMNA
      jmp     sideWaysMovementValidationPassed

    validateNotMovingSidewaysWithStrongholdUp:
      ; INICIO Y DESTINO NO PUEDEN COMPARTIR FILA
      jmp     sideWaysMovementValidationPassed

    validateNotMovingSidewaysWithStrongholdRight:
      ; INICIO Y DESTINO NO PUEDEN COMPARTIR COLUMNA
      jmp     sideWaysMovementValidationPassed


    sideWaysMovementValidationPassed:
      mov     rax,    1
      ret

    cannotMoveSideways:
      mov     qword[errorMsg],    cannotMoveSidewaysMsg
      mov     rax,    0
      ret

    canOnlyMoveSideWays:
      mov     qword[errorMsg],    fromThatPositionCanOnlyMoveSideWaysMsg
      mov     rax,    0
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
    je      strongholdIsUpInit
    cmp     cl,    1
    je      strongholdIsRightInit
    cmp     cl,    2
    je      strongholdIsDownInit
    cmp     cl,    3
    je      strongholdIsLeftInit
    ret

    strongholdIsUpInit:
      mov     word[strongholdPointOfReference],    0
      mov     word[strongholdPointOfReference + 2],    4
      ret

    strongholdIsRightInit:
      mov     word[strongholdPointOfReference],    4
      mov     word[strongholdPointOfReference + 2],    8
      ret
      
    strongholdIsDownInit:
      mov     word[strongholdPointOfReference],    8
      mov     word[strongholdPointOfReference + 2],    4
      ret

    strongholdIsLeftInit:
      mov     word[strongholdPointOfReference],    4
      mov     word[strongholdPointOfReference + 2],    0
      ret

