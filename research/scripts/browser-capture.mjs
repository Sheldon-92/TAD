#!/usr/bin/env node
/** Native, loopback-only Chrome capture for Local Wiki (Node built-ins only). */
import { createServer } from 'node:net';
import { spawn, spawnSync } from 'node:child_process';
import { chmod, lstat, mkdir, mkdtemp, open, readFile, realpath, rm, unlink, writeFile } from 'node:fs/promises';
import { constants as FS } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const MAX_BYTES = 5 * 1024 * 1024;
const FRAME_MAX = 6 * 1024 * 1024;
const TIMEOUT = 15_000;
const LOOPBACK = '127.0.0.1';
const LANGUAGE = /^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8}){0,4}$/;
const YOUTUBE = new Set(['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be']);
const MARKER = '.tad-local-wiki-owner.json';
const ACTIVE_PORT = 'DevToolsActivePort';
export class CaptureError extends Error {}
const byteLength = value => new TextEncoder().encode(value).length;
const sleep = milliseconds => new Promise(resolve => setTimeout(resolve, milliseconds));

export function httpsUrl(value, allowBlank = false) {
  if (allowBlank && value === 'about:blank') return value;
  let url; try { url = new URL(value); } catch { throw new CaptureError('URL must be HTTPS'); }
  if (url.protocol !== 'https:' || url.username || url.password) throw new CaptureError('URL must be credential-free HTTPS');
  return url.href;
}
export function portNumber(value) { const port = Number(value); if (!Number.isInteger(port) || port < 1024 || port > 65535) throw new CaptureError('port must be an integer from 1024 to 65535'); return port; }
export function languageCode(value) { if (!LANGUAGE.test(value) || value.length > 35) throw new CaptureError('language has an unsafe format'); return value; }
export function isYoutubeUrl(value) { try { const u = new URL(value); return u.protocol === 'https:' && YOUTUBE.has(u.hostname) && (u.hostname === 'youtu.be' || u.pathname === '/watch'); } catch { return false; } }
export function selectTab(targets, tabId, explicitPort = false) {
  const pages = targets.filter(target => target.type === 'page' && (() => { try { return new URL(target.url).protocol === 'https:'; } catch { return false; } })());
  if (tabId) { const tab = pages.find(target => target.id === tabId); if (!tab) throw new CaptureError('selected tab is not an eligible HTTPS page'); return tab; }
  if (explicitPort) throw new CaptureError('--port requires --tab');
  if (pages.length !== 1) throw new CaptureError('select exactly one eligible HTTPS tab with --tab');
  return pages[0];
}
export function publicTabs(targets) { return targets.filter(target=>target.type==='page').map(({id,title,url})=>({id,title,url})); }
export function validateWsUrl(value, port) {
  let url; try { url = new URL(value); } catch { throw new CaptureError('invalid debugger endpoint'); }
  if (url.protocol !== 'ws:' || url.hostname !== LOOPBACK || url.username || url.password || Number(url.port) !== port || !/^\/devtools\/page\/[A-Za-z0-9-]+$/.test(url.pathname) || url.search || url.hash) throw new CaptureError('unsafe debugger endpoint');
  return url.href;
}

