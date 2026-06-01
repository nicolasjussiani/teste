"""ERP Ecopremium — Views do Módulo 1: Recrutamento e Seleção"""
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from .models import Vaga, Candidato
from admissional.models import Admissao, DocumentoAdmissional
from core.models import Notificacao
from django.contrib.auth.models import User


@login_required
def lista_vagas(request):
    vagas = Vaga.objects.all().prefetch_related('candidatos')
    status_filter = request.GET.get('status', '')
    if status_filter:
        vagas = vagas.filter(status=status_filter)
    context = {
        'vagas': vagas,
        'status_filter': status_filter,
        'status_choices': Vaga.STATUS_CHOICES,
        'total_vagas': Vaga.objects.count(),
        'vagas_abertas': Vaga.objects.exclude(status__in=['preenchida', 'cancelada']).count(),
    }
    return render(request, 'recrutamento/lista_vagas.html', context)


@login_required
def nova_vaga(request):
    if request.method == 'POST':
        # Gateway 1: Validar campos obrigatórios
        campos_obrigatorios = [
            'nome_vaga', 'quantidade_colaboradores', 'cidade', 'unidade',
            'perfil_desejado', 'atividades', 'horario_trabalho', 'tipo_contratacao',
            'valor_salario', 'previsao_inicio', 'motivo_solicitacao', 'gestor_responsavel'
        ]
        erros = []
        for campo in campos_obrigatorios:
            if not request.POST.get(campo, '').strip():
                erros.append(campo)

        if erros:
            messages.error(request,
                f'⚠️ GATEWAY: Informações incompletas! {len(erros)} campo(s) obrigatório(s) não preenchido(s).')
            return render(request, 'recrutamento/nova_vaga.html', {
                'post_data': request.POST,
                'erros': erros,
                'tipo_choices': Vaga.TIPO_CONTRATACAO,
            })

        vaga = Vaga(
            nome_vaga=request.POST['nome_vaga'],
            quantidade_colaboradores=int(request.POST['quantidade_colaboradores']),
            cidade=request.POST['cidade'],
            unidade=request.POST['unidade'],
            perfil_desejado=request.POST['perfil_desejado'],
            atividades=request.POST['atividades'],
            horario_trabalho=request.POST['horario_trabalho'],
            tipo_contratacao=request.POST['tipo_contratacao'],
            valor_salario=request.POST['valor_salario'],
            previsao_inicio=request.POST['previsao_inicio'],
            exige_experiencia=request.POST.get('exige_experiencia') == 'on',
            descricao_experiencia=request.POST.get('descricao_experiencia', ''),
            motivo_solicitacao=request.POST['motivo_solicitacao'],
            gestor_responsavel=request.POST['gestor_responsavel'],
            gestor_usuario=request.user,
            status='em_selecao',
        )
        vaga.save()
        messages.success(request, f'✅ Vaga "{vaga.nome_vaga}" criada com sucesso! Aguardando candidatos.')
        return redirect('detalhe_vaga', pk=vaga.pk)

    return render(request, 'recrutamento/nova_vaga.html', {
        'tipo_choices': Vaga.TIPO_CONTRATACAO,
    })


@login_required
def detalhe_vaga(request, pk):
    vaga = get_object_or_404(Vaga, pk=pk)
    candidatos = vaga.candidatos.all()
    candidatos_por_etapa = {
        'triagem': candidatos.filter(etapa_atual='triagem'),
        'avaliacao_dp': candidatos.filter(etapa_atual='avaliacao_dp'),
        'entrevista_final': candidatos.filter(etapa_atual='entrevista_final'),
        'aprovado': candidatos.filter(etapa_atual='aprovado'),
        'reprovado': candidatos.filter(etapa_atual='reprovado'),
    }
    return render(request, 'recrutamento/detalhe_vaga.html', {
        'vaga': vaga,
        'candidatos': candidatos,
        'candidatos_por_etapa': candidatos_por_etapa,
    })


