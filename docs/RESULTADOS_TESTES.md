# Resultados históricos da versão 0.1 — 2026-11-04

Para a versão atual, consulte RESULTADOS_TESTES_0_2.md.

Ambiente: Linux, Node 22, Chromium headless 156 / Playwright, WebGL via SwiftShader. Não é um dispositivo Android físico.

## Comandos aprovados

- `npm test`: **22 testes aprovados**, 2 arquivos. Reducer/invariantes, posse/slots, replay de compra, saldo negativo, distância da estação, venda, missão/resgate, abate/loot, capacidade do porão, configurações globais, transição, SHA-256, conteúdo, venda de equipamento e gasto de stellarium; IndexedDB com reopen, journal/snapshot, deduplicação, conflito entre escritores, falha simulada de quota, corrupção preservada e restauração.
- `npm run build`: TypeScript estrito e Vite aprovados; service worker versionado gerado. O diretório `dist` tem todos os recursos necessários para hospedagem estática.
- `npm run check:assets`: **47 arquivos válidos, 3.463.376 bytes**, três cópias idênticas de ícones de drone/AUX intencionais identificadas no relatório. PNGs têm assinatura/dimensões verificadas; WAVs têm cabeçalho RIFF. Auditoria de referências usa inspeção do catálogo e IDs dinâmicos.
- `npm run test:e2e`: **4 aprovados em 2,6 minutos** na rodada final.

## Fluxos de navegador

1. Aceitar missão, voar por teclado, retornar à estação, comprar Emissor Lúmen I, equipar, conferir dano 38, salvar/recarregar mantendo posição/saldo, baixar pacote, desligar rede e reabrir com equipamento persistido.
2. Viewport 915×412 com touch: joystick move nave, hangar abre dentro dos limites da tela. Capturas reais de gameplay e hangar.
3. Deslocamento pelo radar, seleção de hostil real, disparo, abate confirmado e coleta automática do loot por proximidade. Sem comandos de combate injetados.
4. Importar fixture validada por JSON via interface (setup do teste: 4 abates, nave junto ao portal), confirmar substituição, instalar cache, desligar rede, viajar para Fronteira Rubra pela interface e reabrir preservando setor/posição. A fixture não é evidência de progressão humana pelos quatro abates.

## Defeitos encontrados e corrigidos

- A primeira seleção de testes incluía os specs Playwright no Vitest: script agora limita Vitest a `src/tests`.
- Verificações temporizadas de voo e abertura de painel foram substituídas por espera por estado/visibilidade.
- Cache armazenava respostas com `Vary: Origin` do servidor Vite. Requests CORS de scripts não correspondiam ao request original do cache durante abertura offline. O worker usa `ignoreVary: true` somente em cache estático próprio da mesma origem, com versão de build. A reabertura sem rede passou depois da correção.

## Capturas

- `screenshot-desktop.png`: mundo WebGL com estação, planeta e HUD.
- `screenshot-android-viewport.png`: viewport touch em paisagem.
- `screenshot-hangar-mobile.png`: painel e arte da nave.
- `screenshot-combat.png`: combate real no teste.

Nenhum FPS Android, teste físico, tempo de campanha completa ou balanceamento do chefe foi certificado. Os testes de IndexedDB usam fake-indexeddb; a PWA e os fluxos de jogo foram exercitados em Chromium real. Lint dedicado não foi configurado; a verificação estática executada é TypeScript estrito.

## GitHub Pages com prefixo — aprovado

Executado `BASE_PATH=/stellar-legacy-offline/ npm exec vite build -- --outDir dist-pages`, seguido de `node tools/build-offline.mjs dist-pages` e `node tools/smoke-pages.mjs`.

Resultado: **PASS** para abertura em `/stellar-legacy-offline/`, assets WebGL, instalação do service worker e reload sem rede. Captura: `screenshot-pages-prefix.png`. É uma simulação local do caminho de Pages, não um deploy remoto.
