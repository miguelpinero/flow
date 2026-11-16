## Review: change/archive-clean (against main)

`passed`. 0 blocker, 0 high, 0 medium, 2 low.
Lenses run: Correctness, Access and data, Tests, Fit. Lenses not run: Purpose. There is no `.flow/runs/<id>/plan.md`, so I did not compare the change with a plan.

Proof for the result: `bun test` in the repo returned `8 pass, 0 fail, 12 expect() calls`. This covers the existing `test/notes.test.ts` and the four new cases in `test/archive.test.ts`. These are in-process handler tests, not HTTP calls to a running server. I did not start the dev server.

### Findings
1. [low] `test/archive.test.ts:33`. The migration test removes its temp database with `rmSync(path)` after the assertions, with no `try/finally`. If an assertion fails, the file stays in the temp directory. Fix: wrap the body in `try { … } finally { rmSync(path, { force: true }) }`.
2. [low] `src/app.ts:12`. `toNote` now adds an `archived` boolean to every note response. The task does not ask for it, and the README does not document it. It is an additive API change that nobody requested. Fix: drop the field from `toNote` unless a client needs it, and if one does, document it in the README.

### Checked and fine
- The archive handler returns the same `404` body for an unknown id and for another user's note. It does not reveal whether the id exists.
- The owner check runs before the `UPDATE`, so a non-owner cannot change the row.
- `GET /notes` filters with `archived = 0`.
- The `ALTER TABLE` migration in `src/db.ts` lets an existing `data/notes.db` work with the new code. The column defaults to 0, and the old code still runs against the migrated schema, since its inserts name their columns.
- The ownership test would fail if the owner check were removed, because Bob's archive would empty Alice's list.

### Not confirmed
- `GET /notes/:id` still returns an archived note to its owner. The task does not say whether it should. I did not treat this as a defect.

### Not checked
- Purpose lens: no plan at `.flow/runs/<id>/plan.md`.
- House rules: no `.flow/house-rules.md` exists in the repo, so I applied no team rules.
- Live HTTP behavior: I did not start the server, so the 204 and 404 responses were checked only through the handler tests.