-- MIGRATION: contenttypes - 0001_initial\nBEGIN;
--
-- Create model ContentType
--
CREATE TABLE "django_content_type" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(100) NOT NULL, "app_label" varchar(100) NOT NULL, "model" varchar(100) NOT NULL);
--
-- Alter unique_together for contenttype (1 constraint(s))
--
CREATE UNIQUE INDEX "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" ("app_label", "model");
COMMIT;
\n\n-- MIGRATION: auth - 0001_initial\nBEGIN;
--
-- Create model Permission
--
CREATE TABLE "auth_permission" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(50) NOT NULL, "content_type_id" integer NOT NULL REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED, "codename" varchar(100) NOT NULL);
--
-- Create model Group
--
CREATE TABLE "auth_group" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(80) NOT NULL UNIQUE);
CREATE TABLE "auth_group_permissions" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "group_id" integer NOT NULL REFERENCES "auth_group" ("id") DEFERRABLE INITIALLY DEFERRED, "permission_id" integer NOT NULL REFERENCES "auth_permission" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model User
--
CREATE TABLE "auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "password" varchar(128) NOT NULL, "last_login" datetime NOT NULL, "is_superuser" bool NOT NULL, "username" varchar(30) NOT NULL UNIQUE, "first_name" varchar(30) NOT NULL, "last_name" varchar(30) NOT NULL, "email" varchar(75) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL);
CREATE TABLE "auth_user_groups" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "group_id" integer NOT NULL REFERENCES "auth_group" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE TABLE "auth_user_user_permissions" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "permission_id" integer NOT NULL REFERENCES "auth_permission" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE UNIQUE INDEX "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" ("content_type_id", "codename");
CREATE INDEX "auth_permission_content_type_id_2f476e4b" ON "auth_permission" ("content_type_id");
CREATE UNIQUE INDEX "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" ("group_id", "permission_id");
CREATE INDEX "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" ("group_id");
CREATE INDEX "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" ("permission_id");
CREATE UNIQUE INDEX "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" ("user_id", "group_id");
CREATE INDEX "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" ("user_id");
CREATE INDEX "auth_user_groups_group_id_97559544" ON "auth_user_groups" ("group_id");
CREATE UNIQUE INDEX "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" ("user_id", "permission_id");
CREATE INDEX "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" ("user_id");
CREATE INDEX "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" ("permission_id");
COMMIT;
\n\n-- MIGRATION: admin - 0001_initial\nBEGIN;
--
-- Create model LogEntry
--
CREATE TABLE "django_admin_log" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "action_time" datetime NOT NULL, "object_id" text NULL, "object_repr" varchar(200) NOT NULL, "action_flag" smallint unsigned NOT NULL CHECK ("action_flag" >= 0), "change_message" text NOT NULL, "content_type_id" integer NULL REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" ("content_type_id");
CREATE INDEX "django_admin_log_user_id_c564eba6" ON "django_admin_log" ("user_id");
COMMIT;
\n\n-- MIGRATION: admin - 0002_logentry_remove_auto_add\nBEGIN;
--
-- Alter field action_time on logentry
--
CREATE TABLE "new__django_admin_log" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "action_time" datetime NOT NULL, "object_id" text NULL, "object_repr" varchar(200) NOT NULL, "action_flag" smallint unsigned NOT NULL CHECK ("action_flag" >= 0), "change_message" text NOT NULL, "content_type_id" integer NULL REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "new__django_admin_log" ("id", "object_id", "object_repr", "action_flag", "change_message", "content_type_id", "user_id", "action_time") SELECT "id", "object_id", "object_repr", "action_flag", "change_message", "content_type_id", "user_id", "action_time" FROM "django_admin_log";
DROP TABLE "django_admin_log";
ALTER TABLE "new__django_admin_log" RENAME TO "django_admin_log";
CREATE INDEX "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" ("content_type_id");
CREATE INDEX "django_admin_log_user_id_c564eba6" ON "django_admin_log" ("user_id");
COMMIT;
\n\n-- MIGRATION: admin - 0003_logentry_add_action_flag_choices\nBEGIN;
--
-- Alter field action_flag on logentry
--
-- (no-op)
COMMIT;
\n\n-- MIGRATION: administrativo - 0001_initial\nBEGIN;
--
-- Create model DemandaAdministrativa
--
CREATE TABLE "administrativo_demandaadministrativa" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "tipo" varchar(30) NOT NULL, "titulo" varchar(200) NOT NULL, "descricao" text NOT NULL, "requisitante" varchar(200) NOT NULL, "prioridade" varchar(10) NOT NULL, "status" varchar(30) NOT NULL, "motivo_rejeicao" text NOT NULL, "observacoes" text NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "concluido_em" datetime NULL, "requisitante_usuario_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "responsavel_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "administrativo_demandaadministrativa_requisitante_usuario_id_ef581f81" ON "administrativo_demandaadministrativa" ("requisitante_usuario_id");
CREATE INDEX "administrativo_demandaadministrativa_responsavel_id_c85d6b10" ON "administrativo_demandaadministrativa" ("responsavel_id");
COMMIT;
\n\n-- MIGRATION: admissional - 0001_initial\nBEGIN;
--
-- Create model Colaborador
--
CREATE TABLE "admissional_colaborador" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "nome" varchar(200) NOT NULL, "cpf" varchar(14) NOT NULL UNIQUE, "rg" varchar(20) NOT NULL, "data_nascimento" date NULL, "email" varchar(254) NOT NULL, "telefone" varchar(20) NOT NULL, "endereco" text NOT NULL, "cargo" varchar(200) NOT NULL, "setor" varchar(100) NOT NULL, "unidade" varchar(100) NOT NULL, "marca" varchar(20) NOT NULL, "data_admissao" date NOT NULL, "status" varchar(20) NOT NULL, "pis_pasep" varchar(20) NOT NULL, "ctps" varchar(30) NOT NULL, "salario" decimal NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL);
--
-- Create model Admissao
--
CREATE TABLE "admissional_admissao" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "candidato_nome" varchar(200) NOT NULL, "candidato_email" varchar(254) NOT NULL, "candidato_telefone" varchar(20) NOT NULL, "vaga_nome" varchar(200) NOT NULL, "unidade_destino" varchar(100) NOT NULL, "status" varchar(30) NOT NULL, "observacoes" text NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "concluido_em" datetime NULL, "responsavel_rh_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "colaborador_id" bigint NULL UNIQUE REFERENCES "admissional_colaborador" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model DocumentoAdmissional
--
CREATE TABLE "admissional_documentoadmissional" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "tipo" varchar(30) NOT NULL, "status" varchar(20) NOT NULL, "observacao" text NOT NULL, "atualizado_em" datetime NOT NULL, "admissao_id" bigint NOT NULL REFERENCES "admissional_admissao" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "admissional_admissao_responsavel_rh_id_b3fe2f7f" ON "admissional_admissao" ("responsavel_rh_id");
CREATE UNIQUE INDEX "admissional_documentoadmissional_admissao_id_tipo_5f65fb75_uniq" ON "admissional_documentoadmissional" ("admissao_id", "tipo");
CREATE INDEX "admissional_documentoadmissional_admissao_id_b808c4ac" ON "admissional_documentoadmissional" ("admissao_id");
COMMIT;
\n\n-- MIGRATION: contenttypes - 0002_remove_content_type_name\nBEGIN;
--
-- Change Meta options on contenttype
--
-- (no-op)
--
-- Alter field name on contenttype
--
CREATE TABLE "new__django_content_type" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(100) NULL, "app_label" varchar(100) NOT NULL, "model" varchar(100) NOT NULL);
INSERT INTO "new__django_content_type" ("id", "app_label", "model", "name") SELECT "id", "app_label", "model", "name" FROM "django_content_type";
DROP TABLE "django_content_type";
ALTER TABLE "new__django_content_type" RENAME TO "django_content_type";
CREATE UNIQUE INDEX "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" ("app_label", "model");
--
-- Raw Python operation
--
-- THIS OPERATION CANNOT BE WRITTEN AS SQL
--
-- Remove field name from contenttype
--
ALTER TABLE "django_content_type" DROP COLUMN "name";
COMMIT;
\n\n-- MIGRATION: auth - 0002_alter_permission_name_max_length\nBEGIN;
--
-- Alter field name on permission
--
CREATE TABLE "new__auth_permission" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(255) NOT NULL, "content_type_id" integer NOT NULL REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED, "codename" varchar(100) NOT NULL);
INSERT INTO "new__auth_permission" ("id", "content_type_id", "codename", "name") SELECT "id", "content_type_id", "codename", "name" FROM "auth_permission";
DROP TABLE "auth_permission";
ALTER TABLE "new__auth_permission" RENAME TO "auth_permission";
CREATE UNIQUE INDEX "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" ("content_type_id", "codename");
CREATE INDEX "auth_permission_content_type_id_2f476e4b" ON "auth_permission" ("content_type_id");
COMMIT;
\n\n-- MIGRATION: auth - 0003_alter_user_email_max_length\nBEGIN;
--
-- Alter field email on user
--
CREATE TABLE "new__auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "email" varchar(254) NOT NULL, "password" varchar(128) NOT NULL, "last_login" datetime NOT NULL, "is_superuser" bool NOT NULL, "username" varchar(30) NOT NULL UNIQUE, "first_name" varchar(30) NOT NULL, "last_name" varchar(30) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL);
INSERT INTO "new__auth_user" ("id", "password", "last_login", "is_superuser", "username", "first_name", "last_name", "is_staff", "is_active", "date_joined", "email") SELECT "id", "password", "last_login", "is_superuser", "username", "first_name", "last_name", "is_staff", "is_active", "date_joined", "email" FROM "auth_user";
DROP TABLE "auth_user";
ALTER TABLE "new__auth_user" RENAME TO "auth_user";
COMMIT;
\n\n-- MIGRATION: auth - 0004_alter_user_username_opts\nBEGIN;
--
-- Alter field username on user
--
-- (no-op)
COMMIT;
\n\n-- MIGRATION: auth - 0005_alter_user_last_login_null\nBEGIN;
--
-- Alter field last_login on user
--
CREATE TABLE "new__auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "last_login" datetime NULL, "password" varchar(128) NOT NULL, "is_superuser" bool NOT NULL, "username" varchar(30) NOT NULL UNIQUE, "first_name" varchar(30) NOT NULL, "last_name" varchar(30) NOT NULL, "email" varchar(254) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL);
INSERT INTO "new__auth_user" ("id", "password", "is_superuser", "username", "first_name", "last_name", "email", "is_staff", "is_active", "date_joined", "last_login") SELECT "id", "password", "is_superuser", "username", "first_name", "last_name", "email", "is_staff", "is_active", "date_joined", "last_login" FROM "auth_user";
DROP TABLE "auth_user";
ALTER TABLE "new__auth_user" RENAME TO "auth_user";
COMMIT;
\n\n-- MIGRATION: auth - 0007_alter_validators_add_error_messages\nBEGIN;
--
-- Alter field username on user
--
-- (no-op)
COMMIT;
\n\n-- MIGRATION: auth - 0008_alter_user_username_max_length\nBEGIN;
--
-- Alter field username on user
--
CREATE TABLE "new__auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "username" varchar(150) NOT NULL UNIQUE, "password" varchar(128) NOT NULL, "last_login" datetime NULL, "is_superuser" bool NOT NULL, "first_name" varchar(30) NOT NULL, "last_name" varchar(30) NOT NULL, "email" varchar(254) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL);
INSERT INTO "new__auth_user" ("id", "password", "last_login", "is_superuser", "first_name", "last_name", "email", "is_staff", "is_active", "date_joined", "username") SELECT "id", "password", "last_login", "is_superuser", "first_name", "last_name", "email", "is_staff", "is_active", "date_joined", "username" FROM "auth_user";
DROP TABLE "auth_user";
ALTER TABLE "new__auth_user" RENAME TO "auth_user";
COMMIT;
\n\n-- MIGRATION: auth - 0009_alter_user_last_name_max_length\nBEGIN;
--
-- Alter field last_name on user
--
CREATE TABLE "new__auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "last_name" varchar(150) NOT NULL, "password" varchar(128) NOT NULL, "last_login" datetime NULL, "is_superuser" bool NOT NULL, "username" varchar(150) NOT NULL UNIQUE, "first_name" varchar(30) NOT NULL, "email" varchar(254) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL);
INSERT INTO "new__auth_user" ("id", "password", "last_login", "is_superuser", "username", "first_name", "email", "is_staff", "is_active", "date_joined", "last_name") SELECT "id", "password", "last_login", "is_superuser", "username", "first_name", "email", "is_staff", "is_active", "date_joined", "last_name" FROM "auth_user";
DROP TABLE "auth_user";
ALTER TABLE "new__auth_user" RENAME TO "auth_user";
COMMIT;
\n\n-- MIGRATION: auth - 0010_alter_group_name_max_length\nBEGIN;
--
-- Alter field name on group
--
CREATE TABLE "new__auth_group" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(150) NOT NULL UNIQUE);
INSERT INTO "new__auth_group" ("id", "name") SELECT "id", "name" FROM "auth_group";
DROP TABLE "auth_group";
ALTER TABLE "new__auth_group" RENAME TO "auth_group";
COMMIT;
\n\n-- MIGRATION: auth - 0011_update_proxy_permissions\nBEGIN;
--
-- Raw Python operation
--
-- THIS OPERATION CANNOT BE WRITTEN AS SQL
COMMIT;
\n\n-- MIGRATION: auth - 0012_alter_user_first_name_max_length\nBEGIN;
--
-- Alter field first_name on user
--
CREATE TABLE "new__auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "first_name" varchar(150) NOT NULL, "password" varchar(128) NOT NULL, "last_login" datetime NULL, "is_superuser" bool NOT NULL, "username" varchar(150) NOT NULL UNIQUE, "last_name" varchar(150) NOT NULL, "email" varchar(254) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL);
INSERT INTO "new__auth_user" ("id", "password", "last_login", "is_superuser", "username", "last_name", "email", "is_staff", "is_active", "date_joined", "first_name") SELECT "id", "password", "last_login", "is_superuser", "username", "last_name", "email", "is_staff", "is_active", "date_joined", "first_name" FROM "auth_user";
DROP TABLE "auth_user";
ALTER TABLE "new__auth_user" RENAME TO "auth_user";
COMMIT;
\n\n-- MIGRATION: compras - 0001_initial\nBEGIN;
--
-- Create model Material
--
CREATE TABLE "compras_material" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "codigo" varchar(20) NOT NULL UNIQUE, "nome" varchar(200) NOT NULL, "descricao" text NOT NULL, "categoria" varchar(20) NOT NULL, "unidade_medida" varchar(5) NOT NULL, "quantidade_estoque" decimal NOT NULL, "estoque_minimo" decimal NOT NULL, "preco_unitario" decimal NULL, "fornecedor_preferencial" varchar(200) NOT NULL, "localizacao" varchar(100) NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL);
--
-- Create model SolicitacaoMaterial
--
CREATE TABLE "compras_solicitacaomaterial" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "quantidade_solicitada" decimal NOT NULL, "solicitante" varchar(200) NOT NULL, "unidade_destino" varchar(100) NOT NULL, "justificativa" text NOT NULL, "status" varchar(20) NOT NULL, "obs" text NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "atendida_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "material_id" bigint NOT NULL REFERENCES "compras_material" ("id") DEFERRABLE INITIALLY DEFERRED, "solicitante_usuario_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model PedidoCompra
--
CREATE TABLE "compras_pedidocompra" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "fornecedor" varchar(200) NOT NULL, "cnpj_fornecedor" varchar(18) NOT NULL, "valor_unitario" decimal NOT NULL, "valor_total" decimal NOT NULL, "prazo_entrega" date NULL, "status" varchar(30) NOT NULL, "numero_pedido" varchar(30) NOT NULL, "nota_fiscal" varchar(30) NOT NULL, "obs" text NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "aprovado_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "solicitacao_id" bigint NOT NULL REFERENCES "compras_solicitacaomaterial" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "compras_solicitacaomaterial_atendida_por_id_7884bec2" ON "compras_solicitacaomaterial" ("atendida_por_id");
CREATE INDEX "compras_solicitacaomaterial_material_id_24600d72" ON "compras_solicitacaomaterial" ("material_id");
CREATE INDEX "compras_solicitacaomaterial_solicitante_usuario_id_7781011c" ON "compras_solicitacaomaterial" ("solicitante_usuario_id");
CREATE INDEX "compras_pedidocompra_aprovado_por_id_4dbd6198" ON "compras_pedidocompra" ("aprovado_por_id");
CREATE INDEX "compras_pedidocompra_solicitacao_id_c0e52692" ON "compras_pedidocompra" ("solicitacao_id");
COMMIT;
\n\n-- MIGRATION: core - 0001_initial\nBEGIN;
--
-- Create model Notificacao
--
CREATE TABLE "core_notificacao" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "tipo" varchar(20) NOT NULL, "modulo" varchar(20) NOT NULL, "titulo" varchar(200) NOT NULL, "mensagem" text NOT NULL, "lida" bool NOT NULL, "url_acao" varchar(200) NOT NULL, "criado_em" datetime NOT NULL, "destinatario_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model PerfilUsuario
--
CREATE TABLE "core_perfilusuario" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "perfil" varchar(20) NOT NULL, "marca" varchar(20) NOT NULL, "unidade" varchar(100) NOT NULL, "telefone" varchar(20) NOT NULL, "avatar_iniciais" varchar(3) NOT NULL, "criado_em" datetime NOT NULL, "usuario_id" integer NOT NULL UNIQUE REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "core_notificacao_destinatario_id_f3f2984a" ON "core_notificacao" ("destinatario_id");
COMMIT;
\n\n-- MIGRATION: financeiro - 0001_initial\nBEGIN;
--
-- Create model DocumentoFinanceiro
--
CREATE TABLE "financeiro_documentofinanceiro" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "tipo" varchar(20) NOT NULL, "numero_documento" varchar(50) NOT NULL, "descricao" varchar(300) NOT NULL, "valor" decimal NOT NULL, "centro_custo" varchar(100) NOT NULL, "unidade" varchar(100) NOT NULL, "cnpj_emitente" varchar(18) NOT NULL, "razao_social_emitente" varchar(200) NOT NULL, "contratos_vinculados" varchar(200) NOT NULL, "data_emissao" date NOT NULL, "data_vencimento" date NULL, "status" varchar(30) NOT NULL, "motivo_rejeicao" text NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "recebido_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model LancamentoERP
--
CREATE TABLE "financeiro_lancamentoerp" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "descricao" varchar(300) NOT NULL, "tipo" varchar(10) NOT NULL, "valor" decimal NOT NULL, "centro_custo" varchar(100) NOT NULL, "competencia" date NOT NULL, "status" varchar(20) NOT NULL, "motivo_rejeicao" text NOT NULL, "criado_em" datetime NOT NULL, "finalizado_em" datetime NULL, "documento_id" bigint NOT NULL REFERENCES "financeiro_documentofinanceiro" ("id") DEFERRABLE INITIALLY DEFERRED, "lancado_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "validado_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model AuditoriaItem
--
CREATE TABLE "financeiro_auditoriaitem" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "item" varchar(30) NOT NULL, "status" varchar(15) NOT NULL, "observacao" text NOT NULL, "verificado_em" datetime NOT NULL, "verificado_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "documento_id" bigint NOT NULL REFERENCES "financeiro_documentofinanceiro" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "financeiro_documentofinanceiro_recebido_por_id_1e89cfb9" ON "financeiro_documentofinanceiro" ("recebido_por_id");
CREATE INDEX "financeiro_lancamentoerp_documento_id_dc4f6138" ON "financeiro_lancamentoerp" ("documento_id");
CREATE INDEX "financeiro_lancamentoerp_lancado_por_id_4e4a8859" ON "financeiro_lancamentoerp" ("lancado_por_id");
CREATE INDEX "financeiro_lancamentoerp_validado_por_id_d0e36200" ON "financeiro_lancamentoerp" ("validado_por_id");
CREATE UNIQUE INDEX "financeiro_auditoriaitem_documento_id_item_f1594552_uniq" ON "financeiro_auditoriaitem" ("documento_id", "item");
CREATE INDEX "financeiro_auditoriaitem_verificado_por_id_3c931a6f" ON "financeiro_auditoriaitem" ("verificado_por_id");
CREATE INDEX "financeiro_auditoriaitem_documento_id_58dd8b93" ON "financeiro_auditoriaitem" ("documento_id");
COMMIT;
\n\n-- MIGRATION: recrutamento - 0001_initial\nBEGIN;
--
-- Create model Vaga
--
CREATE TABLE "recrutamento_vaga" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "nome_vaga" varchar(200) NOT NULL, "quantidade_colaboradores" integer unsigned NOT NULL CHECK ("quantidade_colaboradores" >= 0), "cidade" varchar(100) NOT NULL, "unidade" varchar(100) NOT NULL, "perfil_desejado" text NOT NULL, "atividades" text NOT NULL, "horario_trabalho" varchar(100) NOT NULL, "tipo_contratacao" varchar(20) NOT NULL, "valor_salario" decimal NOT NULL, "previsao_inicio" date NOT NULL, "exige_experiencia" bool NOT NULL, "descricao_experiencia" text NOT NULL, "motivo_solicitacao" text NOT NULL, "gestor_responsavel" varchar(200) NOT NULL, "status" varchar(30) NOT NULL, "observacoes" text NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "gestor_usuario_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model Candidato
--
CREATE TABLE "recrutamento_candidato" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "nome" varchar(200) NOT NULL, "email" varchar(254) NOT NULL, "telefone" varchar(20) NOT NULL, "cpf" varchar(14) NOT NULL, "etapa_atual" varchar(20) NOT NULL, "aprovado" bool NULL, "curriculum_obs" text NOT NULL, "avaliacao_comportamental" text NOT NULL, "resultado_entrevista" text NOT NULL, "encaminhado_admissao" bool NOT NULL, "criado_em" datetime NOT NULL, "atualizado_em" datetime NOT NULL, "avaliado_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "vaga_id" bigint NOT NULL REFERENCES "recrutamento_vaga" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "recrutamento_vaga_gestor_usuario_id_3b3c9200" ON "recrutamento_vaga" ("gestor_usuario_id");
CREATE INDEX "recrutamento_candidato_avaliado_por_id_5dea98f6" ON "recrutamento_candidato" ("avaliado_por_id");
CREATE INDEX "recrutamento_candidato_vaga_id_d1499630" ON "recrutamento_candidato" ("vaga_id");
COMMIT;
\n\n-- MIGRATION: sesmet - 0001_initial\nBEGIN;
--
-- Create model IntegracaoSeguranca
--
CREATE TABLE "sesmet_integracaoseguranca" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "data_integracao" date NOT NULL, "apresentador" varchar(200) NOT NULL, "missao_visao_valores" bool NOT NULL, "normas_seguranca" bool NOT NULL, "uso_epis" bool NOT NULL, "procedimentos_emergencia" bool NOT NULL, "concluida" bool NOT NULL, "obs" text NOT NULL, "criado_em" datetime NOT NULL, "colaborador_id" bigint NOT NULL UNIQUE REFERENCES "admissional_colaborador" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model OrdemServico
--
CREATE TABLE "sesmet_ordemservico" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "numero" varchar(20) NOT NULL UNIQUE, "descricao_riscos" text NOT NULL, "medidas_preventivas" text NOT NULL, "epis_obrigatorios" text NOT NULL, "data_emissao" date NOT NULL, "assinado" bool NOT NULL, "data_assinatura" date NULL, "criado_em" datetime NOT NULL, "colaborador_id" bigint NOT NULL REFERENCES "admissional_colaborador" ("id") DEFERRABLE INITIALLY DEFERRED, "emitido_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model RegistroEPI
--
CREATE TABLE "sesmet_registroepi" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "tipo_epi" varchar(30) NOT NULL, "data_entrega" date NOT NULL, "quantidade" integer unsigned NOT NULL CHECK ("quantidade" >= 0), "numero_ca" varchar(20) NOT NULL, "data_validade" date NULL, "status" varchar(20) NOT NULL, "motivo_substituicao" varchar(20) NOT NULL, "assinado" bool NOT NULL, "obs" text NOT NULL, "criado_em" datetime NOT NULL, "colaborador_id" bigint NOT NULL REFERENCES "admissional_colaborador" ("id") DEFERRABLE INITIALLY DEFERRED, "registrado_por_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX "sesmet_ordemservico_colaborador_id_c48fbedf" ON "sesmet_ordemservico" ("colaborador_id");
CREATE INDEX "sesmet_ordemservico_emitido_por_id_db776e18" ON "sesmet_ordemservico" ("emitido_por_id");
CREATE INDEX "sesmet_registroepi_colaborador_id_9406e453" ON "sesmet_registroepi" ("colaborador_id");
CREATE INDEX "sesmet_registroepi_registrado_por_id_2537c4ac" ON "sesmet_registroepi" ("registrado_por_id");
COMMIT;
\n\n-- MIGRATION: sessions - 0001_initial\nBEGIN;
--
-- Create model Session
--
CREATE TABLE "django_session" ("session_key" varchar(40) NOT NULL PRIMARY KEY, "session_data" text NOT NULL, "expire_date" datetime NOT NULL);
CREATE INDEX "django_session_expire_date_a5c62663" ON "django_session" ("expire_date");
COMMIT;
\n\n