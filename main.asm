
global main
extern readRotationInput
extern processRotation

%include "macros.asm"

section .bss
  boardMatrix resb  144 ; Matriz de 12x12

section .text
main:
  ; Pide un valor para la rotacion del tablero y la guarda en el registro al
  call readRotationInput
  
  ; Procesa la rotacion y guarda el resultado (la matriz con orientacion correcta) en boardMatrix
  ; Si la entrada no es valida, devuelve un mensaje de error en rax y guarda un cero en boardMatrix
  call processRotation
  cmp rax, 0
  je invalidRotationChar

  ; Continuar si la rotacion es valida
  ; TODO: Pensar como sigue

invalidRotationChar:
  ; Imprimir mensaje de error y volver a pedir caracter
  print rax
  jmp main
