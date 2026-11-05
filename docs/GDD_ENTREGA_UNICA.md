# STELLAR LEGACY OFFLINE — DOCUMENTO MESTRE PARA CODEX

**Especificação funcional, catálogo integral, direção artística, engenharia local-first, correção de navegação e ENTREGA ÚNICA — ZIPs de até 24 MB cada**

**Referências inspecionadas:** pacote principal Stellar Legacy recebido em 04/11/2026; catálogo estático `public/data.js` (177 entradas); módulos e documentação da cumulativa V126.0; vídeo do protótipo offline `XRecorder_20261104_05.mp4` (aprox. 1m33). **Este documento descreve a meta do jogo offline; não afirma que o protótipo já implementa todos os sistemas abaixo.**

> **PRINCIPAL DIRETRIZ DO USUÁRIO:** O Codex **PODE E DEVE criar novas artes originais**, naves, drones, NPCs, spritesheets, partículas pré-renderizadas, efeitos, mapas e interfaces quando necessário. Não é obrigado a reutilizar imagens antigas. **Não utilizar Canvas 2D para desenhar/animações/procedurais**: privilegiar assets visuais reais (PNG/WebP/AVIF/spritesheets) animados por CSS `transform`/Web Animations API ou outra abordagem visual baseada em DOM. Nenhuma arte genérica ou placeholder como resultado final. Manter toda a jogabilidade funcional em Android e GitHub Pages offline.

---

## 00. COMANDO ÚNICO DE EXECUÇÃO PARA O CODEX — LEIA PRIMEIRO

> Você é o programador líder, game designer, diretor técnico e diretor de arte do projeto **Stellar Legacy Offline**. Leia este arquivo inteiro antes de alterar código. **Evolua o projeto offline que já existe** — não substitua por um protótipo genérico, não elimine funcionalidades funcionais. Execute **TUDO EM UMA ÚNICA TAREFA**, de ponta a ponta, sem parar para solicitar aprovação, sem releases intermediários e sem deixar partes previstas para outro prompt. Entregue uma implementação cumulativa real e executável com todos os arquivos, testes, mudanças documentadas e correção da navegação. Reproduza os sistemas, conteúdos, nomes oficiais e identidades descritos neste documento, respeitando estados `IMPLEMENTAR`, `ADAPTAR` e `FUTURO`.
>
> **PRIORIDADE 0:** nave fluida, sem engasgadas e sem exibir constantemente a traseira. Movimento em 360° para o deslocamento, mas direção *visual* predominantemente frente/¾ frontal, rolagem e inclinação suaves, sem saltar frames angulares. Criar artes direcionais originais se faltarem ângulos. Não resolver colocando a nave de frente de forma totalmente imóvel; ela deve demonstrar curva com elegância.
>
> **PRIORIDADE 1:** um único save local transacional em IndexedDB; fila de operações e checkpoints A/B/C, sem múltiplos escritores.
>
> **PRIORIDADE 2:** hangar completo, mercado, economia offline de laboratório, NPCs, missões, refinaria, Farm, AUX-9, drones, especiais, progressão, mapa, PvP simulado e Warfront offline progressivo.
>
> **PRIORIDADE 3:** polish visual de qualidade alta, performance mobile, navegação, menus, indicadores, arte autoral e testes.
>
> Não solicitar conexão com Supabase/Render para o protótipo local. Deixar **interfaces/adapters** prontas para integração futura, sem inventar APIs nem prometer migração automática dos saldos locais para multiplayer competitivo. Entregar testes automatizados e um relatório final: feito/pendente, caminhos alterados, métricas de FPS e tamanho de assets. **A única entrega para o usuário deve ocorrer ao fim da implementação completa**, em um ZIP único quando couber ou em múltiplos ZIPs independentes de até 24.000.000 bytes cada quando necessário, com manifesto de instalação e reconstrução integral do projeto.

### Regras imutáveis

1. **Identidade:** *Stellar Legacy*, universo espacial 2D/2.5D, mecânicas próprias, facções, evolução de frota, PvE/PvP/Warfront; jamais copiar artes ou nomes de outro jogo. Use **nomes oficiais** do catálogo a seguir. Não exibir IDs históricos de banco como nomes de produtos.
2. **Novas artes AUTORIZADAS:** criar nave, drone, AUX, laser, projétil, NPC, cenário, fundo, partículas **pré-renderizadas**, HUD, ícones, designers, animações e spritesheets originais. Consistência de direção, escala e iluminação; sprites em perspectiva 2.5D, nítidos, alpha correto, sem chão/sombra falsa abaixo dos itens voadores.
3. **Sem Canvas 2D para gameplay/efeitos/animações:** sem desenhos de linha, partículas geométricas ou naves procedurais com `ctx.*` e sem recriação do cenário a cada frame. Use imagens/spritesheets e composição DOM/CSS com transformações aceleradas. Não introduzir WebGL/`<canvas>` sem autorização adicional; o objetivo deste laboratório é medir a abordagem sem Canvas.
4. **Offline de verdade:** primeiro carregamento pode baixar assets do GitHub Pages, mas depois o app deve abrir e jogar sem rede com Service Worker + cache versionado e armazenamento IndexedDB. A saída de rede não deve travar combate ou UI.
5. **Dados:** uma única fonte de estado no cliente, um escritor por transação, outbox, checkpoint A/B/C. Dinheiro local é de **laboratório**; servidor futuro será o único autorizado a emitir saldo competitivo compartilhado.
6. **Performance:** almejar ≥30 FPS sustentados em Android simples no modo Alto e 60 FPS em dispositivos capazes; medir P95 e quedas com e sem Autopilot, HUD e missões. Se Alto não atingir o piso, reduzir custo de DOM/efeitos e incluir degradação progressiva, sem substituir sprites por desenhos genéricos.
7. **Entrega cumulativa, em uma única execução:** não quebrar menu/asset anterior; incluir teste de regressão, lint, build GitHub Pages/PWA e README com roteiro reproduzível; NÃO afirmar que testou APK se não rodou APK. **Somente disponibilizar pacotes depois de todos os sistemas integrados e testados.**

---

### 00.1 CONTRATO INEGOCIÁVEL — UMA TAREFA, UMA VERSÃO FINAL, ATÉ 25 MB POR ZIP

**Interpretação correta da exigência do usuário:** a implementação deve ser realizada integralmente pelo Codex **em uma única solicitação/trabalho**. A separação em partes é **somente uma solução logística para o tamanho dos ZIPs**, não uma autorização para fazer várias versões, interromper o desenvolvimento, deixar funcionalidades para etapas posteriores ou solicitar testes do usuário a cada fase. O usuário só testa **após receber e instalar o conjunto final completo**.

1. **Execução única e autônoma:** primeiro audite o repositório offline existente e todo este GDD; depois corrija a navegação, desenvolva os sistemas obrigatórios, crie artes novas, integre a persistência, construa a versão GitHub Pages/PWA, execute testes automatizados e faça o empacotamento final. Planeje internamente as dependências e checkpoints técnicos; **não publique versões P0/P1/P2 ao usuário**. Se a execução ficar grande, faça commits internos no ramo de trabalho, mas o resultado do usuário é **um só release final**.
2. **Limite rígido de distribuição:** **nenhum ZIP entregue pode superar 25 MB**. Use **24.000.000 bytes (24 MB decimais) como teto operacional** para cada ZIP, proporcionando folga. Meça o tamanho do arquivo ZIP final em bytes *depois* da compressão; se ultrapassar o limite, redivida antes de entregar. Também evite arquivos individuais maiores que o limite admitido pelo fluxo de upload do GitHub/Instalador Universal.
3. **Se tudo couber:** entregar **um único** `STELLAR_OFFLINE_FINAL_COMPLETO.zip` contendo integralmente o projeto final, recursos, páginas, estilos, JavaScript, assets, testes, PWA, workflow e documentos.
4. **Se exceder o teto:** entregar `STELLAR_OFFLINE_FINAL_PARTE_01_DE_NN.zip`, `...PARTE_02_DE_NN.zip`, até `...PARTE_NN_DE_NN.zip`. Podem ser 2, 5, 10 ou quantas partes forem necessárias. **Cada parte é um ZIP normal, independente e válido**, com arquivos reais em seus caminhos finais relativos à raiz do repositório. Não usar volumes binários `.zip.001`, `.z01`, `.part` que o Instalador Universal não consiga importar individualmente. Nunca dividir um arquivo de código ou asset entre ZIPs; se um asset não couber sozinho, otimize-o ou divida spritesheet em atlas menores com referências corretas.
5. **Não duplicar caminhos:** cada arquivo do release aparece **em uma única parte**; nenhuma parte posterior pode sobrescrever silenciosamente um arquivo de parte anterior. Caminhos relativos normalizados, sem `../`, sem diretório raiz artificial como `projeto/projeto/`. `index.html`, `manifest.webmanifest`, `sw.js`, `.github/workflows/`, módulos e assets precisam ficar nas posições que o site realmente espera após instalar **todas** as partes. Todas as partes juntas devem reproduzir o **projeto final completo**, não apenas patches que dependem de arquivos não fornecidos.
6. **Manifesto do conjunto:** entregar `MANIFEST_ENTREGA_FINAL.md` e `release-manifest.json` com número total de partes, ordem de instalação, tamanho em bytes e SHA-256 de cada ZIP e de cada arquivo, lista de caminhos por parte, total de arquivos, versão do projeto, revisão de código, dependências e testes. Disponibilize o manifesto **fora dos ZIPs e/ou repetido de forma identificável** (se repetido, apenas como documento de distribuição, sem colisões no repositório).
7. **Instalação ordenada:** README deve mostrar o fluxo no **Instalador Universal**: instalar PARTE 01, PARTE 02, ... PARTE NN, na mesma branch de preparação, sem apagar o conteúdo de partes anteriores; conferir manifesto e contagens; **só então** publicar a branch/merge no `main` e verificar o GitHub Pages. Caso o instalador substitua o repositório inteiro em vez de mesclar os caminhos, criar um script/workflow de montagem compatível, capaz de receber todos os ZIPs e produzir um único commit final. Não presumir capacidades não verificadas do instalador.
8. **Evitar deployments parciais:** se GitHub Pages publica automaticamente a branch principal, montar/instalar todas as partes em **branch de staging** ou em workspace de montagem e fazer **um único merge/commit de release** depois da validação. Não deixar o usuário testar a página quebrada entre partes. Não incluir binários temporários, vídeos brutos, caches, `node_modules`, bancos locais de desenvolvimento ou assets obsoletos.
9. **Prova de integridade antes da entrega:** em diretório vazio, **reconstituir o projeto apenas a partir dos ZIPs entregues**, verificar SHA-256 e ausência de caminhos duplicados, instalar dependências por lockfile quando houver, rodar testes, conferir os imports e o `base path` do GitHub Pages (normalmente `/nome-do-repositorio/`), build/Service Worker/PWA e navegação offline. Se falhar, corrigir **antes** de liberar qualquer parte.
10. **Relatório e conclusão única:** só ao final apresentar **todos os links dos ZIPs numerados**, instruções curtas de instalação, resumo do que foi implementado, testes executados/limitações e pendências verdadeiras. Não chamar uma função simulada de multiplayer real. Não declarar medição de FPS em Android se não tiver sido feita no dispositivo.

