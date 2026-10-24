# Stellar Legacy G0.12 — Premium HUD & Base Refinement

## Experiencia de combate e chat
- Barra inferior: comunicador local, VIAJAR/BASE e municoes/ataque.
- ALVO permanece no painel superior, com atalho de proximo alvo.
- Chat nao envia mensagens a outros jogadores e nao consulta Render ou Supabase. Historico somente em RAM da sessao.
- DRONES e AUX-9 nao possuem controles manuais de ativacao: estado deriva de item possuido/equipado no hangar.
- Kit inicial de teste explicito: Drone Alfa, Drone Beta e AUX-9 (nao representa compra real).
- Hangar > DRONES ou AUX-9: selecionar GLB e INSTALAR/REMOVER. Adquirir um item ausente e demonstrativo, sem transacao real.

## Base X-1
- Geometria redesenhada em plataforma rasa e colocada 4,5 unidades abaixo do plano de voo.
- Sem colisoes; o jogador sobrevoa o pad e portais preexistentes nao mudam.
- Indicacao BASE no minimapa e acesso pelo controle BASE, quando proximo.

## Visual e qualidade
- Casca com contornos iluminados, fundos espaciais e cores por setor em todas as janelas.
- Baixo/Medio/Alto continuam controlando efeitos e iluminacao; nenhum GLB essencial foi simplificado.

## Producao
- Tudo offline. Nao alterar dados de jogadores, banco, Web/iPhone, Render nem Supabase.

## Teste
1. No mapa X-1, sobrevoar base sem o casco ser atravessado por antenas.
2. Arrastar para navegar e atacar sem interrupcao.
3. Rodape: chat local, munições, viajar/base, atacar; sem botao Drone/AUX.
4. Hangar > DRONES: remover/instalar e verificar presenca no mundo. Repetir AUX-9.
5. Fechar e abrir o jogo para verificar persistencia do suporte.
6. Abrir Loja, Central, Piloto, Leilao, Astral, Config e Equipamentos para revisar paleta.
