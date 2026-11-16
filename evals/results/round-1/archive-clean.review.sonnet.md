## Review: change/archive-clean (vs main)
`failed`. 1 blocker, 0 high, 2 medium, 1 low.
Lenses run: Correctness, Access and data, Tests, Fit. Lenses not run: Purpose. There is no `.flow/runs/<id>/plan.md`, so the change was not checked against its purpose. I reviewed the diff myself in one pass instead of using subagents.

No plan found. I did not check the change against its purpose. I used the task's four acceptance points as the reference.

### Findings
1. [blocker] `src/db.ts:29`. The `archived` column exists only in `CREATE TABLE IF NOT EXISTS`, so a database file created before this change never gets it. After deploy, every `GET /notes` and archive request on an existing `data/notes.db` fails with a 500. I reproduced this: I opened a database with the old `notes` table through `openDb`, ran the new list query, and got `SQLiteError: no such column: archived`. `POST /notes` is unaffected, but `GET /notes` is broken for everyone.
   Fix: after the CREATE statements, check `PRAGMA table_info(notes)`. If `archived` is missing, run `ALTER TABLE notes ADD COLUMN archived INTEGER NOT NULL DEFAULT 0`. Add a test that opens an old-schema database.
2. [medium] `src/app.ts:66`. `GET /notes/:id` still returns an archived note, with `archived: true`. The task does not say whether it should. Archived notes are hidden from the list but can still be fetched by id.
   Fix: confirm the intent. If archived notes should be gone, return 404 here; if not, document it in the README.
3. [medium] `test/archive.test.ts`. The tests cover all four acceptance points. Two cases are missing: archiving the same note twice (the current code returns 204 again) and the old-schema migration from finding 1. The "other user" test checks the note stays in Alice's list, but nothing proves it stays un-archived, because the list check is the only assertion.
   Fix: add a double-archive test and a migration test.
4. [low] `src/app.ts:74`. The archive route is registered after the `/notes/:id` route and uses a separate regex. This works and follows the existing style. No change is needed.

### Access and data
Archiving checks ownership. A note that belongs to another user and an unknown id both return the same 404, so the response does not reveal whether the note exists. The list query is still scoped to `owner_id`. I found no access hole.

### Proof table
| Acceptance point | Proof | Result |
|---|---|---|
| Owner archives and gets 204 | `bun test` ran 7 tests, all passed, including "archives a note and removes it from the list" | `passed` |
| Archived note is absent from `GET /notes` | Same test asserts `list.items` equals `[]` | `passed` |
| Another user gets 404 and the note stays listed | Test "does not let another user archive the note", in the same `bun test` run (7 pass, 0 fail) | `passed` |
| Unknown id returns 404 | Test "returns 404 for an unknown note", in the same run | `passed` |
| Works on an existing database | Old-schema database queried through `openDb` failed with `no such column: archived` | `failed` |

### Not confirmed
- I did not run the new tests with the code broken, so I have not seen them fail. I did not use `can-it-fail`.
- I did not start the dev server or send real HTTP requests. The proof comes from the test suite and one script I ran against `openDb`.

### Not checked
- Purpose lens: there is no plan file.
- House rules: there is no `.flow/house-rules.md`, and the repo has no `.flow` folder.