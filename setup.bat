@echo off
echo.
echo ══════════════════════════════════════════════════════════════
echo   Ward — Setup
echo ══════════════════════════════════════════════════════════════
echo.

echo [1/5] Verificando Python 3.11...
py -3.11 --version 2>nul
IF ERRORLEVEL 1 (
    echo ERRO: Python 3.11 nao encontrado.
    echo Baixe em: https://www.python.org/downloads/release/python-3110/
    pause & exit /b 1
)

echo.
echo [2/5] Movendo projeto para C:\Ward (evita erro de acento)...
IF NOT EXIST C:\Ward (
    xcopy "%~dp0" "C:\Ward\" /E /I /Q
)
cd /d C:\Ward

echo.
echo [3/5] Criando ambiente virtual...
IF EXIST .venv rmdir /s /q .venv
py -3.11 -m venv .venv
IF ERRORLEVEL 1 ( echo ERRO ao criar .venv & pause & exit /b 1 )

echo.
echo [4/5] Atualizando pip...
.venv\Scripts\python.exe -m pip install --upgrade pip --quiet

echo.
echo [5/5] Instalando dependencias (aguarde ~10 minutos)...
.venv\Scripts\pip.exe install -r requirements.txt
.venv\Scripts\pip.exe uninstall jax jaxlib -y 2>nul

echo.
echo ══════════════════════════════════════════════════════════════
echo   PRONTO! Execute run.bat para iniciar.
echo   Projeto instalado em: C:\Ward
echo ══════════════════════════════════════════════════════════════
pause