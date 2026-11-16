Here is what I found and what I'd write. I need your answers to the preferences before I write anything.

**`.flow/profile.md`**
```
# Profile

## Facts
- Base branch: main (source: git branches, repo's main branch; no remote or CI configured)
- Runtime: Bun, TypeScript, SQLite, no dependencies (source: README, package.json)
- Package manager: none needed, no dependencies and no lock file (source: package.json)
- Install: unknown (nothing to install)
- Lint: unknown (no script or config)
- Type check: unknown (no script, no tsconfig)
- Test: `bun test` (source: package.json scripts)
- One test: `bun test test/notes.test.ts -t "<name>"` (source: bun test CLI; not run)
- Build: none
- Run: `bun run dev` (source: package.json scripts)
- Layout: src/{app,auth,db,server}.ts; tests in test/*.test.ts with test/helpers.ts (source: tree)
- Tests use an in-memory DB via `setup()` in test/helpers.ts and call the app handler directly, with no HTTP server
- Database: data/notes.db, override with NOTES_DB (source: README)
- CI: none found
- Agent/contributor rules: none found
- Glossary/domain doc: none; README lists the endpoints

## Preferences
- Commits: <your answer>
- Pull request text: <your answer>
- Start the dev server: <your answer>
- Guidance: <your answer>
- Run size: <your answer>
```

**`.flow/proof.md`**
```
# Proof

## Ladder
1. Type check and lint: unknown (none configured)
2. Unit tests: `bun test` (or one file: `bun test test/notes.test.ts`)
3. Real requests to the running server (prove-it)

## Server
- Start: `bun run dev` (source: package.json scripts)
- Address: http://localhost:3210, or set `PORT` (source: src/server.ts, README)
- Is it this branch's code? Check `GET /health` returns `{"ok":true}`, and confirm the process was started from this checkout. The health check does not identify the branch.

## Login
- Demo users alice@example.test and bob@example.test are public test accounts. Passwords are in the README and test/helpers.ts.
- `POST /login` with JSON `{email, password}` returns a token. Send it as `Authorization: Bearer <token>`.
```

I also add `.flow/local/` and `.flow/runs/` to `.gitignore`. Both are already listed there.

**Preferences** (recommended answer first):
1. Commits: `never` / `ask` / `auto`
2. Pull request text: `ask` / `always` / `never`
3. May flow start and stop the dev server: `no` / `yes, on a free port`
4. Guidance level: `short` / `full`
5. Run size: `standard` / `light` / `full`

Two things to settle too:
- There's no lint or type check. Should I leave them as `unknown`, or do you want one added later?
- I assumed `main` is the base branch since there's no remote. Is that right?

Reply with your answers, or "defaults", and I'll write the files.