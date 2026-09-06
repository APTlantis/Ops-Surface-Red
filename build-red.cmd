@echo off
setlocal
cd /d "%~dp0"

if exist "%~dp0redc.exe" (
    set "RED_COMPILER=%~dp0redc.exe"
) else (
    where red.exe >nul 2>nul
    if errorlevel 1 (
        echo Red was not found. Put redc.exe beside this script or expose red.exe on PATH.
        pause
        exit /b 1
    )
    set "RED_COMPILER=red.exe"
)

if not exist dist mkdir dist
"%RED_COMPILER%" -r -e -t Windows -o dist\Aptlantis-Ops.exe main.red
if errorlevel 1 exit /b %errorlevel%

echo Built dist\Aptlantis-Ops.exe
