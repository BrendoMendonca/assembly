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
    num DWORD 5                        
.code
start:
    mov eax, num ;coloca o valor da variável num em eax
    mov ebx, 2 ;ebx recebe 2 para fazer dividir eax e ver se tem resto 0(sendo par)
    xor edx, edx ;inicializar edx com 0
    div ebx ;divide eax e edx por ebx (eax fica com o quaciente e edx com o resto da divisão)
    cmp edx, 0 ;verifica se edx é 0
    je par ;se for igual a 0 imprime que é par pela label par
    jne impar ;se não for igual a zero imprime que é impar com a label impar
impar:    
    printf("%d eh impar\n", num)
    invoke ExitProcess, 0   

par:
    printf("%d eh par\n", num)  

    invoke ExitProcess, 0   
end start





