#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt, font: "New Computer Modern")
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[Todo App API Documentation]
  #v(0.5em)
  #text(size: 12pt, fill: gray)[Version 1.0.0 | OpenAPI 3.1]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[Generated: 2026-04-01]
]

#v(1em)

= Getting Started

== Base URL
- Development: `http://localhost:3000/v1`
- Staging: `https://staging-api.todoapp.example.com/v1`
- Production: `https://api.todoapp.example.com/v1`

== Authentication
All endpoints (except registration, login, and token refresh) require a JWT Bearer token:

```
Authorization: Bearer {accessToken}
```

Access tokens expire after 15 minutes. Use `POST /auth/refresh` to obtain a new one.

== Error Format (RFC 7807)
All errors follow RFC 7807 Problem Details:
```json
{
  "type": "https://todoapp.example.com/errors/{error-type}",
  "title": "Short Title",
  "status": 400,
  "detail": "Human-readable explanation.",
  "errors": [{"field": "email", "message": "...", "code": "..."}]
}
```

= Auth Endpoints

#table(
  columns: (auto, auto, 1fr, auto),
  align: (left, left, left, center),
  table.header([*Method*], [*Endpoint*], [*Description*], [*Auth*]),
  [POST], [`/auth/register`], [Register new user, returns tokens], [No],
  [POST], [`/auth/login`], [Login with email/password, returns tokens], [No],
  [POST], [`/auth/refresh`], [Refresh access token using refresh token], [No],
  [POST], [`/auth/logout`], [Invalidate refresh token], [Yes],
)

#v(0.5em)
*Register Request:* `{ email, password (min 8, mixed case + number), name }`

*Auth Response:* `{ accessToken, refreshToken, expiresIn: 900, user: { id, email, name, role } }`

= User Endpoints

#table(
  columns: (auto, auto, 1fr, auto),
  align: (left, left, left, center),
  table.header([*Method*], [*Endpoint*], [*Description*], [*Role*]),
  [GET], [`/users/me`], [Get current user profile], [Any],
  [PATCH], [`/users/me`], [Update name or password], [Any],
  [GET], [`/users`], [List all users (paginated)], [Owner],
  [GET], [`/users/{userId}`], [Get user by ID], [Owner],
  [DELETE], [`/users/{userId}`], [Soft-delete user], [Owner],
)

= Todo Endpoints

#table(
  columns: (auto, auto, 1fr, auto),
  align: (left, left, left, center),
  table.header([*Method*], [*Endpoint*], [*Description*], [*Scope*]),
  [GET], [`/todos`], [List todos (filtered, paginated)], [Own / All],
  [POST], [`/todos`], [Create todo], [Own],
  [GET], [`/todos/{todoId}`], [Get todo by ID], [Own / Any],
  [PATCH], [`/todos/{todoId}`], [Update todo], [Own / Any],
  [DELETE], [`/todos/{todoId}`], [Delete todo], [Own / Any],
)

#v(0.5em)
*Query Filters:* `status`, `categoryId`, `priority`, `dueBefore`, `dueAfter`, `search`, `sort`, `order`

*Pagination:* `page` (default 1), `pageSize` (default 20, max 100)

*Response:* `{ data: Todo[], meta: { total, page, pageSize, totalPages } }`

= Category Endpoints

#table(
  columns: (auto, auto, 1fr, auto),
  align: (left, left, left, center),
  table.header([*Method*], [*Endpoint*], [*Description*], [*Scope*]),
  [GET], [`/categories`], [List user's categories], [Own],
  [POST], [`/categories`], [Create category], [Own],
  [GET], [`/categories/{categoryId}`], [Get category by ID], [Own],
  [PATCH], [`/categories/{categoryId}`], [Update category], [Own],
  [DELETE], [`/categories/{categoryId}`], [Delete category (todos nullified)], [Own],
)

= Data Schemas

== Todo
#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*Field*], [*Type*], [*Required*], [*Notes*]),
  [id], [string], [auto], [CUID, auto-generated],
  [title], [string], [yes], [1-255 chars],
  [description], [string\|null], [no], [max 2000 chars],
  [completed], [boolean], [no], [default: false],
  [priority], [enum], [no], [low\|medium\|high\|urgent, default: medium],
  [dueDate], [datetime\|null], [no], [ISO 8601],
  [categoryId], [string\|null], [no], [must belong to user],
  [userId], [string], [auto], [set to authenticated user],
  [createdAt], [datetime], [auto], [],
  [updatedAt], [datetime], [auto], [],
)

== User
#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*Field*], [*Type*], [*Required*], [*Notes*]),
  [id], [string], [auto], [CUID],
  [email], [string], [yes], [unique, valid email format],
  [name], [string], [yes], [1-100 chars],
  [role], [enum], [auto], [owner\|member],
  [createdAt], [datetime], [auto], [],
  [updatedAt], [datetime], [auto], [],
)

== Category
#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*Field*], [*Type*], [*Required*], [*Notes*]),
  [id], [string], [auto], [CUID],
  [name], [string], [yes], [1-50 chars, unique per user],
  [color], [string\|null], [no], [hex code e.g. \#FF6B6B],
  [userId], [string], [auto], [set to authenticated user],
  [createdAt], [datetime], [auto], [],
  [updatedAt], [datetime], [auto], [],
)
