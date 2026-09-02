import assert from 'node:assert/strict';
import test from 'node:test';
import vm from 'node:vm';
import { cp, mkdir, mkdtemp, readFile, rm, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createServer } from 'node:net';
import { boundedJson, CaptureError, CdpTransport, PAGE_FUNCTION, captureAndImport, httpsUrl, isYoutubeUrl, languageCode, launch, portNumber, publicTabs, selectTab, validateWsUrl } from '../scripts/browser-capture.mjs';

const ROOT = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const page = { id:'page-1', type:'page', title:'Visible page', url:'https://example.test/article', webSocketDebuggerUrl:'ws://127.0.0.1:9223/devtools/page/page-1' };
const encoder = new TextEncoder();
function fake(value) { return { async call(method) { if(method==='Runtime.evaluate') return {result:{objectId:'global'}}; if(method==='Runtime.callFunctionOn') return {result:{value}}; throw new Error('unexpected call'); }, close() {} }; }
async function repo() { const root=await mkdtemp(join(tmpdir(),'browser-capture-test-')); await mkdir(join(root,'research/raw/articles'),{recursive:true}); await mkdir(join(root,'research/raw/transcripts'),{recursive:true}); await mkdir(join(root,'research/scripts'),{recursive:true}); await cp(join(ROOT,'research/scripts/import-clip.py'),join(root,'research/scripts/import-clip.py')); return root; }
function response(body, { url='http://127.0.0.1:9223/json/list', length=null }={}) { const bytes=typeof body==='string' ? encoder.encode(body) : body; let emitted=false; return {ok:true,url,headers:{get:key=>key==='content-length' && length!==null ? String(length) : null},body:{getReader:()=>({read:async()=>emitted?{done:true}:{done:(emitted=true,false),value:bytes}})}}; }

test('strict URL, port, language, selection and exact WebSocket validation', () => {
  assert.equal(httpsUrl('https://example.test/a'),'https://example.test/a');
  assert.throws(()=>httpsUrl('http://example.test'),CaptureError); assert.equal(portNumber('9223'),9223); assert.throws(()=>portNumber('80'),CaptureError);
  assert.equal(languageCode('en-US'),'en-US'); assert.throws(()=>languageCode('en;bad'),CaptureError); assert.equal(isYoutubeUrl('https://www.youtube.com/watch?v=x'),true);
  assert.equal(selectTab([page],null,false).id,'page-1'); assert.throws(()=>selectTab([page,page],null,false),CaptureError); assert.throws(()=>selectTab([page],null,true),CaptureError);
  assert.deepEqual(publicTabs([page]),[{id:'page-1',title:'Visible page',url:'https://example.test/article'}]);
  assert.equal(validateWsUrl(page.webSocketDebuggerUrl,9223),page.webSocketDebuggerUrl);
  for (const value of ['ws://evil.test/devtools/page/x','ws://127.0.0.1:9223/devtools/page/x/extra','ws://127.0.0.1:9223/devtools/page/x?token=x','ws://user@127.0.0.1:9223/devtools/page/x']) assert.throws(()=>validateWsUrl(value,9223),CaptureError);
});

test('page capture uses fixed declaration and internal importer publication', async () => {
  const root=await repo(); try {
    const calls=[]; const transport=fake({ok:true,kind:'page',title:'Rendered Page',url:page.url,summary:'visible',body:'# Rendered Page\n\nA rendered body.'});
    const wrapped={...transport, async call(method,params){calls.push({method,params});return transport.call(method,params);}};
    const result=await captureAndImport({port:9223,tab:'page-1',kind:'page',language:'',repoRoot:root,explicitPort:true,discover:async()=>[page]},wrapped);
    assert.match(result.path,/research\/raw\/articles\/rendered-page\.md/); const text=await readFile(join(root,result.path),'utf8'); assert.match(text,/rendered_page_export/); assert.match(text,/A rendered body/);
    const invoke=calls.find(call=>call.method==='Runtime.callFunctionOn'); assert.equal(invoke.params.functionDeclaration,PAGE_FUNCTION); assert.deepEqual(invoke.params.arguments,[{value:{expectedUrl:page.url,kind:'page',language:''}}]);
  } finally { await rm(root,{recursive:true,force:true}); }
});

test('YouTube capture transforms through importer into timestamp raw transcript', async () => {
  const root=await repo(); const tab={...page,id:'yt',url:'https://www.youtube.com/watch?v=x'}; try {
    const result=await captureAndImport({port:9223,tab:'yt',kind:'youtube',language:'en',repoRoot:root,explicitPort:true,discover:async()=>[tab]},fake({ok:true,kind:'youtube',title:'Transcript',url:tab.url,subtitle_language:'en',body:'**[00:12]** hello'}));
    const text=await readFile(join(root,result.path),'utf8'); assert.match(text,/youtube_transcript/); assert.match(text,/\*\*\[00:12\]/);
  } finally { await rm(root,{recursive:true,force:true}); }
});

test('protocol, returned URL/kind, and extraction negatives publish nothing', async () => {
  const root=await repo(); try {
    const options={port:9223,tab:'page-1',kind:'page',language:'',repoRoot:root,explicitPort:true,discover:async()=>[page]};
    await assert.rejects(()=>captureAndImport(options,fake({ok:false,error:'nope'})),CaptureError);
    await assert.rejects(()=>captureAndImport(options,fake({ok:true,kind:'page',url:'https://example.test/changed',body:'x'})),CaptureError);
    await assert.rejects(()=>captureAndImport(options,fake({ok:true,kind:'youtube',url:page.url,body:'x'})),CaptureError);
    await assert.rejects(()=>captureAndImport({...options,discover:async()=>[{...page,url:'https://example.test/changed'}]},fake({ok:true,kind:'page',url:page.url,body:'x'})),CaptureError);
  } finally { await rm(root,{recursive:true,force:true}); }
});

