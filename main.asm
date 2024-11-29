global main
global nextShiftMessage

%include "macros.asm"

; FUNCIONES EXTERNAS
extern system
extern printf
extern fopen
extern gets
; SUBRUTINAS
extern checkGameStatus
extern getUserPositionInput
extern movementIsPossible
extern movePiece
extern printBoard
extern printCurrentShift
extern optionsScreen
extern statCounterGetPointer
extern statCounterPrint
extern readRotationInput
extern processBoardRotation
<<<<<<< HEAD
extern printQuitMessage
extern printSaveMessage
extern loadGame
extern startScreen
=======
extern configureCharacters
extern configureFirstShift
>>>>>>> 07e7d50 (Integrar opciones de config de caracteres y turnos al menu de opciones)

extern quit

section .data
  cmd_clear             db      "clear", 0

  board                 db  -1, -1,  1,  1,  1, -1, -1, \
                            -1, -1,  1,  1,  1, -1, -1, \
                             1,  1,  1,  1,  1,  1,  1, \
                             1,  1,  1,  1,  1,  1,  1, \
                             1,  1,  0,  0,  0,  1,  1, \
                            -1, -1,  0,  0,  3, -1, -1, \
                            -1, -1,  2,  0,  0, -1, -1

  stronghold            db  2, 4, 4, 6  ; Array de 4 valores (x1, x2, y1, y2)
  strongholdDir         db  2           ; Donde esta la stronghold (0: Up, 1: Right, 2: Down, 3: Left)

  characters            db      'XO ', 0
  currentShift                 db       0 ; 0 = Soldiers, 1 = Officers

  messageRotationError  db 'Esa orientacion es invalida. ', 0
  messageOptionsError   db 'Esa opcion es invalida.', 10, 0

  messageLoadGame       db 'Ingrese el nombre del archivo guardado: ', 0
  messageLoadError      db 'Ese archivo no existe. Volviendo al inicio.', 10, 0
  newLine               db 10, 0
  modeRead db 'r', 0

section .bss
  gameStatus    resb 1
  positions     resq 1

  mainLoadPath  resb 128
  nextShiftMessage resq 1

section .text
  main:
      command cmd_clear

      sub rsp, 8
      call startScreen
      add rsp, 8
      cmp rax, 1 
      je mainGameLoop
      cmp rax, 2
      je mainLoadGame
      cmp rax, 3
      je mainOptionsMenu
      jmp mainQuit ; Solo da valores entre 1 y 3, asi que por descarte...

    mainLoadGame:

      mov rdi, messageLoadGame
      sub rsp, 8
      call printf
      add rsp, 8
      mov rdi, mainLoadPath
      sub rsp, 8
      call gets
      add rsp, 8
      
      mov rdi, mainLoadPath
      mov rsi, modeRead
      sub rsp, 8
      call fopen
      add rsp, 8
      cmp rax, 0
      je mainLoadError

      mov r10, rax
      mov rdi, board
      sub rsp, 8
      call statCounterGetPointer
      add rsp, 8
      mov rsi, rax
      
      mov rdx, stronghold
      mov rcx, strongholdDir
      mov r8, currentShift
      mov r9, characters
      sub rsp, 8
      call loadGame
      add rsp, 8
      jmp mainGameLoop

      mainLoadError:
          mov rdi, messageLoadError
          sub rsp, 8
          call printf
          add rsp, 8
          jmp main


    mainQuit:

      sub    rsp,    8
      call   quit
      add    rsp,    8
      ret

    mainOptionsMenu:
      command cmd_clear

    mainOptionsMenuAfterClear:
      ; Permitir al usuario elegir una opcion de configuracion
      sub rsp, 8
      call optionsScreen
      add rsp, 8

      ; Menu de orientacion
      cmp rax, 1
      je optionsMenuRotation

      ; Menu de caracteres
      cmp rax, 2
      je optionsMenuCharacters

      ; Menu de turno
      cmp rax, 3
      je optionsMenuShift

      ; Mostrar mensaje de error si es necesario
      cmp rax, -1
      je optionsMenuInvalid

      ; Cancelar y volver al menu principal
      command cmd_clear
      jmp main

    optionsMenuInvalid:
      command cmd_clear
      mov rdi, messageOptionsError
      sub rsp, 8
      call printf
      add rsp, 8
      jmp mainOptionsMenuAfterClear

    optionsMenuRotation:
      ; ===== Orientacion del tablero ===== ;
      command cmd_clear

      ; Preguntar por orientacion del tablero
      sub rsp, 8
      call readRotationInput
      add rsp, 8

      ; Orientar tablero
      lea rdi, [board]
      lea rsi, [stronghold]
      lea rdx, [strongholdDir]
      sub rsp, 8
      call processBoardRotation
      add rsp, 8

      ; Verificar si el input era valido
      cmp rax, 0
      je mainOptionsMenu

      ; Verificar si es un Back
      cmp rax, 2
      je mainOptionsMenu

      ; Si no fue valido, mostrar mensaje de error y reintentar eleccion
      mov rdi, messageRotationError
      sub rsp, 8
      call printf
      add rsp, 8
      jmp optionsMenuRotation
      ; ============================== ;

    optionsMenuCharacters:
      ; ===== Caracteres de piezas ===== ;
      lea rdi, [characters]
      sub rsp, 8
      call configureCharacters
      add rsp, 8
      jmp mainOptionsMenu
      ; ============================== ;

    optionsMenuShift:
      ; ===== Primer turno ===== ;
      lea rdi, [currentShift]
      sub rsp, 8
      call configureFirstShift
      add rsp, 8
      jmp mainOptionsMenu
      ; ============================== ;

    mainGameLoop:

      command cmd_clear

      sub rsp, 8
      call printSaveMessage
      add rsp, 8
      sub rsp, 8
      call printQuitMessage
      add rsp, 8

      mov rdi, [currentShift]
      sub rsp, 8
      call printCurrentShift
      add rsp, 8

      mov rdi, board
      mov esi, [stronghold]
      mov edx, [characters]
      sub rsp, 8
      call printBoard
      add rsp, 8

      cmp qword [nextShiftMessage], 0
      je skipNextShiftMessage

      print newLine
      mov rdx, [nextShiftMessage]
      print rdx
      mov qword [nextShiftMessage], 0
