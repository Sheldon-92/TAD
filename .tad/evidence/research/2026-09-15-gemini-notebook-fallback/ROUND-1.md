# ROUND 1 — 事实与能力变化（Q1, Q2）

> Engine phase（非 gate）。检索日期 2026-09-15。降级路径：Local Wiki 无命中 → `~/.tad-notebooklm-venv` 缺 → `claude_websearch`。

## 本轮查什么
Q1 更名事实/日期/独立性；Q2 能力变化与"源锚定核心命题是否改变"。

## 本轮发现

### F1.1 更名属实，生效 2026-07-16，仍为独立产品
- 官方博客《NotebookLM is now Gemini Notebook》(2026-07-16) 明确："We're renaming NotebookLM to Gemini Notebook. It's the same standalone product." 现为独立产品，同时更深接入 Gemini app 与 Search（AI Mode 规划中）。[S2]
- Workspace Updates 于 2026-07-16 起 Extended rollout；2026-09-10 进一步发布 Gemini Notebook 管理员外部分享控制，企业面命名已全面切换。[S3]
- 交叉验证（二手）：The Verge / TechCrunch / 9to5Google / the-decoder / SiliconANGLE 同日报道一致。[S10]
- 更名原委：品牌归拢 Gemini（原 Project Tailwind → NotebookLM → Gemini Notebook）。[S2][S10]

### F1.2 能力变化：2026-06-08 的架构升级才是实质变化；更名只是品牌
- 官方博客《Do better research with NotebookLM》(2026-06-08)：
  - 引擎升级到 **Gemini 3.5 + Antigravity**；[S1]
  - 每个 notebook 配 **secure cloud computer，可原生写/跑代码**（Python 沙箱），内置 **100+ curated software skills**；[S1]
  - 新增输出格式：图表 PNG/SVG、PDF/DOCX/MD/TXT、图片、CSV/JSON、XLSX、PPTX；[S1]
  - 可从"松散想法"起步，由工具自行检索并建议来源（来源仍由用户批准加入）。[S1]
- 2026-07-16 更名公告重申 Pro 网页端将逐步开放代码执行；Ultra 与合格 Workspace 客户已可用。[S2]
- 关键判断：**"只基于用户提供的源作答"这一核心命题未改变**。跨端同步与自发现来源扩大了输入/输出面，但源锚定依旧是产品定位。[S2][S1]

### F1.3 可用性分层（与 TAD 是否相关）
- 代码执行：Ultra + 合格 Workspace 已可用；Pro 网页版"未来数周"；免费档暂不提供。[S2][S14]
- 这对 TAD 的影响有限——TAD 只用"上传源 + ask 引用"能力，不依赖代码执行。

## 本轮新冒出的问题（下一轮方向）
- Q2b：新能力（代码执行 / 自发现来源）是否引入新的**安全/供应链**风险？→ 转 R3 的反例搜寻。
- Q3：TAD 实际调用的 `notebooklm` CLI 在新命名/新 RPC 下是否仍可用？→ R2 主攻。

## 本轮结论
更名事实成立、产品仍独立、"源锚定"定位未变。**更名本身是品牌层面**，实质能力升级发生在更名的约 5 周前（2026-06-08）。这为"文案改不改"提供了基准：改名是表述问题，不是能力断层问题——但需在 R2 验证工具层是否受更名影响。
