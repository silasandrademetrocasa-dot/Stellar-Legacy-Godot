# STELLAR LEGACY — GODOT G0.9 | ASTRAL DOMINION

**Android / cliente Godot experimental. Somente offline.** A versão web (iPhone), Render e Supabase de produção não foram alterados.

## O que tem de novo

**Portais Astrais Aurora, Nexus e Eclipse**: 3 GLBs novos com cerca de 26 mil faces cada, núcleo, anéis e runas iluminadas. Entrada física apenas nos mapas **1-8 / 2-8 / 3-8**; aproxime-se do portal e use **VIAJAR**. Cada arena tem 3 ondas PvE progressivas e NPCs GLB de qualidade integral. Saia pelo portal físico de retorno. Vitórias e melhor onda ficam salvas no celular; não representam dados reais de outros jogadores.

**Loja normal**: cartões visuais, vitrine 3D giratória, armas ARC, escudos SG, motores THR e extras. Compras de teste descontam créditos exclusivamente locais e acrescentam uma unidade ao estoque local de equipamentos. Não há preço real, pagamento, recibo ou compra em servidor.

**Leilão orbital**: quatro lotes com preview de equipamentos 3D e lances de simulação local (+50 créditos por clique). Não há concorrentes online, temporizador do servidor, reserva de saldo ou vencedor real.

**Gráficos BAIXO / MÉDIO / ALTO**: em CONFIG, os perfis afetam apenas cenário, estrelas, FX auxiliares, iluminação e sombras. Em todos os perfis, o mesmo arquivo GLB de qualidade total é utilizado para naves, NPCs, drones e AUX-9 — nenhuma troca por LOD, simplificação, textura reduzida ou reescalonamento das malhas é feita. O modo ALTO habilita sombras do ambiente, o MÉDIO equilibra cenário e o BAIXO reduz efeitos decorativos.

**Menu Astral**: BATALHA → PORTAIS ASTRAIS ou CENTRAL → ASTRAL. Exibe fichas visuais e progresso. O menu não teleporta: siga pelo universo até um portal.

## Como atualizar pelo instalador universal

1. Mantenha a G0.8 validada no repositório.
2. Exclua os ZIPs antigos da raiz do GitHub (não apague os diretórios de código).
3. Envie **somente** `StellarLegacy_Godot_G0.9_ATUALIZACAO.zip` para a raiz.
4. GitHub → Actions → Instalador ZIP Godot → Run workflow.
5. Acompanhe o job **Importar e validar projeto Godot**. Se terminar verde, baixe a versão do repositório e importe no editor Android.
6. Use o ZIP COMPLETO para iniciar outro projeto isolado no Godot, se desejar.

## Roteiro prático de testes Android

- Iniciar na G0.8 já existente: mapa/nave/equipamentos mantidos.
- Tocar em CONFIG; alternar BAIXO / MÉDIO / ALTO e conferir que as mesmas naves/NPC/drones/AUX continuam idênticos em geometria.
- Ir fisicamente do mapa X-1 até X-8; visualizar os 3 GLBs de portais astrais em X-8; aproximar e viajar para Aurora.
- Selecionar e atacar todos os NPCs; concluir 3 ondas; confirmar a notificação de vitória e progresso no menu ASTRAL.
- Retornar pelo portal de saída para X-8. Repetir em Nexus e Eclipse.
- Abrir CENTRAL → MERCADO; visualizar modelos 3D, adquirir item com créditos locais e verificar o estoque no menu EQUIPAMENTOS.
- Abrir CENTRAL → LEILAO; visualizar lotes e testar lances locais.
- Testar FPS e consumo de memória no modo BAIXO, MÉDIO e ALTO, especialmente em aparelhos modestos.
- Conferir que relés PvP 4-X, drones, movimento por arraste, loot, configuração 1/2 e Perfil continuam operacionais.

## Limites de segurança

- Protótipo OFFLINE, sem autenticação, banco novo, compras premium, ranking e leilão online.
- A captura de relés e resultados de combate não são autoritativos em multiplayer.
- Nenhuma configuração ou SQL do Render e do Supabase foi alterado.
- Os 3 GLBs de portais são originais gerados para Godot, inspirados no esquema de cores e nomes do catálogo web V64, não são réplicas idênticas de imagens conceituais.
- A validação local cobre estrutura, importações referenciadas e GLB; a execução no Godot 4.5.2 deve ser verificada no GitHub Actions e o desempenho no Android.
