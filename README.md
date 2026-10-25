# Stellar Legacy — Design System e continuidade por etapas

Plano oficial: [ROADMAP](docs/ROADMAP.md), [PROJECT_STATUS](docs/PROJECT_STATUS.md)
e [aprovações do proprietário](docs/APPROVALS.md). Sem duração predeterminada.

- **00 APROVADO**; direção visual da fundação 01 aprovada.
- **01 AGUARDANDO APROVAÇÃO** dos componentes adicionais desta entrega.
- [Instalação do ZIP incremental](docs/DELIVERY_01_COMPONENTS.md) e
  [contratos dos componentes](docs/design/COMPONENTS.md).
- [Fundação visual preservada](docs/design/FOUNDATION.md).

**CONFIG → DESIGN SYSTEM:** abas IDENTIDADE e COMPONENTES. Abas, listas com busca,
seleção e campos com validação podem ser avaliados sem alterar dados do jogador.
HUD/Hangar, modelos, combate, inventário e saves existentes foram preservados.
Branch local: `codex/design-system-components`. Entrega em ZIP de até 25 MB.

As seções abaixo são o histórico das versões anteriores. Esta revisão não instala
integralmente os antigos ZIPs e não altera produção.

---

# G0.20 — Naves V2 HQ definitivas

- 13 naves definitivas V2 HQ substituem os protótipos G0.18, sem mudar nomes, atributos, preços, desbloqueios nem inventário.
- Materiais, texturas e malhas originais preservados; apenas escala e orientação de nó GLB corrigidas para a cena Godot.
- Miniaturas derivadas das novas malhas e texturas para Hangar e Loja.
- Instalação GitHub universal **em duas etapas** (cada ZIP menor que 25 MB); consulte `docs/G020_INSTALACAO_DUAS_ETAPAS.md`.
- Cliente offline; nenhuma alteração no Supabase, Render ou jogo web.

# G0.19 — Escudos GLB HQ

Integrados 8 escudos GLB HQ com visualizacoes renderizadas diretamente das malhas na loja, inventario e hangar. Sem alterar moedas, precos existentes, save local nem atributos. Detalhes: `docs/G019_ESCUDOS_HQ.md`.

## G0.17 — Minérios HQ e Caixas Estelares (Godot Android)

- GLBs HQ originais do pacote enviado: minérios (ciano, violeta, esmeralda, ouro e plasma), BOX BÔNUS e BOX LOOT NPC.
- Mineração por aproximação com limite de porão da nave, salvamento offline e venda de minerais por Créditos locais na base X-1 / Terminal Mercante.
- Caixas bônus com recompensa individual, respawn de 40–70 s, 20 por setor comum, 30 no PvP 4-X e nenhuma em arenas Astrais.
- BOX LOOT de NPC, com minérios distribuídos por espécie, duração de 30 s e coleta parcial quando o porão estiver quase cheio.
- Minerais e caixas separados no minimapa, com carregamento visual por distância preservando a qualidade integral dos GLBs.
- Módulos do AUX-9 equipados (`Coletor de Minérios`, `Coletor de Cargas`) ampliam o alcance de coleta, sem botões de ativação no HUD.
- **Não usa Supabase/Render nem altera o jogo web**; créditos, Stellar Dust e munições de recompensa são demonstrativos neste cliente.
- Dados, diferenças da versão web e testes: [docs/G017_MINERACAO_BOXES_LOOT.md](docs/G017_MINERACAO_BOXES_LOOT.md).

# Stellar Legacy — Godot G0.16 | Hangar Premium

Cliente Android Godot offline. Baseado na G0.15 e no esquema de balanceamento oficial importado do projeto web.

**Novo hangar:** GLB real da nave ativa, cartões dinâmicos dos melhores equipamentos *instalados*, status para categorias sem equipamento, atributos reais da nave e galeria das 13 naves com bloqueio de aquisição. Naves bloqueadas não podem ser equipadas sem compra.

O inventário da G0.15 foi preservado; nada foi concedido gratuitamente na atualização. Compras continuam **simulações locais**, sem acesso de escrita ao Supabase.

Instruções: `docs/G016_HANGAR_PREMIUM.md`

---

# Stellar Legacy — Godot G0.14 | Fullscreen Arsenal & Balance

Android primeiro. Projeto Godot independente. **Nenhum acesso a Supabase/Render durante a partida offline.**

## Novidades
- Preços de referência: snapshot somente-leitura do `public.live_shop_prices_v16` do Supabase web.
- Stats: snapshot de `public.game_balance_entries_v1909`, com prioridade sobre `public/data.js` histórico.
- 13 GLBs integrais preservados, atributos HP/velocidade/porão/laser/gerador/extras oficiais.
- Naves de evento não ficam disponíveis na loja comum, mesmo aparecendo na vitrine.
- Loja fullscreen, filtros COMUM/ELITE, cards maiores, modelos GLB por seleção.
- Créditos (COMUM) / Stellarium (ELITE), com **carteira LOCAL DE TESTE** separada de qualquer economia online.
- 29 modelos 3D novos (motores, armas, extras, munições laser/mísseis, módulos AUX), sem alterar GLBs anteriores.
- Inventário e CONF 1/CONF 2 com drones, AUX e módulos configurados separadamente.
- Geradores são compartilhados por **escudos + motores**, e slots respeitam a nave ativa.
- Aurora inicia com ARC-1, SG-1, THR-1 e Reparador Comum; como a Aurora tem apenas 1 slot de gerador compartilhado, THR-1 fica no inventário até remover o escudo.

## Fonte dos dados e observações
- `docs/G014_CATALOGO_VERIFICADO.json` contém nome oficial e metadados de referência sem credenciais e sem dados de jogadores.
- Preços indicados são valores da tabela de loja na data 2026-10-24. **Snapshot**, não sincronização online.
- Não são produtos nem pagamentos reais: dinheiro de teste inicial da G0.14 é 150.000.000 Créditos e 2.500.000 Stellarium. O saldo de teste pode se esgotar.
- Itens de evento sem linha ativa/visível na loja estão indisponíveis.
- Diversas representações GLB novas são modelos originais de prototipagem, não cópias artísticas exatas dos conceitos cinematográficos.
- Alguns efeitos avançados de equipamentos especiais ainda são representados somente no inventário; poderes finais serão migrados em etapas.
- Munições compradas são registradas em estoque local, mas o combate ainda é demonstrativo e **não desconta munições automaticamente**.

## Instalação
1. Para Android, importe o ZIP COMPLETO como projeto Godot separado, ou atualize a pasta do projeto com ZIP ATUALIZACAO no instalador GitHub.
2. Não suba os dois ZIPs simultaneamente para o instalador.
3. Execute a etapa de validação do GitHub Actions com Godot 4.5.2.
4. Teste gameplay no editor Android e envie logs de erro caso haja incompatibilidade.

## Segurança
Não altera nem lê perfis/saldos de jogadores existentes. Nenhum SQL de escrita. Repositório web preservado.
