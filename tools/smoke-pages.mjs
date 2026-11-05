import {chromium} from '@playwright/test';
import {spawn} from 'node:child_process';
import assert from 'node:assert/strict';
const server=spawn('npm',['exec','vite','preview','--','--outDir','dist-pages','--host','127.0.0.1','--port','4174','--strictPort'],{env:{...process.env,BASE_PATH:'/stellar-legacy-offline/'},stdio:'ignore',detached:true});
let browser;
try{
 const url='http://127.0.0.1:4174/stellar-legacy-offline/';
 let ready=false;for(let i=0;i<40;i++){try{ready=(await fetch(url)).ok;if(ready)break;}catch{}await new Promise(r=>setTimeout(r,250));}assert(ready,'Preview server did not start');
 browser=await chromium.launch({headless:true});const context=await browser.newContext({viewport:{width:915,height:412}});const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto(url);await page.locator('#attack').waitFor({timeout:45000});await page.locator('.modal-header [data-action=close]').click();await page.screenshot({path:'docs/screenshot-pages-prefix.png'});
 await page.locator('[data-action=panel][data-id=save]').click();await page.locator('[data-action=offline]').click();await page.waitForFunction(()=>document.querySelector('#offline-progress')?.textContent?.includes('Cache completo'),{},{timeout:45000});
 await context.setOffline(true);await page.reload();await page.locator('#attack').waitFor({timeout:45000});assert.equal(await page.evaluate(()=>window.stellarDiagnostics.sector),0);assert.equal(await page.locator('canvas').count(),0);assert.equal(await page.evaluate(()=>window.stellarDiagnostics.renderer),'dom');assert.deepEqual(errors,[]);console.log('PASS: explicit /stellar-legacy-offline/ build, DOM raster assets, service worker and offline reload.');
}finally{await browser?.close();try{process.kill(-server.pid,'SIGTERM');}catch{}}
