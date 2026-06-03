-- =============================================================================
-- ERP ECOPREMIUM — Script SQL para Supabase (PostgreSQL)
-- =============================================================================
-- Cole este arquivo inteiro no SQL Editor do Supabase e execute.
-- Caminho: Supabase Dashboard → SQL Editor → New Query → Cole e clique em Run
--
-- Este script cria:
--   1. Todas as tabelas do ERP Ecopremium (PostgreSQL syntax)
--   2. Tabela de Linha de Aprovação genérica
--   3. Tabela de Grupos de Privilégio + Permissões
--   4. Índices de performance
--   5. Dados iniciais (grupos de privilégio)
-- =============================================================================

-- Ativa extensão para UUIDs (opcional, usamos BIGSERIAL por compatibilidade Django)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- SEÇÃO 1 — TABELAS DO DJANGO (Auth, Sessions, ContentTypes)
-- =============================================================================

-- Django Content Types
CREATE TABLE IF NOT EXISTS django_content_type (
    id         SERIAL PRIMARY KEY,
    app_label  VARCHAR(100) NOT NULL,
    model      VARCHAR(100) NOT NULL,
    CONSTRAINT django_content_type_app_label_model_uniq UNIQUE (app_label, model)
);

-- Django Auth: Permissões
CREATE TABLE IF NOT EXISTS auth_permission (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    content_type_id INTEGER NOT NULL REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED,
    codename        VARCHAR(100) NOT NULL,
    CONSTRAINT auth_permission_content_type_codename_uniq UNIQUE (content_type_id, codename)
);
CREATE INDEX IF NOT EXISTS auth_permission_content_type_id_idx ON auth_permission(content_type_id);

