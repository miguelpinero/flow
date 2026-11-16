## Prove it: change/archive-cross-user

**7 passed, 0 failed, 0 not-run, 0 could-not-run** (final run, after one fix)

### Impact
- `src/app.ts` (archive route) -> `POST /notes/:id/archive` -> owner check, 204 on success, note removed from `GET /notes`
- `src/app.ts` (list query) -> `GET /notes` -> now filters `archived = 0`
- `src/db.ts` (schema) -> new `archived` column with default 0, so existing rows are unarchived. Every notes endpoint reads it.

### Results
Server: `bun run src/server.ts` on port 3211, database at `/tmp/prove-it-archive/notes.db`, started from this branch's code. Cases ran with `curl` as two real users, alice and bob, logged in through `POST /login`. Script: `/tmp/prove-it-archive/cases.sh`.

| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Owner archives | alice `POST /notes/1/archive` | 204, empty body | 204, 0 bytes | passed |
| 2 | Archived note leaves the list | alice `GET /notes` | id 1 absent | id 1 absent | passed |
| 3 | Other user cannot archive | bob `POST /notes/2/archive` | 404 | 404 `{"error":"not found"}` | passed |
| 3b | Note stays in owner's list | alice `GET /notes` after 3 | id 2 present | id 2 present, `archived=false` | passed |
| 4 | Reverse direction | alice `POST /notes/3/archive` (bob's note) | 404 | 404 | passed |
| 4b | Bob's list unchanged | bob `GET /notes` after 4 | id 3 present | id 3 present | passed |
| 5 | Unknown id | alice `POST /notes/999999/archive` | 404 | 404 `{"error":"not found"}` | passed |
| 6 | No login | `POST /notes/2/archive`, no token | 401 | 401 `{"error":"unauthorized"}` | passed |
| 7 | Non-numeric id | alice `POST /notes/abc/archive` | 404 | 404 `{"error":"not found"}` | passed |

### Failures
- Before the fix, case 3 returned `204` and removed bob's target note from alice's list. Cause: the archive handler looked up the note by id and never compared `owner_id` with the caller. Case 4 had the same bug. Fixed by adding `|| row.owner_id !== user.id` to the 404 check, the same check `GET /notes/:id` already uses. The fix is uncommitted in `src/app.ts`, one line.

### Purpose
Met. Acceptance points, each with proof:
1. Owner archives and gets 204: case 1, `passed`.
2. Archived note is gone from `GET /notes`: case 2, `passed`.
3. Other user gets 404 and the note stays in the owner's list: cases 3, 3b, 4, 4b, `passed` after the fix (failed before it).
4. Unknown id gets 404: case 5, `passed`.

Acceptance points came from the task, not a written spec.

### Also seen (not counted)
- `bun test`: 6 pass, 0 fail. These are unit tests against an in-memory database, so they are not proof of the HTTP behavior above. `test/archive.test.ts` does not cover the cross-user case, and I did not add a test for it.
- Repeat `POST /notes/1/archive` on an already archived note returns 204. Not specified by the task, so I did not count it.
- The owner can still read an archived note with `GET /notes/1`, which returns `archived: true`. The task does not say whether that should 404. Not counted.
- The server is stopped. The temporary database and logs are in `/tmp/prove-it-archive`, outside the repo. Nothing was committed.