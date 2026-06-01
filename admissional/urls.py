"""ERP Ecopremium — URLs do Módulo 2: Admissional"""
from django.urls import path
from admissional import views

urlpatterns = [
    path('', views.lista_admissoes, name='lista_admissoes'),
    path('<int:pk>/', views.detalhe_admissao, name='detalhe_admissao'),
    path('<int:pk>/avancar/', views.avancar_admissao, name='avancar_admissao'),
    path('<int:admissao_pk>/documento/<int:doc_pk>/', views.atualizar_documento, name='atualizar_documento'),
    path('colaboradores/', views.lista_colaboradores, name='lista_colaboradores'),
]
