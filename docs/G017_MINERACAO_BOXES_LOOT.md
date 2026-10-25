# Stellar Legacy G0.17 — Recursos 3D HQ, caixas bônus e loot de NPC

## Fonte de referência
- Modelos 3D: `STELLAR_LEGACY_RECURSOS_3D_HQ_GODOT_GITHUB.zip` enviado pelo criador.
- Mecânica web (backup de 24/10/2026): `public/data.js` (`RESOURCES`, `MAPS`, `NPC_TYPES`) e `public/game.js` (`collectCargoBox`, `spawnOre`, `BONUS_CONFIG_DEFAULT`, `collectBonusBox`).
- Cópia offline exclusiva do cliente Godot; não altera a versão web nem chama banco/Render.

## Modelos GLB instalados sem mudanças
- `assets/loot/box_bonus.glb` — box bônus dourada, GLB HQ original;
- `assets/loot/box_loot.glb` — box loot NPC ciano/cobre, GLB HQ original;
- `assets/resources/minerio_{ciano,ouro,violeta,esmeralda,plasma}.glb` — cinco cores HQ.

## Jogabilidade implementada
1. **Minérios:** viajar, tocar ou arrastar até minério, recolher por aproximação. Porão físico limitado ao da nave e aos expansores equipados, com coleta parcial se necessário. Salvamento em `user://stellar_g017_cargo_local.json`.
2. **BOX LOOT:** NPC destruído solta caixa GLB com recursos por espécie. Dura **30 segundos**; só transfere recursos que cabem no porão, preserva o restante na caixa enquanto ela existir.
3. **BOX BÔNUS:** 20 em mapas comuns, 30 em mapas PvP 4-X e 0 em portais Astrais. Cada uma entrega UMA recompensa aleatória (sem adicionar automaticamente XP/CR fixos extras) conforme sete tipos da configuração web: PLS-1, PLS-2, PLS-3, SIP-2, créditos, Stellarium ou Poeira Stellar. Reaparece entre **40 e 70 segundos**.
4. **Mapas / persistência:** posições e prazos de respawn das caixas bônus persistem por mapa localmente (`user://stellar_g017_resources_demo.json`). Viajar/fechar o jogo não recria instantaneamente o prêmio.
5. **Mineração de mapa:** minérios comuns Ferron/Cryon/Virel, respawn de **5–12 s**. O mapa Android é muito menor que o mundo web; mantemos **10–14 minérios HQ simultâneos**, em lugar dos 44–94 do mapa web. Os minérios de demonstração refinados Duracite e Solarium surgem raramente em setores 5+ e 7+, para aproveitar os cinco GLBs enviados. Essa presença extra ainda não é uma regra oficial de produção.
6. **Refinaria:** menu agora exibe porão e Poeira Stellar, e permite vender recursos por Créditos **locais de teste** quando próximo da base da facção no X-1 ou com Terminal Mercante Remoto equipado. Voidite não é vendida por CR.
7. **Minimapa:** marca separadamente drops de NPC, minérios e bônus, mantendo nave e portais.
8. **AUX-9 equipado:** módulos `Coletor de Minérios` e `Coletor de Cargas` ampliam o alcance local de coleta para 15 unidades; sem possuir e equipar AUX e o módulo, coleta permanece por aproximação da nave.
9. **Gráficos:** nenhum GLB é simplificado. Baixo/Médio/Alto ajustam apenas a distância de carregamento visual dos minérios/caixas HQ para proteger o Android. As posições e as mecânicas continuam existindo à distância.

## Valores locais de venda por unidade (retirados do web)
| Mineral | CR |
|---|---:|
| Ferron | 1.000 |
| Cryon | 1.500 |
| Virel | 2.500 |
| Ferrite | 10.000 |
| Duracite | 15.000 |
| Solarium | 35.000 |
| Voidite | 0 (não vendável) |

## Limitações e proteção da G0.17
- Recompensas, posições e tempo são processados **localmente**, sem sincronização online/autenticidade de servidor.
- O limite de quantidade visível dos recursos HQ é intencional para não saturar aparelhos modestos; nenhum GLB da nave, NPC, AUX ou drone foi alterado.
- As caixas e minérios próximos podem exigir espaço livre no porão; a coleta interrompe sem eliminar recurso quando cheio.
- Esta atualização preserva os arquivos de salvamento anteriores; o estoque de recursos novo tem persistência separada.
- Testar a importação/compilação no GitHub Actions (Godot 4.5.2) e a jogabilidade no aparelho Android antes de publicar.

- A G0.17 mantém o contador de caixas de missão, mas a coleta não concede bônus fixo de XP/Créditos além do prêmio sorteado; o ciclo de recompensa fica mais fiel ao web.
