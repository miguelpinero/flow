# Report: POST /notes/:id/archive

12 passed, 0 failed, 0 not-run, 0 could-not-run. Separately, lint and type check were not run because the repo has none configured, and `manual-test` and `design-check` were not run because the task didn't call for them. `bun test` after the last change: 10 pass, 0 fail.

```
- [x] 0 workspace  - [x] 1 explore  - [x] 2 plan  - [x] GATE A (approved)
- [x] 3 build      - [x] 4 prove    - [x] 5 report - [ ] GATE B: you review and commit
```

| Acceptance point | Proof | Result |
|---|---|---|
| 1. Owner archives and gets `204` | Unit test. Curl returned `204` with an empty body. | passed |
| 2. Archived note is not in `GET /notes` | Unit test. In curl the list went from [one, two] to [two]. | passed |
| 3. Other user gets `404` and the note stays listed | Unit test. In curl, bob got `404` and alice's list was unchanged. | passed |
| 4. Unknown id gets `404` | Unit tests (`9999` and `abc`). Curl with `99999` returned `404`. | passed |
| New tests can fail | `can-it-fail`: each of 6 deliberate breaks turned a test red, and the tree was restored. | passed |
| Review | 0 blocker, 0 high, 1 medium (known, deferred). | passed |

## What changed
- **`src/db.ts`:** new nullable `archived_at` column. A guarded `ALTER TABLE` adds it to databases created before this change. A test covers that path and a second open.
- **`src/app.ts`:** `GET /notes` hides archived notes. The new route is `POST /notes/:id/archive`. One `UPDATE` scoped to the owner returns `204`, or `404` for an unknown id, another user's note, or an already archived note.
- **`test/notes.test.ts`:** 6 new tests, written first and red before the implementation.
- **`README.md`:** one endpoint row.
- Nothing is committed. I started a dev server on a free port with a temporary database, and stopped it afterwards.

## Still open
- `GET /notes/:id` still returns an archived note. You approved leaving this as a separate task.
- Archiving an already archived note returns `404`, which was the default you approved.
- I did the review in the main thread rather than with parallel agents, and I did the explore stage in the main thread too. Only the plan challenger ran as a separate agent.

## Look at first
The migration block in `src/db.ts`, then the archive route at `src/app.ts:65`.

Run files are in `.flow/runs/archive-note/`: `brief.md`, `plan.md`, `checks/`, `report.md`, `pr.md`.

## Pull request description

```
Add POST /notes/:id/archive

## What and why
Owners can archive a note. `POST /notes/:id/archive` returns 204 and the note no longer appears in `GET /notes`. Another user, an unknown id, or an already archived note gets 404.

## How
- Archiving sets a nullable `archived_at` timestamp. The note is not deleted.
- One `UPDATE ... WHERE id = ? AND owner_id = ? AND archived_at IS NULL` decides the result. Not-yours and unknown look the same (404), as in `GET /notes/:id`.
- `CREATE TABLE IF NOT EXISTS` does not change an existing table, so `openDb` adds the column with `ALTER TABLE` when it is missing.

## Proof
| Check | Result |
|---|---|
| `bun test` (10 tests, 6 new) | passed |
| Each new test goes red when its behavior is broken | passed |
| Real HTTP requests on a local server (owner, other user, unknown id, no login, repeat) | passed |
| Review | passed (0 blocker, 0 high) |
| Lint / type check | not-run (none configured) |

## Not done
- `GET /notes/:id` still returns an archived note.
- No unarchive and no way to list archived notes.
```