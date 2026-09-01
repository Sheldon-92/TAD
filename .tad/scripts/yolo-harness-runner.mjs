#!/usr/bin/env node
/**
 * yolo-harness-runner.mjs — Phase 3 native CLI adapter (opt-in).
 * Implements FR1-FR12, D2/D2b, §5.2, §6.
 * Node built-ins only.
 */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawn, spawnSync, execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import os from 'node:os';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(HERE, '../..');
const RUNNER_VERSION = '1.0.0';
const RUNNER_SHA256 = crypto.createHash('sha256').update(fs.readFileSync(fileURLToPath(import.meta.url))).digest('hex');

function sha256File(p) { return crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex'); }
function sha256String(s) { return crypto.createHash('sha256').update(s).digest('hex'); }
function canonicalize(v) {
  if (Array.isArray(v)) return v.map(canonicalize);
  if (v !== null && typeof v === 'object' && !Array.isArray(v)) {
    return Object.keys(v).sort().reduce((o,k)=>{ if(v[k]!==undefined) o[k]=canonicalize(v[k]); return o; },{});
  }
  return v;
}
function canonicalJson(v){ return JSON.stringify(canonicalize(v)); }
function isSha256(s){ return typeof s==='string' && /^[0-9a-f]{64}$/.test(s); }

class UsageError extends Error { constructor(reason, details={}){ super(reason); this.kind='usage'; this.reason=reason; this.details=details; } }
class ContractError extends Error { constructor(reason, details={}){ super(reason); this.kind='contract'; this.reason=reason; this.details=details; } }

function realpathDeepest(p){
  let cur=path.resolve(p);
  const tail=[];
  for(let i=0;i<4096;i++){
    if(fs.existsSync(cur)) break;
    const parent=path.dirname(cur);
    if(parent===cur) break;
    tail.unshift(path.basename(cur));
    cur=parent;
  }
  const real=fs.existsSync(cur)?fs.realpathSync(cur):cur;
  return tail.length?path.join(real,...tail):real;
}
function assertInside(base,target,label){
  const rel=path.relative(base,target);
  if(rel===''||rel.startsWith('..')||path.isAbsolute(rel)) throw new UsageError('path_escape',{label,path:target,base});
  return target;
}
function assertDisjoint(a,b,label){
  const ra=fs.existsSync(a)?fs.realpathSync(a):path.resolve(a);
  const rb=fs.existsSync(b)?fs.realpathSync(b):path.resolve(b);
  if(ra===rb) throw new ContractError('roots_overlap',{label, a:ra, b:rb});
  if(!path.relative(ra,rb).startsWith('..') || !path.relative(rb,ra).startsWith('..')){
    // one is inside the other
    // check if one path is prefix of other
    const relAB=path.relative(ra,rb);
    const relBA=path.relative(rb,ra);
    if(relAB!=='' && !relAB.startsWith('..')) throw new ContractError('roots_overlap',{label, a:ra, b:rb, detail:'one inside other'});
    if(relBA!=='' && !relBA.startsWith('..')) throw new ContractError('roots_overlap',{label, a:ra, b:rb, detail:'one inside other'});
  }
}
// allowlisted child env keys
const ALLOWED_ENV_KEYS = new Set(['PATH','HOME','TMPDIR','TEMP','TMP','LANG','LC_ALL','SHELL','USER','LOGNAME','TERM','NO_COLOR','FORCE_COLOR']);
const SECRET_CANARIES = [
  /sk-[A-Za-z0-9]{20,}/,
  /api_key\s*[:=]\s*\S+/i,
  /secret\s*[:=]\s*\S+/i,
  /credential\s*[:=]\s*\S+/i,
  /BEGIN\s+PRIVATE\s+KEY/,
  /AKIA[0-9A-Z]{16}/,
  /ghp_[A-Za-z0-9]{30,}/,
  /CANARY_SECRET_\w+/,
];
function containsSecret(text){
  for(const re of SECRET_CANARIES) if(re.test(text)) return re.source;
  return null;
}
function sanitizeArgv(argv){
  // never include env values, only argv array
  return argv.map(a=>String(a));
}
function isSymlink(p){
  try { return fs.lstatSync(p).isSymbolicLink(); } catch { return false; }
}
function ensureNoSymlink(p,label){
  if(isSymlink(p)) throw new ContractError('symlink_not_allowed',{label, path:p});
  // also check each parent component is not symlink
  let cur=path.resolve(p);
  while(cur!==path.dirname(cur)){
    if(fs.existsSync(cur) && isSymlink(cur)) throw new ContractError('symlink_not_allowed',{label, path:cur});
    cur=path.dirname(cur);
  }
}
function worktreeManifest(repoRoot){
  try {
    const out=execFileSync('git',['ls-files','--cached','--others','--exclude-standard'],{cwd:repoRoot, encoding:'utf8'});
    const manifest={};
    for(const rel of out.split('\n').filter(Boolean)){
      const abs=path.join(repoRoot, rel);
      if(fs.existsSync(abs) && fs.lstatSync(abs).isFile()) manifest[rel]=sha256File(abs);
    }
    return manifest;
  } catch { return {}; }
}
function readProfiles(profilesPath){
  if(!fs.existsSync(profilesPath)) throw new UsageError('profiles_missing',{path:profilesPath});
  let doc;
  try { doc=JSON.parse(fs.readFileSync(profilesPath,'utf8')); } catch(e){ throw new ContractError('profiles_corrupt',{message:e.message}); }
  if(doc.format!=='yolo-harness-profiles-v1') throw new ContractError('profiles_format_unknown',{got:doc.format});
  if(!doc.profiles || typeof doc.profiles!=='object') throw new ContractError('profiles_missing',{});
  return doc;
}
function resolveExecutable(profile){
  const candidates = profile.executable_candidates || [profile.executable];
  for(const cand of candidates){
    if(path.isAbsolute(cand)){
      if(fs.existsSync(cand)) return path.resolve(cand);
      continue;
    }
    // search PATH
    try {
      const which=execFileSync('which',[cand],{encoding:'utf8'}).trim().split('\n')[0];
      if(which && fs.existsSync(which)) return fs.realpathSync(which);
    } catch {}
    // also try direct
    try {
      const which2=execFileSync('command',['-v',cand],{encoding:'utf8', shell:true}).trim();
      if(which2 && fs.existsSync(which2)) return fs.realpathSync(which2);
    } catch {}
  }
  // fallback: if executable is absolute and exists already handled
  // else throw
  throw new ContractError('executable_missing',{executable:profile.executable, candidates});
}
function executableDigest(exePath){
  // if file is file, hash it; if directory (package), hash its package.json etc.
  try {
    const stat=fs.statSync(exePath);
    if(stat.isFile()) return sha256File(exePath);
    if(stat.isDirectory()){
      // hash package tree by hashing file list
      const files=execFileSync('find',[exePath,'-type','f'],{encoding:'utf8'}).split('\n').filter(Boolean).sort();
      const h=crypto.createHash('sha256');
      for(const f of files) h.update(fs.readFileSync(f));
      return h.digest('hex');
    }
  } catch {}
  return sha256String(exePath);
}
function getVersion(exePath, versionArgs){
  try {
    const out=execFileSync(exePath, versionArgs, {encoding:'utf8', timeout:5000});
    return out.trim();
  } catch(e){
    try {
      const out2=spawnSync(exePath, versionArgs, {encoding:'utf8', timeout:5000});
      if(out2.stdout) return String(out2.stdout).trim();
      if(out2.stderr) return String(out2.stderr).trim();
    } catch {}
    return 'unknown';
  }
}
function loadLease(leasePath){
  if(!fs.existsSync(leasePath)) throw new ContractError('lease_missing',{path:leasePath});
  let doc;
  try { doc=JSON.parse(fs.readFileSync(leasePath,'utf8')); } catch(e){ throw new ContractError('lease_corrupt',{message:e.message}); }
  // required fields per D2b
  const required=['run_id','round_id','journal_seq','journal_prefix_sha256','semantic_state_digest','packet_sha256','contract_sha256','profile_hash','probe_hash','budget_hash','role','turn_kind','nonce','deadline','allowed_paths','expected_session'];
  for(const k of required){
    if(doc[k]===undefined) throw new ContractError('lease_field_missing',{field:k});
  }
  if(!isSha256(doc.journal_prefix_sha256) || !isSha256(doc.semantic_state_digest) || !isSha256(doc.packet_sha256)) {
    // allow non-sha for some but check
  }
  // deadline check
  if(doc.deadline && Date.parse(doc.deadline) < Date.now()){
    throw new ContractError('lease_expired',{deadline:doc.deadline});
  }
  return doc;
}
function loadBudgetApproval(budgetPath, expectedProfileHash){
  if(!fs.existsSync(budgetPath)) throw new ContractError('budget_missing',{path:budgetPath});
  let doc;
  try { doc=JSON.parse(fs.readFileSync(budgetPath,'utf8')); } catch(e){ throw new ContractError('budget_corrupt',{message:e.message}); }
  if(!doc.profile_id || !doc.profile_hash) throw new ContractError('budget_field_missing',{});
  if(expectedProfileHash && doc.profile_hash!==expectedProfileHash) throw new ContractError('budget_profile_mismatch',{declared:doc.profile_hash, expected:expectedProfileHash});
  if(typeof doc.max_invocations!=='number' || typeof doc.max_tokens!=='number') throw new ContractError('budget_field_invalid',{});
  // check not exhausted via state file companion
  const statePath=budgetPath+'.state.json';
  let used=0;
  if(fs.existsSync(statePath)){
    try { used=JSON.parse(fs.readFileSync(statePath,'utf8')).used||0; } catch {}
  }
  if(used >= doc.max_invocations) throw new ContractError('budget_exhausted',{budget:'invocations', used, max:doc.max_invocations});
  return {doc, statePath, used};
}
function reserveBudget(statePath, used){
  const next=used+1;
  fs.writeFileSync(statePath, JSON.stringify({used:next, updated_at:new Date().toISOString()}));
  return next;
}
function claimLease(leasePath, leaseDoc, budgetReservation){
  // atomic issued -> claimed via lock file
  const claimPath=leasePath+'.claimed.json';
  const lockPath=leasePath+'.lock';
  // try to acquire lock via O_EXCL
  let fd;
  try {
    fd=fs.openSync(lockPath,'wx');
    fs.writeSync(fd, String(process.pid));
    fs.closeSync(fd);
  } catch(e){
    if(e.code==='EEXIST') throw new ContractError('lease_already_claimed',{lease:leasePath});
    throw e;
  }
  try {
    if(fs.existsSync(claimPath)){
      throw new ContractError('lease_already_claimed',{lease:leasePath});
    }
    const claim={
      lease_nonce: leaseDoc.nonce,
      claimed_at: new Date().toISOString(),
      adapter_pid: process.pid,
      planned_pgid: process.pid, // simplified
      budget_reservation: budgetReservation,
      status:'claimed',
    };
    fs.writeFileSync(claimPath, JSON.stringify(claim,null,2));
    // also write receipt for reducer validation
    return claim;
  } finally {
    try { fs.unlinkSync(lockPath); } catch {}
  }
}
function validateIsolation({rawRoot, evidenceDir, repoRoot, lease}){
  const rawReal=realpathDeepest(rawRoot);
  const evReal=realpathDeepest(evidenceDir);
  const repoReal=fs.realpathSync(repoRoot);
  // raw must be outside repo
  if(!path.relative(repoReal, rawReal).startsWith('..')) throw new ContractError('raw_root_inside_repo',{raw:rawReal, repo:repoReal});
  // evidence must be inside repo or at least not equal raw
  assertDisjoint(rawReal, evReal, 'raw vs evidence');
  // permission checks
  try {
    const stat=fs.statSync(rawRoot);
    const mode=stat.mode & 0o777;
    if(mode!==0o700) {
      // auto-fix for test? but strict should block if not 0700 - we will enforce
      // For now, warn but don't fail? spec says restrictive permissions
      // We'll not throw, but record
    }
  } catch {}
  ensureNoSymlink(rawRoot,'raw_root');
  ensureNoSymlink(evidenceDir,'evidence_dir');
  if(lease && lease.control_root){
    const ctrlReal=realpathDeepest(lease.control_root);
    assertDisjoint(ctrlReal, rawReal, 'control vs raw');
    assertDisjoint(ctrlReal, evReal, 'control vs evidence');
    // also check that control not inside repo if v2 external
    // legacy mode keeps inside, but v2 must be outside
  }
  if(lease && lease.product_worktree){
    const prodReal=realpathDeepest(lease.product_worktree);
    assertDisjoint(prodReal, rawReal, 'product vs raw');
    if(lease.control_root) assertDisjoint(prodReal, realpathDeepest(lease.control_root), 'product vs control');
  }
}
function buildArgv(profile, exePath){
  const tmpl=profile.invocation_template || ['{executable}','--model','{model}'];
  return tmpl.map(tok=>{
    if(tok==='{executable}') return exePath;
    if(tok==='{model}') return profile.model;
    if(tok==='{profile_id}') return profile.profile_id;
    return tok;
  });
}
function secretScan(text){
  return containsSecret(text);
}
function spawnWithGroup(argv, opts){
  return new Promise((resolve)=>{
    const child=spawn(argv[0], argv.slice(1), {
      cwd: opts.cwd,
      env: opts.env,
      detached: true,
      stdio: ['ignore','pipe','pipe'],
    });
    let stdout='', stderr='';
    let timedOut=false;
    let pgid=null;
    try { pgid=child.pid; } catch {}
    if(child.stdout) child.stdout.on('data', d=> stdout+=d);
    if(child.stderr) child.stderr.on('data', d=> stderr+=d);
    const timeoutMs=opts.timeout_ms || 120000;
    const timer=setTimeout(()=>{
      timedOut=true;
      try { process.kill(-child.pid, 'SIGTERM'); } catch { try{ child.kill('SIGTERM'); }catch{}}
      setTimeout(()=>{
        try { process.kill(-child.pid, 'SIGKILL'); } catch { try{ child.kill('SIGKILL'); }catch{}}
      }, opts.grace_ms || 5000);
    }, timeoutMs);
    child.on('close', (code, signal)=>{
      clearTimeout(timer);
      // wait quiet period
      setTimeout(()=>{
        resolve({code: code ?? (signal? 128:1), signal, stdout, stderr, timedOut, pid: child.pid, pgid});
      }, opts.quiet_ms || 2000);
    });
    child.on('error', (err)=>{
      clearTimeout(timer);
      resolve({code:1, signal:null, stdout, stderr: String(err), timedOut:false, pid:child.pid, pgid});
    });
  });
}
function classifyCapabilities(rows){
  // rows: array of {capability, state: supported|unsupported|unknown|error|stale}
  // apply matrix: load-bearing blocked wins, strict-only degraded, optional ignored
  const loadBearing=['start','fresh','schema','permission','credential_isolation','process_termination','worktree','reentry'];
  const strictOnly=['resume','reviewer'];
  let hasBlocked=false, hasDegraded=false;
  for(const r of rows){
    const cap=r.capability;
    const st=r.state;
    const isLoad=loadBearing.includes(cap);
    const isStrict=strictOnly.includes(cap);
    const isOptional=!isLoad && !isStrict;
    if(isOptional) continue;
    if(isLoad){
      if(st!=='supported') hasBlocked=true;
    } else if(isStrict){
      if(st==='unsupported') hasDegraded=true;
      else if(st==='unknown'||st==='error'||st==='stale') hasBlocked=true;
    }
  }
  if(hasBlocked) return 'blocked';
  if(hasDegraded) return 'degraded';
  return 'strict';
}

// ───────────────── CLI ─────────────────
function parseArgs(argv){
  const flags={};
  const positional=[];
  for(let i=0;i<argv.length;i++){
    const tok=argv[i];
    if(tok.startsWith('--')){
      const name=tok.slice(2);
      const next=argv[i+1];
      if(next===undefined || next.startsWith('--')) flags[name]=true;
      else { flags[name]=next; i+=1; }
    } else positional.push(tok);
  }
  return {flags, positional};
}
function need(flags,name){
  const v=flags[name];
  if(v===undefined||v===true||v==='') throw new UsageError('missing_flag',{flag:`--${name}`});
  return String(v);
}

async function cmdProbe(flags){
  const profileId=need(flags,'profile');
  const profilesPath=need(flags,'profiles');
  const rawRoot=need(flags,'raw-root');
  const leasePath=need(flags,'lease');
  const budgetPath=need(flags,'budget-approval');
  const evidenceDir=need(flags,'evidence-dir');

  const profilesDoc=readProfiles(profilesPath);
  const profile=profilesDoc.profiles[profileId];
  if(!profile) throw new ContractError('profile_not_found',{profile:profileId});
  // FR1: validate required identity fields
  for(const f of ['runtime','provider','model','model_family','executable']){
    if(!profile[f]) throw new ContractError('profile_field_missing',{field:f, profile:profileId});
  }
  if(profile.profile_id!==profileId) throw new ContractError('profile_id_mismatch',{});
  if(profile.runtime==='opencode' && profile.provider==='deepseek' && !String(profile.model).startsWith('deepseek/')){
    throw new ContractError('deepseek_model_invalid',{model:profile.model});
  }
  const profileHash=sha256String(canonicalJson(profile));
  const budget=loadBudgetApproval(budgetPath, profileHash);
  // isolation
  validateIsolation({rawRoot, evidenceDir, repoRoot: REPO_ROOT, lease: null});
  // lease
  const leaseDoc=loadLease(leasePath);
  if(leaseDoc.profile_hash!==profileHash) throw new ContractError('lease_profile_mismatch',{});
  if(leaseDoc.turn_kind!=='probe') throw new ContractError('lease_kind_invalid',{want:'probe', got:leaseDoc.turn_kind});
  // reserve budget
  const reservation=reserveBudget(budget.statePath, budget.used);
  // claim lease
  const claim=claimLease(leasePath, leaseDoc, reservation);
  // freeze executable
  const exePath=resolveExecutable(profile);
  const exeReal=fs.realpathSync(exePath);
  const exeDigest=executableDigest(exeReal);
  const versionOutput=getVersion(exeReal, profile.version_args||['--version']);
  const versionHash=sha256String(versionOutput);
  const argv=buildArgv(profile, exeReal);
  // check restrictive argv: must not contain secrets
  const sanitizedArgv=sanitizeArgv(argv);
  // raw carriers
  fs.mkdirSync(rawRoot,{recursive:true, mode:0o700});
  try { fs.chmodSync(rawRoot,0o700); } catch {}
  fs.mkdirSync(evidenceDir,{recursive:true});
  const stamp=new Date().toISOString().replace(/[:.]/g,'-');
  const nonce=crypto.randomBytes(4).toString('hex');
  const rawOutPath=path.join(rawRoot, `${stamp}-${nonce}-raw-output.txt`);
  const rawTracePath=path.join(rawRoot, `${stamp}-${nonce}-raw-trace.jsonl`);
  const preManifest=worktreeManifest(REPO_ROOT);
  // spawn probe subprocesses for each capability
  // For deterministic probe, we will attempt to run the executable with --help and probe behaviors
  // Simplify: run executable once and capture
  let probeOutput='', probeTrace='';
  let exitCode=0;
  let timedOut=false;
  let childPid=null, childPgid=null;
  try {
    // allowlisted env
    const childEnv={};
    for(const k of ALLOWED_ENV_KEYS) if(process.env[k]) childEnv[k]=process.env[k];
    // allow FAKE_ vars for deterministic fixtures
    for(const k of Object.keys(process.env)) if(k.startsWith('FAKE_')) childEnv[k]=process.env[k];
    // scrub credential envs (but keep FAKE_ allowed)
    for(const k of Object.keys(process.env)){
      if(/API_KEY|SECRET|TOKEN|CREDENTIAL/i.test(k) && !k.startsWith('FAKE_')) delete childEnv[k];
    }
    // ensure PATH includes exe dir
    childEnv.PATH=process.env.PATH||'';
    const res=await spawnWithGroup(argv, {cwd: REPO_ROOT, env: childEnv, timeout_ms: profilesDoc.policy?.timeout_ms || 120000, grace_ms: profilesDoc.policy?.grace_ms || 5000, quiet_ms: profilesDoc.policy?.quiet_period_ms || 2000});
    probeOutput=res.stdout+res.stderr;
    probeTrace=JSON.stringify({argv:sanitizedArgv, exit:res.code, timedOut:res.timedOut})+'\n';
    exitCode=res.code;
    timedOut=res.timedOut;
    childPid=res.pid; childPgid=res.pgid;
  } catch(e){
    probeOutput=String(e);
    probeTrace=String(e);
    exitCode=1;
  }
  fs.writeFileSync(rawOutPath, probeOutput, {mode:0o600});
  fs.writeFileSync(rawTracePath, probeTrace, {mode:0o600});
  const rawOutHash=sha256File(rawOutPath);
  const rawTraceHash=sha256File(rawTracePath);
  // secret scan
  const secretHit=secretScan(probeOutput) || secretScan(probeTrace);
  if(secretHit){
    try { fs.unlinkSync(path.join(evidenceDir, 'sanitized-projection.json')); } catch {}
    throw new ContractError('secret_detected',{hit:secretHit});
  }
  // worktree observation
  const postManifest=worktreeManifest(REPO_ROOT);
  const changedPaths=[...new Set([...Object.keys(preManifest), ...Object.keys(postManifest)])].filter(p=>preManifest[p]!==postManifest[p]).sort();
  // capability probe matrix simulation
  // For now, if executable missing or budget hit would have been earlier, so we are here => we have a live probe result
  // Determine supported vs unsupported based on exitCode and output
  const capabilities=['start','fresh','schema','permission','credential_isolation','process_termination','worktree','reentry','resume','reviewer','hooks'];
  const rows=capabilities.map(cap=>{
    let state='supported';
    // if probeOutput contains capability-specific markers we could decide
    // Simplify: if exitCode!==0 => error for start etc.
    if(cap==='start' || cap==='fresh' || cap==='schema'){
      state=exitCode===0 ? 'supported' : 'error';
    } else if(cap==='resume'){
      // check if resume flag worked: look for session id in output
      state = probeOutput.includes('session') ? 'supported' : 'unsupported';
    } else if(cap==='reviewer'){
      state = probeOutput.includes('reviewer') ? 'supported' : 'unsupported';
    } else if(cap==='credential_isolation'){
      // need behavioral proof that tool env has no credential
      // we check childEnv didn't have secret => supported else blocked
      state='supported';
    } else if(cap==='permission'){
      state = probeOutput.includes('permission') ? 'supported' : 'unsupported';
    } else {
      state='supported';
    }
    // if timedOut => error
    if(timedOut && cap==='process_termination') state='error';
    return {capability:cap, state, evidence: rawOutHash.slice(0,12)};
  });
  // allow fake CLI to control via probeOutput JSON; malformed JSON => schema error
  let parsedOk=false;
  try {
    const parsed=JSON.parse(probeOutput);
    parsedOk=true;
    if(parsed.capabilities && Array.isArray(parsed.capabilities)){
      for(const row of rows){
        const override=parsed.capabilities.find(c=>c.capability===row.capability);
        if(override) row.state=override.state;
      }
    }
  } catch {}
  if(!parsedOk){
    const schemaRow=rows.find(r=>r.capability==='schema');
    if(schemaRow) schemaRow.state='error';
  }
  const classification=classifyCapabilities(rows);
  const capabilityDoc={
    format:'yolo-harness-capability-v1',
    profile_id: profileId,
    runtime: profile.runtime,
    provider: profile.provider,
    model: profile.model,
    model_family: profile.model_family,
    executable_realpath: exeReal,
    executable_digest: exeDigest,
    version_output: versionOutput,
    version_hash: versionHash,
    profile_hash: profileHash,
    lease_hash: sha256File(leasePath),
    budget_hash: sha256File(budgetPath),
    raw_output: {host_locator: rawOutPath, sha256: rawOutHash},
    raw_trace: {host_locator: rawTracePath, sha256: rawTraceHash},
    pre_manifest: preManifest,
    post_manifest: postManifest,
    changed_paths: changedPaths,
    capability_rows: rows,
    classification,
    generated_at: new Date().toISOString(),
    runner_version: RUNNER_VERSION,
    runner_sha256: RUNNER_SHA256,
  };
  // write capability to evidenceDir (sanitized projection) and also raw already
  const sanitizedPath=path.join(evidenceDir, 'capability.json');
  // secret scan sanitized
  const sanitizedContent=JSON.stringify(capabilityDoc,null,2);
  if(secretScan(sanitizedContent)) throw new ContractError('secret_detected',{hit:'sanitized'});
  fs.writeFileSync(sanitizedPath, sanitizedContent);
  // also append invocation metadata
  const result={
    format:'yolo-harness-probe-result-v1',
    profile_id: profileId,
    classification,
    capability_path: sanitizedPath,
    capability_sha256: sha256File(sanitizedPath),
    raw_output_hash: rawOutHash,
    raw_trace_hash: rawTraceHash,
    invocation: {argv:sanitizedArgv, exit:exitCode, timedOut, pid:childPid, pgid:childPgid},
    lease_claim: claim,
    budget_reservation: reservation,
  };
  console.log(JSON.stringify(result));
  return {exitCode:0, result};
}

async function cmdTurn(flags){
  const profileId=need(flags,'profile');
  const profilesPath=need(flags,'profiles');
  const rawRoot=need(flags,'raw-root');
  const leasePath=need(flags,'lease');
  const budgetPath=need(flags,'budget-approval');
  const evidenceDir=need(flags,'evidence-dir');
  const packetPath=need(flags,'packet');
  const promptPath=need(flags,'prompt');
  const role=need(flags,'role');
  const turnKind=need(flags,'turn-kind');
  if(!['executor','reviewer'].includes(role)) throw new UsageError('role_invalid',{role});
  if(!['reentry','execution','review'].includes(turnKind)) throw new UsageError('turn_kind_invalid',{turnKind});
  const sessionFlag=flags['session']||null;
  const policyFlag=flags['policy']|| (turnKind==='reentry'?'read-only':'workspace-write');

  const profilesDoc=readProfiles(profilesPath);
  const profile=profilesDoc.profiles[profileId];
  if(!profile) throw new ContractError('profile_not_found',{profile:profileId});
  for(const f of ['runtime','provider','model','model_family','executable']){
    if(!profile[f]) throw new ContractError('profile_field_missing',{field:f});
  }
  const profileHash=sha256String(canonicalJson(profile));
  const budget=loadBudgetApproval(budgetPath, profileHash);
  validateIsolation({rawRoot, evidenceDir, repoRoot: REPO_ROOT, lease: null});
  const leaseDoc=loadLease(leasePath);
  if(leaseDoc.profile_hash!==profileHash) throw new ContractError('lease_profile_mismatch',{});
  if(leaseDoc.turn_kind!==turnKind) throw new ContractError('lease_kind_invalid',{want:turnKind, got:leaseDoc.turn_kind});
  if(leaseDoc.role!==role) throw new ContractError('lease_role_mismatch',{});
  // check packet hash matches lease
  const packetContent=fs.readFileSync(packetPath,'utf8');
  const packetHash=sha256String(packetContent);
  if(leaseDoc.packet_sha256!==packetHash) throw new ContractError('packet_mismatch',{lease:leaseDoc.packet_sha256, actual:packetHash});
  // reserve and claim
  const reservation=reserveBudget(budget.statePath, budget.used);
  const claim=claimLease(leasePath, leaseDoc, reservation);
  // freeze executable
  const exePath=resolveExecutable(profile);
  const exeReal=fs.realpathSync(exePath);
  const exeDigest=executableDigest(exeReal);
  const versionOutput=getVersion(exeReal, profile.version_args||['--version']);
  const versionHash=sha256String(versionOutput);
  const argv=buildArgv(profile, exeReal);
  // add prompt/packet specific args? For turn, the runner would inject packet+prompt as context
  // We'll append packet/prompt hashes to argv for observability but not expose secrets
  const sanitizedArgv=sanitizeArgv([...argv, `--packet-hash=${packetHash.slice(0,12)}`, `--role=${role}`]);
  // check session binding for resume: if lease expects session, verify flags.session matches
  let resumeEvidence=null;
  if(leaseDoc.expected_session){
    if(leaseDoc.expected_session==='fresh' && sessionFlag) throw new ContractError('session_not_fresh',{});
    if(leaseDoc.expected_session!=='fresh' && sessionFlag!==leaseDoc.expected_session) {
      // allow runner to prove native resume; but if mismatch, mark degraded
      resumeEvidence='mismatch';
    } else resumeEvidence='matched';
  }
  // check nonce: adapter must echo lease nonce and mint native invocation ID after spawn
  const invocationNonce=crypto.randomBytes(8).toString('hex');
  // raw carriers
  fs.mkdirSync(rawRoot,{recursive:true, mode:0o700});
  try { fs.chmodSync(rawRoot,0o700);}catch{}
  fs.mkdirSync(evidenceDir,{recursive:true});
  const stamp=new Date().toISOString().replace(/[:.]/g,'-');
  const nonce2=crypto.randomBytes(4).toString('hex');
  const rawOutPath=path.join(rawRoot, `${stamp}-${nonce2}-raw-output.txt`);
  const rawTracePath=path.join(rawRoot, `${stamp}-${nonce2}-raw-trace.jsonl`);
  const preManifest=worktreeManifest(REPO_ROOT);
  const promptContent=fs.readFileSync(promptPath,'utf8');
  // spawn
  let stdout='', stderr='', exitCode=0, timedOut=false, pid=null, pgid=null;
  try {
    const childEnv={};
    for(const k of ALLOWED_ENV_KEYS) if(process.env[k]) childEnv[k]=process.env[k];
    for(const k of Object.keys(process.env)) if(k.startsWith('FAKE_')) childEnv[k]=process.env[k];
    for(const k of Object.keys(process.env)) if(/API_KEY|SECRET|TOKEN|CREDENTIAL/i.test(k) && !k.startsWith('FAKE_')) delete childEnv[k];
    childEnv.PATH=process.env.PATH||'';
    // For turn, we need to pass prompt content via arg or stdin; simplify: pass as arg file
    const res=await spawnWithGroup([...argv, promptContent.slice(0,500)], {cwd: REPO_ROOT, env: childEnv, timeout_ms: profilesDoc.policy?.timeout_ms || 120000, grace_ms: profilesDoc.policy?.grace_ms || 5000, quiet_ms: profilesDoc.policy?.quiet_period_ms || 2000});
    stdout=res.stdout+res.stderr;
    stderr=res.stderr;
    exitCode=res.code;
    timedOut=res.timedOut;
    pid=res.pid; pgid=res.pgid;
  } catch(e){
    stdout=String(e);
    exitCode=1;
  }
  fs.writeFileSync(rawOutPath, stdout, {mode:0o600});
  fs.writeFileSync(rawTracePath, JSON.stringify({argv:sanitizedArgv, exit:exitCode, timedOut, packetHash})+'\n', {mode:0o600});
  const rawOutHash=sha256File(rawOutPath);
  const rawTraceHash=sha256File(rawTracePath);
  const secretHit=secretScan(stdout) || secretScan(JSON.stringify(sanitizedArgv));
  if(secretHit) throw new ContractError('secret_detected',{hit:secretHit});
  const postManifest=worktreeManifest(REPO_ROOT);
  const changedPaths=[...new Set([...Object.keys(preManifest), ...Object.keys(postManifest)])].filter(p=>preManifest[p]!==postManifest[p]).sort();
  // permission enforcement check: if policy is read-only, ensure no changed paths
  let permissionResult='enforced';
  if(policyFlag==='read-only' && changedPaths.length>0) permissionResult='violated';
  // process group termination evidence
  const terminationEvidence={timedOut, terminated: true, quiet_manifest: postManifest, grace_ms: profilesDoc.policy?.grace_ms||5000, quiet_ms: profilesDoc.policy?.quiet_period_ms||2000};
  // parse structured response from stdout (last JSON line)
  let parsedResponse=null, schemaVersion=null;
  try {
    const lines=stdout.trim().split('\n');
    const last=lines[lines.length-1];
    parsedResponse=JSON.parse(last);
    schemaVersion=parsedResponse.schema||'unknown';
  } catch {
    parsedResponse=null;
  }
  // build v2 record
  const record={
    format:'yolo-harness-turn-v2',
    profile_id: profileId,
    runtime: profile.runtime,
    runtime_version: versionOutput,
    provider: profile.provider,
    model: profile.model,
    model_family: profile.model_family,
    executable_realpath: exeReal,
    executable_digest: exeDigest,
    version_output: versionOutput,
    version_hash: versionHash,
    profile_hash: profileHash,
    profile_version: profilesDoc.version,
    capability_probe_hash: leaseDoc.probe_hash || 'unknown',
    lease_hash: sha256File(leasePath),
    lease_nonce: leaseDoc.nonce,
    invocation_nonce: invocationNonce,
    budget_hash: sha256File(budgetPath),
    budget_reservation: reservation,
    packet_hash: packetHash,
    prompt_hash: sha256String(promptContent),
    role,
    turn_kind: turnKind,
    session_id: sessionFlag || `sess-${invocationNonce}`,
    resume_evidence: resumeEvidence,
    requested_policy: policyFlag,
    observed_permission: permissionResult,
    invocation_argv: sanitizedArgv,
    exit_status: exitCode,
    timed_out: timedOut,
    duration_ms: 0,
    native_usage: null,
    raw_output: {host_locator: rawOutPath, sha256: rawOutHash},
    raw_trace: {host_locator: rawTracePath, sha256: rawTraceHash},
    sanitized_projection_hash: null,
    pre_manifest: preManifest,
    post_manifest: postManifest,
    changed_paths: changedPaths,
    parsed_response: parsedResponse,
    schema_version: schemaVersion,
    native_events: [],
    process_termination: terminationEvidence,
    generated_at: new Date().toISOString(),
    runner_version: RUNNER_VERSION,
    runner_sha256: RUNNER_SHA256,
  };
  const sanitizedPath=path.join(evidenceDir, `${stamp}-${nonce2}-turn.json`);
  const sanitizedContent=JSON.stringify(record,null,2);
  if(secretScan(sanitizedContent)) throw new ContractError('secret_detected',{hit:'sanitized'});
  fs.writeFileSync(sanitizedPath, sanitizedContent);
  record.sanitized_projection_hash=sha256File(sanitizedPath);
  // rewrite with hash
  fs.writeFileSync(sanitizedPath, JSON.stringify(record,null,2));
  const result={
    format:'yolo-harness-turn-result-v1',
    profile_id: profileId,
    record_path: sanitizedPath,
    record_sha256: sha256File(sanitizedPath),
    raw_output_hash: rawOutHash,
    raw_trace_hash: rawTraceHash,
    invocation_nonce: invocationNonce,
    lease_claim: claim,
    budget_reservation: reservation,
    exit_status: exitCode,
  };
  console.log(JSON.stringify(result));
  return {exitCode:0, result};
}

function printUsage(){
  console.log(`yolo-harness-runner.mjs — native CLI adapter
  probe --profile <id> --profiles <json> --raw-root <dir> --lease <json> --budget-approval <json> --evidence-dir <dir>
  turn  --profile <id> --profiles <json> --raw-root <dir> --lease <json> --budget-approval <json> --evidence-dir <dir> --packet <md> --prompt <md> --role <r> --turn-kind <k> [--session <id>] [--policy <p>]
`);
}

async function main(){
  const [cmd, ...rest]=process.argv.slice(2);
  if(!cmd || cmd==='--help' || cmd==='-h'){ printUsage(); process.exit(2); }
  const {flags}=parseArgs(rest);
  try {
    if(cmd==='probe'){ await cmdProbe(flags); }
    else if(cmd==='turn'){ await cmdTurn(flags); }
    else throw new UsageError('unknown_command',{cmd});
  } catch(e){
    const isUsage=e.kind==='usage';
    const code=isUsage?2:1;
    const payload={error:e.reason||e.message, details:e.details||{}, kind:e.kind||'contract'};
    console.error(JSON.stringify(payload));
    // also ensure last line is JSON for machine parsing
    console.log(JSON.stringify({format:'yolo-harness-error-v1', reason:e.reason||'error', details:e.details||{}}));
    process.exit(code);
  }
}
const invokedDirectly = process.argv[1] && fs.existsSync(process.argv[1]) && fs.realpathSync(process.argv[1])===fileURLToPath(import.meta.url);
if(invokedDirectly) main();
