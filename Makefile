ASM = nasm 
ASMFLAGS = -f elf32
LD = ld
#LDFLAGS = -m elf_i386
LDFLAGS = -m32
CC = gcc
CFLAGS = -m32 -Wall -g -O0

SOURCEDIR = src
BUILDDIR = build 


ASM_SRCS = $(wildcard $(SOURCEDIR)/*.asm)
C_SRCS = $(wildcard $(SOURCEDIR)/*.c)

ASM_OBJS = $(ASM_SRCS:$(SOURCEDIR)/%.asm=$(BUILDDIR)%.o)
C_OBJS = $(C_SRCS:$(SOURCEDIR)/%.c=$(BUILDDIR)%.o)

OBJS = $(ASM_OBJS) $(C_OBJS)

TARGET = program

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

all: $(BUILDDIR) $(TARGET)

$(TARGET): $(OBJS)
	@$(CC) $(LDFLAGS) $^ -o $@

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.asm | $(BUILDDIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	@./$(TARGET)

clean:
	rm -rf $(OBJS)

rebuild: clean all

.PHONY: all clean rebuild