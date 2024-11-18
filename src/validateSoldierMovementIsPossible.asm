global validateSoldierMovementIsPossible
%include "macros.asm"


section .data
  strongholdDir                             db    0           ;  0 = Up, 1 = Right, 2 = Down, 3 = Left
  canOnlyMoveTowardsStrongholdMsg           db    "Solo se puede mover hacia la fortaleza",   10,     0
  cannotMoveMoreThanOnePositionMsg          db    "No se puede mover mas de una celda",       10,     0
  cannotMoveSidewaysMsg                     db    "No se puede mover hacia los costados",     10,     0
  fromThatPositionCanOnlyMoveSideWaysMsg    db    "Desde esa posicion solo se puede mover hacia los costados", 10, 0
  errorMsg                                  dq    0
  distance                                  dw    0


section .bss
  board                                 resq  1


section .text
  ; PRE-COND:  LA SUBRUTINA RECIBE
  ;     RECIBE EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO (Cada elemento es un byte)
  ;     RECIBE EN RSI LA DIRECCIÓN DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS (DE 2 BYTES CADA UNO) (Fila de pieza, columna de pieza, fila de destino, columna de destino)
  ;     RECIBE EN RDX LA DIRECCIÓN EN LA QUE SE ENCUENTRA LA FORTALEZA (0 = Up, 1 = Right, 2 = Down, 3 = Left)
  ; POST-COND: RETORNA 0 SI EL MOVIMIENTO NO ES POSIBLE
  validateSoldierMovementIsPossible:
    mov     qword[board],    rdi
    mov     byte[strongholdDir],    dl

    ; Validar que solo se este moviendo 1 posicion

    sub     rsp,    8
    call    validateMovementIsOnePosition
    add     rsp,    8
    
    cmp     rax,    0
    je      invalid

    ; Validar que se este moviendo hacia la fortaleza

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
  call    calculateModuleOfAx           ; Se calcula el modulo de la diferencia
  add     rsp,    8

  cmp     ax,    1
  jg      tryingToMoveMoreThanOnePosition
  
  ; CALCULAR DISTANCIA ENTRE COLUMNAS
  mov     ax,    word[rsi + 2]
  sub     ax,    word[rsi + 6]
  
  sub     rsp,    8
  call    calculateModuleOfAx           ; Se calcula el modulo de la diferencia
  add     rsp,    8

  cmp     ax,    1
  jg      tryingToMoveMoreThanOnePosition

  mov     ax,    1
  ret

  tryingToMoveMoreThanOnePosition:
    mov     qword[errorMsg],    cannotMoveMoreThanOnePositionMsg
    mov     rax,    0
    ret



