# Ward — Monitor de Bem-Estar Ocupacional

Sistema de monitoramento de postura, piscadas e emoção para trabalhadores em home office, com análise de IA local e dashboard web.

---

## Sobre o projeto

O Ward utiliza a webcam do computador para monitorar em tempo real três indicadores biométricos durante a jornada de trabalho:

- **Postura corporal** — detecta projeção de cabeça, inclinação e desalinhamento de ombros
- **Frequência de piscadas** — monitora a saúde ocular com base no padrão médico de 15–20 piscadas/min
- **Estado emocional** — classifica a emoção dominante via reconhecimento facial

Ao final de cada sessão, uma IA local (LLaMA 3 via Ollama) analisa os dados, calcula um Score Ward de bem-estar (0–100) e gera recomendações personalizadas de saúde ocupacional. Os resultados são salvos no banco de dados e exibidos em um dashboard web.

---

## Como funciona

### Três modelos rodando em paralelo

| Modelo | Biblioteca | Função |
|--------|-----------|--------|
| Pose corporal | MediaPipe Pose | Detecta 33 landmarks do corpo — ombros, orelhas, nariz |
| Detecção de piscadas | MediaPipe FaceMesh + EAR | Mapeia 478 pontos do rosto e calcula a abertura dos olhos |
| Reconhecimento de emoção | FER + TensorFlow | Classifica 7 emoções em thread paralela a cada 250ms |

### Calibração individual

A cada sessão, o sistema passa por uma calibração de 60 frames onde o usuário senta reto para estabelecer sua baseline individual. O score de postura é calculado como desvio relativo a essa baseline — não a um padrão genérico.

### Fórmulas

**EAR — Eye Aspect Ratio (Piscadas)**
```
EAR = (dist(p2,p6) + dist(p3,p5)) / (2 × dist(p1,p4))
EAR < 0.20 → piscada detectada
```

**Score de Postura**
```
score = (desvio_cabeça × 50) + (inclinação_cabeça × 20) + (inclinação_ombro × 15) + (queda_nariz × 15)
```

**Saúde Ocular**
```
score = 100 - |piscadas_por_min - 17.5| × 4
17.5 = centro do intervalo ideal médico (15–20/min)
```

**Score Ward Final**
```
score_final = (postura × 0.50) + (piscadas × 0.30) + (emoção × 0.20)
```

| Classificação | Score |
|---------------|-------|
| RUIM | 0 – 40 |
| MEDIANO | 41 – 70 |
| MUITO BOM | 71 – 100 |

---

## Fluxo do sistema

```
Webcam
  ↓
MediaPipe Pose       → métricas de postura → score 0–100
MediaPipe FaceMesh   → EAR → contagem de piscadas
FER + TensorFlow     → emoção dominante (thread paralela)
  ↓
Registro a cada 10s → lista de dados em memória
  ↓
Ao encerrar (Q ou Ctrl+C)
  ↓
Pandas → CSV
OpenPyXL → Excel formatado
TXT → relatório textual
  ↓
Ollama (LLaMA 3) → análise Ward em JSON (100% local, sem internet)
  ↓
Django ORM → salva no SQLite
  ↓
Dashboard → http://127.0.0.1:8000
```

---

## Estrutura do projeto

```
Ward/
├── core/                 # Configurações do Django
├── monitor/              # Models, views e templates do dashboard
│   └── templates/
│       └── monitor/
│           └── dashboard.html
├── data/                 # Datasets de teste e ataque
│   ├── attack_dataset.json
│   └── test_dataset.json
├── outputs/              # Arquivos gerados pelo sistema (.csv, .xlsx, .txt)
├── prompts/              # System prompt do Ward
│   └── system_prompt.txt
├── .env                  # Variáveis de ambiente (não sobe ao GitHub)
├── .gitignore
├── main.py               # Código principal do monitor
├── manage.py             # CLI do Django
├── requirements.txt
├── run.bat               # Inicia o sistema com um clique
└── setup.bat             # Instala tudo com um clique
```

---

## Pré-requisitos

- Python 3.11
- Webcam conectada
- Windows
- [Ollama](https://ollama.com/download) instalado

---

## Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/Emanuelnabarrete/Ward---GS-.git
cd Ward---GS-
```

```bash
# 2. Instale o modelo de IA
ollama pull llama3
ollama serve
```

```bat
# 3. Configure o ambiente
setup.bat
```

O `setup.bat` cria o ambiente virtual, instala as dependências, gera o `.env` com valores padrão, roda as migrations e cria o superusuário do painel admin.

```bat
# 4. Inicie o sistema
run.bat
```

O `run.bat` abre dois terminais — um para o Django e outro para o monitor de câmera.

---

## Configuração (.env)

O `.env` é criado automaticamente pelo `setup.bat`. Para personalizar:

```env
INTERVALO_REGISTRO=10         # Segundos entre cada registro
EAR_THRESH=0.20               # Limiar EAR para detecção de piscada
FRAMES_FECHADO=2              # Frames consecutivos para confirmar piscada
CAMERA_INDEX=0                # Índice da câmera (0 = padrão)
CAMERA_WIDTH=1280
CAMERA_HEIGHT=720
CALIB_TOTAL=60                # Frames para calibração inicial
ALPHA=0.15                    # Suavização do filtro exponencial
OLLAMA_HOST=http://localhost:11434
MODEL=llama3:latest
```

---

## Uso

| Tecla | Ação |
|-------|------|
| `R` | Recalibrar postura |
| `Q` | Encerrar e gerar relatório |

Ao encerrar, três arquivos são gerados em `outputs/`:

- `postura_YYYYMMDD_HHMMSS.csv` — dados brutos de cada registro
- `postura_YYYYMMDD_HHMMSS.txt` — relatório textual com estatísticas
- `postura_YYYYMMDD_HHMMSS.xlsx` — planilha formatada

---

## Dashboard Web

Acesse em `http://127.0.0.1:8000` após rodar o `run.bat`.

- **Score Ward — Semana** — média acumulada das sessões da semana
- **Saúde Ocular** — score baseado na frequência de piscadas
- **Qualidade Postural** — score baseado no desvio de postura
- **Gráfico diário** — evolução do score ao longo da semana
- **Recomendações** — geradas pela IA com base na última sessão
- **Fale com um Especialista** — integração com a [CarePlus](https://www.careplus.com.br/)

Painel admin disponível em `http://127.0.0.1:8000/admin`.

---

## Dependências principais

| Biblioteca | Uso |
|------------|-----|
| `mediapipe` | Pose + FaceMesh |
| `fer` + `tf-keras` | Reconhecimento de emoções |
| `opencv-python` | Captura e renderização de vídeo |
| `openpyxl` | Geração de planilhas Excel |
| `pandas` | Manipulação de dados |
| `django` | Framework web + ORM + dashboard |
| `requests` | Comunicação com o Ollama |
| `python-dotenv` | Leitura do `.env` |

---

## Privacidade

O sistema roda 100% localmente. Nenhum dado biométrico é enviado para servidores externos. O modelo de IA roda via Ollama na própria máquina, sem internet.

---

## Integrantes

| Nome | RM |
|------|----|
| Emanuel Nabarrete | 566931 |
| Luiz Eduardo | 567417 |
| Eduardo Luiz | 567662 |
| Miguel Bezerra | 566763 |
| Lucas Mota | 566670 |
