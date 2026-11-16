## Prove it: change/archive-clean (base main)
8 passed, 0 failed, 0 not-run, 0 could-not-run

I ran the server from this branch on port 3457 with a throwaway DB (`NOTES_DB=/tmp/pi-db/p.db`). I logged in as alice and bob with the README demo accounts. I seeded two notes for alice, ids 1 and 2. The server is stopped and the temp DB is removed.

### Impact
- `src/db.ts` (new `archived` column) -> every notes query -> an existing `data/notes.db` would lack the column, because `CREATE TABLE IF NOT EXISTS` doesn't migrate it.
- `src/app.ts` list query (`archived = 0`) -> `GET /notes` -> archived notes must be hidden.
- `src/app.ts` `toNote` (new `archived` field) -> `GET /notes`, `GET /notes/:id`, `POST /notes` -> response shape gains a field.
- `src/app.ts` new route -> `POST /notes/:id/archive` -> ownership check, 204 response, state change.

### Results
| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Other user archives (acceptance 3) | bob `POST /notes/1/archive` | 404 | 404 `{"error":"not found"}` | passed |
| 2 | Note stays in owner's list (acceptance 3) | alice `GET /notes` after #1 | notes 1 and 2 listed | both listed, `archived:false` | passed |
| 3 | No login | `POST /notes/1/archive`, no token | 401 | 401 | passed |
| 4 | Unknown id (acceptance 4) | alice `POST /notes/9999/archive` | 404 | 404 | passed |
| 5 | Owner archives (acceptance 1) | alice `POST /notes/1/archive` | 204 | 204, empty body | passed |
| 6 | Archived note leaves the list (acceptance 2) | alice `GET /notes` | only note 2 | only note 2 | passed |
| 7 | Saved state | alice `GET /notes/1` | `archived:true` | 200, `archived:true` | passed |
| 8 | Archive twice | alice `POST /notes/1/archive` again | idempotent 204 | 204 | passed |

I also checked two things that aren't acceptance points, and both matched what I expected. `GET /notes/2/archive` returned 404, so the route only answers POST. Bob's list was empty and unaffected.

### Failures
None.

### Purpose
Met. All four acceptance points are proven by the real requests above:
1. Owner archive: #5 returned 204.
2. Hidden from the list: #6 omitted note 1.
3. Other user: #1 returned 404 and #2 showed the note still listed.
4. Unknown id: #4 returned 404.

### Also seen (not counted)
- `bun test`: 7 pass, 0 fail. Those are unit tests, not proof of behavior.
- Existing databases need a migration. A `data/notes.db` created before this branch has no `archived` column, so every notes query will return 500 until the column is added or the file is recreated. I tested only a fresh DB.
- Archived notes can still be fetched by id (#7). The task doesn't say whether that is intended.