import assert from 'node:assert/strict';
import test from 'node:test';
import { cp, mkdir, mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createServer } from 'node:net';
import { CaptureError, PAGE_FUNCTION, captureAndImport, httpsUrl, isYoutubeUrl, languageCode, launch, portNumber, selectTab, validateWsUrl } from '../scripts/browser-capture.mjs';

const ROOT = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const page = { id:'page-1', type:'page', title:'Visible page', url:'https://example.test/article', webSocketDebuggerUrl:'ws://127.0.0.1:9223/devtools/page/page-1' };
function fake(value) { return { async call(method) { if(method==='Runtime.evaluate') return {result:{objectId:'global'}}; if(method==='Runtime.callFunctionOn') return {result:{value}}; throw new Error('unexpected call'); }, close() {} }; }
async function repo() { const root=await mkdtemp(join(tmpdir(),'browser-capture-test-')); await mkdir(join(root,'research/raw/articles'),{recursive:true}); await mkdir(join(root,'research/raw/transcripts'),{recursive:true}); await mkdir(join(root,'research/scripts'),{recursive:true}); await cp(join(ROOT,'research/scripts/import-clip.py'),join(root,'research/scripts/import-clip.py')); return root; }

test('strict URL, port, language, selection and WebSocket validation', () => {
  assert.equal(httpsUrl('https://example.test/a'),'https://example.test/a');
  assert.throws(()=>httpsUrl('http://example.test'),CaptureError); assert.equal(portNumber('9223'),9223); assert.throws(()=>portNumber('80'),CaptureError);
  assert.equal(languageCode('en-US'),'en-US'); assert.throws(()=>languageCode('en;bad'),CaptureError); assert.equal(isYoutubeUrl('https://www.youtube.com/watch?v=x'),true);
  assert.equal(selectTab([page],null,false).id,'page-1'); assert.throws(()=>selectTab([page,page],null,false),CaptureError); assert.throws(()=>selectTab([page],null,true),CaptureError);
  assert.equal(validateWsUrl(page.webSocketDebuggerUrl,9223),page.webSocketDebuggerUrl); assert.throws(()=>validateWsUrl('ws://evil.test/devtools/page/x',9223),CaptureError);
});

test('page capture uses fixed declaration and internal importer publication', async () => {
  const root=await repo(); try {
    const calls=[]; const transport=fake({ok:true,kind:'page',title:'Rendered Page',url:page.url,summary:'visible',body:'# Rendered Page\n\nA rendered body.'});
    const wrapped={...transport, async call(method,params){calls.push({method,params});return transport.call(method,params);}};
    const result=await captureAndImport({port:9223,tab:'page-1',kind:'page',language:'',repoRoot:root,explicitPort:true,discover:async()=>[page]},wrapped);
    assert.match(result.path,/research\/raw\/articles\/rendered-page\.md/); const text=await readFile(join(root,result.path),'utf8'); assert.match(text,/rendered_page_export/); assert.match(text,/A rendered body/);
    const invoke=calls.find(call=>call.method==='Runtime.callFunctionOn'); assert.equal(invoke.params.functionDeclaration,PAGE_FUNCTION); assert.equal(invoke.params.arguments[0].value.expectedUrl,page.url);
  } finally { await rm(root,{recursive:true,force:true}); }
});

test('YouTube capture transforms through importer into timestamp raw transcript', async () => {
  const root=await repo(); const tab={...page,id:'yt',url:'https://www.youtube.com/watch?v=x'}; try {
    const result=await captureAndImport({port:9223,tab:'yt',kind:'youtube',language:'en',repoRoot:root,explicitPort:true,discover:async()=>[tab]},fake({ok:true,kind:'youtube',title:'Transcript',url:tab.url,subtitle_language:'en',body:'**[00:12]** hello'}));
    const text=await readFile(join(root,result.path),'utf8'); assert.match(text,/youtube_transcript/); assert.match(text,/\*\*\[00:12\]/);
  } finally { await rm(root,{recursive:true,force:true}); }
});

test('protocol/extraction negatives publish nothing', async () => {
  const root=await repo(); try {
    await assert.rejects(()=>captureAndImport({port:9223,tab:'page-1',kind:'page',language:'',repoRoot:root,explicitPort:true,discover:async()=>[page]},fake({ok:false,error:'nope'})),CaptureError);
    await assert.rejects(()=>captureAndImport({port:9223,tab:'page-1',kind:'page',language:'',repoRoot:root,explicitPort:true,discover:async()=>[{...page,url:'https://example.test/changed'}]},fake({ok:true,body:'x'})),CaptureError);
  } finally { await rm(root,{recursive:true,force:true}); }
});

test('external prior-art project remains restored', async () => {
  const base='/Users/sheldonzhao/01-on progress programs/下载md插件/web-to-markdown';
  const { createHash } = await import('node:crypto'); const digest=async path=>createHash('sha256').update(await readFile(path)).digest('hex');
  assert.equal(await digest(join(base,'popup/popup.js')),'7f873c78a850ed491c087373d18eedf4e3a6f5fedd134627a84f3b05770eee73');
  assert.equal(await digest(join(base,'tests/run.js')),'f8e3556ab78f68fbd78dfba038b89e109e02225e4e6a7be0b95c3eff6ea5d95f');
  await assert.rejects(readFile(join(base,'tests/youtube-capture-contract.test.js')));
});

test('launcher rejects default and occupied profiles without launching Chrome', async () => {
  await assert.rejects(()=>launch({url:'about:blank',profile:'/tmp/Google Chrome/Default',port:9229,headless:true}),CaptureError);
  const server=createServer(); await new Promise(resolve=>server.listen(9234,'127.0.0.1',resolve));
  const root=await mkdtemp(join(tmpdir(),'browser-capture-profile-')); const profile=join(root,'owned');
  try { await assert.rejects(()=>launch({url:'about:blank',profile,port:9234,headless:true}),CaptureError); }
  finally { await new Promise(resolve=>server.close(resolve)); await rm(root,{recursive:true,force:true}); }
});
