.686
.model flat, stdcall
option casemap:none

; Inclui as defini��es da API do Windows necess�rias para a manipula��o de arquivos e console.
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

.data
    ; Buffers para armazenar os nomes dos arquivos.
    inputFileName db "sw.wav", 0  ; Nome do arquivo de entrada (exemplo: entrada.wav).
    outputFileName db "saida610.wav", 0   ; Nome do arquivo de sa�da (exemplo: saida.wav).
    
    ; Mensagens para exibir em caso de sucesso ou erro.
    msgSuccess db "Processamento de amostras realizado com sucesso!", 0ah, 0
    msgError db "Erro ao abrir o arquivo.", 0ah, 0

    ; Buffer para armazenar os 44 bytes do cabe�alho e blocos de 16 bytes.
    header db 44 dup(0)
    bufferEntrada db 16 dup(0)         ; Buffer para ler blocos de 16 bytes.
    bufferSaida db 16 dup(0)           ; Buffer para armazenar o resultado processado.
    
    ; Vari�veis para armazenar os handles dos arquivos e o n�mero de bytes lidos/escritos.
    hInputFile dd 0
    hOutputFile dd 0
    readBytes dd 0
    writtenBytes dd 0

    ; Vari�vel para armazenar o handle de sa�da do console.
    outputHandle dd 0

    ; Vari�vel para armazenar a constante de redu��o.
    constReducao dw 10                  ; Exemplo de constante de redu��o (deve ser entre 1 e 10).

.code
start:
    ; Obter o handle para a sa�da padr�o (console).
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ; Abrir o arquivo de entrada para leitura.
    invoke CreateFile, addr inputFileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hInputFile, eax
    test eax, eax
    jz error_opening_file

    ; Criar o arquivo de sa�da para escrita.
    invoke CreateFile, addr outputFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hOutputFile, eax
    test eax, eax
    jz error_opening_file

    ; Ler os primeiros 44 bytes do cabe�alho do arquivo de entrada.
    invoke ReadFile, hInputFile, addr header, 44, addr readBytes, NULL
    test eax, eax
    jz error_reading_file

    ; Escrever os 44 bytes do cabe�alho no arquivo de sa�da.
    invoke WriteFile, hOutputFile, addr header, 44, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ; Loop para ler o restante do arquivo em blocos de 16 bytes, processar e escrever no arquivo de sa�da.
process_loop:
    ; L� at� 16 bytes do arquivo de entrada.
    invoke ReadFile, hInputFile, addr bufferEntrada, 16, addr readBytes, NULL
    test eax, eax
    jz error_reading_file
    cmp readBytes, 0
    je end_process

    ; Processa cada amostra de 2 bytes no buffer.
    ; As amostras de �udio s�o WORDs (2 bytes), ent�o dividimos cada par de bytes pela constante.
    mov esi, offset bufferEntrada   ; Aponta para o buffer de entrada.
    mov edi, offset bufferSaida     ; Aponta para o buffer de sa�da.
    mov cx, constReducao            ; Carrega a constante de redu��o em CX.
    mov ecx, readBytes              ; N�mero de bytes lidos.
    shr ecx, 1                      ; Divide por 2, pois cada amostra tem 2 bytes.

process_samples:
    ; L� uma amostra de 2 bytes (WORD) do buffer de entrada.
    lodsw                           ; Carrega o pr�ximo WORD do buffer de entrada em AX.
    cwd                             ; Sinaliza para divis�o, estendendo AX para DX:AX.
    idiv cx                         ; Divide AX pela constante de redu��o (CX).
    stosw                           ; Armazena o resultado no buffer de sa�da.
    loop process_samples            ; Repete para todas as amostras do bloco.

    ; Escreve o buffer processado no arquivo de sa�da.
    invoke WriteFile, hOutputFile, addr bufferSaida, readBytes, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ; Repete o loop at� que n�o haja mais bytes para ler.
    jmp process_loop

end_process:
    ; Fecha os arquivos abertos.
    invoke CloseHandle, hInputFile
    invoke CloseHandle, hOutputFile

    ; Exibir mensagem de sucesso.
    invoke WriteConsole, outputHandle, addr msgSuccess, sizeof msgSuccess - 1, addr writtenBytes, 0

    ; Finaliza o programa chamando ExitProcess com c�digo de sa�da 0.
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
