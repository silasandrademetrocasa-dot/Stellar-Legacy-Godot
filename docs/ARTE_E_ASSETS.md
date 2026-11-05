# Artes originais e pipeline · 1.0.0

As fontes raster originais geradas para este projeto estão em `art-source`, com as novas folhas em `art-source/canonical`: ships-a/b/c, npcs-a/b/c, maps, directions, designers, protocols, drone-designers e stations. Foram geradas com OpenAI Image Generation para esta entrega; sem assets de DarkOrbit ou pacote comercial externo.

O pipeline Pillow somente recorta células, aplica transparência técnica ao fundo, redimensiona e comprime WebP. Não pinta naves, NPCs ou efeitos com primitivas. `tools/prepare-canonical-assets.py` gera 43 naves, 34 NPCs, 14 mapas, oito frames frontais da Aurora, designers, quinze ícones de protocolo e estações de facção. LODs 256/192/128 para ships/NPCs e 768/512/384 para mapas. Fonte e assets finais já acompanham a entrega; não é necessário reprocessar para jogar/compilar.

A vista frontal é definida pela câmera: a ponta frontal pode apontar para a parte inferior da tela. Inverter o movimento não troca para um sprite de traseira. Outras classes usam sua arte frontal própria e bank limitado. Designers de nave são específicos para Aurora/Pioneer; os demais não usam uma skin incompatível. Os NPCs FUTURO utilizam fallback raster da família, permanecendo explicitamente futuros/bloqueados.

A cena usa somente DIVs com sprites raster, atlas de efeitos original, caixa única de loot e portal/relé raster. O atlas legado foi reduzido aos onze elementos ainda usados; os PNGs isolados de naves/NPCs substituídos foram retirados. UI e galeria permitem inspecionar os arquivos finais. `npm run check:assets` valida presença, IDs, assinaturas/dimensões PNG e registra `docs/ASSET_REPORT.json`.

Áudio sintetizado original permanece no projeto. Sem dependência externa durante o jogo offline.
