.686
.model flat, stdcall
option casemap:none

; Inclus�o de bibliotecas necess�rias
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
    inputFileName db 50 dup(0)         ; Buffer para armazenar o nome do arquivo de entrada
    outputFileName db 50 dup(0)        ; Buffer para armazenar o nome do arquivo de sa�da
    bufferEntrada db 4096 dup(0)       ; Buffer para leitura de 4096 bytes do arquivo de entrada
    bufferSaida db 4096 dup(0)         ; Buffer para escrita de 4096 bytes no arquivo de sa�da
    constReducaoStr db 4 dup(0)        ; Buffer para armazenar a constante de redu��o em formato de string
    constReducao dw 0                  ; Vari�vel para armazenar a constante de redu��o em formato num�rico
    readBytes dd 0                     ; Vari�vel para armazenar o n�mero de bytes lidos do arquivo
    writtenBytes dd 0                  ; Vari�vel para armazenar o n�mero de bytes escritos no arquivo
    header db 44 dup(0)                ; Buffer para o cabe�alho de 44 bytes do arquivo WAV
    msgInputFileName db "Digite o nome do arquivo de entrada (.WAV):", 0 ; Mensagem de entrada
    msgOutputFileName db "Digite o nome do arquivo de sa�da (.WAV):", 0  ; Mensagem de sa�da
    msgConstReducao db "Digite a constante de redu��o (1 a 10):", 0      ; Mensagem para constante de redu��o

.data?
    hInputFile dd ?                    ; Handle para o arquivo de entrada
    hOutputFile dd ?                   ; Handle para o arquivo de sa�da
    inputHandle dd ?                   ; Handle para a entrada do console
    outputHandle dd ?                  ; Handle para a sa�da do console

.code
start:
    ; Obter handles para entrada e sa�da do console
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

process_new_file:
    ; Solicitar e obter o nome do arquivo de entrada
    invoke WriteConsole, outputHandle, addr msgInputFileName, sizeof msgInputFileName - 1, addr writtenBytes, 0
    invoke ReadConsole, inputHandle, addr inputFileName, sizeof inputFileName - 1, addr readBytes, 0
    push offset inputFileName          ; Passa o endere�o da string para a fun��o
    call RemoveCRLF                    ; Chama a fun��o para remover CR e LF do nome do arquivo

    ; Solicitar e obter o nome do arquivo de sa�da
    invoke WriteConsole, outputHandle, addr msgOutputFileName, sizeof msgOutputFileName - 1, addr writtenBytes, 0
    invoke ReadConsole, inputHandle, addr outputFileName, sizeof outputFileName - 1, addr readBytes, 0
    push offset outputFileName         ; Passa o endere�o da string para a fun��o
    call RemoveCRLF                    ; Chama a fun��o para remover CR e LF do nome do arquivo

    ; Solicitar e obter a constante de redu��o
    invoke WriteConsole, outputHandle, addr msgConstReducao, sizeof msgConstReducao - 1, addr writtenBytes, 0
    invoke ReadConsole, inputHandle, addr constReducaoStr, sizeof constReducaoStr - 1, addr readBytes, 0
    push offset constReducaoStr        ; Passa o endere�o da string para a fun��o
    call RemoveCRLF                    ; Chama a fun��o para remover CR e LF da constante
    invoke atodw, addr constReducaoStr ; Converte a constante de string para num�rico
    mov constReducao, ax               ; Armazena a constante de redu��o

    ; Abrir o arquivo de entrada para leitura
    invoke CreateFile, addr inputFileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hInputFile, eax
    test eax, eax
    jz error_opening_file

    ; Criar o arquivo de sa�da para escrita
    invoke CreateFile, addr outputFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hOutputFile, eax
    test eax, eax
    jz error_opening_file

    ; Copiar os primeiros 44 bytes (cabe�alho .WAV)
    invoke ReadFile, hInputFile, addr header, 44, addr readBytes, NULL
    invoke WriteFile, hOutputFile, addr header, 44, addr writtenBytes, NULL

process_audio:
    ; L� os dados de �udio do arquivo de entrada
    invoke ReadFile, hInputFile, addr bufferEntrada, 4096, addr readBytes, NULL
    test eax, eax                      ; Verifica se a leitura foi bem-sucedida
    jz error_reading_file              ; Se houve erro, sai com uma mensagem de erro
    cmp readBytes, 0                   ; Compara readBytes com zero
    je end_process                     ; Se n�o h� bytes, termina o processo

    ; Reduz o volume dos dados lidos
    push constReducao                  ; Passa a constante de redu��o para a fun��o
    push offset bufferSaida            ; Passa o buffer de sa�da para a fun��o
    push offset bufferEntrada          ; Passa o buffer de entrada para a fun��o
    push readBytes                     ; Passa o n�mero de bytes lidos para a fun��o
    call ReduceVolume                  ; Chama a fun��o para reduzir o volume

    ; Escrever o buffer de sa�da processado no arquivo de sa�da
    invoke WriteFile, hOutputFile, addr bufferSaida, readBytes, addr writtenBytes, NULL
    jmp process_audio                  ; Volta para processar o pr�ximo bloco de dados


end_process:
    ; Fecha os arquivos abertos
    invoke CloseHandle, hInputFile
    invoke CloseHandle, hOutputFile

    ; Finaliza o programa
    invoke ExitProcess, 0

error_opening_file:
    ; Tratamento de erro ao abrir arquivos
    ; Mensagem de erro pode ser escrita aqui
    invoke ExitProcess, 1

error_reading_file:
    ; Tratamento de erro ao ler arquivos
    ; Mensagem de erro pode ser escrita aqui
    invoke ExitProcess, 2

; Fun��o para remover CR e LF de uma string
RemoveCRLF proc
    mov esi, [esp+4]                    ; Obt�m o endere�o da string a partir da pilha
proximo:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne proximo
    dec esi
    xor al, al
    mov [esi], al
    ret
RemoveCRLF endp

; Fun��o para reduzir o volume de um buffer de �udio
ReduceVolume proc entrada:DWORD, saida:DWORD, constante:WORD, numBytes:DWORD
    mov esi, entrada                     ; Aponta para o buffer de entrada
    mov edi, saida                       ; Aponta para o buffer de sa�da
    mov cx, constante                    ; Carrega a constante de redu��o

    ; Processa as amostras de �udio (2 bytes cada)
    mov ecx, numBytes
    shr ecx, 1                           ; Divide o n�mero de bytes por 2 (WORD)

reducao_loop:
    mov ax, [esi]                        ; L� um WORD (2 bytes) do buffer de entrada
    add esi, 2                           ; Move para o pr�ximo par de bytes
    cwd                                  ; Sinaliza para divis�o
    idiv cx                              ; Divide ax por cx (constante)
    mov [edi], ax                        ; Salva o resultado no buffer de sa�da
    add edi, 2                           ; Move para o pr�ximo par de bytes
    loop reducao_loop                    ; Continua at� processar todos os dados
    ret
ReduceVolume endp

end start