**Atenção:** *um trabalho* ≠ *um arquivo*. A entrega pode conter muitos ZIPs de até 24 MB cada, mas deve representar **uma versão final integral, pronta para instalação ordenada e teste somente no fim**.

### 00.2 MELHORIAS DE QUALIDADE INCLUÍDAS NA MESMA ENTREGA

Estas melhorias não são tarefas ou versões separadas. **Implementar dentro do mesmo trabalho final**:

- **PWA Android:** instalação pela opção do navegador, `manifest.webmanifest`, ícones próprios, Service Worker com precache confiável da interface principal, carregamento offline dos setores visitados e atualização versionada sem misturar assets antigos e novos.
- **Diagnóstico de desempenho:** painel ativável de FPS, tempos de quadro P50/P95/P99, número de elementos DOM ativos, sprites no pool, duração do loop do Autopilot e custo de atualização de HUD. Instrumentação leve/desligável em produção, sem coletar dados pessoais e sem travar o jogo.
- **Replay de movimentação:** ferramenta local para gravar uma sequência curta de comandos de joystick, rumo, posição e eventos de navegação, exportar JSON e repetir o percurso determinísticamente quando possível; útil para caçar engasgos, mudança brusca de ângulo e jitter da câmera. Não precisa gravar vídeo.
- **Exportar/importar save:** backup local em JSON versionado com hash de integridade, prévia das alterações, confirmação antes de substituir a sessão, detecção de corrupção e recuperação via checkpoints A/B/C; sem introduzir segundo escritor de save.
- **Pré-carregamento e streaming de sprites:** carregar em segundo plano artes do próximo setor/portal, lazy-load do restante, atlas WebP/AVIF/PNG e limite de memória por perfil gráfico, evitando picos de FPS e downloads gigantes no Android.

---

## 01. DIAGNÓSTICO DO VÍDEO OFFLINE E CORREÇÃO PRIORITÁRIA

No vídeo de 04/11/2026, o protótipo exibe mapa espacial com planeta grande, estação orbital, nave e pequenas unidades, joystick, HUD de HP/escudo/porão, CONF1/CONF2, Radar Tático, botões de combate, menus **Missões / Hangar / Mercado / Setores / Save**, controles de efeitos, opções Baixo/Alto e memória de bordo. O visual é promissor, mas a nave apresenta transições de direção/ângulo pouco naturais e oscilações de FPS pontuais. O vídeo **não mede com precisão** a origem dos engasgos.

**CORRIGIR PRIMEIRO — movimento e orientação**

- **Separar** `desiredVelocity` (direção do joystick/clique) de `visualHeading` (orientação do sprite). A velocidade pode ser 360°, mas a nave **não deve girar 180° automaticamente** ao inverter deslocamento.
- Fixar a **direção frontal visual** da arte (nariz da nave apontando em geral para cima da tela ou para o sentido de câmera definido pelo jogo). Curvas apresentam uma inclinação de 0° a ±45° e, no máximo, ±60° nas manobras; acima disso, usar lateral/¾ frontal. **Não privilegiar sprite traseiro** durante recuo. Em movimento para baixo, a nave pode usar deslocamento de ré/propulsores suaves sem mudar o nariz para a parte inferior.
- Criar um **conjunto novo de sprites originais** para frente, frente-esquerda 22,5°/45°, frente-direita 22,5°/45°, perfil esquerdo/direito e frenagem. Opcionalmente 8–16 imagens de ¾ dianteiro; todas devem preservar escala, centro, sombras e iluminação coerentes. Spritesheet com **folga transparente em cada célula** para não cortar asas ou motores.
- Aplicar **smoothing de orientação baseado em delta time**, com interpolação angular pelo menor arco e limite de velocidade (começar com 120–160°/s), amortecimento 120–200 ms e histerese de ~8–12° nas trocas de frame. Ajustar por teste no aparelho; valores são parâmetros iniciais, não absolutos.
- Entrada analógica: **dead zone** no joystick (aprox. 0,10–0,15), aceleração suave, limite de velocidade e desaceleração sem snaps ao soltar o dedo. Bloquear comandos redundantes quando o vetor quase não muda.
- O deslocamento deve ser independente do FPS: `dt` limitado e normalizado, posição interpolada no `requestAnimationFrame`, lógica fixa/semifixa a 30/60 Hz. Nunca fazer `style.left/top` para deslocamentos frequentes; preferir `translate3d(x, y, 0)` e rotação/inclinação no mesmo elemento composto.
- Ter **um único controlador** de transformações da nave. Evitar `transition: transform` no mesmo elemento que recebe atualização a cada frame, pois as animações podem competir e provocar solavancos. Separar elemento de translação do elemento de inclinação: `ship-position` / `ship-visual`.
- **Câmera** acompanha a nave com suavização e sem jitter; definir zona morta e evitar pixel snapping conflitante. HUD não pode reajustar layout toda vez que o sprite muda.
- **Spray visual**: disparos, muzzle flashes, explosões e motores via spritesheets/efeitos pré-renderizados; animação CSS/WAAPI, objetos reaproveitados, sem partículas desenhadas proceduralmente.
- Fazer benchmark: 60 segundos movendo em círculos, zig-zag, parada/retomada e ré; registrar 50º/95º/99º percentis de frame, contagem de troca de ângulo, FPS e consumo de memória. **Aprovação:** sem saltos de orientação perceptíveis, sem giro brusco da traseira, posição consistente e ≥30 FPS como alvo em dispositivo de referência.

### Esqueleto de lógica de orientação (pseudocódigo, NÃO chamar diretamente APIs Canvas)

```js
const dt = Math.min(0.05, deltaSeconds);
const input = normalizeDeadzone(joystickX, joystickY, 0.12);
velocity = approachVector(velocity, input.scale(maxSpeed), acceleration * dt);
position = position.add(velocity.scale(dt));
const visualTarget = frontBiasedHeading(input, { maxYawDeg: 60, reverseKeepsNoseForward: true });
const easing = 1 - Math.exp(-dt / 0.16);
visualHeading = angularLerpShortest(visualHeading, visualTarget, easing, 150 * dt);
const spriteFrame = quantizeWithHysteresis(visualHeading, directionalAtlas, 10);
// update DOM com translate3d apenas uma vez ao final do frame.
```

---

## 02. ARQUITETURA OFFLINE, SAVE E FUTURA SINCRONIZAÇÃO

**Stack alvo:** HTML/CSS/JavaScript modular + PWA GitHub Pages + Android WebView/instalação de app; IndexedDB por conta/dispositivo; cache offline versionado. Sem Supabase/Render obrigatórios no laboratório.

```text
INPUT (joystick/toque/clique)
  -> GAME STATE EM MEMÓRIA (única instância)
  -> GAME LOOP: movimento, combate e renderização por sprites DOM
  -> COMMAND BUS / REDUCERS determinísticos
  -> TRANSAÇÃO ATÔMICA IndexedDB
       ├── snapshot ATUAL {revision, version, hash, state}
       ├── operations {opId, type, payload, status, createdAt}
       └── checkpoints A/B/C {revision, hash, capturedAt}
  -> UI/HUD reativos (somente alterações necessárias)
  -> FUTURO: Sync Adapter -> Render/Supabase (valida economia e multiplayer)
```

**Objetos de jogo indispensáveis**: `Player`, `Ship`, `Drones[]`, `Aux9`, `CombatConfigurations {conf1,conf2,active}`, `EquipmentInventory`, `AmmoInventory`, `WorldState`, `MapState`, `MissionState`, `BattlePass`, `Economy`, `Cargo`, `Resources`, `Refinery`, `Crafting`, `AuctionSandbox`, `Events`, `AutopilotState`, `OfflineFarmState`, `ClanSandbox`, `WarfrontSandbox`, `Cosmetics`, `Settings`, `SaveMeta`.

**Save obrigatório:** um `currentState` por perfil. `CONF1` e `CONF2` contêm *nave + drones + AUX-9* e seus equipamentos/protocolos; trocar CONF não duplica itens, não cura HP/escudo e não reseta o porão. Propriedade de itens permanece no inventário global; as duas CONF guardam apenas alocações válidas. `Designers` devem ser tratados explicitamente por alvo e por configuração, sem herdar bugs antigos.

**Checkpoint A/B/C:** três versões históricas verificadas. O checkpoint NÃO é outro escritor; só restaura mediante operação explícita de recuperação. Autossalvamento em eventos críticos e gravação periódica sem `JSON.stringify` enorme a cada quadro. Na recuperação, comparar revisão, hash e operação de origem, descartar apenas registros comprovadamente inválidos. Implementar exportação/importação de save JSON com validação de esquema.

**Fila local de operações:** UUID/idempotência, `pending|committed|failed|compensated`, `createdAt`, `revisionBefore`, `revisionAfter`, `payload`, `result`. Processar na mesma transação IndexedDB que altera o estado. Sem rede: comandos de economia **sandbox** podem ser concluídos localmente, mas marcados `labOnly`; nunca convertê-los automaticamente em créditos/STL competitivos quando o servidor for conectado.

**Futuro online:** envio de lotes pendentes a cada ~5 s enquanto em primeiro plano, flush ao reconectar/retomar, backoff, confirmação por recibo. Só Render/Supabase poderão validar Créditos/STL globais, comércio, leilão real, PvP, controle de clãs e Warfront; para isso migraremos a economia de laboratório por um adaptador com políticas de conciliação, **não por upload irrestrito de saldo local**. O laboratório funciona perfeitamente sem a rede.

**Quedas de energia/app:** no Android, `setInterval(5000)` pode ser suspenso; gravar antes de perder visibilidade e recuperar ao reabrir. Não pressupor que timers executam durante o encerramento.

---

## 03. SISTEMAS E FUNCIONALIDADES OBRIGATÓRIOS

### 03.1 Piloto, conta e progressão
- Criação/seleção de piloto, facção, callsign; XP, nível, pontos de habilidade, conquistas, títulos, estatísticas e perfil detalhado.
- Três facções com identidade visual, bases, território, missões, rivalidades e progressão própria.
- Naves desbloqueadas por compra, jornada, evento ou leilão; mudança de nave sem perder itens.
- Estatísticas claras: HP, escudo, dano de laser, dano de míssil, velocidade, regeneração, porão, bônus e modificadores.
- Habilidades de piloto, upgrades, especializações, pesquisa e melhorias com custo e cooldown; não dar bônus gratuitamente ao trocar de build.

