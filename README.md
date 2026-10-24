# Stellar Legacy Godot G0.7 — Progresso do Piloto (offline)

Cliente 3D Android experimental. Mantém rotas X/4/U, HUD/hangar/loja 3D, controle por arraste, combate em movimento, AUX-9, drones e equipamentos CONF 1/CONF 2 da G0.6.

## Novidades G0.7
- Menu **PILOTO**: XP, nível, créditos demonstrativos, missões, eliminações e caixas coletadas.
- Coleta de caixas no mundo: aproximar a nave ou tocar na caixa para navegar até ela.
- Mini mapa indica caixas em amarelo.
- Recompensas e missões estritamente **offline/de teste**, salvas em `user://stellar_g07_pilot_offline.json`.
- A progressão usa nível 1→2 = 10.000 XP, 2→3 = 20.000 XP etc.

## Instalação
Envie somente o ZIP `StellarLegacy_Godot_G0.7_ATUALIZACAO.zip` à raiz do GitHub, sem extrair, remova outros ZIPs de instalação da raiz e execute `Actions > Instalador Godot > Run workflow`. Depois sincronize o projeto no editor Android. O `StellarLegacy_Godot_G0.7_COMPLETO.zip` é para importar um projeto independente.

## Isolamento
Não chama Render, Supabase ou o banco antigo, nem autentica. Creditos e XP são simulados e NÃO devem ser reutilizados como fonte de autoridade de servidor. O jogo web/iPhone continua inalterado.

Consulte `docs/G07_TESTES_E_PLANO_BACKEND.md` para testes, riscos e futuro staging.
