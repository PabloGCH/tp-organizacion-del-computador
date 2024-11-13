global main
%include "macros.asm"

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

section .data
  msg db "Hello, World!", 10, 0

section .text
  print msg





