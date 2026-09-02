#!/usr/bin/env node
/** Native, loopback-only Chrome capture for Local Wiki (Node built-ins only). */
import { createServer } from 'node:net';
import { spawn, spawnSync } from 'node:child_process';
import { chmod, lstat, mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, resolve, join, isAbsolute } from 'node:path';
import { fileURLToPath } from 'node:url';

const MAX_BYTES = 5 * 1024 * 1024;
const FRAME_MAX = 6 * 1024 * 1024;
const TIMEOUT = 15_000;
const LOOPBACK = '127.0.0.1';
const LANGUAGE = /^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8}){0,4}$/;
const YOUTUBE = new Set(['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be']);
export class CaptureError extends Error {}

export function httpsUrl(value, allowBlank = false) {
  if (allowBlank && value === 'about:blank') return value;
  let url; try { url = new URL(value); } catch { throw new CaptureError('URL must be HTTPS'); }
  if (url.protocol !== 'https:' || url.username || url.password) throw new CaptureError('URL must be credential-free HTTPS');
  return url.href;
}
export function portNumber(value) {
  const port = Number(value);
  if (!Number.isInteger(port) || port < 1024 || port > 65535) throw new CaptureError('port must be an integer from 1024 to 65535');
  return port;
}
export function languageCode(value) { if (!LANGUAGE.test(value) || value.length > 35) throw new CaptureError('language has an unsafe format'); return value; }
export function isYoutubeUrl(value) { try { const u = new URL(value); return u.protocol === 'https:' && YOUTUBE.has(u.hostname) && (u.hostname === 'youtu.be' || u.pathname === '/watch'); } catch { return false; } }
export function selectTab(targets, tabId, explicitPort = false) {
  const pages = targets.filter(target => target.type === 'page' && (() => { try { return new URL(target.url).protocol === 'https:'; } catch { return false; } })());
  if (tabId) { const tab = pages.find(target => target.id === tabId); if (!tab) throw new CaptureError('selected tab is not an eligible HTTPS page'); return tab; }
  if (explicitPort) throw new CaptureError('--port requires --tab');
  if (pages.length !== 1) throw new CaptureError('select exactly one eligible HTTPS tab with --tab');
  return pages[0];
}
export function validateWsUrl(value, port) {
  let url; try { url = new URL(value); } catch { throw new CaptureError('invalid debugger endpoint'); }
  if (url.protocol !== 'ws:' || url.hostname !== LOOPBACK || Number(url.port) !== port || !url.pathname.startsWith('/devtools/page/')) throw new CaptureError('unsafe debugger endpoint');
  return url.href;
}

