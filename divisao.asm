.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
    hStdInput DWORD ?
    hStdOutput DWORD ?
    
    bufferNum db 10 dup(0)       ; Buffer para o numerador
    bufferDen db 10 dup(0)       ; Buffer para o denominador
    bytesRead DWORD ?
    
    promptNum db "Digite o numerador: ", 0
    promptDen db "Digite o denominador: ", 0
    resultMsg db "Resultado: %d", 0
    resultBuffer db 20 dup(0)    ; Buffer para armazenar o resultado formatado

    num DWORD ?
    den DWORD ?
    result DWORD ?
    
.code
start:
    ; Obter os handles de entrada e saída padrão (console)
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hStdInput, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hStdOutput, eax

    ; Exibir mensagem para o numerador
    invoke WriteConsole, hStdOutput, addr promptNum, sizeof promptNum - 1, addr bytesRead, 0
    
    ; Ler o numerador do teclado
    invoke ReadConsole, hStdInput, addr bufferNum, sizeof bufferNum - 1, addr bytesRead, 0
    invoke atodw, addr bufferNum            ; Converte a string do buffer para DWORD
    mov num, eax                            ; Armazena o valor em 'num'

    ; Exibir mensagem para o denominador
    invoke WriteConsole, hStdOutput, addr promptDen, sizeof promptDen - 1, addr bytesRead, 0
    
    ; Ler o denominador do teclado
    invoke ReadConsole, hStdInput, addr bufferDen, sizeof bufferDen - 1, addr bytesRead, 0
    invoke atodw, addr bufferDen            ; Converte a string do buffer para DWORD
    mov den, eax                            ; Armazena o valor em 'den'

    ; Realizar a divisão
    mov eax, num                            ; Carrega o numerador em EAX
    cdq                                     ; Estende o sinal de EAX para EDX:EAX
    mov ebx, den                            ; Carrega o denominador em EBX
    div ebx                                 ; Divide EDX:EAX por EBX
    mov result, eax                         ; Armazena o quociente em 'result'

    ; Formatar o resultado em uma string
    invoke dwtoa, result, addr resultBuffer ; Converte DWORD result para string em resultBuffer
    
    ; Exibir o resultado da divisão
    invoke WriteConsole, hStdOutput, addr resultMsg, sizeof resultMsg - 1, addr bytesRead, 0
    invoke WriteConsole, hStdOutput, addr resultBuffer, sizeof resultBuffer, addr bytesRead, 0

    invoke ExitProcess, 0

end start
