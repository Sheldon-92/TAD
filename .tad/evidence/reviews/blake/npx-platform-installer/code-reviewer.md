# Code Review: npx Platform Installer

**Reviewer**: Code Reviewer (Security + Quality focus)
**Date**: 2026-06-07
**Files**: `tad.sh` (platform sections), `bin/tad-install.mjs`, `.tad/platform-codes.yaml`, `package.json`
**Handoff**: HANDOFF-20260607-npx-platform-installer

---

## Summary

The implementation correctly follows the handoff's core constraints: it reuses `tad.sh` for all copy logic (AC10), uses deny-delta not allow-list (principles 2026-06-01), validates platform/pack membership before passing to bash (AC9), uses `execFileSync` not shell string concatenation (AC security), and uses Node timeout instead of shell `timeout` (portability). The architecture is sound.

However, I identified several issues ranging from a regex injection vector (P0) to YAML parser edge cases and minor quality items.

---

## P0 - Critical / Blocking

### P0-1: Regex injection in `is_denied()` via unescaped `grep` pattern (tad.sh line 299)

**Location**: `tad.sh` line 299
```bash
if [ "$path" = "$entry" ] || printf '%s' "$path" | grep -q "^${entry}"; then
```

**Issue**: The `$entry` value comes from `parse_platform_extra_deny()` which reads raw YAML strings. The value `.claude/settings.json` contains a literal dot (`.`) which in regex matches ANY character. While the current `platform-codes.yaml` values are controlled, the contract is that this file is the extensibility surface for new platforms. A malicious or careless entry like `.claude/s.*` would match unintended paths. More critically, the dot in `.claude/settings.json` already matches `Xclaude/settings.json` (unlikely but incorrect semantics).

The real danger: if a future platform adds a deny entry containing regex metacharacters (`[`, `*`, `+`, `(`, etc.), the `grep -q "^${entry}"` becomes either a regex match or causes grep to error out under `set -e`, rolling back the entire install.

**Fix**: Use `grep -qF` (fixed-string) for exact prefix matching, or better, use shell string comparison:
```bash
is_denied() {
    local path="$1" deny_list="$2"
    [ -z "$deny_list" ] && return 1
    local entry
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        # Exact match OR path starts with entry (prefix/directory match)
        if [ "$path" = "$entry" ] || [ "${path#"$entry"}" != "$path" ]; then
            return 0
        fi
    done <<< "$deny_list"
    return 1
}
```

**Impact**: Command injection is not possible (the pattern is not user-facing input from npx), but regex mismatches can silently over-deny or under-deny files. Over-deny = missing framework files = install failure. Under-deny = codex gets files it should not have (settings.json hooks firing in wrong env).

**Severity**: P0 because a regex failure under `set -e` would trigger ERR trap rollback of an otherwise correct install.

---

### P0-2: `is_pack_skill()` regex injection from pack names (tad.sh line 312)

**Location**: `tad.sh` line 312
```bash
grep -qE "name:[[:space:]]+\"?${name}\"?" "$src/.tad/capability-packs/pack-registry.yaml" 2>/dev/null
```

**Issue**: `$name` is interpolated directly into a `-E` (extended regex) pattern. Pack names like `ai-agent-architecture` contain hyphens which are regex-safe, but this is only true BY CONVENTION. The function accepts any basename from `$src/.claude/skills/*/` -- if a directory name contains `+`, `.`, `(`, `[`, etc., this grep becomes malformed.

While the npx layer validates pack names against the registry (membership check), `tad.sh` can also be invoked directly via `curl|bash` where no Node validation layer exists. A crafted skill directory name in the source tree (unlikely but possible via supply chain) would break this grep.

**Fix**: Use `grep -F` (fixed-string) with a tighter pattern:
```bash
is_pack_skill() {
    local name="$1" src="$2"
    if [ -f "$src/.tad/capability-packs/pack-registry.yaml" ]; then
        grep -qF "name: \"${name}\"" "$src/.tad/capability-packs/pack-registry.yaml" 2>/dev/null \
          || grep -qF "name: ${name}" "$src/.tad/capability-packs/pack-registry.yaml" 2>/dev/null
        return $?
    fi
    return 1
}
```

