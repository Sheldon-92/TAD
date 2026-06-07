# Backend Architect Review: npx Cross-Platform Installer

**Reviewer:** Backend Architect (scalable systems, deny-list design, shell security)
**Date:** 2026-06-07
**Files Reviewed:**
- `tad.sh` (v2.3, ~1216 lines)
- `bin/tad-install.mjs` (217 lines)
- `.tad/platform-codes.yaml` (20 lines)
- `package.json` (48 lines)
- `.tad/hooks/lib/derive-sync-set.sh` (reference baseline)

**Scope:** Architecture conformance against 5 stated principles + extensibility + security.

---

## Verdict: PASS (with 2 P1 and 4 P2 findings)

No P0 issues. The architecture correctly implements the deny-delta model, maintains
backward compatibility, and cleanly separates concerns between the npx UI layer and
the tad.sh installation engine.

---

## Principle Verification

### 1. Deny-delta model: platforms differ ONLY by extra_deny + extra_root_files ON TOP of shared deny-derived core

**PASS.** The implementation is structurally correct:

- `derive_framework_dirs()` (line 204-212) and `derive_framework_top_files()` (line 220-229)
  produce the shared core identically for all platforms. The core derivation is platform-AGNOSTIC.
- Platform differences are layered as post-hoc filtering in `copy_framework_files()` (line 424-425):
  `platform_deny` is read from `platform-codes.yaml` and applied only to `.claude/` paths.
- The `.tad/` core tree is NEVER conditioned on platform -- every platform gets the full
  deny-derived `.tad/` directory set. Only the `.claude/` layer (skills, settings, workflows)
  and root files (AGENTS.md) differ per platform.
- The `claude-code` platform has `extra_deny: []` -- confirming it is the identity/baseline.

This is the correct architecture: the deny-list derivation is the universal constant,
platform differentiation is a thin delta on top.

### 2. Single source of truth: platform-codes.yaml drives both tad.sh copy logic AND npx display

**PASS.** Both consumers read the same file:

- `tad.sh`: `parse_platform_extra_deny()` and `parse_platform_root_files()` read
  `.tad/platform-codes.yaml` from `$TAD_SRC` at copy time (line 424, 469).
- `bin/tad-install.mjs`: `parsePlatformCodes()` (line 15-35) reads the same file from
  the package root at `join(ROOT, '.tad', 'platform-codes.yaml')`.

No duplication of platform definitions exists. Adding a new platform to the YAML
makes it visible in both the installer UI and the copy logic.

### 3. Separation of concerns: npx handles UI/validation, tad.sh handles actual install

**PASS.** Clean boundary:

- `bin/tad-install.mjs` responsibilities: arg parsing, interactive platform/pack selection,
  membership validation, then delegates via `execFileSync('bash', [TAD_SH_PATH, ...])`.
- Zero file-copy primitives in the mjs file (confirmed: no `cpSync`, `copyFileSync`,
  `fs.cp`, `rsync`, `tar`, or `cp` invocations).
- tad.sh responsibilities: download, deny-list derivation, platform-filtered copy,
  deprecation, verification, rollback.

The bridge is a clean function call with validated string arguments.

### 4. Backward compatibility: no --platform = claude-code = current behavior unchanged

**PASS.** Verified via:

- `resolve_platform()` (line 146-158): when `PLATFORM=""` (no --platform flag),
  defaults to `"claude-code"` unconditionally.
- `claude-code` platform has `extra_deny: []` and `extra_root_files: []` -- meaning
  zero behavioral difference from pre-platform tad.sh.
- The arg parser (line 50-69) gracefully handles zero args (no --platform) without error.
- AC1 explicitly tests byte-identity between `--yes` and `--platform claude-code --yes`.

### 5. Config-driven extensibility: adding a new platform requires ONLY yaml + npx display changes

**PARTIAL PASS (P1 finding).** See P1-1 below. The `KNOWN_PLATFORMS` static validation
in tad.sh (line 132) requires a code change when adding a new platform. The copy logic
itself is fully config-driven and needs no change.

---

## Findings

### P1-1: KNOWN_PLATFORMS hardcoded list defeats config-driven extensibility

**Location:** `tad.sh` line 132: `KNOWN_PLATFORMS="claude-code codex"`

**Problem:** The `validate_platform()` function (line 134-143) checks the `--platform`
value against a hardcoded string list. This runs BEFORE download (the yaml file does
not yet exist on a fresh machine), so it cannot read platform-codes.yaml at this point.
However, this means adding a new platform (e.g., `cursor`) requires editing tad.sh code
in addition to the yaml -- violating principle 5.

