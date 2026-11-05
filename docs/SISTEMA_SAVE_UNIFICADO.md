# Save único · 1.0.0

Banco existente `stellar-legacy`, versão IndexedDB 1, stores `game_state`, `event_journal`, `snapshots`, `metadata`, `sync_outbox`. A única autoridade local é `game_state/pilot`. Nenhum menu mantém moeda ou inventário próprio em storage.

`contentVersion=gdd-1.0` e `lab.version=1` adicionam os sistemas sem remover campos antigos. Ao abrir, primeiro valida invariantes e SHA-256 do save original, depois executa migração idempotente. HP e escudo antigos são convertidos proporcionalmente aos atributos canônicos; IDs, carteira, equipamentos, carga, posição e missões são preservados. O tipo do boss antigo é mapeado para Apex Overlord; drone legado vira instância com slots.

Comandos entram em Promise queue serial; `pending` é durável antes da execução. O reducer clona o estado, valida regras e invariantes, incrementa revisão e calcula hash fora da transação IndexedDB. O commit verifica a revisão anterior e grava estado, operação committed, snapshot rotativo A/B/C e recibo labOnly na outbox atomicamente. Falhas registram failed e restauram o último estado íntegro. Pending é recuperado ao reabrir. ID confirmado não paga novamente. Quota, hash corrompido ou conflito de escritor não produzem reset silencioso.

Web Locks admite um escritor por perfil; checagem de revisão protege a transação quando Web Locks não está disponível. `CHECKPOINT` periódico não interrompe o movimento; posições correntes são incorporadas aos comandos comuns. Viagem/respawn/Arena substituem posição intencionalmente.

JSON exportado representa o último commit íntegro. Importação tem limite de tamanho, hash/invariantes, prévia, confirmação e cópia before-import. Migração também ocorre quando um save antigo é importado. Restauração exige verificação e revisão monotônica. Limpar dados, modo anônimo, domínio/caminho diferente e remoção pelo sistema operacional podem perder IndexedDB; exportação externa é indispensável.

Farm reserva munição do tipo selecionado, duração máxima 8h e recompensas por snapshot. Retorna munição não usada ao mesmo tipo. O recibo claimed impede pagamento duplicado; não depende de manter timers ativos nem de uma data diária fixa.

Testes cobrem 100 compras concorrentes, dez reaberturas, recuperação pending, falha quota, corrupção, escritor obsoleto, idempotência, backups, importação, oito horas e passagem pela meia-noite. Não foi testado encerramento de APK nativo, pois não há APK nesta entrega.
