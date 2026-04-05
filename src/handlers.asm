%include "push.inc"

global handler_c
global handler_x
global handler_b
global handler_o
global handler_d
global handler_s
global handler_percent
global handler_unknown

extern buf_putc
extern output_str
extern output_char_uint_base
extern output_int_dec

extern null_str


;============================================================
; HANDLERS
; esi - spec char address
; edi - arg ptr
; ebx - printed_count
;============================================================
;------------------------------------------------------------
handler_c:
    movzx eax, byte [edi]
    add edi, 4

    push eax
    call buf_putc 
    add esp, 4

    inc ebx
    inc esi
    ret
;------------------------------------------------------------
handler_x:
    mov eax, [edi]
    add edi, 4

    push dword 16
    push eax
    call output_char_uint_base
    add esp, 8

    add ebx, eax

    inc esi
    ret
;------------------------------------------------------------
handler_b:
    mov eax, [edi]
    add edi, 4

    push dword 2
    push eax
    call output_char_uint_base
    add esp, 8

    add ebx, eax

    inc esi
    ret
;------------------------------------------------------------
handler_o:
    mov eax, [edi]
    add edi, 4

    push dword 8
    push eax
    call output_char_uint_base
    add esp, 8

    add ebx, eax

    inc esi
    ret
;------------------------------------------------------------
handler_d:
    mov eax, [edi]
    add edi, 4

    push eax
    call output_int_dec
    add esp, 4

    add ebx, eax

    inc esi
    ret
;------------------------------------------------------------
handler_s:
    mov eax, [edi]
    add edi, 4

    test eax, eax
    jnz .have_ptr
    mov eax, null_str

.have_ptr:
    push eax
    call output_str
    add esp, 4

    add ebx, eax

    inc esi
    ret
;------------------------------------------------------------
handler_percent:
    push dword '%'
    call buf_putc 
    add esp, 4

    inc ebx
    inc esi
    ret
;------------------------------------------------------------
handler_unknown:
    push dword '%'
    call buf_putc 
    add esp, 4
    inc ebx

    movzx eax, byte [esi]
    push eax
    call buf_putc 
    add esp, 4
    inc ebx

    inc esi
    ret
;------------------------------------------------------------

section .note.GNU-stack noalloc noexec nowrite progbits