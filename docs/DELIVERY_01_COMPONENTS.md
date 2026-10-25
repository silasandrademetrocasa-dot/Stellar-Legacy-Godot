# Entrega — componentes adicionais da Etapa 01

## Aprovação e escopo

O proprietário respondeu **“Aprovado pode continuar”** à entrega da Etapa 00 e da
fundação 01. Essa aprovação foi registrada em `APPROVALS.md`; a 00 está APROVADO
e a direção visual da fundação permanece preservada.

Esta revisão acrescenta abas reutilizáveis, lista com busca/seleção/estado vazio,
registros indisponíveis e campo com validação e confirmação apenas em memória.
A prévia tem IDENTIDADE e COMPONENTES. A etapa completa fica AGUARDANDO APROVAÇÃO
desses controles; o jogo/HUD/Hangar ainda usam seus fluxos anteriores.

## Arquivos principais

`scripts/ui/design/{galactic_tabs,galactic_item_list,galactic_text_field}.gd`,
variantes adicionais em `galactic_theme.gd`, galeria em `design_preview.gd`, testes
atualizados, documentação/estado/aprovação e capturas em `design/components-previews/`.
Não há novos GLBs nem mudança de materiais/texturas, atributos ou economia.

## Instalar no celular

Base instalada conferida: `d84f5f355c4278a4a310e31c07fd3e4b0a98274c`, contendo a
fundação da entrega anterior. Pacote: `StellarLegacy_ETAPA_01_COMPONENTES_ATUALIZACAO.zip`.

1. Deixe a raiz do GitHub sem outro ZIP de atualização.
2. Suba este único ZIP, sem extrair, e execute o workflow habitual
   **Stellar Legacy Godot - Instalador ZIP**.
3. Aguarde verde, baixe o projeto atualizado e abra no Godot 4.5.2 Android,
   Compatibility. O Codex não publica ou faz merge diretamente.
4. Abra **CONFIG → DESIGN SYSTEM → COMPONENTES**. Compare abas, busca, seleção e
   estados indisponíveis. Na frota, filtre RAPTOR e limpe a busca após selecionar.
5. No formulário, confirme vazio para ver o erro; digite um identificador com
   acentos, confirme e verifique o estado de sucesso. Use VOLTAR e confira que o
   jogo e a configuração existente continuam disponíveis.

O ZIP respeita o limite de 25 MB, o prefixo do instalador e a proibição de `.github/`.
Nenhum modelo/recurso aprovado é removido. Os dados do formulário e seleção são
exemplos da prévia e não devem aparecer como alterações de perfil/posse no jogo.

## Evidências e limites

Godot 4.5.2: **56 comandos de validação**, **17.466 verificações**, incluindo **545**
da UI. Todos passaram na rodada final. O renderizador Compatibility real em
Linux/Mesa renderizou sete cenários anteriores de jogo e doze da galeria, sem erros
de script/shader; o aviso de V-Sync do driver é uma limitação do ambiente de teste.

Os testes cobrem navegação por teclado/ponteiro, busca, IDs inválidos/duplicados,
cópias e seleção persistente, desabilitados, validação com Unicode, trocas de dados,
reabertura e preservação de saves, saldo e equipamentos. Viewports: 960×540,
640×360, 360×740 e 1280×720. O pacote também é conferido em checkout limpo com o
extrator original: **55 comandos headless passaram no checkout instalado**.
Os 1.360 arquivos de assets da base permanecem byte a byte iguais. Logs em
`audit/components-validation-results.json` e `audit/components-install-results.json`.

Não houve teste físico Android, FPS, memória de GPU ou teclado virtual em aparelho.
Não houve alteração de produção, serviços financeiros, bancos ou servidores.
Regressões intermediárias de tipagem de arrays na API dos componentes foram
corrigidas; a rodada final não apresentou essas falhas.

## Próxima tarefa

Após a revisão dos controles adicionais da 01, planejar a aplicação na Etapa 02,
começando por navegação/menu principal e HUD, com preservação de fluxos e assets.
A aprovação da fundação não é uma aprovação automática de outras etapas.
