# TAD Quality Gates - Manual Verification Checklists

> ⚠️ **SUPERSEDED** — This file is superseded by `.tad/gates/gate-canonical-checklist.md` (SSOT).
> The canonical file is the authoritative source for Gate 1-4 checklist items.
> This file is retained for historical reference only. Do NOT edit gate items here.

## 🎯 Purpose
These manual checklists provide quality control when automated testing isn't available. Each gate requires explicit verification before proceeding to the next phase.

---

## 🚪 Gate 1: Requirements Clarity Gate

**Trigger:** After human provides requirements, before Agent A starts design

### ✅ Requirements Verification Checklist
**Agent A must verify:**
- [ ] **Business Value Clear**: Can explain WHY this is needed in one sentence
- [ ] **Success Criteria Defined**: Know exactly what "done" looks like
- [ ] **User Story Complete**: Has Who/What/Why structure
- [ ] **Scope Boundaries**: Clear about what's IN and what's OUT
- [ ] **Historical Code Searched**: Checked for existing similar implementations
- [ ] **Acceptance Criteria**: Testable and measurable criteria defined

### ⚠️ Gate Failure Conditions
- Business value unclear → Ask human for clarification
- Success criteria vague → Request specific metrics
- Missing user context → Gather user persona information
- No historical code search → Search before designing

### 📝 Gate Completion Template
```
✅ REQUIREMENTS CLARITY GATE PASSED
Date: [timestamp]
Verified by: Agent A (Alex)

Business Value: [One sentence explanation]
Success Criteria: [Specific measurable outcomes]
User Story: As [who] I want [what] so that [why]
Scope: IN: [items] | OUT: [items]
Historical Search: [Results of existing code search]
Acceptance Criteria: [List of testable criteria]

Approved for design phase ✅
```

---

## 🚪 Gate 2: Design Completeness Gate

**Trigger:** After Agent A completes design, before handoff to Agent B

### ✅ Design Verification Checklist
**Agent A must verify:**
- [ ] **Technical Specification Complete**: All components defined
- [ ] **Function Existence Verified**: All referenced functions actually exist
- [ ] **Data Flow Mapped**: Backend → Frontend path documented
- [ ] **API Design Detailed**: Endpoints, parameters, responses specified
- [ ] **User Safety Addressed**: Allergy warnings, health risks identified
- [ ] **Sub-Agent Plan Created**: Which sub-agents will be used when
- [ ] **Error Handling Designed**: Happy path + edge cases covered

### ✅ Handoff Package Verification
**Required in handoff to Agent B:**
- [ ] **File Paths Specified**: Exact files to modify/create
- [ ] **Function Names Listed**: Actual existing functions to use
- [ ] **UI Specification**: Layout, components, user interactions
- [ ] **Test Requirements**: What needs to be tested
- [ ] **Performance Targets**: Response time, load requirements

### ⚠️ Gate Failure Conditions
- Function names not verified → Search codebase to confirm existence
- Data flow incomplete → Map every step from API to UI
- Safety requirements missing → Add allergy/warning specifications
- Handoff package incomplete → Use standardized template

### 📝 Gate Completion Template
```
✅ DESIGN COMPLETENESS GATE PASSED
Date: [timestamp]
Verified by: Agent A (Alex)

Technical Specification: [✅ Complete / Details]
Function Verification: [List verified existing functions]
Data Flow: [Backend] → [Processing] → [Frontend display]
API Design: [Endpoint list with parameters]
Safety Features: [Allergy warnings, health alerts]
Sub-Agent Plan: [Which agents for which tasks]
Handoff Quality: [✅ Complete package using template]

Approved for implementation ✅
```

---

## 🚪 Gate 3: Implementation Quality Gate

**Trigger:** After Agent B writes code, before claiming completion

### ✅ Code Quality Verification Checklist
**Agent B must verify:**
- [ ] **Code Compiles**: No syntax errors, builds successfully
- [ ] **Function Calls Valid**: All called functions actually exist
- [ ] **Data Flow Working**: Backend calculations reach frontend display
- [ ] **User Interface Complete**: All computed fields visible to user
- [ ] **Safety Information Prominent**: Allergies/warnings clearly displayed
- [ ] **Error Handling Present**: Graceful handling of edge cases
- [ ] **Test Coverage Adequate**: Key functionality tested

### ✅ End-to-End Verification
**Agent B must test:**
- [ ] **API Response Valid**: Endpoints return expected data structure
- [ ] **Frontend Renders**: UI displays all backend-calculated fields
- [ ] **User Safety Visible**: Critical warnings are prominent
- [ ] **Performance Acceptable**: Response times meet requirements
- [ ] **Integration Working**: New code doesn't break existing features

