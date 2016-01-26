global start
global p4_table
global p3_table
global p2_table

section .text
bits 32

extern check_cpu_features
extern set_up_page_tables
extern enable_sse
extern long_mode_start

start:
    mov esp, stack_top

    call check_cpu_features
    call set_up_page_tables
    call enable_sse

    lgdt [gdt64.pointer]

    mov ax, gdt64.data
    mov ss, ax  ; stack selector
    mov ds, ax  ; data selector
    mov es, ax  ; extra selector

    jmp gdt64.code:long_mode_start

    hlt

section .bss

align 4096

; Page tables
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

; Stack
stack_bottom:
    resb 4096
stack_top:

section .rodata
gdt64:
    dq 0 ; zero entry
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53) ; code segment
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) ; data segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64