validateNotMovingSideways:

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
      imul    ax,    7                  ; No se le resta 1 porque busca la fila la celda siguiente, no la actual

      mov     di,    word[rsi + 2]
      sub     di,    1
      add     ax,    di

      mov     rdx,   qword[board]
      add     dx,    ax

      mov     al,    byte[rdx]

      cmp     al,    -1
      je      canOnlyMoveSideWays
      jmp     sideWaysMovementValidationPassed
    
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
    ; SE VERIFICA SI ESTA INTENTANDO MOVERSE A LOS COSTADOS
    mov     ax,    word[rsi + 2]
    sub     ax,    word[rsi + 6]

    cmp     ax,    0
    je      movingSideWaysWithStrongholdLeft
    
    notMovingSideWaysWithStrongholdLeft:
      ; SI NO SE ESTA MOVIENDO HACIA LOS COSTADOS SE VERIFICA QUE A LA IZQUIERDA NO HAYA UN -1
      ; YA QUE DESDE ESA POSICION SOLO SE PUEDE MOVER HACIA LOS COSTADOS
      mov     ax,    word[rsi]
      sub     ax,    1
      imul    ax,    7
      
      mov     di,    word[rsi + 2]
      sub     di,    1
      
      add     ax,    di
      
      mov     rdx,    qword[board]
      add     dx,    ax

      mov     al,    byte[rdx]

      cmp     al,    -1
      je      canOnlyMoveSideWays
      jmp     sideWaysMovementValidationPassed
  
    movingSideWaysWithStrongholdLeft:
      ; SI ESTA EN LA PRIMERA COLUMNA NO HAY NADA A LA IZQUIERDA. POR LO TANTO NO SE PUEDE MOVER HACIA LOS COSTADOS
      mov     ax,    word[rsi + 2]
      cmp     ax,    1
      je      cannotMoveSideways

      ; SI NO ESTA EN LA PRIMERA COLUMNA, SE VALIDA SI HAY UN -1 EN LA CELDA DE LA IZQUIERDA, EN CASO DE QUE SEA ASI PUEDE MOVER HACIA LOS COSTADOS, SINO NO
      mov     ax,    word[rsi]
      sub     ax,    1
      imul    ax,    7
      
      mov     di,    word[rsi + 2]
      sub     di,    1
      
      add     ax,    di
      
      mov     rdx,    qword[board]
      add     dx,    ax
      mov     al,    byte[rdx]

      cmp     al,    -1
      je      sideWaysMovementValidationPassed

      jmp     cannotMoveSideways


  validateNotMovingSidewaysWithStrongholdUp:
    ; SE VERIFICA SI ESTA INTENTANDO MOVERSE A LOS COSTADOS
    mov     ax,    word[rsi]
    sub     ax,    word[rsi + 4]

    cmp     ax,    0
    je      movingSideWaysWithStrongholdUp

    notMovingSideWaysWithStrongholdUp:
      ; SI NO SE ESTA MOVIENDO HACIA LOS COSTADOS SE VERIFICA QUE ARRIBA NO HAYA UN -1
      ; YA QUE DESDE ESA POSICION SOLO SE PUEDE MOVER HACIA LOS COSTADOS
      mov     ax,    word[rsi]
      sub     ax,    1
      imul    ax,    7
      
      mov     di,    word[rsi + 2]
      sub     di,    1
  
      add     ax,    di

      mov     rdx,    qword[board]
      add     dx,    ax

      mov     al,    byte[rdx]

      cmp     al,    -1
      je      canOnlyMoveSideWays

      jmp     sideWaysMovementValidationPassed

    movingSideWaysWithStrongholdUp:
      ; SI ESTA EN LA PRIMERA FILA NO HAY NADA ARRIBA. POR LO TANTO NO SE PUEDE MOVER HACIA LOS COSTADOS
      mov     ax,    word[rsi]
      cmp     ax,    1
      je      cannotMoveSideways

      ; SI NO ESTA EN LA PRIMERA FILA, SE VALIDA SI HAY UN -1 EN LA CELDA DE ARRIBA, EN CASO DE QUE SEA ASI PUEDE MOVER HACIA LOS COSTADOS, SINO NO
      mov     ax,    word[rsi]
      sub     ax,    1
      imul    ax,    7
      
      mov     di,    word[rsi + 2]
      sub     di,    1
      
      add     ax,    di
      
      mov     rdx,    qword[board]
      add     dx,    ax
      mov     al,    byte[rdx]

      cmp     al,    -1
      je      sideWaysMovementValidationPassed

      jmp     cannotMoveSideways


  validateNotMovingSidewaysWithStrongholdRight:
    ; SE VERIFICA SI ESTA INTENTANDO MOVERSE A LOS COSTADOS
    mov     ax,    word[rsi + 2]
    sub     ax,    word[rsi + 6]

    cmp     ax,    0
    je      movingSideWaysWithStrongholdRight

    notMovingSideWaysWithStrongholdRight:
      ; SI NO SE ESTA MOVIENDO HACIA LOS COSTADOS SE VERIFICA QUE A LA DERECHA NO HAYA UN -1
      ; YA QUE DESDE ESA POSICION SOLO SE PUEDE MOVER HACIA LOS COSTADOS
      mov     ax,    word[rsi]
      imul    ax,    7
      
      mov     di,    word[rsi + 2]
      add     di,    1
      
      add     ax,    di
      
      mov     rdx,    qword[board]
      add     dx,    ax
  
      mov     al,    byte[rdx]
      
      cmp     al,    -1
      je      canOnlyMoveSideWays

      jmp     sideWaysMovementValidationPassed

    movingSideWaysWithStrongholdRight:
      ; SI ESTA EN LA ULTIMA COLUMNA NO HAY NADA A LA DERECHA. POR LO TANTO NO SE PUEDE MOVER HACIA LOS COSTADOS
      mov     ax,    word[rsi + 2]
      cmp     ax,    8
      je      cannotMoveSideways

      ; SI NO ESTA EN LA ULTIMA COLUMNA, SE VALIDA SI HAY UN -1 EN LA CELDA DE LA DERECHA, EN CASO DE QUE SEA ASI PUEDE MOVER HACIA LOS COSTADOS, SINO NO
      mov     ax,    word[rsi]
      imul    ax,    7
      
      mov     di,    word[rsi + 2]
      add     di,    1
  
      add     ax,    di
      
      mov     rdx,    qword[board]
      add     dx,    ax

      mov     al,    byte[rdx]

      cmp     al,    -1
      je      sideWaysMovementValidationPassed

      jmp     cannotMoveSideways

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
; SI EL MOVIMIENTO ES HACIA LOS "COSTADOS" VERIFICA QUE SE MUEVA HACIA EL CENTRO DEL TABLERO
; SI EL MOVIMIENTO ES EN DIRECCION DE LA FORTALEZA, VERIFICA QUE EL SENTIDO SEA CORRECTO

