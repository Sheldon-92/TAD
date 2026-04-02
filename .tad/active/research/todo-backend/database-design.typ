#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt, font: "New Computer Modern")
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[Database Design Document]
  #v(0.5em)
  #text(size: 12pt, fill: gray)[Todo App Backend | SQLite + Prisma ORM]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[Generated: 2026-04-01]
]

#v(1em)

= Overview

Database provider: *SQLite* (zero-infrastructure for development).

ORM: *Prisma 5.x* with `prisma-client-js` generator.

Three models: *User*, *Todo*, *Category*.

= Entity: User

#table(
  columns: (auto, auto, auto, auto, 1fr),
  table.header([*Field*], [*Type*], [*Constraint*], [*Nullable*], [*Notes*]),
  [id], [String], [PK, CUID], [No], [Auto-generated],
  [email], [String], [Unique], [No], [Login identifier],
  [name], [String], [], [No], [Display name],
  [passwordHash], [String], [], [No], [bcrypt hash, never exposed],
  [role], [String], [Default "member"], [No], [owner \| member],
  [refreshToken], [String], [], [Yes], [Hashed refresh token],
  [deletedAt], [DateTime], [], [Yes], [Soft delete timestamp],
  [createdAt], [DateTime], [Default now()], [No], [Audit],
  [updatedAt], [DateTime], [Auto], [No], [Audit],
)

*Indexes:* `email` (unique), `deletedAt`

= Entity: Todo

#table(
  columns: (auto, auto, auto, auto, 1fr),
  table.header([*Field*], [*Type*], [*Constraint*], [*Nullable*], [*Notes*]),
  [id], [String], [PK, CUID], [No], [Auto-generated],
  [title], [String], [], [No], [Max 255 chars (app validation)],
  [description], [String], [], [Yes], [Max 2000 chars (app validation)],
  [completed], [Boolean], [Default false], [No], [Completion status],
  [priority], [String], [Default "medium"], [No], [low\|medium\|high\|urgent],
  [dueDate], [DateTime], [], [Yes], [Optional deadline],
  [userId], [String], [FK -> User.id], [No], [Owner reference],
  [categoryId], [String], [FK -> Category.id], [Yes], [Optional category],
  [createdAt], [DateTime], [Default now()], [No], [Audit],
  [updatedAt], [DateTime], [Auto], [No], [Audit],
)

*Indexes:* `userId`, `categoryId`, `[userId, completed]`, `[userId, priority]`, `[userId, dueDate]`

*On Delete:* User cascade, Category SetNull

= Entity: Category

#table(
  columns: (auto, auto, auto, auto, 1fr),
  table.header([*Field*], [*Type*], [*Constraint*], [*Nullable*], [*Notes*]),
  [id], [String], [PK, CUID], [No], [Auto-generated],
  [name], [String], [Unique per user], [No], [Max 50 chars],
  [color], [String], [], [Yes], [Hex color code],
  [userId], [String], [FK -> User.id], [No], [Owner reference],
  [createdAt], [DateTime], [Default now()], [No], [Audit],
  [updatedAt], [DateTime], [Auto], [No], [Audit],
)

*Indexes:* `userId`, `@@unique([userId, name])`

*On Delete:* User cascade

= Relationships

#table(
  columns: (auto, auto, auto, auto, 1fr),
  table.header([*From*], [*To*], [*Cardinality*], [*On Delete*], [*Notes*]),
  [User], [Todo], [1:N], [Cascade], [Deleting user deletes all todos],
  [User], [Category], [1:N], [Cascade], [Deleting user deletes all categories],
  [Category], [Todo], [1:N], [SetNull], [Deleting category nullifies todo.categoryId],
)

= Index Strategy

#table(
  columns: (auto, auto, 1fr),
  table.header([*Table*], [*Index*], [*Purpose*]),
  [User], [`email` (unique)], [Login lookup],
  [User], [`deletedAt`], [Filter active users],
  [Todo], [`userId`], [List user's todos],
  [Todo], [`categoryId`], [Filter by category],
  [Todo], [`[userId, completed]`], [My completed/pending todos],
  [Todo], [`[userId, priority]`], [My todos by priority],
  [Todo], [`[userId, dueDate]`], [My upcoming todos],
  [Category], [`userId`], [List user's categories],
  [Category], [`[userId, name]` (unique)], [Prevent duplicate names per user],
)

= Design Decisions

1. *CUID over auto-increment*: Prevents ID enumeration attacks, URL-friendly, sortable.
2. *SQLite provider*: Zero-infrastructure for development. Migrate to PostgreSQL for production scale.
3. *String enums*: SQLite lacks native enum support. Validated at application layer (Zod).
4. *Soft delete on User only*: Todos/categories cascade-delete. Only users need audit trail.
5. *Compound indexes*: Cover the three most common query patterns for todo lists.

= Migration Plan

For v1 (development): `npx prisma db push` (direct schema sync to SQLite).

For production: Switch to `npx prisma migrate dev` for versioned, reversible migrations.
