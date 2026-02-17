# TAD Status Check Command

When this command is triggered, check and report TAD configuration status:

## ⚠️ MANDATORY OUTPUT FORMAT

**This command MUST produce standardized status output:**

### 📊 Status Report Template
```
TAD Framework Status Report
Generated: [timestamp]

🔍 INSTALLATION CHECK
[✅/❌] Core directory structure (.tad/, .claude/commands/)
[✅/❌] Agent definition files (tad-alex.md, tad-blake.md)
[✅/❌] Configuration files (config.yaml + module files)
[✅/❌] Template files (.tad/templates/)
[✅/❌] Project context files (PROJECT_CONTEXT.md, CLAUDE.md)

🧩 v2.4.0 MODULES
[✅/❌] Modular Config (config-agents, config-quality, config-execution, config-platform)
[✅/❌] Ralph Loop configured (.tad/ralph-config/)
[✅/❌] Skills System (8 skills in .tad/skills/)
[✅/❌] Skills directory (.tad/skills/)
[✅/❌] Pair Testing template (.tad/templates/test-brief-template.md)

📋 CONFIGURATION VERIFICATION
- Version: [version number from .tad/version.txt]
- Config modules: [count]/6 loaded
- Skills: [count]/8 available in .tad/skills/
- Scenarios: [count]/6 configured
- Templates: [count] output format templates
- Ralph Loop: [enabled/disabled]

⚡ READINESS STATUS
[✅/❌] Ready for Agent A (Alex) activation
[✅/❌] Ready for Agent B (Blake) activation
[✅/❌] Ready for triangle collaboration

🚨 ISSUES (if any)
- [List specific issues]
- [Remediation suggestions]

📋 NEXT ACTIONS
[Specific next steps based on status]
```

---

## Check TAD Installation Status

```markdown
Checking TAD Framework status...

1. Core Files:
   - Check if .tad/config.yaml exists
   - Check if .tad/version.txt exists (should read 2.4)
   - Check if .claude/commands/tad-alex.md exists
   - Check if .claude/commands/tad-blake.md exists
   - Check if CLAUDE.md exists (TAD rules)
   - Check if PROJECT_CONTEXT.md exists

2. Modular Configuration:
   - Read .tad/config.yaml (master index)
   - Check config modules exist:
     - .tad/config-agents.yaml
     - .tad/config-quality.yaml
     - .tad/config-workflow.yaml
     - .tad/config-execution.yaml
     - .tad/config-platform.yaml
   - Verify command_module_binding section present

3. Features:
   - Ralph Loop: Check .tad/ralph-config/loop-config.yaml exists
   - Ralph Loop: Check .tad/ralph-config/expert-criteria.yaml exists
   - Skills: Check .tad/skills/ contains 8 skill directories
   - Templates: Check .tad/templates/output-formats/ has format files
   - Pair Testing: Check .tad/templates/test-brief-template.md exists

4. Project Files:
   - Check .tad/active/handoffs/ directory
   - Check .tad/project-knowledge/ directory
   - List existing project documents

5. Report:
   If all checks pass:
   ✅ TAD Framework v2.4.0 installed
   ✅ Configuration valid (modular config loaded)
   ✅ v2.4.0 features available (Ralph Loop, Skills, Pair Testing)
   ✅ Ready for use

   If issues found:
   ⚠️ Issues detected:
   - [List missing files]
   - [List configuration problems]

   Run '/tad-init' to fix issues.
```
