# Codex-Edition Parity: 3-Layer Mechanizable Criterion

**Date:** 2026-06-01
**Linked to:** L2 pack-build-rules "Capability Pack: Design and Build Rules"

---

### Codex-Edition Parity: 3-Layer Mechanizable Criterion + Bash grep Pattern - 2026-06-01
- **Context**: Phase 1 spike for Codex-edition automated regeneration (EPIC codex-edition-parity). Built a 3-layer parity check to distinguish drifted from current Codex editions.
- **Discovery**: (1) **3-layer structure (section coverage + constraint guards + capability markers) reliably discriminates drift.** The live edition (Generated: 2026-05-04) had 8 missing must-cover protocols + 4 absent feature markers; the regen from current source passed all 3 layers. The key design decision: an **expected-absent allowlist** (9 Conductor/automation protocols) in portable-rules.md prevents false drift flags on legitimately stripped protocols. (2) **`grep -c PATTERN || echo 0` doubles output in bash.** When grep finds 0 matches it outputs `0` to stdout AND exits 1; `|| echo 0` catches the exit and ALSO outputs `0`. The command substitution captures both → variable = "0\n0" → integer comparison fails. Fix: use `|| true` (no extra output) not `|| echo 0`. (3) **Feature markers in Layer 3 MUST be mechanically extracted at gate time (ARCH P1-1).** A hardcoded marker list passes current drift but misses FUTURE drift (a new track added to Claude but not Codex). P1 prototype hardcodes acceptably; P3 release gate must extract from source.
- **Action**: For any multi-artifact parity check: split the source inventory into must-cover + expected-absent (with the allowlist as the source of truth, not the check script). For bash `grep -c` in `$()`: always `|| true`, never `|| echo 0`. For drift-prevention gates: extract the marker list from the primary source at gate time, never from a frozen constant.
- **Grounded in**: .tad/evidence/spikes/codex-parity/parity-check.sh, .tad/evidence/spikes/codex-parity/parity-criterion.md, HANDOFF-20260601-codex-parity-phase1-spike.md
