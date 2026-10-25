# Fundação do Design System galáctico — proposta da Etapa 01

Estado: **EM DESENVOLVIMENTO**. Paleta, tipografia e emblema abaixo são uma proposta
para revisão do proprietário. Não substituem uma identidade aprovada nem tornam
a Etapa 01 concluída por si só.

## Direção visual proposta

Metal profundo e luz de navegação, com órbitas interrompidas e pequenos pontos de
registro. As formas usam uma referência orbital comum em vez de aplicar efeitos
pesados a cada controle. O emblema vetorial é uma proposta original de nave/legado
sobre órbitas; não é uma reconstrução das artes 3D aprovadas.

| Token | Cor | Uso |
|---|---|---|
| VOID | `#040811` | Fundo principal e texto no botão primário |
| PANEL | `#0B1729` | Superfície opaca de leitura |
| PANEL_RAISED | `#11223A` | Controles/superfícies elevadas |
| ION | `#33DCED` | Navegação, ação principal e energia de escudo |
| AMBER | `#FFCB76` | Atenção e contorno de foco |
| ASTRAL / VIOLET | `#B8A2FF` | Descoberta e energia profunda |
| TEXT | `#E8F1FF` | Texto principal |
| MUTED | `#A0B4D0` | Texto secundário legível |
| DANGER | `#FF8990` | Estado de alerta com rótulo textual |
| BORDER | `#304965` | Estrutura secundária |

A identidade usa Oxanium em títulos/legendas, peso variável 600, e Rajdhani Medium
no texto e nos controles. Ambas são distribuídas localmente sob SIL Open Font
License 1.1, com arquivos de licença e hashes. Não depende de conexão de rede.

## Componentes implementados

- `GalacticTitle` e `GalacticCaption`: hierarquia tipográfica reutilizável.
- `GalacticPanel`: painel com registro orbital/cantos e acento sem partículas.
- `GalacticPrimaryButton`, `GalacticSecondaryButton`, `GalacticAlertButton`:
  normal, hover, pressionado, desabilitado e foco independente visível.
- Indicador de progresso/escudo e controles de redução de movimento.
- Alvos de botão com altura mínima de 48 unidades lógicas; escala física ainda
  precisa de revisão no Android. Estado não depende apenas de cor.
- Fundo holográfico em um passe `canvas_item`, sem leitura da tela, luzes ou
  texturas de ruído. BAIXO usa fundo sólido; movimento reduzido congela animação
  do shader e remove a transição de entrada da prévia.
- Tema em `scripts/ui/design/galactic_theme.gd`; geometrias 2D nos componentes e
  `shaders/galactic_hologram.gdshader`. Nenhum tema global foi imposto à partida.

## Como revisar no celular

Após instalar o ZIP, execute o jogo e abra **CONFIG → DESIGN SYSTEM — PRÉVIA DA
ETAPA 01**. Compare as cores, fontes, botões e indicador, role a tela e ative
**REDUZIR MOVIMENTO**. **VOLTAR** retorna à configuração existente. Em BAIXO,
o fundo é sólido. A opção de movimento vale apenas para esta prévia.

Também é possível executar `scenes/ui/design_system_preview.tscn` diretamente no
editor. A cena tem suporte de layout para paisagem e retrato na revisão; isso não
muda a orientação configurada do jogo. Capturas em `previews/` são renderizações
da própria UI, não mockups de uma funcionalidade supostamente pronta.

## Critérios e próxima tarefa

Fundação: fontes locais/licenciadas, componentes reutilizáveis, estados/foco,
contraste em painel opaco, movimento reduzido, fallback de qualidade e abertura/
fechamento sem alterar dados do jogador. 305 verificações automatizadas da prévia passaram; a renderização Compatibility
real também passou. Evidências em `../audit/foundation-validation-results.json`. Contraste medido em cores opacas não garante
legibilidade sobre qualquer cena futura nem substitui revisão visual.

Próxima tarefa disponível: componentes de abas, listas, campos de entrada e
mensagens de validação no mesmo protótipo. Após revisar a identidade e completar
o conjunto, aplicar às telas da Etapa 02 em alterações separadas, preservando os
fluxos existentes. Aprovação visual e testes físicos Android permanecem pendentes.
