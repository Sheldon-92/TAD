# Phase 3R live evidence

## HTTPS rendered-page capture — PASS

Run on 2026-09-02 with `/Applications/Google Chrome.app` and an isolated temporary
TAD-owned profile. Each command below exited 0.

```bash
node research/scripts/browser-capture.mjs launch https://example.com --headless --profile /tmp/tad-local-wiki-p3r-live-profile-r2
# pid=5696 port=60775 profile=/private/tmp/tad-local-wiki-p3r-live-profile-r2
node research/scripts/browser-capture.mjs tabs --port 60775 --json
# [{"id":"E5B923A70C4713B45D7146B8E09E3D8B","title":"Example Domain","url":"https://example.com/"}]
node research/scripts/browser-capture.mjs capture --port 60775 --tab E5B923A70C4713B45D7146B8E09E3D8B --kind page --dry-run
# dry-run
stat -f '%Sp %N' /tmp/tad-local-wiki-p3r-live-profile-r2 /tmp/tad-local-wiki-p3r-live-profile-r2/.tad-local-wiki-owner.json
# drwx------ profile; -rw------- marker
```

The final command made a real loopback CDP `Runtime.callFunctionOn` extraction. Publication
into a temporary Local Wiki root is covered independently by the deterministic importer
integration test; `--dry-run` keeps this live smoke test from changing the corpus.

## Public YouTube transcript probe — experimental_degraded

- Chrome: separate temporary TAD-owned profile, loopback `127.0.0.1:60654`.
- Target: public `https://www.youtube.com/watch?v=M7lc1UVf-VE`, requested language `en`.

```bash
node research/scripts/browser-capture.mjs launch 'https://www.youtube.com/watch?v=M7lc1UVf-VE' --headless --profile /tmp/tad-local-wiki-p3r-youtube-profile
# exit 0; pid=4279 port=60654
node research/scripts/browser-capture.mjs tabs --port 60654 --json
# exit 0; selected the single HTTPS YouTube tab
node research/scripts/browser-capture.mjs capture --port 60654 --tab F72F4F196D98505678C3E683ABDAEB84 --kind youtube --language en --dry-run
# exit 2; browser-capture: page extraction failed
```

The bounded native extractor returned no valid transcript result. No interception, retry,
anti-bot behavior, or external-extension fallback was added. Deterministic YouTube
transformation/import coverage remains passing.
