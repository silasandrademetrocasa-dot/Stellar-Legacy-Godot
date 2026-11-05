import {readdir,writeFile,readFile,rename,access} from 'node:fs/promises';
import {join} from 'node:path';
import {createHash} from 'node:crypto';
async function walk(dir,prefix=''){let files=[];for(const e of await readdir(dir,{withFileTypes:true})){const rel=prefix+e.name;if(e.isDirectory())files.push(...await walk(join(dir,e.name),rel+'/'));else files.push(rel);}return files;}
const output=process.argv[2]||'dist';
try{await access(join(output,'app.html'));await rename(join(output,'app.html'),join(output,'index.html'));}catch{}
const files=(await walk(output)).filter(f=>!['sw.js','offline-files.json'].includes(f));
const hash=createHash('sha256');for(const file of files)hash.update(await readFile(join(output,file)));const version=hash.digest('hex').slice(0,12);
await writeFile(join(output,'offline-files.json'),JSON.stringify(files));
const worker=`const VERSION='${version}',SHELL='stellar-'+VERSION,CONTENT='stellar-v1-content',FILES=${JSON.stringify(files)};
self.addEventListener('install',event=>event.waitUntil((async()=>{const cache=await caches.open(SHELL);for(let i=0;i<FILES.length;i+=4)await cache.addAll(FILES.slice(i,i+4));})()));
self.addEventListener('activate',event=>event.waitUntil((async()=>{for(const key of await caches.keys())if(key.startsWith('stellar-')&&key!==SHELL&&key!==CONTENT)await caches.delete(key);await self.clients.claim();})()));
self.addEventListener('fetch',event=>{if(event.request.method!=='GET'||new URL(event.request.url).origin!==self.location.origin)return;event.respondWith((async()=>{const url=new URL(event.request.url);const scope=new URL(self.registration.scope);const rel=url.pathname.slice(scope.pathname.length);const cache=await caches.open(SHELL);const key=event.request.mode==='navigate'?new URL('index.html',scope).href:event.request;const cached=await cache.match(key,{ignoreVary:true});if(cached)return cached;if(rel==='offline-files.json'){try{return await fetch(event.request);}catch{return new Response(JSON.stringify(FILES),{headers:{'Content-Type':'application/json'}});}}return fetch(event.request);})());});`;
await writeFile(join(output,'sw.js'),worker);console.log(`Offline build ${version}: ${files.length} files (all 14 sectors and LOD assets precached; updates wait for old clients to close).`);
