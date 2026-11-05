# Porta de sincronização futura

O adapter de sincronização está explicitamente desativado. Sem integração ou dependência de servidor para jogar. `sync_outbox` guarda recibos locais `labOnly=true`, com sincronização disabled, no mesmo commit do estado. Nada é enviado.

Antes de uma futura implementação online, definir autoridade do servidor, identidade de conta, reconciliação do catálogo, conflito de revisões e política para saldos sandbox. Hash local detecta corrupção, não prova legitimidade. Nenhum saldo, posse ou recibo labOnly pode virar moeda competitiva automaticamente. Manter exportação JSON e modo offline mesmo quando existir adapter.
