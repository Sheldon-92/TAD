# Knowledge Bootstrap Template

> Use this template during project initialization (`/tad-init`) to establish foundational knowledge.

## Purpose

Capture **foundational knowledge** that should exist BEFORE development begins. This is different from **accumulated learnings** which are discovered during development.

## How to Use

1. Alex runs this during `/tad-init` or when bootstrapping knowledge for existing projects
2. For each category, answer the questions to populate the "Foundational" section
3. Skip sections that don't apply (mark as N/A)
4. This only needs to be done once per project

---

## UX Knowledge Bootstrap

### Questions to Answer:

1. **Design Philosophy**: What visual style is the project using? (e.g., Material Design, custom style)
2. **Color System**: What are the primary colors? (background, foreground, accent, etc.)
3. **Typography**: What fonts are used? For what purposes?
4. **Component Library**: What UI library? (shadcn/ui, MUI, custom)
5. **Spacing System**: What spacing scale? (Tailwind default, custom)
6. **Accessibility**: Any specific requirements? (WCAG level, motion preferences)

### Where to Find Answers:

- `tailwind.config.ts` or `tailwind.config.js`
- `app/globals.css` or `styles/globals.css`
- `app/layout.tsx` (fonts)
- `components/ui/` folder (component library)

---

## Code Quality Bootstrap

### Questions to Answer:

1. **Tech Stack**: What framework, language, styling, state management?
2. **File Organization**: How is `src/` structured?
3. **Naming Conventions**: Components, hooks, utilities, constants?
4. **Import Order**: What order for imports?
5. **Error Handling**: What pattern for errors?

### Where to Find Answers:

- `package.json` (dependencies)
- `tsconfig.json` (TypeScript config)
- `src/` directory structure
- Existing code patterns

---

## Testing Bootstrap

### Questions to Answer:

1. **Testing Stack**: What test runner? (Jest, Vitest, etc.)
2. **Test Structure**: Describe/it pattern? Arrange-Act-Assert?
3. **File Naming**: Where do tests go? What naming?
4. **Coverage Targets**: What coverage is expected?
5. **Running Tests**: What commands?

### Where to Find Answers:

- `package.json` scripts
- `vitest.config.ts` or `jest.config.js`
- Existing test files

---

## Architecture Bootstrap

### Questions to Answer:

1. **Data Flow**: How does data flow through the app?
2. **API Design**: REST, GraphQL, RPC?
3. **State Management**: Local state, Context, external store?
4. **Key Decisions**: Any major architectural decisions already made?

### Where to Find Answers:

- `src/app/api/` (API routes)
- `src/contexts/` (state management)
- `src/lib/` (business logic)

---

## Security Bootstrap

### Questions to Answer:

1. **Authentication**: How are users authenticated?
2. **Authorization**: How are permissions managed?
3. **Data Protection**: Any sensitive data handling?
4. **Known Risks**: Any security concerns to track?

### Where to Find Answers:

- Auth-related files
- Database schema (RLS policies)
- Environment variables usage

---

## Output Format

After answering questions, write the "Foundational" section in each knowledge file:

```markdown
## Foundational: [Category Name]

> Established at project inception. Reference for all [type] development.

### [Subsection]
[Content from answered questions]
```

Keep it concise but complete enough for a new developer (or AI) to understand the project standards.
