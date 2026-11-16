## Review: change/archive-cross-user (vs main)

`failed`. 1 blocker, 0 high, 1 medium, 0 low.
Lenses run: Correctness, Access and data, Tests, Fit. Lenses not run: Purpose, because no plan was found. The branch has one commit and no `.flow/` folder.

### Findings

1. **[blocker]** `src/app.ts:75-77`. Any logged-in user can archive any note. The archive handler loads the note by id only and never compares `owner_id` with the session user. Reproduced with `bun -e` against the in-memory test setup (no edits made): Bob archives a note that Alice created, gets `204`, and Alice's `GET /notes` then returns `[]`. This fails acceptance point 3, which requires `404` and the note to stay in the owner's list.
   Fix: scope the lookup to the caller, as the `GET /notes/:id` handler on line 68-69 already does. Use `SELECT * FROM notes WHERE id = ? AND owner_id = ?` with `user.id`, or check `row.owner_id !== user.id` and return `404`.

2. **[medium]** `test/archive.test.ts:1-36`. No test covers a second user. The three tests check the owner's happy path, an unknown id, and the migration. Finding 1 passes all of them. The suite (`bun test`, 7 pass) therefore does not prove acceptance point 3.
   Fix: add a test where Bob (`setup()` returns `bob`) posts to Alice's note, expects `404`, and then expects Alice's `GET /notes` to still contain the note. Run it against the current code first to confirm it fails.

### Not confirmed
- None.

### Not checked
- **Purpose:** no plan found at `.flow/runs/<id>/plan.md`, so I did not check the change against its purpose.
- **House rules:** no `.flow/house-rules.md` found, so I applied only general fit checks.
- **HTTP level:** the reproduction called the handler directly through the test helper, not over a running server. The code path is the same.
- **Behavior of archived notes on `GET /notes/:id`:** they still return with `archived: true`. This is not in the acceptance points, so I did not count it as a defect. Confirm that this is intended.