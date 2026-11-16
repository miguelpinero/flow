```
- [x] 0 workspace checked (branch task/flow-archive, clean, no .flow/ — onboard skipped as you asked)
- [x] 1 explore   -> .flow/runs/archive-note/brief.md
- [x] 2 plan      -> .flow/runs/archive-note/plan.md (challenged)
- [ ] GATE A: plan approved by the user   <- waiting on you
- [ ] 3 build
- [ ] 4 prove
- [ ] 5 report
- [ ] GATE B: the user reviews and commits
```

I did explore in the main thread, not in a fresh agent, because I had already read every source file. The challenger ran in its own agent. Baseline `bun test` passes (4 tests). I have changed no code.

## Plan (one slice, 4 files)

**Risky assumption:** `src/db.ts` only runs `CREATE TABLE IF NOT EXISTS`. Adding a column to that statement won't change an existing `data/notes.db`. There is no `data/` in this checkout, so I can only observe a fresh database here. I'll test the migration path with an old-schema file database.

**Changes**
- `src/db.ts`: add a nullable `archived_at TEXT` column. If `pragma table_info(notes)` lacks it, run `ALTER TABLE notes ADD COLUMN archived_at TEXT`.
- `src/app.ts`:
  - `GET /notes` adds `AND archived_at IS NULL`.
  - New route `POST /notes/:id/archive`, placed after the auth check, with regex `^/notes/(\d+)/archive$`.
  - The route runs `UPDATE notes SET archived_at = datetime('now') WHERE id = ? AND owner_id = ? AND archived_at IS NULL`. If a row changed it returns `204` with an empty body, otherwise `404`. That covers an unknown id, another user's note, and an already archived note.
- `test/notes.test.ts` (written first):
  - the 4 acceptance points;
  - the note is visible before archiving;
  - `archived_at` gets set;
  - `401` with no session;
  - a non-numeric id returns `404`;
  - `GET` on the archive path returns `404`;
  - migration of an old-schema temp-file database.
- `README.md`: add the endpoint row.

**Proof for each acceptance point:** a unit test plus a real curl request against a dev server on a free port, stopped when I finish. The ladder is `bun test`, `can-it-fail`, `prove-it`, `review`.

**Other problems found (separate tasks unless you say otherwise)**
- `GET /notes/:id` still returns an archived note.
- There is no unarchive and no way to list archived notes.

## Decisions for you
1. **Archiving an already archived note:** I recommend `404`, which is simplest and means an archived note is gone from the user's view. The alternative is `204` (idempotent). The challenger noted that the single `404` can't tell "already archived" from "missing". I think that's acceptable, but you should confirm it.
2. **`GET /notes/:id` on an archived note:** I recommend leaving it as is, since it's out of scope. The challenger points out this makes "archived = gone" inconsistent. Say so if you want it to return `404` as part of this task.

Reply **yes** to approve with my defaults (1 = `404`, 2 = leave as is), or tell me what to change.