skipNextShiftMessage:
      print newLine
      receiveInput:
      ; Inputs necesarios para llamar save desde getUserInputPosition
        sub rsp, 8
        call statCounterGetPointer
        add rsp, 8
        mov rsi, rax
        mov rdi, board
        mov rdx, stronghold
        mov rcx, strongholdDir
        mov r8, currentShift
        mov r9, characters

        sub     rsp,    8
        call    getUserPositionInput
        add     rsp,    8
        mov     qword[positions], rax

      validateIfMovementIsPossible:
        mov     rdi,    board
        mov     rsi,    qword[positions]
        mov     rdx,    qword[currentShift]
        mov     cl,     byte[strongholdDir]

        sub     rsp,    8
        call    movementIsPossible
        add     rsp,    8

        cmp     rax,    0
        je      receiveInput
        cmp     rax,    2
        je      checkIfGameContinues

      handleMovement:
        mov     rsi,        qword[positions]
        mov     rdi,        board
        mov     dl,         byte[strongholdDir]

        sub     rsp,        8
        call    movePiece
        add     rsp,        8

      checkIfGameContinues:
        mov rdi, board
        mov esi, [stronghold]
        sub rsp, 8
        call checkGameStatus
        add rsp, 8

        mov [gameStatus], al

        cmp byte [gameStatus], -1
        jne gameOver

        sub rsp, 8
        call setCurrentShift
        add rsp, 8

        jmp mainGameLoop
  gameOver:
    sub rsp, 8
    call statCounterPrint
    add rsp, 8
    ; TODO: Mensaje de victoria
    ret

setCurrentShift:
    mov al, [currentShift]
    xor al, 1
    mov [currentShift], al
    ret

;TEST DE PRINT STATS
;=================
;%include "printStats.asm"
;section .data
;  t1 db 10,20,30,40,50,60,70,80, 35
;  t2 db 0,1,2,3,4,5,6,7, 20
;
;section .text
;
;main:
;    mov rdi, [t1]
;    mov sil, [t1+8]
;
;    mov rdx, [t2]
;    mov cl, [t2+8]
;    call printStats

;TEST DE PRINT BOARD
;=================
; extern printBoard
; section .data
;   boardTest db  -1,  -1,   1,  1,  1,  -1,   -1, \
;             -1,  -1,   1,  1,  1,  -1,   -1, \
;              1,   1,   1,  1,  1,   1,    1, \
;              1,   1,   1,  1,  1,   1,    1, \
;              1,   1,   0,  0,  0,   1,    1, \
;             -1,  -1,   0,  0,  3,  -1,   -1, \
;             -1,  -1,   2,  0,  0,  -1,   -1,
;   stronghold db 2,4,4,6
;   characters db 'X0',0
; section .text
;   main:

;     lea rdi, [boardTest]
;     mov esi, [stronghold]
;     mov edx, [characters]
;     sub rsp, 8
;     call printBoard
;     add rsp, 8

;TEST DE GET INPUT
;=================
;%include "getUserPositionInput.asm"


;section .text
    ;main:
    ;    sub     rsp,    8
    ;    call    getUserPositionInput
    ;    add     rsp,    8
;    ret

;TEST DE BOARD ROTATION
;=================

;extern readRotationInput
;extern processRotation
;
;section .bss
;  boardMatrix resb  144 ; Matriz de 12x12
;
;section .text
;main:
;  ; Pide un valor para la rotacion del tablero y la guarda en el registro al
;  call readRotationInput
;  
;  ; Procesa la rotacion y guarda el resultado (la matriz con orientacion correcta) en boardMatrix
;  ; Si la entrada no es valida, devuelve un mensaje de error en rax y guarda un cero en boardMatrix
;  call processRotation
;  cmp rax, 0
;  je invalidRotationChar
;
;  ; Continuar si la rotacion es valida
;  ; TODO: Pensar como sigue
;
;invalidRotationChar:
;  ; Imprimir mensaje de error y volver a pedir caracter
;  print rax
;  jmp main

; TEST DE RETURN DIRECTION
;=================

;%include "returnDirection.asm"
;
;section .data
;  msg db "The direction is: %li.", 10, 0
;
;section .bss
;  printNum resb 1
;
;main:
;    mov dil, 1
;    mov sil, 1
;
;    mov dh, 2
;    mov dl, 1
;
;    call returnDirection
;    mov byte[printNum], al
;    printArg msg, printNum
;  ret



