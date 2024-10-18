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
    ;buffers para armazenar os nomes dos arquivos.
    inputFileName db "sw.wav", 0  
    outputFileName db "saida.wav", 0   
    
    ;mensagens para exibir em caso de sucesso ou erro.
    msgSuccess db "Reducao realizada com sucesso!", 0ah, 0
    msgError db "Erro ao abrir o arquivo.", 0ah, 0

    ;buffer para armazenar os 44 bytes do cabeçalho e blocos de 16 bytes.
    header db 44 dup(0)
    buffer db 16 dup(0)                
        
    ;variáveis para armazenar os handles dos arquivos e o número de bytes lidos/escritos.
    hInputFile dd 0
    hOutputFile dd 0
    readBytes dd 0
    writtenBytes dd 0

    ;variável para armazenar o handle de saída do console.
    outputHandle dd 0

    ;variável de reducao de volume
    reducao WORD 10

.code
start:
    ;obter o handle para a saída do console
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ;abre o arquivo de entrada para leitura.
    invoke CreateFile, addr inputFileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hInputFile, eax
    test eax, eax
    jz error_opening_file

    ;cria o arquivo de saída para escrita.
    invoke CreateFile, addr outputFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hOutputFile, eax
    test eax, eax
    jz error_opening_file

    ;faz a leitura dos primeiros 44 bytes do cabeçalho do arquivo de entrada.
    invoke ReadFile, hInputFile, addr header, 44, addr readBytes, NULL
    test eax, eax
    jz error_reading_file

    ;escreve os 44 bytes do cabeçalho no arquivo de saída.
    invoke WriteFile, hOutputFile, addr header, 44, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ;loop para ler o restante do arquivo em blocos de 16 bytes e escrever no arquivo de saída.
copia_loop:
    ;lê 16 bytes do arquivo de entrada.
    invoke ReadFile, hInputFile, addr buffer, 16, addr readBytes, NULL
    test eax, eax
    jz error_reading_file
    ;se nenhum byte foi lido, terminamos o loop.
    cmp readBytes, 0
    je fim_copia

    mov ecx, 0
    mov bx, reducao

diminuir_vol:
    cmp ecx, readBytes
    jge escreve_saida

    mov ax, word ptr [buffer + ecx]

    cwd
    idiv bx

    mov word ptr [buffer + ecx], ax

    add ecx, 2
    jmp diminuir_vol
    
escreve_saida:
    ;escreve os bytes lidos no arquivo de saída.
    invoke WriteFile, hOutputFile, addr buffer, readBytes, addr writtenBytes, NULL
    test eax, eax
    jz error_writing_file

    ;repete o loop até que não tenha mais bytes para ler.
    jmp copia_loop

fim_copia:
    ;fecha os arquivos abertos.
    invoke CloseHandle, hInputFile
    invoke CloseHandle, hOutputFile

    ;exibe mensagem de sucesso.
    invoke WriteConsole, outputHandle, addr msgSuccess, sizeof msgSuccess - 1, addr writtenBytes, 0

    ;finaliza o programa
    invoke ExitProcess, 0

error_opening_file:
    ;exibe mensagem de erro ao abrir os arquivos.
    invoke WriteConsole, outputHandle, addr msgError, sizeof msgError - 1, addr writtenBytes, 0
    invoke ExitProcess, 1

error_reading_file:
    ;exibe mensagem de erro ao ler o arquivo.
    invoke WriteConsole, outputHandle, addr msgError, sizeof msgError - 1, addr writtenBytes, 0
    invoke ExitProcess, 2

error_writing_file:
    ;exibe mensagem de erro ao escrever no arquivo.
    invoke WriteConsole, outputHandle, addr msgError, sizeof msgError - 1, addr writtenBytes, 0
    invoke ExitProcess, 3

end start
