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
extern printQuitMessage
extern printSaveMessage
extern loadGame
extern startScreen
extern configureCharacters
extern configureFirstShift

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

