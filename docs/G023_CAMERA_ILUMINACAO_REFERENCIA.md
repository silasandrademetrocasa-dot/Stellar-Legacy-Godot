# G0.23 — Camera e iluminacao baseadas no video de referencia

O video `XRecorder_20261025_02.mp4` foi usado como referencia visual, sem incorporar o video ao aplicativo.

## Visao de voo
- Camera ortografica com angulo quase superior, eixo fixo e seguimento suave.
- Tamanho fixo: 42 unidades verticais; distancia visual não depende do tamanho importado da nave.
- Parametros centralizados em `scripts/world/tactical_camera.gd`.

## Iluminacao
- Luz principal e luz de preenchimento filhas da camera, acompanhando a orientacao dela.
- Sombras dinamicas apenas no perfil Alto; reducao do custo nos outros perfis.
- Ambient light suave para leitura de detalhes de materiais PBR.

## Cenario
- 33 mapas com texturas de fundo locais em `assets/backgrounds/tactical_sectors/`.
- Nebulosas discretas, poeira e estrelas multiescala sem colisoes.
- Baixo: 65 estrelas proxima, poeira removida e sombras desligadas.
- Medio: 150 estrelas e poeira moderada, iluminacao intermediaria.
- Alto: 260 estrelas, poeira completa e luz com sombras.

## Preservacao
- Modelos V3 e materiais intactos. Nenhum modelo 3D foi simplificado.
- Nao altera inventario, credito, Stellarium, NPC stats, danos, mapas nem regras de viagens.
- Radar: nave, portais, NPCs, rele e base. Minérios, bonus e loot ocultos apenas no minimapa.

## Testes
1. Importacao Godot 4.5.2 sem parse errors.
2. Conferir camera no X-1 e PvP 4-1 sem nave gigante.
3. Trocar naves sem alterar tamanho de projeção.
4. Viajar entre mapas e observar fundo propio.
5. Conferir luz em diferentes rotacoes e modos BAIXO/MEDIO/ALTO.
6. Confirmar coleta de recursos mesmo ocultos no minimapa.
