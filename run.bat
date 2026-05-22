@echo off
cd /d C:\Ward
IF NOT EXIST .venv (
    echo Ambiente nao encontrado. Rodando setup...
    call setup.bat
)
.venv\Scripts\python.exe main.py