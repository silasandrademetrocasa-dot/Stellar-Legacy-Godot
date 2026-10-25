# Stellar Legacy Godot — G0.15

## Foco desta etapa
- remover dependência visual das thumbs antigas G0.13/G0.14;
- iniciar nova base visual G0.15 para itens da loja/equipamentos;
- organizar a loja por **raridade** e **preço**;
- manter o inventário inicial limpo (Aurora + ARC-1 + SG-1 + THR-1 + Reparador Comum).

## O que foi aplicado
1. **Nova camada visual G0.15**
   - pasta `assets/ui/g015_models/` criada;
   - thumbs novas para equipamentos, munições, mísseis, extras, módulos AUX, drones, AUX-9 e naves da vitrine.

2. **Remodelagem procedural dos itens**
   - GLBs de `assets/equipment/` regenerados com linguagem visual unificada;
   - categorias com leitura própria: armas, escudos, motores, extras, módulos AUX, munições e mísseis.

3. **Raridade na loja**
   - filtros: **TODOS, COMUM, RARO, ÉPICO, ELITE, LENDÁRIO**;
   - ordenação por raridade e custo dentro de cada categoria.

4. **Starter kit preservado**
   - nave inicial: `AURORA`;
   - itens iniciais: `ARC-1`, `SG-1`, `THR-1`, `REPARADOR COMUM`;
   - THR-1 continua no inventário, respeitando o gerador compartilhado da Aurora.

5. **Perfil limpo para testes G0.15**
   - novos caminhos `user://` para a carteira e inventário G0.15.

## Observação
- esta etapa prepara a base visual e a organização da loja.
- numa próxima fase dá para evoluir os GLBs proceduralmente item a item com ainda mais diferenciação por família (ex.: ARC, VSH, THR, CPUs e munições especiais).
