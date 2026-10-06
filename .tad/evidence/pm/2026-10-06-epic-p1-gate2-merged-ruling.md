# PM 合并裁定 — Epic Phase 1 Gate 2（2026-10-06）

- 对象：HANDOFF-2026-10-06-epic-p1-clearance（52,982 B／sha256 `767941d8…`）
- fit 路：CONDITIONAL（10,278 B／sha256 `8b224473…`）；tech 路：CONDITIONAL（正文 5,762 B／sha256 `fe8cb37c…`）
- **合并裁定：CONDITIONAL PASS**，下述四项销账后转 PASS。

## 两处设计裁断 · PM 确认

1. **件 1.1「改校验器·双类契约」成立**：两路独立抽核均坐实三处承重消费者依赖投影 type/keywords 键，删键路线不可行；二选一为上位文件明示的开放选项，设计选向不越口径。照设计实施。
2. **件 1.7 反向收敛成立**：生成器 heredoc 产出经两路亲测为非法 JSON（668 B／jq exit 5）、存档件合法（805 B／jq exit 0）；GM 登记倾向的事实前提（仅排版异）不成立。照设计实施：heredoc 向存档件对齐＋语义比对口径。**本裁定即对 GM 登记倾向的正式翻案记录**，Phase 收口后随批号知会 GM 时一并带明。

## 销账条件

- **B1（源 fit C1）**：Epic 件目表 1.7 行与票 TICKET-20261006 范围第 7 行各加裁断注记（指向 HANDOFF §4.7 与本裁定），由 PM 直接落注（两件均为 PM 维护面），定点核在本裁定尾行。
- **B2（源 tech C1）**：HANDOFF AC1–AC3 把 validate 调用形态写死为双参数 `validate "$PWD" <name>`，A2 自检步文（step3c3 草案）同改。交原设计 Alex 增补。
- **B3（源 tech C2）**：§4.9 check6 无条件集按实得**五件**点名写死（含 shell-portability.md 所在行），并注明提取规则对「Before editing」类条件句行的排除口径一句。交原设计 Alex 增补。
- fit 路四条 P2 注记为非条件：Gate 3 判读时按注记执行（件 1.9 条件式落点口径、genesis 惰性双保险、driftcheck 总 exit 判读、件 1.4 指针落点观察）。

## 增补与核销

Alex 增补 B2/B3 后，PM 定点核（改动行逐处＋HANDOFF 新字节/sha）连同 B1 落注一并销账，Gate 2 转 PASS，派 Blake 实施。

（B1 落注与核销行随后由 PM 追加于本件尾部。）

## PM 定点核销账（2026-10-06）

B1：Epic 件目表 1.7 行与票 TICKET-20261006 第 7 行的裁断注记已由 PM 落盘（双处均指向 HANDOFF §4.7 与本裁定）。B2/B3：增补完工说明（3,681 B）到盘；HANDOFF 修订后 53,861 B／sha256 `9c3cc3ff…` PM 复算全等；B2 四处 `validate "$PWD"` 命中与改点逐一对应（L166/L378/L379/L380），B3 于 L256 整段改（五件点名＋排除口径＋衔接句）。**四项条件全销，Gate 2 转 PASS。**
