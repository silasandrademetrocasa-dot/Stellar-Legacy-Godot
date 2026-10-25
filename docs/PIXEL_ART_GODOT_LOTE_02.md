# Stellar Legacy — Pixel Art no mapa e HUD (Lote 02)

## Escopo de instalação

- Conversão de **13 naves originais GLB** em spritesheets transparentes de 32 frames (8 colunas × 4 linhas, 64x64/frame, 11,25°).
- Conversão de **16 modelos NPC GLB** em 32 frames cada e mais três **derivações provisórias** para RAIDER, DEFIANT e BOSS PRIME (sem GLB individual na base enviada).
- **Drones** (7 designs do inventário, variações cromáticas) e **AUX-9** em sprite único 64×64.
- Substituição da apresentação visual de nave, inimigo e auxiliares *somente no mapa*; mantém GLB originais para Hangar, Loja, efeitos, referência e fallback.
- Menu do mapa com colunas **PILOTO / CONQUISTAS / BATALHA / MAPA / LOJAS / MAIS**, opções clicáveis, botões e painéis com bordas pixeladas; chat embaixo à esquerda, status à esquerda, seleção de munições no centro e mini-mapa à direita.
- Valores de dano, velocidades, IA, estoque, movimentação, acesso a equipamentos, dados e saves NÃO foram modificados.

## Instalar no GitHub pelo instalador de ZIP

1. **Não extraia** o pacote `STELLAR_LEGACY_PIXEL_ART_ATUALIZACAO_GODOT.zip` antes de subir.
2. Na raiz do repositório, deixe somente este ZIP de atualização (remova outros ZIPs que estejam na raiz).
3. Execute GitHub Actions → `Stellar Legacy Godot - Instalador ZIP` (`workflow_dispatch`).
4. O instalador extrai arquivos relativos a raiz, importa com Godot **4.5.2** e publica **somente se a verificação passar**. Se ocorrer erro, a pipeline interrompe a instalação e seu projeto original no repositório permanece sem commit.
5. Verifique no dispositivo: menus, rotação de nave, perseguição/tiro nos NPCs, drones equipados e AUX-9, mapa e Hangar/Loja.

## Arquivos

- `assets/pixel/map_units/ships/{id}.png`: **512×256** (32 × 64×64).
- `assets/pixel/map_units/npcs/{id}.png`: **512×256** (32 × 64×64).
- `assets/pixel/map_units/drones/{id}.png` e `assets/pixel/map_units/aux/aux9.png`: **64×64**.
- `assets/pixel/ui/button_*.png`: estilos 9-slice para botões do HUD.
- `scripts/world/pixel_unit_sprite.gd`: seleção do frame pelo ângulo real do pai.
- `scripts/{main.gd,world/enemy_ship.gd,world/fleet_support.gd}`: integração não destrutiva.
- `scripts/ui/stellar_hud.gd`: menu e layout pixelado preservando comandos.

## Limitações e validação

Sprites foram rasterizados dos GLBs desta base para obter ângulos consistentes; a qualidade artística é um **primeiro lote técnico**, não coincide perfeitamente com as artes promocionais. O fundo espacial, os portais, recursos, relés e as vitrines 3D internas continuam com assets anteriores, aguardando os lotes próprios. A tela ilustrativa anterior era conceitual, não atlas de execução.

Testes feitos aqui: integridade/estrutura ZIP, caminhos relativos, dimensão, transparência e 32 quadros não vazios. **Não houve execução do Godot nem teste no Android neste ambiente**; a validação de GDScript/importação ocorrerá no workflow Godot 4.5.2.
