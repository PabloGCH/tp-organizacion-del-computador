global getUserPositionInput
extern gets
extern validateInput
extern validatePieceInput
extern validateDestinationInput
extern saveGame
extern fopen

extern strcmp
extern quit

%include "macros.asm"

section .data
  msgPiecePosition             db     "Ingrese la fila y columna de la pieza (Separado por espacios): ", 0
  msgDestination               db     "Ingrese la fila y columna de destino (Separado por espacios): ", 0
  msgInvalidPosition           db     "Posicion invalida, intente de nuevo", 10, 0
  formatInput                  db     "%d %d", 0
  quitStr                      db     "Quit", 0
  quitLowerStr                 db     "quit", 0
  saveStr                      db     "Save", 0
  saveLowerStr                 db     "save", 0

  pieceRow                     dw     0
  pieceColumn                  dw     0
  destinationRow               dw     0
  destinationColumn            dw     0

  messageSaveGame              db 'Ingrese el nombre del archivo de guardado: ', 0
  messageSaveError             db 'Ese nombre de archivo no es valido, intenta otro.', 10, 0

  modeWrite db 'w', 0


section .bss
  inputText                    resb       100
  position       times 2       resw       1   ; row, column
  positions      times 4       resw       1   ; pieceRow, pieceColumn, destinationRow, destinationColumn

  mainSavePath resb 128

  ; Pointers
  pointerBoard             resq 1  ; Tablero
  pointerScore             resq 1  ; Stats
  pointerStrongholdL       resq 1  ; Ubicacion Fortaleza
  pointerStrongholdD       resq 1  ; Direccion Fortaleza
  pointerCurrentTurn       resq 1  ; Turno Actual
  pointerCharacters        resq 1  ; Caracter Soldado/Oficial

  ; Data

  dataCurrentTurn          resb 1

