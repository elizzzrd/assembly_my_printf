;============================================================
; SYSCALLS
; sys_open  --- eax = 5, ebx = file path, ecx = flags, edx = mode ---> descriptor
; sys_read  --- eax = 3, ebx = descriptor, ecx = buffer, edx = number of bytes
; sys_write --- eax = 4, ebx = descriptor, ecx = buffer, edx = number of bytes
; sys_close --- eax = 6, ebx = descriptor
; sys_exit  --- eax = 1, ebx = return code
;============================================================
; FLAGS (opening)
O_RDONLY    equ 0      ; read only
O_WRONLY    equ 1      ; write only
O_RDWR      equ 2      ; read and write 
O_CREAT     equ 0100o  ; create if not exist
O_TRUNC     equ 01000o ; clean
O_APPEND    equ 02000o ; add to end
;============================================================



;============================================================
; MACRO for syscalls
; Arguments (up to 6) placed in regs:
;                            eax, ebx, ecx, edx, esi, edi
; Exit: return code in edx
;
; write(stdout, msg, len) == syscall 4, 1, msg, len
; exit(0)                 == syscall 1, 0
;============================================================

%macro syscall 1-6
    %if %0 > 6
        %error  "Linux syscall supports max 6 args"
    %endif

    mov eax, %1         ; load syscall number

                        ; load args in registers
    %if %0 > 1
        mov ebx, %2
    %endif

    %if %0 > 2
        mov ecx, %3
    %endif

    %if %0 > 3
        mov edx, %4
    %endif

    %if %0 > 4
        mov esi, %5
    %endif

    %if %0 > 5
        mov edi, %6
    %endif

    int 0x80h

    cmp eax, 0xfffff000
    jb %%no_error

    neg eax
    mov edx, eax
    jmp %%done

%%no_error:
    xor edx, edx
%%done:
%endmacro

