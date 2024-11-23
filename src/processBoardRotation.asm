section .data
  invalidCharError  db  "Error: Invalid rotation char", 0
  allowedChars      db  "UDLR", 0

  ; Definicion de matrices de rotacion para copia posterior
  matrixUp  db    -1, -1,  0,  0,  2, -1, -1, \
                  -1, -1,  3,  0,  0, -1, -1, \
                   1,  1,  0,  0,  0,  1,  1, \
                   1,  1,  1,  1,  1,  1,  1, \
                   1,  1,  1,  1,  1,  1,  1, \
                  -1, -1,  1,  1,  1, -1, -1, \
                  -1, -1,  1,  1,  1, -1, -1

  matrixDown  db  -1, -1,  1,  1,  1, -1, -1, \
                  -1, -1,  1,  1,  1, -1, -1, \
                   1,  1,  1,  1,  1,  1,  1, \
                   1,  1,  1,  1,  1,  1,  1, \
                   1,  1,  0,  0,  0,  1,  1, \
                  -1, -1,  0,  0,  3, -1, -1, \
                  -1, -1,  2,  0,  0, -1, -1

  matrixLeft  db  -1, -1,  1,  1,  1, -1, -1, \
                  -1, -1,  1,  1,  1, -1, -1, \
                   2,  0,  0,  1,  1,  1,  1, \
                   0,  0,  0,  1,  1,  1,  1, \
                   0,  3,  0,  1,  1,  1,  1, \
                  -1, -1,  1,  1,  1, -1, -1, \
                  -1, -1,  1,  1,  1, -1, -1

  matrixRight  db  -1, -1,  1,  1,  1, -1, -1, \
                   -1, -1,  1,  1,  1, -1, -1, \
                    1,  1,  1,  1,  0,  3,  0, \
                    1,  1,  1,  1,  0,  0,  0, \
                    1,  1,  1,  1,  0,  0,  2, \
                   -1, -1,  1,  1,  1, -1, -1, \
                   -1, -1,  2,  1,  1, -1, -1

section .bss
  boardMatrix resq 1

section .text
  global processBoardRotation

; ========== Funcion principal ========== ;

processBoardRotation:
  ; Guardo la base de la pila para volver luego y tomo como base el tope actual
  push rbp
  mov rbp, rsp

  ; Guardo los registros que voy a usar para validacion
  push rbx
  push rcx

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
  jmp copyMatrix

rotationDown:
  lea rsi, [matrixDown]     ; Cargar direccion de matrixDown
  jmp copyMatrix

rotationLeft:
  lea rsi, [matrixLeft]     ; Cargar direccion de matrixLeft
  jmp copyMatrix

rotationRight:
  lea rsi, [matrixRight]    ; Cargar direccion de matrixRight
  jmp copyMatrix

copyMatrix:
  mov rcx, 49
  rep movsb
  jmp cleanup
