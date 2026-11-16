## Review: change/archive-cross-user (base main)
`failed`. 1 blocker, 0 high, 1 medium, 0 low.
Lenses run: Correctness, Access and data, Tests, Fit. Lenses not run: Purpose, because there is no plan.

No plan found. I did not check the change against its purpose. I also found no `.flow/house-rules.md`, so I applied no house rules.

### Findings
1. [blocker] `src/app.ts:73-79`. Any logged-in user can archive another user's note. The archive handler loads the note by id and never compares `row.owner_id` with `user.id`. It then runs the `UPDATE` and returns 204. Example: Bob sends `POST /notes/<alice's id>/archive`. He gets 204, and the note disappears from Alice's `GET /notes`. This breaks acceptance point 3, which requires 404 and the note staying in the owner's list. The sibling `GET /notes/:id` handler at `src/app.ts:66-71` has the check `row.owner_id !== user.id` and returns 404.
   Fix: change the not-found line to `if (!row || row.owner_id !== user.id) return json({ error: "not found" }, 404);`. Alternatively, run `UPDATE notes SET archived = 1 WHERE id = ? AND owner_id = ?` and return 404 when no row changed.
   I confirmed this by reading the code. I did not run a cross-user request.

2. [medium] `test/archive.test.ts`. No test covers the cross-user case (acceptance point 3), so the blocker above passes the suite. I ran `bun test` and got 7 pass, 0 fail, with the hole still present. Fix: add a test where Bob archives Alice's note. It should expect 404, and the note should still be in Alice's `GET /notes`. This test would fail against the current code.

### Not confirmed
- Nothing.

### Not checked
- Purpose lens: there is no plan file.
- House rules: there is no `.flow/house-rules.md`.
- I did not start the dev server. The review reads code, and I ran only `bun test`.

### Other observations
- The `archived` column migration in `src/db.ts` checks `PRAGMA table_info` before the `ALTER`, so reopening an existing database is safe. The test for old databases covers it.
- Acceptance points 1, 2 and 4 are covered by tests that pass. These are code and test observations, not a proof table.