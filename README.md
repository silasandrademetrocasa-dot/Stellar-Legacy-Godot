# Stellar Legacy Godot G0.13 — Commerce & Equipment Rebuild

Cliente experimental Android offline, totalmente separado do jogo web.

## Destaques da G0.13
- **Loja premium** com menu por categorias, cartões com raridade e preço, nave ativa em vitrine GLB e preview 3D do produto selecionado.
- **Gerenciamento de equipamentos** em três colunas: nave original, slots equipados e inventário em quadradinhos. Ícones congelados criados a partir das malhas GLB locais; preview 3D rotativo por seleção.
- **Compras de teste funcionais** para naves, lasers, escudos, motores, extras, drones e AUX-9.
- **Kit inicial único:** Aurora + ARC-1 + SG-1 + THR-1 + Reparador Comum. Nenhum drone ou AUX. O restante precisa ser comprado.
- **Migração única** do estoque antigo, com backup local automático; não reinicia inventário a cada abertura.
- Sem rebaixar modelos GLB de naves, NPCs, drones ou AUX e sem tocar nos servidores web de produção.

## Como importar
Use a opção **Importar projeto ZIP** do editor Godot Android com `StellarLegacy_Godot_G0.13_COMPLETO.zip`. Para atualizar o GitHub via instalador ZIP, envie **somente** `StellarLegacy_Godot_G0.13_ATUALIZACAO.zip` ao repositório e execute o workflow. Verifique os logs e teste no aparelho.

Mais detalhes e roteiro de teste: `docs/G013_COMERCIO_E_INVENTARIO.md`.

**Importante:** esta versão é um protótipo offline. Créditos, compras, estoque, naves e permissões persistem somente no dispositivo; não são propriedade validada por servidor nem pagamentos reais.
