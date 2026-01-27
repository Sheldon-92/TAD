---
name: "API Design"
id: "api-design"
version: "1.0"
claude_subagent: "api-designer"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# API Design Skill

## Purpose
Review API endpoints for RESTful design, consistency, usability, documentation, and developer experience.

## When to Use
- During Gate 2 (design review)
- When creating new API endpoints
- For API refactoring
- For GraphQL schema design
- For API versioning decisions

## Checklist

### Critical (P0) - Must Pass
- [ ] Consistent naming conventions (kebab-case, plural resources)
- [ ] Appropriate HTTP methods (GET, POST, PUT, DELETE, PATCH)
- [ ] Meaningful HTTP status codes
- [ ] Error responses follow standard format
- [ ] Authentication/authorization documented

### Important (P1) - Should Pass
- [ ] Request/response schemas documented
- [ ] Pagination implemented for list endpoints
- [ ] Filtering/sorting supported where useful
- [ ] Rate limiting documented
- [ ] Versioning strategy clear

### Nice-to-have (P2) - Informational
- [ ] OpenAPI/Swagger specification
- [ ] Example requests/responses provided
- [ ] SDK/client library considerations
- [ ] Webhooks for event notifications
- [ ] HATEOAS links where applicable

### Suggestions (P3) - Optional
- [ ] GraphQL alternative considered
- [ ] Batch operations for efficiency
- [ ] Caching headers documented
- [ ] Deprecation strategy planned

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max 2 failures |
| P2 | Informational |
| P3 | Optional |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-api-design-{task}.md`

## Execution Contract
- **Input**: file_paths[], api_spec{}, context{}
- **Output**: {passed: bool, findings: [{severity, endpoint, method, description, recommendation}], evidence_path: string}
- **Timeout**: 180s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `api-designer` for deeper analysis.
Reference: `.tad/templates/output-formats/api-review-format.md`

## API Design Categories

### REST Conventions
- Resource naming (nouns, plural)
- HTTP method semantics
- URL structure hierarchy
- Query parameters vs path params
- Request body conventions

### Response Design
- Status code accuracy
- Error response structure
- Envelope vs direct response
- Pagination metadata
- HATEOAS links

### Security
- Authentication methods
- Authorization scopes
- Input validation
- Rate limiting
- CORS configuration

### Documentation
- OpenAPI specification
- Example requests
- Error code reference
- Change log
- Migration guides

### Developer Experience
- Consistent patterns
- Predictable behavior
- Clear error messages
- SDK-friendly design
- Testing support
