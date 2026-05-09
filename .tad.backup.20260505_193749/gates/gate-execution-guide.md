# Gate Execution Guide for Agents

## 🎯 When to Execute Gates

### Gate 1: Requirements Clarity
**WHO**: Agent A (Alex)
**WHEN**: Immediately after receiving human requirements
**BEFORE**: Starting any design work
**COMMAND**: Copy checklist from quality-gate-checklist.md Gate 1

### Gate 2: Design Completeness
**WHO**: Agent A (Alex)
**WHEN**: After completing design, before handoff to Agent B
**BEFORE**: Using any handoff template
**COMMAND**: Copy checklist from quality-gate-checklist.md Gate 2

### Gate 3: Implementation Quality - **MANDATORY** 🔴
**WHO**: Agent B (Blake)
**WHEN**: After writing code, before claiming completion
**BEFORE**: Reporting back to Agent A
**COMMAND**: Copy checklist from quality-gate-checklist.md Gate 3

#### Prerequisites (BLOCKING)
- [ ] COMPLETION-*.md exists in `.tad/active/handoffs/`

#### Required Subagent Call
- **MUST call**: `test-runner` subagent
- **Output format**: Use `.tad/templates/output-formats/testing-review-format.md`
- **Output to**: `.tad/evidence/reviews/{date}-testing-review-{task}.md`

#### Evidence Check (BLOCKING)
Gate will NOT pass unless:
- [ ] test-runner subagent was called
- [ ] Evidence file exists in `.tad/evidence/reviews/`
- [ ] Evidence follows testing-review-format template

#### Knowledge Capture Step (MANDATORY)
After Gate 3 passes, Blake MUST:
1. **Review what was learned** - Any non-obvious solutions, workarounds, or gotchas?
2. **Check skip criteria** - Is this generic knowledge AI already knows? If yes, skip.
3. **Record if applicable** - Add entry to appropriate `.tad/project-knowledge/{category}.md`
4. **Document decision** - In Gate completion, note "Recorded in X" or "Skipped - no new knowledge"

### Gate 4: Integration Verification - **MANDATORY** 🔴
**WHO**: Both Agent A & Agent B
**WHEN**: Before final delivery to human
**BEFORE**: Presenting working software
**COMMAND**: Copy checklist from quality-gate-checklist.md Gate 4
**⚠️ CRITICAL**: Alex MUST call subagents for actual review (not paper review only)

#### Prerequisites (BLOCKING)
- [ ] Gate 3 passed

#### Required Subagent Calls
MUST call these subagents:

1. **`security-auditor`**
   - Output format: `.tad/templates/output-formats/security-review-format.md`
   - Output to: `.tad/evidence/reviews/{date}-security-review-{task}.md`

2. **`performance-optimizer`**
   - Output format: `.tad/templates/output-formats/performance-review-format.md`
   - Output to: `.tad/evidence/reviews/{date}-performance-review-{task}.md`

3. **`code-reviewer`** (ALWAYS required)
   - Output to: `.tad/evidence/reviews/{date}-code-review-{task}.md`

4. **`ux-expert-reviewer`** (if UI involved)
   - Output to: `.tad/evidence/reviews/{date}-ux-review-{task}.md`

#### Evidence Check (BLOCKING)
Gate will NOT pass unless:
- [ ] security-auditor was called + evidence file exists
- [ ] performance-optimizer was called + evidence file exists
- [ ] Both evidence files follow correct template format

#### Knowledge Capture Step (MANDATORY)
After review completes, Alex MUST:
1. **Review insights** - Any patterns, anti-patterns, or architectural insights discovered?
2. **Check skip criteria** - Is this project-agnostic knowledge? If yes, skip.
3. **Record if applicable** - Add entry to appropriate `.tad/project-knowledge/{category}.md`
4. **Document decision** - In Gate completion, note "Recorded in X" or "Skipped - no new knowledge"

### Gate 3R: Release Quality (Version Releases)
**WHO**: Agent B (Blake)
**WHEN**: Before executing any version release
**BEFORE**: Running npm version or deploying
**COMMAND**: Copy checklist from quality-gate-checklist.md Gate 3R

### Gate 4R: Release Verification (Post-Release)
**WHO**: Agent B (Blake)
**WHEN**: After release deployment
**BEFORE**: Marking release complete
**COMMAND**: Copy checklist from quality-gate-checklist.md Gate 4R

---

## ⚡ Quick Gate Execution Protocol

### Step 1: Copy Checklist
```markdown
Create new file: .tad/working/gates/gate-[N]-[project]-[timestamp].md
Copy relevant checklist from quality-gate-checklist.md
```

### Step 2: Execute Verification
```markdown
Work through each checkbox systematically
Document evidence for each check
Mark ✅ only when actually verified
```

### Step 3: Gate Decision
```markdown
PASS: Fill out completion template, proceed to next phase
FAIL: Document failure reasons, fix issues, re-execute gate
OVERRIDE: Get human approval, document risks accepted
```

### Step 4: Archive Results
```markdown
Save completed checklist in .tad/working/gates/
Reference gate completion in handoff documents
```

---

## 🚨 Critical Gate Rules

### NEVER Skip Gates
- Gates catch the exact problems found in real usage transcripts
- Each gate addresses specific failure patterns
- Skipping gates leads to function call errors, missing data flows, safety issues

### NEVER Assume Pass
- Check every box explicitly
- Provide evidence for each verification
- When in doubt, mark as FAIL and investigate

### NEVER Rush Through
- Gates are designed to save time by preventing rework
- Thorough gate execution prevents downstream problems
- Better to spend 5 minutes on gate than 2 hours debugging

### Always Document
- Future projects learn from gate execution logs
- Patterns in gate failures indicate systemic issues
- Evidence supports continuous improvement

---

## 📊 Gate Effectiveness Tracking

### Success Metrics
- **First-time pass rate**: Higher is better
- **Issue detection**: Problems caught at gates vs. later
- **Cycle time improvement**: Faster delivery through fewer reworks

### Warning Signs
- Multiple gate failures on same project
- Same agent failing same gate repeatedly
- Issues discovered after gate passage

### Improvement Actions
- Update checklist when new issue types found
- Additional agent training on frequently failed checks
- Process improvements for common failure patterns

---

## 🎓 Agent Training on Gates

### Agent A (Alex) Gate Focus
- **Requirements Clarity**: Deep user value understanding
- **Design Completeness**: Function existence verification
- **Handoff Quality**: Complete specification packages

### Agent B (Blake) Gate Focus
- **Implementation Quality**: Code compilation verification
- **Data Flow Testing**: End-to-end functionality
- **Integration Verification**: Regression testing
- **Release Quality (3R)**: Pre-release verification
- **Release Verification (4R)**: Post-deployment health check

### Shared Responsibilities
- Safety-first mindset: User health and security
- Historical code awareness: Reuse before create
- Sub-agent utilization: Use specialized expertise
- Evidence collection: Document all verifications