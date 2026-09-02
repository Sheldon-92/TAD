# Phase 3 Live YouTube Smoke Disposition

**Date:** 2026-09-02
**Disposition:** `experimental_degraded`

The public YouTube UI smoke was attempted after deterministic verification. Google Chrome
is installed at `/Applications/Google Chrome.app`. The available Codex Chrome-control package
could not bootstrap because it imported a missing older Browser runtime module:

```text
Cannot find module .../openai-bundled/browser/26.818.61809/scripts/browser-service.mjs
```

No YouTube page or extension UI was operated, so this is not claimed as a live success or a
product failure. The exact shipped MAIN-world capture function was instead executed through
the deterministic VM suite for success, timeout, missing player, thrown error, fetch
rejection, oversize, XHR cleanup, and re-entry. Repairing Codex browser-control packaging or
installing another automation stack is outside this Phase's approved scope.

