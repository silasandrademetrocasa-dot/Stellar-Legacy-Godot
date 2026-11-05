# Resultados da versão 0.2 — 2026-11-04

Ambiente: Linux + Node 22, Chromium 156 headless / Playwright, WebGL por SwiftShader. Nenhum teste físico Android foi executado e nenhuma taxa de FPS de telefone é certificada.

## Aprovados

- `npm test`: **27 testes**, três arquivos. Inclui integridade transacional, idempotência, equipamentos/configurações, compatibilidade de campos opcionais de saves antigos, revenda sem inflação retroativa, acessibilidade de uma primeira melhoria com as missões iniciais, limites de pixels por preset e FPS/p95 a partir de intervalos reais de quadro (inclusive quadros mais lentos que 100 ms).
- `npm run build`: TypeScript estrito e Vite aprovados. Build offline principal `695fbfc09376`, 69 arquivos e **5.404.292 bytes** sem compressão. Dados completos em BUILD_REPORT.json.
- `npm run check:assets`: **50 entradas de assets, 4.716.168 bytes**. Inclui a nova caixa, atlas de cena e registro de frames. Os 17 frames do atlas foram verificados com recortes dentro da textura e fontes existentes. A caixa foi conferida visualmente e o recorte considera alpha visível para evitar margens transparentes excessivas.
- `npm run test:e2e`: **seis testes aprovados em 3,1 minutos**, na rodada final.

## Fluxos de navegador da rodada final

1. Aceitar missão, pilotar com teclado, comprar/equipar a arma pelo novo preço, salvar/reabrir e reabrir offline preservando posição, arma e saldo. O teste usa um saldo importado de fixture para isolar a transação da campanha; não simula ganhar esse dinheiro jogando.
2. Viewport touch 915×412: joystick, menus e hangar dentro da tela.
3. Selecionar hostil real, disparar, abater, exigir que o drop tenha **textura da caixa**, aproximar e coletar. Sem comando de abate injetado.
4. Importação validada e viagem por portal sem rede, seguida de reload no setor de destino. Posição inicial junto ao portal e quatro abates são fixture declarada do teste.
5. Eventos de toque reais enviados pelo protocolo do Chromium: tocar/segurar, mudar o dedo de posição e mudar a rota da nave; arrastar o radar, cancelar o gesto e verificar que o painel pausa o voo.
6. Importar um save sem os campos novos, preservar 1.873 créditos e 11 unidades de ferrita; aplicar baixo imediatamente, habilitar FPS, trocar alto/médio, reabrir com a preferência preservada e ocultar o monitor novamente.

## Correções durante a verificação

- O teste passou a selecionar a aba Missões do menu explicitamente; o HUD também tem um atalho com o mesmo destino.
- O teste de imagem da caixa detectou colisão entre o ID visual do NPC e o do drop. O registro visual usa `loot:<id>`; o teste exige a textura correta e passou após a correção.
- Importar/restaurar um save agora aplica gráficos e áudio imediatamente, sem depender do próximo checkpoint de três segundos.
- Ícones de recursos no mercado agora apontam corretamente para `assets/sprites/ore*.png`; o fluxo principal também monitora respostas HTTP de erro.

## Evidências visuais

- screenshot-lootbox-v02.png: caixa real após abate, antes da coleta.
- screenshot-fps-v02.png: monitor opcional com resolução e estatísticas reais da sessão de navegador.
- screenshot-android-viewport.png e screenshot-hangar-mobile.png: viewport touch, sem alegação de aparelho físico.

Os números de FPS de uma captura refletem o renderizador por software do ambiente e não representam desempenho do usuário. O balanceamento é uma primeira revisão de preços, sem playtest prolongado de campanha ou chefe. A inclusão de atlas melhora a organização de texturas em runtime, mas aumenta os bytes totais do pacote por preservar os arquivos individuais para UI/galeria.

## Prefixo Pages — aprovado

Executado `BASE_PATH=/stellar-legacy-offline/ npm exec vite build -- --outDir dist-pages`, `node tools/build-offline.mjs dist-pages` e `node tools/smoke-pages.mjs`. O build `e7c01b785dbc` abriu com sprites/atlas em `/stellar-legacy-offline/`, instalou cache e reabriu sem rede. É uma verificação local, sem deploy remoto neste turno.
