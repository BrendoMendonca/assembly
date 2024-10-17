.686
.model flat, stdcall
option casemap:none


include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib


.data
    ; Buffers para armazenar os nomes dos arquivos.
    inputFileName db "sw.wav", 0  ; Nome do arquivo de entrada (exemplo: entrada.wav).
    outputFileName db "saida21.wav", 0   ; Nome do arquivo de saída (exemplo: saida.wav).
    
    ; Mensagens para exibir em caso de sucesso ou erro.
    msgSuccess db "Copia do arquivo realizada com sucesso!", 0ah, 0
    msgError db "Erro ao abrir o arquivo.", 0ah, 0

    ; Buffer para armazenar os 44 bytes do cabeçalho e blocos de 16 bytes.
    header db 44 dup(0)
    buffer db 16 dup(0)                ; Buffer para ler blocos de 16 bytes.
    
    ; Variáveis para armazenar os handles dos arquivos e o número de bytes lidos/escritos.
    hInputFile dd 0
    hOutputFile dd 0
    readBytes dd 0
    writtenBytes dd 0

    ; Variável para armazenar o handle de saída do console.
    outputHandle dd 0

    reducao WORD 1

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

    ; Loop para ler o restante do arquivo em blocos de 16 bytes e escrever no arquivo de saída.
copy_loop:
    ; Lê até 16 bytes do arquivo de entrada.
    invoke ReadFile, hInputFile, addr buffer, 16, addr readBytes, NULL
    test eax, eax
    jz error_reading_file
    ; Se nenhum byte foi lido, terminamos o loop.
    cmp readBytes, 0
    je end_copy

    mov ecx, 0
    mov bx, reducao

diminuir_vol:
    cmp ecx, readBytes
    jge white_data

    mov ax, word ptr [buffer + ecx]

    cwd
    idiv bx

    mov word ptr [buffer + ecx], ax

    add ecx, 2
    jmp diminuir_vol
    
white_data:
    ; Escreve os bytes lidos no arquivo de saída.
    invoke WriteFile, hOutputFile, addr buffer, readBytes, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ; Repete o loop até que não haja mais bytes para ler.
    jmp copy_loop

end_copy:
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
