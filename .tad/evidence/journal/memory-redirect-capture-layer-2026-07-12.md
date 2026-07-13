# Journal — memory-redirect-capture-layer (2026-07-12, Blake)

Raw capture notes (what happened, for Alex's distillation loop — the curse-of-knowledge
antidote is that Alex reads this cold).

1. **parity --fix mirrors gitignored local/ into the TRACKED .agents tree.**
   release-verify.sh parity rsyncs .claude/skills → .agents/skills wholesale. `.claude/skills/local/`
   is gitignored (save-skill contract: local-only, never distributed) but the rsync copied it to
   `.agents/skills/local/`, where NO gitignore rule existed — the local scaffolds became git-visible
   in a PUBLIC repo. Today only `_example.md`/`_index.md` leaked (harmless scaffolds), but any real
   local skill would have been one `git add -A` away from publication. Mitigated: rm + added
   `.agents/skills/local/` to .gitignore. Root fix (parity tool should exclude local/) NOT done —
   out of handoff scope, needs an Alex bugfix handoff.

2. **parity is a race against concurrent terminals.** While this handoff ran, another terminal was
   actively building mobile-*/hw-* packs. My parity --fix mirrored their half-built state; minutes
   later parity verify FAILed with "both sides have uncommitted changes — cannot determine direction
   / agents-newer (STOP)". A global set-equality gate cannot pass while another workstream mutates
   the source side. Scope-level evidence (cmp of the two in-scope mirror files = byte-identical) was
   the honest substitute; global parity must re-run PASS at a quiet moment (pre-*publish).

3. **The git index is shared state across terminals: pathspec-commit protects riders.** The index
   already held 2 pre-staged entries from the other terminal (post-write-sync.sh, detect-state-fixture.sh).
   A plain `git commit` would have swept them into my commit. `git commit -- <pathspec>` committed
   only my 52 paths and left the riders staged for their owner. Caught by the spec-compliance
   reviewer, not by me — I had only checked the worktree, not the index.

4. **Index/ledger files need sensitivity triage too, not just content files.** MEMORY.md (the native
   auto-memory index) looked like plumbing, but its one-line hooks embed the user-profile summary,
   the co-thinking-workshop seed core, and a leaked-source-analysis reference — i.e. it reproduces
   the substance of 3 SENSITIVE files in compressed form, and it keeps absorbing future one-liners
   with no re-triage. Classified SENSITIVE (per-file gitignore). Generalizes: any auto-maintained
   index over mixed-sensitivity content inherits the max sensitivity of what it summarizes.

5. **Mechanical grep for credentials produced 4/4 false positives** ("token cost", "header-token"
   CSP term, "token-burn", LLM token counts). The grep is a smoke alarm for the LLM per-file pass,
   not a verdict. Conversely the email-specific sweep (zhaos948|newschool|@gmail) was the
   high-precision check and came back clean.

6. **AC10's `git ls-files` was vacuous before staging** (empty index set → grep on nothing → PASS).
   Re-ran after `git add` (29 files in index) for a non-vacuous result; security-auditor also ran a
   direct 29-file scan independently. Lesson: verification commands that read the git index must run
   AFTER the index is populated, or they pass trivially.

7. SLUG derivation rule for the native memory dir (`/` and space → `-`) confirmed empirically:
   `-Users-sheldonzhao-01-on-progress-programs-TAD` exists. The script's OLD_DIR preflight WARN
   path was not exercised (dir existed).
