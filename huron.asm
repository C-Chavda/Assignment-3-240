section .data
    half dq 0.5  ; Constant for dividing by 2
    message db "Hello, Assembly!", 0 
section .bss
    align 64
    backup_storage_area resb 832  ; Reserve space for xsave (832 bytes for AVX-512)
    
section .text
    global huron
    extern printf
huron:
    ;=========== Back up all the GPRs whether used in this program or not =========================================================
    push       rbp                                              ; Save a copy of the stack base pointer
    mov        rbp, rsp                                         ; We do this in order to be 100% compatible with C and C++.
    push       rbx                                              ; Back up rbx
    push       rcx                                              ; Back up rcx
    push       rdx                                              ; Back up rdx
    push       rsi                                              ; Back up rsi
    push       rdi                                              ; Back up rdi
    push       r8                                               ; Back up r8
    push       r9                                               ; Back up r9
    push       r10                                              ; Back up r10
    push       r11                                              ; Back up r11
    push       r12                                              ; Back up r12
    push       r13                                              ; Back up r13
    push       r14                                              ; Back up r14
    push       r15                                              ; Back up r15
    pushf                                                       ; Back up rflags

    ; Backup other registers (XMM, etc.) using xsave
    mov rax, 7                  ; Request saving all state components
    mov rdx, 0                  ; Clear upper bits of rdx
    xsave [backup_storage_area] ; Save extended state to backup_storage_area

    ; Allocate 32 bytes on the stack for alignment and local variables
    sub rsp, 32

    ; Load the sides into higher XMM registers
    movsd xmm12, xmm0           ; xmm12 = a
    movsd xmm13, xmm1           ; xmm13 = b
    movsd xmm14, xmm2           ; xmm14 = c

    ; Calculate the semi-perimeter: s = (a + b + c) / 2
    movsd xmm15, xmm12          ; xmm15 = a
    addsd xmm15, xmm13          ; xmm15 = a + b
    addsd xmm15, xmm14          ; xmm15 = a + b + c
    mulsd xmm15, [half]         ; xmm15 = (a + b + c) * 0.5 = s
    
    ; Compute (s - a)
    movsd xmm0, xmm15           ; xmm0 = s
    subsd xmm0, xmm12           ; xmm0 = s - a

    ; Compute (s - b)
    movsd xmm1, xmm15           ; xmm1 = s
    subsd xmm1, xmm13           ; xmm1 = s - b

    ; Compute (s - c)
    movsd xmm2, xmm15           ; xmm2 = s
    subsd xmm2, xmm14           ; xmm2 = s - c
   
    ; Compute s * (s - a) * (s - b) * (s - c)
    mulsd xmm15, xmm0           ; xmm15 = s * (s - a)
    mulsd xmm15, xmm1           ; xmm15 = s * (s - a) * (s - b)
    mulsd xmm15, xmm2           ; xmm15 = s * (s - a) * (s - b) * (s - c)

    ; Compute the square root to get the area
    movsd xmm0, xmm15           ; Copy the result to xmm0
    sqrtsd xmm0, xmm0           ; xmm0 = sqrt(s * (s - a) * (s - b) * (s - c))
    movq rax, xmm0              ; Move the result to RAX for returning

    ; Restore the stack
    add rsp, 32

    ; Restore other registers (XMM, etc.) using xrstor
    mov rax, 7                  ; Request restoring all state components
    mov rdx, 0                  ; Clear upper bits of rdx
    xrstor [backup_storage_area] ; Restore extended state from backup_storage_area

    ;=========== Restore all the GPRs whether used in this program or not =========================================================
    popf                                                        ; Restore rflags
    pop        r15                                              ; Restore r15
    pop        r14                                              ; Restore r14
    pop        r13                                              ; Restore r13
    pop        r12                                              ; Restore r12
    pop        r11                                              ; Restore r11
    pop        r10                                              ; Restore r10
    pop        r9                                               ; Restore r9
    pop        r8                                               ; Restore r8
    pop        rdi                                              ; Restore rdi
    pop        rsi                                              ; Restore rsi
    pop        rdx                                              ; Restore rdx
    pop        rcx                                              ; Restore rcx
    pop        rbx                                              ; Restore rbx
    pop        rbp                                              ; Restore rbp

    ; Return area
    ret

invalid_input:
    ; Handle invalid input (e.g., return NaN or a specific error code)
    mov rax, -1
    ret