validateGettingCloserToStronghold:
  xor     rax,    rax
  cmp     byte[strongholdDir],    0
  je      validateGettingCloserToStrongholdUp
  cmp     byte[strongholdDir],    1
  je      validateGettingCloserToStrongholdRight
  cmp     byte[strongholdDir],    2
  je      validateGettingCloserToStrongholdDown
  cmp     byte[strongholdDir],    3
  je      validateGettingCloserToStrongholdLeft
  jmp     notGettingCloserToStronghold

  validateGettingCloserToStrongholdDown:
    ; SI LA FILA DE INICIO Y FINAL SON IGUALES SE ESTA MOVIENDO A "LOS COSTADOS"
    mov     ax,    word[rsi]
    cmp     ax,    word[rsi + 4]
    je      validateGettingCloserToStrongholdDownSideWays

    ; EN EL CASO CONTRARIO, VERIFICAR QUE LA FILA DESTINO ES MAYOR A LA FILA DE INICIO (SE ESTA ACERCANDO A LA FORTALEZA)
    mov     ax,    word[rsi]
    sub     ax,    word[rsi + 4]

    cmp     ax,    0
    jge     notGettingCloserToStronghold

    mov     rax,    1   ; PASO LA VALIDACION
    ret
    validateGettingCloserToStrongholdDownSideWays:
      mov   word[distance],    0
      ; SE CALCULA LA DISTANCIA ENTRE LA COLUMNA DE INICIO Y EL CENTRO
      mov   ax,    word[rsi + 2]    
      sub   ax,    4

      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8

      mov   word[distance],    ax
      ; SE CALCULA LA DISTANCIA ENTRE LA COLUMNA DE DESTINO Y EL CENTRO
      mov   ax,    word[rsi + 6]
      sub   ax,    4
      
      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8
      
      cmp   ax,    word[distance]
      jge   notGettingCloserToStronghold

      mov   rax,    1      ; PASO LA VALIDACION
      ret


  validateGettingCloserToStrongholdLeft:
    ; SI LA COLUMNA DE INICIO Y FINAL SON IGUALES SE ESTA MOVIENDO A "LOS COSTADOS"
    mov     ax,    word[rsi + 2]
    cmp     ax,    word[rsi + 6]
    je      validateGettingCloserToStrongholdLeftSideWays

    ; EN EL CASO CONTRARIO, VERIFICAR QUE LA COLUMNA DESTINO ES MENOR A LA COLUMNA DE INICIO (SE ESTA ACERCANDO A LA FORTALEZA)
    mov     ax,    word[rsi + 2]
    sub     ax,    word[rsi + 6]

    cmp     ax,    0
    jle     notGettingCloserToStronghold

    mov     rax,    1   ; PASO LA VALIDACION
    ret
    validateGettingCloserToStrongholdLeftSideWays:
      mov   word[distance],    0
      ; SE CALCULA LA DISTANCIA ENTRE LA FILA DE INICIO Y EL CENTRO
      mov   ax,    word[rsi]
      sub   ax,    4
      
      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8
    
      mov   word[distance],    ax
      ; SE CALCULA LA DISTANCIA ENTRE LA FILA DE DESTINO Y EL CENTRO
      mov   ax,    word[rsi + 4]
      sub   ax,    4
      
      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8
    
      cmp   ax,    word[distance]
      jge   notGettingCloserToStronghold
      
      mov   rax,    1      ; PASO LA VALIDACION
      ret


  validateGettingCloserToStrongholdUp:
    ; SI LA FILA DE INICIO Y FINAL SON IGUALES SE ESTA MOVIENDO A "LOS COSTADOS"
    mov     ax,    word[rsi]
    cmp     ax,    word[rsi + 4]
    je      validateGettingCloserToStrongholdUpSideWays

    ; EN EL CASO CONTRARIO, VERIFICAR QUE LA FILA DESTINO ES MENOR A LA FILA DE INICIO (SE ESTA ACERCANDO A LA FORTALEZA)
    mov     ax,    word[rsi]
    sub     ax,    word[rsi + 4]

    cmp     ax,    0
    jle     notGettingCloserToStronghold

    mov     rax,    1   ; PASO LA VALIDACION
    ret
    validateGettingCloserToStrongholdUpSideWays:
      mov   word[distance],    0
      ; SE CALCULA LA DISTANCIA ENTRE LA COLUMNA DE INICIO Y EL CENTRO
      mov   ax,    word[rsi + 2]
      sub   ax,    4
      
      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8
    
      mov   word[distance],    ax
      ; SE CALCULA LA DISTANCIA ENTRE LA COLUMNA DE DESTINO Y EL CENTRO
      mov   ax,    word[rsi + 6]
      sub   ax,    4
      
      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8
    
      cmp   ax,    word[distance]
      jge   notGettingCloserToStronghold
      
      mov   rax,    1      ; PASO LA VALIDACION
      ret

  validateGettingCloserToStrongholdRight:
    ; SI LA COLUMNA DE INICIO Y FINAL SON IGUALES SE ESTA MOVIENDO A "LOS COSTADOS"
    mov     ax,    word[rsi + 2]
    cmp     ax,    word[rsi + 6]
    je      validateGettingCloserToStrongholdRightSideWays

    ; EN EL CASO CONTRARIO, VERIFICAR QUE LA COLUMNA DESTINO ES MAYOR A LA COLUMNA DE INICIO (SE ESTA ACERCANDO A LA FORTALEZA)
    mov     ax,    word[rsi + 2]
    sub     ax,    word[rsi + 6]

    cmp     ax,    0
    jge     notGettingCloserToStronghold

    mov     rax,    1   ; PASO LA VALIDACION
    ret
    validateGettingCloserToStrongholdRightSideWays:
      mov   word[distance],    0
      ; SE CALCULA LA DISTANCIA ENTRE LA FILA DE INICIO Y EL CENTRO
      mov   ax,    word[rsi]
      sub   ax,    4
    
      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8
  
      mov   word[distance],    ax
      ; SE CALCULA LA DISTANCIA ENTRE LA FILA DE DESTINO Y EL CENTRO
      mov   ax,    word[rsi + 4]
      sub   ax,    4

      sub   rsp,  8
      call  calculateModuleOfAx
      add   rsp,  8

      cmp   ax,    word[distance]
      jge   notGettingCloserToStronghold
  
      mov   rax,    1      ; PASO LA VALIDACION
      ret

  notGettingCloserToStronghold:
    mov     qword[errorMsg],    canOnlyMoveTowardsStrongholdMsg
    mov     rax,    0
    ret

calculateModuleOfAx:
  cmp     ax,    0
  jl      negative
  ret
  negative:
    neg     ax
    ret
