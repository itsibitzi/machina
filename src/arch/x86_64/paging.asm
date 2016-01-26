bits 32

global set_up_page_tables

extern p4_table
extern p3_table
extern p2_table

set_up_page_tables:
    mov eax, p3_table   ; map first P4 entry to P3 table
    or eax, 0b11        ; The first and second bits in the page table stand for present and writable
    mov [p4_table], eax ; Set the first entry in P4 to the value in eax

    mov eax, p2_table   ; map first P3 entry to P2 table
    or eax, 0b11        ; present + writable
    mov [p3_table], eax ; Set the first entry in p3 to eax

    mov ecx, 0                    ; counter variable
.map_p2_table:                    ; map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
    mov eax, 0x200000             ; 2MiB
    mul ecx                       ; start address of ecx-th page
    or eax, 0b10000011            ; present + writable + huge
    mov [p2_table + ecx * 8], eax ; map ecx-th entry
    inc ecx                       ; increase counter
    cmp ecx, 512                  ; if counter == 512, the whole P2 table is mapped
    jne .map_p2_table             ; else map the next entry

    ; Now we've initialized our page tables we can enable them

    mov eax, p4_table   ; load P4 to cr3 register (cpu uses this to access the P4 table)
    mov cr3, eax

    mov eax, cr4        ; enable PAE-flag in cr4 (Physical Address Extension)
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080 ; set the long mode bit in the EFER MSR (model specific register)
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0        ; enable paging in the cr0 register
    or eax, 1 << 31
    mov cr0, eax

    ret


