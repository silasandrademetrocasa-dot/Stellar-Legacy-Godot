# G0.13 — Commerce & Equipment Rebuild (24/10/2026)

## Entrega
- Loja estelar: nave 3D à esquerda, catálogo com cartões/raridade/preço no centro, vitrine 3D selecionada à direita. Categorias: Naves, Armas, Escudos, Motores, Extras, Drones, AUX-9.
- Equipamentos: estação em três colunas; quadrados com **retratos congelados gerados dos GLBs** (não a antiga arte promocional), slots no centro, nave GLB à esquerda, item selecionado em 3D à direita.
- 53 retratos novos de modelos GLB para inventário e loja. As malhas `.glb` originais de nave, NPC, drone e AUX permanecem intactas.
- Novo equipamento GLB: **Reparador Comum** — reparação demonstrativa de casco fora de combate, inferior à AUX-9.
- Compra local por crédito de demonstração integrado ao inventário. Equipamentos, naves, drones e AUX precisam ser obtidos na loja; hangar não concede itens gratuitamente.
- G0.13 não conecta Supabase, Render nem API de pagamento.

## Migração única do inventário de teste
Na **primeira execução**, o salvamento local anterior de equipamentos (`user://stellar_g06_equipment_demo.json`) é copiado para `user://stellar_pre_g013_inventory_backup.json` (quando existente), e o novo kit inicial passa a ser:
- Nave **Aurora** (única nave possuída);
- 1 ARC-1 (laser), 1 SG-1 (escudo), 1 THR-1 (motor), 1 Reparador Comum (extra);
- Drones: 0, AUX-9: 0, demais itens: 0.
- Esses quatro itens ficam equipados na configuração 1. Configuração 2 começa vazia.

O marcador `inventory_schema=13` impede novos resets ao reiniciar o app. Créditos de demonstração, XP e outros sistemas locais são mantidos. **Backup é apenas uma cópia de teste**, e não uma transferência automática de progresso do servidor antigo. Remover arquivos em `user://` manualmente pode apagar progresso.

## Regras de compra
- Créditos vêm dos combates, missões e recompensas simuladas do piloto.
- Cada compra usa o preço do catálogo interno, desconta créditos da simulação e entrega **1 unidade** no inventário.
- Nave adquirida fica desbloqueada no hangar; drone/AUX comprados ficam disponíveis para instalação, mas não ativados automaticamente.
- Não há direito de propriedade online, pagamentos, reembolsos reais, leilão real, servidor de economia nem segurança de inventário autoritativa nessa fase.

## Validação no Android
1. Validar importação do ZIP pelo GitHub Actions / Godot 4.5.2.
2. Abrir o jogo: verificar Aurora como nave, quatro itens iniciais, nenhum drone/AUX.
3. Abrir loja: rolar categorias, cartões com imagem GLB congelada, selecionar item e girar vitrine 3D.
4. Ganhar créditos locais ao destruir NPCs/coletar caixas e comprar um laser, depois equipá-lo.
5. Comprar 1 drone e AUX-9, equipá-los no Hangar, confirmar que surgem somente equipados.
6. Comprar nave diferente e confirmar desbloqueio no Hangar.
7. Fechar/reabrir: inventário e saldo persistem, sem nova concessão de itens.
8. Testar controles de nave, portais, PvP 4-X, chat offline e qualidades gráficas anteriores.

**Nota:** importação estática e verificações locais de arquivos NÃO substituem execução real do Godot. Esta entrega depende do workflow e do teste Android para verificar layout e compilação.
