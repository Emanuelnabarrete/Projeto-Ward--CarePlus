@echo off
cd /d C:\Ward
IF NOT EXIST .venv (
    echo Ambiente nao encontrado. Rodando setup...
    call setup.bat
)

echo.
echo ══════════════════════════════════════════════════════════════
echo   Ward — Iniciando sistema
echo ══════════════════════════════════════════════════════════════
echo.
echo   Dashboard : http://127.0.0.1:8000
echo   Admin     : http://127.0.0.1:8000/admin
echo   Feche as janelas para encerrar
echo.
echo ══════════════════════════════════════════════════════════════

start "Ward - Dashboard" cmd /k ".venv\Scripts\python.exe manage.py runserver"
timeout /t 3 /nobreak >nul
start "Ward - Monitor" cmd /k ".venv\Scripts\python.exe main.py"