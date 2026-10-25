# Fundação do Design System galáctico — Etapa 01

A direção visual da fundação foi **aprovada pelo proprietário**, conforme
`../APPROVALS.md`. Paleta, fontes e motivo orbital abaixo são a referência aceita
para a continuidade. Os componentes adicionais desta revisão estão em
**AGUARDANDO APROVAÇÃO**; isso não aprova automaticamente toda a etapa.

## Direção visual aprovada

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

## Componentes adicionais e continuidade

Abas, listas e campos de entrada foram acrescentados sem substituir a direção
aprovada. Contratos e limites: [COMPONENTS.md](COMPONENTS.md). Na prévia, use
**IDENTIDADE** para a fundação aprovada e **COMPONENTES** para os controles novos.
O registro de teste inicial (305 verificações) permanece como histórico; a suíte
atual da UI contém 545 verificações e a validação completa passou em 56 comandos.

Contraste em cores opacas não garante legibilidade sobre qualquer cenário futuro.
A revisão física em Android e a aprovação dos controles novos continuam pendentes.
Após a revisão do conjunto, a próxima aplicação será planejada na Etapa 02,
preservando o funcionamento do HUD, menus e Hangar até suas entregas específicas.
