global main
%include "macros.asm"

;TEST VALIDACION DE POSICION EXISTENTE Y CELDA NO OCUPADA
extern getUserPositionInput
extern printBoard
extern printCurrentTurn

section .data
  board         db      -1, -1,  1,  1,  1, -1, -1, \
                        -1, -1,  0,  0,  1, -1, -1, \
                         1,  1,  0,  0,  1,  1,  1, \
                         0,  1,  1,  0,  1,  1,  1, \
                         0,  1,  0,  0,  0,  1,  1, \
                        -1, -1,  0,  0,  3, -1, -1, \
                        -1, -1,  2,  0,  0, -1, -1

  stronghold            db       2,  4,  4,  6
  strongholdDir         db       2                  ; 0 = Up, 1 = Right, 2 = Down, 3 = Left

  characters            db      'XO ', 0

section .text
  main:

    mov rdi, 0
    sub rsp, 8
    call printCurrentTurn
    add rsp, 8

    mov rdi, board
    mov esi, [stronghold]
    mov edx, [characters]

    sub rsp, 8
    call printBoard
    add rsp, 8

    mov rdi, board
    mov rsi, 0
    mov dl, byte[strongholdDir]

    sub     rsp,    8
    call getUserPositionInput
    add     rsp,    8


    mov rdi, board
    mov rsi, 1
    mov dl, byte[strongholdDir]

    sub     rsp,    8
    call getUserPositionInput
    add     rsp,    8


;TEST DE PRINT STATS
;=================
;%include "printStats.asm"
;section .data
;  t1 db 10,20,30,40,50,60,70,80, 35
;  t2 db 0,1,2,3,4,5,6,7, 20
;
;section .text
;
;main:
;    mov rdi, [t1]
;    mov sil, [t1+8]
;
;    mov rdx, [t2]
;    mov cl, [t2+8]
;    call printStats

;TEST DE PRINT BOARD
;=================
; extern printBoard
; section .data
;   boardTest db  -1,  -1,   1,  1,  1,  -1,   -1, \
;             -1,  -1,   1,  1,  1,  -1,   -1, \
;              1,   1,   1,  1,  1,   1,    1, \
;              1,   1,   1,  1,  1,   1,    1, \
;              1,   1,   0,  0,  0,   1,    1, \
;             -1,  -1,   0,  0,  3,  -1,   -1, \
;             -1,  -1,   2,  0,  0,  -1,   -1,
;   stronghold db 2,4,4,6
;   characters db 'X0',0
; section .text
;   main:

;     lea rdi, [boardTest]
;     mov esi, [stronghold]
;     mov edx, [characters]
;     sub rsp, 8
;     call printBoard
;     add rsp, 8

;TEST DE GET INPUT
;=================
;%include "getUserPositionInput.asm"


;section .text
    ;main:
    ;    sub     rsp,    8
    ;    call    getUserPositionInput
    ;    add     rsp,    8
;    ret

;TEST DE BOARD ROTATION
;=================

;extern readRotationInput
;extern processRotation
;
;section .bss
;  boardMatrix resb  144 ; Matriz de 12x12
;
;section .text
;main:
;  ; Pide un valor para la rotacion del tablero y la guarda en el registro al
;  call readRotationInput
;  
;  ; Procesa la rotacion y guarda el resultado (la matriz con orientacion correcta) en boardMatrix
;  ; Si la entrada no es valida, devuelve un mensaje de error en rax y guarda un cero en boardMatrix
;  call processRotation
;  cmp rax, 0
;  je invalidRotationChar
;
;  ; Continuar si la rotacion es valida
;  ; TODO: Pensar como sigue
;
;invalidRotationChar:
;  ; Imprimir mensaje de error y volver a pedir caracter
;  print rax
;  jmp main

; TEST DE RETURN DIRECTION
;=================

;%include "returnDirection.asm"
;
;section .data
;  msg db "The direction is: %li.", 10, 0
;
;section .bss
;  printNum resb 1
;
;main:
;    mov dil, 1
;    mov sil, 1
;
;    mov dh, 2
;    mov dl, 1
;
;    call returnDirection
;    mov byte[printNum], al
;    printArg msg, printNum
;  ret