**Why it matters:** The stated architectural goal is "adding a new platform should require
ONLY yaml + npx display changes, no tad.sh code changes." This hardcoded list breaks
that contract.

**Mitigation assessment:** The ordering problem (validate before download) is real and
acknowledged in the comment on line 130-131. The npx entry point does NOT have this
problem (it reads the yaml at runtime). For the `curl | bash` path, the validation must
be static.

**Recommendation (incremental):**
1. Accept that `curl | bash tad.sh --platform X` requires tad.sh to know valid platforms
   statically (unavoidable without downloading first).
2. Add a release-time drift check (similar to `--verify-denylist`) that asserts
   `KNOWN_PLATFORMS` matches the keys in platform-codes.yaml. This makes staleness
   detectable at release rather than silently shipping.
3. Document this as an expected maintenance point in platform-codes.yaml comments.

**Severity:** P1 -- architectural principle partially violated but the practical impact
is low (adding a platform is still trivial: one yaml line + one string append).

---

### P1-2: is_denied() uses prefix matching -- overly broad for path deny

**Location:** `tad.sh` line 299: `printf '%s' "$path" | grep -q "^${entry}"`

**Problem:** The `is_denied()` function returns true if ANY deny entry is a prefix of
the path. Given the current deny entries (e.g., `.claude/skills/alex`), this means:
- `.claude/skills/alex-utils` would ALSO be denied (unintended prefix match)
- `.claude/settings.json-backup` would be denied by `.claude/settings.json` prefix

The current platform-codes.yaml entries do not trigger these false positives TODAY
(no such paths exist), but the matching semantics are structurally unsound for future
extensibility.

**Recommendation:** Change the matching to either:
- Exact match for files + exact-prefix-with-separator match for directories:
  `[ "$path" = "$entry" ] || [ "${path#"$entry/"}" != "$path" ]`
- Or use a trailing-slash convention in the deny list for directory entries.

**Severity:** P1 -- latent bug that will surface when paths with common prefixes are added.

---

### P2-1: YAML parser fragility (no-yq tradeoff acknowledged but risks exist)

**Location:** `tad.sh` lines 236-289 (parse_platform_extra_deny, parse_platform_root_files)
and `bin/tad-install.mjs` lines 15-57 (parsePlatformCodes, parsePackRegistry).

**Problem:** Both files implement bespoke YAML parsing via line-by-line regex matching.
These parsers make assumptions about indentation depth (exactly 2 spaces for platform keys,
4+ for nested fields) and quote handling. They will break on:
- YAML comments on the same line as a value
- Multi-line values or block scalars
- Alternate indentation (tabs, 3 spaces)
- Flow-style arrays on a single line (partially handled: `[]` empty case in tad.sh)

**Mitigation:** The YAML file is framework-controlled (not user-edited) and structurally
trivial. The risk is low as long as the file stays minimal. The decision to avoid yq/jq
dependencies is sound for a `curl | bash` installer on bare machines.

**Recommendation:** Add a comment in platform-codes.yaml specifying the exact formatting
contract: "Parsed by line-regex in tad.sh and tad-install.mjs. DO NOT use: comments on
value lines, block scalars, tabs, flow mappings. Maintain exactly this indentation."

**Severity:** P2 -- acceptable tradeoff with documentation.

---

### P2-2: execFileSync timeout (300s) with no progress feedback

**Location:** `bin/tad-install.mjs` line 142: `timeout: 300000`

**Problem:** The 5-minute timeout is reasonable for a normal install (download + copy),
but if the download stalls (slow network, GitHub outage), the user sees no output for
up to 5 minutes before a cryptic timeout error. The `stdio: 'inherit'` passes through
tad.sh output, but the download phase (`curl -sSL`) is silent by design.

**Recommendation:** Consider using `-S` (show errors) without `-s` for curl, or add
a "Downloading..." log line before the curl call in tad.sh. Not blocking.

**Severity:** P2 -- UX polish, not architectural.

---

### P2-3: pack-registry.yaml name matching in is_pack_skill() is overly greedy

**Location:** `tad.sh` line 312:
`grep -qE "name:[[:space:]]+\"?${name}\"?" "$src/.tad/capability-packs/pack-registry.yaml"`

**Problem:** The regex `name:[[:space:]]+"?web-backend"?` could match:
- `name: "web-backend-extras"` (if such a pack existed) -- the regex has no word boundary
  or end-of-line anchor after the name.

Current pack names are distinct enough that this does not produce false positives, but
the matching is structurally unanchored.

