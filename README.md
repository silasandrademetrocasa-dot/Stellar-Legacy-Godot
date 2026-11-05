> Pacote rápido para GitHub: inclui o jogo compilado, código-fonte editável, testes e assets finais. As pinturas originais de art-source e screenshots ficam nos três ZIPs completos anteriores. Nenhuma geração de arte é necessária para npm ci/build. O workflow deve ser instalado separadamente em .github/workflows/extrair-jogo.yml.

# Stellar Legacy Offline · 1.0.0

Evolução cumulativa do projeto 0.2 conforme `docs/GDD_ENTREGA_UNICA.md`. Jogo solo e laboratório de balanceamento, em português. Nenhuma conta, moeda real, chat ou servidor é necessário. Arena, clã, leilão e Warfront são simulações locais, identificadas na interface. O adapter online permanece desativado.

## Instalar a entrega completa

Baixe **todas** as partes ZIP e `release-manifest.json` da mesma entrega. Cada parte é um ZIP normal, com caminhos relativos à raiz, sem pasta externa. Nenhuma parte ultrapassa 24.000.000 bytes. O manifesto contém versão, revisão, ordem, tamanho, SHA-256 de cada ZIP e de cada arquivo. Nomes de upload podem mudar: o instalador identifica as partes pelo conteúdo/SHA, não pelo nome.

Para montar localmente, coloque as partes em uma pasta, extraia `tools/install-release.py` da parte que o contém e execute:

```sh
python install-release.py --manifest release-manifest.json --archives pasta-dos-zips --destination jogo
cd jogo
python -m http.server 8080
```

Abra `http://localhost:8080`. A raiz já contém `index.html`, assets, manifest e Service Worker compilados. Não abra por `file://`. Também pode mesclar manualmente todas as partes, na ordem do manifesto, em uma pasta vazia; execute então `python tools/install-release.py --manifest ../release-manifest.json --archives ../pasta-dos-zips --destination . --verify` para conferir os arquivos dos ZIPs. Nunca publique uma parte isolada.

## Repositório antigo e GitHub Pages

1. Crie uma branch de preparação (`staging-stellar`). Configure Pages para **GitHub Actions** nas configurações do repositório.
2. Instale o workflow fornecido em `.github/workflows/stellar-legacy.yml` e remova o workflow legado `.github/workflows/deploy-pages.yml` nesse commit de preparação, antes de enviar qualquer ZIP. Depois envie o manifesto e **todas** as partes para essa branch. Para Git local, use `git add -f *.zip`, pois ZIPs ficam ignorados no desenvolvimento. O upload pela interface do GitHub pode manter outros nomes.
3. Rode **Install complete Stellar release and publish**. O workflow procura todos os ZIPs, verifica o conjunto inteiro, extrai em temporário, substitui os arquivos reais, remove assets compilados antigos e o workflow legado `deploy-pages.yml`. Preserva arquivos alheios ao jogo. Não apenas descompacta em uma subpasta.
4. Executa `npm ci`, lint, testes e build; grava **um commit completo**, faz push sem force e verifica o SHA remoto. Em staging, não publica Pages. Se faltar/corromper uma parte, não faz commit nem publicação.
5. Revise/mescle a branch completa na principal e execute o workflow manualmente nessa branch. Apenas a branch padrão publica Pages; o build usa caminhos relativos e funciona em `/nome-do-repositorio/`.

O workflow de bootstrap está incluído byte a byte na entrega. Instale-o antes da primeira execução para não depender da permissão de alterar workflows com `GITHUB_TOKEN`. Se regras de branch impedirem o push automático, permita o bot nessa branch de preparação ou execute a montagem local e envie o commit completo. Nenhum acesso remoto ao seu GitHub foi feito durante a preparação deste release. O Instalador Universal externo não foi inspecionado: ele precisa **mesclar** caminhos, sem apagar partes anteriores; se isso não for garantido, use este montador.

## Jogar e instalar offline

WASD/setas, joystick touch ou toque e arraste no espaço/radar. O dedo atualiza continuamente a rota. A nave se desloca em 360° mantendo vista frontal/¾, com dead zone, amortecimento e histerese. Selecione um NPC, saia da estação e use Disparar. A coleta aproxima a nave de uma única caixa de loot com todos os recursos.

No primeiro acesso online, em **Save → Baixar jogo completo para offline**, aguarde “Cache completo”. No Chrome Android em HTTPS, use **Instalar aplicativo / Adicionar à tela inicial**. Depois pode reabrir sem rede. Feche as abas e o PWA antigo para ativar uma atualização de cache. Exportar save continua recomendado: limpar dados do navegador remove o banco e os backups. Não mudar domínio/caminho para preservar o armazenamento. Não há APK nativo nesta entrega.

## Sistemas

