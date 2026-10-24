# Novo backend Stellar Legacy: plano de segurança (NÃO EXECUTADO)

Nesta G0.8, Render e Supabase **não foram alterados**. Este documento é um plano para criar um *novo projeto Supabase* e um *novo serviço de homologação*; o jogo WEB/iPhone permanece em produção.

## Domínios independentes

- `profiles`: UUID autenticado, apelido, facção, progresso validado pelo servidor.
- `account_roles`: papéis administrativos (ex.: `player`, `support`, `moderator`, `admin`) concedidos SOMENTE por backend privilegiado. Nunca confiar em um `is_admin` no cliente, nem em `user_metadata` editável.
- `alliances`, `alliance_members`, `alliance_invites`, `alliance_audit`: criadores, membro, papel, facção, ações auditáveis.
- `relays`, `relay_events`, `relay_influence`: domínio por facção, mapa, integridade, contestação, proteção temporal, auditoria; servidor autoritativo.
- `missions`, `pilot_mission_progress`, `season_pass`, `season_pass_claims`: catálogos versionados, conquistas e concessões validadas no servidor.
- `equipment_catalog`, `inventory_instances`, `loadout_presets`, `wallet_ledger`: itens e movimentações atômicas; proteger contra duplicações por transações e chaves idempotentes.
- `market_listings`, `auction_bids`, `auction_settlements`: lances concorrentes com encerramento transacional, reserva e estorno de saldo.
- `store_products`, `purchase_receipts`: distinguir créditos obtidos no jogo de transações premium verificadas externamente.
- `admin_audit_log`: quem fez o quê, quando, antes/depois, motivo e solicitação assinada.

## Regras mínimas

1. Projeto novo com chaves novas, dados isolados e backup. Nunca migrar ou copiar contas/senhas sem consentimento.
2. RLS ativa em todas as tabelas expostas. Políticas por proprietário/facção/papel, não apenas `TO authenticated`.
3. Chave privilegiada somente no servidor Render; **nunca** no APK, scripts Godot ou GitHub público.
4. Movimentação, danos, inventário, créditos, relés, leilões, missões e premium aprovados pelo backend. Cliente envia intenção, servidor decide.
5. ADM exige autenticação, autorização revalidada no servidor, auditoria e revogação.
6. Premium requer validação de recibos e idempotência; não confiar em cliques locais.
7. Leilões reais exigem tratamento de concorrência, expiração e liquidação segura.
8. PvP pode usar WebSocket para snapshots/deltas e eventos; este é um trabalho futuro, não parte da G0.8 offline.

## Ordem recomendada depois dos protótipos

1. Novo Supabase de homologação e seed de catálogos próprios do Stellar Legacy.
2. Autenticação, perfil e roles por backend.
3. Relés PvP com estados autoritativos e grupos de mapa.
4. Alianças, missões e progressão sincronizadas.
5. Economia, loja, leilão, passe e premium com integridade e auditoria.

**Não existe Arena planejada nesta arquitetura.** Conquista de relés no 4-X será o foco territorial.
