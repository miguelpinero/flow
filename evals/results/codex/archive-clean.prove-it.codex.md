18 passed, 0 failed, 0 not-run, 0 could-not-run

## Prove it: `change/archive-clean`

Compared with `main`; tested commit `36560b0` through real HTTP requests using both demo users authenticated through `POST /login`. Started separate servers on free ports for fresh and legacy-schema databases.

### Impact

- `src/app.ts` → `POST /notes/:id/archive` → ownership checks and persisted archive state.
- `src/app.ts` → `GET /notes` → archived-note filtering.
- `src/app.ts` → `POST /notes`, `GET /notes/:id` → serialized `archived` field.
- `src/db.ts` → note endpoints → fresh schema and migration of existing notes.
- `README.md`, `test/archive.test.ts` → documentation and coverage; no runtime paths.

### Results

“Both” means two independently executed cases, one per database. Archive target IDs were `1` on fresh and `2` on legacy.

| # | Case | Database | Request | Expected | Actual | Result |
|---|---|---|---|---|---|---|
| 1–2 | AP1: Owner archives | Both | `POST /notes/:id/archive` | 204; persisted archive | 204, empty body; SQLite `archived=1` | passed |
| 3–4 | AP2: Archived note leaves list | Both | `GET /notes` | Target omitted; active notes retained | 200; fresh IDs `[2]`, legacy IDs `[1,3]` | passed |
| 5–6 | AP3: Another user cannot archive | Both | Archive as second user, then owner’s list | 404; target remains active | `404 {"error":"not found"}`; owner list retained target; SQLite `archived=0` | passed |
| 7–8 | AP4: Unknown ID | Both | `POST /notes/999999/archive` | 404 | `404 {"error":"not found"}` | passed |
| 9–10 | Create with optional body omitted | Both | `POST /notes` | 201; unarchived; empty body field | 201; `archived:false`, `body:""`; SQLite `archived=0` | passed |
| 11–12 | Archived note detail | Both | `GET /notes/:id` | 200; archived state and content preserved | 200; `archived:true`, original title | passed |
| 13–14 | Repeated archive | Both | `POST /notes/:id/archive` twice | 204; remains archived | 204, empty body; SQLite `archived=1` | passed |
| 15–16 | Invalid ID | Both | `POST /notes/not-a-number/archive` | 404 | `404 {"error":"not found"}` | passed |
| 17 | Empty list | Fresh | `GET /notes` before creation | 200; empty items | `200 {"items":[]}` | passed |
| 18 | Migration preserves existing note | Legacy | Start server, then `GET /notes` | Existing note available and unarchived | 200; “Legacy kept” returned with `archived:false`; SQLite `archived=0` | passed |

### Failures

None.

### Purpose

Met. All four acceptance points passed against both database setups, without modifying the implementation.

### Also seen (not counted)

- Unauthenticated archive requests returned `401 {"error":"unauthorized"}` in both setups; notes remained unarchived. These requests stopped before the changed handler.
- Unit tests were not run; this report covers real HTTP behavior.
- Both servers were stopped. Temporary databases, including seeded users, sessions, and notes, were removed.
- Seeded notes: fresh IDs `1–2`; legacy IDs `1–3`. Each database contained two demo users and two login sessions.
- Working tree remained clean; HEAD remained `36560b0`.
- Reproduction script: [prove.py](/tmp/notes-proof-run/prove.py).