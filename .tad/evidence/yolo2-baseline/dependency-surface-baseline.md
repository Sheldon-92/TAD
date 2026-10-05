# YOLO 2 Phase 1 — Alex-authorized dependency delta

Captured by: Alex (design authority)  
Captured at: 2026-08-24  
Repository HEAD at capture: `bfce27f3469960946679b03e2562ece67a34f0f3`

## Frozen pre-change state

```tsv
SHA256	62a2f529de107940ca5b7424f0f1f56711e19d5f67862668031890a0fbb3a32d	package.json
ABSENT	-	package-lock.json
ABSENT	-	npm-shrinkwrap.json
ABSENT	-	yarn.lock
ABSENT	-	pnpm-lock.yaml
```

## Exact authorized delta

The human selected option 1 on 2026-08-24: permit one pinned mature JavaScript parser rather than continue the hand-written scanner.

1. `package.json` may differ from the frozen parent only by adding:

   ```json
   "devDependencies": {
     "acorn": "8.18.0"
   }
   ```

2. Create `package-lock.json` with `lockfileVersion: 1` and exactly one dependency:

   ```json
   {
     "acorn": {
       "version": "8.18.0",
       "resolved": "https://registry.npmjs.org/acorn/-/acorn-8.18.0.tgz",
       "integrity": "sha512-lGq+9yr1/GuAWaVYIHRjvvySG5/4VfKIvC8EWxStPdcDh/Ka7FG3twP6v4d5BkravUilhIAsG4Qj83t02LWUPQ==",
       "dev": true
     }
   }
   ```

3. `npm-shrinkwrap.json`, `yarn.lock`, and `pnpm-lock.yaml` remain absent.
4. Install/generate with lifecycle scripts disabled. No range, alias, git/file source, extra direct dependency, transitive dependency, alternate registry, or extra package-lock key is authorized.
5. The verifier resolves only `<repo>/node_modules/acorn/dist/acorn.js` with no realpath escape and pins the published bytes: `package.json` SHA-256 `5c1ed7259579a7899b303f514b0194adcb9fe474fc7d136a84c6a45f10eefc84`; CommonJS parser SHA-256 `fc3ed7b81e58464715d0291402892f22c3d86ea75302645a330390f85d8015c9`.
6. A live `npm audit signatures --json` must exit 0 with exactly empty `invalid` and `missing` arrays and equal `.tad/evidence/yolo2-baseline/acorn-signature-audit.json`. Failure or unavailable registry verification is blocking.

The Alex-owned verifier compares the implementation parent `package.json` byte hash to the frozen SHA, compares the child package semantically after removing the one allowed field, verifies both child files equal their committed Git blobs, and checks the exact lock object. Blake MUST NOT edit or regenerate this baseline.

Research and pre-install trust evidence: `.tad/evidence/research/yolo2-parser/2026-08-24-parser-dependency-decision.md`.
