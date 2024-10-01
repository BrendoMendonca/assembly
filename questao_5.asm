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
    mov ecx, 1000 ;inicializa ecx com 1000
 repete2:
 repete:
    inc ecx ;incrementa ecx com +1
    mov ebx, 11 ;ebx rebe 11 para fazer a divisão
    mov eax, ecx ;eax recebe o valor de ecx
    cmp ecx, 1999 ;verifica o valor de ecx
    je fim ; se ecx é menor do que 1999, então o programa pula para o fim
    xor edx, edx ;zera edx para realizar a divisão
    div ebx ;ebx divide eax e edx(eax fica com o quociente e edx com o resto da divisão)
    cmp edx, 5 ;verifica se edx(resto da divisão) é igual a 5
    jne repete ;se não for igual a 5, repete o processo novamente
    push ecx ;coloca o valor de ecx na pilha(backup de ecx)
    printf("%d\n", ecx) ;exibe o valor de ecx
    pop ecx ;recupera o valor de ecx da pilha
    cmp ecx, 1999 ;verifica novamente se o valor de ecx é 1999 
    jb repete2 ;se for menor que 1999, repete o processo
    fim:

    invoke ExitProcess, 0   
end start
