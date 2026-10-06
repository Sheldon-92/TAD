# PM 裁定 — Epic P4 Gate 3 两条件与 gc 连带认领（2026-10-06）

Gate 3：SAFETY PASS；CODE CONDITIONAL（C-1/C-2）。PM 裁定：

- **C-1（AC27 字面 exit 0）**：按归因判读成立。release-verify 三 mode 非 0 的三因（freshness 台账过期、migration hop 为发版时点形态、guard 两重复 id）经双审复跑确认均非 P4 引入（P4 对 tad.sh 仅 +4 行接线、在案可证）。本链 AC27 以「归因判读」销账；release-verify 全绿列 **Epic 总收口发版步的实作项**（hop 随船与收口同步落地时逐 mode 复跑取绿，写进总收口清单执行记录）。guard 两重复 id 为既存件，随总收口分诊具名记录、不在本链修。
- **C-2（COMPLETION 远端尖错值）**：COMPLETION 两处 `526f1df3` 系错值（实测远端尖 7e407b7c），以可见追记更正，原文不改。
- **gc 连带认领（SAFETY P2-1）**：`git gc` 的 pack-refs 连带移除 `.git/refs/` 内 3 件 .sync-conflict 冻结副本一事，PM 在此显式认领——该变化是授权 gc 的标准连带、活内容可由远端 ref 再生、`.git/logs/` 的 F4 类冻结件实测仍全数在盘；与「同步冲突冻结原则」的边界自此写清：冻结纪律辖工作树面，`.git/refs` 的 loose ref 副本被 gc 打包属 git 内部整理面。此认领随总收口记录入 Epic 总完事卡。后续含 gc 的链，设计预检新增「.git/refs loose 件预检」一项（记入下轮自查批输入）。
- AC9 按两段口径判读（删除时点 8→8、gc 后链末 5），Gate 4 照此判。
