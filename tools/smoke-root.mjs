import {chromium} from '@playwright/test';
import {spawn} from 'node:child_process';
import assert from 'node:assert/strict';
const server=spawn('python',['-m','http.server','4175','--bind','127.0.0.1'],{stdio:'ignore'});let browser;
try{for(let i=0;i<50;i++){try{if((await fetch('http://127.0.0.1:4175/')).ok)break;}catch{}await new Promise(r=>setTimeout(r,250));}
 browser=await chromium.launch();const context=await browser.newContext();const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));page.on('response',r=>{if(r.status()>=400)errors.push(r.status()+' '+r.url());});await page.goto('http://127.0.0.1:4175/');await page.locator('#attack').waitFor({timeout:60000});assert.equal(await page.evaluate(()=>window.stellarDiagnostics.renderer),'dom');assert.equal(await page.locator('canvas').count(),0);await page.evaluate(()=>navigator.serviceWorker.ready);await context.setOffline(true);await page.reload();await page.locator('#attack').waitFor({timeout:60000});assert.deepEqual(errors,[]);console.log('PASS: precompiled root opens in a plain static HTTP server and reopens offline, DOM without canvas.');
}finally{await browser?.close();server.kill('SIGTERM');}