@login_required
def adicionar_candidato(request, vaga_pk):
    vaga = get_object_or_404(Vaga, pk=vaga_pk)
    if request.method == 'POST':
        candidato = Candidato(
            vaga=vaga,
            nome=request.POST['nome'],
            email=request.POST['email'],
            telefone=request.POST['telefone'],
            cpf=request.POST.get('cpf', ''),
            curriculum_obs=request.POST.get('curriculum_obs', ''),
            etapa_atual='triagem',
        )
        candidato.save()
        messages.success(request, f'✅ Candidato {candidato.nome} adicionado à vaga {vaga.nome_vaga}.')
        return redirect('detalhe_vaga', pk=vaga_pk)
    return render(request, 'recrutamento/adicionar_candidato.html', {'vaga': vaga})


@login_required
def avancar_etapa(request, candidato_pk):
    """Gateway: avança candidato para próxima etapa ou reprova"""
    candidato = get_object_or_404(Candidato, pk=candidato_pk)
    if request.method == 'POST':
        acao = request.POST.get('acao')
        obs = request.POST.get('obs', '')
        etapas = ['triagem', 'avaliacao_dp', 'entrevista_final', 'aprovado']

        if acao == 'reprovar':
            candidato.etapa_atual = 'reprovado'
            candidato.aprovado = False
            candidato.save()
            messages.warning(request,
                f'❌ GATEWAY: Candidato {candidato.nome} reprovado. Processo retorna para nova seleção.')

        elif acao == 'avancar':
            idx = etapas.index(candidato.etapa_atual) if candidato.etapa_atual in etapas else 0
            if idx < len(etapas) - 1:
                candidato.etapa_atual = etapas[idx + 1]
                if candidato.etapa_atual == 'avaliacao_dp':
                    candidato.avaliacao_comportamental = obs
                elif candidato.etapa_atual == 'entrevista_final':
                    candidato.avaliacao_comportamental = obs
                elif candidato.etapa_atual == 'aprovado':
                    candidato.aprovado = True
                    candidato.resultado_entrevista = obs
                    # GATEWAY SIM → Dispara gatilho automático para Módulo 2
                    _disparar_admissao(candidato, request.user)
                candidato.save()
                messages.success(request, f'✅ Candidato {candidato.nome} avançou para: {candidato.get_etapa_atual_display()}')
            else:
                messages.info(request, 'Candidato já está na etapa final.')

        return redirect('detalhe_vaga', pk=candidato.vaga.pk)

    return render(request, 'recrutamento/gateway_candidato.html', {'candidato': candidato})


def _disparar_admissao(candidato, usuario):
    """Gatilho automático: candidato aprovado → cria processo admissional no Módulo 2"""
    if not candidato.encaminhado_admissao:
        admissao = Admissao(
            candidato_nome=candidato.nome,
            candidato_email=candidato.email,
            candidato_telefone=candidato.telefone,
            vaga_nome=candidato.vaga.nome_vaga,
            unidade_destino=candidato.vaga.unidade,
            status='aguardando_documentos',
            responsavel_rh=usuario,
        )
        admissao.save()

        # Criar checklist de documentos automaticamente
        tipos_doc = [t[0] for t in DocumentoAdmissional.TIPOS]
        for tipo in tipos_doc:
            DocumentoAdmissional.objects.create(admissao=admissao, tipo=tipo, status='pendente')

        candidato.encaminhado_admissao = True
        candidato.save()

        # Notificar RH
        for rh_user in User.objects.filter(perfil__perfil='rh'):
            Notificacao.objects.create(
                destinatario=rh_user,
                tipo='gateway',
                modulo='admissional',
                titulo=f'🔔 Novo candidato aprovado: {candidato.nome}',
                mensagem=f'Candidato {candidato.nome} foi aprovado para a vaga "{candidato.vaga.nome_vaga}" '
                         f'({candidato.vaga.unidade}). Processo admissional criado automaticamente.',
                url_acao=f'/admissional/{admissao.pk}/',
            )
