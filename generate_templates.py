import os

BASE_DIR = r"C:\Users\Default.DESKTOP-VJ7TKO1\.gemini\antigravity\scratch\erp-ecopremium\templates"

templates = {
    r"admissional\atualizar_documento.html": """{% extends 'base.html' %}
{% block title %}Avaliar Documento — ERP Ecopremium{% endblock %}
{% block nav_admissional %}active{% endblock %}
{% block topbar_title %}Gateway — Avaliação de Documento{% endblock %}
{% block content %}
<a href="{% url 'detalhe_admissao' admissao.pk %}" style="color:var(--text-muted);font-size:0.82rem;text-decoration:none;display:block;margin-bottom:16px;">← Voltar à Admissão</a>
<div class="card" style="max-width:600px;">
  <div style="margin-bottom:20px;">
    <div style="font-size:1.1rem;font-weight:800;">{{ doc.get_tipo_display }}</div>
    <div style="font-size:0.82rem;color:var(--text-muted);">{{ admissao.candidato_nome }}</div>
    <div style="margin-top:8px;"><span class="badge badge-info">Status: {{ doc.get_status_display }}</span></div>
  </div>

  <div class="gateway-box">
    <div class="gateway-question">Documento correto e válido?</div>
    <form method="post">
      {% csrf_token %}
      <div class="form-group">
        <label class="form-label">Status</label>
        <select name="status" class="form-control">
          {% for val, label in doc.STATUS %}
          <option value="{{ val }}" {% if doc.status == val %}selected{% endif %}>{{ label }}</option>
          {% endfor %}
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Observação</label>
        <textarea name="observacao" class="form-control" rows="3">{{ doc.observacao }}</textarea>
      </div>
      <div class="gateway-actions">
        <button type="submit" class="btn btn-success btn-lg">✅ Salvar Avaliação</button>
      </div>
    </form>
  </div>
</div>
{% endblock %}""",

    r"admissional\lista_colaboradores.html": """{% extends 'base.html' %}
{% block title %}Colaboradores Ativos — ERP Ecopremium{% endblock %}
{% block nav_colaboradores %}active{% endblock %}
{% block topbar_title %}Colaboradores{% endblock %}
{% block content %}
<div class="module-banner mod-banner-2">
  <div class="mod-title">🏢 Colaboradores Ativos</div>
  <div class="mod-desc">Quadro geral de colaboradores registrados e ativos no sistema</div>
</div>
{% if colaboradores %}
<div class="table-wrap">
  <table>
    <thead>
      <tr><th>Nome</th><th>CPF</th><th>Cargo</th><th>Unidade</th><th>Marca</th><th>Admissão</th><th>Status</th></tr>
    </thead>
    <tbody>
      {% for collab in colaboradores %}
      <tr>
        <td><div style="font-weight:600;">{{ collab.nome }}</div></td>
        <td>{{ collab.cpf }}</td>
        <td>{{ collab.cargo }}</td>
        <td>{{ collab.unidade }}</td>
        <td>{{ collab.get_marca_display }}</td>
        <td>{{ collab.data_admissao|date:'d/m/Y' }}</td>
        <td><span class="badge badge-success">Ativo</span></td>
      </tr>
      {% endfor %}
    </tbody>
  </table>
</div>
{% else %}
<div class="card"><div class="empty-state"><p>Nenhum colaborador encontrado.</p></div></div>
{% endif %}
{% endblock %}""",

    r"administrativo\lista_demandas.html": """{% extends 'base.html' %}
{% block title %}Central Administrativa — ERP Ecopremium{% endblock %}
{% block nav_administrativo %}active{% endblock %}
{% block topbar_title %}Central Administrativa{% endblock %}
{% block content %}
<div class="module-banner mod-banner-3">
  <div class="mod-title">🗂️ Central Administrativa</div>
  <div class="mod-desc">Gestão de contratos, demandas, reembolsos e serviços</div>
</div>
<div class="page-header">
  <div class="flex gap-3">
    <div class="kpi-card kpi-mod3" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ demandas_abertas }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Demandas Abertas</div>
    </div>
    <div class="kpi-card kpi-mod3" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ demandas_urgentes }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Urgentes</div>
    </div>
  </div>
  <a href="{% url 'nova_demanda' %}" class="btn btn-mod3">+ Nova Demanda</a>
</div>
{% if demandas %}
<div class="table-wrap">
  <table>
    <thead><tr><th>ID</th><th>Título</th><th>Requisitante</th><th>Prioridade</th><th>Status</th><th>Data</th><th>Ação</th></tr></thead>
    <tbody>
      {% for dem in demandas %}
      <tr>
        <td style="color:var(--text-muted);">#{{ dem.pk }}</td>
        <td><div style="font-weight:600;">{{ dem.titulo }}</div><div style="font-size:0.74rem;color:var(--text-muted);">{{ dem.get_tipo_display }}</div></td>
        <td>{{ dem.requisitante }}</td>
        <td><span class="badge badge-{{ dem.get_prioridade_color }}">{{ dem.get_prioridade_display }}</span></td>
        <td><span class="badge badge-info">{{ dem.get_status_display }}</span></td>
        <td>{{ dem.criado_em|date:"d/m/Y" }}</td>
        <td><a href="{% url 'detalhe_demanda' dem.pk %}" class="btn btn-sm btn-outline">Ver →</a></td>
      </tr>
      {% endfor %}
    </tbody>
  </table>
</div>
{% endif %}
{% endblock %}""",

    r"administrativo\nova_demanda.html": """{% extends 'base.html' %}
{% block title %}Nova Demanda — ERP Ecopremium{% endblock %}
{% block nav_administrativo %}active{% endblock %}
{% block topbar_title %}Nova Demanda{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">🗂️ Abrir Nova Demanda Administrativa</div>
  <form method="post">
    {% csrf_token %}
    <div class="form-group">
      <label class="form-label">Tipo de Demanda</label>
      <select name="tipo" class="form-control" required>
        {% for val, label in tipo_choices %}
        <option value="{{ val }}">{{ label }}</option>
        {% endfor %}
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Título</label>
      <input type="text" name="titulo" class="form-control" required>
    </div>
    <div class="form-group">
      <label class="form-label">Descrição</label>
      <textarea name="descricao" class="form-control" rows="4" required></textarea>
    </div>
    <div class="form-grid">
      <div class="form-group">
        <label class="form-label">Requisitante</label>
        <input type="text" name="requisitante" class="form-control" value="{{ user.get_full_name|default:user.username }}" required>
      </div>
      <div class="form-group">
        <label class="form-label">Prioridade</label>
        <select name="prioridade" class="form-control" required>
          <option value="baixa">Baixa</option>
          <option value="media" selected>Média</option>
          <option value="alta">Alta</option>
          <option value="urgente">Urgente</option>
        </select>
      </div>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'lista_demandas' %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod3">Salvar Demanda</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"administrativo\detalhe_demanda.html": """{% extends 'base.html' %}
{% block title %}Detalhe da Demanda — ERP Ecopremium{% endblock %}
{% block nav_administrativo %}active{% endblock %}
{% block topbar_title %}Detalhe da Demanda{% endblock %}
{% block content %}
<a href="{% url 'lista_demandas' %}" style="color:var(--text-muted);font-size:0.82rem;text-decoration:none;display:block;margin-bottom:16px;">← Voltar às Demandas</a>
<div class="grid-2">
  <div class="card">
    <div class="flex justify-between items-start mb-4">
      <div>
        <div class="card-title">{{ demanda.titulo }}</div>
        <div style="font-size:0.82rem;color:var(--text-muted);">{{ demanda.get_tipo_display }}</div>
      </div>
      <span class="badge badge-info">{{ demanda.get_status_display }}</span>
    </div>
    <div style="font-size:0.86rem;line-height:1.6;margin-bottom:20px;">{{ demanda.descricao }}</div>
    <div class="divider"></div>
    <div class="form-grid">
      <div><div class="form-label">Requisitante</div><div style="font-size:0.86rem;font-weight:600;">{{ demanda.requisitante }}</div></div>
      <div><div class="form-label">Prioridade</div><div style="font-size:0.86rem;font-weight:600;"><span class="badge badge-{{ demanda.get_prioridade_color }}">{{ demanda.get_prioridade_display }}</span></div></div>
      <div><div class="form-label">Abertura</div><div style="font-size:0.86rem;font-weight:600;">{{ demanda.criado_em|date:"d/m/Y H:i" }}</div></div>
    </div>
  </div>
  <div class="card">
    <div class="card-title mb-4">🔄 Atualizar Status</div>
    <div class="gateway-box">
      <div class="gateway-question">Processo finalizado corretamente?</div>
      <form method="post" action="{% url 'atualizar_status_demanda' demanda.pk %}">
        {% csrf_token %}
        <div class="form-group">
          <label class="form-label">Novo Status</label>
          <select name="status" class="form-control">
            {% for val, label in demanda.STATUS %}
            <option value="{{ val }}" {% if demanda.status == val %}selected{% endif %}>{{ label }}</option>
            {% endfor %}
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">Motivo (se rejeição)</label>
          <textarea name="motivo_rejeicao" class="form-control" rows="2">{{ demanda.motivo_rejeicao }}</textarea>
        </div>
        <button type="submit" class="btn btn-mod3" style="width:100%;">Atualizar Status</button>
      </form>
    </div>
  </div>
</div>
{% endblock %}""",

    r"sesmet\dashboard.html": """{% extends 'base.html' %}
{% block title %}Dashboard SESMET — ERP Ecopremium{% endblock %}
{% block nav_sesmet %}active{% endblock %}
{% block topbar_title %}Dashboard SESMET{% endblock %}
{% block content %}
<div class="module-banner mod-banner-4">
  <div class="mod-title">🦺 SESMET — Segurança do Trabalho</div>
  <div class="mod-desc">Gestão de EPIs, Ordens de Serviço, Integração e Matriz de Risco</div>
</div>
<div class="page-header">
  <div class="flex gap-3">
    <div class="kpi-card kpi-mod4" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ total_epis_ativos }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">EPIs Ativos</div>
    </div>
    <div class="kpi-card kpi-mod4" style="padding:14px 20px;min-width:140px; border-color:{% if epis_vencidos %}var(--danger){% else %}transparent{% endif %};">
      <div style="font-size:1.6rem;font-weight:800; color:{% if epis_vencidos %}var(--danger){% endif %};">{{ epis_vencidos|length }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">EPIs Vencidos</div>
    </div>
  </div>
  <div class="flex gap-2">
    <a href="{% url 'matriz_epis' %}" class="btn btn-outline btn-sm">Matriz de EPIs</a>
    <a href="{% url 'registrar_epi' %}" class="btn btn-mod4 btn-sm">+ Registrar Entrega</a>
  </div>
</div>
<div class="card mb-4">
  <div class="card-title">🚨 EPIs Vencidos</div>
  {% if epis_vencidos %}
  <div class="table-wrap">
    <table>
      <thead><tr><th>Colaborador</th><th>Tipo EPI</th><th>Data Entrega</th><th>Data Vencimento</th><th>Dias Vencido</th><th>Ação</th></tr></thead>
      <tbody>
        {% for epi in epis_vencidos %}
        <tr>
          <td><div style="font-weight:600;">{{ epi.colaborador.nome }}</div></td>
          <td>{{ epi.get_tipo_epi_display }}</td>
          <td>{{ epi.data_entrega|date:"d/m/Y" }}</td>
          <td style="color:var(--danger);font-weight:600;">{{ epi.data_vencimento|date:"d/m/Y" }}</td>
          <td><span class="badge badge-danger">{{ epi.dias_vencido }} dias</span></td>
          <td><a href="{% url 'registrar_epi_colaborador' epi.colaborador.pk %}" class="btn btn-sm btn-outline">Substituir</a></td>
        </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
  {% else %}
  <div class="empty-state"><p>✅ Nenhum EPI vencido no momento.</p></div>
  {% endif %}
</div>
{% endblock %}""",

    r"sesmet\registrar_epi.html": """{% extends 'base.html' %}
{% block title %}Registrar Entrega de EPI — ERP Ecopremium{% endblock %}
{% block nav_sesmet %}active{% endblock %}
{% block topbar_title %}Registrar EPI{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">🦺 Registrar Entrega de EPI</div>
  <form method="post">
    {% csrf_token %}
    <div class="form-group">
      <label class="form-label">Colaborador</label>
      <select name="colaborador" class="form-control" required>
        {% for col in colaboradores %}
        <option value="{{ col.pk }}" {% if pre_colab and pre_colab.pk == col.pk %}selected{% endif %}>{{ col.nome }} - {{ col.cargo }}</option>
        {% endfor %}
      </select>
    </div>
    <div class="form-grid">
      <div class="form-group">
        <label class="form-label">Tipo de EPI</label>
        <select name="tipo_epi" class="form-control" required>
          {% for val, label in tipos_epi %}
          <option value="{{ val }}">{{ label }}</option>
          {% endfor %}
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Data de Entrega</label>
        <input type="date" name="data_entrega" class="form-control" value="{{ hoje|date:'Y-m-d' }}" required>
      </div>
      <div class="form-group">
        <label class="form-label">Quantidade</label>
        <input type="number" name="quantidade" class="form-control" value="1" min="1" required>
      </div>
      <div class="form-group">
        <label class="form-label">Número do CA</label>
        <input type="text" name="numero_ca" class="form-control">
      </div>
    </div>
    <div class="form-group">
      <label class="form-label">Motivo</label>
      <select name="motivo_substituicao" class="form-control" required>
        {% for val, label in motivos_epi %}
        <option value="{{ val }}">{{ label }}</option>
        {% endfor %}
      </select>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'dashboard_sesmet' %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod4">Registrar Entrega</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"sesmet\matriz_epis.html": """{% extends 'base.html' %}
{% block title %}Matriz de EPIs — ERP Ecopremium{% endblock %}
{% block nav_sesmet %}active{% endblock %}
{% block topbar_title %}Matriz de EPIs{% endblock %}
{% block content %}
<div class="card">
  <div class="card-title mb-4">📊 Matriz de EPIs por Colaborador</div>
  <div class="table-wrap">
    <table class="epi-matrix-table">
      <thead>
        <tr>
          <th>Colaborador</th><th>Cargo</th>
          {% for k, label in epi_labels.items %}<th>{{ label }}</th>{% endfor %}
        </tr>
      </thead>
      <tbody>
        {% for mat in matriz %}
        <tr>
          <td><div style="font-weight:600;">{{ mat.colaborador.nome }}</div></td>
          <td><span style="font-size:0.75rem;color:var(--text-muted);">{{ mat.colaborador.cargo }}</span></td>
          {% for k, status in mat.epis.items %}
          <td style="text-align:center;">
            {% if status.vencido %}
            <span class="epi-status-danger" title="Vencido em {{ status.data_vencimento|date:'d/m/Y' }}">❌</span>
            {% elif status.tem_registro %}
            <span class="epi-status-ok" title="Validade: {{ status.data_vencimento|date:'d/m/Y' }}">✅</span>
            {% else %}
            <span class="epi-status-none">—</span>
            {% endif %}
          </td>
          {% endfor %}
        </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
{% endblock %}""",

    r"sesmet\emitir_os.html": """{% extends 'base.html' %}
{% block title %}Emitir OS — ERP Ecopremium{% endblock %}
{% block nav_sesmet %}active{% endblock %}
{% block topbar_title %}Emitir Ordem de Serviço{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">📄 Emitir OS de Segurança</div>
  <form method="post">
    {% csrf_token %}
    <div class="form-group">
      <label class="form-label">Colaborador</label>
      <input type="text" class="form-control" value="{{ colaborador.nome }} — {{ colaborador.cargo }}" disabled>
    </div>
    <div class="form-group">
      <label class="form-label">Descrição dos Riscos</label>
      <textarea name="descricao_riscos" class="form-control" rows="4" required></textarea>
    </div>
    <div class="form-group">
      <label class="form-label">Medidas Preventivas</label>
      <textarea name="medidas_preventivas" class="form-control" rows="4" required></textarea>
    </div>
    <div class="form-group">
      <label class="form-label">EPIs Obrigatórios</label>
      <textarea name="epis_obrigatorios" class="form-control" rows="3" required></textarea>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'dashboard_sesmet' %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod4">Emitir Ordem de Serviço</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"compras\painel.html": """{% extends 'base.html' %}
{% block title %}Painel de Compras — ERP Ecopremium{% endblock %}
{% block nav_compras %}active{% endblock %}
{% block topbar_title %}Compras e Almoxarifado{% endblock %}
{% block content %}
<div class="module-banner mod-banner-5">
  <div class="mod-title">🛒 Compras / Almoxarifado</div>
  <div class="mod-desc">Gestão de estoque, solicitações de materiais e pedidos de compra</div>
</div>
<div class="page-header">
  <div class="flex gap-3">
    <div class="kpi-card kpi-mod5" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ total_materiais }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Total Materiais</div>
    </div>
    <div class="kpi-card kpi-mod5" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800; color:{% if total_estoque_critico %}var(--danger){% endif %};">{{ total_estoque_critico }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Estoque Crítico</div>
    </div>
    <div class="kpi-card kpi-mod5" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ solicitacoes_pendentes|length }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Solicitações Pend.</div>
    </div>
  </div>
  <div class="flex gap-2">
    <a href="{% url 'lista_materiais' %}" class="btn btn-outline btn-sm">Estoque Geral</a>
    <a href="{% url 'nova_solicitacao' %}" class="btn btn-mod5 btn-sm">+ Solicitar Material</a>
  </div>
</div>
<div class="grid-2">
  <div class="card">
    <div class="card-title">⚠️ Estoque Crítico</div>
    {% if estoque_critico %}
    <div class="table-wrap mt-3">
      <table>
        <thead><tr><th>Cód</th><th>Material</th><th>Atual</th><th>Min</th><th>Ação</th></tr></thead>
        <tbody>
          {% for mat in estoque_critico %}
          <tr>
            <td style="font-size:0.75rem;color:var(--text-muted);">{{ mat.codigo }}</td>
            <td style="font-weight:600;">{{ mat.nome }}</td>
            <td style="color:var(--danger);font-weight:800;">{{ mat.quantidade_estoque }}</td>
            <td style="color:var(--text-muted);">{{ mat.estoque_minimo }}</td>
            <td><a href="{% url 'nova_solicitacao' %}?material={{ mat.pk }}" class="btn btn-sm btn-outline">Solicitar</a></td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
    {% else %}
    <div class="empty-state"><p>✅ Nenhum material em estoque crítico.</p></div>
    {% endif %}
  </div>
  <div class="card">
    <div class="card-title">📋 Solicitações Pendentes</div>
    {% if solicitacoes_pendentes %}
    <div class="table-wrap mt-3">
      <table>
        <thead><tr><th>Material</th><th>Qtd</th><th>Status</th><th>Ação</th></tr></thead>
        <tbody>
          {% for sol in solicitacoes_pendentes %}
          <tr>
            <td style="font-weight:600;">{{ sol.material.nome }}</td>
            <td>{{ sol.quantidade_solicitada }}</td>
            <td><span class="badge badge-warning">{{ sol.get_status_display }}</span></td>
            <td><a href="{% url 'detalhe_solicitacao' sol.pk %}" class="btn btn-sm btn-outline">Ver</a></td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
    {% else %}
    <div class="empty-state"><p>Nenhuma solicitação pendente.</p></div>
    {% endif %}
  </div>
</div>
{% endblock %}""",

    r"compras\lista_materiais.html": """{% extends 'base.html' %}
{% block title %}Estoque de Materiais — ERP Ecopremium{% endblock %}
{% block nav_compras %}active{% endblock %}
{% block topbar_title %}Estoque de Materiais{% endblock %}
{% block content %}
<div class="card mb-4">
  <form method="get" class="flex gap-3 items-center">
    <input type="text" name="q" class="form-control" placeholder="Buscar material por nome ou código..." value="{{ request.GET.q }}">
    <button type="submit" class="btn btn-outline">Buscar</button>
  </form>
</div>
<div class="card">
  <div class="table-wrap">
    <table>
      <thead><tr><th>Código</th><th>Nome</th><th>Categoria</th><th>Estoque</th><th>Mínimo</th><th>Status</th><th>Ações</th></tr></thead>
      <tbody>
        {% for mat in materiais %}
        <tr>
          <td style="font-size:0.75rem;color:var(--text-muted);">{{ mat.codigo }}</td>
          <td style="font-weight:600;">{{ mat.nome }}</td>
          <td>{{ mat.get_categoria_display }}</td>
          <td style="font-weight:800; color:{% if mat.estoque_critico %}var(--danger){% else %}var(--success){% endif %};">{{ mat.quantidade_estoque }} {{ mat.unidade_medida }}</td>
          <td style="color:var(--text-muted);">{{ mat.estoque_minimo }}</td>
          <td><span class="badge badge-{% if mat.estoque_critico %}danger{% else %}success{% endif %}">{% if mat.estoque_critico %}CRÍTICO{% else %}OK{% endif %}</span></td>
          <td><a href="{% url 'nova_solicitacao' %}?material={{ mat.pk }}" class="btn btn-sm btn-outline">Pedir</a></td>
        </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>
{% endblock %}""",

    r"compras\nova_solicitacao.html": """{% extends 'base.html' %}
{% block title %}Nova Solicitação — ERP Ecopremium{% endblock %}
{% block nav_compras %}active{% endblock %}
{% block topbar_title %}Solicitar Material{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">🛒 Solicitação de Material</div>
  <div class="gateway-box mb-4">
    <div class="gateway-question">Gateway de Suprimentos</div>
    <p style="font-size:0.84rem;color:var(--text-secondary);">O sistema analisará automaticamente o estoque. Se houver quantidade suficiente, será classificado como "Atendido via Estoque Interno". Caso contrário, gerará uma "Necessidade de Compra Externa".</p>
  </div>
  <form method="post">
    {% csrf_token %}
    <div class="form-group">
      <label class="form-label">Material</label>
      <select name="material" class="form-control" required>
        {% for mat in materiais %}
        <option value="{{ mat.pk }}" {% if request.GET.material == mat.pk|stringformat:"s" %}selected{% endif %}>{{ mat.codigo }} - {{ mat.nome }} (Estoque: {{ mat.quantidade_estoque }})</option>
        {% endfor %}
      </select>
    </div>
    <div class="form-grid">
      <div class="form-group">
        <label class="form-label">Quantidade Solicitada</label>
        <input type="number" name="quantidade_solicitada" class="form-control" min="1" required>
      </div>
      <div class="form-group">
        <label class="form-label">Unidade de Destino</label>
        <input type="text" name="unidade_destino" class="form-control" value="{{ user.perfil.unidade|default:'' }}" required>
      </div>
    </div>
    <div class="form-group">
      <label class="form-label">Justificativa</label>
      <textarea name="justificativa" class="form-control" rows="3" required></textarea>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'painel_compras' %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod5">Analisar e Criar Solicitação</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"compras\detalhe_solicitacao.html": """{% extends 'base.html' %}
{% block title %}Detalhe da Solicitação — ERP Ecopremium{% endblock %}
{% block nav_compras %}active{% endblock %}
{% block topbar_title %}Detalhe da Solicitação{% endblock %}
{% block content %}
<a href="{% url 'painel_compras' %}" style="color:var(--text-muted);font-size:0.82rem;text-decoration:none;display:block;margin-bottom:16px;">← Voltar ao Painel</a>
<div class="card">
  <div class="flex justify-between items-start mb-4">
    <div>
      <div class="card-title">{{ solicitacao.material.nome }}</div>
      <div style="font-size:0.82rem;color:var(--text-muted);">Solicitado por {{ solicitacao.solicitante }} em {{ solicitacao.criado_em|date:"d/m/Y" }}</div>
    </div>
    <span class="badge badge-info">{{ solicitacao.get_status_display }}</span>
  </div>
  <div class="form-grid mt-4">
    <div><div class="form-label">Quantidade Solicitada</div><div style="font-size:1.1rem;font-weight:800;">{{ solicitacao.quantidade_solicitada }}</div></div>
    <div><div class="form-label">Destino</div><div style="font-size:1.1rem;font-weight:800;">{{ solicitacao.unidade_destino }}</div></div>
    <div class="form-full"><div class="form-label">Justificativa</div><div>{{ solicitacao.justificativa }}</div></div>
  </div>
  {% if solicitacao.status == 'compra_externa' %}
  <div class="divider"></div>
  <div class="flex justify-between items-center">
    <div style="font-size:0.86rem;color:var(--warning);font-weight:600;">⚠️ Necessidade de Compra Externa (Sem Estoque Suficiente)</div>
    <a href="{% url 'criar_pedido' solicitacao.pk %}" class="btn btn-mod5">Criar Pedido de Compra</a>
  </div>
  {% endif %}
  
  {% if pedidos %}
  <div class="divider"></div>
  <div class="card-title mb-3">📦 Pedidos Vinculados</div>
  <div class="table-wrap">
    <table>
      <thead><tr><th>ID</th><th>Fornecedor</th><th>Valor Total</th><th>Status</th><th>Ação</th></tr></thead>
      <tbody>
        {% for p in pedidos %}
        <tr>
          <td>#{{ p.pk }}</td>
          <td>{{ p.fornecedor }}</td>
          <td>R$ {{ p.valor_total }}</td>
          <td><span class="badge badge-info">{{ p.get_status_display }}</span></td>
          <td>
            {% if p.status == 'aguardando_aprovacao' %}
            <form method="post" action="{% url 'aprovar_pedido' p.pk %}">{% csrf_token %}<button type="submit" class="btn btn-sm btn-success">Aprovar Pedido</button></form>
            {% endif %}
          </td>
        </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
  {% endif %}
</div>
{% endblock %}""",

    r"compras\criar_pedido.html": """{% extends 'base.html' %}
{% block title %}Criar Pedido — ERP Ecopremium{% endblock %}
{% block nav_compras %}active{% endblock %}
{% block topbar_title %}Criar Pedido de Compra{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">📄 Criar Pedido de Compra</div>
  <div style="background:var(--bg-surface);padding:16px;border-radius:var(--radius-sm);margin-bottom:20px;">
    <strong>Material:</strong> {{ solicitacao.material.nome }} <br>
    <strong>Quantidade:</strong> {{ solicitacao.quantidade_solicitada }}
  </div>
  <form method="post">
    {% csrf_token %}
    <div class="form-grid">
      <div class="form-group form-full">
        <label class="form-label">Fornecedor</label>
        <input type="text" name="fornecedor" class="form-control" required>
      </div>
      <div class="form-group">
        <label class="form-label">CNPJ (Opcional)</label>
        <input type="text" name="cnpj_fornecedor" class="form-control">
      </div>
      <div class="form-group">
        <label class="form-label">Valor Unitário (R$)</label>
        <input type="number" name="valor_unitario" class="form-control" step="0.01" required>
      </div>
      <div class="form-group form-full">
        <label class="form-label">Prazo de Entrega Estimado</label>
        <input type="date" name="prazo_entrega" class="form-control">
      </div>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'detalhe_solicitacao' solicitacao.pk %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod5">Criar Pedido</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"financeiro\painel.html": """{% extends 'base.html' %}
{% block title %}Painel Financeiro — ERP Ecopremium{% endblock %}
{% block nav_financeiro %}active{% endblock %}
{% block topbar_title %}Painel Financeiro e Fiscal{% endblock %}
{% block content %}
<div class="module-banner mod-banner-6">
  <div class="mod-title">💰 Financeiro / Fiscal</div>
  <div class="mod-desc">Auditoria de documentos, integração com sistema contábil e validações finais.</div>
</div>
<div class="page-header">
  <div class="flex gap-3">
    <div class="kpi-card kpi-mod6" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ docs_pendentes|length }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Docs em Auditoria</div>
    </div>
    <div class="kpi-card kpi-mod6" style="padding:14px 20px;min-width:140px;">
      <div style="font-size:1.6rem;font-weight:800;">{{ lancamentos_pendentes|length }}</div>
      <div style="font-size:0.75rem;color:var(--text-secondary);">Lançamentos a Validar</div>
    </div>
  </div>
  <a href="{% url 'entrada_documento' %}" class="btn btn-mod6">+ Entrada de Documento</a>
</div>
<div class="grid-2">
  <div class="card">
    <div class="card-title">🔍 Documentos em Auditoria</div>
    {% if docs_pendentes %}
    <div class="table-wrap mt-3">
      <table>
        <thead><tr><th>Documento</th><th>Valor</th><th>Status</th><th>Ação</th></tr></thead>
        <tbody>
          {% for doc in docs_pendentes %}
          <tr>
            <td><div style="font-weight:600;">{{ doc.numero_documento }}</div><div style="font-size:0.72rem;color:var(--text-muted);">{{ doc.get_tipo_display }}</div></td>
            <td>R$ {{ doc.valor }}</td>
            <td><span class="badge badge-warning">{{ doc.get_status_display }}</span></td>
            <td><a href="{% url 'auditoria_documento' doc.pk %}" class="btn btn-sm btn-outline">Auditar</a></td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
    {% else %}
    <div class="empty-state"><p>Nenhum documento em auditoria.</p></div>
    {% endif %}
  </div>
  <div class="card">
    <div class="card-title">⚖️ Lançamentos Pendentes de Validação</div>
    {% if lancamentos_pendentes %}
    <div class="table-wrap mt-3">
      <table>
        <thead><tr><th>Lançamento</th><th>Valor</th><th>Status</th><th>Ação</th></tr></thead>
        <tbody>
          {% for lanc in lancamentos_pendentes %}
          <tr>
            <td><div style="font-weight:600;">{{ lanc.descricao|truncatechars:30 }}</div><div style="font-size:0.72rem;color:var(--text-muted);">{{ lanc.get_tipo_display }}</div></td>
            <td>R$ {{ lanc.valor }}</td>
            <td><span class="badge badge-info">{{ lanc.get_status_display }}</span></td>
            <td><a href="{% url 'validar_lancamento' lanc.pk %}" class="btn btn-sm btn-outline">Validar</a></td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
    {% else %}
    <div class="empty-state"><p>Nenhum lançamento pendente.</p></div>
    {% endif %}
  </div>
</div>
{% endblock %}""",

    r"financeiro\entrada_documento.html": """{% extends 'base.html' %}
{% block title %}Entrada de Documento — ERP Ecopremium{% endblock %}
{% block nav_financeiro %}active{% endblock %}
{% block topbar_title %}Registrar Entrada{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">📥 Registro de Entrada Fiscal/Financeira</div>
  <form method="post">
    {% csrf_token %}
    <div class="form-grid">
      <div class="form-group">
        <label class="form-label">Tipo de Documento</label>
        <select name="tipo" class="form-control" required>
          {% for val, label in tipos %}
          <option value="{{ val }}">{{ label }}</option>
          {% endfor %}
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Número do Documento</label>
        <input type="text" name="numero_documento" class="form-control" required>
      </div>
      <div class="form-group">
        <label class="form-label">Valor Total (R$)</label>
        <input type="number" name="valor" class="form-control" step="0.01" required>
      </div>
      <div class="form-group">
        <label class="form-label">Data Emissão</label>
        <input type="date" name="data_emissao" class="form-control" required>
      </div>
      <div class="form-group form-full">
        <label class="form-label">Descrição</label>
        <input type="text" name="descricao" class="form-control" required>
      </div>
      <div class="form-group">
        <label class="form-label">Centro de Custo</label>
        <input type="text" name="centro_custo" class="form-control" required>
      </div>
      <div class="form-group">
        <label class="form-label">Unidade Origem/Destino</label>
        <input type="text" name="unidade" class="form-control" required>
      </div>
    </div>
    <div class="divider"></div>
    <div class="form-grid">
      <div class="form-group">
        <label class="form-label">CNPJ Emitente</label>
        <input type="text" name="cnpj_emitente" class="form-control" required>
      </div>
      <div class="form-group">
        <label class="form-label">Razão Social Emitente</label>
        <input type="text" name="razao_social_emitente" class="form-control" required>
      </div>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'painel_financeiro' %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod6">Registrar e Iniciar Auditoria</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"financeiro\auditoria.html": """{% extends 'base.html' %}
{% block title %}Auditoria de Documento — ERP Ecopremium{% endblock %}
{% block nav_financeiro %}active{% endblock %}
{% block topbar_title %}Auditoria Fiscal{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">🔍 Gateway de Auditoria: {{ doc.numero_documento }}</div>
  <div style="background:var(--bg-surface);padding:16px;border-radius:var(--radius-sm);margin-bottom:20px;display:flex;gap:40px;">
    <div><div class="text-muted text-sm">Valor</div><div class="font-bold">R$ {{ doc.valor }}</div></div>
    <div><div class="text-muted text-sm">Emitente</div><div class="font-bold">{{ doc.razao_social_emitente }}</div></div>
    <div><div class="text-muted text-sm">Centro de Custo</div><div class="font-bold">{{ doc.centro_custo }}</div></div>
  </div>
  <div class="gateway-box mb-4">
    <div class="gateway-question">Análise de Checklist</div>
    <p class="text-sm text-secondary">A aprovação do documento depende da conformidade de todos os itens abaixo.</p>
  </div>
  <form method="post">
    {% csrf_token %}
    {% for item in itens %}
    <div style="border:1px solid var(--border);padding:16px;border-radius:var(--radius-sm);margin-bottom:12px;">
      <div class="font-bold mb-2">{{ item.get_item_display }}</div>
      <div class="flex gap-4 mb-2">
        <label style="cursor:pointer;"><input type="radio" name="item_{{ item.pk }}" value="ok" required> ✅ Conforme</label>
        <label style="cursor:pointer;"><input type="radio" name="item_{{ item.pk }}" value="divergente"> ❌ Divergente</label>
      </div>
      <input type="text" name="obs_{{ item.pk }}" class="form-control text-sm" placeholder="Observações (opcional)">
    </div>
    {% endfor %}
    <div class="flex justify-between mt-4">
      <a href="{% url 'painel_financeiro' %}" class="btn btn-outline">Voltar</a>
      <button type="submit" class="btn btn-mod6">Salvar Auditoria</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"financeiro\detalhe_documento.html": """{% extends 'base.html' %}
{% block title %}Detalhe do Documento — ERP Ecopremium{% endblock %}
{% block nav_financeiro %}active{% endblock %}
{% block topbar_title %}Detalhe do Documento{% endblock %}
{% block content %}
<a href="{% url 'painel_financeiro' %}" style="color:var(--text-muted);font-size:0.82rem;text-decoration:none;display:block;margin-bottom:16px;">← Voltar ao Painel</a>
<div class="card">
  <div class="flex justify-between items-start mb-4">
    <div>
      <div class="card-title">{{ doc.numero_documento }}</div>
      <div style="font-size:0.82rem;color:var(--text-muted);">{{ doc.get_tipo_display }}</div>
    </div>
    <span class="badge badge-info">{{ doc.get_status_display }}</span>
  </div>
  <div class="form-grid mt-4">
    <div><div class="form-label">Valor</div><div style="font-size:1.1rem;font-weight:800;">R$ {{ doc.valor }}</div></div>
    <div><div class="form-label">Centro de Custo</div><div style="font-size:1.1rem;font-weight:800;">{{ doc.centro_custo }}</div></div>
    <div class="form-full"><div class="form-label">Emitente</div><div>{{ doc.razao_social_emitente }} ({{ doc.cnpj_emitente }})</div></div>
  </div>
  <div class="divider"></div>
  {% if doc.status == 'aprovado_lancamento' %}
  <div class="flex justify-end">
    <a href="{% url 'lancar_erp' doc.pk %}" class="btn btn-mod6">Realizar Lançamento no ERP</a>
  </div>
  {% elif doc.status == 'reprovado' %}
  <div class="alert alert-error">Documento reprovado na auditoria.</div>
  {% elif doc.status == 'arquivado' %}
  <div class="alert alert-success">Documento arquivado com sucesso.</div>
  {% endif %}
</div>
{% endblock %}""",

    r"financeiro\lancar_erp.html": """{% extends 'base.html' %}
{% block title %}Lançar no ERP — ERP Ecopremium{% endblock %}
{% block nav_financeiro %}active{% endblock %}
{% block topbar_title %}Lançamento Contábil/Financeiro{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">🖥️ Inserir Lançamento no ERP Ecopremium</div>
  <div style="background:var(--bg-surface);padding:16px;border-radius:var(--radius-sm);margin-bottom:20px;">
    <strong>Documento:</strong> {{ doc.numero_documento }} <br>
    <strong>Valor:</strong> R$ {{ doc.valor }}
  </div>
  <form method="post">
    {% csrf_token %}
    <div class="form-group">
      <label class="form-label">Descrição do Lançamento</label>
      <input type="text" name="descricao" class="form-control" value="{{ doc.descricao }}" required>
    </div>
    <div class="form-grid">
      <div class="form-group">
        <label class="form-label">Tipo</label>
        <select name="tipo" class="form-control" required>
          <option value="debito">Débito</option>
          <option value="credito">Crédito</option>
          <option value="provisao">Provisão</option>
          <option value="estorno">Estorno</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Competência</label>
        <input type="date" name="competencia" class="form-control" value="{{ doc.data_emissao|date:'Y-m-d' }}" required>
      </div>
    </div>
    <div class="flex justify-between mt-4">
      <a href="{% url 'detalhe_documento' doc.pk %}" class="btn btn-outline">Cancelar</a>
      <button type="submit" class="btn btn-mod6">Gravar Lançamento</button>
    </div>
  </form>
</div>
{% endblock %}""",

    r"financeiro\validar_lancamento.html": """{% extends 'base.html' %}
{% block title %}Validar Lançamento — ERP Ecopremium{% endblock %}
{% block nav_financeiro %}active{% endblock %}
{% block topbar_title %}Gateway de Validação de Lançamento{% endblock %}
{% block content %}
<div class="card" style="max-width:800px; margin:0 auto;">
  <div class="card-title mb-4">⚖️ Validação Final de Lançamento</div>
  <div class="form-grid mb-4" style="background:var(--bg-surface);padding:16px;border-radius:var(--radius-sm);">
    <div><div class="text-muted text-sm">Lançamento</div><div class="font-bold">{{ lancamento.descricao }}</div></div>
    <div><div class="text-muted text-sm">Valor</div><div class="font-bold">R$ {{ lancamento.valor }}</div></div>
    <div><div class="text-muted text-sm">Centro de Custo</div><div class="font-bold">{{ lancamento.centro_custo }}</div></div>
    <div><div class="text-muted text-sm">Competência</div><div class="font-bold">{{ lancamento.competencia|date:"m/Y" }}</div></div>
  </div>
  <div class="gateway-box" style="border-color:var(--success); background:rgba(16,185,129,0.05);">
    <div class="gateway-question" style="color:var(--success);">Gateway Final: Lançamento validado pelo sistema?</div>
    <p class="text-sm text-secondary mb-4">Confirmar este lançamento encerra o processo no módulo financeiro.</p>
    <form method="post">
      {% csrf_token %}
      <div class="form-group">
        <label class="form-label">Motivo (em caso de rejeição)</label>
        <textarea name="motivo_rejeicao" class="form-control" rows="2"></textarea>
      </div>
      <div class="gateway-actions mt-4">
        <button type="submit" name="acao" value="validar" class="btn btn-success btn-lg">✅ SIM — Validar e Finalizar</button>
        <button type="submit" name="acao" value="rejeitar" class="btn btn-danger">❌ NÃO — Rejeitar Lançamento</button>
      </div>
    </form>
  </div>
</div>
{% endblock %}""",
}

for path, content in templates.items():
    full_path = os.path.join(BASE_DIR, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Todas as 20 templates foram geradas com sucesso!")
