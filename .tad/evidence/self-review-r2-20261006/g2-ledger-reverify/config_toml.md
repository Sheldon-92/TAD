# config_toml — A 类复核（2026-10-06）
探针：`codex --help`/`codex exec --help` 示 -c/--config 覆盖项。文档复查：config-basic（2026-10-06）载明优先级序：CLI flags/--config > 项目 .codex/config.toml（trusted only）> profile > 用户 ~/.codex/config.toml > cloud-managed > system > 内置默认。
判定：相符（CLI 显式设置优先于项目与用户默认）→ 刷新（next_review 2026-12-05）。
