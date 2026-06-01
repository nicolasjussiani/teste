"""ERP Ecopremium — Views do Módulo 4: SESMET"""
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from .models import IntegracaoSeguranca, RegistroEPI, OrdemServico
from admissional.models import Colaborador


@login_required
def dashboard_sesmet(request):
    hoje = timezone.now().date()
    epis_vencidos = RegistroEPI.objects.filter(data_validade__lt=hoje, status='ativo')
    epis_vencendo = RegistroEPI.objects.filter(
        data_validade__gte=hoje,
        data_validade__lte=hoje + timezone.timedelta(days=7),
        status='ativo'
    )
    nao_assinados = RegistroEPI.objects.filter(assinado=False, status='ativo')
    return render(request, 'sesmet/dashboard.html', {
        'epis_vencidos': epis_vencidos,
        'epis_vencendo': epis_vencendo,
        'nao_assinados': nao_assinados,
        'total_colaboradores': Colaborador.objects.filter(status='ativo').count(),
        'total_epis_ativos': RegistroEPI.objects.filter(status='ativo').count(),
        'hoje': hoje,
        'PERIODICIDADE': RegistroEPI.PERIODICIDADE,
        'tipos_epi': RegistroEPI.TIPOS_EPI,
    })


@login_required
def registrar_epi(request, colaborador_pk=None):
    colaborador = None
    if colaborador_pk:
        colaborador = get_object_or_404(Colaborador, pk=colaborador_pk)

    if request.method == 'POST':
        colab_pk = request.POST.get('colaborador') or colaborador_pk
        colab = get_object_or_404(Colaborador, pk=colab_pk)
        epi = RegistroEPI(
            colaborador=colab,
            tipo_epi=request.POST['tipo_epi'],
            data_entrega=request.POST['data_entrega'],
            quantidade=int(request.POST.get('quantidade', 1)),
            numero_ca=request.POST.get('numero_ca', ''),
            motivo_substituicao=request.POST.get('motivo_substituicao', 'inicial'),
            registrado_por=request.user,
            obs=request.POST.get('obs', ''),
        )
        epi.save()  # save() calcula validade automaticamente
        messages.success(request,
            f'✅ EPI registrado: {epi.get_tipo_epi_display()} para {colab.nome}. '
            f'Próxima substituição: {epi.data_validade or "Conforme avaliação"}')
        return redirect('dashboard_sesmet')

    colaboradores = Colaborador.objects.filter(status='ativo')
    return render(request, 'sesmet/registrar_epi.html', {
        'colaborador': colaborador,
        'colaboradores': colaboradores,
        'tipos_epi': RegistroEPI.TIPOS_EPI,
        'motivos': RegistroEPI.MOTIVOS_SUBSTITUICAO,
        'periodicidade': RegistroEPI.PERIODICIDADE,
    })


@login_required
def matriz_epis(request):
    """Matriz de validade e controle de EPIs por colaborador"""
    hoje = timezone.now().date()
    colaboradores = Colaborador.objects.filter(status='ativo').prefetch_related('epis')
    return render(request, 'sesmet/matriz_epis.html', {
        'colaboradores': colaboradores,
        'tipos_epi': RegistroEPI.TIPOS_EPI,
        'hoje': hoje,
    })


@login_required
def emitir_os(request, colaborador_pk):
    colaborador = get_object_or_404(Colaborador, pk=colaborador_pk)
    if request.method == 'POST':
        os_count = OrdemServico.objects.count() + 1
        os_num = f'OS-{os_count:04d}'
        os = OrdemServico(
            colaborador=colaborador,
            numero=os_num,
            descricao_riscos=request.POST['descricao_riscos'],
            medidas_preventivas=request.POST['medidas_preventivas'],
            epis_obrigatorios=request.POST['epis_obrigatorios'],
            data_emissao=timezone.now().date(),
            emitido_por=request.user,
        )
        os.save()
        messages.success(request, f'✅ Ordem de Serviço {os_num} emitida para {colaborador.nome}.')
        return redirect('dashboard_sesmet')
    return render(request, 'sesmet/emitir_os.html', {'colaborador': colaborador})


@login_required
def assinar_epi(request, epi_pk):
    """Gateway: Colaborador assinou o EPI?"""
    epi = get_object_or_404(RegistroEPI, pk=epi_pk)
    if request.method == 'POST':
        acao = request.POST.get('acao')
        if acao == 'assinar':
            epi.assinado = True
            epi.save()
            messages.success(request,
                f'✅ GATEWAY: EPI {epi.get_tipo_epi_display()} assinado por {epi.colaborador.nome}. '
                f'Controle contínuo ativado.')
        else:
            messages.warning(request,
                f'⚠️ GATEWAY: Colaborador {epi.colaborador.nome} ainda não assinou o EPI. '
                f'Supervisor deve realizar cobrança imediata.')
        return redirect('dashboard_sesmet')
    return redirect('dashboard_sesmet')
