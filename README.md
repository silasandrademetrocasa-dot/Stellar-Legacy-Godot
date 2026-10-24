# Stellar Legacy Godot — G0.6

Cliente experimental offline para Android com suporte a migração futura para desktop/iOS. **A versão Web/iPhone do Stellar Legacy permanece totalmente separada.**

## O que há na versão

- Navegação X-1 a X-8 / U-1 a U-3 / 4-X e portais 3D
- Toque e arraste no cenário e minimapa para reposicionamento contínuo
- Ataque automático independente da navegação e mira orientada ao alvo
- HUD superior, minimapa, munições e modais
- Hangar/Loja com vitrine 3D, plataforma e modelos carregados localmente
- Equipamentos experimentais: 12 GLBs, slots locais e CONF 1/CONF 2
- NPCs e drones locais, efeitos e drops demonstrativos

## Instalar

Para primeiro acesso, importe o ZIP **completo** usando o Godot Android.
Para GitHub, envie o ZIP **incremental G0.6** como o único ZIP da raiz e execute o workflow já existente `Stellar Legacy Godot - Instalador ZIP`. O workflow valida a importação antes de publicar. Extraia/importe o projeto atualizado no Godot Android para jogar a nova versão.

## Segurança

Nenhum acesso ao Render/Supabase, login, SQL ou economia de produção. Alterações da G0.6 são somente do cliente Godot e de salvamentos locais `user://`. Veja `docs/G0.6-TACTICAL-HANGAR-EQUIPMENT.md` para as mudanças e testes.
