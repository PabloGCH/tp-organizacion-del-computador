section .data


section .bss
    origin times 2 resb 1      ; Array de 2 elementos de 1b
    destination times 2 resb 1 ; Idem

section .text
    global returnDirection

    returnDirection:
        ; (rdi;rsi) = (x₀,y₀)
        ; (rdx;rcx) = (x₁,y₁)

        mov [origin]  , rdi 
        mov [origin+1], rsi

        sub [origin], rdx ; x₀ - x₁
        sub [origin+1], rcx ; y₀ - y₁

        cmp [origin],0
        je xAxisZero
        jg xAxisPositive
        jl xAxisNegative

    ; Las etiquetas de movimiento usan horarios del reloj
    xAxisZero:

        cmp [origin+1],0
        je movementNull
        jg movementUp
        jl movementDown
    
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

        cmp [origin+1],0
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

    xAxisNegative:

        cmp [origin+1, 0]
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
        return