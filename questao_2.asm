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
    b DWORD 5                        
    d DWORD 10                       
    a DWORD 0 
.code
start:
    mov eax, b
    add eax, d
    add eax, 100
    mov a, eax
    printf("A: %d\n", a)
    invoke ExitProcess, 0   
end start

