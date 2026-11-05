# Entrega final · Stellar Legacy Offline 1.0.0

Todas as partes são obrigatórias e pertencem ao mesmo release. Consulte `release-manifest.json`, entregue ao lado dos ZIPs, para ordem, nomes, bytes e SHA-256 das partes e de cada arquivo, com sua parte de origem. Cada ZIP é normal, independente, abaixo de 24.000.000 bytes e contém caminhos finais sem duplicatas entre partes.

O conjunto contém raiz pré-compilada pronta para Pages, fonte completa, assets finais, artes originais, dados, PWA/Service Worker, workflow, scripts, testes e documentação. Não contém node_modules, caches, bancos privados, vídeos ou volumes ZIP binários.

Montagem: todas as partes em uma branch/pasta de preparação, nunca publicação parcial. O instalador só começa a substituir arquivos após verificar todo o conjunto. Recriar dependências com Node 22 e `npm ci`; nenhuma geração manual de imagem é necessária. Leia `README.md` para comandos e instalação em repositório antigo. Não se presumiu a capacidade de merge de um Instalador Universal externo.

Validação registrada em `docs/RESULTADOS_GDD.md`; o manifesto externo registra também a revisão de código e a execução de reconstrução. As medições são de Chromium Linux, sem alegação de teste em Android físico ou APK. Os modos sociais são simulações locais.
