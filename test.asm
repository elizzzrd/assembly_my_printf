; testing my_printf.asm
%include "ker.inc"

global _start
extern my_printf

section .data
    msg1        db "Hello, world!", 10, 0
    msg2        db "char: %c", 10, 0
    msg3        db "hex : %x", 10, 0
    msg4        db "bin : %b", 10, 0
    msg5        db "oct : %o", 10, 0
    msg6        db "dec : %d", 10, 0
    msg7        db "neg : %d", 10, 0
    msg8        db "str : %s", 10, 0
    msg9        db "null: %s", 10, 0
    msg10       db "pct : %%", 10, 0
    msg11       db "%s %d %x %b %o %c %%", 10, 0
    
    test_str    db "abc", 0
    newline     db 10, 0

section .text

_start:
    push msg1
    call my_printf
    add esp, 4

    push 'A'
    push msg2
    call my_printf
    add esp, 8

    push 0xFF
    push msg3
    call my_printf
    add esp, 8

    push 10
    push msg4
    call my_printf
    add esp, 8

    push 10
    push msg5
    call my_printf
    add esp, 8

    push 12345
    push msg6
    call my_printf
    add esp, 8

    push -12345
    push msg7
    call my_printf
    add esp, 8

    push test_str
    push msg8
    call my_printf
    add esp, 8

    push 0
    push msg9
    call my_printf
    add esp, 8

    push msg10
    call my_printf
    add esp ,4

    push 'Z'                    ; %c
    push 9                      ; %o
    push 5                      ; %b
    push 255                    ; %x
    push -42                    ; %d
    push test_str               ; %s
    push msg11
    call my_printf
    add esp, 7*4

    syscall 1, 0

section .note.GNU-stack noalloc noexec nowrite progbits