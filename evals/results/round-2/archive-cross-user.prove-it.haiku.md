## Prove it: `change/archive-cross-user`

8 passed, 2 failed, 0 not-run, 0 could-not-run

The branch as found does not meet acceptance point 3. Another user can archive the owner's note, and the owner loses it from her list.

### Impact
- `src/app.ts` archive branch -> `POST /notes/:id/archive` -> no owner check, so any logged-in user can archive any note, and an unknown id is the only 404 path
- `src/app.ts` list filter -> `GET /notes` -> archived notes are hidden, and a cross-user archive hides someone else's note
- `src/app.ts` `toNote` -> `GET /notes`, `GET /notes/:id` -> new `archived` field in responses
- `src/db.ts` new column and `ALTER TABLE` migration -> every notes read and write, and startup on an existing database

### Results
Server: `PORT=3311`, temp DB outside the repo, started from the clean branch HEAD. Logged in as alice (owner) and bob (second user). Tokens not printed.

| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Owner archives own note (AP1) | alice `POST /notes/1/archive` | 204 | 204 | passed |
| 2 | Archived note leaves owner's list (AP2) | alice `GET /notes` | note 1 absent | only note 2 listed | passed |
| 3 | Second user cannot archive (AP3) | bob `POST /notes/2/archive` (alice's note) | 404 | **204**, note 2 archived in DB | failed |
| 4 | Note stays in owner's list after other user's attempt (AP3) | alice `GET /notes` | note 2 present | `{"items":[]}`, note 2 gone | failed |
| 5 | Unknown id (AP4) | alice `POST /notes/99999/archive` | 404 | 404 `{"error":"not found"}` | passed |
| 6 | No login | `POST /notes/2/archive`, no token | 401 | 401 | passed |
| 7 | Re-archive an archived note (edge) | alice `POST /notes/1/archive` | 204 | 204 | passed |
| 8 | Non-numeric id (edge) | alice `POST /notes/abc/archive` | 404 | 404 | passed |
| 9 | Migration on pre-archive schema (not HTTP) | `openDb()` on a DB with the old `notes` table, which has a row | `archived` column added, old row kept with `archived=0` | column added, row present with `archived: 0` | passed |

Cases 4 and 5 map to the two states of AP3: the other user's archive returns 204 when it should be 404, and the owner's list loses note 2 as a result.

### Failures
- Case 3: expected 404 for bob archiving alice's note 2, got 204 and note 2 archived in the DB. Likely cause: `src/app.ts` archive branch runs `SELECT * FROM notes WHERE id = ?` and never checks `row.owner_id !== user.id`. The `GET /notes/:id` branch right above it does that check, and the archive branch does not. Next step: add the same owner check to the archive branch, returning 404 when it fails, then rerun cases 3 and 4. I did not edit the code.
- Case 4: expected note 2 in alice's list, got it missing. Same cause as case 3.

### Purpose
Met for points 1, 2 and 4. Not met for point 3. Points 1, 2 and 4 were checked over HTTP as the owner. Point 3 was checked as a second user.

### Also seen (not counted)
- Owner `GET /notes/1` on an archived note returns 200 with `archived: true`. The task does not say whether archived notes should stay readable by id, so I did not count it.
- Bob's `GET /notes` returned an empty list. He had no notes, so this shows little.
- Did not run `bun test`. Did not read `test/archive.test.ts`, so I cannot say whether it covers the cross-user case.
- Did not read `server.log` for errors. The server printed only its startup line.
- Server stopped. Repo is clean (no changes made).
- Temp data kept for you to delete: `/var/folders/r3/cskc2t_94g114n9m4g9x93k80000gn/T/tmp.Zl5RoRRlCO` (notes.db with alice's notes 1 and 2 and bob's test rows, server.log) and `/var/folders/r3/cskc2t_94g114n9m4g9x93k80000gn/T/tmp.ocrsUzAVKm` (old-schema test DB).