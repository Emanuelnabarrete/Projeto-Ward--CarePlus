@echo off
echo.
echo [1/5] Verificando Python 3.11...
py -3.11 --version 2>nul
IF ERRORLEVEL 1 (
    echo ERRO: Python 3.11 nao encontrado.
    echo Baixe em: https://www.python.org/downloads/release/python-3110/
    pause & exit /b 1
)
echo.
echo [2/5] Removendo ambiente antigo se existir...
IF EXIST .venv rmdir /s /q .venv
echo.
echo [3/5] Criando ambiente virtual...
py -3.11 -m venv .venv
IF ERRORLEVEL 1 ( echo ERRO ao criar .venv & pause & exit /b 1 )
echo.
echo [4/5] Atualizando pip...
.venv\Scripts\python.exe -m pip install --upgrade pip --quiet
echo.
echo [5/5] Instalando dependencias (aguarde, pode demorar ~10 min)...
.venv\Scripts\pip.exe install -r requirements.txt
IF ERRORLEVEL 1 ( echo ERRO na instalacao & pause & exit /b 1 )
echo.
echo ✅ PRONTO! Execute run.bat para iniciar.
pause