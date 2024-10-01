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
    um_array DW 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
.code
start:
    xor eax, eax
    xor ecx, ecx
 laco:
    add ax, [um_array + ecx*2]
    inc ecx
    cmp ecx, 10
    jl laco
    printf("Valor do somatorio: %d\n", eax)
    invoke ExitProcess, 0   
end start





