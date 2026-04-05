;============================================================
; MACROs for pushing and popping multiple registers
;============================================================
%macro multipush 1-*
    %rep %0
        push %1
        %rotate 1
    %endrep
%endmacro
;------------------------------------------------------------
%macro multipop 1-*
    %rep %0
        pop %1
        %rotate 1
    %endrep
%endmacro
;============================================================


BUF_SIZE    equ 128
SYS_WRITE   equ 4
STDOUT      equ 1

