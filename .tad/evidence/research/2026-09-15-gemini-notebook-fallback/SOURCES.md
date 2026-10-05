# SOURCES — Gemini Notebook（原 NotebookLM）与 TAD fallback 链

> provenance：每条 load-bearing 结论 → 来源 → 检索日期。检索日期统一 **2026-09-15**（除注明）。
> Tier：1=一手/官方/上游仓库；2=可信二手/厂商文档；3=一般网页/博客。

| ID | Tier | 标题 | URL | 发布/版本日期 | 检索日期 | 支撑的结论 |
|----|------|------|-----|--------------|----------|-----------|
| S1 | 1 | Do better research with NotebookLM（Google 官方博客） | https://blog.google/innovation-and-ai/products/notebooklm/better-research-notebooklm/ | 2026-06-08 | 2026-09-15 | F1.2（Gemini 3.5+Antigravity、secure cloud computer、100+ skills、自发现来源、输出格式） |
| S2 | 1 | NotebookLM is now Gemini Notebook（Google 官方博客） | https://blog.google/innovation-and-ai/products/gemini-notebook/notebooklm-gemini-notebook/ | 2026-07-16 | 2026-09-15 | F1.1（更名/日期/独立产品）、F1.2（Pro 网页端 rollout）、Q2（源锚定未变） |
| S3 | 1 | Workspace Updates：NotebookLM is now Gemini Notebook / Manage external sharing for Gemini Notebook | https://workspaceupdates.googleblog.com/ | 2026-07-16 / 2026-09-10 | 2026-09-15 | F1.1（企业面命名、Extended rollout、自动重定向） |
| S4 | 1 | notebooklm-py README（含 July 2026 更名注记 + 仓库标题） | https://github.com/teng-lin/notebooklm-py | July 2026 注记 | 2026-09-15 | F2.1（"same underlying service, works unchanged"，包名保留） |
| S5 | 1 | notebooklm-py ADR-0028: Renaming the package for Gemini Notebook | https://github.com/teng-lin/notebooklm-py/blob/main/docs/adr/0028-gemini-notebook-rename.md | Proposed v3（~2026-08-03） | 2026-09-15 | F2.5、F3.2（dist→gemini-notebook-py at 0.9.0；import/CLI 永久保留；typosquat 风险） |
| S6 | 1 | notebooklm-py Releases / CHANGELOG（0.8.0/0.8.1/0.8.2） | https://github.com/teng-lin/notebooklm-py/releases | 0.8.0=2026-08-03；0.8.1=2026-08-14；0.8.2=2026-09-02 | 2026-09-15 | F2.2（0.8.0 首发登录修复）、F2.5（0.9.0 未发布）、F3.4-CE7（0.8.2 Android backend） |
| S7 | 1 | notebooklm-py Issue #2022: Login fails — rebranded to Gemini Notebook | https://github.com/teng-lin/notebooklm-py/issues/2022 | 2026-07-29（修复 v0.8.0） | 2026-09-15 | F2.2（登录断带 < 0.8.0）、F2.4（RPC 未迁移、仅页面路由 302） |
| S8 | 1 | notebooklm-py Issue #2019: RPC Health Check Authentication Failure | https://github.com/teng-lin/notebooklm-py/issues/2019 | 2026-07-28（更新 2026-08-03） | 2026-09-15 | F2.2 佐证（cutover 当日、CLI 免疫、脚本 cookie 域缺陷）；Issue #294（0.3.4 RPC null-result 历史 bug） |
| S9 | 1 | Google Cloud：Gemini Notebook Enterprise — Create and manage notebooks (API) | https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks | N/A | 2026-09-15 | F3.4-CE1（官方仅企业级 API） |
| S10 | 2 | The Verge / TechCrunch / 9to5Google / the-decoder / SiliconANGLE（2026-07-16 更名报道） | https://www.theverge.com/tech/966112/google-gemini-notebook-notebooklm · https://techcrunch.com/2026/07/16/google-continues-its-renaming-streak-by-turning-notebooklm-to-gemini-notebook/ · https://9to5google.com/2026/07/16/notebooklm-gemini-notebook/ · https://the-decoder.com/google-rebrands-notebooklm-as-gemini-notebook-and-opens-its-search-app-to-third-party-integration/ · https://siliconangle.com/2026/07/16/google-rebrands-notebooklm-gemini-notebook-focusing-on-ecosystem-accessibility/ | 2026-07-16 | 2026-09-15 | F1.1 交叉验证 |
| S11 | 2 | The Verge：NotebookLM's Gemini 3.5 upgrade adds a cloud computer | https://www.theverge.com/tech/944325/google-notebooklm-ai-gemini-update | 2026-06-08 | 2026-09-15 | F1.2 交叉验证（Gemini 3.5 / Antigravity / cloud computer / 输出格式） |
| S12 | 1（本仓库自证） | TAD 仓库文件 | `.tad/config-workflow.yaml`(L787-791) · `.tad/cross-model/capabilities.yaml`(L25-40) · `.tad/cross-model/setup-notebooklm.sh`(L39-40) · `research/CLAUDE.md`(L39-42) · 全仓 grep 计数 | 工作树 @2026-09-15 | 2026-09-15 | F3.1、F3.2、F3.3（分类、链结构、pin 0.3.4） |
| S13 | 3 | Notebook Clipper：Gemini Notebook API — What's Available Today | https://notebookclipper.com/blog/gemini-notebook-api | 2026-03-14 | 2026-09-15 | F3.4-CE1（无消费级 API；社区工具）— 仅辅助，一手锚为 S9 |
| S14 | 3 | Ryan Nichols：NotebookLM Is Now Gemini Notebook — secure cloud computer | https://realryannichols.com/posts/gemini-notebook-secure-cloud-computer-code-execution-2026 | 2026-07-23 | 2026-09-15 | F3.4-CE4（代码执行安全规格缺失、可用性分层） |
| S15 | 1 | notebooklm-py 源码 tag v0.3.4（静态核验） | https://github.com/teng-lin/notebooklm-py/tree/v0.3.4 ｜ `src/notebooklm/cli/session.py`(L47-48,L234) ｜ `src/notebooklm/auth.py`(L49-52) | tag v0.3.4 | 2026-09-15 | Q3/CE2 的代码级证据：0.3.4 硬编码 `NOTEBOOKLM_HOST="notebooklm.google.com"` 与 `ALLOWED_COOKIE_DOMAINS`（不含 `notebook.google.com`） |
| S16 | 1 | notebooklm-py v0.8.2 release notes | https://github.com/teng-lin/notebooklm-py/releases/tag/v0.8.2 | 2026-09-02 | 2026-09-15 | CE7（Android gRPC backend；master-token 更强凭证的权衡） |

## 否定性证据说明
- "无消费级官方 API"是**否定命题**，一手锚点是 S9（官方仅企业 API）+ 官方 @NotebookLM 号承诺（见 S13 转述，无时间线）；S13 为 Tier-3 聚合博客，仅辅助。

## 未独立核验（如实标注）
- "30M 用户 / 600k 组织"为 Google 自报（S2/S10），无独立来源。
- notebooklm-py GitHub star 数在不同页面显示不一致（README 徽章 vs 仓库页），未承重，未采用。
- 0.3.4 登录失效为**静态源码证据**（S15），非本机 live 复现（本机无该 venv、无 Google 账号）。
