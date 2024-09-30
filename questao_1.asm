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
 
.code
start:

    xor eax, eax ;inicializa eax com 0
    mov ecx, 1 ;inicializa ecx com 1
 repete:
    add eax, ecx ;incrementa eax com o valor de ecx
    inc ecx ;incrementa ecx com 1
    cmp ecx, 100 ;verifica se ecx é o centesimo numero somado
    jbe repete ;se ecx for menor ou igual a 100, repete a operação
    printf("Valor da soma: %d\n", eax) ;exibe o resultado
    invoke ExitProcess, 0   
end start

