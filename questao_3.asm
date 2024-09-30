.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.data
    a dword 5
    b dword 5
.code
start:
    mov eax, a
    cmp eax, b
    jl maiorB
    jg maiorA
    je igual
 igual:
    printf("Valores iguais: %d\n", eax)
    invoke ExitProcess, 0
 maiorB:
    printf("B eh maior: %d\n", b)
    invoke ExitProcess, 0
 maiorA:
    printf("A eh maior: %d\n", a)
    invoke ExitProcess, 0
end start