### 03.2 Hangar completo e inventário
- **Hangar > Naves:** vitrine 2.5D com nova arte, status, raridade, capacidade, laser/escudo/motor/extras/designers e CONF global.
- **Hangar > Drones:** drones individualmente selecionáveis; lasers, escudos, designers, progressão do drone, slots e prévias nítidas.
- **Hangar > AUX-9:** equipamento de apoio próprio, nível/XP, nome e módulos; abas Informações, Armas, Escudos, Protocolos, Módulos e Designers; bônus e consumo corretos.
- **Inventário unificado:** todos os itens possuídos, quantidades, raridades, equipados em CONF1 ou CONF2, filtros, comparação e estado de durabilidade quando aplicável.
- **CONF1 e CONF2 globais:** uma configuração pode ser FARM, outra TANQUE/DEFESA; a troca sincroniza nave+drones+AUX simultaneamente. Sem inventário negativo, itens que desaparecem ou cópias fantasmas.
- **Designers:** aparência da nave, dos drones e do AUX-9 com raridade/preview/raridade de evento; permitir criar designers novos coerentes com cada classe.

### 03.3 Combate, inimigos e recompensas
- Controle 360° de deslocamento, travamento de alvo, alcance, HP/escudo, dano, mitigação, resistências, críticos quando especificados, efeitos de habilidade e IA dos NPCs.
- Armas laser ARC, munições PLS/SIP, mísseis CMT, tiro automático/manual, consumo correto por emissor (nave, drones e AUX-9) e cooldown.
- IA por classe: patrulha, perseguição, órbita, evasão, suporte, ataque especial, elites/Prime, chefes e ondas; NPCs de evento desaparecem ao fim do evento.
- Morte/respawn, reparo, retorno à base, loot de NPC, caixas bônus e minério; nunca conceder uma mesma recompensa duas vezes.
- **Apex Overlord** como chefe importante; fragmentos especiais conectados à forja dos protocolos.

### 03.4 Exploração e mapas
- Mundo espacial com mapas, portais interligados, rotas seguras/hostis, bases, traders, refinaria, missão, estação, relé, grupo e arenas.
- Setores da facção Terra / Marte / Júpiter conforme universo expandido; mapas X-1 a X-8 na árvore canônica, battleground PvP e portais astrais.
- **Extensão planejada do universo:** setores 1-1 a 1-8 (Terra), 2-1 a 2-8 (Marte), 3-1 a 3-8 (Júpiter); PvP 4-1/4-2/4-3; Universo U-1/U-2/U-3; dimensões Aurora/Nexus/Eclipse. Implementar essas regiões como **evolução da árvore** e não afirmar que as 40+ telas já existem no protótipo.
- Minimap, radar, pins, setas de portal, linhas de navegação, mapa galáctico, zoom e preview de perigo sem bloquear FPS.

### 03.5 Economia, mineração e comércio
- **Créditos** e **Stellarium (STL)**; regras independentes de aquisição, gasto, teto, fontes e destinos.
- **Recursos:** Ferron, Cryon, Virel; refinados Ferrite, Duracite, Solarium, Voidite. Caixas, minério, baús, drops e conversões (somente receitas oficiais, sem inventar multiplicadores).
- Porão com capacidade, extra de ampliação, bônus do AUX e validação de estoque; mineração, coleta, venda de recursos e estoque preservado ao reiniciar.
- Mercado/Loja Orbital, loja comum/premium, leilão simulado, preços e disponibilidade, compra 1x/5x/10x/Max onde fizer sentido, recibos de transação, recursos por quantidade.
- Refinaria com receitas de conversão e verificação de insumos; craft/materializador/forja e upgrades de lasers, equipamentos e AUX.
- Cupons e Passe/Premium com regras de acesso claras; assinatura premium offline é **simulada** até integração online.

### 03.6 AUX-9: especializações e protocolos
- AUX-9 tem especializações tradicionais **Guarda, Mineração, Salvager, Reparação, Nova Burst** com pontos de progressão, distintas dos protocolos avançados.
- Protocolos avançados: **DANO, HP, ESCUDO, BOX/LOOT e PORÃO**. Três tiers N1, N2, N3 por família; 15 artes originais possíveis, um card distinto por tier.
- Efeitos por tier: Dano 1/2/3% (laser AUX PvE); HP 1/2,5/5%; Escudo 2/4/7%; Box/Loot 1/4/7%; Porão 5/10/15%. O bônus não deve estourar limites, nem criar recursos do nada.
- Slots de protocolo avançado conforme nível AUX: nível 1=1, 5=2, 9=3, 13=4 e 17=5; separadamente das especializações gratuitas.
- Receita de **forja mais recente**: N1 por loja (Dano/HP/Escudo 50.000 STL; Box/Porão 100.000.000 Créditos); N2 requer **4× N1 da mesma família + 10 Fragmentos Apex + custo de craft**; N3 **4× N2 + 10 Fragmentos do Universo + custo de craft**; requisitos de nível AUX 8 e 15 para N2/N3. Valores de referência de craft: N2 a partir de 250.000 STL; N3 a partir de 500.000 STL + 180.000.000 Créditos. Preços editáveis no administrador da versão online; no laboratório ficam em dados locais configuráveis.
- Fragmento Apex: drop previsto de 10% do Apex Overlord; Fragmento do Universo: drop previsto de 10% nos NPCs de U-1/U-2/U-3, sempre idempotente.

### 03.7 Missões, Passe e atividades
- Campanha inicial/tutorial, missão diária/semanal, missões de caça, coleta, exploração, reparação, boss, PvP e facções.
- Passe de Temporada com tiers, pontos, missões gratuitas/premium, prêmios e interface completa; Jornada, conquistas, títulos, recompensas, notificações e centro de comando.
- **Regra de persistência:** abate contabilizado uma vez; missão concluída tem estado terminal explícito, resgate único e retomada após reiniciar; nunca completar novamente no login.
- Preparar eventos configuráveis de duração, ciclos e calendário de lançamento; NPCs de evento encerram quando o relógio do evento termina.

### 03.8 Autopilot, Farm Offline e comércio automático
- Autopilot com seleção de mapa, alvos, órbitas, prioridades de combate, coletar bônus/loot, mineração, vender, comprar munição/míssil, reparo e retornar/reiniciar.
- Prioridades configuráveis: sobrevivência, missão, minério, NPC, loot, caixa; evitar que o autopiloto interrompa cada combate para abrir o mercado.
- IA com tick desacoplado do loop de render; decisões a cada ~300–700 ms ajustáveis e navegação/render a 30/60 Hz; cache de cálculos de porão e preços.
- Farm Offline com início, duração, consumo, simulação determinística, progresso fechado, conclusão e resgate **apenas uma vez**, inclusive após meia-noite, virada do dia ou app fechado; limitar ganho sem jogar para não quebrar economia.
- Venda e compra automáticas por lotes, sem estados inconsistentes; persistir estratégias e recuperar depois do logout.

### 03.9 Multiplayer, Arena, clãs, relés e Warfront — offline agora, adaptável depois
- **Laboratório offline:** PvP contra bots/ghosts locais com regras de duelo, ranking simulado e arena; grupos de NPCs aliados, relés e Warfront PvE com captura, defesa e reinício de temporada. **Não chamar de multiplayer real sem servidor.**
- **Futuro online:** PvP entre contas, grupos/squads, clãs, chat global/clã/privado, convites, rotas compartilhadas, luta por relés, pontuação/controle territorial, arenas, Warfront, campanhas, recompensas e temporadas com relógio do servidor.
- Warfront: mapa tático de objetivos, fases de captura/defesa, reforços, pontuação de facção, líderes, recompensas e período do evento. Definir tudo em configurações ao invés de hardcode em telas.

### 03.10 Administração, qualidade e acessibilidade
- ADM/local debug: editar dados de teste (catálogo, NPCs, eventos, drops, mapa, missões, preços), gerar conta de testes e resetar progresso do laboratório com confirmação dupla.
- Telemetria visível: FPS, frame P95/P99, tempo das compras, tempo de IndexedDB, pendências no outbox, tamanho do save, memória estimada, NPCs ativos e atualização de UI.
- Menu de preferências: Baixo/Médio/Alto, som, vibração opcional, escala, acessibilidade, controles, ocultar HUD, mini mapa, idioma PT-BR, configurações de cache e salvar/exportar.
- PWA com ícone e instalação Android, versão de cache explícita, funcionar offline após carregar, tela de loading original e botão para instalar aplicativo.
- Não incluir logs de debug extensos na experiência de jogo; mostrar erros reais com status local/pendente/confirmado e botão de recuperação.

---

## 04. ESTRUTURA DE MENUS E HUD ALVO

```text
TELA PRINCIPAL / HUD
├── Perfil do Piloto (nível, XP, facção, moedas, vida/escudo, AUX)
├── Joystick / toque / autopilot / mira e disparos
├── Radar Tático / Minimap / Mapa Galáctico
├── Armas e munição (laser, mísseis, troca rápida)
├── Estado de porão / bases / portais / objetivo atual
├── Missões / Hangar / Mercado / Setores / SAVE (conservar menu do LAB)
├── Menus expandidos opcionais
│   ├── PILOTO → Hangar, Naves, Drones, AUX-9, Habilidades, Equipamentos, Designers
│   ├── MISSÕES → Missões, Jornada, Passe, Conquistas, Títulos, Atividades
│   ├── BATALHA → Arena, PvP sandbox, Relés, Warfront, Portais, Eventos, Grupos
│   ├── ECONOMIA → Mercado, Refinaria, Recursos, Leilão sandbox, Craft, Premium
│   ├── SOCIAL (futuro) → Clãs, Chat Global, Aliança, PV, Squad
│   └── MAIS → Mapa, Preferências, Logs/Diagnóstico, Salvar/Exportar, ADM
└── GESTÃO DE SAVE → perfil, status offline, snapshot, checkpoints A/B/C
```

**Regras de UX:** nos painéis, botões grandes para toque, nenhum modal cobrindo botões críticos, cards compatíveis com telas estreitas, vitrine inteira da nave sem corte, contador de saldo diferenciado, abas com hierarquia clara, item selecionado persistente, tela de missão sem afetar o loop de render. Fundo não deve ser refeito ao abrir menu.

---

## 05. DIREÇÃO DE ARTES — NOVAS ARTES ORIGINAIS PERMITIDAS

