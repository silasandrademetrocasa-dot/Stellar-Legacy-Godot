# Stellar Legacy — Godot G0.5

**Cliente experimental Android / 3D local.** Versão WEB e usuários iPhone continuam no repositório e banco originais.

## Funcionalidades G0.5

- Mapas e portais X-1 ... X-8, 4-1 a 4-3 e U-1 a U-3 (rotas protótipo).
- Comando de navegação por toque no mundo ou minimapa.
- Seleção por toque, duplo toque para ataque, laser automático **durante o deslocamento** e rotação independente para travar o NPC.
- NPCs oficiais Stellar Legacy com GLBs locais, drones, AUX-9, HP e ESC offline.
- Barra superior: **HANGAR / BATALHA / MAPAS / LOJA / CONFIG**.
- Vitrine 3D rotativa no Hangar e Loja para naves, drones e AUX; equipamentos sem GLB ainda têm conceito 3D de demonstração.
- Rodapé: **PLS-1 / PLS-2 / PLS-3 / PLS-4 / CMT-1**, ALVO, VIAJAR, DRONES, AUX-9 e ATACAR.

**Sem login, compra, inventário persistente real, comunicação WebSocket, Render ou Supabase.** O perfil salvo localmente guarda preferências de protótipo.

## Instalação do ZIP incremental no GitHub

Envie `StellarLegacy_Godot_G0.5_ATUALIZACAO.zip` para a raiz de `Stellar-Legacy-Godot` e execute o workflow `Stellar Legacy Godot - Instalador ZIP` no GitHub Actions. Apenas um ZIP por execução. Só depois de resultado verde, atualize o projeto no editor Godot Android.

## Documentação

- `docs/G0.5-HUD-COMBAT-E-VITRINE.md`: alterações, testes e limites.
- `docs/G0.5-SUPABASE-PLANEJAMENTO.md`: proposta isolada do banco novo.
- `docs/NAVEGACAO_ORIGEM_G0.2.md`: rotas utilizadas no protótipo.

## Requisito

Godot 4.5.x, renderer Compatibility, orientação paisagem. Validar importação via workflow e gameplay no Android.
