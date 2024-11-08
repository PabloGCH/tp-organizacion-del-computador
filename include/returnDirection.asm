section .data


section .bss
    origin times 2 resb 1      ; Array de 2 elementos de 1b
    destination times 2 resb 1 ; Idem

section .text
    global returnDirection

    returnDirection:
        ; (dil;sil) = (x₀,y₀)
        ; (dh;dl) = (x₁,y₁)

        mov byte[origin]  , dil 
        mov byte[origin+1], sil

        sub byte[origin], dh ; x₀ - x₁
        sub byte[origin+1], dl ; y₀ - y₁

        cmp byte[origin],0
        je xAxisZero
        jl xAxisPositive
        jg xAxisNegative

    ; Las etiquetas de movimiento usan horarios del reloj
    xAxisZero:

        cmp byte[origin+1],0
        je movementNull
        jl movementUp
        jg movementDown
    
        movementUp:
            mov rax,1
            jmp end
        movementDown:
            mov rax, 5
            jmp end
        movementNull:
            mov rax, 0
            jmp end 
    
    xAxisPositive:

        cmp byte[origin+1],0
        je movementRight
        jl movementUpRight
        jg movementDownRight

        movementRight:    
            mov rax, 3
            jmp end
        movementUpRight:
            mov rax, 2
            jmp end
        movementDownRight:
            mov rax, 4
            jmp end

    xAxisNegative:

        cmp byte[origin+1], 0
        je movementLeft
        jl movementUpLeft
        jg movementDownLeft

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