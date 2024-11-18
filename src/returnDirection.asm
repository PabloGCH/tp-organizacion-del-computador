section .data


section .bss
    origin times 2 resb 1      ; Array de 2 elementos de 1b
    destination times 2 resb 1 ; Idem

section .text
    global returnDirection

    returnDirection:
        ; (dil;sil) = (x) columnaInicio ; (y) filaInicio
        ; (dh;dl) = (x) columnaDestino ; (y) filaDestino

        mov byte[origin]  , dil 
        mov byte[origin+1], sil

        sub byte[origin], dh ; columnaInicio - columnaDestino
        sub byte[origin+1], dl ; filaInicio - filaDestino

        cmp byte[origin], 0
        je colDifferenceZero
        jl colDifferenceNegative
        jg colDifferencePositive

        ; Las etiquetas de movimiento usan horarios del reloj
        colDifferenceZero:

            cmp byte[origin+1],0    ; Diferencia entre filas
            je movementNull
            jl movementDown
            jg movementUp
        
            movementUp:
                mov rax,1
                jmp end
            movementDown:
                mov rax, 5
                jmp end
            movementNull:
                mov rax, 0
                jmp end 
        
        colDifferenceNegative:

            cmp byte[origin+1], 0
            je movementRight
            jg movementUpRight
            jl movementDownRight

            movementRight:    
                mov rax, 3
                jmp end
            movementUpRight:
                mov rax, 2
                jmp end
            movementDownRight:
                mov rax, 4
                jmp end

        colDifferencePositive:

            cmp byte[origin+1], 0
            je movementLeft
            jg movementUpLeft
            jl movementDownLeft

            movementLeft:
                mov rax, 7
                jmp end
            movementUpLeft:
                mov rax, 8
                jmp end
            movementDownLeft:
                mov rax, 6
                jmp end
        
    end:
        ret
