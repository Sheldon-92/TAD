# Journal — surplus-deprecate-domain-pack-yaml rerun (Blake raw journal, 2026-07-12)

Raw capture for Alex's distillation loop (Gate 4). Doer notes, not finished knowledge.

- **"Previous attempt wrote nothing" was false.** Launch instruction claimed the spend-limit-killed
  attempt wrote nothing; on disk, ~60% of the deliverable existed (all 9 references/ sets, 5/9
  SKILL.md, partial stale .agents mirrors; mtimes Jul 12 19:45-19:48). Handled by auditing prior
  output against every AC (frontmatter, line cap, mech-keys, ❌ parity, pointer coverage, content
  spot-checks) before trusting it — all passed — then building only the 4 missing SKILL.md.
  Lesson candidate: on any "rerun after crash", ALWAYS inventory the target paths before assuming
  clean state; a crash between "wrote files" and "reported progress" makes orchestrator claims
  about write-state unreliable.
- **AC11/AC12 (empty git-status scope checks) are structurally blind on a shared dirty worktree.**
  A live parallel session (files modified at 21:51-21:54 DURING my run: blake/SKILL.md,
  skill-body-verify.sh, .gitignore, etc.) made "expected: no output" impossible for any
  implementation, however clean. Resolution used: attribution filtering — subtract the do-not-touch
  list + session-start snapshot + my own write log; residual attributable to me = 0 lines. Related
  to principles.md 2026-06-01 (global metric conflates two populations); here the two populations
  are "my changes" vs "concurrent session's changes". Candidate AC pattern: scope git-status ACs to
  an explicit path allowlist OR compare against a session-start `git status --porcelain` baseline
  snapshot diff, not to empty.
- **Pre-staged foreign index entries constrain `git add` discipline.** The parallel session had
  already staged 6 files; "stage only my files" could not produce a clean index without resetting
  someone else's staging. Explicit-path `git add` is the only safe move on a shared repo; never
  `git add -A`.
- **zsh does not word-split `$PACKS`** — every §9.1 loop failed spuriously under the default shell
  and had to run under `bash -c`. shell-portability pattern already covers macOS/BSD but not the
  zsh-vs-bash word-splitting trap for handoff-embedded AC commands. AC authors should either quote
  arrays or state "run under bash".
- **CHANGELOG heading choice**: version.txt=2.33.0 but no 2.33.0 CHANGELOG entry exists; release
  in flight elsewhere. Used Keep-a-Changelog `## [Unreleased]` to avoid inventing/colliding with a
  version number (version bumps out of handoff scope §10.2). AC7's `awk n==1` works against it.
- **Fact-check reflex paid off**: my draft CHANGELOG said the domain router was deleted "in
  v2.13.0" (from memory); checking which `## [x.y.z]` heading precedes CHANGELOG line 416 showed
  v2.17.0. Fixed before staging. (research-before-assert, handoff §10.1 "不发明事实".)
- **Sanctioned reference additions**: hw-firmware references all pointed at a review-checklist.md
  that did not exist (dangling pointers from the prior attempt); hw-testing lacked its 7th YAML
  capability (hw_pair_testing) entirely. Both filled per FR4's preserve-not-discard rule. Pattern:
  when auditing inherited partial work, grep for dangling reference pointers.
- **Commit deferred**: orchestrator instruction "git add only, do not commit" conflicts with Gate 3
  Git_Commit_Verification → recorded gate3_verdict: partial (sole non-green item; §9.1 all pass).