O Codex está autorizado a produzir **um novo conjunto gráfico completo**. As artes do jogo online são **referência de identidade e conteúdo**, não dependência obrigatória. Entregar assets novos coerentes com o estilo: ficção científica 2.5D, metal, emissivos azuis/cianos/âmbar e violeta, planetas e nebulosas detalhadas, contraste legível, design de silhueta própria para cada nave.

| Grupo | Produzir / aceitar novas artes | Técnica sugerida |
|---|---|---|
| Naves | sprites 2.5D de frente/¾, laterais, direção visual consistente; variantes de dano e designers | PNG/WebP com alpha + atlas com padding |
| NPCs | sprites, elites/Prime, bosses, 2–6 frames de motores/ataque | atlas e sprites pré-renderizados |
| Halo/Nova e AUX-9 | sprites de idle/combate, seleção, designers e módulos | `transform` DOM/WAAPI; sem procedural Canvas |
| Explosões/lasers/mísseis | assets transparentes de disparo, impacto, rastro e explosão | spritesheets / CSS animation / pooling |
| Mapas | planetas, estrelas, asteroides, estações, relés, portais, fundo de nebulosa | camadas WebP/AVIF pré-renderizadas |
| HUD e loja | ícones de itens/recursos com raridades, cartões e abas | SVG estático para interface ou imagem raster, sem desenho de jogo Canvas |
| Login/loading | logo Stellar Legacy, imagem de batalha com nave, drones, AUX e relés | imagem autoral otimizada |

**Processo de arte obrigatório:** produzir uma direção de arte e um catálogo de arquivos; criar arte em resolução de origem 2× a de exibição (quando o peso permitir), gerar LOD 0/1/2 ou versões low/medium/high, usar `image-rendering` adequado, testar objetos grandes e pequenos, atlas com margem entre sprites, registrar licença/proveniência dos próprios assets, proibir imagens externas sem direitos. **Nunca usar placeholders coloridos genéricos como arte final.**

**Requisitos de desempenho:** PNG apenas quando transparência indispensável; preferir WebP/AVIF para cenários; lazy-load de NPCs por mapa, cache de imagens `decode()` antes de exibí-las, pooling de sprites e DOM nodes, culling fora da viewport, atualizar HUD somente ao mudar dado, orçamento por perfil gráfico. Sem downloads em combate que gerem travamentos.

---

## 06. CATÁLOGO CANÔNICO COMPLETO — 177 REGISTROS

Catálogo oficial extraído do `public/data.js` do projeto principal. Estes são nomes de gameplay; **não mostrar identificadores históricos do SQL nas lojas, missões, tooltips nem saves exibidos**. Alguns registros incluem conteúdo de EVENTO/FUTURO: estão listados para planejamento, não automaticamente disponíveis para compra.


## faccoes — 3

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| Terra Alliance | `terra-alliance` | Tecnologia, comércio e defesa orbital. | — |
| Mars Dominion | `mars-dominion` | Força militar, indústria e expansão agressiva. | — |
| Jupiter Federation | `jupiter-federation` | Pesquisa, mineração e domínio das rotas externas. | — |

## naves — 43

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| Aurora | `aurora` | Nave inicial | 0 Créditos |
| Pioneer | `pioneer` | Progressão inicial | 10.000.000 Créditos |
| Raptor | `raptor` | Ataque rápido | 30.000.000 Créditos |
| Meridian | `meridian` | Farm e progressão | 80.000.000 Créditos |
| Bastion | `bastion` | Tanque comum | 150.000.000 Créditos |
| Concord | `concord` | Nave de progressão avançada | 160.000.000 Créditos |
| Vanguard | `vanguard` | Caçadora comum avançada | 240.000.000 Créditos |
| Sovereign | `sovereign` | Nave comum topo de créditos | 400.000.000 Créditos |
| Lynx | `lynx` | Elite de mapas baixos | 900.000 STL |
| Valkyrie | `valkyrie` | Elite veloz | 1.400.000 STL |
| Leviathan | `leviathan` | Elite de combate pesado | 2.500.000 STL |
| Striker | `striker` | Elite ofensiva de alta velocidade | 3.500.000 STL |
| Seraph | `seraph` | EVENTO • suporte | 0 STL |
| Venatrix | `venatrix` | EVENTO • controle tóxico | 0 STL |
| Ravager | `ravager` | EVENTO • contra-ataque | 0 STL |
| Praetor | `praetor` | EVENTO • projetos instáveis | 0 STL |
| Bulwark | `bulwark` | EVENTO • tanque pesado | 0 STL |
| Nexus Prime | `nexus-prime` | EVENTO • dano contínuo | 0 STL |
| Phantom | `phantom` | EVENTO • camuflagem | 0 STL |
| Wraith | `wraith` | EVENTO • camuflagem reforçada | 0 STL |
| Nullifier | `nullifier` | EVENTO • anti-escudo | 0 STL |
| Interdictor | `interdictor` | EVENTO • interferência | 0 STL |
| Leviathan-X | `leviathan-x` | EVENTO • congelamento | 0 STL |
| Ironclaw | `ironclaw` | EVENTO • suporte pesado | 0 STL |
| Lumina | `lumina` | EVENTO • feixe de partículas | 0 STL |
| Mirage | `mirage` | EVENTO • reversão | 0 STL |
| Gravastar | `gravastar` | EVENTO • controle gravitacional | 0 STL |
| Plaguewing | `plaguewing` | EVENTO • contágio | 0 STL |
| Echo | `echo` | EVENTO • evasão | 0 STL |
| Doppel | `doppel` | EVENTO • duplicação | 0 STL |
| Warden | `warden` | EVENTO • sobrevivência | 0 STL |
| Lancer | `lancer` | EVENTO • tiro carregado | 0 STL |
| Guardian | `guardian` | EVENTO • defesa | 0 STL |
| Reclaimer | `reclaimer` | EVENTO • reparação | 0 STL |
| Helios | `helios` | EVENTO • incêndio | 0 STL |
| Pathfinder | `pathfinder` | EVENTO • reconhecimento | 0 STL |
| Prism | `prism` | EVENTO • defesa prismática | 0 STL |
| Hellrunner | `hellrunner` | EVENTO • velocidade / foguetes | 0 STL |
| Stormrider | `stormrider` | EVENTO • eletricidade | 0 STL |
| Viper | `viper` | EVENTO • dano contínuo | 0 STL |
| Kensei | `kensei` | EVENTO • aceleração | 0 STL |
| Shogun | `shogun` | EVENTO • aceleração | 0 STL |
| Gale | `gale` | EVENTO • momentum | 0 STL |

## equipamentos — 40

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| ARC-1 | `arc-1` | laser | 1.000.000 Créditos |
| ARC-P1 | `arc-p1` | laser | 5.000.000 Créditos |
| SOL-1 | `sol-1` | laser | 20.000.000 Créditos |
| ARC-2 | `arc-2` | laser | 25.000.000 Créditos |
| ARC-3 | `arc-3` | laser | 125.000 STL |
| ARC-4 | `arc-4` | laser | 500.000 STL |
| ARC-X | `arc-x` | laser | 0 STL |
| ARC-Ω | `arc-omega` | laser | 0 STL |
| THR-1 | `thr-1` | generator | 250.000 Créditos |
| THR-2 | `thr-2` | generator | 1.000.000 Créditos |
| THR-3 | `thr-3` | generator | 3.000.000 Créditos |
| THR-4 | `thr-4` | generator | 10.000.000 Créditos |
| THR-5 | `thr-5` | generator | 80.000 STL |
| THR-6 | `thr-6` | generator | 250.000 STL |
| THR-7 | `thr-7` | generator | 0 STL |
| AEG-1 | `aeg-1` | generator | 15.000.000 Créditos |
| AEG-2 | `aeg-2` | generator | 80.000.000 Créditos |
| AEG-3 | `aeg-3` | generator | 0 STL |
| AEG-4 | `aeg-4` | generator | 0 STL |
| VSH-0 | `vsh-0` | generator | 0 STL |
| VSH-1 | `vsh-1` | generator | 1.000.000 Créditos |
| VSH-2 | `vsh-2` | generator | 5.000.000 Créditos |
| VSH-3 | `vsh-3` | generator | 20.000.000 Créditos |
| VSH-4 | `vsh-4` | generator | 60.000.000 Créditos |
| VSH-5 | `vsh-5` | generator | 250.000 STL |
| VSH-6 | `vsh-6` | generator | 0 STL |
| Mira Autônoma | `mira-autonoma` | extra | 10.000.000 Créditos |
| Lançador Autônomo | `lancador-autonomo` | extra | 12.000.000 Créditos |
| Propulsor de Recarga | `propulsor-de-recarga` | extra | 25.000.000 Créditos |
| CPU Expansora de Extras • Comum | `cpu-expansora-de-extras-comum` | extra | 50.000.000 Créditos |
| CPU Expansora de Extras • Elite | `cpu-expansora-de-extras-elite` | extra | 250.000 STL |
| Nanobot de Reparo • Comum | `nanobot-de-reparo-comum` | extra | 20.000.000 Créditos |
| Nanobot de Reparo • Elite | `nanobot-de-reparo-elite` | extra | 180.000 STL |
| Nanobot Prime | `nanobot-prime` | extra | 0 STL |
| Módulo de Porão • Comum | `modulo-de-porao-comum` | extra | 75.000.000 Créditos |
| Módulo de Porão • Elite | `modulo-de-porao-elite` | extra | 500.000 STL |
| Repositor Automático | `repositor-automatico` | extra | 30.000.000 Créditos |
| Terminal Mercante Remoto • Elite | `terminal-mercante-remoto-elite` | extra | 350.000 STL |
| Halo | `halo` | drone | 10.000.000 Créditos |
| Nova | `nova` | drone | 15.000 STL |

## municao laser — 5

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| PLS-1 | `pls-1` | — | 500.000 Créditos |
| PLS-2 | `pls-2` | — | 1.500.000 Créditos |
| PLS-3 | `pls-3` | — | 20.000 STL |
| PLS-4 | `pls-4` | — | 100.000 STL |
| SIP-2 | `sip-2` | Captura energia de escudo x2 e transfere o valor drenado para seu próprio… | 45.000 STL |

## misseis — 4

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| CMT-1 | `cmt-1` | — | 500.000 Créditos |
| CMT-2 | `cmt-2` | — | 2.000.000 Créditos |
| CMT-3 | `cmt-3` | — | 10.000 STL |
| CMT-4 | `cmt-4` | — | 30.000 STL |

## recursos — 7

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| Ferron | `ferron` | — | — |
| Cryon | `cryon` | — | — |
| Virel | `virel` | — | — |
| Ferrite | `ferrite` | — | — |
| Duracite | `duracite` | — | — |
| Solarium | `solarium` | — | — |
| Voidite | `voidite` | — | — |

