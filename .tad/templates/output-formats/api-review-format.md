# API Review Output Format

> Extracted from api-design skill - use this checklist and format for API design reviews

## Quick Checklist

```
1. [ ] Resources use nouns (plural), not verbs
2. [ ] HTTP methods match operations (GET=read, POST=create, PUT=replace, PATCH=update, DELETE=remove)
3. [ ] Status codes correct + RFC 7807 error format
4. [ ] Version strategy defined (URL path `/v1/` recommended)
5. [ ] Idempotency-Key for non-idempotent operations
6. [ ] Pagination for lists (> 50 items)
```

## Red Flags

- `/getUsers` instead of `/users`
- Using POST for everything
- Returning 200 for errors
- No pagination for lists
- Missing `Idempotency-Key` on payment APIs
- No deprecation policy

## Output Format

### API Endpoint Specification

| Endpoint | Method | Request Body | Response | Status Codes |
|----------|--------|--------------|----------|--------------|
| /users | GET | - | User[] | 200, 401 |
| /users/:id | GET | - | User | 200, 404 |
| /users | POST | CreateUser | User | 201, 400, 409 |
| /users/:id | PATCH | UpdateUser | User | 200, 400, 404 |
| /users/:id | DELETE | - | - | 204, 404 |

### Error Response Format (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "Email format is invalid",
  "instance": "/users/123"
}
```

### Version Strategy

- URL Path versioning: `/v1/users`, `/v2/users`
- Breaking changes only in major versions
- Deprecation notice: 6 months minimum