// This declaration is fixed code. All page-specific values arrive as structured arguments.
export const PAGE_FUNCTION = `function(options) {
  const MAX = 5 * 1024 * 1024, MAX_NODES = 50000;
  const fail = error => ({ok:false,error});
  if (location.href !== options.expectedUrl) return fail('page navigation changed');
  const isYT = /^(www\\.|m\\.)?youtube\\.com$/.test(location.hostname) && location.pathname === '/watch' || location.hostname === 'youtu.be';
  if (options.kind === 'youtube' && !isYT) return fail('selected page is not YouTube');
  if (options.kind === 'page' && isYT) return fail('page kind does not match YouTube');
  const clean = text => String(text || '').replace(/\\s+/g, ' ').trim();
  const stamp = seconds => { seconds = Math.max(0, Math.floor(seconds)); const h=Math.floor(seconds/3600), m=Math.floor(seconds%3600/60), s=seconds%60; return h ? String(h).padStart(2,'0')+':'+String(m).padStart(2,'0')+':'+String(s).padStart(2,'0') : String(m).padStart(2,'0')+':'+String(s).padStart(2,'0'); };
  const concat = (chunks,total) => { const out=new Uint8Array(total); let offset=0; for(const chunk of chunks){out.set(chunk,offset);offset+=chunk.byteLength;} return out; };
  const page = () => {
    const root = document.querySelector('main, article, [role=main], body'); if (!root) return fail('no rendered page content');
    const copy = root.cloneNode(true); copy.querySelectorAll('script,style,nav,header,footer,form,button,noscript,iframe,[hidden],[aria-hidden=true]').forEach(n=>n.remove());
    let seen=0, out=[]; const walk = node => { if (++seen > MAX_NODES) throw Error('DOM node limit exceeded'); if (node.nodeType===3) { const t=clean(node.nodeValue); if(t) out.push(t); return; } if(node.nodeType!==1) return; const tag=node.tagName.toLowerCase(); if(/^h[1-6]$/.test(tag)) out.push('\\n'+ '#'.repeat(+tag[1])+' '+clean(node.textContent)+'\\n'); else if(tag==='li') out.push('\\n- '+clean(node.textContent)); else if(tag==='blockquote') out.push('\\n> '+clean(node.textContent)); else if(tag==='pre') out.push('\\n    '+node.textContent.trim()+'\\n'); else if(tag==='br') out.push('\\n'); else for(const child of node.childNodes) walk(child); };
    try { walk(copy); } catch(e) { return fail(e.message); }
    const body=out.join(' ').replace(/ ?\\n ?/g,'\\n').trim(); if(!body || new TextEncoder().encode(body).length>MAX) return fail('rendered page is empty or oversized');
    const description=document.querySelector('meta[name=description]')?.content || ''; return {ok:true,kind:'page',title:clean(document.title)||'Captured page',url:location.href,summary:clean(description).slice(0,1000),body};
  };
  const youtube = async () => {
    let player = globalThis.ytInitialPlayerResponse; if (!player) { const scripts=[...document.scripts].slice(0,50); for(const script of scripts) { const text=script.textContent||''; if(new TextEncoder().encode(text).length>MAX) continue; const match=text.match(/ytInitialPlayerResponse\\s*=\\s*({[\\s\\S]*?});/); if(match) { try { player=JSON.parse(match[1]); break; } catch {} } } }
    const tracks=player?.captions?.playerCaptionsTracklistRenderer?.captionTracks; if(!Array.isArray(tracks)||!tracks.length) return fail('no captions available');
    const requested=options.language || ''; const track=tracks.find(t=>t.languageCode===requested&&!t.kind) || tracks.find(t=>t.languageCode===requested) || tracks.find(t=>!t.kind) || tracks[0];
    let endpoint; try { endpoint=new URL(track.baseUrl); } catch { return fail('invalid caption endpoint'); }
    if(endpoint.protocol!=='https:' || !/^(www\\.)?youtube\\.com$/.test(endpoint.hostname) || endpoint.pathname!=='/api/timedtext') return fail('untrusted caption endpoint');
    endpoint.searchParams.set('fmt','json3'); let response; try { response=await fetch(endpoint.href); } catch { return fail('caption request failed'); }
    if(location.href !== options.expectedUrl) return fail('page navigation changed');
    const length=Number(response.headers.get('content-length')); if(Number.isFinite(length)&&length>MAX) return fail('caption response oversized');
    let reader; try { reader=response.body?.getReader(); } catch {} if(!reader) return fail('caption response unreadable');
    const chunks=[]; let total=0; try { for (;;) { const next=await reader.read(); if(next.done) break; total+=next.value.byteLength; if(total>MAX) return fail('caption response oversized'); chunks.push(next.value); } } catch { return fail('caption response unreadable'); }
    let json; try { json=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(concat(chunks,total))); } catch { return fail('invalid caption response'); } if(!Array.isArray(json.events)||json.events.length>100000) return fail('invalid caption events');
    const lines=[]; for(const event of json.events) { const value=clean((event.segs||[]).map(s=>s.utf8||'').join('')); if(value) lines.push('**['+stamp((event.tStartMs||0)/1000)+']** '+value); }
    const body=lines.join('\\n\\n'); if(!body || new TextEncoder().encode(body).length>MAX) return fail('caption transcript is empty or oversized'); return {ok:true,kind:'youtube',title:clean(player?.videoDetails?.title)||clean(document.title)||'YouTube transcript',url:location.href,channel:clean(player?.videoDetails?.author),subtitle_language:track.languageCode,body};
  };
  return (options.kind === 'youtube' || (options.kind === 'auto' && isYT)) ? youtube() : page();
}`;

