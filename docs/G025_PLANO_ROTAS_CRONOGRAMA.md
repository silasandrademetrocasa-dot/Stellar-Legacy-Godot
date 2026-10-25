# STELLAR LEGACY • FASE G0.25 PIXEL ART
**Data de planejamento:** 25/10/2026  
**Fonte de rotas:** `stellar_godot_web_routes.zip` (Web V48.1)  
**Vídeo analisado:** `XRecorder_20261025_06.mp4` (~77 s)  
**Base técnica:** cliente Godot G0.24, offline e independente do Supabase de produção.

## Diagnóstico do vídeo
- Sprites das naves pequenos na visão geral e orientação angular inconsistentes com o enquadramento.
- Câmera anterior: deslocamento `(0,82,18)` / tamanho ortográfico `42`; proposta atual `(0,69,32)` / tamanho `36`.
- Hangar e Equipamentos ainda renderizavam prévias 3D; troca implementada por sprites pixelados.
- Base orbital com peças 3D procedurais grandes, substituída por cartão espacial Sprite3D.
- Dados de combate, HP, escudo e armas precisam permanecer intocados para comparação funcional.

## Entregue neste ZIP — G0.25
1. **Navegação:** 23 IDs reais da Web em `routes.json` e `WebRouteRegistry.gd` como Autoload. Dropdowns agora seguem PILOTO / CONQUISTAS / BATALHA / MAPA / LOJAS / MAIS e despacham entradas conhecidas para telas locais já existentes.
2. **Ângulo:** índice dos 32 quadros calculado em coordenadas de tela relativas à câmera, não diretamente pelo eixo Y do mundo. Ajustada câmera 3/4 e a escala dos sprites.
3. **Vitrines:** Loja, Equipamentos, Hangar e Leilão agora usam artes Pixel Art PNG para as miniaturas, inspeção de itens e naves, com botões pixelados e filtro nearest; funcionalidades offline existentes continuam.
4. **Mapa:** rotas de portais e coordenadas de setores em `world_routes.gd` preservadas; portais, minérios, BOX, loot, relés e Base passam a utilizar visuais PNG.
5. **Otimização:** retirados GLB/GLTF e renders 3D grandes substituídos por PNG; **scripts e saves `user://` preservados**. Elementos visuais 3D gerados pelo Godot para efeito simples ainda existem em pontos específicos (lasers, anéis e fundo).
6. **GitHub APK:** atualizado o workflow separadamente para limpar ativos antigos ao instalar atualização. Primeira instalação do workflow exige commit manual em `.github/workflows/godot-zip-installer.yml`.

## Rotas Web → destino local G0.25
| Grupo | Referências Web no arquivo | Destino Godot |
|---|---|---|
| PILOTO | Hangar, Nave, Habilidades, AUX-9 | Hangar / Perfil / Hangar |
| PILOTO | Autopilot condicional | Mapeado; funcionalidade pendente |
| CONQUISTAS | Missões, Passe, Centro de Comando | Missões / Passe / Central |
| BATALHA | Arena, Warfront, Portais, Eventos, Grupo | Batalha / Relés / Astral / Central / Aliança |
| MAPA | Mapa | Mapa galáctico local, viagens existentes preservadas |
| LOJAS | Loja, Loja Premium, Leilão | Vitrines locais com sprites PNG |
| MAIS | Clã, Universo, Configurações, Administração | Aliança / Mapa / Configurações / ADM local |
| MAIS | HUD, Modo Compacto | HUD já ativo / Modo Compacto pendente |

**Atenção:** o `routes.json` é um **espelhamento de IDs dos menus da Web**, não uma cópia do servidor ou suas URLs. A navegação **entre setores** permanece definida em `scripts/world_routes.gd`: mapas 1/2/3-1..8, 4-1..3, U-1..3, A-AURORA/NEXUS/ECLIPSE. Regras finais do servidor não são transferidas nesta atualização.

## Cronograma proposto para próximas validações
| Etapa | Prioridade | Janela estimada (após iniciar os testes) | Critério de aceite |
|---|---|---|---|
| Fase 1 — Compilação e smoke test Android | P0 | Dia 1 | GitHub Actions verde; APK abre; toque nave/combate/chat minimapa funciona |
| Fase 2 — Ângulos e escala dos sprites | P0 | Dias 1–2 | Aurora + Scavenger percorrem 32 direções sem inversão, espelhamento ou salto |
| Fase 3 — Rotas de menus Web | P0 | Dias 2–3 | 23 IDs testados; rotas não implementadas exibem estado pendente |
| Fase 4 — Loja/Equipamentos/Hangar/Leilão | P1 | Dias 3–5 | Miniaturas corretas, inspeção legível, equipar/comprar simulado e leilão local funcionando |
| Fase 5 — Mapas e estruturas 2D | P1 | Dias 5–6 | Portais/BOX/minérios/Base/relés legíveis em 64/96px; travel e pickups preservados |
| Fase 6 — Android baixo consumo | P1 | Dias 6–7 | Sem importação GLB, comparação tamanho APK/FPS/memória no aparelho |
| Fase 7 — Expansão Web → Godot | P2 | Dias 8–12 | Desenhar telas ainda ausentes (Autopilot e compacto); avaliar integração com backend sob contrato |

*Prazos são estimativas de planejamento, não tarefas automáticas nem promessa de execução em segundo plano.*

## Validações recomendadas
- **Compilação**: Godot 4.5.2 headless import, GDScript e export Android Debug com keystore de teste.
- **Funcional**: mapa 1-1 → 1-2 → 1-1, 4-1, U-1 e arenas astrais; escolher nave; coletar minério/BOX; atacar NPC; abrir Hangar/Loja/Equipamentos/Leilão; comparar saldo local.
- **Ângulos**: girar manualmente 360° com câmera fixa. Se ficar invertido num aparelho, ajuste `yaw_offset` em `scripts/world/pixel_unit_sprite.gd`, mas preserve a fórmula relativa à câmera.
- **Identidade**: sprites de 96×96 gerados a partir das pranchas anteriores; algumas miniaturas usam equivalentes visuais por categoria até sua arte individual definitiva.
- **Segurança**: instalador modifica somente o repositório de teste Godot. Não instalar no repositório Web de produção; faça backup/commit antes de testar. Não publicar APK debug na Play Store.

## Limitações verificáveis
- Ambiente de criação sem motor Godot instalado: **não foi possível executar o cliente nem compilar APK aqui**; a primeira validação real acontece no GitHub Actions e no Android.
- A UI ainda usa `SubViewport` + `Sprite3D` para mostrar artes 2D em telas historicamente 3D. Não carrega modelos GLB, mas migração integral para Control/TextureRect é uma otimização futura.
- O arquivo ZIP incremental sozinho **não remove** modelos antigos que já estão no repositório: usar workflow G0.25 incluído separadamente, cuja etapa de limpeza é restrita a pastas de assets legados.
