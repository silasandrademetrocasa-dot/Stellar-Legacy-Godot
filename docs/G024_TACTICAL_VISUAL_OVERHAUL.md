# Stellar Legacy G0.24 — Tactical Visual Overhaul

## Base obrigatoria
G0.23 Camera e Luz Tatica validada e publicada pelo instalador universal.

## Correcoes aplicadas
- Mesma camera ortografica e visao superior aprovadas da G0.23.
- Nave jogador: 14% maior **somente na tela de voo**, GLB V3 preservado.
- NPC: escala visual por classe via tamanho real do GLB, sem alterar dano, HP, velocidade ou colisao.
- Rele LV1/LV2/LV3: multiplicadores 0.39/0.36/0.34, cerca de 25-30% maiores que antes.
- Portais: moldura inclinada 64 graus (59 para astrais), plataforma luminosa e rotulo mais baixo; rotas e distancia de viagem intactas.
- 33 novos fundos de nebulosas locais de resolucao 1536 x 1024, um por setor. Variante economica 640 x 432 para modo BAIXO.
- Plano espacial segue a camera, para nao esticar 1024 px por 950 unidades; camadas de estrelas, poeira e destrocos movem em parallax.
- Perfis: BAIXO 44 estrelas / 0 poeira e destrocos; MEDIO 175 / 36 / 9; ALTO 340 / 96 / 34.
- Itens do minimapa, inventario, naves HQ, AUX, escudos, loja, economia, combate e servidor sem alteracao.

## Checklist Android
- Importacao via GitHub Actions Godot 4.5.2: sem SCRIPT ERROR ou Parse Error.
- Mapa 4-1: visualizar a Aurora com escala moderada e rele central maior.
- Mapa 1-1: portais com abertura inclinada e anel de chegada, viagem funcionando.
- Nave Aurora/Valkyrie/Leviathan e NPC Scavenger/Kharon/Boss: relacao proporcional.
- Alternar BAIXO/MEDIO/ALTO: mudanca de efeitos sem alterar naves GLB ou combate.
- Cruzar extremos dos mapas: textura visivel, sem buracos e sem travar camera.
- Testar minimapa: sem minerios ou caixas, somente alvos/rotas previstos.

**Nao foi possivel executar Godot 4.5.2 neste ambiente; a validacao definitiva depende do workflow.**
