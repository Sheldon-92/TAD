# External rollback manifest — Local Wiki Phase 3

The extension directory is not Git-backed. These are the exact external paths changed by the
Phase 3 bridge and the recovery material for each.

| Path | Pre-state | Post SHA-256 | Forward / reverse recovery |
|---|---|---|---|
| `popup/popup.js` | byte backup `popup.js.before`, SHA `7f873c78a850ed491c087373d18eedf4e3a6f5fedd134627a84f3b05770eee73` | `51051bb97339589ddf0fe443dccef072568340e122be88d7e9521a52496da7a5` | `popup.js.forward.patch` / `popup.js.reverse.patch` |
| `tests/run.js` | exact reconstructed pre-image `tests-run.js.before`, SHA `f8e3556ab78f68fbd78dfba038b89e109e02225e4e6a7be0b95c3eff6ea5d95f` | `cefe0d3a2db20f9e86e89524f88add9b0414a7f8983c4110a592f7df69ca049a` | `tests-run.js.forward.patch` / `tests-run.js.reverse.patch` |
| `tests/youtube-capture-contract.test.js` | ABSENT | `44bf8595a2fa3eb83c02826297497c8d1b18733f01651ece7e070385ac92e101` | `youtube-capture-contract.test.js.forward.patch` / `youtube-capture-contract.test.js.reverse.patch` |

The first popup backup hash is separately recorded in `popup.js.before.sha256`; it equals the
backup bytes. `rollback-replay.log` is a real temporary-copy replay: `patch -E -p1` applies all
reverse patches, proves the two pre-state digests and the test's absence, then applies every
forward patch and proves all three final digests. `-E` is required by `patch` to turn the
reverse patch's `+++ /dev/null` result into deletion rather than a zero-byte file.
