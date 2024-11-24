section .data
  invalidCharError  db  "Error: Invalid rotation char", 0
  allowedChars      db  "12345", 0

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
                   -1, -1,  1,  1,  1, -1, -1

section .text
  global processBoardRotation

; ========== Funcion principal ========== ;

processBoardRotation:
  ; rdi = Direccion del tablero
  ; rsi = Direccion de stronghold (array de 4 valores)
  ; rdx = Direccion de strongholdDir (orientacion del tablero)

  ; Guardo la base de la pila para volver luego y tomo como base el tope actual
  push rbp
  mov rbp, rsp

  ; Guardo los registros que voy a usar para validacion
  push rbx
  push rcx

  ; Verificamos que el caracter enviado esta en el rango aceptable
  cmp al, '1'
  jl invalidInput
  cmp al, '5'
  jg invalidInput

  ; Validar que el caracter sea uno permitido. Cargamos el nro de caracteres validos en rcx y la direccion de la 'tabla' en rbx
  mov rcx, 5
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
  cmp al, '2'
  je rotationUp

  cmp al, '1'
  je rotationDown

  cmp al, '3'
  je rotationLeft

  cmp al, '4'
  je rotationRight

  cmp al, '5'
  je cancel

invalidInput:
  ; Si el valor no es válido, guarda un 0 en la matriz y un mensaje de error en el rax
  mov rax, 1
  xor rcx, rcx
  rep stosb
  jmp cleanup

cancel:
  ; Cancelar operacion
  mov rax, 2
  jmp cleanup

cleanup:
  ; Restaurar los registros
  pop rcx
  pop rbx

  mov rsp, rbp
  pop rbp
  ret

; ========== Rotaciones ========== ;

rotationUp:
  ; Cargar valores de stronghold
  mov byte[rsi], 2
  mov byte[rsi+1], 4
  mov byte[rsi+2], 0
  mov byte[rsi+3], 2

  ; Cargar ubicacion de stronghold
  mov byte[rdx], 0

  ; Copiar matriz de tablero
  lea rsi, [matrixUp]       ; Cargar direccion de matrixUp
  jmp copyMatrix

rotationDown:
  ; Cargar valores de stronghold
  mov byte[rsi], 2
  mov byte[rsi+1], 4
  mov byte[rsi+2], 4
  mov byte[rsi+3], 6

  ; Cargar ubicacion de stronghold
  mov byte[rdx], 2

  ; Copiar matriz de tablero
  lea rsi, [matrixDown]     ; Cargar direccion de matrixDown
  jmp copyMatrix

rotationLeft:
  ; Cargar valores de stronghold
  mov byte[rsi], 0
  mov byte[rsi+1], 2
  mov byte[rsi+2], 2
  mov byte[rsi+3], 4

  ; Cargar ubicacion de stronghold
  mov byte[rdx], 3

  ; Copiar matriz de tablero
  lea rsi, [matrixLeft]     ; Cargar direccion de matrixLeft
  jmp copyMatrix

rotationRight:
  ; Cargar valores de stronghold
  mov byte[rsi], 4
  mov byte[rsi+1], 6
  mov byte[rsi+2], 2
  mov byte[rsi+3], 4

  ; Cargar ubicacion de stronghold
  mov byte[rdx], 1

  ; Copiar matriz de tablero
  lea rsi, [matrixRight]    ; Cargar direccion de matrixRight
  jmp copyMatrix

copyMatrix:
  mov rcx, 49
  rep movsb
  mov rax, 0
  jmp cleanup
