# Atualização Codex — duas partes menores que 25 MB

Base conferida no GitHub: `ed7158b792cb021b7f56955e244c4bd105a517a4`,
repositório `silasandrademetrocasa-dot/Stellar-Legacy-Godot`.

Use o workflow existente **Stellar Legacy Godot - Instalador ZIP**. Os pacotes
são incrementais para essa base, não projetos completos e não arquivos partidos
que precisam ser juntados. Cada ZIP é extraído e validado pelo instalador.

## Ordem obrigatória no celular

1. Deixe a raiz do repositório sem outro ZIP de atualização.
2. Envie **StellarLegacy_Codex_PARTE_1_ASSETS.zip** à raiz, sem extrair.
3. Abra **Actions → Stellar Legacy Godot - Instalador ZIP → Run workflow**.
4. Aguarde o workflow concluir em verde e publicar a Parte 1. O instalador remove
   o ZIP usado. Se um ZIP antigo ainda aparecer na raiz, remova-o antes da Parte 2.
5. Envie **StellarLegacy_Codex_PARTE_2_CORRECOES.zip** à raiz, sem extrair.
6. Execute o mesmo workflow e aguarde o resultado verde.
7. Depois das duas partes, baixe o projeto atualizado do GitHub e abra
   `project.godot` no Godot 4.5.2 Android, renderizador Compatibility.

**Suba apenas um ZIP por vez.** Se uma etapa falhar, não avance para a próxima:
registre o erro do workflow. A Parte 2 depende dos assets instalados na Parte 1.

## Conteúdo

- **Parte 1 — ASSETS**: oito armas HQ recuperadas do pacote local, texturas,
  miniaturas e configurações de importação. Não muda o controlador nessa etapa.
- **Parte 2 — CORREÇÕES**: Aurora e frota, escala/pivôs, movimentação/mira,
  propulsores, relés HQ/LOD, efeitos, otimizações, testes e relatórios.
- Os 13 GLBs de nave e os demais assets existentes não são substituídos.
- Nenhum arquivo é apagado pelo pacote. Os scripts corrigidos ficam versionados
  pelo commit que o próprio workflow faz no GitHub.
- Não há arquivos `.github/` nos ZIPs: o instalador proíbe esse caminho. O workflow
  novo de CI de PR preparado no workspace não faz parte desta instalação e não
  é necessário para o instalador existente funcionar.

A instalação pelo workflow grava em `main` quando você o executa, conforme o fluxo
que você solicitou. O Codex não publica nem faz merge diretamente no GitHub.

## Integridade e validação

Cada parte tem menos de **25.000.000 bytes**, no máximo 2.000 entradas e menos de
200 MiB descompactados. Prefixo interno compatível: `StellarLegacy-Godot/`.
Os arquivos de acompanhamento `MANIFESTO_INSTALACAO.json` e `SHA256SUMS.txt`
registram ordem, tamanhos, caminhos e hashes; não precisam ser enviados ao instalador.

A validação da entrega reproduz o extrator real do workflow em um checkout limpo:
Parte 1, importação Godot; Parte 2, nova importação e suíte headless. Evidências
finais acompanham os ZIPs no arquivo `VALIDACAO_DAS_PARTES.txt`.

Não envie o ZIP completo de 181 MB nem o bundle Git ao instalador. Use somente
as duas partes desta entrega.


## Resultado executado da instalação sequencial

- Parte 1: extrator original aceitou o ZIP; importação limpa Godot 4.5.2 passou.
- Parte 2: extrator original aceitou o ZIP; os 45 comandos da suíte headless
  passaram, incluindo 16.921 verificações de regressão. Sem erros finais.
- CRC dos dois arquivos, limite de 25 MB e hashes de todo o conteúdo conferidos.
- Teste local no Codex Cloud, sem disparar o workflow no GitHub e sem testar FPS
  em aparelho Android. Resultado por comando: `zip-validation-results.json`.
