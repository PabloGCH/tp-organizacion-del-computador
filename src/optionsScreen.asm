%include "macros.asm"

section .data
  optionPrompt  db  10, \
                      "Elegir aspecto a configurar", 10, \
                      "[1] - Orientacion del tablero", 10, \
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
  cmp al, '1'
  jg invalidInput

  ; Guardo la opcion seleccionada en rax
  cmp al, '0'
  je backOption
  cmp al, '1'
  je rotationOption

invalidInput:
  mov rax, -1
  ret

backOption:
  mov rax, 0
  ret

rotationOption:
  mov rax, 1
  ret
