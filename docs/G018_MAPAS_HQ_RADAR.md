# Stellar Legacy Godot G0.18 — Setores expansivos + frota/AUX HQ

## Atualização cumulativa sobre G0.17
- 13 modelos HQ de naves fornecidos pelo usuário, instalados nos caminhos `assets/ships/SL_*_FINAL.glb` que já são usados por combate, loja, equipamento e hangar.
- AUX-9 HQ com texturas PBR embutidas no GLB original (`assets/aux/aux9.glb`). O LOD fornecido foi **deliberadamente excluído**: a qualidade de naves/AUX nunca varia entre os perfis Baixo/Médio/Alto.
- Setores 720 x 540 unidades (anteriormente 240 x 180), 9× mais área; portais de borda, limites de voo, navegação por toque e minimapa atualizados.
- Raio de detecção de minérios, caixas bônus e loot no minimapa: 112 unidades do jogador, sem depender do perfil gráfico. O restante do mapa continua representado, mas **recursos distantes são ocultos**.
- 27–35 minérios e 34 caixas bônus por setor normal; 40 bônus no PvP 4-X, sem minério comum. Arenas astrais continuam sem recursos regulares. Instanciação dos GLBs HQ de minérios permanece **por proximidade**, conforme G0.17.
- NPCs redistribuídos em área maior, de acordo com tier do mapa. Limite moderado para Android. PvP 4-X continua sem NPCs comuns.
- Salvamento anterior de minério/caixas migrado uma única vez para as novas coordenadas, preservando coleta e timers de respawn.
- Texturas e geometria dos GLBs recebidos preservadas; escala ajustada apenas nos nós da cena para melhor legibilidade.

## Instalador universal
Um ZIP incremental cumulativo **sobre a G0.17** (e um ZIP completo para Godot Android).

## Testes sugeridos
1. Nave Aurora HQ aparece no espaço e hangar, sem perda de qualidade no perfil BAIXO.
2. AUX-9 HQ com texturas só aparece após comprado/equipado e segue a nave.
3. Minimap mostra minérios, bônus e loot somente dentro do anel de detecção.
4. Arrastar pelo minimapa alcança as bordas (±360, ±270); navegar, caçar e minerar nos quadrantes distantes.
5. Portais nas extremidades do mapa levam para setor correto; mapas astrais e PvP preservados.
6. 4-X continua sem minérios ou NPC comuns.
7. Inventário, carga, créditos e progresso são preservados sem reset.

## Limitações
Os sistemas são protótipos locais offline; não alteram a versão web, Render nem Supabase. A compilação real precisa passar pelo workflow no GitHub e pelos testes no Android.
