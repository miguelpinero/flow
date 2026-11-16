## Prove it: change/archive-cross-user (base main)
3 passed, 1 failed, 0 not-run, 0 could-not-run

### Impact
- `src/app.ts` archive route -> `POST /notes/:id/archive` -> the owner check is missing, so any logged-in user can archive any note.
- `src/app.ts` list query -> `GET /notes` -> it must hide archived notes.
- `src/db.ts` migration -> server start-up on an existing database. A unit test covers this and I did not run it over HTTP. It is not counted.

### Results
Server: started by me on port 3977 with a temp DB, then stopped. Logged in as the demo users alice and bob. Tokens are `<redacted>`. Alice created notes 1 and 2.

| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Owner archives | alice `POST /notes/1/archive` | 204 | 204 | `passed` |
| 2 | Archived note leaves the list | alice `GET /notes` after #1 | note 1 absent | `{"items":[]}` (note 2 was already archived by bob in #3, so the list was empty) | `passed` |
| 3 | Other user cannot archive | bob `POST /notes/2/archive` (alice's note) | 404, note stays in alice's list | **204**. Note 2 vanished from alice's list. | `failed` |
| 4 | Unknown id | alice `POST /notes/999/archive` | 404 | 404 `{"error":"not found"}` | `passed` |

Before #1, alice's list held only note 1. This shows bob's request archived note 2.

Extra case, no login: `POST /notes/2/archive` returned 401. This is the auth check and is not counted.

### Failures
- Case 3, other user: expected 404 and an unchanged list, got 204 and note 2 archived. Likely cause: the handler at `src/app.ts:73-79` loads the note by id only. It never compares `row.owner_id` with `user.id`. Next step, not applied here: look the note up with `WHERE id = ? AND owner_id = ?`, as `GET /notes/:id` does, so a note you don't own returns 404. Add a cross-user test, because `test/archive.test.ts` has none.

### Purpose
Not met. Acceptance points 1, 2 and 4 work. Point 3 fails: any user can archive another user's note.

### Acceptance points
| Point | Proof | Result |
|---|---|---|
| 1. Owner gets 204 | case 1 | `passed` |
| 2. Archived note is not in `GET /notes` | case 2 | `passed` |
| 3. Other user gets 404, note stays listed | case 3: got 204 and the note disappeared | `failed` |
| 4. Unknown id gets 404 | case 4 | `passed` |

### Also seen (not counted)
- The temp DB and server log (`/tmp/proof-server.log`) were left or removed as noted. The DB was deleted and the server stopped. The log file remains in `/tmp`.
- No source file was changed.