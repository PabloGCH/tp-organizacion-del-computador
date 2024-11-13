%include "macros.asm"

section .data
  rotationPrompt  db  "Ingrese la rotacion (U, D, L, R): ", 0
  rotationFormat  db  "%c", 0

section .bss
  rotationChar    resb  1

section .text
  global readRotationInput
  extern read

readRotationInput:
  ; Leemos el caracter de rotacion
  read rotationPrompt, rotationChar, rotationFormat, rotationChar

  ; Cargo el valor leido en el registro al
  mov al, byte[rotationChar]
  ret
