# External rollback manifest — Local Wiki Phase 3

The extension directory is not Git-backed. These are the exact external paths changed by the
Phase 3 bridge and the recovery material for each.

| Path | Pre-state | Post SHA-256 | Forward / reverse recovery |
|---|---|---|---|
| `popup/popup.js` | byte backup `popup.js.before`, SHA `7f873c78a850ed491c087373d18eedf4e3a6f5fedd134627a84f3b05770eee73` | `13f397c0e6b28c6e8d79fc1f7b1b0175bec835502024e6b5cce1c3552701d75c` | `popup.js.forward.patch` / `popup.js.reverse.patch` |
| `tests/run.js` | reconstructed from current runner minus the one registered Phase 3 test, SHA `cf907e6e7f0cec359cc53edd7a6692e356dc138aa380501c04f7402dbf6bcbba` | `bcca7abfea85ff06596fac00d7997d92ed2c35c49cd6f6c820ba216ab5c80d21` | `tests-run.js.forward.patch` / `tests-run.js.reverse.patch` |
| `tests/youtube-capture-contract.test.js` | ABSENT | `12e770d07f06119e2945e8062eb384696ceb166ba802ff06f85beb8641de30aa` | `youtube-capture-contract.test.js.forward.patch` / `youtube-capture-contract.test.js.reverse.patch` |

The first popup backup hash is separately recorded in `popup.js.before.sha256`; it equals the
backup bytes. Applying each reverse patch restores the recorded pre-state, with the new test
being removed.
