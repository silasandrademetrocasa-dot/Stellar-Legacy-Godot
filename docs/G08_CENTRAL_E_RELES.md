# Stellar Legacy G0.8 — Central Estelar, relés e economia experimental

## O que foi implementado

- Nova aba **CENTRAL**: links para Aliança, Relés, Missões, Passe, Mercado, Leilão, Premium e ADM.
- **PILOTO**: apelido personalizável, facção, aliança, level, XP, créditos e atividades locais.
- **Aliança local**: criar e sair, nome/tag com persistência no aparelho. Sem convites reais ou jogadores remotos.
- **PvP 4-X / evento Relés**: modelo de relé criado programaticamente no centro dos mapas `4-1`, `4-2` e `4-3`. Conquista demonstrativa por permanência de 12 segundos a até 19 unidades do centro. Indicador de captura no minimapa; núcleo muda de cor conforme facção. Estado salvo somente no Android. Não existe contestação PvP real.
- **Missões**: contratos adicionais com metas de combate, coleta e exploração; resgate de créditos de simulação.
- **Passe galáctico gratuito**: 4 etapas com progresso pelos mesmos eventos e recompensas offline; sem temporada paga.
- **Loja normal**: compra de 3 colecionáveis de demonstração com créditos locais, sem alterar armamentos.
- **Leilão**: registro de lances simulados em lotes demonstrativos, sem cobrança, saldo reservado, timer ou outros jogadores.
- **Loja premium**: tela informativa sem pagamento.
- **ADM**: planejamento somente leitura. Nenhum papel ADM é concedido localmente.
- **Batalha**: atalho para o evento PvP / relés. Não foi implementada Arena.

## O que permanece preservado

- Controle por toque e arraste, navegação pelo minimapa, perseguição, disparos sem cancelar deslocamento.
- Modelos originais 3D, hangar giratório, equipamentos, duas configurações e persistência.
- Progressão G0.7 e suas missões base.
- Produção WEB/iPhone, Render e Supabase atuais completamente isolados.

## Limitações honestas

O pacote não implementa autenticação, rede, multiplayer, disputas de relés entre jogadores, mercado transacional, leilão com lances reais, moderação, permissões administrativas, pagamento premium ou salvamento online. Todos os valores econômicos são de DEMONSTRAÇÃO. A captura local é um protótipo da regra de jogo para testarmos antes da autoridade no servidor.

## Testes no Android

1. Mover a nave e atacar enquanto arrasta; viajar por portal e manter G0.7.
2. Abrir PILOTO e salvar apelido; fechar e reabrir para conferir persistência.
3. Abrir CENTRAL e trocar por ALIANCA, RELES, MISSOES, PASSE, MERCADO, LEILAO, PREMIUM, ADM.
4. Criar aliança de teste, sair e reabrir para conferir armazenamento local.
5. Viajar até 4-1 pelo portal no mapa 1-1; chegar ao centro e ficar por 12 s; conferir relé e cor.
6. Viajar ao 4-2, 4-3; testar domínio por facções; confirmar que mapa comum não mostra relé.
7. Cumprir metas de missões e resgatar uma vez; verificar que repetir não concede prêmio.
8. Resgatar etapa do passe quando tiver pontos suficientes.
9. Comprar um colecionável de teste e verificar saldo de teste/persistência.
10. Testar um lance de leilão e confirmar aviso **sem pagamento real**.
11. Confirmar que PREMIUM não abre checkout e ADM não concede permissões.
12. Conferir desempenho, orientação, menus e rolagem no celular.

## Instalação

Use `StellarLegacy_Godot_G0.8_ATUALIZACAO.zip` no instalador universal, sobre a G0.7 validada. O ZIP contém somente arquivos criados/alterados. Para importação limpa no Godot, use o arquivo `COMPLETO.zip`. O workflow faz a validação Godot em modo headless antes de publicar; uma falha preserva o estado anterior do repositório. Não mantenha mais de um ZIP de instalação na raiz simultaneamente.