## npcs — 34

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| Scavenger | `scavenger` | — | — |
| Scavenger Scout | `scavenger-scout` | — | — |
| Scavenger Support | `scavenger-support` | — | — |
| Scavenger Prime | `scavenger-prime` | — | — |
| Vrax | `vrax` | — | — |
| Vrax Prime | `vrax-prime` | — | — |
| Zyron | `zyron` | — | — |
| Zyron Prime | `zyron-prime` | — | — |
| Kharon | `kharon` | — | — |
| Kharon Prime | `kharon-prime` | — | — |
| Dreadnox | `dreadnox` | — | — |
| Dreadnox Prime | `dreadnox-prime` | — | — |
| Colossar | `colossar` | — | — |
| Colossar Prime | `colossar-prime` | — | — |
| Ember Fang | `ember-fang` | — | — |
| Ember Fang Prime | `ember-fang-prime` | — | — |
| Iron Wasp | `iron-wasp` | — | — |
| Iron Wasp Prime | `iron-wasp-prime` | — | — |
| Rift Mauler | `rift-mauler` | — | — |
| Rift Mauler Prime | `rift-mauler-prime` | — | — |
| Obsidian Pike | `obsidian-pike` | — | — |
| Obsidian Pike Prime | `obsidian-pike-prime` | — | — |
| Apex Overlord | `apex-overlord` | — | — |
| Sentinel Scavenger | `sentinel-scavenger` | — | — |
| Sentinel Scout | `sentinel-scout` | — | — |
| Sentinel Support | `sentinel-support` | — | — |
| Batedor da Fenda | `batedor-da-fenda` | — | — |
| Batedor da Fenda Prime | `batedor-da-fenda-prime` | — | — |
| Corsário do Vazio | `corsario-do-vazio` | — | — |
| Corsário do Vazio Prime | `corsario-do-vazio-prime` | — | — |
| Guardião Nexus | `guardiao-nexus` | — | — |
| Guardião Nexus Prime | `guardiao-nexus-prime` | — | — |
| Ceifador Astral | `ceifador-astral` | — | — |
| Ceifador Astral Prime | `ceifador-astral-prime` | — | — |

## npcs futuros — 27

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| Vrax Spore | `vrax-spore` | — | — |
| Colossar Spawn | `colossar-spawn` | — | — |
| Colossar Spawn Prime | `colossar-spawn-prime` | — | — |
| Colossar Spawn Apex | `colossar-spawn-apex` | — | — |
| Vrax Overlord | `vrax-overlord` | — | — |
| Vrax Overlord Prime | `vrax-overlord-prime` | — | — |
| Vrax Overlord Apex | `vrax-overlord-apex` | — | — |
| Crysalid | `crysalid` | — | — |
| Crysalid Prime | `crysalid-prime` | — | — |
| Crysalid Apex | `crysalid-apex` | — | — |
| Crysalon | `crysalon` | — | — |
| Crysalon Prime | `crysalon-prime` | — | — |
| Crysalon Apex | `crysalon-apex` | — | — |
| Reaver | `reaver` | — | — |
| Reaver Prime | `reaver-prime` | — | — |
| Reaver Apex | `reaver-apex` | — | — |
| Wardrone | `wardrone` | — | — |
| Wardrone Apex | `wardrone-apex` | — | — |
| Nexus Core | `nexus-core` | — | — |
| Riftling II | `riftling-ii` | — | — |
| Warden IX | `warden-ix` | — | — |
| Harbinger XVI | `harbinger-xvi` | — | — |
| Pyre Behemoth | `pyre-behemoth` | — | — |
| Starfall Barrage | `starfall-barrage` | — | — |
| Emperor Vrax | `emperor-vrax` | — | — |
| Emperor Crysalon | `emperor-crysalon` | — | — |
| Emperor Colossar | `emperor-colossar` | — | — |

## mapas — 14

| Nome oficial | Código novo | Categoria / função | Custo atual |
|---|---|---|---|
| Fronteira Inicial | `fronteira-inicial` | — | — |
| Nebulosa Azul | `nebulosa-azul` | — | — |
| Cinturão Sombrio | `cinturao-sombrio` | — | — |
| Planícies de Fogo | `planicies-de-fogo` | — | — |
| Véu da Fenda | `veu-da-fenda` | — | — |
| Desfiladeiro Vazio | `desfiladeiro-vazio` | — | — |
| Coração do Nexus | `coracao-do-nexus` | — | — |
| Bastião Astral | `bastiao-astral` | — | — |
| Deep Battle Alpha | `deep-battle-alpha` | — | — |
| Alien Core Beta | `alien-core-beta` | — | — |
| Abismo Vermelho | `abismo-vermelho` | — | — |
| Portal Astral Alpha | `portal-astral-alpha` | — | — |
| Portal Astral Beta | `portal-astral-beta` | — | — |
| Portal Astral Gamma | `portal-astral-gamma` | — | — |


### 06.1 Observações sobre os dados oficiais

- Valores e atributos a seguir são *referências da base auditada*, sujeitos a balanceamento. Para o offline, podem ser usados como ponto de partida com tabela de ajustes **centralizada**; nunca replicar preços em múltiplos componentes.
- Naves EVENTO com preço zero são **recompensas especiais**, não compra gratuita.
- Contentores futuros, variantes estelares e NPCs futuros devem ficar em `plannedContent` até possuírem arte, estatísticas, spawn e testes.
- O banco remoto usa códigos legados; a tradução deve ocorrer em um único adaptador. **No produto offline**, usar `code`/`name` canônicos do catálogo e não espalhar aliases históricos.


## 07. ATRIBUTOS DE REFERÊNCIA DO CATÁLOGO — NÃO APENAS NOMES

Nesta seção, as tabelas derivam de atributos estáticos do catálogo oficial e podem servir como `seed` do banco local, sem precisar consultar Supabase. `Créditos` e `STL` são as duas moedas do jogo; os custos de economia podem ser reajustados posteriormente por dados centralizados.

### 07.1 Atributos de todas as naves (43)


| Nave | Função | HP | Lasers | Geradores | Velocidade | Porão | Extras | Obtenção/custo | Marcadores |
|---|---|---|---|---|---|---|---|---|---|
| Aurora | Nave inicial | 104.000 | 1 | 1 | 320 | 100 | 1 | Não disponível na loja | Loja bloqueada |
| Pioneer | Progressão inicial | 116.000 | 4 | 6 | 300 | 400 | 2 | 10.000.000 Créditos | — |
| Raptor | Ataque rápido | 164.000 | 6 | 8 | 360 | 600 | 2 | 30.000.000 Créditos | — |
| Meridian | Farm e progressão | 220.000 | 7 | 10 | 340 | 700 | 3 | 80.000.000 Créditos | — |
| Bastion | Tanque comum | 360.000 | 8 | 15 | 260 | 800 | 3 | 150.000.000 Créditos | — |
| Concord | Nave de progressão avançada | 240.000 | 7 | 10 | 340 | 900 | 3 | Exclusivo de evento | Evento, Loja bloqueada |
| Vanguard | Caçadora comum avançada | 160.000 | 10 | 10 | 340 | 1000 | 3 | Exclusivo de evento | Evento, Loja bloqueada |
| Sovereign | Nave comum topo de créditos | 320.000 | 12 | 12 | 340 | 1500 | 3 | Exclusivo de evento | Evento, Loja bloqueada |
| Lynx | Elite de mapas baixos | 164.000 | 6 | 6 | 360 | 500 | 1 | 900.000 STL | — |
| Valkyrie | Elite veloz | 280.000 | 10 | 10 | 380 | 1000 | 2 | 1.400.000 STL | — |
| Leviathan | Elite de combate pesado | 356.000 | 15 | 15 | 300 | 1500 | 3 | 2.500.000 STL | — |
| Striker | Elite ofensiva de alta velocidade | 225.000 | 16 | 12 | 370 | 500 | 3 | Exclusivo de evento | Evento, Loja bloqueada |
| Seraph | EVENTO • suporte | 455.000 | 11 | 18 | 315 | 2250 | 4 | Exclusivo de evento | Evento, Habilidade especial |
| Venatrix | EVENTO • controle tóxico | 450.000 | 15 | 17 | 330 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Ravager | EVENTO • contra-ataque | 620.000 | 8 | 18 | 300 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Praetor | EVENTO • projetos instáveis | 455.000 | 16 | 17 | 335 | 1600 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Bulwark | EVENTO • tanque pesado | 750.000 | 8 | 21 | 250 | 4500 | 5 | Exclusivo de evento | Evento, Habilidade especial |
| Nexus Prime | EVENTO • dano contínuo | 455.000 | 16 | 17 | 325 | 1600 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Phantom | EVENTO • camuflagem | 290.000 | 12 | 11 | 380 | 900 | 3 | Exclusivo de evento | Evento, Habilidade especial |
| Wraith | EVENTO • camuflagem reforçada | 365.000 | 12 | 12 | 385 | 1000 | 3 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Nullifier | EVENTO • anti-escudo | 460.000 | 15 | 17 | 325 | 1700 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Interdictor | EVENTO • interferência | 450.000 | 14 | 16 | 345 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Leviathan-X | EVENTO • congelamento | 540.000 | 15 | 18 | 305 | 1900 | 5 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Ironclaw | EVENTO • suporte pesado | 465.000 | 13 | 18 | 305 | 1900 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Lumina | EVENTO • feixe de partículas | 475.000 | 15 | 17 | 320 | 1600 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Mirage | EVENTO • reversão | 445.000 | 15 | 16 | 330 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Gravastar | EVENTO • controle gravitacional | 480.000 | 15 | 18 | 320 | 1750 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Plaguewing | EVENTO • contágio | 445.000 | 15 | 17 | 330 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Echo | EVENTO • evasão | 430.000 | 13 | 15 | 350 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Doppel | EVENTO • duplicação | 440.000 | 15 | 16 | 320 | 1750 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Warden | EVENTO • sobrevivência | 500.000 | 13 | 20 | 315 | 1750 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Lancer | EVENTO • tiro carregado | 465.000 | 15 | 16 | 340 | 1600 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Guardian | EVENTO • defesa | 535.000 | 15 | 18 | 305 | 1800 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Reclaimer | EVENTO • reparação | 465.000 | 15 | 17 | 320 | 1800 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Helios | EVENTO • incêndio | 460.000 | 15 | 17 | 330 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Pathfinder | EVENTO • reconhecimento | 280.000 | 7 | 12 | 410 | 650 | 3 | Exclusivo de evento | Evento, Habilidade especial |
| Prism | EVENTO • defesa prismática | 510.000 | 15 | 18 | 310 | 1750 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Hellrunner | EVENTO • velocidade / foguetes | 460.000 | 14 | 16 | 345 | 1700 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Stormrider | EVENTO • eletricidade | 450.000 | 14 | 16 | 360 | 1700 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Viper | EVENTO • dano contínuo | 450.000 | 15 | 17 | 335 | 1700 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Kensei | EVENTO • aceleração | 340.000 | 10 | 13 | 365 | 1100 | 3 | Exclusivo de evento | Evento, Habilidade especial |
| Shogun | EVENTO • aceleração | 390.000 | 11 | 14 | 375 | 1200 | 3 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |
| Gale | EVENTO • momentum | 380.000 | 13 | 16 | 370 | 1650 | 4 | Exclusivo de evento | Evento, Loja bloqueada, Habilidade especial |


