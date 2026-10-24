# Estratégia de migração com risco mínimo

## Preservação
1. Repositório WEB/MAIN mantém Render/Supabase atuais e usuários de iPhone.
2. Fazer tag `web-v64-backup` no GitHub original e guardar ZIP em local próprio.
3. Criar novo repositório `stellar-legacy-godot` (sem copiar `render.yaml` da versão web).
4. Usar Godot primeiro totalmente offline para validar GLB, FPS, controles e importação.
5. Criar backend *staging* ou endpoints isolados/sem escrita antes de conectar à versão atual.
6. Somente depois implementar ponte de autenticação, snapshots de estado, delta updates e reconexão.
7. Não executar migração SQL do cliente novo no banco de produção durante o experimento.

## Ordem sugerida
- G0.1: importação e controles Android com assets originais (este pacote)
- G0.2: mapa, NPCs, drones, AUX e UI definitiva
- G0.3: cliente de protocolo WebSocket + autenticação segura, só no staging
- G0.4: multiplayer, mapa e interpolação sincronizados
- G0.5: export Android automatizado, medições e testes com usuários

## Limites
- Um GLB pode exigir ajustes de escala, orientação ou importação; o protótipo não substitui QA no editor.
- Godot Android não oferece suporte a C# no editor móvel: utilizar GDScript.
- Ter dois clientes conectados ao mesmo servidor exigirá protocolo retrocompatível para não quebrar o jogo web.
- Render/Supabase continuam sendo necessários para autoridade de combate, economias e persistência.
