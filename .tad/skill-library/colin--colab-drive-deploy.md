# colab-drive-deploy

**Source project**: Colin声音项目
**Date**: 2026-06-03
**SCAND**: SCAND-20260603-colab-drive-deploy
**Type**: judgment

## Pattern
When deploying ML training to Google Colab via Claude Code, follow a Drive-first execution pattern: upload data/scripts to Google Drive first, then mount in Colab, avoiding data loss from session disconnects and account conflicts. Key steps: Drive upload → Colab mount → checkpoint to Drive → resume from Drive state.

## T3 Status
T3 candidate for ml-training pack WHEN a 2nd project corroborates the same pattern (per ≥2-project Domain Pack decision rule). Currently single-project evidence only.