**Impact**: Same class as P0-1 -- under `set -e`, a regex error terminates the script with ERR trap rollback.

**Severity**: P0 -- script termination on edge-case input.

---

## P1 - Important / Should Fix

### P1-1: YAML parser does not handle comments or inline values (tad.sh lines 236-289)

**Location**: `parse_platform_extra_deny()` and `parse_platform_root_files()`

**Issue**: The handwritten YAML parser uses line-by-line regex matching. It does not handle:
1. **Comments**: A line like `    # - ".claude/test"` would be parsed as a valid deny entry (the `^\s+-\s+` pattern matches after the `#`).
2. **Inline arrays**: `extra_deny: [".claude/settings.json", ".claude/workflows"]` -- the parser checks for `\[\]` (empty array) but not for a populated inline array. Non-empty inline arrays are silently ignored (zero entries emitted).

For the current `platform-codes.yaml` this is fine (no comments in list items, no inline populated arrays), but the file is documented as the extensibility surface. A future editor adding a comment or using inline array syntax gets silent breakage.

**Fix**: Add comment stripping at the top of the while loop:
```bash
# Skip comment lines
printf '%s' "$line" | grep -qE '^[[:space:]]*#' && continue
```

For inline arrays, either document "must use block style" in `platform-codes.yaml` header or parse them:
```bash
# Handle inline array: extra_deny: ["a", "b"]
if printf '%s' "$line" | grep -qE '\[.+\]'; then
    printf '%s' "$line" | sed -E 's/.*\[//;s/\].*//;s/"//g' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
    in_deny=0; continue
fi
```

**Severity**: P1 -- silent data loss for a documented extension point.

---

### P1-2: `tad-install.mjs` YAML parser regex too permissive for pack names (line 45)

**Location**: `bin/tad-install.mjs` line 45
```javascript
const nameMatch = line.match(/^\s+-?\s*name:\s+"?([^"]+)"?/);
```

**Issue**: The capture group `([^"]+)` matches everything up to a quote OR end of line. If a name is unquoted (e.g., `name: ai-agent-architecture`), the match includes trailing whitespace or comment text. Example: `name: foo # my pack` would capture `foo # my pack`.

Also, `^\s+-?\s*name:` with the optional `-?` means it matches both `  - name:` (list item) and `  name:` (object key). In a YAML file where `name:` appears in a nested context (like inside a `metadata:` block), this could capture wrong values.

**Fix**: Tighten the regex:
```javascript
const nameMatch = line.match(/^\s+-\s+name:\s+"([^"]+)"/);
// Or for unquoted: /^\s+-\s+name:\s+([a-z0-9-]+)/
```

Requiring the list-item prefix (`-`) ensures only top-level pack entries are matched.

**Severity**: P1 -- wrong pack list shown to user if registry format varies.

---

### P1-3: `parseArgs()` in tad-install.mjs silently accepts `--platform` without value (line 161)

**Location**: `bin/tad-install.mjs` line 161
```javascript
case '--platform':
    platform = args[++i] || '';
    break;
```

**Issue**: If `--platform` is the last argument, `args[++i]` is `undefined`, so `platform` becomes `''` (empty string). This empty string then passes through `if (argPlatform)` (line 187) as falsy, falling into the interactive path. This is accidentally correct behavior, but the user gets no feedback that their `--platform` flag was ignored.

Contrast with `tad.sh` which explicitly checks: `[ -z "${2:-}" ] && echo "...requires a value" >&2 && exit 1`.

**Fix**:
```javascript
case '--platform':
    i++;
    if (!args[i]) {
        console.error('Error: --platform requires a value');
        process.exit(1);
    }
    platform = args[i];
    break;
```

**Severity**: P1 -- poor UX (silent flag drop) and asymmetry with tad.sh's strict validation.

---

### P1-4: `package.json` references non-existent `scripts/install.js` (line 10)

**Location**: `package.json` line 10
```json
"install": "node scripts/install.js"
```

