# Stellar Legacy — acompanhamento oficial

Plano de referência: [ROADMAP.md](ROADMAP.md). A evolução segue critérios técnicos
e aprovação, sem duração predeterminada. O estado não é um percentual de esforço
nem uma declaração de que o sistema correspondente não existe no cliente atual.

Estados permitidos: **PENDENTE**, **EM DESENVOLVIMENTO**, **PRONTO PARA TESTES**,
**AGUARDANDO APROVAÇÃO**, **APROVADO**, **BLOQUEADO**.

| Etapa | Nome | Estado | Evidência / próximo marco |
|---|---|---|---|
| 00 | Auditoria e segurança | AGUARDANDO APROVAÇÃO | Auditoria, inventário, mapa de sistemas e 53 comandos de validação concluídos; revisão do proprietário pendente. |
| 01 | Design System galáctico | EM DESENVOLVIMENTO | Fundação implementada, 305 verificações e renderização da prévia passaram; identidade e conjunto completo de componentes ainda em desenvolvimento. |
| 02 | UI principal e Hangar | PENDENTE | HUD/Hangar atuais preservados; reconstrução depende da identidade aprovada. |
| 03 | Menus e sistemas | PENDENTE | Menus locais existentes; aplicar design e revisar fluxos sem perda de funcionalidades. |
| 04 | Frota 3D | PENDENTE | 13 modelos existentes com orientação/escala testadas; fidelidade artística e LOD por nave ainda exigem revisão. |
| 05 | Biblioteca de modelos 3D | PENDENTE | 147 GLBs inventariados; refino e novas versões separados dos originais. |
| 06 | Combate e animações | PENDENTE | Combate/strafe/FX atuais testados; expansão segue contratos e critérios oficiais. |
| 07 | Relés, portais e ambientes | PENDENTE | Relés HQ/LOD e portais animados existentes; ampliar ambientes sem regressão. |
| 08 | Progressão e economia | PENDENTE | Sistemas demonstrativos locais preservados; produção fora do escopo autorizado. |
| 09 | Otimização Android | PENDENTE | Melhorias anteriores preservadas; perfis e medição em aparelho ainda pendentes. |
| 10 | Qualidade e testes | PENDENTE | Suíte de regressão existente em uso contínuo; fechamento integrado ainda pendente. |
| 11 | Polimento e versão candidata | PENDENTE | Depende do escopo aceito nas etapas anteriores. |

## Entrega atual

Branch local: `codex/master-plan-design-system`. Base instalada lida do GitHub:
`0c861a72152e2bf1b1bb45d55f893314b3582d60`. As duas partes da entrega anterior
estão instaladas, com código/assets coincidentes. Nenhuma aprovação visual ou de
etapa foi presumida desse fato. Não houve escrita direta do Codex na principal.

Entregas desta revisão: roadmap oficial, plano de migração atualizado, inventário,
mapa técnico, fundação visual e prévia acessível por CONFIG → DESIGN SYSTEM.
Resultado: 53 comandos de validação, 17.226 verificações de regressão e renderização
Compatibility real sem erros. Os 1.354 arquivos de assets instalados foram
comparados por hash e preservados. Evidências em `audit/foundation-validation-results.json`
e `design/previews/`. Testes Android físicos não foram executados.

O pacote é incremental sobre a base instalada, em um único ZIP menor que 25 MB,
para o workflow existente. Instruções e escopo: [DELIVERY_00_01.md](DELIVERY_00_01.md).

## Impedimentos e decisões abertas

- **Referências V3:** originais/hashes e artes aprovadas por nave ainda precisam de
  confirmação para certificar fidelidade; os 13 GLBs atuais estão preservados.
- **Android:** não há aparelho físico disponível nesta sessão; não declarar FPS,
  temperatura, toque físico, memória de GPU nem aprovação mobile sem esse teste.
- **Identidade:** paleta e tipografia propostas ainda não são arte oficial aprovada.
- **Produção:** nenhum serviço de produção, banco ou sistema financeiro autorizado.

## Continuidade

A Etapa 00 está tecnicamente pronta para revisão. A fundação da 01 está testada
e disponível para feedback visual; a etapa completa não foi declarada concluída.
Próxima tarefa técnica disponível: abas, listas, campos de entrada e mensagens de
validação no protótipo da 01. Consolidar a identidade após feedback antes de
reconstruir telas da 02. Nenhuma etapa está marcada APROVADO.