### 07.2 Armas, geradores, escudos, motores, extras e drones (40)


| Item/equipamento | Classe | Atributos base (quando definidos) | Preço/obtenção | Regra |
|---|---|---|---|---|
| ARC-1 | laser | Dano: 65 | 1.000.000 Créditos | — |
| ARC-P1 | laser | Dano: 70 | 5.000.000 Créditos | — |
| SOL-1 | laser | Dano: 125 | 20.000.000 Créditos | Loja indisponível |
| ARC-2 | laser | Dano: 140 | 25.000.000 Créditos | — |
| ARC-3 | laser | Dano: 175; Bônus PvE: 0.15 | 125.000 STL | — |
| ARC-4 | laser | Dano: 200 | 500.000 STL | — |
| ARC-X | laser | Dano: 250; Bônus PvE: 0.04 | Exclusivo de evento | Evento |
| ARC-Ω | laser | Dano: 265; Bônus PvE: 0.06 | Exclusivo de evento | Evento |
| THR-1 | speed | Vel.: 2 | 250.000 Créditos | — |
| THR-2 | speed | Vel.: 3 | 1.000.000 Créditos | — |
| THR-3 | speed | Vel.: 4 | 3.000.000 Créditos | — |
| THR-4 | speed | Vel.: 5 | 10.000.000 Créditos | — |
| THR-5 | speed | Vel.: 7 | 80.000 STL | — |
| THR-6 | speed | Vel.: 10 | 250.000 STL | — |
| THR-7 | speed | Vel.: 14 | Exclusivo de evento | Evento |
| AEG-1 | shield | Escudo: 3200; Absorção: 70; Regen. escudo: 0.0625 | 15.000.000 Créditos | — |
| AEG-2 | shield | Escudo: 5600; Absorção: 75; Regen. escudo: 0.0625 | 80.000.000 Créditos | — |
| AEG-3 | shield | Escudo: 12500; Absorção: 82; Regen. escudo: 0.0625 | Exclusivo de evento | Evento |
| AEG-4 | shield | Escudo: 17200; Absorção: 84; Regen. escudo: 0.0625 | Exclusivo de evento | Evento |
| VSH-0 | shield | Escudo: 13500; Absorção: 78 | Exclusivo de evento | Evento |
| VSH-1 | shield | Escudo: 1000; Absorção: 40 | 1.000.000 Créditos | — |
| VSH-2 | shield | Escudo: 5000; Absorção: 50 | 5.000.000 Créditos | — |
| VSH-3 | shield | Escudo: 5000; Absorção: 60 | 20.000.000 Créditos | — |
| VSH-4 | shield | Escudo: 9500; Absorção: 70 | 60.000.000 Créditos | — |
| VSH-5 | shield | Escudo: 10000; Absorção: 80 | 250.000 STL | — |
| VSH-6 | shield | Escudo: 17500; Absorção: 85 | Exclusivo de evento | Evento |
| Mira Autônoma | extra | Ao selecionar um alvo, inicia o laser automaticamente. | 10.000.000 Créditos | — |
| Lançador Autônomo | extra | Dispara automaticamente o míssil selecionado durante o combate. | 12.000.000 Créditos | — |
| Propulsor de Recarga | extra | Reduz o cooldown de mísseis pela metade. | 25.000.000 Créditos | — |
| CPU Expansora de Extras • Comum | extra | Extra slots: 3 | 50.000.000 Créditos | — |
| CPU Expansora de Extras • Elite | extra | Extra slots: 6 | 250.000 STL | — |
| Nanobot de Reparo • Comum | extra | Reparo: 0.01 | 20.000.000 Créditos | — |
| Nanobot de Reparo • Elite | extra | Reparo: 0.02 | 180.000 STL | — |
| Nanobot Prime | extra | Reparo: 0.024 | Exclusivo de evento | Evento |
| Módulo de Porão • Comum | extra | Porão +: 2500 | 75.000.000 Créditos | — |
| Módulo de Porão • Elite | extra | Porão +: 10000 | 500.000 STL | — |
| Repositor Automático | extra | Compra automaticamente novo pacote da munição laser e do míssil selecionados quando o estoque estiver baixo. | 30.000.000 Créditos | — |
| Terminal Mercante Remoto • Elite | extra | EXTRA Elite: enquanto equipado, permite vender recursos diretamente na aba Refinaria do Hangar em qualquer setor, sem retorno | 350.000 STL | — |
| Halo | drone | Slots: 1 | 10.000.000 Créditos | — |
| Nova | drone | Slots: 2 | 15.000 STL | — |


### 07.3 Munições e mísseis


| Nome | Tipo | Efeito/dano | Pacote | Custo |
|---|---|---|---|---|
| PLS-1 | Laser | x1 | 10.000 unidades | 500.000 Créditos |
| PLS-2 | Laser | x2 | 5.000 unidades | 1.500.000 Créditos |
| PLS-3 | Laser | x3 | 5.000 unidades | 20.000 STL |
| PLS-4 | Laser | x4 | 5.000 unidades | 100.000 STL |
| SIP-2 | Laser | x2; dreno de escudo True | 5.000 unidades | 45.000 STL |
| CMT-1 | Míssil | Dano 1.000 | 100 unidades | 500.000 Créditos |
| CMT-2 | Míssil | Dano 2.000 | 100 unidades | 2.000.000 Créditos |
| CMT-3 | Míssil | Dano 4.000 | 100 unidades | 10.000 STL |
| CMT-4 | Míssil | Dano 6.000 | 100 unidades | 30.000 STL |


### 07.4 Recursos e preço-base de venda


| Recurso | Venda unitária na base auditada | Uso |
|---|---|---|
| Ferron | 1.000 Créditos | Mineração, refinaria, comércio e craft |
| Cryon | 1.500 Créditos | Mineração, refinaria, comércio e craft |
| Virel | 2.500 Créditos | Mineração, refinaria, comércio e craft |
| Ferrite | 10.000 Créditos | Mineração, refinaria, comércio e craft |
| Duracite | 15.000 Créditos | Mineração, refinaria, comércio e craft |
| Solarium | 35.000 Créditos | Mineração, refinaria, comércio e craft |
| Voidite | 0 Créditos | Mineração, refinaria, comércio e craft |


### 07.5 NPCs atuais (34): base de balanceamento


| NPC | HP | Escudo | Dano | XP | Créditos | STL | Recursos-base |
|---|---|---|---|---|---|---|---|
| Scavenger | 900 | 500 | 95 | 200 | 6.200 | 13 | Ferron×12, Cryon×12 |
| Scavenger Scout | 1.100 | 700 | 130 | 260 | 8.800 | 17 | Ferron×14, Cryon×14 |
| Scavenger Support | 1.500 | 1.000 | 210 | 370 | 12.400 | 26 | Ferron×15, Virel×15 |
| Scavenger Prime | 1.600 | 800 | 120 | 440 | 15.400 | 32 | Ferron×20, Virel×20 |
| Vrax | 2.000 | 2.000 | 240 | 530 | 18.500 | 32 | Ferron×20, Virel×20, Cryon×20 |
| Vrax Prime | 4.000 | 4.000 | 480 | 1.060 | 37.100 | 63 | Ferron×40, Virel×40, Cryon×40, Voidite×1 |
| Zyron | 6.000 | 6.000 | 600 | 1.060 | 36.000 | 47 | Ferron×40, Virel×40, Cryon×40, Ferrite×2, Duracite×2 |
| Zyron Prime | 12.000 | 12.000 | 1.200 | 2.110 | 72.100 | 94 | Ferron×80, Virel×80, Cryon×80, Ferrite×4, Duracite×4, Voidite×2 |
| Kharon | 20.000 | 10.000 | 1.170 | 2.640 | 92.700 | 105 | Ferron×80, Virel×80, Cryon×80, Ferrite×8, Duracite×8, Solarium×1 |
| Kharon Prime | 40.000 | 20.000 | 2.340 | 5.280 | 185.400 | 210 | Ferron×160, Virel×160, Cryon×160, Ferrite×16, Duracite×16, Solarium×2, Voidite×4 |
| Dreadnox | 108.000 | 108.000 | 3.780 | 8.780 | 330.000 | 280 | Ferron×100, Virel×100, Cryon×100, Ferrite×16, Duracite×16, Solarium×2 |
| Dreadnox Prime | 216.000 | 216.000 | 7.560 | 17.570 | 660.000 | 560 | Ferron×200, Virel×200, Cryon×200, Ferrite×32, Duracite×32, Solarium×4, Voidite×8 |
| Colossar | 216.000 | 216.000 | 8.350 | 14.640 | 715.000 | 448 | Ferron×200, Virel×200, Cryon×200, Ferrite×32, Duracite×32, Solarium×4 |
| Colossar Prime | 432.000 | 432.000 | 16.695 | 29.280 | 1.430.000 | 896 | Ferron×400, Virel×400, Cryon×400, Ferrite×64, Duracite×64, Solarium×8, Voidite×16 |
| Ember Fang | 266.800 | 172.500 | 4.535 | 19.580 | 731.600 | 487 | Ferrite×20, Duracite×20, Solarium×3 |
| Ember Fang Prime | 533.600 | 345.000 | 8.425 | 40.500 | 1.475.000 | 986 | Ferrite×31, Duracite×31, Solarium×7, Voidite×2 |
| Iron Wasp | 324.800 | 253.000 | 5.510 | 23.620 | 896.800 | 580 | Ferrite×22, Duracite×22, Solarium×3 |
| Iron Wasp Prime | 649.600 | 494.500 | 10.045 | 48.600 | 1.829.000 | 1.137 | Ferrite×36, Duracite×36, Solarium×7, Voidite×2 |
| Rift Mauler | 417.600 | 368.000 | 6.910 | 31.050 | 1.156.400 | 754 | Ferrite×25, Duracite×25, Solarium×4, Voidite×1 |
| Rift Mauler Prime | 835.200 | 713.000 | 12.745 | 63.450 | 2.360.000 | 1.508 | Ferrite×40, Duracite×40, Solarium×9, Voidite×3 |
| Obsidian Pike | 580.000 | 483.000 | 8.965 | 41.850 | 1.593.000 | 986 | Ferrite×27, Duracite×29, Solarium×6, Voidite×2 |
| Obsidian Pike Prime | 1.136.800 | 989.000 | 16.415 | 87.750 | 3.304.000 | 1.972 | Ferrite×45, Duracite×47, Solarium×11, Voidite×4 |
| Apex Overlord | 6.000.000 | 4.200.000 | 32.000 | 425.000 | 14.000.000 | 8.800 | Ferrite×110, Duracite×110, Solarium×36, Voidite×45 |
| Sentinel Scavenger | 780.000 | 590.000 | 10.465 | 52.200 | 1.952.000 | 1.140 | Ferrite×34, Duracite×34, Solarium×7, Voidite×2 |
| Sentinel Scout | 912.000 | 684.400 | 11.770 | 60.900 | 2.257.000 | 1.320 | Ferrite×36, Duracite×36, Solarium×7, Voidite×2 |
| Sentinel Support | 1.080.000 | 826.000 | 13.950 | 75.400 | 2.684.000 | 1.560 | Ferrite×38, Duracite×40, Solarium×9, Voidite×3 |
| Batedor da Fenda | 371.200 | 253.000 | 5.615 | 24.300 | 1.003.000 | 696 | Ferrite×27, Duracite×27, Solarium×4 |
| Batedor da Fenda Prime | 719.200 | 517.500 | 10.585 | 51.300 | 2.124.000 | 1.392 | Ferrite×40, Duracite×40, Solarium×9, Voidite×2 |
| Corsário do Vazio | 556.800 | 437.000 | 8.210 | 37.800 | 1.475.000 | 986 | Ferrite×31, Duracite×31, Solarium×6, Voidite×1 |
| Corsário do Vazio Prime | 1.067.200 | 874.000 | 15.660 | 78.300 | 3.186.000 | 1.914 | Ferrite×45, Duracite×45, Solarium×10, Voidite×3 |
| Guardião Nexus | 840.000 | 731.600 | 11.990 | 62.350 | 2.318.000 | 1.440 | Ferrite×38, Duracite×38, Solarium×8, Voidite×2 |
| Guardião Nexus Prime | 1.620.000 | 1.357.000 | 22.455 | 124.700 | 4.758.000 | 2.760 | Ferrite×54, Duracite×54, Solarium×13, Voidite×6 |
| Ceifador Astral | 1.260.000 | 1.038.400 | 17.005 | 92.800 | 3.477.000 | 2.100 | Ferrite×43, Duracite×43, Solarium×9, Voidite×3 |
| Ceifador Astral Prime | 2.460.000 | 2.006.000 | 30.955 | 191.400 | 7.076.000 | 4.080 | Ferrite×63, Duracite×63, Solarium×16, Voidite×9 |


