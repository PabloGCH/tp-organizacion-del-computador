global getUserPositionInput
extern gets



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
  inputText                    resb       60
  positions      times 4       resw       0   ; pieceRow, pieceColumn, destinationRow, destinationColumn




;PRE-COND: LA SUBRUTINA NO TIENE PARAMETROS DE ENTRADA
;POST-COND: LA SUBRUTINA DEVUELVE UNA DIRECCION DE MEMORIA DE UN ARRAY DE 4 ELEMENTOS
;           QUE CONTIENE LA FILA Y COLUMNA DE LA PIEZA Y LA FILA Y COLUMNA DE DESTINO          
;           EN ESE ORDEN. CADA ELEMENTO ES UN WORD (2 BYTES)
;PROBAR CON COMANDO "p/d *((short *) $rax)@4" desde gdb
section .text
  getUserPositionInput:
    
    getPiecePosition:
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
      ; Si no es valido deberia de repetir "receivePiecePosition"
    getDestination:
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
      ; Si no es valido deberia de repetir "receiveDestination"
    saveResults:
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
    







