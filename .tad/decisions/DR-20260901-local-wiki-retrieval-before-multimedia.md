# DR-20260901 — Local Wiki Retrieval Before Multimedia

**Status:** accepted by human instruction on 2026-09-01
**Authority:** “你自己使用yolo模式设计phase2，并自主完成”

## Decision

Local Wiki's former Phase 3 becomes Phase 2, but its product name is **Retrieval
Foundations**, not “install a vector database”. The former Phase 2 video/audio
ingest moves to Phase 3.

Phase 2 ships a local, file-traceable lexical retrieval baseline and evaluates it
against real repository questions. Vector retrieval remains an optional follow-up
inside the retrieval architecture only when measured semantic-recall gaps justify
the dependency and operational cost.

## Why

- Retrieval benefits every existing and future source type; adding more media before
  findability compounds information debt.
- The current corpus is small (21 Markdown files, about 157 KB at design time), so a
  mandatory vector store is not evidence-based.
- SQLite FTS5 is locally available and provides BM25 ranking without a new service.
- `sqlite-vec` is still pre-v1 and may introduce breaking changes.
- Hybrid lexical + semantic retrieval is the likely mature destination, so the first
  phase must preserve a stable result/evaluation contract rather than bind the Wiki
  to one vector implementation.

## YOLO mandate

Alex may design and pass Gates 1/2; Blake may implement, test, review, commit, and
prepare Gate 3; Alex may perform Gate 4 and archive without additional checkpoints.
The mandate does not authorize network provider calls, paid embeddings, publishing,
pushing, deleting user data, or modifying unrelated dirty worktree state.
