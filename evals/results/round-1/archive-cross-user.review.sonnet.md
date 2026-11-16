## Review: change/archive-cross-user (base: main)
failed. 1 blocker, 0 high, 2 medium, 0 low.
Lenses run: Correctness, Access and data, Tests, Fit. Lenses not run: Purpose. There is no `.flow/runs/<id>/plan.md`, so I did not check the change against its purpose.
No `.flow/house-rules.md` exists, so I applied no house rules.

Result counts: 1 failed, 1 passed, 0 not-run, 0 could-not-run.

### Findings
1. [blocker] `src/app.ts:73-79`. Any logged-in user can archive another user's note. The handler loads the note by id and never compares `row.owner_id` to `user.id`. `GET /notes/:id` at line 68 does make that comparison.
   - I reproduced it with a scratch test outside the repo. Alice created a note, and Bob called `POST /notes/<id>/archive`. It returned `204`, and Alice's `GET /notes` returned `{"items":[]}`.
   - This breaks acceptance point 3, which requires `404` and the note staying in the owner's list.
   - Fix: change the guard to `if (!row || row.owner_id !== user.id) return json({ error: "not found" }, 404);`.
2. [medium] `test/archive.test.ts`. There is no test for the cross-user case, so nothing catches finding 1. The `bun test` suite passes (6 pass, 0 fail) while the hole exists.
   - Fix: add a test where Bob archives Alice's note. Expect `404`, and expect the note still in Alice's `GET /notes`.
3. [medium] `src/db.ts:29`. The `archived` column is only in `CREATE TABLE IF NOT EXISTS`, so an existing `data/notes.db` never gets it. The first `GET /notes` or archive call against an old database would fail with "no such column: archived".
   - Fix: add a guarded `ALTER TABLE notes ADD COLUMN archived INTEGER NOT NULL DEFAULT 0` when the column is missing (check with `PRAGMA table_info(notes)`). Alternatively, document that the database must be recreated.
   - I did not run this against an old database. It follows from reading the schema code.

### Not confirmed
- `GET /notes/:id` still returns archived notes, with `archived: true` in the body. The task doesn't say whether it should, so I left it out of the findings.

### Proof table
| Acceptance point | Proof | Result |
|---|---|---|
| Owner archives a note and gets 204 | `test/archive.test.ts` "archives a note and removes it from the list" passes in `bun test`. | `passed` |
| Archived note is gone from `GET /notes` | The same test checks that `items` is empty. | `passed` |
| Another user gets 404 and the note stays listed | Scratch test: Bob's archive returned `204`, and Alice's list came back empty. | `failed` |
| Unknown id returns 404 | `test/archive.test.ts` "returns 404 for an unknown note" passes. | `passed` |

Corrected counts for the table: 3 passed, 1 failed.

I didn't start the dev server, so I stopped nothing. I didn't edit anything in the repo. The scratch test is in `/tmp/rv`, outside it.