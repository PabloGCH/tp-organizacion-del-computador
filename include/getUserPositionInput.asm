global receiveUserPositionInputs
extern gets

section .data
  msgPiecePosition             db     "Ingrese la fila y columna de la pieza (Separado por espacios): ", 0
  msgDestination               db     "Ingrese la fila y columna de destino (Separado por espacios): ", 0
  mgsInvalidPosition           db     "Posicion invalida, intente de nuevo", 10, 0
  formatInput                  db     "%d %d", 0
  positions                    dq     0,0,0,0   ; pieceRow, pieceColumn, destinationRow, destinationColumn

  pieceRow                     dq     0
  pieceColumn                  dq     0
  destinationRow               dq     0
  destinationColumn            dq     0


section .bss
  inputText                    resb   60

section .text
  receiveUserPosition:
    
    receivePiecePosition:
      print msgPiecePosition

      mov     rdi,    inputText

      sub     rsp,    8
      call    gets
      add     rsp,    8

      mov     rdi,    inputText
      mov     rsi,    formatInput

      mov     rdx,    pieceRow
      mov     rsi,    pieceColumn

      sub     rsp,    8
      call    sscanf
      add     rsp,    8
      ; Si no es valido deberia de repetir "receivePiecePosition"
    receiveDestination:
      print msgDestination

      mov     rdi,    inputText
      
      sub     rsp,    8
      call    gets
      add     rsp,    8
    
      mov     rdi,    inputText
      mov     rsi,    formatInput

      mov     rdx,    destinationRow
      mov     rsi,    destinationColumn

      sub     rsp,    8
      call    sscanf
      add     rsp,    8
      ; Si no es valido deberia de repetir "receiveDestination"

    saveResults:
      mov     [positions],        pieceRow
      mov     [positions + 2],    pieceColumn
      mov     [positions + 4],    destinationRow
      mov     [positions + 6],    destinationColumn
    ret
    







