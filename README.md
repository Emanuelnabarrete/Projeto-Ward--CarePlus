# Ward — Monitor de Postura, Piscadas e Emoção

Sistema de monitoramento em tempo real via webcam que analisa postura corporal, frequência de piscadas e expressões faciais, gerando relatórios automáticos ao final de cada sessão.

---

## Como funciona

O sistema utiliza três modelos rodando em paralelo:

- **MediaPipe Pose** — detecta landmarks do corpo e calcula métricas de postura (projeção da cabeça, inclinação, encolhimento de ombros)
- **MediaPipe FaceMesh** — calcula o EAR (Eye Aspect Ratio) para detectar piscadas em tempo real
- **FER (Facial Expression Recognition)** — classifica a emoção dominante do rosto em uma thread separada para não travar o loop principal

A cada sessão, o sistema passa por uma **calibração de 60 frames** onde o usuário senta reto para estabelecer a baseline individual. A partir daí, o score de postura é calculado como desvio relativo à baseline.

A cada 10 segundos (configurável via `.env`), um registro é salvo com: horário, classificação de postura, score, piscadas no intervalo e emoção detectada.

---

## Estrutura do projeto

```
Ward/
├── configs/              # Configurações internas da aplicação
├── data/                 # Datasets de teste e ataque
│   ├── attack_dataset.json
│   └── test_dataset.json
├── outputs/              # Arquivos gerados pelo sistema (.csv, .xlsx, .txt)
├── prompts/              # Prompts do sistema Ollama
│   └── system_prompt.txt
├── .env                  # Variáveis de ambiente
├── .gitignore
├── main.py               # Código principal
├── requirements.txt
├── run.bat               # Executa o sistema
└── setup.bat             # Instala dependências e configura o ambiente
```

---

## Instalação

### Pré-requisitos

- Python 3.11
- Webcam conectada
- Windows (scripts `.bat` nativos)

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/Ward---GS-.git
cd Ward---GS-

# 2. Configure o ambiente e instale as dependências
setup.bat

# 3. Configure o .env com suas variáveis
# (veja a seção de configuração abaixo)

# 4. Execute o sistema
run.bat
```

---

## Configuração (.env)

```env
INTERVALO_REGISTRO=10       # Segundos entre cada registro
EAR_THRESH=0.20             # Limiar para detecção de piscada
FRAMES_FECHADO=2            # Frames consecutivos para confirmar piscada
CAMERA_INDEX=0              # Índice da câmera (0 = padrão)
CAMERA_WIDTH=1280
CAMERA_HEIGHT=720
CALIB_TOTAL=60              # Frames para calibração inicial
ALPHA=0.15                  # Suavização do filtro exponencial
OLLAMA_HOST=http://localhost:11434
MODEL=gpt-oss:120b
```

---

## Uso

| Tecla | Ação |
|-------|------|
| `R` | Recalibrar postura |
| `Q` | Encerrar e gerar relatório |

Ao encerrar, três arquivos são gerados automaticamente em `outputs/`:

- `postura_YYYYMMDD_HHMMSS.csv` — dados brutos de cada registro
- `postura_YYYYMMDD_HHMMSS.txt` — relatório textual com estatísticas
- `postura_YYYYMMDD_HHMMSS.xlsx` — planilha formatada com gráficos de distribuição

---

## Classificações de postura

| Classificação | Score | Cor |
|---------------|-------|-----|
| Boa postura | 0 – 19 | Verde |
| Postura regular | 20 – 49 | Amarelo |
| Má postura | 50 – 100 | Vermelho |

---

## Dependências principais

| Biblioteca | Uso |
|------------|-----|
| `mediapipe` | Pose + FaceMesh |
| `fer` + `tf-keras` | Reconhecimento de emoções |
| `opencv-python` | Captura e renderização de vídeo |
| `openpyxl` | Geração de planilhas Excel |
| `pandas` | Manipulação de dados |
| `python-dotenv` | Leitura do `.env` |

---

## Integrantes

| Nome | RM |
|---|---|
| Emanuel Nabarrete | 566931 |
| Luiz Eduardo | 567417 |
| Eduardo Luiz | 567662 |
| Miguel Bezerra | 566763 |
| Lucas Mota | 566670 |