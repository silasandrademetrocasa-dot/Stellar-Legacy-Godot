export async function registerOffline(){if('serviceWorker'in navigator){await navigator.serviceWorker.register(`${import.meta.env.BASE_URL}sw.js`,{scope:import.meta.env.BASE_URL});await navigator.serviceWorker.ready;}}
export async function downloadOffline(report:(done:number,total:number,bytes:number)=>void){
 await registerOffline();const base=new URL(import.meta.env.BASE_URL,location.href);const response=await fetch(new URL('offline-files.json',base));if(!response.ok)throw Error('Lista offline indisponível. Use a versão compilada.');const files:string[]=await response.json();const cache=await caches.open('stellar-v1-content');let done=0,bytes=0;
 for(const file of files){const url=new URL(file,base),r=await fetch(url);if(!r.ok)throw Error(`Falha no pacote ${file}`);bytes+=(await r.clone().arrayBuffer()).byteLength;await cache.put(url,r);done++;report(done,files.length,bytes);}
 for(const file of files)if(!await cache.match(new URL(file,base)))throw Error(`Cache incompleto: ${file}`);
 await navigator.storage?.persist?.();return bytes;
}
