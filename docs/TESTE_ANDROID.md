# Android/PWA · escopo desta entrega

Testes automáticos usam Chromium Linux com viewport touch 915×412 e eventos de toque CDP. Validam espaço dos menus, joystick/arraste, presets/FPS, armazenamento e reabertura sem rede. Isso não certifica um aparelho Android físico, consumo de bateria, pressão de memória ou encerramento forçado do sistema operacional. Não foi produzido/testado APK nativo.

Para uso no Chrome Android, publicar o build completo em HTTPS, abrir, usar Save → Baixar jogo completo para offline, aguardar Cache completo e instalar pelo menu do Chrome. Testes locais no PC usam localhost, permitido para Service Worker. file:// não funciona para PWA. Exportar JSON antes de trocar domínio, limpar armazenamento ou atualizar manualmente.

Baixo limita 30 FPS com efeitos mínimos/LOD2; Médio limita 30 com efeitos moderados/LOD1; Alto limita 60 com arte integral/LOD0. O modo adaptativo reduz LOD/efeitos após quedas prolongadas. Medições reais do ambiente disponível: `RESULTADOS_GDD.md`. O alvo de 30 FPS em aparelho de referência ainda precisa de homologação física.

Após a entrega final, homologação física deve observar voo em círculos/ziguezague/inversão, combate com boss/drones/AUX, painéis, Autopilot, cache offline, rotação/retomada, exportação/importação e perda de visibilidade. Nenhuma aprovação intermediária do usuário foi necessária para desenvolver o release.
