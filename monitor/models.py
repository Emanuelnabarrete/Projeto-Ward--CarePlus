from django.db import models

# Create your models here.
from django.db import models

class SessaoWard(models.Model):
    # Dados da sessão
    data_hora        = models.DateTimeField(auto_now_add=True)
    duracao_minutos  = models.FloatField()
    total_registros  = models.IntegerField()

    # Dados brutos agregados
    postura_predominante   = models.CharField(max_length=30)
    score_postura_medio    = models.FloatField()
    piscadas_por_minuto    = models.FloatField()
    emocao_predominante    = models.CharField(max_length=20)

    # Análise Ward
    score_ward         = models.FloatField()
    classificacao_ward = models.CharField(max_length=20)
    resumo             = models.TextField()

    # Análise por fator
    analise_postura  = models.TextField()
    analise_piscadas = models.TextField()
    analise_emocao   = models.TextField()

    # Recomendações
    recomendacao_1 = models.TextField()
    recomendacao_2 = models.TextField(blank=True, null=True)
    recomendacao_3 = models.TextField(blank=True, null=True)

    class Meta:
        ordering = ["-data_hora"]
        verbose_name = "Sessão Ward"
        verbose_name_plural = "Sessões Ward"

    def __str__(self):
        return f"[{self.data_hora.strftime('%d/%m/%Y %H:%M')}] {self.classificacao_ward} — {self.score_ward}/100"