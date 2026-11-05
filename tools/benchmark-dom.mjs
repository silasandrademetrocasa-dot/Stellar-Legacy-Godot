import {chromium} from '@playwright/test';
import {writeFile} from 'node:fs/promises';
import {spawn} from 'node:child_process';
const server=spawn('npm',['exec','vite','preview','--','--host','127.0.0.1','--port','4186','--strictPort'],{stdio:'ignore',detached:true});
try{
 let ready=false;for(let i=0;i<80;i++){try{if((await fetch('http://127.0.0.1:4186/')).ok){ready=true;break;}}catch{}await new Promise(r=>setTimeout(r,250));}if(!ready)throw Error('Benchmark preview did not start');
const browser=await chromium.launch({headless:true});const results=[];
const quantile=(a,p)=>{const b=[...a].sort((x,y)=>x-y);return b[Math.max(0,Math.ceil(b.length*p)-1)]||0;};
async function open(page,id){await page.evaluate(id=>{const b=document.createElement('button');b.dataset.action='panel';b.dataset.id=id;document.querySelector('#overlay').append(b);b.click();b.remove();},id);await page.locator('#panel-title').waitFor();}
for(const preset of ['low','medium','high']){
 const context=await browser.newContext({viewport:{width:915,height:412},isMobile:true,hasTouch:true});const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));await page.goto('http://127.0.0.1:4186/');await page.locator('#attack').waitFor();await page.locator('.modal-header [data-action=close]').click();await open(page,'settings');await page.locator('[data-setting=graphics]').selectOption(preset);await page.locator('[data-lab-pref=adaptive]').uncheck();await page.locator('.modal-header [data-action=close]').click();
 await page.evaluate(()=>document.documentElement.dataset.benchmark='true');
 const warmStarted=Date.now();await page.evaluate(()=>Promise.race([navigator.serviceWorker.ready,new Promise((_,reject)=>setTimeout(()=>reject(Error('Precache timed out')),120000))]));await page.waitForTimeout(1000);const warmupMs=Date.now()-warmStarted;
 const frames=[],samples=[],menus=[];let previous=await page.evaluate(()=>window.stellarDiagnostics.frameCount),keys=[];const started=Date.now();let enabled=false,finished=false,hud=false,menuDone=false,hidden=false,reshown=false;
 while(Date.now()-started<60000){const seconds=(Date.now()-started)/1000;
  if(seconds>10&&!hud){await open(page,'settings');await page.locator('[data-setting=showFPS]').check();await page.locator('.modal-header [data-action=close]').click();hud=true;}
  if(seconds>20&&!enabled){await open(page,'automation');await page.locator('[data-type=AUTOPILOT]').first().click();await page.locator('.modal-header [data-action=close]').click();enabled=true;}
  if(seconds>30&&!hidden){await page.evaluate(()=>{const b=document.createElement('button');b.dataset.action='hud-toggle';document.querySelector('#overlay').append(b);b.click();b.remove();});hidden=true;}
  if(seconds>45&&!reshown){await page.evaluate(()=>{const b=document.createElement('button');b.dataset.action='hud-toggle';document.querySelector('#overlay').append(b);b.click();b.remove();});reshown=true;}
  if(seconds>40&&!finished){await open(page,'automation');await page.locator('[data-type=AUTOPILOT]').first().click();await page.locator('.modal-header [data-action=close]').click();finished=true;}
  if(seconds>48&&!menuDone){for(const id of ['missions','hangar','catalog']){const t=Date.now();await open(page,id);await page.waitForTimeout(150);menus.push({id,openMs:Date.now()-t-150});await page.locator('.modal-header [data-action=close]').click();}menuDone=true;}
  const angle=seconds*.8;const next=seconds<20?[...(Math.cos(angle)>.3?['d']:Math.cos(angle)<-.3?['a']:[]),...(Math.sin(angle)>.3?['s']:Math.sin(angle)<-.3?['w']:[])]:seconds<40?[]:seconds<50?[Math.floor(seconds)%2?'a':'d','w']:['s'];
  for(const k of keys)if(!next.includes(k))await page.keyboard.up(k);for(const k of next)if(!keys.includes(k))await page.keyboard.down(k);keys=next;
  await page.waitForTimeout(800);const d=await page.evaluate(()=>window.stellarDiagnostics);const count=d.frameCount>=previous?d.frameCount-previous:d.frameCount;frames.push(...d.frameMs.slice(-Math.min(count,d.frameMs.length)));previous=d.frameCount;samples.push({seconds:Math.round(seconds),fps:d.fps,p95:d.p95,p99:d.p99,dom:d.domNodes,pool:d.pooled,autopilotMs:d.autopilotMs,saveMs:d.saveMs,heading:d.visualHeading,x:d.x,y:d.y,queue:d.queue,hudMs:d.hudMs,hudHidden:d.hudHidden,autopilot:d.autopilot});
 }
 for(const k of keys)await page.keyboard.up(k);results.push({preset,warmupMs,elapsedMs:Date.now()-started,samples:frames.length,fps:1000/(frames.reduce((a,b)=>a+b,0)/frames.length),p50:quantile(frames,.5),p95:quantile(frames,.95),p99:quantile(frames,.99),peakDOM:Math.max(...samples.map(s=>s.dom)),peakPool:Math.max(...samples.map(s=>s.pool)),maxAutopilotMs:Math.max(...samples.map(s=>s.autopilotMs)),maxSaveMs:Math.max(...samples.map(s=>s.saveMs)),maxYawDegrees:Math.max(...samples.map(s=>Math.abs(s.heading)))*180/Math.PI,menus,errors,timeline:samples});console.log(JSON.stringify({...results.at(-1),timeline:undefined}));await context.close();
}
await browser.close();await writeFile('docs/benchmark-dom.json',JSON.stringify({environment:'Chromium headless Linux; emulated touch viewport 915x412; no physical Android, no video recorder; presets capped 30/30/60; after complete Service Worker precache and1s warmup; sampling instrument active all60s; FPS widget disabled first10s, enabled afterwards; side HUD hidden30-45s; Autopilot20-40s; menus48s; scene starts with6NPCs; no concurrent test/build jobs',measuredAt:new Date().toISOString(),results},null,2));

}finally{try{process.kill(-server.pid,'SIGTERM');}catch{}}
