%include "push.inc"
global my_printf

global buffer_pos
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
extern handler_unknown

extern buf_putc
extern buf_flush

section .data
    null_str        db "(null)", 0

    spec_min        equ '%'
    spec_max        equ 'x'
    spec_range      equ spec_max - spec_min + 1

    jump_table:
                                dd handler_percent
    times ('b' - '%' - 1)       dd handler_unknown
                                dd handler_b
                                dd handler_c
                                dd handler_d
    times ('o' - 'd' - 1)       dd handler_unknown
                                dd handler_o
    times ('s' - 'o' - 1)       dd handler_unknown
                                dd handler_s
    times ('x' - 's' - 1)       dd handler_unknown
                                dd handler_x



section .bss
    num_buf         resb 34             ; temporary buffer 
    out_buf         resb 128
    buffer_pos      resd 1

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
    mov dword [buffer_pos], 0

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

    movzx eax, byte [esi]

    cmp eax, spec_min
    jb .unknown_spec

    cmp eax, spec_max
    ja .unknown_spec

    sub eax, spec_min
    call dword [jump_table + 4*eax]


    jmp .main_loop

.unknown_spec:
    call handler_unknown
    jmp .main_loop

.done:
    push ebx
    call buf_flush
    pop eax

    multipop edi, esi, ebx, ebp
    ret



section .note.GNU-stack noalloc noexec nowrite progbits