# Stellar Legacy G0.20 — NAVES V2 HQ DEFINITIVAS

Base: G0.19 Escudos HQ. Não mistura com o repositório web.

## O que mudou
- 13 modelos V2 HQ de Aurora, Pioneer, Raptor, Meridian, Bastion, Lynx, Phantom, Pathfinder, Kensei, Valkyrie, Leviathan, Seraph e Bulwark, substituindo os GLBs protótipos no caminho esperado pelo jogo.
- Meshes e texturas GLB originais preservados: foram corrigidas apenas a escala e a orientação do nó raiz, sem redução de polígonos, materiais ou texturas.
- Novas prévias de naves geradas a partir dos próprios modelos V2 para Hangar e Loja.
- Regras, saldo, equipamentos, desbloqueios e atributos não foram alterados.

## Instalação GitHub Actions (duas etapas obrigatórias)
**1.** Remova qualquer ZIP antigo da raiz do repositório. Envie `StellarLegacy_Godot_G0.20_NAVES_V2_PARTE_1.zip`. Execute o workflow `Stellar Legacy Godot - Instalador ZIP` e confira a validação verde.
**2.** Após a etapa 1 aprovada e publicada no repositório, envie `StellarLegacy_Godot_G0.20_NAVES_V2_PARTE_2.zip`. Execute o MESMO workflow e aguarde validação verde.
**3.** Só depois teste no Godot Android. Não envie ambos os ZIPs de uma vez: o instalador exige exatamente um ZIP na raiz por execução.

Obs: o Godot pode demorar mais para importar os modelos V2 pela primeira vez, pois têm dezenas de milhares de faces e texturas HD.

Um projeto completo independente também foi fornecido para importação direta no editor Android (não envie o ZIP completo pela interface web do GitHub).
