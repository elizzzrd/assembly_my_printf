// nasm -f elf32 my_printf.asm -o my_printf.o
// gcc -m32 main.c my_printf.o -o printf

#include <stdio.h>

int my_printf(const char *fmt, ...);

int main(void) {
    my_printf("Hello, world!\n");
    my_printf("char: %c\n", 'A');
    my_printf("hex : %x\n", 0xFF);
    my_printf("bin : %b\n", 10);
    my_printf("oct : %o\n", 10);
    my_printf("dec : %d\n", 12345);
    my_printf("neg : %d\n", -12345);
    my_printf("str : %s\n", "test");
    my_printf("null: %s\n", (char*)0);
    my_printf("pct : %%\n");
    my_printf("%s %d %x %b %o %c %%\n", "abc", -42, 255, 5, 9, 'Z');

    return 0;
}