export class CdpTransport {
  constructor(wsUrl, WebSocketImpl = globalThis.WebSocket) { this.wsUrl=wsUrl; this.WebSocketImpl=WebSocketImpl; this.ws=null; this.next=1; this.pending=new Map(); }
  async connect() { this.ws = new this.WebSocketImpl(this.wsUrl); await new Promise((resolve,reject)=>{ const timer=setTimeout(()=>reject(new CaptureError('CDP connection timed out')),TIMEOUT); this.ws.addEventListener('open',()=>{clearTimeout(timer);resolve();},{once:true}); this.ws.addEventListener('error',()=>{clearTimeout(timer);reject(new CaptureError('CDP connection failed'));},{once:true}); }); this.ws.addEventListener('message',event=>{ if(typeof event.data!=='string' || byteLength(event.data)>FRAME_MAX) return this.close(); let packet; try { packet=JSON.parse(event.data); } catch { return this.close(); } const entry=this.pending.get(packet.id); if(!entry) return; this.pending.delete(packet.id); clearTimeout(entry.timer); packet.error ? entry.reject(new CaptureError('CDP protocol error')) : entry.resolve(packet.result); }); this.ws.addEventListener('close',()=>this.#rejectAll(new CaptureError('CDP connection closed'))); this.ws.addEventListener('error',()=>this.#rejectAll(new CaptureError('CDP connection failed'))); return this; }
  #rejectAll(error) { for(const entry of this.pending.values()) { clearTimeout(entry.timer); entry.reject(error); } this.pending.clear(); }
  call(method, params={}) { if(!this.ws || this.ws.readyState!==this.WebSocketImpl.OPEN) return Promise.reject(new CaptureError('CDP connection unavailable')); const id=this.next++; return new Promise((resolve,reject)=>{ const timer=setTimeout(()=>{this.pending.delete(id);reject(new CaptureError('CDP request timed out'));},TIMEOUT); this.pending.set(id,{resolve,reject,timer}); try { this.ws.send(JSON.stringify({id,method,params})); } catch { this.pending.delete(id); clearTimeout(timer); reject(new CaptureError('CDP connection failed')); } }); }
  close() { if(this.ws) this.ws.close(); this.#rejectAll(new CaptureError('CDP transport closed')); }
}

export async function boundedJson(url, fetchImpl = globalThis.fetch) {
  let response; try { response=await fetchImpl(url,{redirect:'error',signal:AbortSignal.timeout(TIMEOUT)}); } catch { throw new CaptureError('CDP discovery failed'); }
  if(!response.ok || response.url !== url) throw new CaptureError('CDP discovery failed');
  const declared=Number(response.headers.get('content-length')); if(Number.isFinite(declared)&&declared>FRAME_MAX) throw new CaptureError('CDP discovery oversized');
  const reader=response.body?.getReader(); if(!reader) throw new CaptureError('CDP discovery failed'); const chunks=[]; let total=0;
  try { for (;;) { const next=await reader.read(); if(next.done) break; total+=next.value.byteLength; if(total>FRAME_MAX) throw new CaptureError('CDP discovery oversized'); chunks.push(next.value); } return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(concatBytes(chunks,total))); } catch(error) { if(error instanceof CaptureError) throw error; throw new CaptureError('CDP discovery failed'); }
}
function concatBytes(chunks,total) { const out=new Uint8Array(total); let offset=0; for(const chunk of chunks){out.set(chunk,offset);offset+=chunk.byteLength;} return out; }
export async function discover(port, fetchImpl = globalThis.fetch) { const targets=await boundedJson(`http://${LOOPBACK}:${port}/json/list`,fetchImpl); if(!Array.isArray(targets)) throw new CaptureError('invalid CDP target list'); return targets.map(({id,type,title,url,webSocketDebuggerUrl})=>({id,type,title,url,webSocketDebuggerUrl})); }
export async function captureAndImport(options, transport) {
  const targets=await options.discover(options.port); const target=selectTab(targets,options.tab,options.explicitPort); const current=(await options.discover(options.port)).find(item=>item.id===target.id); if(!current || current.type!=='page' || current.url!==target.url) throw new CaptureError('tab changed before capture');
  const global=await transport.call('Runtime.evaluate',{expression:'globalThis',returnByValue:false}); const objectId=global?.result?.objectId; if(!objectId) throw new CaptureError('CDP global object unavailable');
  const result=await transport.call('Runtime.callFunctionOn',{objectId,functionDeclaration:PAGE_FUNCTION,arguments:[{value:{expectedUrl:target.url,kind:options.kind,language:options.language||''}}],awaitPromise:true,returnByValue:true}); const value=result?.result?.value; const expectedKind=options.kind==='auto' ? (isYoutubeUrl(target.url)?'youtube':'page') : options.kind;
  if(!value?.ok || value.kind!==expectedKind || value.url!==target.url || typeof value.body!=='string' || byteLength(value.body)>MAX_BYTES) throw new CaptureError('page extraction failed');
  const meta={title:value.title,source_url:value.url,saved_at:new Date().toISOString(),summary:value.summary||null,channel:value.channel||null,subtitle_language:value.subtitle_language||null}; const clip=['---',...Object.entries(meta).filter(([,v])=>v).map(([k,v])=>`${k}: ${JSON.stringify(v)}`),'---','',value.body,''].join('\n');
  if(options.dryRun) return {path:null,value}; const dir=await mkdtemp(join(tmpdir(),'tad-browser-capture-')); const file=join(dir,'clip.md'); try { await writeFile(file,clip,{mode:0o600}); await chmod(file,0o600); const importer=join(options.repoRoot,'research/scripts/import-clip.py'); const output=spawnSync('python3',[importer,file,'--repo-root',options.repoRoot],{encoding:'utf8'}); if(output.status!==0) throw new CaptureError('importer rejected captured content'); return {path:output.stdout.trim(),value}; } finally { await rm(dir,{recursive:true,force:true}); }
}

function parse(argv) { const [command,...rest]=argv; const out={command,port:null,profile:null,headless:false,json:false,tab:null,kind:'auto',language:'',repoRoot:resolve(dirname(fileURLToPath(import.meta.url)),'../..'),dryRun:false,url:null}; for(let i=0;i<rest.length;i++){const a=rest[i]; if(!a.startsWith('--')&&!out.url){out.url=a;continue;} if(a==='--headless'||a==='--dry-run'||a==='--json'){out[a.slice(2).replace(/-./g,m=>m[1].toUpperCase())]=true;continue;} const key=a.slice(2).replace(/-./g,m=>m[1].toUpperCase()); if(!['port','profile','tab','kind','language','repoRoot'].includes(key)||!rest[i+1]) throw new CaptureError('unknown or incomplete flag'); out[key]=rest[++i];} if(!['launch','tabs','capture'].includes(command)) throw new CaptureError('command must be launch, tabs, or capture'); if(!['auto','page','youtube'].includes(out.kind)) throw new CaptureError('kind must be auto, page, or youtube'); if(out.language) languageCode(out.language); return out; }
async function unused(port){ return await new Promise(resolve=>{const server=createServer(); server.once('error',()=>resolve(false));server.listen(port,LOOPBACK,()=>server.close(()=>resolve(true)));}); }
function defaultProfile(path) { return /(?:^|\/)Library\/Application Support\/(?:Google\/Chrome|Chromium)\/Default$/.test(path) || /(?:^|\/)(?:Google Chrome|Chromium)\/Default$/.test(path); }
function privateMode(info, expected) { return (info.mode & 0o777) === expected; }
async function readPrivateRegular(path, limit = 4096) { let info; try { info=await lstat(path); } catch { throw new CaptureError('profile ownership marker is missing'); } if(!info.isFile() || info.isSymbolicLink() || !privateMode(info,0o600) || info.size>limit) throw new CaptureError('profile ownership marker is unsafe'); let handle; try { handle=await open(path,FS.O_RDONLY|FS.O_NOFOLLOW); info=await handle.stat(); if(!info.isFile() || !privateMode(info,0o600) || info.size>limit) throw new CaptureError('profile ownership marker is unsafe'); const data=Buffer.alloc(info.size); await handle.read(data,0,data.length,0); return data.toString('utf8'); } catch(error) { if(error instanceof CaptureError) throw error; throw new CaptureError('profile ownership marker is unsafe'); } finally { await handle?.close(); } }
function processAlive(pid) { try { process.kill(pid,0); return true; } catch(error) { return error.code==='EPERM'; } }
async function prepareProfile(input) { let profile=resolve(input||join(process.env.HOME||tmpdir(),'.tad-browser/local-wiki-profile')); if(defaultProfile(profile)) throw new CaptureError('default Chrome profile is forbidden'); let info; try { info=await lstat(profile); } catch {} if(info){ if(!info.isDirectory() || info.isSymbolicLink() || !privateMode(info,0o700)) throw new CaptureError('profile directory is unsafe'); } else { await mkdir(profile,{recursive:true,mode:0o700}); await chmod(profile,0o700); }
  profile=await realpath(profile); if(defaultProfile(profile)) throw new CaptureError('default Chrome profile is forbidden'); const marker=join(profile,MARKER); if(info) { let value; try { value=JSON.parse(await readPrivateRegular(marker)); } catch(error) { if(error instanceof CaptureError) throw error; throw new CaptureError('profile ownership marker is invalid'); } if(value?.magic!=='tad-local-wiki-profile' || value.path!==profile || !Number.isInteger(value.pid) || value.pid<=0 || !Number.isInteger(value.port) || value.port<0 || typeof value.started_at!=='string') throw new CaptureError('profile ownership marker is invalid'); if(processAlive(value.pid)) throw new CaptureError('owned Chrome profile is already in use'); }
  return {profile,marker,existing:Boolean(info)};
}
async function clearActivePort(profile) { const file=join(profile,ACTIVE_PORT); try { const info=await lstat(file); if(!info.isFile() || info.isSymbolicLink()) throw new CaptureError('DevTools state is unsafe'); await unlink(file); } catch(error) { if(error?.code==='ENOENT') return; throw error; } }
async function discoveredPort(profile) { const text=await readFile(join(profile,ACTIVE_PORT),'utf8'); const [raw]=text.split(/\r?\n/,1); return portNumber(raw); }
async function waitForReady(profile, requestedPort) { const deadline=Date.now()+TIMEOUT; while(Date.now()<deadline) { try { const port=requestedPort===0 ? await discoveredPort(profile) : requestedPort; await discover(port); return port; } catch { await sleep(100); } } throw new CaptureError('Chrome CDP did not become ready'); }
async function writeMarker(path, value, existing) { let handle; try { handle=await open(path,FS.O_WRONLY|FS.O_CREAT|FS.O_NOFOLLOW|(existing?FS.O_TRUNC:FS.O_EXCL),0o600); await handle.writeFile(value); await handle.chmod(0o600); await handle.sync(); } catch { throw new CaptureError('could not safely publish profile ownership'); } finally { await handle?.close(); } }
export async function launch(options){ const url=httpsUrl(options.url||'about:blank',true); const requested=options.port===null?0:portNumber(options.port); const {profile,marker,existing}=await prepareProfile(options.profile); if(requested && !(await unused(requested))) throw new CaptureError('requested port is occupied'); await clearActivePort(profile); const chrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'; const args=[`--remote-debugging-address=${LOOPBACK}`,`--remote-debugging-port=${requested}`,`--user-data-dir=${profile}`, ...(options.headless?['--headless=new']:[]),url]; const child=spawn(chrome,args,{detached:true,stdio:'ignore'}); child.unref(); const port=await waitForReady(profile,requested); await writeMarker(marker,JSON.stringify({magic:'tad-local-wiki-profile',path:profile,pid:child.pid,port,started_at:new Date().toISOString()})+'\n',existing); console.log(`pid=${child.pid} port=${port} profile=${profile}`); return {pid:child.pid,port,profile}; }
async function main(){const o=parse(process.argv.slice(2)); if(o.command==='launch') return launch(o); if(o.port===null) throw new CaptureError('--port is required'); const port=portNumber(o.port); const targets=await discover(port); if(o.command==='tabs'){const pages=publicTabs(targets); console.log(o.json?JSON.stringify(pages):pages.map(t=>`${t.id}\t${t.title}\t${t.url}`).join('\n'));return;} const target=selectTab(targets,o.tab,true); const ws=validateWsUrl(target.webSocketDebuggerUrl,port); const transport=await new CdpTransport(ws).connect(); try{const result=await captureAndImport({...o,port,explicitPort:true,discover},transport); console.log(result.path||'dry-run');}finally{transport.close();}}
if(import.meta.main) main().catch(error=>{console.error(`browser-capture: ${error instanceof CaptureError ? error.message : 'capture failed'}`);process.exitCode=2;});
