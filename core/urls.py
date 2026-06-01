"""ERP Ecopremium — URLs do Core"""
from django.urls import path
from core import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('api/notificacoes/', views.notificacoes_json, name='notificacoes_json'),
    path('api/notificacoes/<int:pk>/lida/', views.marcar_notificacao_lida, name='marcar_lida'),
]
