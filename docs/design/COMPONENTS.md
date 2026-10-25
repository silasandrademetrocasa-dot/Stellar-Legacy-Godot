# Componentes do Design System — revisão da Etapa 01

A fundação visual anterior foi aprovada; estes componentes adicionais são uma
entrega para revisão. Não alteram paleta/fontes aprovadas nem telas da partida.

## Abas — `galactic_tabs.gd`

`set_tabs(records, preferred)` recebe registros com `id`, `label` e `enabled`.
IDs vazios/duplicados ou registros inválidos são rejeitados sem substituir as
abas atuais. `select_tab(id)` retorna sucesso apenas para aba disponível. A aba
ativa permanece pressionada e tem variante visual própria. A seleção usa IDs,
não a posição de um item que possa mudar.

Sinal `tab_changed(id)`. Teclas esquerda/direita percorrem e dão volta nas abas
disponíveis; Home/End vão aos extremos; abas indisponíveis são ignoradas. Tab e
ativação por botão seguem o comportamento nativo do Godot. O layout quebra linhas
quando necessário, mantendo 48 unidades lógicas de altura mínima.

## Lista — `galactic_item_list.gd`

`set_items(records)` recebe `id`, `title`, `detail` e `enabled`. Atualizações com
IDs vazios/duplicados ou registros não dicionários são rejeitadas atomicamente.
Os dados e a seleção retornada são cópias; o componente não altera o catálogo.

`set_filter(text)` compara título/descrição sem distinguir caixa e remove espaços
externos da consulta. Busca não promete normalização de diacríticos. O contador
mostra registros visíveis/total e há mensagem explícita de resultado vazio.

`select_item(id)` só seleciona registro visível e disponível. Sinal
`selection_changed(id)`; `get_selected_item()` retorna cópia do registro atual.
Filtrar não perde a seleção por ID: ao limpar a busca, o destaque retorna. Trocar
o conjunto limpa uma seleção que deixou de existir. A lista usa botões nativos,
foco e rolagem, sem carregar modelos HQ ou interpretar posse/equipamento do jogador.

O componente foi exercitado com a frota de 13 registros e amostras de sistemas.
Não implementa virtualização para catálogos grandes; isso precisa de orçamento e
medição no uso futuro. Textos longos podem ser cortados na linha; o tooltip retém
a descrição. A lista da prévia é demonstração, não inventário real.

## Campo — `galactic_text_field.gd`

Campo reutilizável com rótulo, LineEdit, botão e mensagem textual. `validate_value`
é puro: remove espaços externos e valida os limites configurados, preservando
acentos e espaços internos. A prévia usa 3 a 24 caracteres; isso não altera regras
existentes de perfil, clã ou servidor. Entrada limitada a 256 caracteres na UI.

`submit()` e Enter/IME usam a mesma validação. Apenas valores válidos emitem
`value_submitted(value)`. Editar após um erro atualiza o feedback sem confirmar
nem emitir uma submissão. Campo desabilitado não confirma, inclusive por chamada
programática. `set_value` e `set_editable` permitem uso pelo controlador futuro.

Estados: neutro, erro, pronto para confirmar, confirmado e indisponível. Erro e
confirmação têm texto explícito além da cor; foco continua visível em âmbar.
Em largura compacta, entrada e botão ficam empilhados. Nenhum valor é salvo pelo
componente: persistência depende de um controlador que ainda não foi conectado.

## Galeria e limites

A prévia mantém **IDENTIDADE** separada de **COMPONENTES**. A frota listada vem do
catálogo existente, apenas como registros de texto; selecionar não equipa ou compra.
O formulário confirma somente em memória. Nenhum sinal é ligado ao perfil,
carteira, inventário ou serviços de rede. As transições de abas são instantâneas;
as preferências de movimento/fundo da fundação continuam funcionando.

Testes de teclado, ponteiro, estados, cópias de dados, substituição de conjuntos,
validação e viewports foram executados. IME é simulado por evento/sinal de entrada;
não houve teste físico de teclado virtual, gestos, áreas seguras ou FPS Android.
Capturas reais em `components-previews/`. Validação completa em
`../audit/components-validation-results.json`.
