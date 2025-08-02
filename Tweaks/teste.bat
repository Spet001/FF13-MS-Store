@echo off
setlocal enabledelayedexpansion

:: Solicita o diretório do jogo
set /p game_dir="Digite o diretório do jogo (ex: C:\XboxGames\FINAL FANTASY XIII\Content\): "

:: Verifica se o diretório é válido (deve conter white_data\sys\)
if not exist "%game_dir%\white_data\sys\" (
    echo Diretório inválido. Certifique-se de que o diretório contém white_data\sys\.
    pause
    exit /b
)

:: Define o caminho para o ff13tool.exe (assumindo que está na mesma pasta do script)
set "ff13tool_path=%~dp0ff13tool.exe"

:: Verifica se o ff13tool.exe existe
if not exist "%ff13tool_path%" (
    echo ff13tool.exe não encontrado. Certifique-se de que o arquivo está na mesma pasta do script.
    pause
    exit /b
)

:: Navega para o diretório dos arquivos de dados do jogo
cd /d "%game_dir%\white_data\sys\"

:: Faz backup do arquivo original (se não existir um backup)
if exist filelistu.win32.bin (
    if not exist filelistu.win32.bin.backup (
        copy filelistu.win32.bin filelistu.win32.bin.backup
        echo Backup de filelistu.win32.bin criado.
    ) else (
        echo Backup já existe.
    )
) else (
    echo filelistu.win32.bin não encontrado. Verifique se o arquivo existe.
    pause
    exit /b
)

:: Extrai o arquivo usando ff13tool.exe
"%ff13tool_path%" -x filelistu.win32.bin
if %errorlevel% equ 0 (
    echo Extração bem-sucedida. Verifique os arquivos extraídos.
) else (
    echo Erro ao extrair o arquivo. Verifique se o ff13tool.exe está correto e se o arquivo não está corrompido.
)

pause