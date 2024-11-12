section .data
  invalidCharError  db  "Error: Invalid rotation char", 0
  allowedChars      db  "UDLR", 0

; Definicion de matrices de rotacion para copia posterior
matrixUp:
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
matrixDown:
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
matrixLeft:
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
matrixRight:
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

section .bss
  extern  boardMatrix   ; Agarramos el tablero declarado en main

section .text
  global processRotation

; ========== Funcion principal ========== ;

processRotation:
  ; Guardo la base de la pila para volver luego y tomo como base el tope actual
  push rbp
  mov rbp, rsp

  ; Guardo los registros que voy a usar para validacion
  push rbx, rcx

  ; Verificamos que el caracter enviado esta en mayusculas
  cmp al, 'A'
  jl invalidInput
  cmp al, 'Z'
  jg invalidInput

  ; Validar que el caracter sea uno permitido. Cargamos el nro de caracteres validos en rcx y la direccion de la 'tabla' en rbx
  mov rcx, 4
  lea rbx, [allowedChars]

checkCaracterLoop:
  ; Comparo el caracter ingresado uno por uno con los de la tabla
  cmp al, [rbx]
  je validInput
  inc rbx
  loop checkCaracterLoop

  ; Si se termina el ciclo entonces el caracter no es valido
  jmp invalidInput

validInput:
  ; Comparar el caracter de rotacion guardado en al con los casos validos
  cmp al, 'U'
  je rotationUp

  cmp al, 'D'
  je rotationDown

  cmp al, 'L'
  je rotationLeft

  cmp al, 'R'
  je rotationRight

invalidInput:
  ; Si el valor no es válido, guarda un 0 en la matriz y un mensaje de error en el rax
  mov rax, invalidCharError
  mov qword[boardMatrix], 0

cleanup:
  ; Restaurar los registros
  pop rcx
  pop rbx

  mov rsp, rbp
  pop rbp
  ret

; ========== Rotaciones ========== ;

rotationUp:
  lea rsi, [matrixUp]       ; Cargar direccion de matrixUp
  lea rdi, [boardMatrix]    ; Cargar direccion de matriz destino
  mov rcx, 144              ; 12x12
  rep movsb                 ; Copiamos los 144 bytes de la origen a la destino
  jmp cleanup

rotationDown:
  lea rsi, [matrixDown]       ; Cargar direccion de matrixDown
  lea rdi, [boardMatrix]      ; Cargar direccion de matriz destino
  mov rcx, 144                ; 12x12
  rep movsb                   ; Copiamos los 144 bytes de la origen a la destino
  jmp cleanup

rotationLeft:
  lea rsi, [matrixLeft]       ; Cargar direccion de matrixLeft
  lea rdi, [boardMatrix]      ; Cargar direccion de matriz destino
  mov rcx, 144                ; 12x12
  rep movsb                   ; Copiamos los 144 bytes de la origen a la destino
  jmp cleanup

rotationRight:
  lea rsi, [matrixRight]      ; Cargar direccion de matrixRight
  lea rdi, [boardMatrix]      ; Cargar direccion de matriz destino
  mov rcx, 144                ; 12x12
  rep movsb                   ; Copiamos los 144 bytes de la origen a la destino
  jmp cleanup