### 07.6 NPCs futuros (27): prototipar e liberar por fase


| NPC futuro | HP | Escudo | Dano | XP | Créditos | STL | Estado |
|---|---|---|---|---|---|---|---|
| Vrax Spore | 4.000 | 4.000 | 160 | 400 | 800 | 3 | Futuro / não ativar sem evento |
| Colossar Spawn | 40.000 | 40.000 | 3.200 | 3.200 | 12.800 | 12 | Futuro / não ativar sem evento |
| Colossar Spawn Prime | 160.000 | 160.000 | 12.800 | 12.800 | 102.400 | 48 | Futuro / não ativar sem evento |
| Colossar Spawn Apex | 320.000 | 320.000 | 8.000 | 25.600 | 204.800 | 96 | Futuro / não ativar sem evento |
| Vrax Overlord | 300.000 | 200.000 | 3.600 | 25.600 | 204.800 | 64 | Futuro / não ativar sem evento |
| Vrax Overlord Prime | 1.200.000 | 800.000 | 14.400 | 102.400 | 819.200 | 256 | Futuro / não ativar sem evento |
| Vrax Overlord Apex | 2.400.000 | 1.600.000 | 32.000 | 204.800 | 1.638.400 | 512 | Futuro / não ativar sem evento |
| Crysalid | 50.000 | 40.000 | 1.650 | 6.400 | 12.800 | 16 | Futuro / não ativar sem evento |
| Crysalid Prime | 200.000 | 160.000 | 4.700 | 25.600 | 51.200 | 64 | Futuro / não ativar sem evento |
| Crysalid Apex | 400.000 | 320.000 | 13.200 | 51.200 | 102.400 | 128 | Futuro / não ativar sem evento |
| Crysalon | 400.000 | 300.000 | 4.450 | 51.200 | 409.600 | 128 | Futuro / não ativar sem evento |
| Crysalon Prime | 1.600.000 | 1.200.000 | 20.000 | 204.800 | 1.638.400 | 512 | Futuro / não ativar sem evento |
| Crysalon Apex | 3.200.000 | 2.400.000 | 40.000 | 490.000 | 3.276.800 | 1.024 | Futuro / não ativar sem evento |
| Reaver | 40.000 | 30.000 | 3.000 | 6.000 | 12.000 | 15 | Futuro / não ativar sem evento |
| Reaver Prime | 80.000 | 40.000 | 2.000 | 12.800 | 25.600 | 32 | Futuro / não ativar sem evento |
| Reaver Apex | 320.000 | 240.000 | 7.500 | 48.000 | 96.000 | 120 | Futuro / não ativar sem evento |
| Wardrone | 50.000 | 40.000 | 1.500 | 6.400 | 12.800 | 16 | Futuro / não ativar sem evento |
| Wardrone Apex | 400.000 | 320.000 | 12.000 | 51.200 | 102.400 | 128 | Futuro / não ativar sem evento |
| Nexus Core | 1.600.000 | 1.200.000 | 0 | 536.200 | 1.638.400 | 1.024 | Futuro / não ativar sem evento |
| Riftling II | 1.200.000 | 750.000 | None | None | 200.000 | 45 | Futuro / não ativar sem evento |
| Warden IX | 9.000.000 | 4.800.000 | None | None | 1.000.000 | 275 | Futuro / não ativar sem evento |
| Harbinger XVI | 36.000.000 | 0 | None | None | 9.500.000 | 2.000 | Futuro / não ativar sem evento |
| Pyre Behemoth | 135.000.000 | 0 | None | None | 200.000.000 | 5.000 | Futuro / não ativar sem evento |
| Starfall Barrage | 4.500.000 | 500.000 | None | None | 6.500.000 | 4.000 | Futuro / não ativar sem evento |
| Emperor Vrax | 9.600.000 | 6.800.000 | 45.000 | 768.000 | 2.000.000 | 9.214 | Futuro / não ativar sem evento |
| Emperor Crysalon | 14.080.000 | 10.560.000 | 60.000 | 1.536.000 | 5.000.000 | 36.864 | Futuro / não ativar sem evento |
| Emperor Colossar | 6.400.000 | 6.400.000 | 35.000 | 409.600 | 1.400.000 | 4.608 | Futuro / não ativar sem evento |


### 07.7 Mapas canônicos (14): navegação, portais e zonas


| Mapa | Tier | Risco | Dimensões | Minério | População conhecida | Portais declarados |
|---|---|---|---|---|---|---|
| Fronteira Inicial | 1 | Seguro | 7200×5400 | Ferron, Cryon | Scavenger × 10, Scavenger Scout × 6, Scavenger Support × 5 | x2 |
| Nebulosa Azul | 2 | Baixo | 7900×5800 | Ferron, Cryon, Virel | Scavenger × 7, Scavenger Scout × 5, Scavenger Support × 5, Scavenger Prime × 4, Vrax × 8, Vrax Prime × 2 | x1, x3, x4 |
| Cinturão Sombrio | 3 | Médio | 8650×6250 | Cryon, Virel | Vrax × 7, Zyron × 7, Zyron Prime × 2, Kharon × 6, Kharon Prime × 2, Dreadnox × 2, Dreadnox Prime × 1 | x2, x4 |
| Planícies de Fogo | 4 | Alto | 9400×6750 | Cryon, Virel | Vrax × 5, Zyron × 6, Zyron Prime × 4, Kharon × 6, Colossar × 3, Colossar Prime × 1 | x2, x3, battleHome |
| Véu da Fenda | 5 | Alto | 10100×7300 | Ferron, Cryon, Virel | Ember Fang × 10, Ember Fang Prime × 2, Iron Wasp × 8, Iron Wasp Prime × 2 | — |
| Desfiladeiro Vazio | 6 | Crítico | 10700×7800 | Ferron, Cryon, Virel | Rift Mauler × 8, Rift Mauler Prime × 2, Obsidian Pike × 7, Obsidian Pike Prime × 2 | — |
| Coração do Nexus | 7 | Extremo | 11300×8300 | Ferron, Cryon, Virel | Rift Mauler × 5, Obsidian Pike × 7, Obsidian Pike Prime × 3, Apex Overlord × 2 | — |
| Bastião Astral | 8 | Extremo | 12000×8900 | Ferron, Cryon, Virel | Sentinel Scavenger × 7, Sentinel Scout × 6, Sentinel Support × 5 | — |
| Deep Battle Alpha | 41 | Extremo | 11800×8400 | — | Batedor da Fenda × 8, Batedor da Fenda Prime × 2, Corsário do Vazio × 6 | x4HomeEarth, b42, b43 |
| Alien Core Beta | 42 | Extremo | 12500×8900 | — | Corsário do Vazio × 8, Corsário do Vazio Prime × 3, Guardião Nexus × 5 | x4HomeMars, b41, b43 |
| Abismo Vermelho | 43 | Extremo | 13500×9600 | — | Guardião Nexus × 8, Guardião Nexus Prime × 2, Ceifador Astral × 4, Guardião Nexus Prime × 1 | x4HomeJupiter, b41, b42 |
| Portal Astral Alpha | 90 | Portal | 11500×8500 | — | — | — |
| Portal Astral Beta | 94 | Portal Elite | 13200×9600 | — | — | — |
| Portal Astral Gamma | 99 | Portal Extremo | 14800×10800 | — | — | — |


---

## 08. MECÂNICAS DETALHADAS E BALANCEAMENTO

