The drafts are ready for review. `.gitignore` already excludes `.flow/local/` and `.flow/runs/`. No files have changed.

Proposed `.flow/profile.md`:

```markdown
# Profile

## Facts
- Base branch: unknown. Local main exists, but no remote or CI establishes the default.
- Runtime: Bun and TypeScript; SQLite via bun:sqlite (sources: README.md, src/db.ts).
- Runtime version: not pinned; locally installed Bun is 1.4.0.
- Package manager: Bun implied by README.md; no lockfile or dependencies.
- Install command: unknown; none documented.
- Test: `bun test` (source: package.json).
- One test: `bun test test/notes.test.ts -t "rejects a request with no session"`
  (checked: 1 pass, 0 fail, 3 filtered out).
- Lint, type check, build: unknown; no scripts or configuration found.
- Run: `bun run dev` (source: package.json).
- Address: http://localhost:3210; override with PORT (source: src/server.ts).
- Layout: src/ contains app, server, authentication, and database code;
  test/ contains endpoint tests and helpers.
- Database: data/notes.db; override with NOTES_DB (source: src/db.ts).
- Login: seeded demo accounts documented in README.md; POST /login
  returns a token for Authorization: Bearer <token>.
- Domain documentation: README.md endpoint table; no separate glossary found.
- Contributor rules: no repository AGENTS.md or contributor guide found.
  Workflow skills live in .agents/skills/.

## Preferences
- Commits: never
- Pull request text: ask
- Start the dev server: no
- Guidance: short
- Run size: standard
```

Proposed `.flow/proof.md`:

```markdown
# Proof

## Ladder
1. Run the relevant test:
   `bun test test/notes.test.ts -t "<name>"`
2. Run the full suite: `bun test`.
3. For backend changes, use prove-it against the running local server:
   check response bodies and saved state, including authentication,
   validation, and isolation between users where relevant.

Lint, type check, and build commands are unknown; none are configured.
Existing tests call the app handler with an in-memory database.
They do not prove that the HTTP server starts or accepts connections.

## Server
- Start: `bun run dev` (source: package.json).
- Address: http://localhost:3210; PORT overrides the port
  (source: src/server.ts).
- Database: NOTES_DB overrides data/notes.db (source: src/db.ts).
- Start or stop the server only according to profile.md preferences.
- Branch verification: verify the process was launched from the intended
  checkout and record its commit and working-tree state.
  GET /health returns {"ok":true}, but does not identify the branch.

## Login
- Database initialization seeds demo accounts (source: src/db.ts).
- Use credentials from README.md without copying them into flow files.
- POST /login with JSON email and password; use the returned token as
  Authorization: Bearer <token> (sources: README.md, src/auth.ts).
- Use the second demo account for ownership-isolation checks.
- Test helpers create sessions directly against an in-memory database;
  real HTTP checks must exercise POST /login (source: test/helpers.ts).
```

Please confirm **yes to write these drafts**, or give changes, including:

- Preferences: recommended **never / ask / no / short / standard**. Alternatives are commits `ask|auto`, PR text `always|never`, server `yes, on a free port`, guidance `full`, run size `light|full`.
- Base branch: should this be `main`?
- Unknown commands: supply any install, lint, type-check, or build commands, or leave them `unknown`.

This confirmation is required by the invoked [onboard skill](.agents/skills/onboard/SKILL.md): “Print both files in the conversation. Write them after the user says yes.”