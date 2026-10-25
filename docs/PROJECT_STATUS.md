# Stellar Legacy — acompanhamento oficial

Plano de referência: [ROADMAP.md](ROADMAP.md). A evolução segue critérios técnicos
e aprovação, sem duração predeterminada. O estado não é um percentual de esforço
nem uma declaração de que o sistema correspondente não existe no cliente atual.

Estados permitidos: **PENDENTE**, **EM DESENVOLVIMENTO**, **PRONTO PARA TESTES**,
**AGUARDANDO APROVAÇÃO**, **APROVADO**, **BLOQUEADO**.

| Etapa | Nome | Estado | Evidência / próximo marco |
|---|---|---|---|
| 00 | Auditoria e segurança | APROVADO | Aprovação explícita do proprietário registrada em APPROVALS.md; auditoria e evidências preservadas. |
| 01 | Design System galáctico | AGUARDANDO APROVAÇÃO | Direção visual aprovada; abas/listas/campos/validação adicionados com 545 verificações de UI e renderização. Revisão dos componentes novos pendente. |
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

Branch local: `codex/design-system-components`. Base instalada conferida no GitHub:
`d84f5f355c4278a4a310e31c07fd3e4b0a98274c`. A fundação anterior já foi instalada pelo workflow do proprietário.
A Etapa 00 e a direção visual apresentada receberam aprovação explícita, registrada
em [APPROVALS.md](APPROVALS.md). Isso não presume aprovação de código novo ou de
outras etapas. Nenhum push/merge direto do Codex foi realizado.

Etapa 01: componentes adicionais implementados e testados na prévia isolada.
Abas IDENTIDADE/COMPONENTES, abas por categoria, lista com busca/seleção/estado
vazio, registros indisponíveis e campo com validação e confirmação em memória.
Cores, fontes e motivo orbital aprovados foram preservados; HUD/Hangar e regras
do jogo não foram reconstruídos nesta revisão.

Resultado: **56 comandos** de validação, **17.466 verificações**, incluindo 545 da
UI; renderização Compatibility de sete cenários de jogo e doze da prévia. Logs em
`audit/components-validation-results.json`, capturas em `design/components-previews/`.
A instalação incremental é conferida pelo extrator do workflow e pela suíte em um
checkout limpo da base. Instruções: [DELIVERY_01_COMPONENTS.md](DELIVERY_01_COMPONENTS.md).

## Impedimentos e decisões abertas

- **Referências V3:** confirmar originais/hashes e artes por nave antes de certificar
  fidelidade. Os GLBs atuais permanecem intactos.
- **Android:** não há aparelho físico na sessão. Viewports e IME simulados não
  comprovam toque, teclado virtual físico, FPS, temperatura ou memória de GPU.
- **Identidade:** direção visual da fundação aprovada; novos componentes aguardam
  revisão. Alterações futuras nas artes aprovadas exigem validação.
- **Produção:** nenhum serviço de produção, banco ou serviço financeiro autorizado.

## Continuidade

A Etapa 00 está **APROVADO**. A Etapa 01 fica **AGUARDANDO APROVAÇÃO** do conjunto
adicional desta entrega. Nenhuma aprovação automática por teste ou instalação.

Próxima tarefa técnica: planejar a aplicação do Design System na Etapa 02,
começando pela estrutura de navegação/menu principal e HUD, em mudanças isoladas
que mantenham os fluxos existentes. O início da aplicação visual depende da
revisão desta biblioteca. Retopologia/novos GLBs e economia não integram esta entrega.
