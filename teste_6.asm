.686
.model flat, stdcall
option casemap:none

; Inclui as definições da API do Windows necessárias para a manipulação de arquivos e console.
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

.data
    ; Buffers para armazenar os nomes dos arquivos.
    inputFileName db "sw.wav", 0  ; Nome do arquivo de entrada (exemplo: entrada.wav).
    outputFileName db "saida610.wav", 0   ; Nome do arquivo de saída (exemplo: saida.wav).
    
    ; Mensagens para exibir em caso de sucesso ou erro.
    msgSuccess db "Processamento de amostras realizado com sucesso!", 0ah, 0
    msgError db "Erro ao abrir o arquivo.", 0ah, 0

    ; Buffer para armazenar os 44 bytes do cabeçalho e blocos de 16 bytes.
    header db 44 dup(0)
    bufferEntrada db 16 dup(0)         ; Buffer para ler blocos de 16 bytes.
    bufferSaida db 16 dup(0)           ; Buffer para armazenar o resultado processado.
    
    ; Variáveis para armazenar os handles dos arquivos e o número de bytes lidos/escritos.
    hInputFile dd 0
    hOutputFile dd 0
    readBytes dd 0
    writtenBytes dd 0

    ; Variável para armazenar o handle de saída do console.
    outputHandle dd 0

    ; Variável para armazenar a constante de redução.
    constReducao dw 10                  ; Exemplo de constante de redução (deve ser entre 1 e 10).

.code
start:
    ; Obter o handle para a saída padrão (console).
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ; Abrir o arquivo de entrada para leitura.
    invoke CreateFile, addr inputFileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hInputFile, eax
    test eax, eax
    jz error_opening_file

    ; Criar o arquivo de saída para escrita.
    invoke CreateFile, addr outputFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hOutputFile, eax
    test eax, eax
    jz error_opening_file

    ; Ler os primeiros 44 bytes do cabeçalho do arquivo de entrada.
    invoke ReadFile, hInputFile, addr header, 44, addr readBytes, NULL
    test eax, eax
    jz error_reading_file

    ; Escrever os 44 bytes do cabeçalho no arquivo de saída.
    invoke WriteFile, hOutputFile, addr header, 44, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ; Loop para ler o restante do arquivo em blocos de 16 bytes, processar e escrever no arquivo de saída.
process_loop:
    ; Lê até 16 bytes do arquivo de entrada.
    invoke ReadFile, hInputFile, addr bufferEntrada, 16, addr readBytes, NULL
    test eax, eax
    jz error_reading_file
    cmp readBytes, 0
    je end_process

    ; Processa cada amostra de 2 bytes no buffer.
    ; As amostras de áudio são WORDs (2 bytes), então dividimos cada par de bytes pela constante.
    mov esi, offset bufferEntrada   ; Aponta para o buffer de entrada.
    mov edi, offset bufferSaida     ; Aponta para o buffer de saída.
    mov cx, constReducao            ; Carrega a constante de redução em CX.
    mov ecx, readBytes              ; Número de bytes lidos.
    shr ecx, 1                      ; Divide por 2, pois cada amostra tem 2 bytes.

process_samples:
    ; Lê uma amostra de 2 bytes (WORD) do buffer de entrada.
    lodsw                           ; Carrega o próximo WORD do buffer de entrada em AX.
    cwd                             ; Sinaliza para divisão, estendendo AX para DX:AX.
    idiv cx                         ; Divide AX pela constante de redução (CX).
    stosw                           ; Armazena o resultado no buffer de saída.
    loop process_samples            ; Repete para todas as amostras do bloco.

    ; Escreve o buffer processado no arquivo de saída.
    invoke WriteFile, hOutputFile, addr bufferSaida, readBytes, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ; Repete o loop até que não haja mais bytes para ler.
    jmp process_loop

end_process:
    ; Fecha os arquivos abertos.
    invoke CloseHandle, hInputFile
    invoke CloseHandle, hOutputFile

    ; Exibir mensagem de sucesso.
    invoke WriteConsole, outputHandle, addr msgSuccess, sizeof msgSuccess - 1, addr writtenBytes, 0

    ; Finaliza o programa chamando ExitProcess com código de saída 0.
    invoke ExitProcess, 0

error_opening_file:
    ; Exibe mensagem de erro ao abrir os arquivos.
    invoke WriteConsole, outputHandle, addr msgError, sizeof msgError - 1, addr writtenBytes, 0
    invoke ExitProcess, 1

error_reading_file:
    ; Exibe mensagem de erro ao ler o arquivo.
    invoke WriteConsole, outputHandle, addr msgError, sizeof msgError - 1, addr writtenBytes, 0
    invoke ExitProcess, 2

error_writing_file:
    ; Exibe mensagem de erro ao escrever no arquivo.
    invoke WriteConsole, outputHandle, addr msgError, sizeof msgError - 1, addr writtenBytes, 0
    invoke ExitProcess, 3

end start
