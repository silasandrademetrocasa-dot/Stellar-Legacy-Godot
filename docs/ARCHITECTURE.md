# Mapa técnico — Etapa 00

## Versão e base verificadas

- Base instalada: `0c861a72152e2bf1b1bb45d55f893314b3582d60`, publicada pelo instalador
  do proprietário. Código e assets coincidem com a entrega anterior; o workflow
  adicional de CI de PR não está instalado e não é requisito deste pacote.
- `project.godot`: **Stellar Legacy | Godot G0.20**, feature **4.3**, Compatibility
  em PC/mobile, viewport 960×540. O cliente inclui componentes posteriores sem
  alteração do identificador histórico. Não se infere uma versão nova aprovada.
- Engine de validação: **4.5.2.stable.official.6ce3de25a**, como o instalador atual.
  O 4.6.3 do ambiente não foi usado para migrar o projeto; 4.3 não foi executado.
- Cena de entrada: `scenes/main.tscn` → `scripts/main.gd`.
- Branch de trabalho local: `codex/master-plan-design-system`. Sem push ou merge.

## Sistemas ativos e pontos de entrada

| Área | Arquivos principais | Contrato atual |
|---|---|---|
| Orquestração e navegação | `scripts/main.gd`, `scripts/world_routes.gd` | Plano XZ; nariz +Z; rumo de viagem separado de mira durante disparo; portais físicos e facções. |
| Dados da frota | `scripts/data/ship_balance.gd`, `scripts/world/ship_presentation.gd` | Nomes/atributos preservados; 13 modelos, escala uniforme por classe. |
| Pivôs/apresentação | `scripts/world/model_presentation.gd` | Bounds hierárquicos; wrapper visual central; malhas/materiais originais intactos. |
| Combate e NPCs | `scripts/world/combat_world.gd`, `enemy_ship.gd`, `scripts/data/npc_catalog.gd` | IA local, seleção, perseguição, dano, respawn, laser/míssil demonstrativos, impactos/explosões limitadas. |
| Drones/AUX | `scripts/world/fleet_support.gd` | Modelos apenas quando equipados; suporte e rotação locais. |
| Relés | `scenes/relays/`, `scripts/relays/`, `shaders/relays/` | Três níveis HQ/LOD; quatro estados; captura/evolução/recuperação locais. |
| Portais/ambientes | `scripts/world/portal_animation.gd`, `astral_environment.gd`, `faction_base.gd` | Anéis/núcleos e base; FX por perfil, sem colisão de cenário. |
| Recursos/coleta | `scripts/world/resource_field.gd`, `scripts/systems/resource_cargo.gd` | Minérios, bônus, loot, porão, carga visual por distância e saves locais. |
| HUD/mapas | `scripts/ui/stellar_hud.gd`, `mini_map.gd`, `galaxy_map.gd` | HUD de partida, modal, minimapa/rotas e comandos por toque. |
| Hangar/equipamentos/loja | `scripts/ui/stellar_hangar_premium.gd`, `equipment_command.gd`, `stellar_store.gd` | Posse, slots/CONF 1/2, vitrines, carga/descarga sob demanda. |
| Catálogos visuais | `scripts/data/equipment_catalog.gd`, `store_catalog.gd`, `weapon_art.gd` | Mapeamentos HQ de armas, conceitos sem venda, metadados comerciais existentes. |
| Progressão | `scripts/systems/pilot_progress.gd`, `astral_trials.gd`, `stellar_hub.gd` | Missões, XP, arenas, títulos, clãs/relés demonstrativos locais. |
| Economia demonstrativa | `scripts/systems/stellar_wallet.gd`, `equipment_state.gd` | Carteira, inventário e saves em `user://`; não é um serviço financeiro. |
| Design System proposto | `scripts/ui/design/`, `shaders/galactic_hologram.gdshader`, `scenes/ui/design_system_preview.tscn` | Prévia isolada, sem substituir HUD/Hangar; tema, fontes, estados/foco, movimento reduzido e fundo simples em BAIXO. |

O cliente auditado usa picking por projeção/plano e distâncias para combate/coleta;
não há necessidade de gerar trimeshes físicos para esta fundação de interface.
Não foram introduzidas colisões ou mudanças de física.

## Inventário de assets

Inventário integral e hashes de cada GLB:
[audit/asset-inventory.json](audit/asset-inventory.json). Metadados de procedência:
[audit/ship-assets.json](audit/ship-assets.json) e
[audit/integrated-assets.json](audit/integrated-assets.json).

| Categoria | GLBs |
|---|---:|
| Frota | 13 |
| NPCs e versões preservadas | 32 |
| Drones | 7 |
| AUX-9 | 1 |
| Portais normais e astrais | 6 |
| Relés e módulos HQ/LOD | 12 |
| Equipamentos, escudos, motores, munições e mísseis | 61 |
| Armas HQ | 8 |
| Minérios | 5 |
| Boxes | 2 |
| **Total** | **147** |

Fontes da proposta visual são locais e licenciadas; origem/hashes/licenças em
[design/font-sources.json](design/font-sources.json). Não há fontes carregadas da
rede durante a partida. Nenhum GLB/Blender novo foi alegado nesta fundação.

## Preservação e segurança

- Estado de jogador fica em `user://`; os testes usam diretórios temporários de
  `XDG_DATA_HOME` para separar perfis de teste dos saves do proprietário.
- Os scripts ativos são de cliente offline; referências de backend na documentação
  são planos históricos, não autorização nem comprovação de conexão a produção.
- Nesta entrega não foram chamados serviços de produção, bancos ou pagamentos.
  Nenhuma credencial foi inserida no projeto. Nenhum GLB original foi alterado.
- O novo protótipo não concede itens/moedas, troca de nave, grava configurações de
  jogador ou altera a ordem de navegação. O modal mantém a navegação bloqueada
  enquanto a prévia está aberta e retorna a CONFIG ao fechar.
- Novas artes/modelos podem ser criados em desenvolvimento, mantendo os originais
  aprovados e uma comparação explícita para validação do proprietário.

## Ambiente e evidências de teste

`tools/validate_godot.py` reúne auditoria estrutural, contrato do plano, importação,
parsing individual, cenas e regressões. `tests/test_design_system.gd` cobre
contraste em painéis opacos, área lógica de toque, foco, tamanhos de viewport,
estados, movimento reduzido, retorno à configuração e preservação de saves.
`tests/test_rendering.gd` renderiza com Compatibility real para verificar shaders.

Logs e resultados desta fundação são registrados em
[audit/foundation-validation-results.json](audit/foundation-validation-results.json)
quando a rodada é concluída. Capturas de revisão ficam em `docs/design/previews/`.
Não há aparelho Android físico nesta sessão; testes por viewport e render desktop
não medem FPS, temperatura, memória de GPU ou toque em um aparelho real.

## Pendências reais

Confirmação artística/V3 por nave, refino de HQ/LOD, orçamento de draw calls em
aparelho, export/assinatura Android, escopo da candidata e aprovação da identidade.
A documentação da auditoria anterior preserva os riscos ainda aplicáveis. O plano
mestre define as próximas entregas; sistemas existentes não são considerados
completos para a nova etapa apenas porque já existem no cliente.
