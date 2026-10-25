# Estratégia de migração com risco mínimo

## Preservação
1. Repositório WEB/MAIN mantém Render/Supabase atuais e usuários de iPhone.
2. Fazer tag `web-v64-backup` no GitHub original e guardar ZIP em local próprio.
3. Criar novo repositório `stellar-legacy-godot` (sem copiar `render.yaml` da versão web).
4. Usar Godot primeiro totalmente offline para validar GLB, FPS, controles e importação.
5. Criar backend *staging* ou endpoints isolados/sem escrita antes de conectar à versão atual.
6. Somente depois implementar ponte de autenticação, snapshots de estado, delta updates e reconexão.
7. Não executar migração SQL do cliente novo no banco de produção durante o experimento.

## Planejamento oficial

A ordem antiga por versões de migração foi substituída pelo plano mestre de
12 etapas numeradas de 00 a 11 em [ROADMAP.md](ROADMAP.md). Objetivos, entregas,
critérios e dependências estão nesse arquivo; o acompanhamento e as aprovações
ficam em [PROJECT_STATUS.md](PROJECT_STATUS.md). O avanço segue qualidade,
estabilidade, testes e aprovação do proprietário, sem duração predeterminada.

As anotações técnicas de preservação acima continuam sendo limites de migração,
não instruções para criar serviços de produção nesta entrega. Qualquer integração
externa futura exige autorização específica e ambiente apropriado.

## Limites
- Um GLB pode exigir ajustes de escala, orientação ou importação; o protótipo não substitui QA no editor.
- Godot Android não oferece suporte a C# no editor móvel: utilizar GDScript.
- Ter dois clientes conectados ao mesmo servidor exigirá protocolo retrocompatível para não quebrar o jogo web.
- Render/Supabase continuam sendo necessários para autoridade de combate, economias e persistência.
