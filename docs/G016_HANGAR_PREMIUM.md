# G0.16 — Hangar Premium e modelos reais

## Implementado

- Tela própria em Godot 4.x dentro do modal HANGAR, utilizando GLBs locais.
- Nave de verdade em SubViewport 3D, com girar por arraste e rotação lenta automática.
- Carrossel de 13 naves; somente as **adquiridas** podem ser ativadas. As demais ficam visíveis escurecidas e marcadas como bloqueadas.
- Visualização de **um item realmente instalado por categoria** (maior bônus entre os equipados na configuração ativa): ARMAS, ESCUDOS, MOTORES, EXTRAS. Drone destaca unidade instalada; AUX mostra o suporte equipado. Nada é fabricado visualmente caso não exista.
- Miniaturas geradas a partir da geometria original dos **82 GLBs** existentes (naves, equipamentos, drones, AUX), não dos sprites do projeto web.
- Atributos das naves (HP/velocidade/porão/slots) oriundos de `scripts/data/ship_balance.gd` e o escudo ativo exibido conforme simulação offline atual.
- Abas de navegação para equipamentos, refinaria, títulos e loja.
- Os modelos GLB e a G0.15 são preservados integralmente.

## Importante sobre a qualidade visual

A vitrine usa os modelos GLB integrais, sem LOD reduzido. As miniaturas são renderizações 2D derivadas da malha 3D; portanto **não são sprites legados**, mas também não são imagens cinematográficas fotorealistas. O acabamento final das peças continua evolutivo.

## Como testar

1. Entrar no hangar e ver Aurora destacada, outras naves bloqueadas.
2. Conferir se escudo/laser/extras exibidos correspondem aos itens de fato equipados.
3. Selecionar nave bloqueada: botão leva à loja, nunca libera gratuitamente.
4. Comprar nave de teste e voltar: botão de ativar aparece após compra.
5. Mudar CONF 1 / CONF 2 nos equipamentos: os destaques de drones/AUX e slots mudam junto.
6. Reiniciar e verificar persistência local.

Este cliente não altera a produção Web/Supabase.
