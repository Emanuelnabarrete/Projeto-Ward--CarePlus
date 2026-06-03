from django.shortcuts import render
from django.utils import timezone
from datetime import timedelta
from .models import SessaoWard

def calcular_saude_ocular(ppm):
    if ppm >= 15:   return min(100, max(0, round(100 - abs(ppm - 17.5) * 4)))
    elif ppm >= 8:  return round(ppm / 15 * 70)
    elif ppm >= 3:  return round(ppm / 8 * 40)
    else:           return max(0, round(ppm * 5))


def calcular_score_postura_card(score_postura_medio):
    return max(0, round(100 - score_postura_medio))

def classificar_ward(score):
    if score >= 71:  return "MUITO BOM"
    elif score >= 41: return "MEDIANO"
    else:             return "RUIM"

def dashboard(request):
    hoje = timezone.localtime(timezone.now())
    inicio_semana = hoje - timedelta(days=30)
    sessoes_semana = SessaoWard.objects.filter(data_hora__gte=inicio_semana)
    todas_sessoes  = SessaoWard.objects.all()

    saude_ocular       = 0
    score_postura      = 0
    score_ward_semana  = 0
    classif_semana     = "—"

    if sessoes_semana.exists():
        # Saúde ocular — filtra sessões com piscadas válidas
        sessoes_validas = [s for s in sessoes_semana if s.piscadas_por_minuto <= 60]
        if sessoes_validas:
            media_ppm = sum(s.piscadas_por_minuto for s in sessoes_validas) / len(sessoes_validas)
            saude_ocular = calcular_saude_ocular(media_ppm)

        # Postura e score — usa todas as sessões
        media_postura = sum(s.score_postura_medio for s in sessoes_semana) / sessoes_semana.count()
        score_postura = calcular_score_postura_card(media_postura)
        score_ward_semana = round(sum(s.score_ward for s in sessoes_semana) / sessoes_semana.count(), 1)
        classif_semana = classificar_ward(score_ward_semana)


    # Gráfico diário
    labels, scores = [], []
    for i in range(6, -1, -1):
        dia = hoje - timedelta(days=i)
        inicio_dia = dia.replace(hour=0, minute=0, second=0, microsecond=0)
        fim_dia    = dia.replace(hour=23, minute=59, second=59, microsecond=999999)
        sessoes_dia = todas_sessoes.filter(data_hora__range=(inicio_dia, fim_dia))
        labels.append(dia.strftime("%d/%m"))
        scores.append(
            round(sum(s.score_ward for s in sessoes_dia) / sessoes_dia.count(), 1)
            if sessoes_dia.exists() else "null"
        )

    ultima = todas_sessoes.first()
    recomendacoes = []
    if ultima:
        if ultima.recomendacao_1: recomendacoes.append(ultima.recomendacao_1)
        if ultima.recomendacao_2: recomendacoes.append(ultima.recomendacao_2)
        if ultima.recomendacao_3: recomendacoes.append(ultima.recomendacao_3)

    context = {
        "saude_ocular":      saude_ocular,
        "score_postura":     score_postura,
        "score_ward_semana": score_ward_semana,
        "classif_semana":    classif_semana,
        "labels":            labels,
        "scores":            scores,
        "recomendacoes":     recomendacoes,
        "ultima":            ultima,
        "total_sessoes":     todas_sessoes.count(),
    }
    return render(request, "monitor/dashboard.html", context)