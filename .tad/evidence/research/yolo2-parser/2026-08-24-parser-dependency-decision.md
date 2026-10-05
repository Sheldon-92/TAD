# YOLO 2 Phase 1 — JavaScript parser dependency decision

Date: 2026-08-24  
Decision owner: Human (option 1)  
Question: Replace the bypassable hand-written comment scanner with which pinned, mature JavaScript parser?

## Decision

Use `acorn@8.18.0` as the only new development dependency. Parse the four Phase 1 entry graphs with `ecmaVersion: 2020`, `sourceType: "module"`, and Acorn's token stream. Import traversal and forbidden-API checks operate on AST nodes; the one computed mutation import is matched against parser-produced tokens, never a hand-written comment/string/RegExp scanner.

The dependency must be exact (`"acorn": "8.18.0"`, no range), installed with scripts disabled, and locked in a committed npm-v6-compatible `package-lock.json` (`lockfileVersion: 1`). Phase 4 still must run the frozen suite and author verifier on actual Node 14.0.x; package metadata is not runtime proof.

## Options compared

| Option | Current evidence | Fit | Decision |
|---|---|---|---|
| Acorn 8.18.0 | Full ESTree parser, ESM/CJS, zero dependencies, MIT, package engine `>=0.4.0`, current changelog includes tokenizer/RegExp fixes | Smallest dependency surface; sufficient for plain `.mjs` and import/API analysis | Selected |
| `@babel/parser` 7.29.8 | Full parser with JSX/Flow/TypeScript/proposal support; one dependency (`@babel/types`) | Capable but adds unused syntax surface and a transitive dependency | Rejected |
| Esprima 4.0.1 | ESTree, zero dependencies, but published language coverage/documentation centers on ECMAScript 2019 and its release line is much older | Higher risk of rejecting syntax already accepted by the project | Rejected |
| Custom tokenizer/scanner | No dependency | Cycle 3 proved RegExp-vs-comment lexical ambiguity is easy to get wrong; maintaining a JavaScript lexer is outside Phase 1's purpose | Rejected by human option 1 |

## Primary sources

- Acorn repository and package metadata: https://github.com/acornjs/acorn
- Acorn package manifest (`8.18.0`, engines, exports, license): https://github.com/acornjs/acorn/blob/master/acorn/package.json
- Acorn changelog: https://github.com/acornjs/acorn/blob/master/acorn/CHANGELOG.md
- npm package page: https://www.npmjs.com/package/acorn
- Babel parser documentation: https://babeljs.io/docs/babel-parser
- Babel parser npm package: https://www.npmjs.com/package/@babel/parser
- Esprima repository: https://github.com/jquery/esprima
- npm lockfile format: https://docs.npmjs.com/files/package-lock.json/
- npm install flags and lock semantics: https://docs.npmjs.com/cli/install/

## Supply-chain pre-install audit

### Identity and provenance

- Exact name `acorn` matches the official `acornjs/acorn` repository manifest and npm package.
- Registry metadata for `8.18.0`: MIT, three listed maintainers, git head `d788421b242ddccb28040f1431438ee5cf474208`, tarball `https://registry.npmjs.org/acorn/-/acorn-8.18.0.tgz`.
- Exact registry integrity: `sha512-lGq+9yr1/GuAWaVYIHRjvvySG5/4VfKIvC8EWxStPdcDh/Ka7FG3twP6v4d5BkravUilhIAsG4Qj83t02LWUPQ==`.
- The published package has zero runtime dependencies. A temporary exact install followed by `npm audit signatures --json` exited 0 with `invalid: []` and `missing: []`, establishing the npm registry-signature check for the selected artifact. A separate Sigstore provenance attestation was not asserted; lock integrity, installed-byte pins, and registry/repository identity checks remain mandatory.

### Behavioral analysis

`npm pack acorn@8.18.0 --ignore-scripts` produced a 10-file tarball (133,521 bytes compressed; 565,327 unpacked). Inspection found parser distribution files, declarations, CLI, README, changelog, license, and package manifest. No imports of filesystem, child-process, network, HTTP, or HTTPS modules; no filesystem-write or process-spawn calls were found. The package has `prepare` for its own source build but no preinstall/install/postinstall lifecycle script in the published manifest.

The acceptance verifier also pins the installed bytes it actually loads: published `package.json` SHA-256 `5c1ed7259579a7899b303f514b0194adcb9fe474fc7d136a84c6a45f10eefc84` and `dist/acorn.js` SHA-256 `fc3ed7b81e58464715d0291402892f22c3d86ea75302645a330390f85d8015c9`. Resolution and realpath must remain under the reviewed repository's `node_modules/acorn/`; a matching lockfile alone is insufficient.

Decision: ALLOW as an exact dev dependency, conditional on the locked integrity value and scripts-disabled install. This analysis would catch a litellm-class change if a future version introduced install scripts, network/process APIs, obfuscation, or unexpected files; it does not replace future version-diff review.

### Typosquat check

The official name was derived from the repository, not typed from memory. Registry probes for representative swap/omission/addition/homoglyph-style ASCII variants `acrom`, `acor`, `acornn`, and `ac0rn` returned unregistered on 2026-08-24. Exact-name and publisher/repository checks remain authoritative; this small probe is not a full registry-wide typosquat audit.

### Lockfile policy

The repository currently has a manifest but no lockfile. For this dependency change, Phase 1 requires a committed npm lockfile because the parser is part of the acceptance trust boundary. The lock must contain exactly one dependency (`acorn@8.18.0`), HTTPS registry URL, the SHA-512 integrity above, `dev: true`, and `lockfileVersion: 1` so npm 5/6 (the Node 14-era format) can consume it. `npm-shrinkwrap.json`, `yarn.lock`, and `pnpm-lock.yaml` remain absent.

## Gate consequences

- CRITICAL/HIGH behavioral or integrity findings block Gate 2/3; none were found in this pre-install pass.
- Any package/version/integrity/registry/lockfile drift is a hard failure.
- Live `npm audit signatures --json` must exit 0 with empty `invalid` and `missing` arrays and match saved evidence; unavailable verification blocks acceptance.
- Parser load failure is `E_ACORN_MISSING` and cannot degrade to the old scanner.
- Parse failure is fail-closed (`E_ACORN_PARSE`); no regex/comment fallback exists.
- Add a negative control using a legal RegExp literal containing `/*`, followed by a real external dynamic import. It must fail with `E_DYNAMIC_EXTERNAL_IMPORT`.
