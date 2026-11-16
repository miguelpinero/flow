## Prove it: change/archive-clean
8 passed, 0 failed, 0 not-run, 0 could-not-run

I ran the real dev server (`bun run src/server.ts`) on ports 38417 and 38418, each with a temporary database. I logged in over HTTP as the demo users alice and bob. Both servers are stopped and the temporary databases are deleted. No source file was changed.

### Impact
- `src/app.ts` (new route) -> `POST /notes/:id/archive` -> ownership check, 204/404 behaviour, and the saved `archived` flag.
- `src/app.ts` (list filter) -> `GET /notes` -> archived notes must disappear from the list.
- `src/app.ts` (`toNote`) -> `GET /notes`, `GET /notes/:id`, `POST /notes` -> responses now include an `archived` boolean.
- `src/db.ts` (new column and `ALTER TABLE`) -> every endpoint on server start -> a database created before this change must still work.

### Results
| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Owner archives a note (acceptance 1) | alice `POST /notes/1/archive` | 204 | 204, empty body | `passed` |
| 2 | Archived note leaves the list (acceptance 2) | alice `GET /notes` before and after | Notes 1 and 2, then only note 2 | Before: ids 1 and 2. After: only id 2 | `passed` |
| 3 | Another user cannot archive it (acceptance 3) | bob `POST /notes/1/archive`, then alice `GET /notes` | 404, and the note stays in alice's list | 404 `{"error":"not found"}`. Alice's list still had notes 1 and 2 | `passed` |
| 4 | Unknown id (acceptance 4) | alice `POST /notes/99999/archive` | 404 | 404 `{"error":"not found"}` | `passed` |
| 5 | No login | `POST /notes/2/archive` with no token | 401 | 401 | `passed` |
| 6 | Saved state | alice `GET /notes/1` after archiving | `archived: true` | `"archived":true` | `passed` |
| 7 | Archive twice | alice `POST /notes/1/archive` again | 204 | 204 | `passed` |
| 8 | Database from before this change | Server started on a database whose `notes` table has no `archived` column. Then `GET /notes`, `POST /notes/1/archive`, `GET /notes`. | The column is added, the note is listed, then archived and hidden | The legacy note was listed with `archived:false`. Archive returned 204. The list was then empty | `passed` |

### Failures
None.

### Purpose
Met. All four acceptance points have a request and response above, and each was checked against the response body or the later list.

| Acceptance point | Proof | Result |
|---|---|---|
| Owner archives a note and gets 204 | Case 1 | `passed` |
| Archived note no longer appears in `GET /notes` | Case 2 | `passed` |
| Another user gets 404 and the note stays in the owner's list | Case 3 | `passed` |
| Unknown id returns 404 | Case 4 | `passed` |

### Also seen (not counted)
- My first attempt at case 8 failed because of a quoting error in my seed script. The server then created a fresh empty database, so that run proved nothing and I discarded it. The second attempt, using a script file in a temp directory, is the one reported.
- After archiving, `GET /notes/:id` still returns the note to its owner with `archived:true`. Bob gets 404 for it. The task does not say what this should do, so I did not count it.
- I did not run `bun test`. The branch's tests would not count as proof here.
- No `.flow/proof.md` existed. I used the README login recipe and the demo accounts.