### ✅ Knowledge Capture (MANDATORY)
**Agent B must record project knowledge if applicable:**
- [ ] **Implementation Discoveries**: Any non-obvious solutions, workarounds, or gotchas documented in `.tad/project-knowledge/`
- [ ] **Problems Solved**: Significant debugging insights or error resolutions recorded
- [ ] **Skip Criteria Checked**: If nothing new learned, confirm it's generic knowledge AI already knows

### ⚠️ Gate Failure Conditions
- Code doesn't compile → Fix syntax/import errors
- Function not found → Use existing functions or implement missing ones
- Data not displayed → Complete data flow implementation
- Safety info hidden → Make warnings prominent and visible
- Tests failing → Fix code until tests pass

### 📝 Gate Completion Template
```
✅ IMPLEMENTATION QUALITY GATE PASSED
Date: [timestamp]
Verified by: Agent B (Blake)

Code Quality: [✅ Compiles / ✅ No errors]
Function Calls: [List verified function calls]
Data Flow: [✅ Backend → Frontend working]
UI Completeness: [✅ All fields displayed]
Safety Display: [✅ Warnings prominent]
Performance: [Response time: X ms]
Test Results: [X/Y tests passing]

Knowledge Capture: [✅ Recorded in .tad/project-knowledge/{category}.md / ⏭️ Skipped - no new project-specific knowledge]

Ready for review ✅
```

---

## 🚪 Gate 4: Integration Verification Gate

**Trigger:** After implementation, before delivery to human

### ✅ System Integration Checklist
**Both agents must verify:**
- [ ] **Feature Works End-to-End**: Complete user journey functional
- [ ] **Existing Features Intact**: Regression testing passed
- [ ] **Performance Maintained**: No significant degradation
- [ ] **Security Standards Met**: No new vulnerabilities introduced
- [ ] **User Experience Smooth**: Intuitive and error-free interactions
- [ ] **Documentation Updated**: Changes reflected in docs

### ✅ Delivery Package Verification
**Required for human handoff:**
- [ ] **Working Software**: Demonstrable functionality
- [ ] **Test Evidence**: Screenshots or test results
- [ ] **Performance Metrics**: Response times, load handling
- [ ] **Known Issues**: Any limitations or future work needed
- [ ] **User Guide**: How to use the new feature

### ✅ Subagent Review Verification ⚠️ CRITICAL
**Alex MUST complete actual review using subagents (NOT paper review only):**
- [ ] **code-reviewer Called**: Code quality, standards, maintainability verified
- [ ] **ux-expert-reviewer Called**: (if UI involved) UX/UI quality assessed
- [ ] **security-auditor Called**: (if auth/data involved) Security scan completed
- [ ] **performance-optimizer Called**: (if performance sensitive) Bottlenecks analyzed
- [ ] **Subagent Feedback Documented**: All findings in acceptance report
- [ ] **Critical Issues Resolved**: Blocking issues from subagents addressed

### ✅ Knowledge Capture (MANDATORY)
**Alex must record project knowledge from review insights:**
- [ ] **Review Insights Recorded**: Patterns, anti-patterns, or architectural insights documented in `.tad/project-knowledge/`
- [ ] **Skip Criteria Checked**: If nothing project-specific learned, confirm and note "No new project knowledge"

### ⚠️ Gate Failure Conditions
- Feature incomplete → Continue implementation
- Existing features broken → Fix regressions
- Performance degraded → Optimize bottlenecks
- Security concerns → Address vulnerabilities
- UX problems → Improve user interactions
- **Subagent review skipped → BLOCKED** (must call at least code-reviewer)
- **Critical subagent feedback ignored → BLOCKED** (must address)

### 📝 Gate Completion Template
```
✅ INTEGRATION VERIFICATION GATE PASSED
Date: [timestamp]
Verified by: Agent A & Agent B

Feature Status: [✅ Working end-to-end]
Regression Tests: [✅ No existing features broken]
Performance: [✅ Maintained / Improved]
Security: [✅ No new vulnerabilities]
User Experience: [✅ Smooth and intuitive]
Documentation: [✅ Updated]

Subagent Review Results:
- code-reviewer: [✅ Passed / ⚠️ Minor issues / ❌ Blocked]
- ux-expert-reviewer: [✅/⚠️/❌ or N/A]
- security-auditor: [✅/⚠️/❌ or N/A]
- performance-optimizer: [✅/⚠️/❌ or N/A]

Critical Feedback Addressed: [✅ Yes / Items resolved]

Knowledge Capture: [✅ Review insights recorded in .tad/project-knowledge/{category}.md / ⏭️ Skipped - no new project-specific knowledge]

READY FOR DELIVERY TO HUMAN ✅
```

