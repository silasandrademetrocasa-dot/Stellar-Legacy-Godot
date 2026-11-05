import './presentation/style.css';
import {Repository} from './infrastructure/storage';
import {Sound} from './infrastructure/audio';
import {registerOffline} from './infrastructure/offline';
import {Flight} from './presentation/flight';
import {UI} from './presentation/ui';
import {uid,type Command} from './core/game';
async function boot(){
 const repo=new Repository();let ui:UI|undefined;
 try{await repo.open();}catch(error){
  document.getElementById('app')!.innerHTML='<main style="padding:40px;max-width:800px"><h1>Memória de bordo requer recuperação</h1><p id="error"></p><div id="recovery"></div><p>O save ativo foi preservado. Nenhum progresso foi reiniciado.</p></main>';
  document.getElementById('error')!.textContent=String(error);
  if(repo.db){for(const b of await repo.backups()){const btn=document.createElement('button');btn.textContent=`Restaurar ${b.key} · revisão ${b.state.revision}`;btn.onclick=async()=>{if(confirm('Restaurar este backup?')){await repo.replace(b.state);location.reload();}};document.getElementById('recovery')!.append(btn);}
  const input=document.createElement('input');input.type='file';input.accept='.json';input.onchange=async()=>{try{if(input.files?.[0]){const state=await repo.inspectImport(input.files[0]);if(confirm(`Importar revisão ${state.revision}?`)){await repo.replace(state);location.reload();}}}catch(e){document.getElementById('error')!.textContent=String(e);}};document.getElementById('recovery')!.append(input);}return;
 }
 const sound=new Sound();let flight:Flight;
 const command=async(c:Command)=>{try{if(flight&&c.type==='TRAVEL')await flight.prepareSector(Number(c.payload?.sector));if(flight&&c.type==='SHIP')await flight.prepareShip(String(c.payload?.id));await repo.command(c);sound.set(repo.state.settings.sound,repo.state.settings.music);document.documentElement.dataset.graphics=repo.state.settings.graphics;if(c.type!=='CHECKPOINT')sound.play('ui');if(repo.state.lab?.settings.haptics&&['KILL','LOOT','BUY_CATALOG','CLAIM'].includes(c.type))navigator.vibrate?.(12);if(flight)flight.applyGraphics();return true;}catch(error){ui?.toast(String(error instanceof Error?error.message:error));return false;}};
 document.getElementById('app')!.innerHTML=`<main id="flight"></main><div id="overlay"></div><div id="loading"><img src="${import.meta.env.BASE_URL}assets/icons/icon-192.png" alt="" width="96" height="96">STELLAR LEGACY<br><small>Sincronizando mapas e texturas…</small></div>`;
 flight=new Flight(repo,sound,command,message=>ui?.toast(message));await flight.init(document.getElementById('flight')!);ui=new UI(repo,flight,command);ui.mount();document.documentElement.dataset.graphics=repo.state.settings.graphics;document.getElementById('loading')!.remove();
 document.addEventListener('pointerdown',()=>{sound.set(repo.state.settings.sound,repo.state.settings.music);void sound.start().catch(()=>ui?.toast('Áudio indisponível. O jogo continua normalmente.'));},{once:true});
 setInterval(()=>{if(!repo.busy&&!repo.readOnly&&!document.hidden&&!flight.replaying)void command({id:uid(),type:'CHECKPOINT'});},3000);
 setInterval(()=>{if(!repo.busy&&!repo.readOnly&&!ui?.panel&&(repo.state.world.encounters[repo.state.world.sector]||[]).length<2)void command({id:uid(),type:'REPOPULATE'});},60000);
 document.addEventListener('visibilitychange',()=>{if(document.hidden&&!repo.busy&&!repo.readOnly)void command({id:uid(),type:'CHECKPOINT'});});
 window.addEventListener('pagehide',()=>{if(!repo.busy&&!repo.readOnly)void command({id:uid(),type:'CHECKPOINT'});});
 window.addEventListener('keydown',e=>{if(e.key==='Escape')ui?.close();});
 void registerOffline().catch(()=>{});
 window.addEventListener('beforeinstallprompt',e=>{e.preventDefault();(window as any).stellarInstall=e;});
 setInterval(()=>{if(!repo.busy&&!flight.paused&&!flight.replaying&&repo.state.lab?.warfront.active)void command({id:uid(),type:'WARFRONT_TICK'});},1000);
 setInterval(()=>{if(!repo.busy&&Object.values(repo.state.world.encounters).some(ns=>ns.some(n=>n.eventId&&repo.state.lab?.events.some(e=>e.id===n.eventId&&Date.now()>e.end))))void command({id:uid(),type:'EVENT_TICK'});},5000);
 if(repo.readOnly)ui.toast('Outra aba está pilotando. Esta sessão está somente em leitura.');else if(!repo.state.lab?.research.profileCreated)ui.open('profile');
 // A read-only diagnostic projection; no commands or wallet setters are exposed.
 Object.defineProperty(window,'stellarDiagnostics',{get:()=>({renderer:flight.app.renderer.type,revision:repo.state.revision,sector:repo.state.world.sector,x:repo.state.world.x,y:repo.state.world.y,credits:repo.state.credits,npcs:repo.state.world.encounters[repo.state.world.sector].length,fps:flight.fps,graphics:repo.state.settings.graphics,showFPS:!!repo.state.settings.showFPS,hudHidden:!!repo.state.lab?.settings.hideHUD,resolution:flight.app.renderer.resolution,maxFPS:flight.app.ticker.maxFPS,visualHeading:flight.visualHeading,angleChanges:flight.angleChanges,recording:flight.recording,recordedSamples:flight.recorded.length,replaying:flight.replaying,replayMaxError:flight.replayMaxError,autopilot:flight.brain.status,autopilotMs:flight.brain.duration,p50:flight.meter.p50,p99:flight.meter.p99,domNodes:document.querySelectorAll('.space-sprite').length,effects:flight.fx.length,bullets:flight.bullets.length,pooled:flight.spare.length,sceneMs:flight.meter.sceneMs,p95:flight.meter.p95,goal:flight.goal,dragging:flight.drag?.pointer!=null,lootSprites:(repo.state.world.loot[repo.state.world.sector]||[]).map(l=>({id:l.id,crate:flight.entities.get('loot:'+l.id)?.texture===flight.textures.lootbox})),frameCount:flight.meter.total,hudMs:ui.hudMs,saveMs:repo.lastSaveMs,queue:repo.pendingCount,frameMs:[...flight.framesMs],readOnly:repo.readOnly,kills:repo.state.pilot.kills,loot:repo.state.world.loot[repo.state.world.sector],targets:repo.state.world.encounters[repo.state.world.sector].map(n=>({id:n.id,x:n.x,y:n.y,hp:n.hp,shield:n.shield,screen:flight.screen(n.x,n.y)}))})});
}
boot().catch(error=>{document.getElementById('app')!.textContent=`Não foi possível iniciar o jogo: ${String(error)}. Verifique o cache e recarregue.`;});