**Issue**: The file `scripts/install.js` does not exist (only `scripts/archive/` directory found). This means `npm install tad-framework` (as a dependency) or `npx tad-framework` (which runs lifecycle scripts) will **fail** with a `ENOENT` error on the install lifecycle hook.

This is BLOCKING for npm distribution. The `npm install` lifecycle runs BEFORE `bin` scripts are available, so users hitting this error never get to `tad-install`.

**Fix**: Either create the file or remove the script:
```json
"scripts": {
    "test": "echo \"No tests yet\""
}
```

If the intent is to run installation logic on `npm install`, create a proper `scripts/install.js` that is a no-op or prints a message.

**Severity**: P1 -- npm distribution broken (install lifecycle failure).

---

### P1-5: `version_le()` relies on `sort -V` which is not available on all macOS versions (tad.sh line 677)

**Location**: `tad.sh` line 677
```bash
[ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -1)" = "$v1" ]
```

**Issue**: `sort -V` (version sort) is a GNU coreutils extension. On macOS with the stock BSD `sort`, `-V` is not supported (added in macOS 12+ via newer coreutils, but not guaranteed on older systems). The script already warns about Bash 4+ but does not check for GNU sort.

This function is used in `apply_deprecations()` -- if it fails, deprecation cleanup is skipped (or worse, under `set -e`, the install aborts).

**Fix**: Implement a simple numeric semver comparison:
```bash
version_le() {
    local IFS='.'
    local -a v1_parts=($1) v2_parts=($2)
    local i
    for i in 0 1 2; do
        local a="${v1_parts[$i]:-0}" b="${v2_parts[$i]:-0}"
        [ "$a" -lt "$b" ] && return 0
        [ "$a" -gt "$b" ] && return 1
    done
    return 0  # equal
}
```

**Severity**: P1 -- script failure on older macOS (the primary target platform per handoff context).

---

### P1-6: `parse_platform_extra_deny` uses `\s` in grep which requires ERE but not all patterns use `-E` (tad.sh lines 246-256)

**Location**: `tad.sh` lines 246, 252, 256, 274, 280, 284

**Issue**: The functions use `grep -qE '^\s+...'` -- while `\s` works with `-E` on GNU grep, on macOS BSD grep with `-E`, `\s` is NOT part of POSIX ERE. It works on modern macOS because Apple ships GNU grep, but this is an implementation detail, not a portable guarantee.

The handoff explicitly says "no grep -P" but `\s` in ERE is the same class of portability issue.

**Fix**: Replace `\s` with `[[:space:]]`:
```bash
# Before:
printf '%s' "$line" | grep -qE '^\s+extra_deny:'
# After:
printf '%s' "$line" | grep -qE '^[[:space:]]+extra_deny:'
```

**Severity**: P1 -- shell portability violation (handoff constraint).

---

## P2 - Minor / Consider

### P2-1: `bin/tad-install.mjs` does not validate that `tad.sh` exists before exec (line 141)

**Location**: `bin/tad-install.mjs` line 13 + 141

**Issue**: `TAD_SH_PATH` is derived from `__dirname` relative path. If the npm package is installed with a broken `files` list or partial download, `tad.sh` may not exist. The error from `execFileSync` would be cryptic (`ENOENT: no such file or directory`).

**Fix**: Add a pre-flight check:
```javascript
if (!existsSync(TAD_SH_PATH)) {
    console.error(`Error: tad.sh not found at ${TAD_SH_PATH}`);
    console.error('The package may be corrupted. Try: npm cache clean --force && npx tad-framework');
    process.exit(1);
}
```

---

### P2-2: `tad-install.mjs` readline not robust against pipe/non-TTY (line 199)

**Location**: `bin/tad-install.mjs` line 199

**Issue**: When stdin is not a TTY (e.g., `echo "1" | npx tad-framework`), readline may behave unexpectedly. The error handling (line 207) catches `readline was closed` but not EOF. In non-interactive contexts, the script should detect `!process.stdin.isTTY` and require `--platform` explicitly.

**Fix**:
```javascript
if (!process.stdin.isTTY && !argPlatform) {
    console.error('Error: stdin is not a TTY. Use --platform and --packs for non-interactive mode.');
    process.exit(1);
}
```

---

