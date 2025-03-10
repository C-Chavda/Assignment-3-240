section .data
    ; No data section needed for this module

section .bss
    ; No uninitialized data needed for this module

section .text
    global istriangle

istriangle:
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

    ; Load the sides into XMM registers
    movsd xmm0, xmm0            ; xmm0 = a
    movsd xmm1, xmm1            ; xmm1 = b
    movsd xmm2, xmm2            ; xmm2 = c

    ; Check if a + b > c
    movsd xmm3, xmm0            ; xmm3 = a
    addsd xmm3, xmm1            ; xmm3 = a + b
    comisd xmm3, xmm2           ; Compare (a + b) with c
    jbe .invalid_triangle       ; Jump if (a + b) <= c

    ; Check if a + c > b
    movsd xmm3, xmm0            ; xmm3 = a
    addsd xmm3, xmm2            ; xmm3 = a + c
    comisd xmm3, xmm1           ; Compare (a + c) with b
    jbe .invalid_triangle       ; Jump if (a + c) <= b

    ; Check if b + c > a
    movsd xmm3, xmm1            ; xmm3 = b
    addsd xmm3, xmm2            ; xmm3 = b + c
    comisd xmm3, xmm0           ; Compare (b + c) with a
    jbe .invalid_triangle       ; Jump if (b + c) <= a

    ; If all conditions are satisfied, the sides form a valid triangle
    mov rax, 1                  ; Return true (1)
    jmp .restore_registers

.invalid_triangle:
    ; If any condition fails, the sides do not form a valid triangle
    mov rax, 0                  ; Return false (0)

.restore_registers:
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

    ret                                                         ; Return to caller