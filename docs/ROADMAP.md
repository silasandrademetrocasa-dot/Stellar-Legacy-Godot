# Stellar Legacy — plano mestre oficial

O desenvolvimento é organizado nas etapas **00 a 11**, sem duração predeterminada.
O avanço depende de conclusão técnica, qualidade visual, estabilidade, testes e
aprovação do proprietário. O estado oficial de cada etapa fica em
[PROJECT_STATUS.md](PROJECT_STATUS.md). Este documento substitui a ordem antiga
presente no plano de migração.

## Processo de execução e aprovação

1. Registrar objetivo, entregas, dependências, riscos e critérios antes da mudança.
2. Implementar em branch de desenvolvimento com commits pequenos e reversíveis.
3. Preservar recursos e sistemas aprovados; novas versões de arte ficam separadas.
4. Executar os testes pertinentes e registrar resultados reais e limitações.
5. Entregar para revisão. Somente o proprietário pode marcar **APROVADO**.
6. Ao concluir tecnicamente uma etapa, registrar evidências e a próxima tarefa
   disponível. A aprovação visual não é inferida da passagem de testes.

Etapas independentes podem avançar em paralelo, em arquivos/recursos isolados,
respeitando as dependências. Não há merge automático na principal. Neste ambiente,
a entrega ocorre por ZIP de até 25 MB para o proprietário instalar pelo workflow;
uma descrição de revisão acompanha a entrega quando não houver publicação de PR.

## ETAPA 00 — Auditoria e segurança

- **Objetivo:** estabelecer a situação real do cliente e um ambiente reproduzível.
- **Entregas:** versão declarada/executada, mapa de sistemas, inventário com hashes,
  relatório por gravidade, testes isolados e processo de entrega documentado.
- **Conclusão:** importação, scripts e cenas verificados; originais preservados;
  pendências e limites de teste registrados; revisão do proprietário.
- **Dependências:** acesso de leitura ao repositório e arquivos disponíveis.

## ETAPA 01 — Design System galáctico

- **Objetivo:** criar uma identidade exclusiva e uma linguagem visual reutilizável.
- **Entregas:** proposta de paleta e tipografia, tokens, temas, painéis holográficos,
  botões/estados, navegação de foco, shaders e transições com movimento reduzido.
- **Conclusão:** componentes legíveis e consistentes, prévia responsiva testada,
  licenças/fontes locais, orçamento de efeitos definido e identidade aprovada.
- **Dependências:** inventário e restrições de renderização identificados em 00.

## ETAPA 02 — UI principal e Hangar

- **Objetivo:** reconstruir HUD, entrada no jogo e navegação com usabilidade Android.
- **Entregas:** menu principal, facções, HUD, Hangar 3D, mapa galáctico e fluxos de
  navegação aplicando os componentes da identidade aprovada.
- **Conclusão:** fluxos completos e acessíveis por toque/teclado, layouts suportados
  verificados, modelos bem enquadrados, sem regressão de navegação e aprovação visual.
- **Dependências:** 01; interface com modelos/contratos de apresentação de 04/05.

## ETAPA 03 — Menus e sistemas

- **Objetivo:** oferecer interfaces consistentes para as funcionalidades existentes.
- **Entregas:** inventário, equipamentos, Loja Estelar, perfil, clãs, missões,
  configurações e demais menus, mantendo seus contratos de dados.
- **Conclusão:** posse/bloqueios, slots, configurações e saves preservados; fluxos
  testados, texto claro e aprovação de usabilidade.
- **Dependências:** 01/02; contratos de progressão/economia revisados junto a 08.

## ETAPA 04 — Frota 3D

- **Objetivo:** alcançar fidelidade máxima às referências aprovadas das 13 naves.
- **Entregas:** Aurora, Pioneer, Raptor, Meridian, Bastion, Lynx, Phantom, Pathfinder,
  Kensei, Valkyrie, Leviathan, Seraph e Bulwark; geometria real, proporções, cockpit,
  asas, pintura, materiais PBR, texturas, motores, orientação, montagem e LODs.
- **Conclusão:** comparação por nave com referências identificadas, validação do
  proprietário, orientação/movimentação e importação testadas; originais mantidos.
