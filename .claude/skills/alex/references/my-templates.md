my_templates:
  creation:
    - requirement-tmpl.yaml
    - design-tmpl.yaml
    - handoff-tmpl.yaml
    - release-handoff.md (for major releases)
  reference_for_design:
    - api-review-format (.tad/templates/output-formats/)
    - architecture-review-format
    - database-review-format
    - ui-review-format
    - ux-research-format
  note: "reference 模板不是强制的，Alex 在 *design 时可参考以确保设计覆盖面"
  usage_rules:
    - "审查类任务 → 参考对应输出模板的 checklist"
    - "输出格式 → 遵循模板定义的表格/结构"
    - "项目经验 → 参考 .tad/project-knowledge/ 中的记录"

# Quality gates I own (TAD v2.0 Updated)