-- Django Auth: Grupos
CREATE TABLE IF NOT EXISTS auth_group (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

-- Django Auth: Grupos ↔ Permissões
CREATE TABLE IF NOT EXISTS auth_group_permissions (
    id            SERIAL PRIMARY KEY,
    group_id      INTEGER NOT NULL REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED,
    permission_id INTEGER NOT NULL REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT auth_group_permissions_group_perm_uniq UNIQUE (group_id, permission_id)
);
CREATE INDEX IF NOT EXISTS auth_group_permissions_group_id_idx ON auth_group_permissions(group_id);
CREATE INDEX IF NOT EXISTS auth_group_permissions_perm_id_idx ON auth_group_permissions(permission_id);

-- Django Auth: Usuários
CREATE TABLE IF NOT EXISTS auth_user (
    id           SERIAL PRIMARY KEY,
    password     VARCHAR(128) NOT NULL,
    last_login   TIMESTAMPTZ,
    is_superuser BOOLEAN NOT NULL DEFAULT FALSE,
    username     VARCHAR(150) NOT NULL UNIQUE,
    first_name   VARCHAR(150) NOT NULL DEFAULT '',
    last_name    VARCHAR(150) NOT NULL DEFAULT '',
    email        VARCHAR(254) NOT NULL DEFAULT '',
    is_staff     BOOLEAN NOT NULL DEFAULT FALSE,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    date_joined  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Django Auth: Usuários ↔ Grupos
CREATE TABLE IF NOT EXISTS auth_user_groups (
    id       SERIAL PRIMARY KEY,
    user_id  INTEGER NOT NULL REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED,
    group_id INTEGER NOT NULL REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT auth_user_groups_user_group_uniq UNIQUE (user_id, group_id)
);
CREATE INDEX IF NOT EXISTS auth_user_groups_user_id_idx ON auth_user_groups(user_id);
CREATE INDEX IF NOT EXISTS auth_user_groups_group_id_idx ON auth_user_groups(group_id);

-- Django Auth: Usuários ↔ Permissões
CREATE TABLE IF NOT EXISTS auth_user_user_permissions (
    id            SERIAL PRIMARY KEY,
    user_id       INTEGER NOT NULL REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED,
    permission_id INTEGER NOT NULL REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT auth_user_perms_user_perm_uniq UNIQUE (user_id, permission_id)
);

-- Django Admin Log
CREATE TABLE IF NOT EXISTS django_admin_log (
    id              SERIAL PRIMARY KEY,
    action_time     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    object_id       TEXT,
    object_repr     VARCHAR(200) NOT NULL,
    action_flag     SMALLINT NOT NULL CHECK (action_flag >= 0),
    change_message  TEXT NOT NULL DEFAULT '',
    content_type_id INTEGER REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED,
    user_id         INTEGER NOT NULL REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX IF NOT EXISTS django_admin_log_content_type_id_idx ON django_admin_log(content_type_id);
CREATE INDEX IF NOT EXISTS django_admin_log_user_id_idx ON django_admin_log(user_id);

-- Django Sessions
CREATE TABLE IF NOT EXISTS django_session (
    session_key  VARCHAR(40) PRIMARY KEY,
    session_data TEXT NOT NULL,
    expire_date  TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS django_session_expire_date_idx ON django_session(expire_date);

-- Django Migrations
CREATE TABLE IF NOT EXISTS django_migrations (
    id      SERIAL PRIMARY KEY,
    app     VARCHAR(255) NOT NULL,
    name    VARCHAR(255) NOT NULL,
    applied TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SEÇÃO 2 — MÓDULO CORE (Perfil + Notificações + Aprovações)
-- =============================================================================

-- Perfil do Usuário
CREATE TABLE IF NOT EXISTS core_perfilusuario (
    id              BIGSERIAL PRIMARY KEY,
    perfil          VARCHAR(20) NOT NULL DEFAULT 'operacional',
    marca           VARCHAR(20) NOT NULL DEFAULT 'eco_premium',
    unidade         VARCHAR(100) NOT NULL DEFAULT 'Matriz',
    telefone        VARCHAR(20) NOT NULL DEFAULT '',
    avatar_iniciais VARCHAR(3) NOT NULL DEFAULT '',
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario_id      INTEGER NOT NULL UNIQUE REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX IF NOT EXISTS core_perfilusuario_usuario_id_idx ON core_perfilusuario(usuario_id);

-- Notificações
CREATE TABLE IF NOT EXISTS core_notificacao (
    id             BIGSERIAL PRIMARY KEY,
    tipo           VARCHAR(20) NOT NULL DEFAULT 'info',
    modulo         VARCHAR(20) NOT NULL DEFAULT 'sistema',
    titulo         VARCHAR(200) NOT NULL,
    mensagem       TEXT NOT NULL DEFAULT '',
    lida           BOOLEAN NOT NULL DEFAULT FALSE,
    url_acao       VARCHAR(200) NOT NULL DEFAULT '',
    criado_em      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    destinatario_id INTEGER NOT NULL REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX IF NOT EXISTS core_notificacao_destinatario_id_idx ON core_notificacao(destinatario_id);
CREATE INDEX IF NOT EXISTS core_notificacao_lida_idx ON core_notificacao(lida);

-- =============================================================================
-- SEÇÃO 3 — LINHA DE APROVAÇÃO GENÉRICA
-- =============================================================================

CREATE TABLE IF NOT EXISTS core_aprovacaoregistro (
    id              BIGSERIAL PRIMARY KEY,

    -- Referência genérica ao objeto aprovado (GenericForeignKey)
    content_type_id INTEGER NOT NULL REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED,
    object_id       BIGINT NOT NULL,

    -- Dados da aprovação
    modulo          VARCHAR(20) NOT NULL DEFAULT 'sistema',
    nivel           INTEGER NOT NULL DEFAULT 1 CHECK (nivel IN (1, 2)),
    status          VARCHAR(20) NOT NULL DEFAULT 'pendente'
                    CHECK (status IN ('pendente','aprovado','rejeitado','cancelado')),

    titulo          VARCHAR(255) NOT NULL,
    descricao       TEXT NOT NULL DEFAULT '',
    comentario      TEXT NOT NULL DEFAULT '',
    motivo_rejeicao TEXT NOT NULL DEFAULT '',

    -- Usuários
    solicitado_por_id INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    aprovado_por_id   INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,

    -- Timestamps
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    decidido_em     TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS core_aprovacao_content_idx ON core_aprovacaoregistro(content_type_id, object_id);
CREATE INDEX IF NOT EXISTS core_aprovacao_status_idx ON core_aprovacaoregistro(status);
CREATE INDEX IF NOT EXISTS core_aprovacao_modulo_status_idx ON core_aprovacaoregistro(modulo, status);
CREATE INDEX IF NOT EXISTS core_aprovacao_solicitado_por_idx ON core_aprovacaoregistro(solicitado_por_id);

-- =============================================================================
-- SEÇÃO 4 — MÓDULO RECRUTAMENTO
-- =============================================================================

CREATE TABLE IF NOT EXISTS recrutamento_vaga (
    id                        BIGSERIAL PRIMARY KEY,
    nome_vaga                 VARCHAR(200) NOT NULL,
    quantidade_colaboradores  INTEGER NOT NULL DEFAULT 1 CHECK (quantidade_colaboradores >= 0),
    cidade                    VARCHAR(100) NOT NULL DEFAULT '',
    unidade                   VARCHAR(100) NOT NULL DEFAULT '',
    perfil_desejado           TEXT NOT NULL DEFAULT '',
    atividades                TEXT NOT NULL DEFAULT '',
    horario_trabalho          VARCHAR(100) NOT NULL DEFAULT '',
    tipo_contratacao          VARCHAR(20) NOT NULL DEFAULT 'clt',
    valor_salario             NUMERIC(10,2) NOT NULL DEFAULT 0,
    previsao_inicio           DATE NOT NULL,
    exige_experiencia         BOOLEAN NOT NULL DEFAULT FALSE,
    descricao_experiencia     TEXT NOT NULL DEFAULT '',
    motivo_solicitacao        TEXT NOT NULL DEFAULT '',
    gestor_responsavel        VARCHAR(200) NOT NULL DEFAULT '',
    status                    VARCHAR(30) NOT NULL DEFAULT 'aguardando_aprovacao',
    observacoes               TEXT NOT NULL DEFAULT '',
    criado_em                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    gestor_usuario_id         INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS recrutamento_vaga_status_idx ON recrutamento_vaga(status);
CREATE INDEX IF NOT EXISTS recrutamento_vaga_gestor_idx ON recrutamento_vaga(gestor_usuario_id);

CREATE TABLE IF NOT EXISTS recrutamento_candidato (
    id                      BIGSERIAL PRIMARY KEY,
    nome                    VARCHAR(200) NOT NULL,
    email                   VARCHAR(254) NOT NULL,
    telefone                VARCHAR(20) NOT NULL DEFAULT '',
    cpf                     VARCHAR(14) NOT NULL DEFAULT '',
    etapa_atual             VARCHAR(20) NOT NULL DEFAULT 'triagem',
    aprovado                BOOLEAN,
    curriculum_obs          TEXT NOT NULL DEFAULT '',
    avaliacao_comportamental TEXT NOT NULL DEFAULT '',
    resultado_entrevista    TEXT NOT NULL DEFAULT '',
    encaminhado_admissao    BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    avaliado_por_id         INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    vaga_id                 BIGINT NOT NULL REFERENCES recrutamento_vaga(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS recrutamento_candidato_vaga_id_idx ON recrutamento_candidato(vaga_id);
CREATE INDEX IF NOT EXISTS recrutamento_candidato_etapa_idx ON recrutamento_candidato(etapa_atual);

-- =============================================================================
-- SEÇÃO 5 — MÓDULO ADMISSIONAL
-- =============================================================================

CREATE TABLE IF NOT EXISTS admissional_colaborador (
    id              BIGSERIAL PRIMARY KEY,
    nome            VARCHAR(200) NOT NULL,
    cpf             VARCHAR(14) NOT NULL UNIQUE,
    rg              VARCHAR(20) NOT NULL DEFAULT '',
    data_nascimento DATE,
    email           VARCHAR(254) NOT NULL DEFAULT '',
    telefone        VARCHAR(20) NOT NULL DEFAULT '',
    endereco        TEXT NOT NULL DEFAULT '',
    cargo           VARCHAR(200) NOT NULL DEFAULT '',
    setor           VARCHAR(100) NOT NULL DEFAULT '',
    unidade         VARCHAR(100) NOT NULL DEFAULT '',
    marca           VARCHAR(20) NOT NULL DEFAULT 'eco_premium',
    data_admissao   DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'ativo',
    pis_pasep       VARCHAR(20) NOT NULL DEFAULT '',
    ctps            VARCHAR(30) NOT NULL DEFAULT '',
    salario         NUMERIC(10,2),
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS admissional_colaborador_status_idx ON admissional_colaborador(status);
CREATE INDEX IF NOT EXISTS admissional_colaborador_cpf_idx ON admissional_colaborador(cpf);

CREATE TABLE IF NOT EXISTS admissional_admissao (
    id                  BIGSERIAL PRIMARY KEY,
    candidato_nome      VARCHAR(200) NOT NULL,
    candidato_email     VARCHAR(254) NOT NULL DEFAULT '',
    candidato_telefone  VARCHAR(20) NOT NULL DEFAULT '',
    vaga_nome           VARCHAR(200) NOT NULL DEFAULT '',
    unidade_destino     VARCHAR(100) NOT NULL DEFAULT '',
    status              VARCHAR(30) NOT NULL DEFAULT 'aguardando_documentos',
    observacoes         TEXT NOT NULL DEFAULT '',
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    concluido_em        TIMESTAMPTZ,
    responsavel_rh_id   INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    colaborador_id      BIGINT UNIQUE REFERENCES admissional_colaborador(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS admissional_admissao_status_idx ON admissional_admissao(status);
CREATE INDEX IF NOT EXISTS admissional_admissao_rh_idx ON admissional_admissao(responsavel_rh_id);

CREATE TABLE IF NOT EXISTS admissional_documentoadmissional (
    id            BIGSERIAL PRIMARY KEY,
    tipo          VARCHAR(30) NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'pendente',
    observacao    TEXT NOT NULL DEFAULT '',
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    admissao_id   BIGINT NOT NULL REFERENCES admissional_admissao(id) ON DELETE CASCADE,
    CONSTRAINT admissional_doc_admissao_tipo_uniq UNIQUE (admissao_id, tipo)
);
CREATE INDEX IF NOT EXISTS admissional_documentoadmissional_admissao_idx ON admissional_documentoadmissional(admissao_id);

-- =============================================================================
-- SEÇÃO 6 — MÓDULO ADMINISTRATIVO
-- =============================================================================

CREATE TABLE IF NOT EXISTS administrativo_demandaadministrativa (
    id                   BIGSERIAL PRIMARY KEY,
    tipo                 VARCHAR(30) NOT NULL,
    titulo               VARCHAR(200) NOT NULL,
    descricao            TEXT NOT NULL DEFAULT '',
    requisitante         VARCHAR(200) NOT NULL DEFAULT '',
    prioridade           VARCHAR(10) NOT NULL DEFAULT 'media',
    status               VARCHAR(30) NOT NULL DEFAULT 'recebida',
    motivo_rejeicao      TEXT NOT NULL DEFAULT '',
    observacoes          TEXT NOT NULL DEFAULT '',
    criado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    concluido_em         TIMESTAMPTZ,
    requisitante_usuario_id INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    responsavel_id          INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS administrativo_demanda_status_idx ON administrativo_demandaadministrativa(status);
CREATE INDEX IF NOT EXISTS administrativo_demanda_prioridade_idx ON administrativo_demandaadministrativa(prioridade);

-- =============================================================================
-- SEÇÃO 7 — MÓDULO SESMET
-- =============================================================================

CREATE TABLE IF NOT EXISTS sesmet_integracaoseguranca (
    id                      BIGSERIAL PRIMARY KEY,
    data_integracao         DATE NOT NULL,
    apresentador            VARCHAR(200) NOT NULL DEFAULT '',
    missao_visao_valores    BOOLEAN NOT NULL DEFAULT FALSE,
    normas_seguranca        BOOLEAN NOT NULL DEFAULT FALSE,
    uso_epis                BOOLEAN NOT NULL DEFAULT FALSE,
    procedimentos_emergencia BOOLEAN NOT NULL DEFAULT FALSE,
    concluida               BOOLEAN NOT NULL DEFAULT FALSE,
    obs                     TEXT NOT NULL DEFAULT '',
    criado_em               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    colaborador_id          BIGINT NOT NULL UNIQUE REFERENCES admissional_colaborador(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sesmet_ordemservico (
    id                  BIGSERIAL PRIMARY KEY,
    numero              VARCHAR(20) NOT NULL UNIQUE,
    descricao_riscos    TEXT NOT NULL DEFAULT '',
    medidas_preventivas TEXT NOT NULL DEFAULT '',
    epis_obrigatorios   TEXT NOT NULL DEFAULT '',
    data_emissao        DATE NOT NULL,
    assinado            BOOLEAN NOT NULL DEFAULT FALSE,
    data_assinatura     DATE,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    colaborador_id      BIGINT NOT NULL REFERENCES admissional_colaborador(id) ON DELETE CASCADE,
    emitido_por_id      INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS sesmet_os_colaborador_idx ON sesmet_ordemservico(colaborador_id);
CREATE INDEX IF NOT EXISTS sesmet_os_emitido_por_idx ON sesmet_ordemservico(emitido_por_id);

CREATE TABLE IF NOT EXISTS sesmet_registroepi (
    id                   BIGSERIAL PRIMARY KEY,
    tipo_epi             VARCHAR(30) NOT NULL,
    data_entrega         DATE NOT NULL,
    quantidade           INTEGER NOT NULL DEFAULT 1 CHECK (quantidade >= 0),
    numero_ca            VARCHAR(20) NOT NULL DEFAULT '',
    data_validade        DATE,
    status               VARCHAR(20) NOT NULL DEFAULT 'ativo',
    motivo_substituicao  VARCHAR(20) NOT NULL DEFAULT '',
    assinado             BOOLEAN NOT NULL DEFAULT FALSE,
    obs                  TEXT NOT NULL DEFAULT '',
    criado_em            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    colaborador_id       BIGINT NOT NULL REFERENCES admissional_colaborador(id) ON DELETE CASCADE,
    registrado_por_id    INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS sesmet_epi_colaborador_idx ON sesmet_registroepi(colaborador_id);
CREATE INDEX IF NOT EXISTS sesmet_epi_data_validade_idx ON sesmet_registroepi(data_validade);
CREATE INDEX IF NOT EXISTS sesmet_epi_status_idx ON sesmet_registroepi(status);

-- =============================================================================
-- SEÇÃO 8 — MÓDULO COMPRAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS compras_material (
    id                    BIGSERIAL PRIMARY KEY,
    codigo                VARCHAR(20) NOT NULL UNIQUE,
    nome                  VARCHAR(200) NOT NULL,
    descricao             TEXT NOT NULL DEFAULT '',
    categoria             VARCHAR(20) NOT NULL DEFAULT 'consumo',
    unidade_medida        VARCHAR(5) NOT NULL DEFAULT 'un',
    quantidade_estoque    NUMERIC(10,2) NOT NULL DEFAULT 0,
    estoque_minimo        NUMERIC(10,2) NOT NULL DEFAULT 5,
    preco_unitario        NUMERIC(10,2),
    fornecedor_preferencial VARCHAR(200) NOT NULL DEFAULT '',
    localizacao           VARCHAR(100) NOT NULL DEFAULT '',
    criado_em             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS compras_material_categoria_idx ON compras_material(categoria);
CREATE INDEX IF NOT EXISTS compras_material_nome_idx ON compras_material(nome);

CREATE TABLE IF NOT EXISTS compras_solicitacaomaterial (
    id                    BIGSERIAL PRIMARY KEY,
    quantidade_solicitada NUMERIC(10,2) NOT NULL,
    solicitante           VARCHAR(200) NOT NULL DEFAULT '',
    unidade_destino       VARCHAR(100) NOT NULL DEFAULT '',
    justificativa         TEXT NOT NULL DEFAULT '',
    status                VARCHAR(20) NOT NULL DEFAULT 'pendente',
    obs                   TEXT NOT NULL DEFAULT '',
    criado_em             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atendida_por_id       INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    material_id           BIGINT NOT NULL REFERENCES compras_material(id) ON DELETE CASCADE,
    solicitante_usuario_id INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS compras_solicitacao_material_idx ON compras_solicitacaomaterial(material_id);
CREATE INDEX IF NOT EXISTS compras_solicitacao_status_idx ON compras_solicitacaomaterial(status);

CREATE TABLE IF NOT EXISTS compras_pedidocompra (
    id              BIGSERIAL PRIMARY KEY,
    fornecedor      VARCHAR(200) NOT NULL DEFAULT '',
    cnpj_fornecedor VARCHAR(18) NOT NULL DEFAULT '',
    valor_unitario  NUMERIC(10,2) NOT NULL DEFAULT 0,
    valor_total     NUMERIC(12,2) NOT NULL DEFAULT 0,
    prazo_entrega   DATE,
    status          VARCHAR(30) NOT NULL DEFAULT 'em_cotacao',
    numero_pedido   VARCHAR(30) NOT NULL DEFAULT '',
    nota_fiscal     VARCHAR(30) NOT NULL DEFAULT '',
    obs             TEXT NOT NULL DEFAULT '',
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    aprovado_por_id INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    solicitacao_id  BIGINT NOT NULL REFERENCES compras_solicitacaomaterial(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS compras_pedido_solicitacao_idx ON compras_pedidocompra(solicitacao_id);
CREATE INDEX IF NOT EXISTS compras_pedido_status_idx ON compras_pedidocompra(status);

-- =============================================================================
-- SEÇÃO 9 — MÓDULO FINANCEIRO
-- =============================================================================

CREATE TABLE IF NOT EXISTS financeiro_documentofinanceiro (
    id                    BIGSERIAL PRIMARY KEY,
    tipo                  VARCHAR(20) NOT NULL,
    numero_documento      VARCHAR(50) NOT NULL DEFAULT '',
    descricao             VARCHAR(300) NOT NULL DEFAULT '',
    valor                 NUMERIC(14,2) NOT NULL DEFAULT 0,
    centro_custo          VARCHAR(100) NOT NULL DEFAULT '',
    unidade               VARCHAR(100) NOT NULL DEFAULT '',
    cnpj_emitente         VARCHAR(18) NOT NULL DEFAULT '',
    razao_social_emitente VARCHAR(200) NOT NULL DEFAULT '',
    contratos_vinculados  VARCHAR(200) NOT NULL DEFAULT '',
    data_emissao          DATE NOT NULL,
    data_vencimento       DATE,
    status                VARCHAR(30) NOT NULL DEFAULT 'recebido',
    motivo_rejeicao       TEXT NOT NULL DEFAULT '',
    criado_em             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    recebido_por_id       INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS financeiro_doc_status_idx ON financeiro_documentofinanceiro(status);
CREATE INDEX IF NOT EXISTS financeiro_doc_data_emissao_idx ON financeiro_documentofinanceiro(data_emissao);
CREATE INDEX IF NOT EXISTS financeiro_doc_data_vencimento_idx ON financeiro_documentofinanceiro(data_vencimento);

CREATE TABLE IF NOT EXISTS financeiro_auditoriaitem (
    id              BIGSERIAL PRIMARY KEY,
    item            VARCHAR(30) NOT NULL,
    status          VARCHAR(15) NOT NULL DEFAULT 'pendente',
    observacao      TEXT NOT NULL DEFAULT '',
    verificado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    verificado_por_id INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    documento_id    BIGINT NOT NULL REFERENCES financeiro_documentofinanceiro(id) ON DELETE CASCADE,
    CONSTRAINT financeiro_auditoria_doc_item_uniq UNIQUE (documento_id, item)
);
CREATE INDEX IF NOT EXISTS financeiro_auditoria_doc_idx ON financeiro_auditoriaitem(documento_id);

CREATE TABLE IF NOT EXISTS financeiro_lancamentoerp (
    id              BIGSERIAL PRIMARY KEY,
    descricao       VARCHAR(300) NOT NULL DEFAULT '',
    tipo            VARCHAR(10) NOT NULL DEFAULT 'debito',
    valor           NUMERIC(14,2) NOT NULL DEFAULT 0,
    centro_custo    VARCHAR(100) NOT NULL DEFAULT '',
    competencia     DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'rascunho',
    motivo_rejeicao TEXT NOT NULL DEFAULT '',
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finalizado_em   TIMESTAMPTZ,
    documento_id    BIGINT NOT NULL REFERENCES financeiro_documentofinanceiro(id) ON DELETE CASCADE,
    lancado_por_id  INTEGER REFERENCES auth_user(id) ON DELETE SET NULL,
    validado_por_id INTEGER REFERENCES auth_user(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS financeiro_lancamento_doc_idx ON financeiro_lancamentoerp(documento_id);
CREATE INDEX IF NOT EXISTS financeiro_lancamento_status_idx ON financeiro_lancamentoerp(status);

-- =============================================================================
-- SEÇÃO 10 — GRUPOS DE PRIVILÉGIO (Dados Iniciais)
-- =============================================================================
-- Insere os 14 grupos de privilégio por área.
-- O Django vai sincronizar automaticamente ao rodar: python manage.py criar_grupos

INSERT INTO auth_group (name) VALUES
    ('Recrutamento_Gestor'),
    ('Recrutamento_RH'),
    ('Admissional_RH'),
    ('Administrativo_Gestor'),
    ('Administrativo_Operador'),
    ('SESMET_Tecnico'),
    ('SESMET_Gestor'),
    ('Compras_Solicitante'),
    ('Compras_Almoxarife'),
    ('Compras_Aprovador'),
    ('Financeiro_Operador'),
    ('Financeiro_Auditor'),
    ('Financeiro_Aprovador'),
    ('Admin_Global')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- SEÇÃO 11 — TRIGGERS: updated_at automático
-- =============================================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplica o trigger a todas as tabelas com atualizado_em
DO $$
DECLARE
    tabelas TEXT[] := ARRAY[
        'core_perfilusuario',
        'admissional_colaborador',
        'admissional_admissao',
        'administrativo_demandaadministrativa',
        'compras_material',
        'compras_solicitacaomaterial',
        'compras_pedidocompra',
        'financeiro_documentofinanceiro',
        'recrutamento_vaga',
        'recrutamento_candidato'
    ];
    t TEXT;
BEGIN
    FOREACH t IN ARRAY tabelas LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS set_updated_at ON %I;
             CREATE TRIGGER set_updated_at
             BEFORE UPDATE ON %I
             FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();',
            t, t
        );
    END LOOP;
END;
$$;

-- =============================================================================
-- SEÇÃO 12 — ROW LEVEL SECURITY (RLS) — Supabase
-- =============================================================================
-- Ativa RLS nas tabelas principais.
-- ATENÇÃO: Com Django + psycopg2, o acesso ocorre via service_role,
-- que bypassa RLS por padrão. Estas políticas são para acesso direto via API REST.

-- Desabilita RLS para acesso via Django (serviço)
ALTER TABLE auth_user              DISABLE ROW LEVEL SECURITY;
ALTER TABLE core_perfilusuario     DISABLE ROW LEVEL SECURITY;
ALTER TABLE core_notificacao       DISABLE ROW LEVEL SECURITY;
ALTER TABLE core_aprovacaoregistro DISABLE ROW LEVEL SECURITY;

-- Para módulos operacionais, também desabilita (Django controla acesso):
ALTER TABLE recrutamento_vaga                     DISABLE ROW LEVEL SECURITY;
ALTER TABLE recrutamento_candidato                DISABLE ROW LEVEL SECURITY;
ALTER TABLE admissional_colaborador               DISABLE ROW LEVEL SECURITY;
ALTER TABLE admissional_admissao                  DISABLE ROW LEVEL SECURITY;
ALTER TABLE admissional_documentoadmissional      DISABLE ROW LEVEL SECURITY;
ALTER TABLE administrativo_demandaadministrativa  DISABLE ROW LEVEL SECURITY;
ALTER TABLE sesmet_integracaoseguranca            DISABLE ROW LEVEL SECURITY;
ALTER TABLE sesmet_ordemservico                   DISABLE ROW LEVEL SECURITY;
ALTER TABLE sesmet_registroepi                    DISABLE ROW LEVEL SECURITY;
ALTER TABLE compras_material                      DISABLE ROW LEVEL SECURITY;
ALTER TABLE compras_solicitacaomaterial           DISABLE ROW LEVEL SECURITY;
ALTER TABLE compras_pedidocompra                  DISABLE ROW LEVEL SECURITY;
ALTER TABLE financeiro_documentofinanceiro        DISABLE ROW LEVEL SECURITY;
ALTER TABLE financeiro_auditoriaitem              DISABLE ROW LEVEL SECURITY;
ALTER TABLE financeiro_lancamentoerp              DISABLE ROW LEVEL SECURITY;

-- =============================================================================
-- FIM DO SCRIPT
-- =============================================================================
-- Próximos passos após executar este SQL:
--
-- 1. Configure as variáveis de ambiente no Vercel:
--    DATABASE_URL, SECRET_KEY, DEBUG=False, SUPABASE_URL, SUPABASE_ANON_KEY
--
-- 2. No terminal local, rode as migrations do Django:
--    python manage.py migrate
--
-- 3. Crie os grupos de privilégio via management command:
--    python manage.py criar_grupos
--
-- 4. Crie o superusuário:
--    python manage.py createsuperuser
--
-- 5. Faça o deploy no Vercel (git push ou vercel --prod)
-- =============================================================================