- Catálogo oficial de 177 registros: 3 facções, 43 naves, 40 equipamentos, 5 munições laser, 4 mísseis, 7 recursos, 34 NPCs ativos, 27 futuros e 14 mapas. Preços de referência integrais, atributos e status visíveis. Item de evento com preço zero não é uma compra gratuita.
- Hangar com slots físicos, inventário global, oito drones Halo/Nova, AUX-9 de níveis 1–25, especializações, protocolos de três tiers e CONF1/CONF2 globais. Um item não pode ocupar duas posições na configuração ativa. Designers de nave disponíveis para Aurora/Pioneer; drones e AUX também têm skins.
- Combate, mísseis, SIP com drenagem, IA de suporte/elites/boss, recursos, portais, 12 missões, XP/habilidades, passe free/premium sandbox, atividades diárias/semanais/facção, eventos e fragmentos. Conteúdo marcado FUTURO permanece bloqueado.
- Mercado, venda de recursos/equipamentos, upgrades, refinaria, materializador e forja. Receitas sem fórmula oficial estão marcadas **TODO_BALANCE**; o laboratório não afirma balanceamento homologado.
- Autopilot com decisões a cada 500 ms, órbita, seleção de alvo/mapa, retorno, mineração e comércio automático. Farm offline reserva munição e nave, calcula até oito horas por snapshot e permite resgate único mesmo atravessando a meia-noite.
- Arena contra ghost, clã com bots, leilão com escrow e Warfront de captura/defesa. Todos locais, sem falsa alegação de multiplayer.
- Administração local de preços, NPCs/drops, mapas, missões e calendário; conta de testes com confirmação dupla; cupom `LAB-LEGACY-1`; calculadora teórica de combate.

## Desempenho e diagnóstico

Sem Canvas 2D ou WebGL: sprites raster originais em DOM/CSS. Pré-carregamento assíncrono, texturas WebP com três LODs, culling, pool de efeitos, lógica fixa e interpolação visual. **Baixo** minimiza efeitos e limita 30 FPS; **Médio** conserva efeitos moderados, também 30; **Alto** usa os efeitos completos, até 60. A redução adaptativa pode baixar efeitos/LOD após quedas prolongadas. O teto não garante FPS no aparelho.

Preferências permite FPS opcional com P50/P95/P99, DOM, pool, HUD, Autopilot e tempo de save. Replay grava entradas/posições sem vídeo; para comparar deterministicamente, mantenha o mesmo mapa e equipamento. Durante playback, combate/recompensas/checkpoints são suspensos e a posição original é restaurada ao terminar.

Veja `docs/RESULTADOS_GDD.md` e `docs/benchmark-dom.json` para as medições após completar o cache. `docs/benchmark-dom-cold.json` registra o ensaio anterior com preparação do cache em paralelo. O navegador com viewport Android é emulação; não certifica FPS, instalação ou ciclo de vida em aparelho físico.

## Desenvolvimento e estrutura

Node 22, npm e Python 3 (instalador/verificações). Assets prontos incluídos; nenhuma geração de arte é necessária para compilar.

```sh
npm ci
npm run lint
npm test
npm run check:assets
npm run build
npm exec playwright install chromium
npm run test:e2e
python tools/test-installer.py
# Após compilar, benchmark de 3 × 60 s, sem outros testes em paralelo:
node tools/benchmark-dom.mjs
```

`npm run dev` abre `/app.html`. Vite usa `app.html` como entrada de fonte, evitando confundir a página pré-compilada da raiz com o desenvolvimento. `npm run build` gera `dist/index.html` pronto para Pages. `BASE_PATH=/repositorio/ npm run build` testa base explícita. Não copie `node_modules` para Pages.

`src/core` contém estado/regras/fila de comandos; `src/content` contém catálogo e parâmetros; `src/presentation` contém cena DOM, controles, HUD e painéis; `src/infrastructure` contém IndexedDB, cache e adapter desativado; `public/assets` contém assets finais; `art-source` guarda as artes originais; `tools` contém processamento, instalação e validação; `e2e` contém testes de navegador. Reprocessamento opcional das imagens requer Pillow e as fontes incluídas, sem rede. O pipeline só recorta, ajusta transparência, redimensiona e empacota arte raster original gerada para o projeto.

## Save e migração futura

Um `GameState` transacional no IndexedDB existente, mesmo nome/versão de banco para conservar os saves 0.2. Abertura verifica SHA-256 antes da migração única; preserva saldos, IDs, posições, inventário e configurações. HP/escudo legado são convertidos proporcionalmente para os atributos oficiais, sem reset de conta. Operações têm IDs, revisão, journal pending/committed/failed, fila serial, checkpoints A/B/C e outbox local desativada. Pendências são recuperadas ao reabrir; falhas não apagam o save. Hash detecta corrupção, não é mecanismo anti-cheat.

Exportação JSON, importação validada com prévia e confirmação e cópia “before-import” estão no menu Save. Um escritor por perfil via Web Locks e revisão transacional. Render/Supabase são apenas referência futura: servidor deverá reconciliar catálogo e autorizar saldos; valores `labOnly` jamais viram moeda competitiva automaticamente.
