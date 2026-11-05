# Aceite da entrega 1.0.0

Evidência executada e números finais em `RESULTADOS_GDD.md` e `benchmark-dom.json`.

| Área | Verificação |
| --- | --- |
| Navegação | Dead zone, amortecimento, velocidade angular, histerese e sequência de 3.600 entradas; touch real via CDP; replay compara posição com erro menor que 0,01 unidade no percurso testado |
| Cena | Renderer DOM; nenhum elemento canvas; imagens raster originais, LODs e caixa de loot independente do NPC |
| Estado | 100 comandos concorrentes serializados, dez reaberturas, pending recuperado, falha quota, hash corrompido, conflito de revisão, snapshots e importação |
| Legado | Hash verificado antes da migração, carteira/carga/IDs/configurações preservados e HP convertido proporcionalmente |
| Economia | Compra, slots, venda na moeda paga, preço administrado, insumos de refinaria, protocolo, idempotência e evento bloqueado na loja |
| Conteúdo | Exatamente 177 registros; 43 naves, 34 NPCs ativos com rota de spawn e 14 mapas; 27 NPCs futuros bloqueados |
| Progressão | Missões terminais, passe, XP, arena com alvo próprio, captura/defesa Warfront, contribuições do clã e leilão com escrow |
| Farm | Snapshot, reserva/devolução do mesmo tipo de munição, oito horas, meia-noite e resgate único após reabrir offline |
| PWA | Root e base explícita de subdiretório; cache completo, sem rede e reabertura em Chromium |
| Entrega | ZIPs comuns <=24.000.000 bytes; caminhos únicos e SHA-256 por arquivo/parte; reconstrução vazia, npm ci/lint/test/build e teste Pages/offline |
| Instalação | Partes ausentes/corrompidas recusadas antes da mutação; troca do index real e remoção de assets antigos; push/clone em remoto Git local |

Não homologado: Android físico, APK nativo, FPS/bateria/memória no telefone, balanceamento definitivo, multiplayer real e publicação na conta GitHub do usuário. São limites explícitos, não testes declarados como aprovados. Receitas sem especificação oficial permanecem TODO_BALANCE.
