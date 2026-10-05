Model: harness=codex | model=unknown | route=unknown
Reviewer: /root/execution_review (terra_reviewer; independent session)
Verdict: CONDITIONAL PASS with two unresolved P0 — NOT Gate 2 clearance

## Findings (reviewer returned, retained)

- P0 C1 — source-root contract missing. Six paths are cloud-root relative; CLI root is TAD. All six missing under repo but readable regular files under parent. Fix: canonical parent root, static allowlist, reject escapes/symlinks, test arbitrary cwd.
- P0 C2 — read scope conflicts with baseline construction. §3.2 permits only six external documents, while §4.3 requires three TAD skill roots, configs/templates and reference closure. Fix: distinguish external-history reads from pinned-revision TAD git-object reads; explicit roots and manifest for direct documented references.
- P1 C3 — offline/no-side-effect compliance asserted but not tested. Baseline extraction may legitimately invoke git. Fix: narrow non-shell read-only git wrapper, deny other processes/network imports, independent inspection and guard policy in dry-run evidence.
- P1 C4 — commit boundary ambiguous. Commit limited to experiments directory but lifecycle files also required. Fix: exact staged-file list and separate policy for NEXT/completion/private evidence.
- P2 C5 — clarify oracle authority/version. Score artifact against independent frozen host oracle; manifest expectations only diagnostic. Negative test changes and re-hashes manifest without changing oracle.

Evidence checked by reviewer: Node v24.7.0; pinned commit and three skill files exist; six sources readable only from parent; first65 lines of old runners support non-reuse rationale.
