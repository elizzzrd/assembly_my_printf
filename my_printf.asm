global my_printf

BITS 32

section .data
null_str    db "(null)", 0


spec_chars      db 'c', 'x', 'b', 'o', 'd', 's', '%'
spec_funcs      dd handler_c, handler_x, handler_b, handler_o, handler_d, handler_s, handler_percent
spec_count      equ 7

section .bss
num_buf         resb 34


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

    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]
    lea edi, [ebp + 12]
    xor ebx, ebx

.main_loop:
    mov al, [esi]
    test al, al
    jz .done

    cmp al, '%'
    je .fmt_spec

    ; usual symbol, not spec
    movzx eax, al
    push eax
    call output_char
    add esp, 4

    inc ebx
    inc esi
    jmp .main_loop

.fmt_spec:
    inc esi                 ; skip '%'
    mov al, [esi]
    test al, al
    jz .done

    push esi
    push edi
    push ebx

    movzx eax, byte [esi]
    push eax
    call dispatch_spec          ; eax = handler address or 0
    add esp, 4

    pop ebx
    pop edi
    pop esi

    test eax, eax
    jz .unknown_spec

    call eax
    jmp .main_loop

.unknown_spec:
    push dword '%'
    call output_char
    add esp, 4
    inc ebx

    movzx eax, byte [esi]
    push eax
    call output_char
    add esp, 4
    inc ebx

    inc esi
    jmp .main_loop

.done:
    mov eax, ebx

    pop edi
    pop esi
    pop ebx
    pop ebp

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

    push esi
    push ecx

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
    pop ecx
    pop esi
    pop ebp
    ret


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
    call output_char
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
    call output_char
    add esp, 4

    inc ebx
    inc esi
    ret
;------------------------------------------------------------
handler_unknown:
    xor eax, eax
    ret
;------------------------------------------------------------



;============================================================
; OUTPUT SYMBOLS
; exit
;   eax = numbers of printed symbols
;============================================================
;------------------------------------------------------------
; output_char (via write)
; entry: 
;   [ebp + 8] - char
; exit: 
;   eax = 1 
;------------------------------------------------------------
output_char:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edx

    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    lea ecx, [ebp + 8]
    mov edx, 1
    int 0x80

    mov eax, 1
    pop edx
    pop ecx
    pop ebx
    pop ebp

    ret
;------------------------------------------------------------
output_str:
    push ebp
    mov ebp, esp

    push esi
    push ebx

    mov esi, [ebp + 8]
    xor ebx, ebx

.str_loop:
    mov al, [esi]
    test al, al
    jz .done

    movzx eax, al
    push eax
    call output_char
    add esp, 4

    inc ebx
    inc esi
    jmp .str_loop

.done:
    mov eax, ebx

    pop ebx
    pop esi
    pop ebp

    ret
;------------------------------------------------------------
; [ebp + 8] = value
; [ebp + 12] = base (2, 8, 10, 16)
;------------------------------------------------------------
output_char_uint_base:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]

    lea edi, [num_buf + 33]
    mov byte [edi], 0
    dec edi

    xor ecx, ecx

    test eax, eax
    jnz .convert_loop

    mov byte [edi], '0'
    dec edi
    inc ecx
    jmp .print_res

.convert_loop:
    xor edx, edx
    div  ebx               ; quotient in EAX, remainder in EDX

    cmp edx, 9
    jbe .digit09

    add edx, 'a' - 10
    jmp .store_digit

.digit09:
    add edx, '0'

.store_digit:
    mov [edi], dl
    dec edi
    inc ecx

    test eax, eax
    jnz .convert_loop

.print_res:
    lea esi, [edi + 1]

    push ecx
.print_loop:
    test ecx, ecx
    jz .printed

    movzx eax, byte [esi]

    push ecx
    push eax
    call output_char
    add esp, 4
    pop ecx

    inc esi
    dec ecx
    jmp .print_loop

.printed:
    pop eax

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp

    ret
;------------------------------------------------------------
output_int_dec:
    push ebp
    mov ebp, esp

    push ebx
    mov eax, [ebp + 8]
    xor ebx, ebx

    test eax, eax
    jns .positive

    push eax
    push dword '-'
    call output_char
    add esp, 4
    pop eax
    
    inc ebx
    neg eax

.positive:
    push dword 10
    push eax
    call output_char_uint_base
    add esp, 8

    add eax, ebx

    pop ebx
    pop ebp
    ret


section .note.GNU-stack noalloc noexec nowrite progbits