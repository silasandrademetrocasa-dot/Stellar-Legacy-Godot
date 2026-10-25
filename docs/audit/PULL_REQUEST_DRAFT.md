> Registro da proposta de PR anterior. A entrega atual, solicitada pelo
> proprietário, usa os ZIPs e o workflow existente; veja INSTALACAO_PARTES.md.

# Stellar Legacy — Correções Godot, Frota e Integração 3D

**Estado pretendido: Draft. Base: main. Head: codex/godot-fleet-audit-20261025.**
Publicação pendente de acesso GitHub: push e criação de branch via integração
retornaram HTTP 403 nesta sessão. Este arquivo é a descrição pronta, não um PR aberto.

## 1. Resumo das correções

Aurora e demais naves deixavam o casco atrasado em relação ao vetor de movimento
nas curvas fora do ataque. O movimento agora acompanha a frente +Z do casco;
strafe com mira/laser independente durante combate foi preservado. Escala/pivô
são ajustados pelos bounds reais de cada GLB e classe, com jatos nos motores e
origem de tiro no nariz. Spawn evita ficar escondido pelo portal central.

Relés HQ/LOD existentes agora aparecem no PvP e atendem aos botões antes ligados
a métodos ausentes. Evolução, captura, escudo/recuperação e perfis de qualidade
estão testados. Oito armas HQ recuperadas do ZIP da própria base chegam às
vitrines; conceitos seguem sem venda. Portais têm núcleo/anéis animados; NPCs têm
flash de ataque e explosões limitadas. Menus ocultos liberam modelos.

Estrelas passam de 4.224 para 80 triângulos por instância, mantendo as 720
posições/cores/tamanhos. Nenhum GLB, textura ou importador original foi modificado;
os 1.226 arquivos originais de assets foram comparados por hash.

## 2. Arquivos modificados

- `scripts/main.gd`: movimento, spawn, montagem de efeitos, relés e qualidade.
- `scripts/world/model_presentation.gd`, `ship_presentation.gd`,
  `portal_animation.gd`: apresentação não destrutiva e animação dos portais.
- `scripts/world/combat_world.gd`, `enemy_ship.gd`, `fleet_support.gd`,
  `astral_environment.gd`: efeitos e carregamento de suporte.
- `scripts/relays/relay_controller.gd`: LOD/perfis, evolução e recuperação.
- `scripts/ui/{stellar_hud,stellar_hangar_premium,stellar_store,equipment_command}.gd`:
  enquadramento, carga sob demanda e descarte de previews.
- `scripts/data/{weapon_art,equipment_catalog,store_catalog}.gd`:
  referências visuais HQ; metadados comerciais existentes preservados.
- `assets/weapons/`, `assets/ui/g022_textured/`: oito GLBs, oito miniaturas e
  texturas/importadores gerados pelo Godot. Originais extraídos do ZIP local com
  hashes em `docs/audit/integrated-assets.json`; nenhum pacote externo presumido.
- `shaders/{portal_energy,combat_burst}.gdshader`: efeitos Compatibility.
- `tests/`, `tools/`, `.github/workflows/godot-validation.yml`:
  regressões, auditoria estrutural, runner com timeout e CI somente leitura.
- `README.md`, `docs/audit/`: evidências, manifestos e roteiro Android.

Nenhum script/cena/recurso aprovado foi apagado. O instalador ZIP antigo não foi
executado nem alterado. A remoção externa do ZIP em `main` foi respeitada via
rebase da branch; nenhuma escrita na principal foi realizada pelo Codex.

## 3. Resultados dos testes

Godot **4.5.2** real no Codex Cloud, Compatibility. **46 comandos**, todos passaram:
importação, parsing individual de 36 scripts, inicialização principal/demo e cinco
suítes com **16.921 verificações, zero falhas**. Os **147 GLBs** foram importados e
instanciados com materiais. Sete cenários também renderizados em OpenGL/Mesa
llvmpipe, sem erros de shader. Um aviso do driver sobre V-Sync ficou registrado.

Mesma cena/câmera antes da correção de spawn: **3.093.260 → 109.580 primitivas**
no viewport principal (−96,46%), 158 draw calls em ambos. Medição desktop por
software, por viewport; não é FPS nem estimativa de desempenho Android.

Detalhes em `docs/audit/TESTES-E-ENTREGA.md` e `validation-results.json`.
CI remoto ainda não executado enquanto a publicação estiver bloqueada.

## 4. Problemas pendentes

Comparação com artes V3, custos de superfícies de AUX/boxes/minérios/relés,
hardpoints artísticos individuais de equipamentos, clips de animação ausentes,
exportação/assinatura APK e QA em aparelho. Mísseis em voo mantêm a representação
demonstrativa prévia. Não foi instalada a atualização inteira G0.22.1 nem feita
refatoração de balanceamento/economia/saves.

## 5. Assets que precisam de confirmação/envio

Os 13 GLBs existem e foram preservados. Para certificar geração/fidelidade V3,
fornecer originais ou hashes confirmados e artes aprovadas de Aurora, Pioneer,
Raptor, Meridian, Bastion, Lynx, Phantom, Pathfinder, Kensei, Valkyrie, Leviathan,
Seraph e Bulwark. As dimensões coincidem com o helper rotulado V3 no pacote local,
mas o manifesto V2 antigo não corresponde aos hashes atuais. Nenhum substituto
foi fabricado nem foi presumido acesso a anexos de outra conversa.

## 6. Riscos e impactos Android

Menos geometria decorativa, FX limitados, menos carga/retensão HQ e LOD nos relés
BAIXO/MÉDIO; ALTO usa HQ. Materiais/texturas originais mantidos. O primeiro import
pode demorar. As armas recuperadas ocupam cerca de 23 MiB com texturas extraídas e
são carregadas por seleção. Muitas superfícies ainda exigem perfil em aparelho.
FPS, memória de GPU, temperatura e exportação Android não foram medidos/testados.

## 7. Como testar pelo celular

Baixar o projeto completo da branch após publicação, extrair em pasta de teste e
importar `project.godot` no Godot 4.5.2 Android/Compatibility. Executar
`scenes/main.tscn`: navegar Aurora em quatro direções; atacar NPC e definir nova
rota mantendo laser/alvo; conferir 13 previews no Hangar, oito armas na Loja,
coleta, suporte equipado e CONF 1/2. No PvP, capturar por 12s, testar escudo e
LV1→LV3 em CENTRAL > RELÉS; comparar BAIXO/MÉDIO/ALTO e persistência após reiniciar.

Roteiro detalhado: `docs/audit/TESTES-E-ENTREGA.md`.
Não executar o instalador ZIP que escreve em `main` para revisar este Draft.
**Sem merge até aprovação explícita do proprietário.**