section .text
  ;PRE-COND:  LA SUBRUTINA RECIBE
  ;           EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO
  ;           EN RSI UN NUMERO QUE INDICA TIPO DE JUGADOR
  ;           EN RDX LA DIRECCION DE LA FORTALEZA

  ; Inputs (RDI -> R9 Punteros)
  ; RDI : Matriz       7  x 7
  ; RSI : Stats        18 x 1
  ; RDX : FortalezaLoc 4  x 1
  ; RCX : FortalezaDir 1  x 1
  ; R8  : Turno        1  x 1
  ; R9  : Caracteres   2  x 1

  ;POST-COND: LA SUBRUTINA DEVUELVE UNA DIRECCION DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS
  ;           QUE CONTIENE LA FILA Y COLUMNA DE LA PIEZA Y LA FILA Y COLUMNA DE DESTINO
  ;           EN ESE ORDEN. CADA ELEMENTO ES UN WORD (2 BYTES)
  ;TESTEAR:   PROBAR CON EL COMANDO "p/d *((short *) $rax)@4" DESDE GDB ANTES DE QUE TERMINE EL PROGRAMA
  ;           DEBERIA MOSTRAR LOS VALORES INGRESADOS POR EL USUARIO
  getUserPositionInput:
    mov    qword[pointerBoard], rdi
    mov    qword[pointerScore], rsi
    mov    qword[pointerStrongholdL], rdx
    mov    qword[pointerStrongholdD], rcx
    mov    qword[pointerCurrentTurn], r8
    mov    qword[pointerCharacters], r9

    mov rdi, dataCurrentTurn
    mov rsi, [pointerCurrentTurn]
    movsb ; [pointer] -> data

    getPiecePosition:
      ; SE INICIALIZAN LA POSICION CON UN VALOR INVALIDO PARA QUE NO USE VALORES VIEJOS
      ; EN FUTURAS INVOCACIONES DE LA SUBRUTINA
      initPiecePosition:
        mov     word[pieceRow],             0
        mov     word[pieceColumn],          0
      print msgPiecePosition

      mov     rdi,    inputText

      sub     rsp,    8
      call    gets
      add     rsp,    8

      mov     rdi,    inputText
      sub     rsp,    8
      call    validateQuit
      add     rsp,    8

      mov     rdi, inputText 
      sub     rsp, 8
      call    validateSave
      add     rsp, 8

      mov     rdi,    inputText
      mov     rsi,    formatInput

      mov     rdx,    pieceRow
      mov     rcx,    pieceColumn

      sub     rsp,    8
      call    sscanf
      add     rsp,    8

      ; SI EL INPUT NO ES VALIDO, SE REPITE LA SOLICITUD
      validatePiecePosition:
        mov     ax,  word[pieceRow]
        mov     word[position],         ax
        mov     ax,  word[pieceColumn]
        mov     word[position + 2],     ax

        mov     rdi,    position

        sub     rsp,    8
        call    validateInput
        add     rsp,    8

        cmp     rax,    0
        je      getPiecePosition


        mov     rdi,    qword[pointerBoard]
        mov     rsi,    position
        mov     rdx,    qword[dataCurrentTurn]

        sub     rsp,    8
        call    validatePieceInput
        add     rsp,    8

        cmp     rax,    0
        je      getPiecePosition

    getDestination:
      ; SE INICIALIZAN LA POSICION CON UN VALOR INVALIDO PARA QUE NO USE VALORES VIEJOS
      ; EN FUTURAS INVOCACIONES DE LA SUBRUTINA
      initDestinationPosition:
        mov     word[destinationRow],       0
        mov     word[destinationColumn],    0
      print msgDestination

      mov     rdi,    inputText

      sub     rsp,    8
      call    gets
      add     rsp,    8

      mov     rdi,    inputText
      sub     rsp,    8
      call    validateQuit
      add     rsp,    8

      mov     rdi,    inputText
      mov     rsi,    formatInput

      mov     rdx,    destinationRow
      mov     rcx,    destinationColumn

      sub     rsp,    8
      call    sscanf
      add     rsp,    8


      ; SI EL INPUT NO ES VALIDO, SE REPITE LA SOLICITUD
      validateDestinationPosition:
        mov     ax,  word[destinationRow]
        mov     word[position],         ax
        mov     ax,  word[destinationColumn]
        mov     word[position + 2],     ax

        mov     rdi,    position

        sub     rsp,    8
        call    validateInput
        add     rsp,    8

        cmp     rax,    0
        je      getDestination

        mov     rdi,    qword[pointerBoard]
        mov     rsi,    position
        mov     rdx,    qword[dataCurrentTurn]

        sub     rsp,    8
        call    validateDestinationInput
        add     rsp,    8

        cmp     rax,    0
        je      getPiecePosition


    saveInputResults:
      mov     ax,    word[pieceRow]
      mov     word[positions],        ax
      mov     ax,    word[pieceColumn]
      mov     word[positions + 2],    ax
      mov     ax,    word[destinationRow]
      mov     word[positions + 4],    ax
      mov     ax,    word[destinationColumn]
      mov     word[positions + 6],    ax

    mov     rax,    positions
    ret

validateQuit:
    mov     rsi,    quitStr
    call    strcmp
    cmp     rax,    0
    jz      quitGame

    mov     rdi,    inputText
    mov     rsi,    quitLowerStr
    call    strcmp
    cmp     rax,    0
    jz      quitGame

    ret

  validateSave:
    mov rsi, saveStr
    call strcmp
    cmp rax, 0
    jz mainSaveGame

    mov rdi, inputText
    mov rsi, saveLowerStr
    call strcmp
    cmp rax, 0
    jz mainSaveGame

    ret

quitGame:
    sub    rsp,    8
    call   quit
    add    rsp,    8
    ret

mainSaveGame:

  mov rdi, messageSaveGame
  call printf

  mov rdi, mainSavePath
  call gets
      
  mov rdi, mainSavePath
  mov rsi, modeWrite
  call fopen
  cmp rax, 0
  je mainSaveError

  mov r10, rax

  mov rdi, [pointerBoard]
  mov rsi, [pointerScore]
  mov rdx, [pointerStrongholdL]
  mov rcx, [pointerStrongholdD]
  mov r8, [pointerCurrentTurn]
  mov r9, [pointerCharacters]

  call saveGame

  jmp getPiecePosition

  mainSaveError:

    mov rdi, messageSaveError
    call printf
    jmp mainSaveGame
