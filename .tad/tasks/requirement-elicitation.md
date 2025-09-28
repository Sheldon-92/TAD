# Requirement Elicitation Task (需求挖掘任务)

## ⚠️ CRITICAL EXECUTION NOTICE ⚠️

**THIS IS AN EXECUTABLE WORKFLOW - NOT REFERENCE MATERIAL**

When this task is invoked:

1. **DISABLE ALL EFFICIENCY OPTIMIZATIONS** - This workflow requires full user interaction
2. **MANDATORY 3-5 ROUNDS** - Must complete AT LEAST 3 rounds of confirmation
3. **ELICITATION IS REQUIRED** - When `elicit: true`, you MUST use the 0-9 format and wait for user response
4. **NO SHORTCUTS ALLOWED** - Cannot proceed without user confirmation at each round

**VIOLATION INDICATOR:** If you proceed with less than 3 rounds of confirmation, you have violated this workflow.

## Purpose

Deep understanding of user requirements through structured, iterative elicitation. This is Agent A's primary tool for ensuring complete requirement understanding before design.

## Mandatory Process

### Round 1: Initial Understanding (MANDATORY)

**YOU MUST:**

1. Listen to user's initial requirement
2. Rephrase in your own words
3. Identify key value propositions
4. List initial assumptions

**Present to user:**
```
Based on what you've told me, I understand that:
[Your rephrasing]

Key value propositions I've identified:
1. [Value 1]
2. [Value 2]
3. [Value 3]

My initial assumptions:
- [Assumption 1]
- [Assumption 2]

Please select an option (0-8) or 9 to continue:
0. Expand on requirements
1. Clarify specific details
2. Provide more context
3. Correct my understanding
4. Add constraints or limitations
5. Define priorities
6. Give examples
7. Discuss alternatives
8. Explore edge cases
9. Continue to next round

Select 0-9:
```

**WAIT FOR USER RESPONSE** - Do not proceed until user selects option or provides feedback

### Round 2: Deep Exploration (MANDATORY)

**Based on Round 1 feedback, YOU MUST:**

1. Incorporate all corrections and additions
2. Check for existing/historical solutions
3. Identify technical constraints
4. Explore non-functional requirements

**Present to user:**
```
Updated understanding after your feedback:
[Refined requirements]

Critical questions to explore:
1. Have you implemented something similar before?
2. Are there existing components we can reuse?
3. What are the performance expectations?
4. What are the security requirements?
5. Who are the end users?

[[LLM: You MUST ask these questions and wait for answers]]

Please select an option (0-8) or 9 to continue:
0. Discuss scalability needs
1. Define user personas
2. Explore integration requirements
3. Identify dependencies
4. Discuss error handling
5. Define success metrics
6. Consider future extensions
7. Review technical constraints
8. Analyze risks
9. Continue to next round

Select 0-9:
```

### Round 3: Validation and Confirmation (MANDATORY)

**Present complete requirement understanding:**

```
## Complete Requirement Understanding

### Functional Requirements:
1. [Requirement 1]
2. [Requirement 2]
...

### Non-Functional Requirements:
1. [NFR 1]
2. [NFR 2]
...

### Constraints:
- [Constraint 1]
- [Constraint 2]

### Success Criteria:
- [Criterion 1]
- [Criterion 2]

### Risks and Mitigation:
- [Risk 1]: [Mitigation]
- [Risk 2]: [Mitigation]

Please select an option (0-8) or 9 to finalize:
0. Adjust functional requirements
1. Modify non-functional requirements
2. Add missing requirements
3. Change priorities
4. Revise success criteria
5. Add acceptance criteria
6. Include additional stakeholders
7. Define timeline constraints
8. Request another round of refinement
9. Confirm and finalize requirements

Select 0-9:
```

### Rounds 4-5: Additional Refinement (OPTIONAL but RECOMMENDED)

If user selects option 8 in Round 3, or if significant changes were made, continue with:

**Round 4: Edge Cases and Exceptions**
- Explore boundary conditions
- Identify exception scenarios
- Define fallback behaviors

**Round 5: Final Polish**
- Last chance for adjustments
- Confirm all stakeholder needs met
- Verify completeness

## Output Document

After minimum 3 rounds (or when user confirms), create:

**File:** `.tad/docs/requirements/requirements_[timestamp].md`

```markdown
# Requirements Document
Version: 1.0
Date: [Date]
Rounds of Elicitation: [Number]
Status: Confirmed

## Executive Summary
[Brief overview]

## Functional Requirements
[Detailed list with IDs: FR1, FR2, etc.]

## Non-Functional Requirements
[Detailed list with IDs: NFR1, NFR2, etc.]

## User Personas
[Identified users and their needs]

## Success Criteria
[Measurable success indicators]

## Constraints and Assumptions
[Technical and business constraints]

## Risks and Mitigation
[Identified risks with mitigation strategies]

## Traceability
- Elicitation Rounds: [Number]
- Key Decisions: [List]
- Deferred Items: [List]

## Sign-off
- Confirmed by: Human (Value Guardian)
- Date: [Date]
- Ready for: Design Phase
```

## CRITICAL REMINDERS

**❌ NEVER:**
- Skip rounds (minimum 3 required)
- Assume understanding without confirmation
- Use yes/no questions
- Proceed without numbered options
- Create design before requirements confirmed

**✅ ALWAYS:**
- Complete minimum 3 rounds
- Use 0-9 numbered options
- Wait for user selection
- Document all decisions
- Create formal requirements document

## Violation Handling

If you attempt to skip rounds or proceed too quickly:
```
⚠️ VIOLATION DETECTED ⚠️
Type: Insufficient Elicitation
Required: Minimum 3 rounds
Completed: [X] rounds
Action: Returning to Round [X+1]
```

[[LLM: This task is MANDATORY for Agent A before any design work can begin. The 3-round minimum is NOT negotiable unless user explicitly requests YOLO mode.]]