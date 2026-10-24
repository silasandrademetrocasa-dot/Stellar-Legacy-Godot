# Stellar Legacy Godot G0.8 — Central Estelar & Relés 4-X

**Cliente Android 3D experimental, OFFLINE.** O jogo WEB/iPhone, seus jogadores, Render e Supabase de produção seguem inalterados.

## Funcionalidades novas
- PILOTO: apelido local, facção e estatísticas da G0.7.
- CENTRAL: Alianças, Relés PvP 4-X, Missões, Passe gratuito, Mercado, Leilão, Premium e planejamento ADM.
- Relés 3D nos mapas 4-1 / 4-2 / 4-3: domínio demonstrativo em 12 segundos junto ao núcleo; facção muda a cor do relé e estado fica salvo no dispositivo.
- Missões e passe: objetivos locais com recompensas de teste resgatáveis.
- Mercado de colecionáveis de demonstração: operações offline apenas.
- Leilão: simulação de propostas; loja premium informativa e ADM somente leitura.
- **Não implementa Arena, PvP online, pagamentos ou permissões administrativas reais.**

## Funcionalidades preservadas
Navegação por toque/arraste, ataque em movimento, mapas X/4/U, portais, NPCs, modelos GLB, vitrine 3D, drones, AUX-9, equipamentos e duas configurações G0.6, progressão e caixas da G0.7.

## Instalação pelo celular
1. Use apenas `StellarLegacy_Godot_G0.8_ATUALIZACAO.zip` no instalador universal do GitHub, **sobre a G0.7 aprovada**.
2. Remova outros ZIPs antigos da raiz e execute Actions > Instalador Godot > Run workflow.
3. Depois de validado, baixe o projeto do GitHub e importe no editor Godot Android.
4. Para projeto novo independente, importe `StellarLegacy_Godot_G0.8_COMPLETO.zip`.

## Documentação
`docs/G08_CENTRAL_E_RELES.md` contém o escopo real, as limitações e 12 testes recomendados. `docs/G08_ARQUITETURA_BANCO_NOVO.md` descreve o futuro backend seguro e isolado — **não foi executado**.

---

## Histórico G0.7
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
