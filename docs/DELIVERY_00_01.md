# Entrega — Etapa 00 e fundação da Etapa 01

## Escopo para revisão

O planejamento foi reorganizado nas etapas oficiais 00 a 11. O arquivo
`docs/PLANO_MIGRACAO.md` aponta para `docs/ROADMAP.md`, e `docs/PROJECT_STATUS.md`
registra os estados permitidos, evidências, impedimentos e próxima tarefa.
Não foi encontrado um planejamento antigo com duração por calendário nos arquivos
disponíveis; a ordem antiga de migração foi substituída pela estrutura oficial.
Os registros históricos de teste/importação permanecem como evidência técnica.

A Etapa 00 consolida inventário de 147 GLBs com hashes, mapa de sistemas, versão
real declarada/executada e validação reproduzível. A Etapa 01 recebe tema e tokens,
fontes locais/licenciadas, painéis/emblema orbitais, controles com foco/estados,
shader Compatibility e redução de movimento. É uma proposta visual revisável,
sem reconstrução do HUD ou substituição das artes/modelos atuais.

## Arquivos e recursos principais

- `docs/ROADMAP.md`, `PROJECT_STATUS.md`, `PLANO_MIGRACAO.md`, `ARCHITECTURE.md`.
- `docs/audit/asset-inventory.json`, `foundation-validation-results.json`.
- `scripts/ui/design/galactic_theme.gd`, `galactic_panel.gd`, `galactic_emblem.gd`,
  `design_preview.gd`; `scenes/ui/design_system_preview.tscn`.
- `scripts/ui/stellar_hud.gd`: apenas acesso à prévia a partir de CONFIG e descarte
  ao fechar; sem substituição do tema global nem mudança de dados do jogador.
- `assets/ui/design/fonts/`: Oxanium, Rajdhani e licenças SIL OFL 1.1.
- `shaders/galactic_hologram.gdshader`; `docs/design/FOUNDATION.md`,
  `font-sources.json` e capturas em `previews/`.
- `tests/test_design_system.gd`, extensão do teste de renderização, verificador do
  plano, runner atualizado e opção de ZIP único no empacotador existente.

## Instalar pelo celular

**Arquivo:** `StellarLegacy_ETAPAS_00_01_ATUALIZACAO.zip`.
Base conferida: `0c861a72152e2bf1b1bb45d55f893314b3582d60`. As duas partes anteriores
já estão instaladas nessa base. Este ZIP traz somente a nova revisão e preserva
as correções anteriores.

1. Deixe a raiz do repositório sem outro ZIP de atualização.
2. Envie este único ZIP à raiz, sem extrair.
3. Execute **Actions → Stellar Legacy Godot - Instalador ZIP → Run workflow**.
4. Aguarde concluir em verde. O instalador extrai, valida e publica o commit no
   repositório pelo fluxo que você controla; o Codex não faz push ou merge.
5. Baixe o projeto atualizado e importe `project.godot` no **Godot 4.5.2 Android**,
   Compatibility. Execute a cena principal e abra **CONFIG → DESIGN SYSTEM**.
6. Role a prévia, teste botões, indicador, redução de movimento e **VOLTAR**.
   Compare BAIXO (fundo sólido) e os demais perfis; teste também o jogo/Hangar
   existentes para confirmar que o fluxo anterior permanece disponível.

O pacote fica abaixo de 25.000.000 bytes e usa o prefixo aceito
`StellarLegacy-Godot/`. Nenhum caminho `.github/` é incluído, como exige o seu
instalador. O workflow adicional de PR não é necessário nesta entrega.

## Testes realmente executados

Godot 4.5.2, com saves de teste isolados. **53 comandos**, todos passaram:
auditoria de assets, contrato do plano, importação, parsing, inicialização da cena
principal/demo dos relés, seis suítes e renderização Compatibility em Linux/Mesa.
**17.226 verificações** de regressão, sendo 305 específicas do Design System.
A prévia foi verificada em 960×540, 640×360, 360×740 e 1280×720; a renderização real
cobre três tamanhos, controles e fundo simples, além dos sete cenários anteriores.
Sem erros finais de script/shader. O driver de teste emite um aviso sobre V-Sync.

Os 1.354 arquivos de assets já instalados permanecem byte a byte iguais. Nenhum
modelo, cena, script ou recurso aprovado foi apagado. A integridade do ZIP e a
extração pelo instalador são verificadas antes da entrega; o registro de transporte
acompanha o download. A instalação sobre checkout limpo da base passou pelo
extrator original e pelos 52 comandos da suíte headless. Resultados por comando
em `audit/foundation-validation-results.json` e `audit/foundation-install-results.json`.

## Estados, pendências e próxima tarefa

- **00: AGUARDANDO APROVAÇÃO** — escopo técnico concluído, documentação/evidências
  disponíveis; só o proprietário pode aprovar.
- **01: EM DESENVOLVIMENTO** — fundação pronta para revisão; paleta, tipografia e
  emblema ainda são propostas, e o conjunto de componentes será ampliado.
- **02 a 11: PENDENTE** no plano oficial; sistemas e correções já existentes estão
  registrados como base técnica, sem aprovação de etapa presumida.

Próxima tarefa disponível: componentes de abas/listas/campos e mensagens de
validação no protótipo da 01. A reconstrução das telas da 02 depende da identidade
validada. Não foram criados modelos GLB/Blender ou artes substitutas nesta entrega.

Permanecem pendentes comparação artística V3, uso físico em Android, FPS/memória/
temperatura em aparelho e export/assinatura APK. Os tempos de transição e shaders
não são metas de planejamento. Não houve alteração de produção, bancos, servidores
ou serviços financeiros. A prévia não altera economia, inventário nem saves.