### P2-3: `platform-codes.yaml` comment says "NEVER use per-platform install_dirs allow-list" but there is no mechanical guard

**Issue**: The comment at line 4 is a human-readable warning. If a future contributor adds `install_dirs:` to a platform block, nothing in the code would catch it -- the parser simply ignores unknown keys.

**Fix**: Add a lint assertion in `verify_denylist_drift` or a new `--verify-platform-codes` flag that asserts no platform block contains `install_dirs`.

---

### P2-4: `tad.sh` platform detection logic is minimal (line 146-158)

**Location**: `tad.sh` `resolve_platform()` line 152

**Issue**: Auto-detection only checks for `claude` command or `~/.claude` directory. For codex users who do NOT have Claude Code installed, the script silently defaults to `claude-code` with a warning. This is correct per spec ("default: claude-code") but the warning message could be more actionable.

**Fix**: Improve the warning:
```bash
log_warn "Claude Code not detected. Using default platform: claude-code"
log_warn "  Use --platform codex if installing for Codex CLI."
```

---

### P2-5: `package.json` engines field says `"node": ">=14.0.0"` but code uses ES modules

**Location**: `package.json` line 45, `bin/tad-install.mjs` line 1

**Issue**: `tad-install.mjs` uses ES module syntax (`import { ... } from 'node:...'`). The `node:` protocol prefix requires Node 16+. Node 14 supports ES modules but not the `node:` prefix for built-in modules.

**Fix**: Either change engines to `>=16.0.0` or use the unprefixed form:
```javascript
import { createInterface } from 'readline';
import { execFileSync } from 'child_process';
// etc.
```

The handoff says "node14 compatible" (section 4.4), so removing the prefix is the correct fix.

---

### P2-6: pack description truncation in tad-install.mjs (line 53) has no visual indicator

**Location**: `bin/tad-install.mjs` line 53
```javascript
current.description = desc.length > 80 ? desc.slice(0, 77) + '...' : desc;
```

**Issue**: Minor UX -- the `...` at 77+3=80 chars works, but the character count includes potential trailing quote/space from the regex strip (line 52). If the regex leaves a trailing space, the visual output has `space...` which looks odd.

**Fix**: Trim before truncating:
```javascript
const desc = line.replace(/.*description:\s*"?/, '').replace(/"?\s*$/, '').trim();
```

---

## Positive Observations

1. **Security model is correct**: `execFileSync('bash', args, ...)` with array arguments prevents shell injection. This is the right pattern.
2. **Membership validation before exec**: Both platform and pack names are validated against parsed registries before being passed to bash -- this closes the command injection vector at the Node/bash boundary.
3. **Deny-list architecture**: The deny-delta model in `platform-codes.yaml` correctly follows the 2026-06-01 principle. New framework dirs auto-flow to both platforms.
4. **Timeout via Node**: Using `{timeout: 300000}` on `execFileSync` correctly avoids the macOS `timeout` command portability issue.
5. **Verify_install_complete platform-scoping**: The verifier correctly reads the same `platform_deny` so codex's legitimate exclusions are not false-positived as missing.
6. **Backward compatibility**: Default behavior (no `--platform`) resolves to `claude-code` with empty `extra_deny` = identical to pre-platform behavior.

---

## Action Items (Prioritized)

1. **[P0-1, P0-2]** Fix regex injection in `is_denied()` and `is_pack_skill()` -- use `grep -F` or pure shell string ops.
2. **[P1-4]** Remove or fix the `"install": "node scripts/install.js"` entry in package.json -- this blocks npm distribution.
3. **[P1-5]** Replace `sort -V` with numeric semver comparison for macOS portability.
4. **[P1-6]** Replace `\s` with `[[:space:]]` in all grep patterns for POSIX ERE compliance.
5. **[P1-1]** Add comment-line skipping to YAML parsers.
6. **[P1-3]** Add explicit error for `--platform` without value in tad-install.mjs.
7. **[P1-2]** Tighten pack-name regex in tad-install.mjs parser.
8. **[P2-5]** Fix Node engine requirement to >=16 or remove `node:` prefix from imports.

---

*Review by: Code Reviewer*
*Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>*
