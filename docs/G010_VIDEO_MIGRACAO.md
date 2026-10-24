# Stellar Legacy Godot G0.10 — migração guiada por vídeo WEB

## Base / preservação
- Pacote **incremental cumulativo** sobre G0.9; projeto WEB/iPhone permanece intocado.
- Não modifica modelos GLB das naves, drones, AUX-9 ou NPCs; perfis baixo/médio/alto continuam variando apenas a ambientação.
- Não cria conexão ao servidor, pagamentos, leilão real ou controle ADM.

## Funcionalidade adicionada
1. **Portais astrais no X-1**: 1-1, 2-1, 3-1; os portais de U-1 permanecem no X-8. Corrigidas rotas visuais, destinos e retorno.
2. **Materializador**: fragmentos por NPC (+1) e caixa (+2), geração de chaves Aurora (4), Nexus (9), Eclipse (15), custo de entrada local; primeiro login inclui 22 fragmentos de demonstração e 1 chave Aurora.
3. **19 GLBs inéditos**: VSH-0 até VSH-6, FS-01 até FS-04, ARC-Q, VORTEX-X, PULSAR-7, FALCAO, CATACLISMO, RAIO CELESTE, SUSSURRO e BRASA. Modelagem 3D procedural de teste com materiais PBR; não são reprodução exata do conceito artístico.
4. **19 miniaturas** recortadas das artes fornecidas pelo autor, usadas como referência visual nos cartões; o preview lateral segue renderizando modelos GLB rotativos de verdade.
5. **Loja / leilão**: opções adicionais com prévia 3D, filtros por categoria, preços e lances locais. Não há pagamento ou usuários fictícios.
6. **Progressão de equipamentos**: os 12 itens iniciais da G0.6 continuam disponíveis; os 19 novos modelos começam sem estoque e podem ser inspecionados antes da compra local.
7. **Hangar com subtelas**: NAVES, EQUIPAMENTOS, DRONES, AUX-9, REFINARIA e TÍTULOS.
8. **Refinaria local**: converter 350 créditos demonstrativos em quatro fragmentos.
9. **Títulos**: desbloquear conforme derrotas, relés e portais concluídos.
10. **Persistência corrigida**: compras de equipamentos agora salvam também o estoque local (antes apenas layouts). Salvos antigos são preservados.

## Diferenças do vídeo WEB ainda pendentes
- Equipamento real por nave/drone/AUX-9, estatísticas de equipamento persistentes no backend, sistema de grupo e clã online, missões diárias baseadas em datas, temporadas e passe online, leilão entre jogadores, ADM remoto seguro e ranking de domínio.
- Arte dos novos GLBs é inspirada nas referências, mas ainda requer modelagem detalhada e texturização próprias para atingir fidelidade cinematográfica.

## Plano de testes Godot Android
1. Conferir X-1 com os portais Aurora/Nexus/Eclipse e X-8 com U-1 (sem astral).
2. Abrir CENTRAL > ASTRAL; materializar uma chave; aproximar de um portal e VIAJAR. Sem chave, a viagem deve ser bloqueada sem gasto de fragmentos.
3. Derrotar um NPC, pegar caixa, reiniciar editor e conferir persistência de fragmentos.
4. Entrar em HANGAR e abrir os seis subtítulos; equipar VSH e ARC no inventário.
5. Abrir CENTRAL > MERCADO, alternar filtros e inspecionar os novos GLBs.
6. Comprar um item local, fechar e reabrir; verificar estoque total (correção G0.9).
7. Abrir LEILAO; inspecionar novo lote e fazer lance DEMO; verificar persistência.
8. Em CONFIG alternar qualidade BAIXO/MEDIO/ALTO e conferir que modelos essenciais não são alterados.

## Segurança
Não usar este ZIP em repositório web. Todo o progresso monetário é **simulação local sem valor real**. Não conceder privilégios ADM por variáveis do cliente.
