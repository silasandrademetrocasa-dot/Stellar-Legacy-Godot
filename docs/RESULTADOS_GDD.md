# Verificação executada · 1.0.0

## Regras e persistência

`npm run lint` (ESLint + TypeScript), `npm test` e `npm run build` aprovados. **49 testes unitários/de integração**, em quatro arquivos. Cobrem catálogo 177, todos os 34 NPCs com rota de spawn, disponibilidade de eventos, compras/carteiras, venda na moeda paga e preço administrado, upgrade em slots legados, alocações globais, refinaria TODO_BALANCE, protocolos, oito horas de Farm e meia-noite, retorno do tipo de munição, passe/escrow, clã/Warfront/Arena, administração, cupom, migração 0.2 e invariantes.

No IndexedDB simulado: 100 compras concorrentes na fila serial, dez reaberturas, pending recuperado uma vez, failed registrado, falha de quota com rollback, hash corrompido preservado, conflito de escritor, snapshots rotativos e restauração. A conversão do boss antigo conserva seu ID; carteiras e carga legadas não são resetadas.

## Navegador

**Seis testes Playwright aprovados** em Chromium Linux:

1. Renderer DOM sem canvas; compra de ARC-1, slot físico, movimento real, checkpoint e carteira/configuração após reload offline.
2. Todos os painéis expandidos e catálogo paginado de 177 entradas em viewport touch 915×412, dentro dos limites da tela.
3. Projétil real mata o NPC; uma única loot box é coletada e entrega exatamente Ferron/Cryon esperados.
4. Farm de oito horas atravessa o período fechado, reabre sem rede, entrega uma vez e conserva saldo no próximo reload.
5. Toque CDP atualiza continuamente a rota; presets 30/30/60 e monitor FPS persistem.
6. Portal para outro setor sem rede, gravação de entradas, replay com erro máximo <0,01 unidade no percurso testado, restauração da posição e preservação do saldo/save.

Testes usam contextos/browser recarregados, não encerramento forçado de Chrome Android ou de APK. Screenshots `gdd-flight.png`, `gdd-mobile.png`, `gdd-catalog-mobile.png`, `gdd-loot.png`, `gdd-fps.png` documentam a interface; não são usados durante a medição de FPS.

## Assets e instalação

`npm run check:assets` aprovado: 359 arquivos do registro, 424 frames raster, 64 frames de VFX; aproximadamente 9,7 MB de assets registrados. Build offline contém 366 arquivos antes de Service Worker/lista offline. A galeria e o manifest também estão incluídos; fontes raster originais ficam no projeto completo e não no deploy `dist`.

O contrato do instalador foi executado com nomes arbitrários de ZIP, arquivo antigo realmente substituído, asset antigo removido, arquivo alheio preservado, repetição idempotente e parte ausente/corrompida rejeitada antes de qualquer mutação. YAML do workflow e sintaxe Python validados. O commit/push é sem force, com SHA remoto conferido; não há publicação de staging nem commit de montagem parcial.

A validação final de reconstrução é registrada no arquivo externo `VALIDACAO_RECONSTRUCAO.txt`, entregue ao lado do manifesto e das partes. Ela executa instalação somente dos ZIPs/manifesto em pasta vazia, verifica os arquivos extraídos por SHA, roda `npm ci`, lint, testes, build, Pages com subdiretório e reabertura offline. O teste de remoto usa Git bare local, não a conta GitHub do usuário.

## Medições e limites

Resultados brutos e protocolo em `benchmark-dom.json`. Chromium headless Linux, viewport touch 915×412, seis NPCs no setor inicial, sem gravação de tela. Três execuções sequenciais de 60 segundos, presets fixos (adaptação desativada), navegação circular/ziguezague/inversão, Autopilot, HUD visível/oculto e abertura de missões/hangar/catálogo. O observador continua ativo no ensaio quando o widget FPS está oculto. Intervalos são brutos, incluindo quadros lentos, sem clamp artificial. O coletor lê o buffer de 120 intervalos e o contador de frames aproximadamente a cada 800 ms; os números são das amostras capturadas, não um profiler de GPU. O tempo de save abrange reducer, hash e commit IndexedDB, além do agendamento do navegador.

O agendamento do teto de quadros foi corrigido para conservar a fase quando há atraso. O JSON principal representa a execução separada do trabalho de build/testes. Os números não equivalem a FPS de Android físico. O ambiente headless usa composição por software; menus e checkpoints fazem parte do ensaio misto, após cache completo e aquecimento de um segundo. O ensaio de início com cache simultâneo foi preservado em `benchmark-dom-cold.json`: houve pico de 6.150 ms no save no primeiro preset. Por isso o pré-cache passou a baixar no máximo quatro arquivos por lote e o relatório principal separa preparação de cache de voo.

| Preset | Duração | FPS médio das amostras | P50 / P95 / P99 (ms) | Pico save (ms) | Pico DOM |
| --- | --- | --- | --- | --- | --- |
| low | 60.2s | 24.2 | 33.3 / 44.1 / 190.7 | 37.7 | 23 |
| medium | 60.0s | 27.7 | 33.3 / 39.1 / 131.0 | 561.5 | 24 |
| high | 60.7s | 55.0 | 16.7 / 18.9 / 44.7 | 28.8 | 25 |

Os três ensaios foram sequenciais em ambiente compartilhado, com composição por software. Baixo e Médio não sustentaram 30 FPS neste ensaio; Alto ficou em aproximadamente 55 FPS. Isso não é homologação de dispositivo Android. Menus abriram entre 25 e 232 ms nas amostras; Autopilot teve pico de 2,3 ms. HUD, save e timeline completos estão no JSON.

Não homologados: FPS/memória/bateria em Android físico, APK nativo, balanceamento final, PvP/chat/sincronização de servidor, publicação remota GitHub. Conteúdo FUTURO continua bloqueado; receitas sem especificação oficial e pesquisas locais estão identificadas como TODO_BALANCE. Designers de nave específicos existem para Aurora/Pioneer; outras classes conservam sua arte própria.
