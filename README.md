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
