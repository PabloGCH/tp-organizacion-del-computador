%macro command 1
  mov rdi, cmd_clear
  sub rsp, 8
  call system
  add rsp, 8
%endmacro

;Recibe un string y lo imprime
%macro print 1
  mov     rdi,    %1
  sub     rsp,    8
  call    printf
  add     rsp,    8
%endmacro

;Recibe un string y un argumento
%macro printArg 2
  mov     rdi,    %1
  mov     rsi,    [%2]
  sub     rsp,    8
  call    printf
  add     rsp,    8
%endmacro

;Recibe:
;     un string que se imprime para pedir un valor
;     un buffer donde se guarda el valor
;     un formato para sscanf
;     un puntero a la variable donde se guarda el valor
%macro read 4
  print %1

  mov     rdi,    %2

  sub     rsp,    8
  call    gets
  add     rsp,    8

  mov     rdi,    %2
  mov     rsi,    %3
  mov     rdx,    %4

  sub     rsp,    8
  call    sscanf
  add     rsp,    8

%endmacro

%macro resetVector 1
    mov rdi, %1
    mov byte[rdi], -1
    mov byte[rdi+1], -1
    mov byte[rdi+2], -1
    mov byte[rdi+3], -1
%endmacro

extern  printf
extern  gets
extern  sscanf

extern system
