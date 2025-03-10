global manager
extern printf
extern scanf
extern fgets
extern stdin
extern atof
extern isfloat
extern istriangle
extern huron
section .data
    author_info db 10, "This program is brought to you as a courtesy of", 10 ,\
                      "Author: Chandresh Chavda", 10 ,\
                      "CWID: 885158899", 10 ,\
                      "Email: chav349@csu.fullerton.edu", 10, 0
    welcome_msg db 10, "Welcome to Huron’s Triangles. We take care of all your triangle needs.", 10, 0
    prompt_for_name db 10, "Please enter your name: ", 0
    prompt_for_sides db 10, "Please enter the lengths of three sides of a triangle: ", 0
    invalid_input db 10, "Error input try again", 10, 0
    valid_triangle db 10, "These inputs have been tested and they are sides of a valid triangle.", 10, 0
    invalid_triangle db 10, "These inputs have been tested and they are not the sides of a valid triangle.", 10, 0
    huron_formula_msg db 10, "The Huron formula will be applied to find the area.", 10, 0
    area_message db 10, "The area is %.4lf sq units. This number will be returned to the caller module.", 10, 0
    thank_you db 10, "Thank you %s. Your patronage is appreciated.", 10, 0
    zero_return_msg db 10, "A zero will not be returned to the operating system.", 10, 0
    string_input db "%s %s %s", 0
section .bss
    align 64
    backup_storage_area resb 832
    name resb 64
    side1 resq 1
    side2 resq 1
    side3 resq 1
    input_buffer resb 256
    endptr resq 1

section .text
 

manager:

push rbp
mov rbp, rsp
push rbx
push rcx
push rdx
push rdi
push rsi
push r8
push r9
push r10
push r11
push r12
push r13
push r14
push r15
pushf
; Print welcome message
mov rax, 0  ; Standard input is file descriptor 0
mov rdi, welcome_msg
call printf

    ; Prompt for name
    mov rax, 0
    mov rdi, prompt_for_name
    call printf

    mov rax, 0
    mov rdi, name
    mov rsi, 64
    mov rdx, [stdin]
    call fgets

    ; Remove newline character from name
    ; mov rax, 0
    ; mov rdi, name
    ; call remove_newline

    ; Print author information
    mov rax, 0
    mov rdi, author_info
    call printf

input_loop:
    ; Prompt for sides
    mov rax, 0
    mov rdi, prompt_for_sides
    call printf


    mov rax, 0
    mov rdi, string_input  ; Format string: "%s %s %s"
    mov rsi, side1          ; Address for first side
    mov rdx, side2          ; Address for second side
    mov rcx,  side3          ; Address for third side (use R8 instead of RCX)
    call scanf
    

    
    ; Parse the input string into three floating-point numbers

    mov rdi, side1        
    call isfloat           
    cmp rax, 0             
    je invalid_input_jmp       
    mov rdi, side1          
    call atof              
    movsd xmm12, xmm0      
    
    ; Validate and convert side2
    mov rdi, side2         
    call isfloat            
    cmp rax, 0             
    je invalid_input_jmp       
    mov rdi, side2          
    call atof              
    movsd xmm13, xmm0       
    
    ; Validate and convert side3
    mov rdi, side3        
    call isfloat           
    cmp rax, 0             
    je invalid_input_jmp       
    mov rdi, side3         
    call atof              
    movsd xmm14, xmm0      
    
    
    ; Call istriangle to validate the sides
    mov rax, 3
    movsd xmm0, xmm12       ; Passing side1
    movsd xmm1, xmm13       ; Passing side2
    movsd xmm2, xmm14       ; Passing side3
    call istriangle         ; Function using the three side args to check if the side make a vaild triangle
    cmp rax, 1              ; If returned false will prompt invalid_msg
    jne invalid_input_jmp       ; Jump to invalid_input block
    jmp next


    ; If valid, compute area
    invalid_input_jmp:
    mov rax, 0
    mov rdi, invalid_input          ; Display invalid_msg and prompt for re-input
    call printf
    jmp input_loop

        ; Print thank you message
    next:
    mov rax, 0
    mov rdi, thank_you
    mov rsi, name
    call printf

    
    ; Print valid triangle message
    mov rax, 0
    mov rdi, valid_triangle
    call printf


    
    ; Print Huron formula message
    mov rax, 0
    mov rdi, huron_formula_msg
    call printf

    movsd xmm0, xmm12       ; Passing side1
    movsd xmm1, xmm13       ; Passing side2
    movsd xmm2, xmm14       ; Passing side3
    call huron              ; Function using Heron's formula to calculate for triangle's area with the three sides
    movsd xmm15, xmm0       ; Saving area into non-violatile register


    ; Print area
    mov rax, 0
    mov rdi, area_message
    movsd xmm0, xmm15
    call printf



    ; Print zero return message
    mov rax, 0
    mov rdi, zero_return_msg
    call printf

    ; Restore the stack
    add rsp, 32

    ; Restore extended state
    mov rax, 7
    mov rdx, 0
    xrstor [backup_storage_area]

    ; Restore GPRs
    popf
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp

    ; Return area
    movsd xmm0, [side1]
    ret

; .invalid_input:
;     ; Print invalid input message
;     mov rdi, invalid_input
;     call printf
;     jmp input_loop

; invalid_triangle:
;     ; Print invalid triangle message
;     mov rdi, invalid_triangle
;     call printf

;     ; Restore the stack
;     add rsp, 32

;     ; Restore extended state
;     mov rax, 7
;     mov rdx, 0
;     xrstor [backup_storage_area]

;     ; Restore GPRs
;     popf
;     pop r15
;     pop r14
;     pop r13
;     pop r12
;     pop r11
;     pop r10
;     pop r9
;     pop r8
;     pop rdi
;     pop rsi
;     pop rdx
;     pop rcx
;     pop rbx
;     pop rbp

;     ; Return -1 to indicate error
;     mov rax, -1
;     ret

; remove_newline:
;     ; Remove newline character from name
;     mov rcx, 64
; .remove_loop:
;     cmp byte [rdi + rcx - 1], 10
;     je .replace_null
;     loop .remove_loop
;     ret
; .replace_null:
;     mov byte [rdi + rcx - 1], 0
;     ret