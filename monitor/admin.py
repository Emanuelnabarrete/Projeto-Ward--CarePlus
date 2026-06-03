from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import SessaoWard

@admin.register(SessaoWard)
class SessaoWardAdmin(admin.ModelAdmin):
    list_display  = ["data_hora", "classificacao_ward", "score_ward", "postura_predominante", "emocao_predominante", "duracao_minutos"]
    list_filter   = ["classificacao_ward", "postura_predominante", "emocao_predominante"]
    search_fields = ["resumo", "classificacao_ward"]
    readonly_fields = ["data_hora"]