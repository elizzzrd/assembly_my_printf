%include "push.inc"

global buf_flush
global buf_putc
global buf_write

global output_str
global output_char_uint_base
global output_int_dec

extern buffer_pos
extern out_buf
extern num_buf

;============================================================
; buf_flush
; flush buffered output to stdout
;============================================================
buf_flush:
    push ebp
    mov ebp, esp

    multipush ebx, ecx, edx

    mov edx, [buffer_pos]
    test edx, edx
    jz .done

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, out_buf
    int 0x80

    mov dword [buffer_pos], 0

.done:
    multipop edx, ecx, ebx, ebp
    ret

;============================================================
; int buf_putc (char ch)
; [ebp + 8] = ch
; eax = 1
;============================================================
buf_putc :
    push ebp
    mov ebp, esp

    multipush ebx, ecx, edx

    mov ecx, [buffer_pos]
    cmp ecx, BUF_SIZE
    jb .enough_space

    call buf_flush
    xor ecx, ecx

.enough_space:
    mov eax, [ebp + 8]
    mov [out_buf + ecx], al
    inc ecx
    mov [buffer_pos], ecx

    mov eax, 1

    multipop edx, ecx, ebx, ebp
    ret

;============================================================
; int buf_write(const char * ptr, unsigned len)
; [ebp + 8] = ptr
; [ebp + 12] = len
; eax = len
;============================================================
buf_write:
    push ebp
    mov ebp, esp

    multipush ebx, ecx, edx, esi, edi

    mov ecx, [ebp + 12]                 ; len

    test ecx, ecx
    jz .len_zero

    ; if len >= BUF_SIZE ---> flush current buffer and write str directly
    cmp ecx, BUF_SIZE
    jae .direct_write

    ; if buffer_pos + len > BUF_SIZE ---> flush buffer first
    mov eax, [buffer_pos]
    add eax, ecx
    cmp eax, BUF_SIZE
    jbe .copy_to_buffer

    call buf_flush

.copy_to_buffer:
    mov edx, ecx
    mov esi, [ebp + 8]                  ; str ptr
    mov eax, [buffer_pos]
    lea edi, [out_buf + eax]
    cld
    rep movsb 

    mov eax, [buffer_pos]
    add eax, edx
    mov [buffer_pos], eax

    mov eax, edx
    jmp .done

.direct_write:
    call buf_flush

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, [ebp + 8]
    mov edx, [ebp + 12]
    int 0x80

    mov eax, [ebp + 12]
    jmp .done

.len_zero:
    xor eax, eax

.done:
    multipop edi, esi, edx, ecx, ebx, ebp
    ret




;============================================================
; OUTPUT SYMBOLS
; [ebp + 8] = const char * str
; exit
;   eax = printed length 
;
;   const char *start = s;
;   const char *end = s;
;   while (*end != '\0')
;       end++;
;   int len = end - start;
;   buf_write(start, len);
;   return len;
;
;============================================================
output_str:
    push ebp
    mov ebp, esp

    multipush esi, edi, ecx

    mov esi, [ebp + 8]
    mov edi, esi

    ; find '\0'
    cld
    xor eax, eax
    mov ecx, -1
    repne scasb         

    mov eax, edi
    sub eax, esi
    dec eax         ; length

    push eax
    push esi
    call buf_write
    add esp, 8

    multipop ecx, edi, esi, ebp
    ret
;------------------------------------------------------------
; [ebp + 8] = value
; [ebp + 12] = base (2, 8, 10, 16)
;------------------------------------------------------------
output_char_uint_base:
    push ebp
    mov ebp, esp

    multipush ebx, ecx, edx, esi, edi

    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]

    lea edi, [num_buf + 33]             ; edi = &num_buf[33]
    mov byte [edi], 0                   ; num_buf[33] = 0
    dec edi                             ; edi = &num_buf[32]

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
    lea esi, [edi + 1]      ; after last digit edi points 1 byte before str

    push ecx                ; len
    push esi                ; ptr
    call buf_write
    add esp, 8

    multipop edi, esi, edx, ecx, ebx, ebp
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
    call buf_putc 
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
