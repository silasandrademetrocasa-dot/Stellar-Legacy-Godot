# Revisão 1.0.2 — navegação, combate e orientação 2D

- As 43 naves agora usam arte nova ortográfica, vista diretamente de cima, com oito frames no mesmo plano. Nenhuma nave é inclinada/rolada em perspectiva ao mudar de rumo. Designers de Aurora/Pioneer usam a mesma silhueta 2D com pintura correspondente.
- Novos sprites de lasers retos e mísseis. Origem dos disparos à frente da nave; impacto sem ultrapassar a posição do alvo; lasers rápidos e mísseis mais lentos. A seleção usa contorno discreto e acompanha o NPC a cada frame.
- Campanha estritamente encadeada 1↔2↔3↔4↔5↔6↔7↔8. Mapa 8 retorna apenas ao 7. Regiões de arena e futuras permanecem separadas dessa cadeia.
- Cada destino possui seu portal, identificado no mundo e radar. O salto chega ao portal correspondente de retorno, com orientação para dentro do novo mapa. É possível voltar imediatamente; seguir adiante exige alcançar o outro portal.
- Base real apenas no mapa 1, no lado direito, substituindo o antigo portal desse lado. Novos perfis começam perto dela; saves antigos conservam posição e recebem botão MINHA BASE para traçar rota. Serviços exigem aproximação; respawn volta para a base.
- Seletores explícitos X1/X2/X3/X4 e mísseis tipos 1/2/3/4, com estoque numérico. Todas as munições são finitas; não há laser gratuito infinito. Estoque insuficiente interrompe o ataque sem paralisar a IA inimiga. Reposição automática continua condicionada ao equipamento/regra e cobra a moeda do pacote.
- Sem reset de saldos, equipamentos ou missões. Pinturas originais 2.5D preservadas no histórico de fonte; atlas de voo atual usa as novas artes 2D.

Validação: regras de ligações dos oito mapas, percurso ida/volta, portal errado recusado, base/serviços e esgotamento de X1–X4, além das regressões anteriores e testes de navegador. Não há alegação de homologação em Android físico.
