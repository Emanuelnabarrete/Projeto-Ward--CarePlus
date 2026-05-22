@echo off
IF NOT EXIST .venv (
    echo Execute setup.bat primeiro!
    pause & exit /b 1
)
.venv\Scripts\python.exe main.py