# Validação e teste no celular

Branch: `codex/godot-fleet-audit-20261025`. Revisão da base mista G0.20/G0.22;
identificadores históricos do projeto/HUD preservados. Validado com
**Godot 4.5.2.stable.official.6ce3de25a**, Compatibility.

## Resultados executados

| Verificação | Resultado final |
|---|---|
| Estrutura GLB, imagens, materiais/referências e caminhos literais | 147 GLBs válidos; nenhum caminho ausente |
| Hashes de naves e dos recursos recuperados | Iguais às fontes registradas |
| Importação Godot headless | Passou, código 0, sem erros |
| Parsing individual | 30 scripts do jogo + 6 scripts de teste passaram |
| Inicialização principal e demo dos relés | Ambas passaram, 120 frames cada |
| Aurora: curvas, spawn, cockpit, motores, tiro/strafe | 338 verificações, zero falhas |
| Frota: 13 modelos, proporções, materiais, navegação e vitrines | 8.000 verificações, zero falhas |
| Importação/instanciação dos assets e catálogos | 8.496 verificações, zero falhas |
| Relés: estados, níveis salvos, LOD, recovery e troca de mapa | 42 verificações, zero falhas |
| Portais, ataque NPC e pool de explosão | 45 verificações, zero falhas |
| Compatibility com janela real | Sete cenários renderizados; sem erros de shader |
| Android físico / APK / FPS Android | Não executados; sem dispositivo/presets de exportação |

Total: **46 comandos de validação**, **16.921 verificações de regressão**,
nenhuma falha final. Resultado por comando e tempo real de execução em
[validation-results.json](validation-results.json). O runner falha com erro de log
mesmo se o Godot retornar código 0, e impõe timeout. Saves de testes ficam em
`XDG_DATA_HOME` temporário separado por comando.

Falhas intermediárias resolvidas: o teste de assets assumiu que os três conceitos
de arma já existiam na loja; foram incorporados apenas para exposição conforme o
ZIP. O teste dos relés detectou callback capturando nó destruído após trocar mapa;
foi substituído por lookup de instance ID. O primeiro script de captura usou
assinatura errada de `Viewport.get_render_info`; corrigida para a API 4.5.2.
Nenhum desses erros ficou na rodada final.

### Renderização e geometria

Ambiente: Linux/Xorg dummy, **Mesa llvmpipe 25.0.7, OpenGL 4.5**, driver de áudio
Dummy. Foi usado o renderizador Compatibility real, não o renderizador dummy do
headless. Único aviso nessa rodada: driver sem suporte à alteração de V-Sync.

Cenários: Aurora no mapa/hangar, arma HQ na loja, relé em combate/escudo quebrado/
evolução e portal astral. Capturas e logs são gerados pelo runner com `--render`.
Não é um benchmark de FPS; o HUD de uma captura não serve como medição.

| Mesma posição/câmera antes da mudança de spawn | Antes da otimização | Depois |
|---|---:|---:|
| Primitivas no viewport principal | 3.093.260 | 109.580 |
| Draw calls no viewport principal | 158 | 158 |
| Triângulos por estrela | 4.224 | 80 |
| Instâncias de estrelas | 720 | 720 |

Redução observada de primitivas: **96,46%**. Depois da mudança de spawn, a rodada
final registrou 111.696 primitivas / 342 draw calls no viewport principal, pois a
câmera passou a ver outros objetos da base. Métricas são **por viewport**; não
somam as vitrines em SubViewports, não equivalem ao custo de GPU e não são dados
Android. A quantidade de superfícies de AUX, relés e coleta ainda merece perfil
em aparelho. Texturas e GLBs HQ originais foram preservados.

## Reproduzir no Cloud / PC Linux

```bash
python3 tools/audit_assets.py --output /tmp/stellar-assets.json
python3 tools/validate_godot.py --godot /caminho/Godot_v4.5.2-stable_linux.x86_64 --logs /tmp/stellar-validation
```

Com display X11 configurado, acrescentar `--render`. A versão de Godot é checada
antes da suíte. O workflow adicional de CI de PR foi preparado no workspace, mas
não vai nos ZIPs porque o instalador rejeita `.github/`. Para esta entrega use o
workflow **Stellar Legacy Godot - Instalador ZIP** que já existe no repositório.

## Testar pelo celular

1. [Instale as duas partes na ordem indicada](INSTALACAO_PARTES.md). Depois de ambas
   concluírem em verde, [baixe o projeto atualizado](https://github.com/silasandrademetrocasa-dot/Stellar-Legacy-Godot/archive/refs/heads/main.zip).
   Extraia em pasta de teste e importe `project.godot` no editor **Godot 4.5.2 para
   Android**, com Compatibility. Aguarde a primeira importação.
2. Execute `scenes/main.tscn`. Em perfil novo, Aurora deve aparecer fora do portal
   central. Toque/arraste em quatro direções e observe nariz e trajetória durante
   as curvas, altura e propulsores atrás do casco.
3. Dê dois toques em um NPC e depois defina outro destino no cenário ou minimapa.
   Laser/alvo devem continuar; o casco pode mirar em uma direção e transladar em
   outra durante o ataque. Observe flash NPC, impactos e explosão.
4. Abra HANGAR, arraste o modelo e percorra as 13 miniaturas. Cockpit/asas/motores
   devem ficar completos e sem cortes. Naves não adquiridas permanecem bloqueadas.
   Compare também Loja e Equipamentos e abra/feche os menus repetidamente.
5. Na Loja, visualize ARC-1/2/3/4/P1 e os três conceitos. As oito armas HQ devem
   mostrar texturas; ARC-Q/VORTEX-X/CATACLISMO não têm compra habilitada.
6. Viaje fisicamente ao PvP 4-X e fique no centro por 12 segundos para capturar.
   Em CENTRAL > RELÉS, teste escudo e evolução de nível junto ao relé. Compare
   BAIXO/MÉDIO/ALTO: LOD nos dois primeiros, HQ no último; partículas desligadas em
   BAIXO. Repetir evolução durante a animação deve pedir que aguarde.
7. Observe núcleos/anéis dos portais, equipe drones/AUX que possuir e confira
   suporte, coleta e porão. Troque CONF 1/2 e feche/reabra o jogo para verificar
   persistência. Não remova saves pessoais para testar.
8. Registre aparelho/GPU, versão Godot, perfil gráfico, mapa e ações quando houver
   problema. FPS, memória e temperatura precisam ser observados no próprio aparelho.

## Assets pendentes e riscos

Os 13 GLBs de naves existem e não foram substituídos. A identificação V3 e a
fidelidade às artes ainda dependem dos originais/hashes confirmados e das artes
aprovadas para Aurora, Pioneer, Raptor, Meridian, Bastion, Lynx, Phantom,
Pathfinder, Kensei, Valkyrie, Leviathan, Seraph e Bulwark.

Armas HQ adicionais ocupam aproximadamente 23 MiB na pasta com texturas extraídas;
só o modelo selecionado é carregado na vitrine. A primeira importação pode demorar.
AUX/boxes/minérios e relés ainda têm muitas superfícies. Não foram criados LODs
artísticos novos nem export Android assinado. A suite não garante FPS ou memória
em qualquer celular. Não há integração ou alteração de produção.

O workflow de PR não foi executado no GitHub e não é incluído nos ZIPs. Os resultados acima são da execução real
no Codex Cloud. Nenhum link de PR foi criado ou presumido.
