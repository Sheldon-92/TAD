#!/usr/bin/env node

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

  // Default: full install (claude-code + all packs), no questions asked
  const platform = argPlatform || 'claude-code';
  runInstall(platform, argPacks);
}

main();