**Recommendation:** Anchor with `$` or `"` at the end:
`grep -qE "name:[[:space:]]+\"?${name}\"?[[:space:]]*$"`

**Severity:** P2 -- latent, not currently triggered.

---

### P2-4: npx package includes entire .tad/ and .claude/ tree via package.json "files"

**Location:** `package.json` lines 34-43:
```json
"files": [".tad/", ".claude/", "bin/", "tad.sh", "AGENTS.md", "CLAUDE.md", "*.md", "scripts/"]
```

**Problem:** The npm package will include ALL of `.tad/` (including evidence, active
handoffs, research notebooks, etc.) and all of `.claude/` (including potentially
local settings). This is:
- A size concern (the full .tad/ tree may be very large)
- A potential information leak (evidence, proposals, research contain project-specific data)

The `files` field is an ALLOW-list for npm pack -- it controls what ships in the tarball.
Including `.tad/` wholesale means the published npm package contains internal project data.

**Recommendation:** Either:
1. Add a `.npmignore` that excludes zero-touch/transient/evidence directories, OR
2. Narrow the `files` array to only framework-distributable paths:
   `".tad/config.yaml", ".tad/version.txt", ".tad/skills/", ".tad/agents/", ...`
3. OR (simplest): if the npm package is meant to bootstrap via downloading from GitHub
   anyway (tad.sh does `curl` the tarball), then the local `.tad/` content in the npm
   package is REDUNDANT -- tad.sh downloads fresh. In that case, `files` should only
   contain `["bin/", "tad.sh", ".tad/platform-codes.yaml", ".tad/capability-packs/pack-registry.yaml"]`.

**Severity:** P2 -- information hygiene + package size. Not a functional bug since
tad.sh downloads fresh regardless, but a supply-chain cleanliness issue.

---

## Architectural Strengths

1. **Deny-list consistency.** The inlined DENY_LIST in tad.sh is byte-verified against
   derive-sync-set.sh via `--verify-denylist` at release time. This prevents drift
   between the two copies (a known historical failure class).

2. **Verifier is platform-scoped.** `verify_install_complete()` (line 515-599) reads
   `platform_deny` and skips verification of intentionally-excluded paths. This prevents
   false failures on codex installs (AC12 scenario).

3. **Bridge security.** `execFileSync('bash', args)` with array arguments avoids shell
   injection. Platform and pack values are membership-validated before reaching bash.
   No string interpolation into shell commands.

4. **Rollback on failure.** The ERR trap + `verify_install_complete` returning non-zero
   triggers automatic rollback to backup. A partial install cannot persist silently.

5. **Ordering discipline.** Platform validation pre-download uses a static known-set
   (not yaml), while platform-aware copy post-download uses the yaml (when it exists).
   The ordering problem (detect vs download) is explicitly acknowledged and handled.

---

## Extensibility Assessment

**Adding a new platform (e.g., cursor):**
1. Add entry to `platform-codes.yaml` -- drives npx UI + copy filtering. (DONE)
2. Add platform name to `KNOWN_PLATFORMS` in tad.sh line 132. (CODE CHANGE -- see P1-1)
3. Optionally add platform-specific root files or codex-style scripts.

Effort: ~5 minutes. The architecture correctly isolates the delta to config + one string.

**Adding a new capability pack:**
1. Add to `pack-registry.yaml` with description.
2. Create `.claude/skills/<pack-name>/` directory.
3. Both tad-install.mjs (pack selection UI) and tad.sh (copy logic) auto-discover it.

Effort: Zero installer changes needed. Pure config-driven.

**Adding a new .tad/ framework directory:**
1. Create the directory in the source repo.
2. It auto-syncs to ALL platforms (deny-list derivation means new dirs are included by default).
3. No installer code changes.

This is the key architectural win of deny-list derivation.

---

## Summary Table

| ID | Severity | Title | Blocking? |
|----|----------|-------|-----------|
| P1-1 | P1 | KNOWN_PLATFORMS hardcoded list defeats full config-driven extensibility | No |
| P1-2 | P1 | is_denied() prefix matching overly broad | No |
| P2-1 | P2 | YAML parser fragility (documented tradeoff) | No |
| P2-2 | P2 | No progress feedback during download timeout | No |
| P2-3 | P2 | is_pack_skill() grep regex unanchored | No |
| P2-4 | P2 | package.json "files" ships entire .tad/ including project data | No |

**Recommendation:** PROCEED with implementation. Address P1-1 and P1-2 before release
if feasible (both are single-line fixes). P2 items can be deferred to a follow-up.
