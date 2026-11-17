# TAD Self-Test — 驱动协议（会话驱动层）

> 上游正本注记（2026-11-06，TASK-20261106-004）：本协议 2026-10-31 建成于 Sober Creator 仓（TASK-20261031-005），2026-11-06 上游入框架源仓，本仓为正本。
> 基线治理与消费面见同目录伴生文档：`.tad/tests/self-test-companion.md`。

本协议归驱动会话执行。分工（沿 `.tad/scripts/pack-eval-runner.sh` 既定先例）：**脚本只断言、永不 spawn 子代理；spawn 归驱动会话**。确定层 runner 是 `.tad/tests/self-test.sh`，本协议管的是它管不了的那一半：探针的产生、落盘与处置。

## 触发时机

以下任一事件后，先跑自测再收口本轮工作：

- TAD 框架升级 / 整替落地后；
- hook、skill、config（`.claude/settings.json`、`.tad/capability-packs/` 等接线面）有改动后；
- 人点名要跑时。

## 前置：surface 先行

先跑 `bash .tad/tests/self-test.sh surface`。全绿才 spawn 探针——surface 红时先修接线，探针不背接线损坏的锅；surface 的 FAIL 无体重跑（见处置），修后整轮重跑。

## 探针与 spawn 纪律

四件探针，fixture 在 `.tad/tests/self-test-probes/`：

| 探针 fixture | id | 验什么 | capture 文件 |
|---|---|---|---|
| `probe-alex.md` | probe-alex | Alex 激活协议行为（A1） | `capture-alex.md` |
| `probe-blake.md` | probe-blake | Blake 激活协议行为（A2） | `capture-blake.md` |
| `probe-pack-pos.md` | probe-pack-pos | 包指针正例 announce 行为（A3） | `capture-pack-pos.md` |
| `probe-pack-neg.md` | probe-pack-neg | 包指针负例（不误报）（A4） | `capture-pack-neg.md` |

纪律：

- 每件探针 spawn **一个 fresh 子代理**；该子代理**不得参与过被测改动**（做过被测改动的实现者/评审者不合此独立性）。
- 任务 = 对应 fixture 的正文**整段原文**，不得增删、不得加提示、不得预告期望值（fixture 文本卫生由 AC13 守：正文不含任何真值字面，防探针鹦鹉学舌）。
- 探针只读盘面、只回文本，不写任何文件；落盘由驱动会话做。

## Capture 落盘

子代理的最终消息**逐字**存入 `.tad/evidence/self-test/runs/<日期>-v<版本>/capture-<id>.md`，其中 `<id>` 取上表 capture 文件名中 `capture-` 与 `.md` 之间的部分（`alex` / `blake` / `pack-pos` / `pack-neg`）。不许摘编、不许补字、不许把多件探针合并进同一文件。

## Assert 与 report

```bash
bash .tad/tests/self-test.sh surface
bash .tad/tests/self-test.sh assert --run-dir .tad/evidence/self-test/runs/<日期>-v<版本>
bash .tad/tests/self-test.sh run --run-dir .tad/evidence/self-test/runs/<日期>-v<版本>
```

assert 的真值一律在断言时从活盘重算（版本、计数、指针目标包），capture 里的值与之逐字比对；capture 缺失或字段缺失即 FAIL 并指名。run 模式把报告落到 `.tad/evidence/self-test/SELF-TEST-<日期>-v<版本>.md`，报告与 stdout 的末行同为 verdict 行。

## 处置（失败了怎么办）

- **探针项 FAIL**：只重 spawn 该探针一次。新 capture 存 `capture-<id>-try2.md`（try1 原样留盘），并以 try2 文件断言（runner 自动优先 try2）。再 FAIL 即真 FAIL——探针随机性只许被这一次重跑吸收，不许跑到过为止。经 try2 通过的项，run 报告的 Probes 节会显名 `NOTE <项>: passed on try2`；转述给人看时也必须提这条，不许只报绿。
- **surface FAIL**：无体重跑。先按 FAIL 行的指名修接线/盘面，修后整轮重跑（surface + 探针 + assert + run 全部重来），因为探针结论建立在接线成立的前提上。

## 上报口径

报给人时一条消息说清四件事，模板：

```
TAD 自测结果
报告: .tad/evidence/self-test/SELF-TEST-<日期>-v<版本>.md
verdict: <报告末行 verdict 原文>
scope: <surface-only | surface+probes>
FAIL 指名: <逐件列 FAIL 行的指名坏件；全绿时写「无」>
```

scope 必须单列成字段——不许只藏在 verdict 行的后缀里转述：只跑了 surface 的运行，末行是 `SELF-TEST: PASS (surface-only)`，转述时 scope 照写 `surface-only`，不得说成「自测全过」。全过只许指 scope = surface+probes 且 verdict 为裸 `SELF-TEST: PASS` 的运行。
