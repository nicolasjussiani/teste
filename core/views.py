"""ERP Ecopremium — Views do Core (Login, Dashboard, Notificações)"""
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse
from django.db.models import Count, Q
from django.utils import timezone

from core.models import PerfilUsuario, Notificacao
from recrutamento.models import Vaga, Candidato
from admissional.models import Admissao, Colaborador
from administrativo.models import DemandaAdministrativa
from sesmet.models import RegistroEPI
from compras.models import SolicitacaoMaterial, Material
from financeiro.models import DocumentoFinanceiro, LancamentoERP


from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def login_view(request):
    if request.user.is_authenticated:
        return redirect('dashboard')

    if request.method == 'POST':
        username = request.POST.get('username', '').strip()
        
        # DEMONSTRAÇÃO: Login sem validar senha
        from django.contrib.auth.models import User, update_last_login
        from django.contrib.auth.signals import user_logged_in
        
        try:
            user = User.objects.get(username=username)
            # Bypassa a função login() completamente para evitar QUALQUER escrita no banco
            request.session['_auth_user_id'] = str(user.pk)
            request.session['_auth_user_backend'] = 'django.contrib.auth.backends.ModelBackend'
            request.session['_auth_user_hash'] = user.get_session_auth_hash()
            
            next_url = request.GET.get('next', '/')
            return redirect(next_url)
        except User.DoesNotExist:
            messages.error(request, 'Usuário não encontrado no sistema. Para demonstração, use um usuário existente.')

    return render(request, 'login.html')


def logout_view(request):
    logout(request)
    return redirect('login')


@login_required
def dashboard(request):
    # KPIs agregados
    try:
        perfil = request.user.perfil
    except PerfilUsuario.DoesNotExist:
        perfil = None

    hoje = timezone.now().date()

    # Módulo 1 - Recrutamento
    vagas_abertas = Vaga.objects.exclude(status__in=['preenchida', 'cancelada']).count()
    vagas_em_selecao = Vaga.objects.filter(status='em_selecao').count()
    candidatos_pendentes = Candidato.objects.exclude(etapa_atual__in=['aprovado', 'reprovado', 'desistente']).count()

    # Módulo 2 - Admissional
    admissoes_em_andamento = Admissao.objects.exclude(status__in=['concluido']).count()
    colaboradores_ativos = Colaborador.objects.filter(status='ativo').count()

    # Módulo 3 - Administrativo
    demandas_abertas = DemandaAdministrativa.objects.exclude(status__in=['arquivada']).count()
    demandas_urgentes = DemandaAdministrativa.objects.filter(
        prioridade='urgente').exclude(status='arquivada').count()

    # Módulo 4 - SESMET
    epis_vencidos = RegistroEPI.objects.filter(
        data_validade__lt=hoje, status='ativo').count()
    epis_vencendo_7d = RegistroEPI.objects.filter(
        data_validade__gte=hoje,
        data_validade__lte=hoje + timezone.timedelta(days=7),
        status='ativo').count()

    # Módulo 5 - Compras
    from django.db.models import F as Fcompras
    solicitacoes_pendentes = SolicitacaoMaterial.objects.filter(
        status__in=['pendente', 'em_analise']).count()
    materiais_criticos = Material.objects.filter(
        quantidade_estoque__lte=Fcompras('estoque_minimo')).count()


    # Módulo 6 - Financeiro
    docs_em_auditoria = DocumentoFinanceiro.objects.filter(
        status__in=['recebido', 'em_auditoria']).count()
    lancamentos_pendentes = LancamentoERP.objects.filter(
        status__in=['rascunho', 'em_validacao']).count()

    # Notificações não lidas
    notificacoes_nao_lidas = Notificacao.objects.filter(
        destinatario=request.user, lida=False).count()
    ultimas_notificacoes = Notificacao.objects.filter(
        destinatario=request.user).order_by('-criado_em')[:5]

    # Atividade recente global
    vagas_recentes = Vaga.objects.order_by('-criado_em')[:3]
    admissoes_recentes = Admissao.objects.order_by('-criado_em')[:3]
    demandas_recentes = DemandaAdministrativa.objects.order_by('-criado_em')[:3]

    context = {
        'perfil': perfil,
        'vagas_abertas': vagas_abertas,
        'vagas_em_selecao': vagas_em_selecao,
        'candidatos_pendentes': candidatos_pendentes,
        'admissoes_em_andamento': admissoes_em_andamento,
        'colaboradores_ativos': colaboradores_ativos,
        'demandas_abertas': demandas_abertas,
        'demandas_urgentes': demandas_urgentes,
        'epis_vencidos': epis_vencidos,
        'epis_vencendo_7d': epis_vencendo_7d,
        'solicitacoes_pendentes': solicitacoes_pendentes,
        'docs_em_auditoria': docs_em_auditoria,
        'lancamentos_pendentes': lancamentos_pendentes,
        'notificacoes_nao_lidas': notificacoes_nao_lidas,
        'ultimas_notificacoes': ultimas_notificacoes,
        'vagas_recentes': vagas_recentes,
        'admissoes_recentes': admissoes_recentes,
        'demandas_recentes': demandas_recentes,
        'hoje': hoje,
    }
    return render(request, 'dashboard.html', context)



@login_required
def notificacoes_json(request):
    """API JSON para notificações (AJAX)"""
    notifs = Notificacao.objects.filter(
        destinatario=request.user, lida=False
    ).values('id', 'tipo', 'modulo', 'titulo', 'mensagem', 'url_acao', 'criado_em')
    return JsonResponse({'notificacoes': list(notifs), 'total': notifs.count()})


@login_required
def marcar_notificacao_lida(request, pk):
    if request.method == 'POST':
        Notificacao.objects.filter(pk=pk, destinatario=request.user).update(lida=True)
        return JsonResponse({'status': 'ok'})
    return JsonResponse({'status': 'error'}, status=400)