// This declaration is fixed code. All page-specific values arrive as structured arguments.
export const PAGE_FUNCTION = `function(options) {
  const MAX = 5 * 1024 * 1024, MAX_NODES = 50000;
  const fail = error => ({ok:false,error});
  const safeUrl = value => { try { const u = new URL(value); return u.protocol === 'https:' && !u.username && !u.password ? u.href : null; } catch { return null; } };
  if (location.href !== options.expectedUrl) return fail('page navigation changed');
  const isYT = /^(www\\.|m\\.)?youtube\\.com$/.test(location.hostname) && location.pathname === '/watch' || location.hostname === 'youtu.be';
  if (options.kind === 'youtube' && !isYT) return fail('selected page is not YouTube');
  if (options.kind === 'page' && isYT) return fail('page kind does not match YouTube');
  const clean = text => String(text || '').replace(/\\s+/g, ' ').trim();
  const stamp = seconds => { seconds = Math.max(0, Math.floor(seconds)); const h=Math.floor(seconds/3600), m=Math.floor(seconds%3600/60), s=seconds%60; return h ? String(h).padStart(2,'0')+':'+String(m).padStart(2,'0')+':'+String(s).padStart(2,'0') : String(m).padStart(2,'0')+':'+String(s).padStart(2,'0'); };
  const page = () => {
    const root = document.querySelector('main, article, [role=main], body'); if (!root) return fail('no rendered page content');
    const copy = root.cloneNode(true); copy.querySelectorAll('script,style,nav,header,footer,form,button,noscript,iframe,[hidden],[aria-hidden=true]').forEach(n=>n.remove());
    let seen=0, out=[]; const walk = node => { if (++seen > MAX_NODES) throw Error('DOM node limit exceeded'); if (node.nodeType===3) { const t=clean(node.nodeValue); if(t) out.push(t); return; } if(node.nodeType!==1) return; const tag=node.tagName.toLowerCase(); if(/^h[1-6]$/.test(tag)) out.push('\\n'+ '#'.repeat(+tag[1])+' '+clean(node.textContent)+'\\n'); else if(tag==='li') out.push('\\n- '+clean(node.textContent)); else if(tag==='blockquote') out.push('\\n> '+clean(node.textContent)); else if(tag==='pre') out.push('\\n    '+node.textContent.trim()+'\\n'); else if(tag==='br') out.push('\\n'); else for(const child of node.childNodes) walk(child); };
    try { walk(copy); } catch(e) { return fail(e.message); }
    const body=out.join(' ').replace(/ ?\\n ?/g,'\\n').trim(); if(!body || new TextEncoder().encode(body).length>MAX) return fail('rendered page is empty or oversized');
    const description=document.querySelector('meta[name=description]')?.content || ''; return {ok:true,kind:'page',title:clean(document.title)||'Captured page',url:location.href,summary:clean(description).slice(0,1000),body};
  };
  const youtube = async () => {
    let player = globalThis.ytInitialPlayerResponse; if (!player) { const scripts=[...document.scripts].slice(0,50); for(const script of scripts) { const text=script.textContent||''; if(text.length>MAX) continue; const match=text.match(/ytInitialPlayerResponse\\s*=\\s*({[\\s\\S]*?});/); if(match) { try { player=JSON.parse(match[1]); break; } catch {} } } }
    const tracks=player?.captions?.playerCaptionsTracklistRenderer?.captionTracks; if(!Array.isArray(tracks)||!tracks.length) return fail('no captions available');
    const requested=options.language || ''; const track=tracks.find(t=>t.languageCode===requested&&!t.kind) || tracks.find(t=>t.languageCode===requested) || tracks.find(t=>!t.kind) || tracks[0];
    let endpoint; try { endpoint=new URL(track.baseUrl); } catch { return fail('invalid caption endpoint'); }
    if(endpoint.protocol!=='https:' || !/^(www\\.)?youtube\\.com$/.test(endpoint.hostname) || endpoint.pathname!=='/api/timedtext') return fail('untrusted caption endpoint');
    endpoint.searchParams.set('fmt','json3'); let response; try { response=await fetch(endpoint.href); } catch { return fail('caption request failed'); }
    const length=Number(response.headers.get('content-length')); if(Number.isFinite(length)&&length>MAX) return fail('caption response oversized'); let text; try { text=await response.text(); } catch { return fail('caption response unreadable'); } if(text.length>MAX) return fail('caption response oversized');
    let json; try { json=JSON.parse(text); } catch { return fail('invalid caption response'); } if(!Array.isArray(json.events)||json.events.length>100000) return fail('invalid caption events');
    const lines=[]; for(const event of json.events) { const value=clean((event.segs||[]).map(s=>s.utf8||'').join('')); if(value) lines.push('**['+stamp((event.tStartMs||0)/1000)+']** '+value); }
    const body=lines.join('\\n\\n'); if(!body) return fail('caption transcript is empty'); return {ok:true,kind:'youtube',title:clean(player?.videoDetails?.title)||clean(document.title)||'YouTube transcript',url:location.href,channel:clean(player?.videoDetails?.author),subtitle_language:track.languageCode,body};
  };
  return (options.kind === 'youtube' || (options.kind === 'auto' && isYT)) ? youtube() : page();
}`;

