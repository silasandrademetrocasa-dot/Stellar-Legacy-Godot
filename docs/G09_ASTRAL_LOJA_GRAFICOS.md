# G0.9 — Especificação técnica

Origem: backup WEB V64 `public/modules/astral-gates-v380.js` e `public/data.js` (Aurora / Nexus / Eclipse); rotas Godot G0.8.

- `scripts/systems/astral_trials.gd`: recorde/vitórias locais no `user://`, ondas 1 a 3.
- `scripts/world/astral_environment.gd`: estrutura visual e efeitos do cenário de arena por perfil gráfico.
- `scripts/world/combat_world.gd`: NPCs especiais, 3 ondas por arena, sem respawn até a próxima onda.
- `scripts/world_routes.gd`: 3 novas rotas astrais físicas no mapa de facção X-8; retorno ao X-8.
- `scripts/ui/stellar_hud.gd`: painéis da loja, leilão, portais e CONFIG de qualidade.
- `scripts/systems/stellar_hub.gd`: compras locais de equipamentos e lotes de leilão demo.
- `assets/astral/*.glb`: 3 novos portais de geometria detalhada.
- `assets/ui/astral_interface_g09.png`: novo fundo ornamental sem texto para controles nativos Godot.

**Qualidade**: modelos críticos **100% preservados** nos três níveis. Nenhuma substituição dos GLBs em `assets/ships`, `assets/npcs`, `assets/drones`, `assets/aux`. O nível BAIXO muda iluminação e FX de ambiente; MEDIO restaura estrelas e arena balanceada; ALTO ativa mais FX ambientais e sombra da luz principal. Em nenhum dos modos há redução de polígonos ou escala de renderização aplicada para diminuir fidelidade das naves.

**Nota de monetização**: a loja não recebe dinheiro real. Créditos e leilões de demonstração não podem ser usados como inventário autoritativo.
