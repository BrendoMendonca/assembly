.686
.model flat, stdcall
option casemap:none

; Inclusão de bibliotecas necessárias
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
    inputFileName db 50 dup(0)         ; Buffer para armazenar o nome do arquivo de entrada
    outputFileName db 50 dup(0)        ; Buffer para armazenar o nome do arquivo de saída
    bufferEntrada db 4096 dup(0)       ; Buffer para leitura de 4096 bytes do arquivo de entrada
    bufferSaida db 4096 dup(0)         ; Buffer para escrita de 4096 bytes no arquivo de saída
    constReducaoStr db 4 dup(0)        ; Buffer para armazenar a constante de redução em formato de string
    constReducao dw 0                  ; Variável para armazenar a constante de redução em formato numérico
    readBytes dd 0                     ; Variável para armazenar o número de bytes lidos do arquivo
    writtenBytes dd 0                  ; Variável para armazenar o número de bytes escritos no arquivo
    header db 44 dup(0)                ; Buffer para o cabeçalho de 44 bytes do arquivo WAV
    msgInputFileName db "Digite o nome do arquivo de entrada (.WAV):", 0 ; Mensagem de entrada
    msgOutputFileName db "Digite o nome do arquivo de saída (.WAV):", 0  ; Mensagem de saída
    msgConstReducao db "Digite a constante de redução (1 a 10):", 0      ; Mensagem para constante de redução

.data?
    hInputFile dd ?                    ; Handle para o arquivo de entrada
    hOutputFile dd ?                   ; Handle para o arquivo de saída
    inputHandle dd ?                   ; Handle para a entrada do console
    outputHandle dd ?                  ; Handle para a saída do console

.code
start:
    ; Obter handles para entrada e saída do console
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

process_new_file:
    ; Solicitar e obter o nome do arquivo de entrada
    invoke WriteConsole, outputHandle, addr msgInputFileName, sizeof msgInputFileName - 1, addr writtenBytes, 0
    invoke ReadConsole, inputHandle, addr inputFileName, sizeof inputFileName - 1, addr readBytes, 0
    push offset inputFileName          ; Passa o endereço da string para a função
    call RemoveCRLF                    ; Chama a função para remover CR e LF do nome do arquivo

    ; Solicitar e obter o nome do arquivo de saída
    invoke WriteConsole, outputHandle, addr msgOutputFileName, sizeof msgOutputFileName - 1, addr writtenBytes, 0
    invoke ReadConsole, inputHandle, addr outputFileName, sizeof outputFileName - 1, addr readBytes, 0
    push offset outputFileName         ; Passa o endereço da string para a função
    call RemoveCRLF                    ; Chama a função para remover CR e LF do nome do arquivo

    ; Solicitar e obter a constante de redução
    invoke WriteConsole, outputHandle, addr msgConstReducao, sizeof msgConstReducao - 1, addr writtenBytes, 0
    invoke ReadConsole, inputHandle, addr constReducaoStr, sizeof constReducaoStr - 1, addr readBytes, 0
    push offset constReducaoStr        ; Passa o endereço da string para a função
    call RemoveCRLF                    ; Chama a função para remover CR e LF da constante
    invoke atodw, addr constReducaoStr ; Converte a constante de string para numérico
    mov constReducao, ax               ; Armazena a constante de redução

    ; Abrir o arquivo de entrada para leitura
    invoke CreateFile, addr inputFileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hInputFile, eax
    test eax, eax
    jz error_opening_file

    ; Criar o arquivo de saída para escrita
    invoke CreateFile, addr outputFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hOutputFile, eax
    test eax, eax
    jz error_opening_file

    ; Copiar os primeiros 44 bytes (cabeçalho .WAV)
    invoke ReadFile, hInputFile, addr header, 44, addr readBytes, NULL
    invoke WriteFile, hOutputFile, addr header, 44, addr writtenBytes, NULL

process_audio:
    ; Lê os dados de áudio do arquivo de entrada
    invoke ReadFile, hInputFile, addr bufferEntrada, 4096, addr readBytes, NULL
    test eax, eax                      ; Verifica se a leitura foi bem-sucedida
    jz error_reading_file              ; Se houve erro, sai com uma mensagem de erro
    cmp readBytes, 0                   ; Compara readBytes com zero
    je end_process                     ; Se não há bytes, termina o processo

    ; Reduz o volume dos dados lidos
    push constReducao                  ; Passa a constante de redução para a função
    push offset bufferSaida            ; Passa o buffer de saída para a função
    push offset bufferEntrada          ; Passa o buffer de entrada para a função
    push readBytes                     ; Passa o número de bytes lidos para a função
    call ReduceVolume                  ; Chama a função para reduzir o volume

    ; Escrever o buffer de saída processado no arquivo de saída
    invoke WriteFile, hOutputFile, addr bufferSaida, readBytes, addr writtenBytes, NULL
    jmp process_audio                  ; Volta para processar o próximo bloco de dados


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

; Função para remover CR e LF de uma string
RemoveCRLF proc
    mov esi, [esp+4]                    ; Obtém o endereço da string a partir da pilha
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

; Função para reduzir o volume de um buffer de áudio
ReduceVolume proc entrada:DWORD, saida:DWORD, constante:WORD, numBytes:DWORD
    mov esi, entrada                     ; Aponta para o buffer de entrada
    mov edi, saida                       ; Aponta para o buffer de saída
    mov cx, constante                    ; Carrega a constante de redução

    ; Processa as amostras de áudio (2 bytes cada)
    mov ecx, numBytes
    shr ecx, 1                           ; Divide o número de bytes por 2 (WORD)

reducao_loop:
    mov ax, [esi]                        ; Lê um WORD (2 bytes) do buffer de entrada
    add esi, 2                           ; Move para o próximo par de bytes
    cwd                                  ; Sinaliza para divisão
    idiv cx                              ; Divide ax por cx (constante)
    mov [edi], ax                        ; Salva o resultado no buffer de saída
    add edi, 2                           ; Move para o próximo par de bytes
    loop reducao_loop                    ; Continua até processar todos os dados
    ret
ReduceVolume endp

end start
