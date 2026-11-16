## Prove it: change/archive-cross-user (vs main)
Final run: 6 passed, 0 failed, 0 not-run, 0 could-not-run. The first run found 1 failure, and I fixed it (see Failures).

### Impact
- `src/app.ts` (new archive handler) -> `POST /notes/:id/archive` -> an ownership leak, and a wrong status for unknown or non-numeric ids.
- `src/app.ts` (list query now filters `archived = 0`) -> `GET /notes` -> archived notes hidden.
- `src/app.ts` (`toNote` now returns `archived`) -> `GET /notes`, `POST /notes`, `GET /notes/:id` -> response shape gains one field.
- `src/db.ts` (new `archived` column) -> every notes query. The column is added only through `CREATE TABLE IF NOT EXISTS`, so an existing `data/notes.db` would not get it. I tested a fresh DB only.

### Results
These come from the second run, after the fix. The server was freshly started on port 34872 with a temp DB, as alice and bob. The first run, on the unfixed branch code, is under Failures.

| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Owner archives (AP1) | alice `POST /notes/1/archive` | 204 | 204 | `passed` |
| 2 | Archived note leaves the list (AP2) | alice `GET /notes` | only note 2 | `items` held only note 2 | `passed` |
| 3 | Other user cannot archive (AP3) | bob `POST /notes/2/archive` | 404, note 2 stays listed | 404. Alice's list still had note 2 with `archived:false`. | `passed` |
| 4 | Unknown id (AP4) | alice `POST /notes/99999/archive` | 404 | 404 | `passed` |
| 5 | No login | `POST /notes/2/archive` | 401 | 401 | `passed` |
| 6 | Archived note by id | alice `GET /notes/1` | 200 with `archived:true` | 200 with `archived:true` | `passed` |

Also seen, not counted as a pass or fail:
- Re-archiving an already archived note returns 204.
- A non-numeric id (`/notes/abc/archive`) returns 404.

### Failures
- **Case 3 on the branch as committed:** I expected 404, and bob's `POST /notes/2/archive` returned 204 instead. Alice's note then disappeared from her list.
  - Likely cause: the archive handler only checked `!row` and never compared `row.owner_id` to the caller. `GET /notes/:id` already has that check.
  - Fix: I changed the check to `!row || row.owner_id !== user.id` (`src/app.ts`) and restarted the server so it ran the new code. Case 3 passed on the rerun.
  - The fix is uncommitted.
- The existing tests did not catch this. `test/archive.test.ts` only had the owner and unknown-id cases.

### Purpose
Met. All four acceptance points have a real HTTP request with the response and saved state checked, as shown above.

### Also seen (not counted)
- `bun test`: 7 pass, 0 fail. I added a cross-user test to `test/archive.test.ts`. I did not run `can-it-fail` on it, but the pre-fix HTTP run showed the same behaviour it asserts: 204 and a missing note.
- Both servers I started are stopped, and nothing is left on the port. The temp DB and script were in `/tmp/pi`, and I deleted that folder. I seeded no rows outside it.
- Uncommitted changes: `src/app.ts` and `test/archive.test.ts`.