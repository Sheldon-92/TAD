#!/usr/bin/env node

import { createInterface } from 'node:readline';
import { execFileSync } from 'node:child_process';
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const PLATFORM_CODES_PATH = join(ROOT, '.tad', 'platform-codes.yaml');
const PACK_REGISTRY_PATH = join(ROOT, '.tad', 'capability-packs', 'pack-registry.yaml');
const TAD_SH_PATH = join(ROOT, 'tad.sh');

function parsePlatformCodes() {
  if (!existsSync(PLATFORM_CODES_PATH)) {
    console.error('Error: .tad/platform-codes.yaml not found');
    process.exit(1);
  }
  const content = readFileSync(PLATFORM_CODES_PATH, 'utf8');
  const platforms = [];
  let current = null;
  for (const line of content.split('\n')) {
    const platformMatch = line.match(/^  ([a-z-]+):$/);
    if (platformMatch) {
      current = { id: platformMatch[1], label: '' };
      platforms.push(current);
      continue;
    }
    if (current && line.match(/^\s+label:/)) {
      current.label = line.replace(/.*label:\s*"?/, '').replace(/"?\s*$/, '');
    }
  }
  return platforms;
}

function parsePackRegistry() {
  if (!existsSync(PACK_REGISTRY_PATH)) {
    return [];
  }
  const content = readFileSync(PACK_REGISTRY_PATH, 'utf8');
  const packs = [];
  let current = null;
  for (const line of content.split('\n')) {
    const nameMatch = line.match(/^\s+-?\s*name:\s+"?([^"]+)"?/);
    if (nameMatch) {
      current = { name: nameMatch[1], description: '' };
      packs.push(current);
      continue;
    }
    if (current && line.match(/^\s+description:/)) {
      const desc = line.replace(/.*description:\s*"?/, '').replace(/"?\s*$/, '');
      current.description = desc.length > 80 ? desc.slice(0, 77) + '...' : desc;
    }
  }
  return packs;
}

function getValidPlatformIds() {
  return parsePlatformCodes().map(p => p.id);
}

function getValidPackNames() {
  return parsePackRegistry().map(p => p.name);
}

function validatePlatform(value) {
  const valid = getValidPlatformIds();
  if (!valid.includes(value)) {
    console.error(`Error: unknown platform '${value}'. Valid: ${valid.join(', ')}`);
    process.exit(1);
  }
}

function validatePacks(packList) {
  const valid = getValidPackNames();
  for (const p of packList) {
    if (!valid.includes(p)) {
      console.error(`Error: unknown pack '${p}'. Valid packs: ${valid.join(', ')}`);
      process.exit(1);
    }
  }
}

async function prompt(rl, question) {
  return new Promise(resolve => rl.question(question, resolve));
}

async function selectPlatform(rl) {
  const platforms = parsePlatformCodes();
  console.log('\n📦 TAD Framework Installer\n');
  console.log('Select your AI coding platform:\n');
  platforms.forEach((p, i) => {
    console.log(`  ${i + 1}. ${p.label} (${p.id})`);
  });
  console.log('');
  const answer = await prompt(rl, `Choice [1-${platforms.length}]: `);
  const idx = parseInt(answer, 10) - 1;
  if (idx < 0 || idx >= platforms.length) {
    console.error('Invalid choice.');
    process.exit(1);
  }
  return platforms[idx].id;
}

async function selectPacks(rl) {
  const packs = parsePackRegistry();
  console.log('\nSelect capability packs to install (comma-separated numbers, or "all"):\n');
  packs.forEach((p, i) => {
    console.log(`  ${String(i + 1).padStart(2)}. ${p.name}`);
    if (p.description) {
      console.log(`      ${p.description}`);
    }
  });
  console.log('');
  const answer = await prompt(rl, `Choice [1-${packs.length}, all]: `);
  if (answer.trim().toLowerCase() === 'all' || answer.trim() === '') {
    return '';
  }
  const indices = answer.split(',').map(s => parseInt(s.trim(), 10) - 1);
  const selected = [];
  for (const idx of indices) {
    if (idx >= 0 && idx < packs.length) {
      selected.push(packs[idx].name);
    }
  }
  if (selected.length === 0) {
    console.error('No valid packs selected.');
    process.exit(1);
  }
  return selected.join(',');
}

function runInstall(platform, packs) {
  const args = [TAD_SH_PATH, '--platform', platform, '--yes'];
  if (packs) {
    args.push('--packs', packs);
  }
  console.log(`\n🚀 Installing TAD for ${platform}${packs ? ` (packs: ${packs})` : ' (all packs)'}...\n`);
  try {
    execFileSync('bash', args, {
      stdio: 'inherit',
      cwd: process.cwd(),
      timeout: 300000,
    });
    console.log('\n✅ TAD installation complete!');
  } catch (err) {
    console.error('\n❌ Installation failed.');
    process.exit(err.status || 1);
  }
}

function parseArgs() {
  const args = process.argv.slice(2);
  let platform = '';
  let packs = '';
  let i = 0;
  while (i < args.length) {
    switch (args[i]) {
      case '--platform':
        platform = args[++i] || '';
        break;
      case '--packs':
        packs = args[++i] || '';
        break;
      case '--help':
      case '-h':
        console.log('Usage: npx tad-framework [--platform <name>] [--packs <list>]');
        console.log('');
        console.log('Options:');
        console.log('  --platform <name>  Target platform (claude-code, codex)');
        console.log('  --packs <list>     Comma-separated pack names to install');
        console.log('  --help             Show this message');
        process.exit(0);
      default: // eslint-disable-line no-fallthrough
        console.error(`Unknown option: ${args[i]}`);
        process.exit(1);
    }
    i++;
  }
  return { platform, packs };
}

async function main() {
  const { platform: argPlatform, packs: argPacks } = parseArgs();

  if (argPlatform) {
    validatePlatform(argPlatform);
  }
  if (argPacks) {
    validatePacks(argPacks.split(','));
  }

  if (argPlatform) {
    runInstall(argPlatform, argPacks);
    return;
  }

  const rl = createInterface({ input: process.stdin, output: process.stdout });
  try {
    const platform = await selectPlatform(rl);
    const packs = await selectPacks(rl);
    rl.close();
    runInstall(platform, packs);
  } catch (err) {
    rl.close();
    if (err.message && err.message.includes('readline was closed')) {
      console.error('\nInterrupted.');
    } else {
      console.error(`\nError: ${err.message}`);
    }
    process.exit(1);
  }
}

main();
