bits 32

global check_cpu_features

check_cpu_features:
    call check_multiboot
    call check_cpuid
    call check_long_mode
    ret

error:
    mov dword [0xb8000], 0x4f454f72 ; Er
    mov dword [0xb8004], 0x4f724f6f ; ro
    mov dword [0xb8008], 0x4f724f3a ; r:
    mov word  [0xb800c], 0x4f20     ; <Space>
    mov byte  [0xb800e], al         ; Accumulator reg
    hlt

; Multiboot2 checks
check_multiboot:
    cmp eax, 0x36d76289 ; Multiboot sets eax to this magic number
    jne .no_multiboot  ; if it isn't set, the go to no_multiboot
    ret
.no_multiboot:
    mov al, "0"
    jmp error

; CPUID checks
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    xor eax, ecx
    jz .no_cpuid
    ret
.no_cpuid:
    mov al, "1"
    jmp error

; Long Mode checks
check_long_mode:
    mov eax, 0x80000000    ; Set the A-register to 0x80000000.
    cpuid                  ; CPU identification.
    cmp eax, 0x80000001    ; Compare the A-register with 0x80000001.
    jb .no_long_mode       ; It is less, there is no long mode.
    mov eax, 0x80000001    ; Set the A-register to 0x80000001.
    cpuid                  ; CPU identification.
    test edx, 1 << 29      ; Test if the LM-bit is set in the D-register.
    jz .no_long_mode       ; They aren't, there is no long mode.
    ret
.no_long_mode:
    mov al, "2"
    jmp error

check_sse:
    ; check for SSE
    mov eax, 0x1
    cpuid
    test edx, 1<<25
    jz .no_SSE

    ; enable SSE
    ret
.no_SSE:
    mov al, "a"
    jmp error