1. **Progressão:** XP por NPC/missão, níveis, loja progressiva, mapa de perigo crescente, dificuldade escalada e equipamentos por moeda/raridade. Todas as tabelas de dano/drops/preço são `gameData`, não números espalhados em handlers.
2. **Cálculo de dano:** laser base × munição × equipamentos × bônus PvE/skills, mitigado pelo escudo antes do HP conforme regras do jogo; MISSILE/ROCKET tem dano independente; demais módulos contribuem apenas se equipados na CONF ativa.
3. **Caixas e mineração:** cada nó possui `resourceId`, quantidade e `claimId`; coletar atualiza porão e desativa o nó transacionalmente; tela visual aparece instantânea; nenhum item pode exceder limite do porão.
4. **Refino:** receitas partem das famílias Ferron, Cryon, Virel e resultam em Ferrite, Duracite, Solarium e Voidite segundo tabela definida. Não inventar receitas econômicas como se fossem oficiais: quando faltarem nas fontes, usar `TODO_BALANCE` em dados locais editáveis.
5. **Loadout:** slots de armas/escudos/motores/extras dependem da nave; drone possui slots próprios; AUX possui slots/protocolos. Na CONF ativa, o inventário contém a contagem restante e os equipamentos alocados são contabilizados uma única vez.
6. **Raridades e eventos:** itens obtidos por eventos/superiores não ficam automaticamente disponíveis na loja comum; mostrar cadeado, origem de obtenção e tooltip de raridade.
7. **Combate/loots:** cada NPC possui `spawnId` e `killId`; morte, crédito e saque ocorrem uma vez. Reaparecimento com cooldown/temporada definido. Prime/elite e boss têm arte e ataque distintos, não apenas mudança de cor.
8. **Economia offline:** o jogador pode experimentar compras/vendas mesmo sem conexão. Marcar moedas e inventário como `sandbox` e apresentar mensagem transparente de que não são transferíveis para multiplayer sem revalidação.
9. **Administração:** filtros de item, buscas, duplicação de preset, reset de testes e simulador de balanceamento separados do menu do jogador.
10. **Efeito visual:** nunca gerar partículas em Canvas; usar spritesheets de impactos/faíscas, fades CSS e pools com limite configurável por perfil gráfico.

---

## 09. PLANO INTERNO DE EXECUÇÃO — NÃO ENTREGAR POR ETAPAS

| Prioridade interna | Implementação na mesma tarefa | Aceitação automatizada |
|---|---|---|
| **P0 — já** | Corrigir orientação frontal da nave, interpolação, snapping, joystick, câmera, sprites novos | Círculo, zig-zag, ré e parada: sem engasgos perceptíveis, sem mostrar traseira excessivamente |
| **P1** | Save IndexedDB único, operações, A/B/C, export/import, PWA offline, perfil | 100 gravações, 10 reinícios, um restore explícito, sem perda |
| **P2** | HUD, Hangar, naves/drone/AUX-9, CONF1/CONF2, designers, inventário | Troca 1↔2 sem item duplicado; status, stats e previews corretos |
| **P3** | Catálogo 177, mercado, economia sandbox, compra/venda, refinaria, craft e protocolos | Nenhuma compra repetida duplica saldo/item; menu rápido; nomes canônicos |
| **P4** | Mapas/portais, NPCs, IA PvE, armas, loot, missões, passe, XP e recompensas | Progressão persistente e derrota/recompensa idempotentes |
| **P5** | Autopilot, Farm Offline, vendas automáticas, eventos, chefes, boss, fragmentos | Sem bloqueio do loop visual, 8h offline simulado e virada de dia sem perda |
| **P6** | Arena contra bots, clãs sandbox, relés e Warfront offline | Simulação local honesta e jogável; nenhuma falsa alegação de multiplayer |
| **P7** | Polimento Android, gráficos Baixo/Médio/Alto, assets novos, testes, métricas | ≥30 FPS alvo no Alto em aparelho de referência, sem jank de HUD, menu ou save |
| **P8 — futuro** | Adapters Render/Supabase, economia online e PvP reais | Projetos sincronizam com recibos; cliente não pode inventar saldos/posses |

**Operação do Codex:** as prioridades P0→P7 são apenas **sequenciamento interno de programação**, não releases, não ZIPs por fase e não marcos para o usuário testar. Executar tudo sem interromper o trabalho, com testes internos e commits de segurança se úteis. Manter `CHANGELOG_OFFLINE.md` atualizado. **Entregar apenas no término**, em um ZIP completo ou em N ZIPs finais normais de até 24.000.000 bytes cada, na ordem do manifesto. A prioridade P8 permanece como *adaptador futuro*, sem conectar a servidores reais nesta versão offline.

---

## 10. TESTES DE ACEITAÇÃO OBRIGATÓRIOS

- [ ] GitHub Pages abre sem erro com assets cacheados; depois de um carregamento online, abre em modo avião.
- [ ] Nave toca 360° de movimento, mas **exibe frente/¾ frontal** e realiza curvas suaves; inverter direção não a faz girar para mostrar a traseira.
- [ ] Nave não sofre saltos em joystick a baixa velocidade ou com dedo tremendo; câmera sem jitter.
- [ ] FPS e P95/P99 medidos sem gravador; modos Baixo/Médio/Alto e com painel de missões, hangar, NPCs e Autopilot.
- [ ] Save íntegro após fechar/abrir Chrome e APK; IndexedDB único e checkpoint A/B/C testado.
- [ ] Equipar item em nave/drone/AUX e trocar CONF mantém inventário correto.
- [ ] Compra/venda e recursos/refinaria funcionam offline; saldo sandbox não duplica após reiniciar.
- [ ] NPC e loot não pagam duas vezes ao repetir evento/idempotency key.
- [ ] Missões, Passe, XP, níveis, recompensas e evento sobrevivem à virada do dia.
- [ ] Farm Offline após oito horas simuladas não perde progresso e não resgata duas vezes.
- [ ] Portais, arenas sandbox, Warfront sandbox e mapa tático têm transições sem carregamento pesado.
- [ ] Toda nave/arma/munição/recurso/NPC/mapa do catálogo possui `name`, `code`, icon/arte ou fallback original **com qualidade**, status de disponibilidade, categoria e atributos suficientes para uso.
- [ ] Nenhum conteúdo de jogo em Canvas 2D; não há `canvas.getContext('2d')`, `ctx.drawImage`, partículas procedurais ou linha de tiro desenhada em Canvas.
- [ ] README documenta estrutura, execução, build, exportação e migração futura; nenhum link/asset externo indisponível quebra o offline.
- [ ] O conjunto completo de ZIPs possui limite de **24.000.000 bytes por arquivo**, SHA-256, caminhos únicos, ordem explícita de instalação e reconstrução fiel em diretório vazio.
- [ ] Instalação de todas as partes na branch de staging reproduz o GitHub Pages final; PWA abre pelo caminho correto de subdiretório e não publica build parcial.
- [ ] Replay de navegação reproduz movimentos, exportação/importação do save verifica integridade, e pré-carregamento de sprites não bloqueia o loop principal.

---

## 11. ARQUIVOS RECOMENDADOS A PRODUZIR NA IMPLEMENTAÇÃO

```text
/public/
  index.html
  css/game.css, css/hangar.css, css/hud.css, css/animations.css
  js/core/game-loop.js, input.js, state.js, event-bus.js
  js/render/dom-scene.js, ship-sprite-controller.js, sprite-pool.js
  js/world/maps.js, portals.js, npc-ai.js, combat.js
  js/economy/wallet.js, shop.js, cargo.js, refinery.js, crafting.js
  js/hangar/ship.js, drone.js, aux9.js, conf-manager.js
  js/progression/missions.js, battle-pass.js, rewards.js
  js/automation/autopilot.js, farm-offline.js
  js/storage/indexeddb.js, save-store.js, checkpoints.js, outbox.js
  js/online/sync-adapter.js // vazio/desabilitado até fase online
  js/data/catalog.js, balance.js, aliases-legacy.js
  assets/ships/, assets/drones/, assets/aux/, assets/npcs/
  assets/maps/, assets/backgrounds/, assets/portals/, assets/effects/
  assets/ui/, assets/market/, assets/resources/
  manifest.webmanifest, sw.js
/tests/ movement.test.js, saves.test.js, economy.test.js, combat.test.js
/README.md, CHANGELOG_OFFLINE.md, TODO_OFFLINE.md
/MANIFEST_ENTREGA_FINAL.md, release-manifest.json, scripts/verify-release-parts.*
```

A estrutura é sugestão. **Respeitar a organização atual do repositório offline** e implementar componentes equivalentes sem mover arquivos funcionais sem necessidade. O código da versão online é uma referência de sistemas, não uma obrigação de copiar servidor, SQL, recursos legados ou dependências pesadas para o APK.

---

## 12. ENTREGA FINAL OBRIGATÓRIA DO CODEX — SEM TESTES DO USUÁRIO NO MEIO

**Um único trabalho completo:** receber este GDD, evoluir integralmente o jogo offline existente, integrar todos os sistemas obrigatórios, corrigir navegação/ângulo frontal da nave, criar novas artes e sprites de qualidade, testar, otimizar, montar e verificar o release. **Não entregar protótipos, links ou versões parciais para o usuário aprovar enquanto o trabalho estiver em execução.** Testes internos do Codex são permitidos e exigidos; o usuário fará testes manuais só após a entrega da versão final.

**Formato da entrega:**

- Se o release completo tiver **até 24.000.000 bytes**, entregar **1 ZIP final completo**.
- Caso ultrapasse, entregar **N ZIPs finais de até 24.000.000 bytes por parte**, todos arquivos `.zip` normais compatíveis com importação por vez, numerados `PARTE_01_DE_NN` etc., sem caminhos repetidos; pode usar dez ou mais partes se necessário.
- O conteúdo agregado precisa conter **o projeto completo pronto para GitHub Pages**, incluindo código, sprites/efeitos novos, dados canônicos, saves, Service Worker, PWA, workflow, scripts e testes. Não entregar apenas diffs nem exigir que o usuário reconstrua assets manualmente.
- Criar manifesto com ordem, lista de arquivos, SHA-256 e tamanho de todas as partes. **Recompor e testar a união das partes antes de fornecer links.** Preferir montagem em branch de staging, seguida de um único merge/commit final para evitar deploy parcial no GitHub Pages.
- Apresentar ao final: todos os ZIPs, README de instalação, versão do release, principais funcionalidades, checklist de testes realizados, resultados que foram realmente medidos, itens indisponíveis que dependam de serviços externos e como rodar a página offline/PWA.

**Critério máximo:** a nave obedece ao jogador com movimento fluido, sempre valorizando a frente; o combate e o hangar têm artes realmente boas; o jogo funciona offline; os sistemas e nomes oficiais estão preservados; nenhuma operação local depende de servidor para responder na interface. **O limite por ZIP nunca é negociável: manter margem e não ultrapassar 25 MB.**

**Nota de procedência:** 177 entradas confirmadas no catálogo estático; a lista é completa para aquele arquivo `public/data.js`, mas não é uma extração de todas as configurações dinâmicas históricas de SQL. Conteúdos futuros, regras de live-ops e preços administráveis exigem reconciliação quando o projeto online for conectado. Os números no catálogo são base de referência, não garantia de balanceamento homologado.
