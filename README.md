# Stellar Legacy — Godot G0.3 (Mundo Vivo)

**Android primeiro, Godot 4.5.x, renderizador Compatibility.**

> **Projeto experimental LOCAL. Não se conecta ao Render, ao Supabase ou ao servidor do jogo WEB.**
> Todos os HPs, escudos, inimigos, lasers e eliminações são simulação local. Não existem STL, créditos, XP, drops resgatáveis ou inventário persistente.

## Resultado G0.2

O usuário confirmou 7/7 testes no Android: movimentação, portais, X-1→X-2, minimapa, ROTAS, PvP 4-1 e persistência do mapa/nave. Tudo permanece neste projeto.

## Novidades G0.3

- **NPCs 3D** da versão web V64: Streuner, Recruta Streuner, Mordon, Saimon, Sibelon, Lordakia, Devolarium. Mapas U-X usam Rift Scout, Void Corsair, Astral Reaper e Nexus Warden.
- **Mapas 4-X:** *nenhum NPC comum*, respeitando a regra de PvP.
- **IA local:** NPC patrulha uma região próxima da origem e só reage/ataca após ser atingido. Após destruído, renasce em ~11 segundos.
- **Alvos:** botão ALVO seleciona NPCs ativos em ordem de proximidade, alternando a cada toque.
- **Combate:** segurar LASER atira a cada ~0,42 s, com alcance de 78 unidades; espaço no teclado também dispara.
- **Escudo e HP:** barras da nave e do alvo, dano, resgate de nave para nova simulação ao chegar a zero, AUX-9 reparando escudo fora de combate.
- **Drones:** dois modelos originais voam acompanhando a nave; ataque assistido quando há alvo em alcance, com botão de ligar/desligar.
- **AUX-9:** modelo original seguindo a nave, botão para ligar/desligar o módulo de reparo experimental.
- **Drops demonstrativos:** caixas GLB locais por 18 segundos após uma eliminação. Não são resgatáveis.
- **Minimapa:** NPCs como pontos vermelhos; portais azuis/dourados e jogador verde.
- **Navegação original G0.2:** 1-X, 2-X, 3-X, 4-X e U-X, portais físicos e perfil local preservados.
- **HUD horizontal:** painel de HP/ESC e alvo, ALVO, LASER, DRONES, AUX-9.

## Instalação no GitHub pelo celular

1. Para um repositório G0.2 com o instalador ativo, coloque somente `StellarLegacy_Godot_G0.3_ATUALIZACAO.zip` na raiz (não extrair).
2. Abra **GitHub → Actions → Stellar Legacy Godot - Instalador ZIP → Run workflow**.
3. Aguarde a execução concluir. O instalador extrai o ZIP, valida com Godot 4.5.2 e publica as mudanças.
4. Para um projeto novo, importe `StellarLegacy_Godot_G0.3_COMPLETO.zip` diretamente no editor Godot Android.
5. Não deixe vários `.zip` na raiz do repositório: o instalador atual exige **um só**.

## Controles Android

- `◀`, `▶`: girar;
- `AVANCAR`, `PARAR`: movimentação;
- `VIAJAR`: viajar ao estar próximo do portal;
- `ROTAS`: visualizar mapa galáctico;
- `ALVO`: selecionar próximo NPC ativo;
- `LASER`: segurar para atirar, estando até 78 unidades;
- `DRONES ON/OFF`, `AUX-9 ON/OFF`: alternar suporte.

## Testes de regressão G0.3

1. Abrir `1-1` em Android horizontal; mover, trocar nave e reabrir app; testar todos os 7 casos G0.2.
2. Encontrar NPCs (pontos vermelhos) e selecionar ALVO. Confirmar barras e distância.
3. Aproximar-se, segurar LASER; HP e escudo do alvo devem diminuir e o alvo reagir.
4. Eliminar um NPC; a caixa aparece, contador sobe apenas localmente e o NPC renasce ~11 s depois.
5. Testar drones ON/OFF e AUX ON/OFF (o AUX repara escudo após ~4 s sem danos).
6. Trocar de mapa por um portal; NPCs do mapa anterior devem sumir, novos devem aparecer e os drones devem acompanhar.
7. Entrar em `4-1`; **não devem aparecer NPCs comuns**, mesmo após permanecer por vários segundos.
8. Visitar U-1: encontrar NPCs especiais e manter o painel ROTAS funcional.
9. Testar FPS, tempo de carregamento, uso de memória e estabilidade por 10 minutos.

## Limites conhecidos

- Trata-se de uma **simulação de mecânicas**, não do combate online original. Números e IA são de prototipação e precisam ser calibrados depois.
- Recursos da economia, missão, PvP multiplayer, Autopilot, clan relays, autenticacão e sincronização não são implementados nessa fase.
- Cenas 3D, iluminação e escala dos GLBs precisam ser verificados visualmente no dispositivo; os modelos estão incluídos para importação local.
- Não houve teste real de FPS no Android ou exportação APK nesta sessão. O workflow fará a validação de importação; o teste de jogo cabe ao editor Android.
- Não altere banco SQL, Render ou a versão Web/iPhone para experimentar G0.3.