- **Dependências:** 00 e referências de arte aprovadas; integração com 05/06/09.

## ETAPA 05 — Biblioteca de modelos 3D

- **Objetivo:** organizar e refinar os recursos além da frota.
- **Entregas:** NPCs, drones, AUX-9, portais, escudos, motores, armas, munições,
  mísseis, relés, minérios, boxes e extras; GLB/Blender, PBR, texturas, scripts de
  geração e metadados de pivôs/montagem, preservando HQ e LOD existentes.
- **Conclusão:** catálogo e procedência completos, caminhos/materiais válidos,
  montagem testada, variantes novas separadas e validação das artes alteradas.
- **Dependências:** 00; referências e uso por 04/06/07/09.

## ETAPA 06 — Combate e animações

- **Objetivo:** tornar movimento e combate claros, responsivos e estáveis.
- **Entregas:** movimento, ataques, disparos, escudos, impactos, explosões, animações,
  partículas, IA dos NPCs e feedback visual/sonoro onde houver recursos disponíveis.
- **Conclusão:** mira/viagem independentes preservadas quando previstas no design,
  dano e estados coerentes, efeitos limitados e regressão dos sistemas existentes.
- **Dependências:** contratos de 03 e modelos de 04/05; testes contínuos de 10.

## ETAPA 07 — Relés, portais e ambientes

- **Objetivo:** desenvolver a identidade mecânica e ambiental dos setores.
- **Entregas:** três níveis de relé; repouso, combate, escudo quebrado e evolução;
  portais com núcleo/anéis/pulsação e ambientes por setor.
- **Conclusão:** estados/transições, mudança de mapa, qualidade/LOD e orçamento de
  efeitos validados; captura e navegação preservadas; aprovação visual.
- **Dependências:** 05/06; integração com 02/09.

## ETAPA 08 — Progressão e economia

- **Objetivo:** revisar a coerência dos sistemas existentes da demonstração local.
- **Entregas:** progressão, recompensas, inventário, missões, equipamentos e economia
  demonstrativa documentados e integrados aos menus.
- **Conclusão:** invariantes e migrações de save testadas; nenhuma perda de itens,
  concessão indevida ou alteração de produção; regras revisadas pelo proprietário.
- **Dependências:** 03/06 e contratos de dados auditados em 00.

## ETAPA 09 — Otimização Android

- **Objetivo:** adequar o jogo aos dispositivos que vierem a ser suportados.
- **Entregas:** orçamento de geometria/draw calls/memória, LODs, texturas, shaders,
  partículas, carga/descarga e perfis gráficos por capacidade.
- **Conclusão:** comparação reproduzível de cenários, testes em aparelhos
  identificados, qualidade preservada e limitações registradas. Desktop não
  comprova FPS Android.
- **Dependências:** cenários representativos de 02 a 08; pode atuar a cada entrega.

## ETAPA 10 — Qualidade e testes

- **Objetivo:** verificar o conjunto e impedir regressões ao longo do projeto.
- **Entregas:** importação, parsing, cenas, movimento, combate, UI, integridade de
  assets, saves, instalação sequencial e matriz de testes por plataforma.
- **Conclusão:** riscos da versão cobertos por testes pertinentes, falhas tratadas,
  itens não executados explícitos e evidências reproduzíveis para aprovação.
- **Dependências:** acompanha todas as etapas; fechamento sobre 09 e escopo integrado.

## ETAPA 11 — Polimento e versão candidata

- **Objetivo:** preparar uma candidata revisável para aprovação do proprietário.
- **Entregas:** correções finais, consistência visual, revisão de desempenho,
  checklist de candidata, pacote e instruções de teste.
- **Conclusão:** escopo definido aceito, regressões executadas, pendências/riscos
  de lançamento explícitos e aprovação final. Sem publicação automática.
- **Dependências:** entregas aceitas de 00 a 10.

## Limites permanentes

Criação/edição de GLB, Blender, PBR, texturas e geradores é autorizada nas branches
de desenvolvimento. Isso não autoriza substituir artes aprovadas sem validação.
Serviços de produção, servidores, bancos e serviços financeiros exigem autorização
específica; este plano não a concede. Não inventar arquivos recebidos, testes,
funcionalidades ou resultados. A documentação acompanha cada entrega.
