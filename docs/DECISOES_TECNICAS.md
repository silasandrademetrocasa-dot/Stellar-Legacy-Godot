# Decisões vigentes · 1.0.0

O GDD novo substitui a decisão anterior de PixiJS: a versão atual usa DOM/CSS e imagens raster, sem Canvas/WebGL ou dependência Pixi. Input, lógica e apresentação são separados. A direção de deslocamento não determina uma rotação completa do sprite; yaw frontal é limitado, amortecido e quantizado com histerese.

Um estado de domínio versionado mantém a compatibilidade da base IndexedDB 0.2. Sem storage paralelo por painel. A fila serial reserva a intenção pending, reduz uma cópia, verifica invariantes/hash/revisão e confirma estado, journal, backup e outbox no mesmo commit. O loop visual continua independente durante gravação; a posição viva é incorporada após commits comuns. Viagem, respawn e Arena alteram a posição atomicamente.

Os dados oficiais têm 177 entradas e status de disponibilidade. Preços reais de referência são usados no sandbox; valores não fornecidos (receitas, cadência, shield inicial, movimento da IA e progressão de eventos) são parâmetros de laboratório e não uma reconstrução de SQL histórico. Nenhum saldo sandbox é autoridade online.

Mapas/ships/NPCs usam WebP e três LODs, decode assíncrono, cache limitado ao setor ativo/próximo e recursos ativos. O cache HTTP offline contém o conteúdo completo; a memória decodificada do browser é gerida pelo navegador e precisa ser medida em Android físico. Pool e culling limitam a cena. O HUD usa texto atualizado quando muda e cadência reduzida; não escreve layout do mundo a cada tick.

A raiz pré-compilada e `app.html` fonte coexistem. Vite compila explicitamente a fonte e renomeia a saída para `dist/index.html`. O montador verifica todas as partes antes de substituir caminhos. CI testa antes de um único commit/push; staging não publica, branch padrão publica `dist`. O suporte real do Instalador Universal externo não foi presumido.
