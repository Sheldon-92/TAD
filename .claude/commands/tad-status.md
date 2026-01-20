# TAD Status Check Command

When this command is triggered, check and report TAD configuration status:

## ⚠️ MANDATORY OUTPUT FORMAT

**This command MUST produce standardized status output:**

### 📊 Status Report Template
```
TAD Framework Status Report
Generated: [timestamp]

🔍 INSTALLATION CHECK
[✅/❌] Core directory structure
[✅/❌] Agent definition files
[✅/❌] Configuration files
[✅/❌] Template files
[✅/❌] Project context files

🧩 v1.4 MODULES
[✅/❌] Mandatory Questions (MQ1–MQ6) configured
[✅/❌] Research Phase enabled (requirement_elicitation.research_phase)
[✅/❌] Skills System enabled (.claude/skills present)
[✅/❌] Learn System enabled (/tad-learn available)

📋 CONFIGURATION VERIFICATION
- Version: [version number]
- Scenarios: [count]/6 configured
- Sub-agents: [count]/16 available
- Templates: [count] handoff templates
 - Skills: [count] files in .claude/skills

⚡ READINESS STATUS
[✅/❌] Ready for Agent A activation
[✅/❌] Ready for Agent B activation
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
   - Check if .claude/commands/tad-alex.md exists
   - Check if .claude/commands/tad-blake.md exists
   - Check if CLAUDE.md exists (TAD rules)
   - Check if PROJECT_CONTEXT.md exists

2. Configuration:
   - Read .tad/config.yaml version
   - Verify v1.4 modules present: `mandatory_questions`, `requirement_elicitation.research_phase`, `skills_system`, `learn_system`
   - Verify scenarios configured
   - Verify sub-agents listed

3. Project Files:
   - Check .tad/active/handoffs/ directory
   - Check .tad/project-knowledge/ directory
   - List existing project documents

4. Report:
   If all checks pass:
   ✅ TAD Framework v1.4 installed
   ✅ Configuration valid
   ✅ v1.4 modules available (MQ6, Research, Skills, Learn)
   ✅ Ready for use

   If issues found:
   ⚠️ Issues detected:
   - [List missing files]
   - [List configuration problems]

   Run '/tad-init' to fix issues.
```
