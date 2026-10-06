# PM 裁定 — Epic Phase 1 实施两件（2026-10-06）

## 一、写集扩展（案 A）追认

实施中途停步所裁「三件 CAPABILITY.md 的 keywords 行以现行投影为源回同步」已在 HANDOFF §7 WRITE-SET EXPANSION 注记在册（L358），扩展面经 PM 盘上核实：三件各仅 keywords 一行、type/version 无分歧、回同步后 validate 27/27 exit 0。**追认成立**，Gate 3 按扩展后写集判读。附带事实（投影曾带外增补、未回写源包；仓内 registry 仍含旧 keywords）已如实披露——发版收口时由 PM 跑 scan-packs regen 使仓内 registry 对齐（隔离副本已验证生成值与投影一致），此步列入本链收口清单，不算实施缺口。

## 二、AC23 判读裁断

事实：初装副本 brain-index.md 实存、生成步可见失败已落（件 1.9 处置目标达成）；AC23 字面「读单全过」中另四件 project-knowledge 路径在初装副本缺失，成因是 installer 既有 zero-touch 设计（Option A：新装只给种子、principles/patterns 由项目自著、永不拷贝）。

**裁断：AC23 判读辖区以 installer 供给面为准。** 断言只能管供给方实际供给的东西；项目自著面不在 installer 供给面内，其缺失属设计形态（与 driftcheck (r) 形态同型逻辑），不作缺陷计。AC23 以「供给面全过＋自著面缺失已归因」判 **PASS（附归因）**。后续若要改 Option A 设计，另立议题，不在本链。

Gate 3 双审按本裁定判读 AC23，并对案 A 扩展面的行级保真独立复核。
