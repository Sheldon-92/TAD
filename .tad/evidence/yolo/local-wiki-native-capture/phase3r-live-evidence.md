# Phase 3R live evidence

## HTTPS rendered-page capture — PASS

- Chrome: `/Applications/Google Chrome.app`, headless temporary TAD-owned profile.
- CDP: loopback `127.0.0.1:9235`, temporary HTTPS target `https://example.com/`.
- CLI performed a real `Runtime.callFunctionOn` page extraction, then internal importer
  publication into a temporary Local Wiki root.
- Result: `research/raw/articles/example-domain.md`; SHA-256
  `394b1be73fe3e384b27b3bbced1fdd56c7223d9c1c3da8c7191567a245812042`.

## Public YouTube transcript probe — experimental_degraded

- Chrome: separate temporary TAD-owned profile, loopback `127.0.0.1:9236`.
- Target: public `https://www.youtube.com/watch?v=dQw4w9WgXcQ`, requested language `en`.
- The bounded native extractor returned no valid transcript result. No interception, retries,
  anti-bot behavior, or external-extension fallback was added. Deterministic YouTube
  transformation/import coverage remains passing.
