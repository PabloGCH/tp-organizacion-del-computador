global getUserPositionInput
extern gets
extern validateInput
extern validatePieceInput
%include "macros.asm"

section .data
  msgPiecePosition             db     "Ingrese la fila y columna de la pieza (Separado por espacios): ", 0
  msgDestination               db     "Ingrese la fila y columna de destino (Separado por espacios): ", 0
  mgsInvalidPosition           db     "Posicion invalida, intente de nuevo", 10, 0
  formatInput                  db     "%d %d", 0

  pieceRow                     dw     0
  pieceColumn                  dw     0
  destinationRow               dw     0
  destinationColumn            dw     0


section .bss
  inputText                    resb       100
  position       times 2       resw       1   ; row, column
  positions      times 4       resw       1   ; pieceRow, pieceColumn, destinationRow, destinationColumn
  playerType                   resb       1
  board                        resq       1




section .text
  ;PRE-COND:  LA SUBRUTINA RECIBE
  ;           EN RDI LA DIRECCIÓN DE MEMORIA DE LA MATRIZ DEL TABLERO
  ;           EN RSI UN NUMERO QUE INDICA TIPO DE JUGADOR           
              
  ;POST-COND: LA SUBRUTINA DEVUELVE UNA DIRECCION DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS
  ;           QUE CONTIENE LA FILA Y COLUMNA DE LA PIEZA Y LA FILA Y COLUMNA DE DESTINO          
  ;           EN ESE ORDEN. CADA ELEMENTO ES UN WORD (2 BYTES)
  ;TESTEAR:   PROBAR CON EL COMANDO "p/d *((short *) $rax)@4" DESDE GDB ANTES DE QUE TERMINE EL PROGRAMA
  ;           DEBERIA MOSTRAR LOS VALORES INGRESADOS POR EL USUARIO
  getUserPositionInput:
    mov    qword[board],    rdi
    mov    byte[playerType], sil
    
    
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


        mov     rdi,    qword[board]
        mov     rsi,    position
        mov     rdx,    qword[playerType]

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

    







