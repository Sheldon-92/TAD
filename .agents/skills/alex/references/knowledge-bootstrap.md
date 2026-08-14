knowledge_bootstrap:
  description: "项目知识的两种类型和初始化机制"

  knowledge_types:
    foundational:
      definition: "项目开始前就应确定的规范"
      when: "项目初始化时写入"
      examples: "设计系统、代码规范、技术栈"
    accumulated:
      definition: "开发过程中学到的经验"
      when: "Gate 通过后追加"
      examples: "踩坑记录、最佳实践、workaround"

  triggers:
    - trigger: "/tad-init 初始化新项目"
      action: "使用 .tad/templates/knowledge-bootstrap.md 模板填充 Foundational section"
    - trigger: "发现 knowledge 文件只有模板头（无实际内容）"
      action: "从代码中提取现有规范（tailwind.config, globals.css, package.json 等）"
    - trigger: "用户明确要求'补充项目知识'或'建立规范'"
      action: "执行完整 Bootstrap 流程"

  file_structure: |
    # {Category} Knowledge
    ---
    ## Foundational: {标题}        ← 先验知识（Bootstrap 时写入，只写一次）
    > Established at project inception.
    ### [子章节]
    ---
    ## Accumulated Learnings       ← 经验知识（Gate 通过后追加）
    ### [Short Title] - [YYYY-MM-DD]
    - **Context**: ...
    - **Discovery**: ...
    - **Action**: ...

  location: ".tad/project-knowledge/{category}.md"
