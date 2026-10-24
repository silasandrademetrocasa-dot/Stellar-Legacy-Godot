# Stellar Legacy Godot G0.7 — Fundação de progressão local

## Objetivo
Converter as aprovações da G0.6 em uma base de exploração/recompensas demonstrativas que poderá ser substituída por resultados validados pelo servidor.

## Conteúdo incluído
- Menu PILOTO: nível, XP, créditos de TESTE, mortes de NPC, caixas recuperadas, mapas explorados, missões e histórico curto.
- Coleta física de caixas: após destruir NPC, aproximar a nave da caixa a até 7,5 unidades; pode tocar na caixa para voar até ela.
- Minimap mostra caixas em amarelo.
- Recompensas demonstrativas locais por NPC (com valores diferentes para U-X) e caixa.
- Missões de fundação: 5 NPCs, 3 caixas, explorar 4 mapas. Premiação local apenas uma vez.
- Progressão XP: custo incremental nível 1→2 = 10.000; 2→3 = 20.000 e assim sucessivamente.
- Dados persistem em `user://stellar_g07_pilot_offline.json`, independentemente dos saves anteriores (configuração, naves e equipamentos).

## Regras importantes
- ZERO conexões Render/Supabase. Dinheiro, XP, eliminação, missão e caixa NÃO são dados reais e NÃO devem ser enviados como confiáveis ao futuro servidor.
- Nenhuma alteração nas rotas, mira independente ou configurações 1/2 já aprovadas.
- PvP 4-X continua sem NPCs comuns; recompensas PvE não funcionam em 4-X.
- O cliente não faz autenticação, compra, leilão, ranking ou persistência de servidor.

## Checklist G0.7 (Android)
1. G0.6: arrastar cenário/minimapa e disparar simultaneamente — comportamento inalterado.
2. Abre menu PILOTO, exibe nível 1, barra de XP e contadores de TESTE.
3. Elimina NPC, vê aviso de XP e créditos DEMONSTRATIVOS, surge caixa amarela no minimapa.
4. Toca na caixa distante, nave vai até ela, recolhe só ao chegar perto; o ataque não é cancelado.
5. Abre PILOTO e confirma que o contador de caixas aumentou só uma vez.
6. Completa 5 eliminações e 3 caixas; missão é concluída apenas uma vez.
7. Explora 4 mapas diferentes e verifica missão de exploração.
8. Fecha/reabre Godot e confere que XP, missões e equipamentos permanecem salvos.
9. Visita 4-X e confirma ausência de NPCs comuns.
10. Mede FPS com NPCs, caixas e movimento em celular real.

## Próxima etapa proposta: backend staging isolado
- Criar **novo projeto Supabase**, separado do banco usado pela versão web/iPhone.
- Projetar tabelas próprias: `pilot_profiles`, `pilot_progress`, `pilot_inventory`, `pilot_loadouts`, `pilot_missions`.
- Todo dado econômico, combate PvP/PvE, XP e prêmios devem ser **calculados no servidor Render de staging**; não aceitar valores declarados pelo cliente.
- O futuro jogo Godot receberá snapshots iniciais + deltas compactos via WebSocket, com autenticação e reconexão.
- Aplicar RLS e autorização por proprietário no Supabase. Nunca colocar chaves secretas no APK.
- Migrar/adaptar regras do jogo, não histórico de IDs e nem dados de produção.

## Voltar para a G0.6
- Não alterar ou excluir `user://` ao testar atualização.
- Manter backup do repositório e da G0.6 Hotfix2. Rollback do código não altera dados de produção.