---

## 🚪 Gate 3R: Release Quality Gate

**Trigger:** Before executing any version release

### ✅ Pre-Release Verification Checklist
**Blake must verify:**
- [ ] **Tests Pass**: All tests green (`npm test`)
- [ ] **Build Succeeds**: Production build works (`npm run build`)
- [ ] **Lint Clean**: No linting errors (`npm run lint`)
- [ ] **CHANGELOG Updated**: Version changes documented
- [ ] **Version Bump Correct**: SemVer rules followed (patch/minor/major)
- [ ] **No Uncommitted Changes**: Working directory clean (except release updates)

### ✅ Platform Impact Assessment
**Blake must assess:**
- [ ] **Web Impact**: Changes deployed to Vercel automatically?
- [ ] **iOS Impact**: Does iOS need rebuild? (`npm run release:ios`)
- [ ] **API Contract**: Any breaking API changes? (requires major bump)
- [ ] **Database Changes**: Migration needed?

### ⚠️ Gate Failure Conditions
- Tests failing → Fix tests before release
- Build broken → Fix build errors
- CHANGELOG not updated → Document changes
- Wrong version bump → Adjust version type
- Breaking change with minor bump → Use major version

### 📝 Gate Completion Template
```
✅ RELEASE QUALITY GATE PASSED
Date: [timestamp]
Verified by: Blake (Execution Master)

Pre-Release:
- Tests: [X/Y passing]
- Build: [Success]
- Lint: [Clean]
- CHANGELOG: [Updated]

Version: [old] → [new] ([patch|minor|major])
Platform Impact:
- Web: [Auto-deploy/None]
- iOS: [Rebuild needed/None]

Approved for release ✅
```

---

## 🚪 Gate 4R: Release Verification Gate

**Trigger:** After release deployment, before marking complete

### ✅ Post-Release Verification Checklist
**Blake must verify:**
- [ ] **Web Deployment**: Vercel deployment successful
- [ ] **Production URL**: Site accessible and functional
- [ ] **Critical Paths**: Core features working (menu analysis, recommendations)
- [ ] **Version Display**: Correct version shown (if applicable)
- [ ] **Error Monitoring**: No spike in errors

### ✅ iOS-Specific Verification (if applicable)
**Blake must verify:**
- [ ] **Version Sync**: iOS version matches package.json
- [ ] **Build Success**: Xcode archive successful
- [ ] **TestFlight**: App uploaded (if releasing to App Store)

### ⚠️ Gate Failure Conditions
- Deployment failed → Check Vercel logs, retry
- Site not accessible → Rollback immediately
- Critical features broken → Rollback, fix, re-release
- Version mismatch → Run `npm run version:sync`

### 📝 Gate Completion Template
```
✅ RELEASE VERIFICATION GATE PASSED
Date: [timestamp]
Verified by: Blake (Execution Master)

Deployment:
- Web: [Verified at URL]
- iOS: [Verified/NA]

Production Health:
- Site Accessible: [Yes]
- Features Working: [Yes]
- Errors: [None/Normal levels]

Release Complete ✅
Version [X.Y.Z] successfully deployed
```

---

## 🎛️ Gate Management Guidelines

### Manual Gate Execution
1. **Copy checklist** for each gate execution
2. **Fill out each checkbox** explicitly
3. **Document evidence** for each verification
4. **Get explicit approval** before proceeding
5. **Archive completed checklists** in `.tad/working/gates/`

### Emergency Gate Override
If critical business need requires bypassing a gate:
1. **Document the business reason** for override
2. **List the risks** being accepted
3. **Create follow-up tasks** to address skipped checks
4. **Get explicit human approval** for override

### Gate Quality Metrics
Track gate effectiveness:
- **Gate pass rate**: % of first-time gate passes
- **Issue prevention**: Bugs caught at gates vs. in production
- **Cycle time**: Time between gates
- **Rework frequency**: How often gates fail

### Continuous Improvement
After each project:
- **Review gate effectiveness**: Which gates caught real issues?
- **Identify missed issues**: What got through that shouldn't have?
- **Update checklists**: Add new verification points
- **Train agents**: Share learnings from gate experiences