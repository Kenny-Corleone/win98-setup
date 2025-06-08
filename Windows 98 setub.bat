@echo off
title Windows 98 Setup Utility
mode con: cols=80 lines=25
color 1F

:MENU
cls
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║                      Windows 98 Setup Utility                         ║
echo ║                                                                       ║
echo ║  1. Сохранить пользовательские данные                                 ║
echo ║  2. Скачать Windows 10 Media Creation Tool                            ║
echo ║  3. Запустить установку Windows                                       ║
echo ║  4. Установить программы после Windows                                ║
echo ║  5. Воспроизвести Win98 музыку (nostalgia.wav)                        ║
echo ║  6. Выйти                                                             ║
echo ║                                                                       ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.
set /p choice=Введите номер действия (1-6): 

if "%choice%"=="1" goto BACKUP
if "%choice%"=="2" goto DOWNLOAD_WIN
if "%choice%"=="3" goto RUN_SETUP
if "%choice%"=="4" goto INSTALL_SOFTWARE
if "%choice%"=="5" goto MUSIC
if "%choice%"=="6" exit
goto MENU

:LOADING
setlocal EnableDelayedExpansion
set str=Загрузка
for /L %%A in (1,1,3) do (
    cls
    echo !str!.
    timeout /nobreak /t 1 >nul
    set str=!str!.
)
endlocal
goto :eof

:BACKUP
call :LOADING
cls
echo [⏳] Подготовка к сохранению данных...
powershell -ExecutionPolicy Bypass -Command ^
 "$backup='C:\WinBackup_'+(Get-Date -Format yyyyMMdd_HHmm);" ^
 "New-Item -ItemType Directory -Force -Path $backup | Out-Null;" ^
 "foreach($f in @('Desktop','Documents','Downloads','Pictures')){" ^
 "Copy-Item -Path (Join-Path $env:USERPROFILE $f) -Destination (Join-Path $backup $f) -Recurse -Force -ErrorAction SilentlyContinue };" ^
 "Copy-Item -Path $env:LOCALAPPDATA\Google\Chrome\User Data -Destination (Join-Path $backup 'ChromeProfile') -Recurse -Force -ErrorAction SilentlyContinue;" ^
 "Write-Host '✅ Данные сохранены в: ' $backup"
pause
goto MENU

:DOWNLOAD_WIN
call :LOADING
cls
echo [⏬] Загружаем Media Creation Tool...
powershell -Command "Invoke-WebRequest 'https://go.microsoft.com/fwlink/?LinkId=691209' -OutFile $env:TEMP\MediaCreationTool.exe"
echo.
echo [✔] Файл сохранён в %%TEMP%%\MediaCreationTool.exe
pause
goto MENU

:RUN_SETUP
call :LOADING
cls
echo [🚀] Запуск Media Creation Tool...
start "" "%TEMP%\MediaCreationTool.exe"
pause
goto MENU

:INSTALL_SOFTWARE
call :LOADING
cls
echo [🛠] Установка программ...
powershell -Command ^
 "Set-ExecutionPolicy Bypass -Scope Process -Force;" ^
 "[System.Net.ServicePointManager]::SecurityProtocol = 3072;" ^
 "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
call choco install googlechrome vscode git python windows-terminal powertoys 7zip notepadplusplus -y
echo.
echo [✔] Установка завершена!
pause
goto MENU

:MUSIC
cls
echo [🎵] Воспроизведение ностальгической мелодии...
if exist nostalgia.wav (
    start /min wmplayer nostalgia.wav
) else (
    echo [!] Файл nostalgia.wav не найден в этой папке.
)
pause
goto MENU