test('CDP discovery refuses redirects and bounds streamed UTF-8 bytes before parsing', async () => {
  const url='http://127.0.0.1:9223/json/list';
  await assert.rejects(()=>boundedJson(url,async()=>response('[]',{url:'http://127.0.0.1:9223/redirected'})),CaptureError);
  await assert.rejects(()=>boundedJson(url,async()=>response(new Uint8Array(6*1024*1024+1))),CaptureError);
  assert.deepEqual(await boundedJson(url,async()=>response('[{"id":"ok"}]')),[{id:'ok'}]);
});

test('CdpTransport handles injected WebSocket response, protocol error, and close', async () => {
  class Socket {
    static OPEN=1;
    constructor() { this.readyState=0; this.listeners=new Map(); queueMicrotask(()=>{this.readyState=Socket.OPEN;this.emit('open');}); }
    addEventListener(name,callback,{once=false}={}) { const list=this.listeners.get(name)||[]; list.push({callback,once}); this.listeners.set(name,list); }
    emit(name,event={}) { const list=this.listeners.get(name)||[]; this.listeners.set(name,list.filter(item=>!item.once)); for(const item of list) item.callback(event); }
    send(raw) { const request=JSON.parse(raw); if(request.method==='bad') queueMicrotask(()=>this.emit('message',{data:JSON.stringify({id:request.id,error:{message:'bad'}})})); else queueMicrotask(()=>this.emit('message',{data:JSON.stringify({id:request.id,result:{ok:true}})})); }
    close() { this.readyState=3; this.emit('close'); }
  }
  const transport=await new CdpTransport('ws://127.0.0.1:9223/devtools/page/unit',Socket).connect();
  assert.deepEqual(await transport.call('Runtime.evaluate'),{ok:true}); await assert.rejects(()=>transport.call('bad'),CaptureError); transport.close(); await assert.rejects(()=>transport.call('after-close'),CaptureError);
});

test('exact YouTube page function executes in node:vm and detects navigation drift', async () => {
  const initial='https://www.youtube.com/watch?v=captioned'; const payload=JSON.stringify({events:[{tStartMs:12000,segs:[{utf8:'hello world'}]}]});
  const location={href:initial,hostname:'www.youtube.com',pathname:'/watch'};
  const context={URL,TextEncoder,TextDecoder,Uint8Array,JSON,location,document:{title:'Video title',scripts:[],querySelector:()=>null},ytInitialPlayerResponse:{videoDetails:{title:'Video title',author:'Channel'},captions:{playerCaptionsTracklistRenderer:{captionTracks:[{languageCode:'en',baseUrl:'https://www.youtube.com/api/timedtext?v=x'}]}}},fetch:async url=>({headers:{get:()=>String(encoder.encode(payload).byteLength)},body:{getReader:()=>{let done=false;return {read:async()=>done?{done:true}:{done:(done=true,false),value:encoder.encode(payload)}}}}})};
  const fn=vm.runInNewContext(`(${PAGE_FUNCTION})`,context); const result=await fn({expectedUrl:initial,kind:'youtube',language:'en'}); assert.equal(result.ok,true); assert.match(result.body,/\*\*\[00:12\]\*\* hello world/);
  context.fetch=async()=>{location.href='https://www.youtube.com/watch?v=other';return {headers:{get:()=>null},body:{getReader:()=>({read:async()=>({done:true})})}};}; const drift=await fn({expectedUrl:initial,kind:'youtube',language:'en'}); assert.equal(drift.ok,false); assert.equal(drift.error,'page navigation changed');
});

test('native source has no external absolute-path runtime dependency', async () => {
  const source=await readFile(join(ROOT,'research/scripts/browser-capture.mjs'),'utf8'); assert.doesNotMatch(source,/下载md插件|web-to-markdown/);
});

test('launcher rejects default, unowned, unsafe-marker, and occupied profiles before Chrome launch', async () => {
  await assert.rejects(()=>launch({url:'about:blank',profile:'/tmp/Google Chrome/Default',port:9229,headless:true}),CaptureError);
  const root=await mkdtemp(join(tmpdir(),'browser-capture-profile-')); const profile=join(root,'owned'); await mkdir(profile,{mode:0o700});
  try {
    await assert.rejects(()=>launch({url:'about:blank',profile,port:9229,headless:true}),CaptureError);
    await writeFile(join(profile,'.tad-local-wiki-owner.json'),'{}',{mode:0o600}); await assert.rejects(()=>launch({url:'about:blank',profile,port:9229,headless:true}),CaptureError);
    await rm(join(profile,'.tad-local-wiki-owner.json')); await symlink('/tmp',join(profile,'.tad-local-wiki-owner.json')); await assert.rejects(()=>launch({url:'about:blank',profile,port:9229,headless:true}),CaptureError); await rm(join(profile,'.tad-local-wiki-owner.json'));
    const server=createServer(); await new Promise(resolve=>server.listen(9234,'127.0.0.1',resolve)); await assert.rejects(()=>launch({url:'about:blank',profile,port:9234,headless:true}),CaptureError); await new Promise(resolve=>server.close(resolve));
  } finally { await rm(root,{recursive:true,force:true}); }
});
