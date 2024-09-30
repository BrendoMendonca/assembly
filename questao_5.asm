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
    num DWORD 1005
   ; aux DWORD 0
.code
start:
 repete:
    inc num
    mov ebx, 11
    mov eax, num
    xor edx, edx
    div ebx
    cmp edx, 5
    je imprime
    jne repete
 imprime:
    printf("%d\n", num)
    

    invoke ExitProcess, 0   
end start





