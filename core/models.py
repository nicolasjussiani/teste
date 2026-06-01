"""ERP Ecopremium — Models do Core (Perfil de Usuário)"""
from django.db import models
from django.contrib.auth.models import User


class PerfilUsuario(models.Model):
    PERFIS = [
        ('admin', 'Administrador'),
        ('gestor', 'Gestor'),
        ('rh', 'RH / Departamento Pessoal'),
        ('financeiro', 'Financeiro / Fiscal'),
        ('sesmet', 'SESMET / Segurança do Trabalho'),
        ('compras', 'Compras / Almoxarifado'),
        ('operacional', 'Operacional'),
    ]
    MARCAS = [
        ('eco_premium', 'Eco Premium'),
        ('trip_premium', 'Trip Premium'),
        ('log_premium', 'Log Premium'),
        ('matriz', 'Matriz Ecopremium'),
    ]

    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil')
    perfil = models.CharField(max_length=20, choices=PERFIS, default='operacional')
    marca = models.CharField(max_length=20, choices=MARCAS, default='eco_premium')
    unidade = models.CharField(max_length=100, default='Matriz')
    telefone = models.CharField(max_length=20, blank=True)
    avatar_iniciais = models.CharField(max_length=3, blank=True)
    criado_em = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Perfil de Usuário'
        verbose_name_plural = 'Perfis de Usuários'

    def __str__(self):
        return f"{self.usuario.get_full_name()} ({self.get_perfil_display()})"

    def save(self, *args, **kwargs):
        if not self.avatar_iniciais:
            nome = self.usuario.get_full_name() or self.usuario.username
            partes = nome.split()
            if len(partes) >= 2:
                self.avatar_iniciais = (partes[0][0] + partes[1][0]).upper()
            else:
                self.avatar_iniciais = nome[:2].upper()
        super().save(*args, **kwargs)


class Notificacao(models.Model):
    TIPOS = [
        ('info', 'Informação'),
        ('sucesso', 'Sucesso'),
        ('aviso', 'Aviso'),
        ('erro', 'Erro'),
        ('gateway', 'Gateway de Processo'),
    ]
    MODULOS = [
        ('recrutamento', 'Recrutamento'),
        ('admissional', 'Admissional'),
        ('administrativo', 'Administrativo'),
        ('sesmet', 'SESMET'),
        ('compras', 'Compras'),
        ('financeiro', 'Financeiro'),
        ('sistema', 'Sistema'),
    ]

    destinatario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notificacoes')
    tipo = models.CharField(max_length=20, choices=TIPOS, default='info')
    modulo = models.CharField(max_length=20, choices=MODULOS, default='sistema')
    titulo = models.CharField(max_length=200)
    mensagem = models.TextField()
    lida = models.BooleanField(default=False)
    url_acao = models.CharField(max_length=200, blank=True)
    criado_em = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Notificação'
        verbose_name_plural = 'Notificações'
        ordering = ['-criado_em']

    def __str__(self):
        return f"[{self.get_tipo_display()}] {self.titulo}"
