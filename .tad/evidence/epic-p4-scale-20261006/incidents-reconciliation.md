# incidents 索引对账表 — Epic Phase 4 件 4.3b（2026-10-06，Blake，AC24）

对账口径：索引条目集（`_index.md` 链接目标）↔ 在盘 incident 文件集（`2026-05/`、`2026-06/` 两月目录），`LC_ALL=C comm` 双向差集。

| 面 | 计数 |
|---|---|
| 在盘 incident 文件 | 25（2026-05：17／2026-06：8） |
| 索引链接目标 | 26 |
| 仅盘面（漏登记） | **0** |
| 仅索引（悬空） | **1**（逐项处置见下） |

## 差集逐项处置

| 项 | 类别 | 处置 |
|---|---|---|
| `2026-05/yq-normalizes-once-idempotent.md` | 悬空条目 | **注记保留**：该条目在索引内已以删除线标注 GRADUATED——内容已于 2026-06-02 升格为 L2 pattern（shell-portability「mikefarah yq -i Normalizes Whole File on First Write」，该 pattern 在盘可查），源 incident 文件随毕业移除。悬空系毕业谱系留痕、非登记错误；条目本体即注记，不删不补 |

## 结论

索引↔盘面实质等账：25 件在盘 incident 全部在册，唯一差集为已注记的毕业条目。2026-07 后无新 incident 落盘之存量事实（HANDOFF §2.4）不在本件处置范围——是否补写归 PM 后续自查批议题（`size-inventory.md` 外的登记行见 COMPLETION 遗留节）。

`_index.md` 末尾已加对账验证行（日期＋双向差集计数），与本表同值。
