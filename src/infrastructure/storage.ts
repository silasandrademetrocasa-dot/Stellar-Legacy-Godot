import {openDB,type IDBPDatabase} from 'idb';
import {digest,initialState,reduce,verified,type Command,type State} from '../core/game';
export class Repository{
 db!:IDBPDatabase; state!:State;busy=false;readOnly=false;lastGood!:State;pendingCount=0;lastSaveMs=0;private queue:Promise<unknown>=Promise.resolve();
 async open(){
  this.db=await openDB('stellar-legacy',1,{upgrade(db){db.createObjectStore('game_state');db.createObjectStore('event_journal');db.createObjectStore('snapshots');db.createObjectStore('metadata');db.createObjectStore('sync_outbox');}});
  const old=await this.db.get('game_state','pilot');
  if(old){this.state=await verified(old);}else{this.state=initialState();this.state.hash=await digest(this.state);const tx=this.db.transaction('game_state','readwrite');if(await tx.store.get('pilot')){await tx.done;this.state=await verified(await this.db.get('game_state','pilot'));}else{await tx.store.put(this.state,'pilot');await tx.done;}}
  this.lastGood=structuredClone(this.state);
  if(navigator.locks){let release:()=>void=()=>{};const ready=new Promise<void>(resolve=>{navigator.locks.request('stellar-pilot-writer',{ifAvailable:true},async lock=>{if(!lock)this.readOnly=true;resolve();if(lock)await new Promise<void>(r=>release=r);});});await ready;window.addEventListener('pagehide',()=>release(),{once:true});}
  if(!this.readOnly&&!this.state.lab)await this.command({id:crypto.randomUUID(),type:'MIGRATE_LAB'});if(!this.readOnly){const pending=(await this.db.getAll('event_journal')).filter(op=>op.status==='pending').sort((a,b)=>a.createdAt-b.createdAt);for(const op of pending){try{await this.command({id:op.id,type:op.type,payload:op.payload});}catch{/* failed recovery is recorded; active state is preserved */}}}
  return this.state;
 }
 command(c:Command):Promise<State>{
  this.pendingCount++;const createdAt=Date.now();c={...c,payload:{...c.payload,now:c.payload?.now??createdAt}};
  const operation=this.queue.then(async()=>{if(!this.readOnly&&c.type!=='CHECKPOINT'){const tx=this.db.transaction('event_journal','readwrite'),old=await tx.store.get(c.id);if(!old||['failed','pending'].includes(old.status))await tx.store.put({id:c.id,type:c.type,payload:c.payload,status:'pending',createdAt,revisionBefore:this.state.revision,labOnly:true},c.id);await tx.done;}return this.execute(c,createdAt);});
  this.queue=operation.catch(()=>{}).finally(()=>{this.pendingCount--;});return operation;
 }
 private async execute(c:Command,createdAt:number){
  if(this.readOnly)throw Error('Outra aba está pilotando. Feche-a e recarregue esta sessão.');
  if(this.busy)throw Error('Operação de importação em andamento');this.busy=true;const started=performance.now();
  try{
   const revision=this.state.revision;const candidate=reduce(this.state,c);candidate.hash=await digest(candidate);
   const tx=this.db.transaction(['game_state','event_journal','snapshots','sync_outbox'],'readwrite');
   const current:State=await tx.objectStore('game_state').get('pilot');
   if(current.revision!==revision){tx.abort();await tx.done.catch(()=>{});this.readOnly=true;throw Error('Conflito de revisão entre sessões. Exporte sua sessão e recarregue.');}
   const previous=c.type!=='CHECKPOINT'?await tx.objectStore('event_journal').get(c.id):null;if(previous&&previous.status!=='pending'&&previous.status!=='failed'){await tx.done;this.state=await verified(current);return this.state;}
   if(candidate.revision===revision){await tx.done;return this.state;}
   await tx.objectStore('game_state').put(candidate,'pilot');
   await tx.objectStore('event_journal').put({id:c.id,type:c.type,payload:c.payload||{},status:'committed',createdAt,labOnly:true,revisionBefore:revision,revisionAfter:candidate.revision,revision:candidate.revision,result:{ok:true},date:candidate.updatedAt},c.type==='CHECKPOINT'?'latest-checkpoint':c.id);
   if(c.type!=='CHECKPOINT'||candidate.revision%10===0)await tx.objectStore('snapshots').put(current,['A','B','C'][candidate.revision%3]);
   if(c.type!=='CHECKPOINT')await tx.objectStore('sync_outbox').put({opId:c.id,type:c.type,payload:c.payload||{},revision:candidate.revision,labOnly:true,status:'committed',sync:'disabled'},c.id);
   await tx.done;this.lastGood=structuredClone(candidate);
   const live=this.state.world;if(!['TRAVEL','RESPAWN','ARENA_START'].includes(c.type)&&live.sector===candidate.world.sector){candidate.world.x=live.x;candidate.world.y=live.y;candidate.world.heading=live.heading;}
   this.state=candidate;return candidate;
  }catch(error){const live=this.state.world;this.state=structuredClone(this.lastGood);if(live.sector===this.state.world.sector){this.state.world.x=live.x;this.state.world.y=live.y;this.state.world.heading=live.heading;}if(c.type!=='CHECKPOINT'){try{const tx=this.db.transaction('event_journal','readwrite'),old=await tx.store.get(c.id);if(!old||old.status!=='committed')await tx.store.put({id:c.id,type:c.type,payload:c.payload,status:'failed',labOnly:true,createdAt,revisionBefore:this.state.revision,revisionAfter:this.state.revision,result:{ok:false,error:String(error).slice(0,240)}},c.id);await tx.done;}catch{}}throw error;}finally{this.busy=false;this.lastSaveMs=performance.now()-started;}
 }
 async backups(){const result:{key:string;state:State}[]=[];for(const key of ['A','B','C']){const s=await this.db.get('snapshots',key);if(s)try{await verified(s);result.push({key,state:s});}catch{/* preserve damaged backup for diagnosis */}}return result.sort((a,b)=>b.state.revision-a.state.revision);}
 async inspectImport(file:File){if(file.size>8_000_000)throw Error('Arquivo excede 8 MB');return verified(JSON.parse(await file.text()));}
 async replace(incoming:State){
  await this.queue;
  if(this.readOnly||this.busy)throw Error('Sessão ocupada ou somente leitura');this.busy=true;
  try{await verified(incoming);const current=await this.db.get('game_state','pilot');const next=structuredClone(incoming);next.revision=(current?.revision||0)+1;next.updatedAt=new Date().toISOString();next.hash=await digest(next);
   const tx=this.db.transaction(['game_state','snapshots','event_journal'],'readwrite');const actual=await tx.objectStore('game_state').get('pilot');if(actual?.revision!==current?.revision){tx.abort();await tx.done.catch(()=>{});throw Error('Outra sessão alterou o save. Recarregue.');}
   if(current)await tx.objectStore('snapshots').put(current,'before-import');await tx.objectStore('game_state').put(next,'pilot');await tx.objectStore('event_journal').put({type:'RESTORE',revision:next.revision},crypto.randomUUID());await tx.done;this.state=next;this.lastGood=structuredClone(next);
  }finally{this.busy=false;}
  if(!this.state.lab)await this.command({id:crypto.randomUUID(),type:'MIGRATE_LAB'});
 }
 export(){const data=JSON.stringify(this.lastGood,null,2),url=URL.createObjectURL(new Blob([data],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download=`stellar-legacy-r${this.lastGood.revision}.json`;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
}
