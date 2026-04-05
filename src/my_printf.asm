%include "push.inc"
global my_printf

global used_bytes
global out_buf
global num_buf
global null_str

extern handler_c
extern handler_x
extern handler_b
extern handler_o
extern handler_d
extern handler_s
extern handler_percent
extern buf_putc
extern buf_flush

section .data
    null_str        db "(null)", 0

    spec_chars      db 'c', 'x', 'b', 'o', 'd', 's', '%'
    spec_funcs      dd handler_c, handler_x, handler_b, handler_o, handler_d, handler_s, handler_percent
    spec_count      equ 7

section .bss
    num_buf         resb 34             ; temporary buffer 
    out_buf         resb 128
    used_bytes      resd 1


section .text

;============================================================
; int my_printf(const char * fmt, ...)
; cdecl
; 
; esi - fmt pointer
; edi - arg pointer
; ebx - printed_count
;============================================================
my_printf:
    push ebp
    mov ebp, esp

    multipush ebx, esi, edi

    mov esi, [ebp + 8]
    lea edi, [ebp + 12]
    xor ebx, ebx
    mov dword [used_bytes], 0

.main_loop:
    mov al, [esi]
    test al, al
    jz .done

    cmp al, '%'
    je .fmt_spec

    ; usual symbol, not spec
    movzx eax, al
    push eax
    call buf_putc 
    add esp, 4

    inc ebx
    inc esi
    jmp .main_loop

.fmt_spec:
    inc esi                 ; skip '%'
    mov al, [esi]
    test al, al
    jz .done

    multipush esi, edi, ebx

    movzx eax, byte [esi]
    push eax
    call dispatch_spec          ; eax = handler address or 0
    add esp, 4

    multipop ebx, edi, esi

    test eax, eax
    jz .unknown_spec

    call eax
    jmp .main_loop

.unknown_spec:
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
    jmp .main_loop

.done:
    push ebx
    call buf_flush
    pop eax

    multipop edi, esi, ebx, ebp
    ret


;============================================================
; dispatch_spec
; entry:
;   [esp + 4] - spec char
; exit:
;   eax = handler address or 0
;============================================================
dispatch_spec:
    push ebp
    mov ebp, esp

    multipush esi, ecx

    movzx eax, byte [ebp + 8]
    mov esi, spec_chars
    mov ecx, spec_count
    mov edx, spec_funcs

.find_loop:
    test ecx, ecx
    jz .not_found_spec

    cmp al, [esi]
    je .found_spec

    inc esi
    add edx, 4
    dec ecx
    jmp .find_loop

.found_spec:
    mov eax, [edx]
    jmp .exit_find_loop

.not_found_spec:
    xor eax, eax

.exit_find_loop:
    multipop ecx, esi, ebp
    ret


section .note.GNU-stack noalloc noexec nowrite progbits