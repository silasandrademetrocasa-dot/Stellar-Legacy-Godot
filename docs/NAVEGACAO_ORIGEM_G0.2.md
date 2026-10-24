# Roteiro migrado - V64 WEB -> Godot G0.2

Referencias da fonte **WEB V64**: `public/modules/portal-layout-v461.js` e `public/modules/route-map-layout-v4825.js` do ZIP original recebido.

- Terra 1-1 <-> 1-2 <-> ... <-> 1-8 <-> U-1 <-> U-2 <-> U-3
- Marte 2-1 <-> 2-2 <-> ... <-> 2-8 <-> U-1 <-> U-2 <-> U-3
- Jupiter 3-1 <-> 3-2 <-> ... <-> 3-8 <-> U-1 <-> U-2 <-> U-3
- 1-1 <-> 4-1; 2-1 <-> 4-2; 3-1 <-> 4-3.
- Mapas de batalha: 4-1 <-> 4-2 <-> 4-3 e 4-1 <-> 4-3.

## Portais em mapa X

Slots herdados: TL topo-esquerda, TR topo-direita, BL inferior-esquerda, BR inferior-direita, CENTER centro.

- Terra (1): proximo `BR`, anterior `TL`.
- Marte (2): proximo `BL`, anterior `TR`.
- Jupiter (3): proximo `TL`, anterior `BR`.
- X-1 para PvP e X-8 para U-1 ficam em `CENTER`.

## Portais em 4-X

- 4-1: 1-1=`TL`, 4-2=`TR`, 4-3=`BR`
- 4-2: 2-1=`TR`, 4-1=`BL`, 4-3=`BR`
- 4-3: 3-1=`BR`, 4-1=`BL`, 4-2=`TL`

## Importante

A fonte web deixa expressamente os portais U-1, U-2 e U-3 intocados. As posicoes atuais no Godot sao apenas demonstrativas, para validar as transicoes; **nao representam coordenadas canônicas**. As regras de nivel, bloqueios e PvP exigirao integracao com o backend em ambiente de teste.