export class CdpTransport {
  constructor(wsUrl) { this.wsUrl=wsUrl; this.ws=null; this.next=1; this.pending=new Map(); }
  async connect() { this.ws = new WebSocket(this.wsUrl); await new Promise((resolve,reject)=>{ const timer=setTimeout(()=>reject(new CaptureError('CDP connection timed out')),TIMEOUT); this.ws.addEventListener('open',()=>{clearTimeout(timer);resolve();},{once:true}); this.ws.addEventListener('error',()=>{clearTimeout(timer);reject(new CaptureError('CDP connection failed'));},{once:true}); }); this.ws.addEventListener('message',event=>{ if(typeof event.data!=='string' || event.data.length>FRAME_MAX) return this.close(); let packet; try { packet=JSON.parse(event.data); } catch { return this.close(); } const entry=this.pending.get(packet.id); if(!entry) return; this.pending.delete(packet.id); clearTimeout(entry.timer); packet.error ? entry.reject(new CaptureError('CDP protocol error')) : entry.resolve(packet.result); }); this.ws.addEventListener('close',()=>this.#rejectAll(new CaptureError('CDP connection closed'))); this.ws.addEventListener('error',()=>this.#rejectAll(new CaptureError('CDP connection failed'))); return this; }
  #rejectAll(error) { for(const entry of this.pending.values()) { clearTimeout(entry.timer); entry.reject(error); } this.pending.clear(); }
  call(method, params={}) { if(!this.ws || this.ws.readyState!==WebSocket.OPEN) return Promise.reject(new CaptureError('CDP connection unavailable')); const id=this.next++; return new Promise((resolve,reject)=>{ const timer=setTimeout(()=>{this.pending.delete(id);reject(new CaptureError('CDP request timed out'));},TIMEOUT); this.pending.set(id,{resolve,reject,timer}); this.ws.send(JSON.stringify({id,method,params})); }); }
  close() { if(this.ws) this.ws.close(); this.#rejectAll(new CaptureError('CDP transport closed')); }
}

async function json(url) { const response=await fetch(url,{signal:AbortSignal.timeout(TIMEOUT)}); if(!response.ok) throw new CaptureError('CDP discovery failed'); const data=await response.json(); if(JSON.stringify(data).length>FRAME_MAX) throw new CaptureError('CDP discovery oversized'); return data; }
export async function discover(port) { const targets=await json(`http://${LOOPBACK}:${port}/json/list`); if(!Array.isArray(targets)) throw new CaptureError('invalid CDP target list'); return targets.map(({id,type,title,url,webSocketDebuggerUrl})=>({id,type,title,url,webSocketDebuggerUrl})); }
export async function captureAndImport(options, transport) {
  const targets=await options.discover(options.port); const target=selectTab(targets,options.tab,options.explicitPort); const current=(await options.discover(options.port)).find(item=>item.id===target.id); if(!current || current.type!=='page' || current.url!==target.url) throw new CaptureError('tab changed before capture');
  const global=await transport.call('Runtime.evaluate',{expression:'globalThis',returnByValue:false}); const objectId=global?.result?.objectId; if(!objectId) throw new CaptureError('CDP global object unavailable');
  const result=await transport.call('Runtime.callFunctionOn',{objectId,functionDeclaration:PAGE_FUNCTION,arguments:[{value:{expectedUrl:target.url,kind:options.kind,language:options.language||''}}],awaitPromise:true,returnByValue:true}); const value=result?.result?.value; if(!value?.ok || typeof value.body!=='string' || new TextEncoder().encode(value.body).length>MAX_BYTES) throw new CaptureError('page extraction failed');
  const meta={title:value.title,source_url:value.url,saved_at:new Date().toISOString(),summary:value.summary||null,channel:value.channel||null,subtitle_language:value.subtitle_language||null}; const clip=['---',...Object.entries(meta).filter(([,v])=>v).map(([k,v])=>`${k}: ${JSON.stringify(v)}`),'---','',value.body,''].join('\n');
  if(options.dryRun) return {path:null,value}; const dir=await mkdtemp(join(tmpdir(),'tad-browser-capture-')); const file=join(dir,'clip.md'); try { await writeFile(file,clip,{mode:0o600}); await chmod(file,0o600); const importer=join(options.repoRoot,'research/scripts/import-clip.py'); const output=spawnSync('python3',[importer,file,'--repo-root',options.repoRoot],{encoding:'utf8'}); if(output.status!==0) throw new CaptureError('importer rejected captured content'); return {path:output.stdout.trim(),value}; } finally { await rm(dir,{recursive:true,force:true}); }
}

function parse(argv) { const [command,...rest]=argv; const out={command,port:null,profile:null,headless:false,json:false,tab:null,kind:'auto',language:'',repoRoot:resolve(dirname(fileURLToPath(import.meta.url)),'../..'),dryRun:false,url:null}; for(let i=0;i<rest.length;i++){const a=rest[i]; if(!a.startsWith('--')&&!out.url){out.url=a;continue;} if(a==='--headless'||a==='--dry-run'||a==='--json'){out[a.slice(2).replace(/-./g,m=>m[1].toUpperCase())]=true;continue;} const key=a.slice(2).replace(/-./g,m=>m[1].toUpperCase()); if(!['port','profile','tab','kind','language','repoRoot'].includes(key)||!rest[i+1]) throw new CaptureError('unknown or incomplete flag'); out[key]=rest[++i];} if(!['launch','tabs','capture'].includes(command)) throw new CaptureError('command must be launch, tabs, or capture'); if(!['auto','page','youtube'].includes(out.kind)) throw new CaptureError('kind must be auto, page, or youtube'); if(out.language) languageCode(out.language); return out; }
async function unused(port){ return await new Promise(resolve=>{const server=createServer(); server.once('error',()=>resolve(false));server.listen(port,LOOPBACK,()=>server.close(()=>resolve(true)));}); }
export async function launch(options){ const url=httpsUrl(options.url||'about:blank',true); const profile=resolve(options.profile||join(process.env.HOME||tmpdir(),'.tad-browser/local-wiki-profile')); if(/Google Chrome\/Default|Chromium\/Default/.test(profile)) throw new CaptureError('default Chrome profile is forbidden'); let info; try{info=await lstat(profile);}catch{} if(info&&!info.isDirectory()) throw new CaptureError('profile path is unsafe'); const marker=join(profile,'.tad-local-wiki-owner.json'); if(info){ try{const value=JSON.parse(await readFile(marker,'utf8')); if(value.magic!=='tad-local-wiki-profile') throw Error();}catch{throw new CaptureError('existing profile is not TAD-owned');} } else { await mkdir(profile,{recursive:true,mode:0o700}); await chmod(profile,0o700); } if(options.port!==null && !(await unused(portNumber(options.port)))) throw new CaptureError('requested port is occupied'); const chrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'; const args=[`--remote-debugging-address=${LOOPBACK}`,`--remote-debugging-port=${options.port===null?0:portNumber(options.port)}`,`--user-data-dir=${profile}`, ...(options.headless?['--headless=new']:[]),url]; const child=spawn(chrome,args,{detached:true,stdio:'ignore'}); child.unref(); await writeFile(marker,JSON.stringify({magic:'tad-local-wiki-profile',path:profile,pid:child.pid,port:options.port??0,started_at:new Date().toISOString()})+'\n',{mode:0o600}); await chmod(marker,0o600); console.log(`pid=${child.pid} port=${options.port??0} profile=${profile}`); }
async function main(){const o=parse(process.argv.slice(2)); if(o.command==='launch') return launch(o); if(o.port===null) throw new CaptureError('--port is required'); const port=portNumber(o.port); const targets=await discover(port); if(o.command==='tabs'){const pages=targets.filter(t=>t.type==='page'); console.log(o.json?JSON.stringify(pages):pages.map(t=>`${t.id}\t${t.title}\t${t.url}`).join('\n'));return;} const target=selectTab(targets,o.tab,true); const ws=validateWsUrl(target.webSocketDebuggerUrl,port); const transport=await new CdpTransport(ws).connect(); try{const result=await captureAndImport({...o,port,explicitPort:true,discover},transport); console.log(result.path||'dry-run');}finally{transport.close();}}
if(import.meta.main) main().catch(error=>{console.error(`browser-capture: ${error instanceof CaptureError ? error.message : 'capture failed'}`);process.exitCode=2;});
