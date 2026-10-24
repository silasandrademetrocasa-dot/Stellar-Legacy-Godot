# Stellar Legacy - Godot G0.2 (Navigation Foundation)

**Cliente Android experimental totalmente local**, independente da producao web.

Este projeto e uma migracao progressiva; NAO e ainda o MMORPG de producao. Os dados locais sao apenas preferencias do prototipo. Nao ha login, PvP real, economia real, chamadas Render ou SQL.

## Instalacao Android / GitHub

1. **Primeiro acesso no Godot**: na tela inicial do editor Android, escolha `Importar Projeto ZIP` e selecione `StellarLegacy_Godot_G0.2_COMPLETO.zip`.
2. **Atualizar G0.1 ja importado no celular**: extraia o ZIP `G0.2_ATUALIZACAO` usando o instalador configurado para *mesclar na raiz do projeto Godot*. Nao remova a pasta `assets/ships`. Reabra o editor para importar portais GLB.
3. **GitHub novo**: o repositorio esta vazio; seu instalador web atual NAO atende a Godot. Use o bootstrap do instalador Godot fornecido separadamente; depois coloque o ZIP completo na raiz do GitHub e execute o workflow **Instalador Godot - ZIP**.

## O que mudou desde G0.1

- Portais 3D (normal, PvP, universo) originais V53 importados em `assets/portals/`.
- Navegacao fisica local X-1 ... X-8 por faccao, conexoes 4-X via X-1, U-1 via X-8, U-2 e U-3.
- Posicoes dos portais dos mapas X e 4 espelhadas de `public/modules/portal-layout-v461.js` da WEB V64.
- Mapas U usam coordenadas provisórias nesta versao; a geometria original sera sincronizada depois com o servidor.
- Minimap mostra nave + portais do mapa inteiro; painel de mapa galactico orientativo (nao teleporta).
- Seletor de faccao e de nave; controles de toque; botao Viajar aparece ativo apenas a 10 unidades de um portal.
- Ao atravessar, nave surge afastada do portal de entrada com cooldown, evitando viagem de volta em loop.
- Preferencias (`map`, `faction`, `ship`) salvas em `user://`, so offline.

## Comandos

- Tela: setas `◀`/`▶`, `AVANCAR`, `PARAR`, `VIAJAR`, `ROTAS`.
- Teclado: W/S (avancar/parar), A/D (girar), M (mapa), E (viajar), R (voltar ao centro, apenas debug).
- Botao `VIAJAR` desabilitado se longe; entre no alcance do portal e toque.

## Regras e seguranca

- **Web/iPhone**: projeto de producao permanece inalterado.
- **Supabase / Render**: nao sao consultados pelo prototipo.
- **PvP**: somente um percurso demonstrativo, sem combate nem acesso validado a conta. Um cliente nao pode validar direitos de acesso sozinho.
- `4-X`: portais dos mapas 4-X seguem o grafo canonico. O prototipo impede entrar em X-1 de outra faccao, mas a autorizacao real devera ocorrer no servidor.
- `U-X`: posicoes de portais demonstrativas, nao copie essas coordenadas para o banco real.

## Teste rapido

1. Iniciar em `1-1` com nave PIONEER; rotacionar, acelerar, parar.
2. Abrir ROTAS; conferir sequencia de X-1 a X-8, U1-U3 e 4-X; fechar.
3. Ir ate `1-2` pela borda (portal BR da Terra); VIAJAR; volta em `1-2` proximo ao portal de `1-1`.
4. Verificar que viaja de volta ao `1-1` sem loop instantaneo.
5. No `1-1` usar portal central para `4-1` e voltar.
6. Testar Marte (`2-1`) e Jupiter (`3-1`) trocando faccao e observar orientacao dos portais.
7. Chegar em `X-8` e ir ate `U-1`, depois `U-2` e `U-3`.
8. Fechar o jogo e abrir; verificar a preferencia local restaurada.
9. Medir FPS, tempo de carregamento e consumo de memoria no Android.

## Limitacoes conhecidas

Godot Android 4.x em modo Compatibility recomendado. Nao foi validado no Godot Android desta sessao: teste na sua instalacao e compartilhe logs/prints de erros. GLBs podem exigir ajuste de escala/orientacao em aparelhos especificos. O script principal ainda orquestra varias funcoes; migracoes seguintes separarao jogadores/NPCs/HUD/combate em cenas e sistemas independentes.
