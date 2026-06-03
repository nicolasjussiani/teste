-- =============================================================================
-- ERP ECOPREMIUM — Script para criar o primeiro superusuário admin
-- =============================================================================
-- Cole este script no SQL Editor do Supabase e execute.
-- Senha do usuário criado: admin123  (troque depois!)
--
-- Supabase Dashboard → SQL Editor → New Query → Cole → Run
-- =============================================================================

-- 1. Garante que as sequences do Django estejam presentes
--    (rode o supabase_schema.sql antes deste script se ainda não rodou)

-- 2. Cria o superusuário "admin"
INSERT INTO auth_user (
    password,
    last_login,
    is_superuser,
    username,
    first_name,
    last_name,
    email,
    is_staff,
    is_active,
    date_joined
) VALUES (
    -- Hash Django válido para a senha: admin123
    'pbkdf2_sha256$1200000$iSifJ2WGWC8doj08PcEptr$6JPyoJsNWFeM6j8xrCad7wxkTnXX7nnJN97LcKRNZ6s=',
    NOW(),
    TRUE,
    'admin',
    'Admin',
    'ERP',
    'admin@ecopremium.com.br',
    TRUE,
    TRUE,
    NOW()
) ON CONFLICT (username) DO UPDATE SET
    password    = EXCLUDED.password,
    is_superuser= TRUE,
    is_staff    = TRUE,
    is_active   = TRUE;

-- 3. Atribui o grupo Admin_Global ao usuário (se já existir)
INSERT INTO auth_user_groups (user_id, group_id)
SELECT u.id, g.id
FROM auth_user u, auth_group g
WHERE u.username = 'admin'
  AND g.name = 'Admin_Global'
ON CONFLICT DO NOTHING;

-- 4. Verifica resultado
SELECT id, username, email, is_superuser, is_staff, is_active
FROM auth_user
WHERE username = 'admin';

-- =============================================================================
-- Login no sistema:
--   URL:   https://teste-eight-tau-53.vercel.app/login/
--   Usuário: admin
--   Senha:   admin123
--
-- TROQUE A SENHA depois de entrar!
--   Django Admin → /admin/ → Users → admin → Change password
-- =============================================================================
