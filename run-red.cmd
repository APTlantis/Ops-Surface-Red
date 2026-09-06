@echo off
setlocal
cd /d "%~dp0"

where red.exe >nul 2>nul
if errorlevel 1 (
    echo Red was not found on PATH.
    echo Install the Windows Red/View toolchain, then rerun this file.
    echo Project entry point: main.red
    pause
    exit /b 1
)

red.exe main.red

