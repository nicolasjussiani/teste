from django.contrib import admin
from .models import PerfilUsuario, Notificacao

@admin.register(PerfilUsuario)
class PerfilUsuarioAdmin(admin.ModelAdmin):
    list_display = ['usuario', 'perfil', 'marca', 'unidade']
    list_filter = ['perfil', 'marca']

@admin.register(Notificacao)
class NotificacaoAdmin(admin.ModelAdmin):
    list_display = ['destinatario', 'tipo', 'modulo', 'titulo', 'lida', 'criado_em']
    list_filter = ['tipo', 'modulo', 'lida']
