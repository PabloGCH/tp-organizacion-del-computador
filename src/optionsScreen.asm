%include "macros.asm"

section .data
  optionPrompt  db    "Elegir aspecto a configurar", 10, 10, \
                      "[1] - Orientacion del tablero", 10, \
                      "[2] - Caracteres de piezas", 10, \
                      "[3] - Primer turno", 10, 10, \
                      "[0] - Volver", 10, \
                      10, \
                      "Ingrese el numero de la opcion elegida: ", 0

  optionFormat  db  "%c", 0

section .bss
  optionChar    resb  1

section .text
  global optionsScreen
  extern read

optionsScreen:
  ; Leemos el caracter de opcion
  read optionPrompt, optionChar, optionFormat, optionChar

  ; Cargo el valor leido en el registro al
  mov al, byte[optionChar]

  ; Valido caracteres
  cmp al, '0'
  jl invalidInput
  cmp al, '3'
  jg invalidInput

  ; Guardo la opcion seleccionada en rax
  cmp al, '0'
  je backOption
  cmp al, '1'
  je rotationOption
  cmp al, '2'
  je characterOption
  cmp al, '3'
  je shiftOption

invalidInput:
  mov rax, -1
  ret

backOption:
  mov rax, 0
  ret

rotationOption:
  mov rax, 1
  ret

characterOption:
  mov rax, 2
  ret

shiftOption:
  mov rax, 3
  ret
