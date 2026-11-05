import type {Flight} from './flight';
import {cargo,stats,nearStation,uid} from '../core/game';
import {enemies,sectors,missions} from '../content/catalog';
import {laserStock} from '../core/laboratory';
export class Autopilot{
 next=0;duration=0;status='DESATIVADO';
 constructor(private flight:Flight){}
 tick(now:number){const f=this.flight,s=f.s,l=s.lab;if(!l?.autopilot.enabled||f.paused||f.repo.busy||f.replaying){this.status='DESATIVADO';return;}if(now<this.next)return;this.next=now+500;const start=performance.now(),st=stats(s),w=s.world,sector=sectors[w.sector];
 if(w.hp<st.hp*l.autopilot.returnHp||cargo(s)>st.cargo*.85||laserStock(s)<20){this.status='RETORNO / SERVIÇOS';f.attacking=false;f.setGoal(sector.station);if(nearStation(s))void f.command({id:uid(),type:'AUTOTRADE'});}
 else{const mission=missions.find(m=>s.missions[m.id].status==='active');const destination=mission?.kind==='visit'?mission.sector:l.autopilot.sector;if(destination!==undefined&&destination>=0&&destination!==w.sector&&(s.pilot.kills>=sectors[destination].unlock||l.research.unlockAll)){const queue:number[][]=[[w.sector]],seen=new Set<number>();let route:number[]|undefined;while(queue.length){const path=queue.shift()!,last=path[path.length-1];if(last===destination){route=path;break;}if(seen.has(last))continue;seen.add(last);for(const next of sectors[last].links)queue.push([...path,next]);}if(route?.[1]!==undefined){this.status='VIAGEM';f.attacking=false;f.setGoal(sector.portal);if(Math.hypot(w.x-sector.portal.x,w.y-sector.portal.y)<210)void f.command({id:uid(),type:'TRAVEL',payload:{sector:route[1]}});this.duration=performance.now()-start;return;}}
 const loot=w.loot[w.sector]?.find(v=>Math.hypot(v.x-w.x,v.y-w.y)<650&&cargo(s)+v.quantity<=st.cargo);const target=w.encounters[w.sector]?.filter(n=>!f.pendingKills.has(n.id)&&(!l.autopilot.targetCode||enemies[n.type].code===l.autopilot.targetCode)).sort((a,b)=>Math.hypot(a.x-w.x,a.y-w.y)-Math.hypot(b.x-w.x,b.y-w.y))[0];
 const miner=f.mineralNodes().filter(n=>!s.resolved.includes('mine-'+n.id)).sort((a,b)=>Math.hypot(a.x-w.x,a.y-w.y)-Math.hypot(b.x-w.x,b.y-w.y))[0];if(mission?.kind==='sell'&&cargo(s)>0){this.status='MISSÃO / COMÉRCIO';f.attacking=false;f.setGoal(sector.station);if(nearStation(s))void f.command({id:uid(),type:'AUTOTRADE'});}else if(l.autopilot.priority==='minerio'&&miner){this.status='MINERAÇÃO PRIORITÁRIA';f.attacking=false;f.setGoal(miner);}else if(loot&&(!f.attacking||!target||l.autopilot.priority==='loot')){this.status='COLETA';f.setGoal(loot);}
 else if(target){this.status='COMBATE / ÓRBITA';f.target=target.id;f.attacking=true;const d=Math.hypot(target.x-w.x,target.y-w.y);if(d>430)f.setGoal(target);else{const angle=Math.atan2(w.y-target.y,w.x-target.x)+.25;f.setGoal({x:target.x+Math.cos(angle)*(l.autopilot.orbit||310),y:target.y+Math.sin(angle)*(l.autopilot.orbit||310)});}}
 else if(l.autopilot.mine){this.status='MINERAÇÃO';const node=f.mineralNodes().find(n=>!s.resolved.includes('mine-'+n.id));if(node)f.setGoal(node);else this.status='SETOR LIMPO';}
 else{this.status='SETOR LIMPO';f.attacking=false;}}
 this.duration=performance.now()-start;
 }
}
