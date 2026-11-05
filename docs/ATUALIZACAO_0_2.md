# Atualização 0.2 — desempenho, navegação e economia

## Gráficos

Os presets mantêm as mesmas regras de movimento, IA, dano, munição, recompensa e coleta. Só o trabalho visual muda.

| Perfil | Limite de renderização | Resolução interna máxima | Orçamento de pixels | VFX simultâneos | Efeitos |
| --- | --- | --- | --- | --- | --- |
| Baixo | 30 FPS | 0,75× CSS, limitado pelo aparelho | 650 mil | 3 | Tiros e explosão curta; sem partículas de impacto/coleta, parallax ou blur do HUD |
| Médio | 30 FPS | 1× CSS, limitado pelo aparelho | 1,1 milhão | 10 | Impactos com intervalo mínimo, explosão/coleta moderadas, parallax leve, sem blur do HUD |
| Alto | Até 60 FPS | Até 2× CSS, limitado pelo aparelho | 4 milhões | 28 | Sequências completas, parallax e acabamento de interface completos |

Esses limites não são promessa de FPS no aparelho. Resolução é recalculada ao redimensionar e o preset salvo é aplicado já na inicialização. O atlas de naves/NPCs/estação/portal/caixa é compartilhado para facilitar batching; tiros e VFX usam um pool de até 64 sprites inativos. O HUD atualiza em 350/250/150 ms por perfil e não reconstrói o cartão do alvo quando seus dados não mudaram.

## Monitor opcional

Em Preferências, marque **Mostrar FPS e desempenho**. A escolha fica no save. O monitor mostra FPS médio recente, intervalo médio por quadro, p95 do intervalo, tempo suavizado da simulação/atualização da cena em JS, VFX, projéteis e resolução interna. As amostras usam `performance.now()` entre atualizações de quadro, sem o teto do delta de simulação. A janela contém no máximo 120 intervalos e é recalculada a cada 500 ms. Ocultar desativa a amostragem e limpa o histórico. Retomar após suspensão também limpa as amostras.

`JS cena` não inclui uma medição direta de GPU nem de todo o custo de composição do navegador. FPS no teto do preset significa que o limitador pode estar atuando. Comparações devem usar o mesmo setor/cenário e ocorrer em voo, não no painel que pausa a simulação.

## Toque e arraste

O mapa principal aceita toque mantido com atualização contínua da direção/destino. A posição do dedo é convertida novamente após o deslocamento da câmera, permitindo continuar o voo enquanto ele fica pressionado. Movê-lo muda a rota imediatamente; soltá-lo conserva o último destino. Toque em NPC continua selecionando o alvo, sem iniciar movimento. O radar também aceita arrastar. Controles usam Pointer Events e captura do ponteiro; cancelar o toque, suspender ou abrir painel encerra o gesto. Joystick e teclado continuam disponíveis.

## Caixa de loot

Todo NPC deixa uma única caixa metálica original, independentemente do recurso contido. Sem rotação de minério no espaço. O conteúdo continua sendo o recurso correspondente ao NPC, com as mesmas quantidades, capacidade de porão, distância de coleta e pagamento único. Caixas já salvas passam a usar a nova aparência sem conversão/descarte de conteúdo.

A nova arte está em `art-source/lootbox.png`; o recorte técnico e o empacotamento de atlas estão em `tools/prepare-assets.py`. Arquivos individuais continuam disponíveis para UI/galeria. O atlas acrescenta bytes ao pacote estático, visando menos trocas de textura e requisições do renderizador; não se afirma que o download ficou menor.

## Preços iniciais para o próximo playtest

| Produto | Antes | Agora |
| --- | ---: | ---: |
| Emissor Lúmen I | 300 CR | 650 CR |
| Égide I | 280 CR | 600 CR |
| Impulsor Vetor I | 250 CR | 550 CR |
| Drone Sentinela | 450 CR | 1.100 CR |
| AUX Remendo | 550 CR | 1.300 CR |
| Albatroz | 1.800 CR | 4.200 CR |
| Bastião | 4.800 CR | 11.000 CR |
| Vésper | 11.000 CR | 28.000 CR |
| 600 pulsos | 60 CR | 110 CR |
| 200 íons | 180 CR | 360 CR |
| Kit de reparo | 90 CR | 200 CR |
| 100 íons por stellarium | 5 ST | 8 ST |

Demais equipamentos também subiram progressivamente; a tabela autoritativa está em `src/content/catalog.ts`. Valores de venda dos recursos e recompensas foram preservados. O saldo inicial continua em 380 CR. O total das quatro primeiras missões com o saldo inicial permite uma primeira melhoria sem uma concessão gratuita de dinheiro. Isso é um teste de acessibilidade econômica, não prova de campanha balanceada.

Compras novas registram o valor pago por instância. A revenda paga até 50% da aquisição; itens de saves antigos usam a tabela de preços anterior como referência. Assim o reajuste não transforma inventário antigo em um lucro artificial. Nada é removido das carteiras/configurações já existentes.

## Instalar a atualização

Use o novo `stellar-legacy-build.zip` no mesmo workflow e no mesmo domínio/caminho já usados. O banco IndexedDB e o schema 1 foram preservados; os campos novos são opcionais para compatibilidade com exports anteriores. A atualização do service worker não limpa o save. Com internet, feche todas as abas/PWA da versão anterior e reabra para ativar o cache novo. Depois confirme novamente o pacote offline em Save. Exportar um JSON antes de atualizar é uma cópia externa útil.

O kit de instalação inclui o workflow já fornecido, sem necessidade de mudar sua lógica. Ele continua limpando somente o checkout remoto e não acessa os dados locais de quem joga.

## Verificação

Resultados atuais serão registrados em `RESULTADOS_TESTES_0_2.md`. Teste físico Android e playtest prolongado continuam pendentes; nenhuma taxa de FPS em telefone foi certificada.

### Correção visual encontrada na regressão

NPC e drop usavam o mesmo ID no registro de sprites. Como o loot nasce na mesma atualização em que o NPC some, a imagem do inimigo podia permanecer no lugar do recurso. O registro visual agora separa `loot:<id>` do ID do NPC. O teste de combate exige que um abate real gere uma entidade com a textura da caixa antes de coletar.
