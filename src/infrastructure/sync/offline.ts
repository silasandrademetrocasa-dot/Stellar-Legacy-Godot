/** Future online authority port. Lab balances are never sent as competitive balances. */
export interface SyncOperation{opId:string;type:string;payload:unknown;labOnly:true;revision:number}
export interface SyncReceipt{opId:string;accepted:boolean;serverRevision?:number}
export interface SyncAdapter{readonly enabled:boolean;flush(operations:readonly SyncOperation[]):Promise<SyncReceipt[]>}
export class OfflineAdapter implements SyncAdapter{readonly enabled=false;async flush(_operations:readonly SyncOperation[]){return [];}}
