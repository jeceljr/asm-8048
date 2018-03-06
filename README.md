# asm-8048

this is a 1988 modification of the Z80 assembler for the Intel 8048 microcontroller

The file __asm8048.c__ was compiled by Borland Turbo C to generate the MS-DOS executable file __asm8048.exe__.
It uses text pattern matching and the patterns are in the separate __table.c__ file which is simply
included in __asm8048.c__ so compiling is very simple.

The __teclado.asm__ file is the 8048 assembly code for a IBM PC AT compatible keyboard and can be used
as a test input for the assembler.
