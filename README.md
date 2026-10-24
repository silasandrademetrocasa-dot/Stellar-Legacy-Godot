# Stellar Legacy Godot G0.11 — Base & Equipment Command

**Atualização incremental sobre a G0.10 aprovada no Android.** Cliente experimental inteiramente local: não altera a versão web, Render ou Supabase.

## Novidades G0.11

- **Estação de equipamentos em três colunas**: nave ativa e visualização 3D à esquerda, slots por categoria e configurações ao centro, inventário organizado em grade à direita.
- **Sem miniaturas antigas na tela de equipamentos.** O inventário usa cartões de texto compactos (nome e quantidade), e a vitrine GLB animada só aparece quando um item é selecionado.
- **Ações funcionais**: equipar, remover, tocar slots vazios/ocupados, copiar configuração e alternar CONF 1/CONF 2, preservando o intervalo de 5 s e os dados locais existentes.
- **Base estelar 3D própria em X-1**: plataformas, anéis, torres, núcleo luminoso e cores das facções Terra/Marte/Júpiter; visível no minimapa como BASE.
- **Interação com a base**: viaje até a marca BASE no minimapa, aproxime-se e toque BASE na barra inferior para abrir o hangar.
- **Qualidade Baixo/Médio/Alto**: afeta iluminação e decoração da base; não simplifica modelos GLB de naves, drones, AUX-9 ou NPCs.

## Testes prioritários no Android
1. Em X-1, toque BASE no minimapa para chegar perto da estação; verifique a estrutura 3D e o botão BASE.
2. Abra Equipamentos: esquerda = nave 3D; centro = slots; direita = inventário em grade sem miniaturas antigas.
3. Selecione ARC-1 na grade: surge preview 3D; toque EQUIPAR e confirme mudança do slot.
4. Toque slot ocupado para remover, depois um slot vazio da mesma categoria para equipar.
5. Troque configurações 1/2 (aguarde intervalo), copie config e feche/abra o jogo para conferir salvamento.
6. Troque Terra/Marte/Júpiter; confirme base apenas nos respectivos X-1 e manutenção de todos os portais.
7. Teste toque e arraste para navegar, ataque em movimento, loja, refinaria e portais astrais.

## Limites
- A base 3D é uma estrutura local original criada com malhas e materiais Godot, sem colisão/PvP ou serviços reais.
- Os itens e as duas configurações permanecem demonstrações locais em `user://`.
- Nenhuma instalação desta versão cria direitos administrativos, créditos verdadeiros ou compras online.
- O importador GitHub Actions valida os scripts Godot. A jogabilidade exige teste no aparelho.

---

# Stellar Legacy Godot G0.10 — Arsenal & Materializador X-1

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


Veja `docs/G010_VIDEO_MIGRACAO.md` para diferencas, testes e escopo.
