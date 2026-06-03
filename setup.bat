@echo off
echo.
echo ══════════════════════════════════════════════════════════════
echo   Ward — Setup
echo ══════════════════════════════════════════════════════════════
echo.

echo [1/8] Verificando Python 3.11...
py -3.11 --version 2>nul
IF ERRORLEVEL 1 (
    echo ERRO: Python 3.11 nao encontrado.
    echo Baixe em: https://www.python.org/downloads/release/python-3110/
    pause & exit /b 1
)

echo.
echo [2/8] Movendo projeto para C:\Ward (evita erro de acento)...
IF NOT EXIST C:\Ward (
    xcopy "%~dp0" "C:\Ward\" /E /I /Q
)
cd /d C:\Ward

echo.
echo [3/8] Criando ambiente virtual...
IF EXIST .venv rmdir /s /q .venv
py -3.11 -m venv .venv
IF ERRORLEVEL 1 ( echo ERRO ao criar .venv & pause & exit /b 1 )

echo.
echo [4/8] Criando arquivo .env...
IF NOT EXIST C:\Ward\.env (
    echo OLLAMA_HOST=http://localhost:11434 > C:\Ward\.env
    echo MODEL=llama3:latest >> C:\Ward\.env
    echo INTERVALO_REGISTRO=10 >> C:\Ward\.env
    echo EAR_THRESH=0.20 >> C:\Ward\.env
    echo FRAMES_FECHADO=2 >> C:\Ward\.env
    echo CAMERA_INDEX=0 >> C:\Ward\.env
    echo CAMERA_WIDTH=1280 >> C:\Ward\.env
    echo CAMERA_HEIGHT=720 >> C:\Ward\.env
    echo CALIB_TOTAL=60 >> C:\Ward\.env
    echo ALPHA=0.15 >> C:\Ward\.env
    echo .env criado com valores padrao!
) ELSE (
    echo .env ja existe, pulando...
)

echo.
echo [5/8] Atualizando pip...
.venv\Scripts\python.exe -m pip install --upgrade pip --quiet

echo.
echo [6/8] Instalando dependencias (aguarde ~10 minutos)...
.venv\Scripts\pip.exe install -r requirements.txt
.venv\Scripts\pip.exe uninstall jax jaxlib -y 2>nul

echo.
echo [7/8] Configurando banco de dados...
.venv\Scripts\python.exe manage.py migrate
IF ERRORLEVEL 1 ( echo ERRO ao rodar migrations & pause & exit /b 1 )

echo.
echo [8/8] Criando usuario administrador...
echo Voce precisara definir usuario e senha para acessar o painel web.
.venv\Scripts\python.exe manage.py createsuperuser

echo.
echo ══════════════════════════════════════════════════════════════
echo   PRONTO! Execute run.bat para iniciar.
echo   Projeto instalado em: C:\Ward
echo ══════════════════════════════════════════════════════════════
pause