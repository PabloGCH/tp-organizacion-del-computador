%include "macros.asm"

section .data
  rotationPrompt  db  10, \
                      "Posiciones posibles para la fortaleza", 10, \
                      "[1] - Abajo", 10, \
                      "[2] - Arriba", 10, \
                      "[3] - Izquierda", 10, \
                      "[4] - Derecha", 10, \
                      "[0] - Cancelar", 10, \
                      10, \
                      "Ingrese el numero de la opcion elegida: ", 0

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
