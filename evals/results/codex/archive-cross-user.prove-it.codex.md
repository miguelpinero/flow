11 passed, 1 failed, 0 not-run, 0 could-not-run

## Prove it: `change/archive-cross-user`

Tested commit `885e7e8` against `main`, using real HTTP requests and two users authenticated through `/login`. No source or tests were changed.

### Impact

- `src/app.ts` → archive, list, create, and read endpoints → ownership enforcement, list filtering, and `archived` response field.
- `src/db.ts` → all note endpoints → archive defaults and migration of existing databases.
- `README.md`, `test/archive.test.ts` → documentation and test coverage; no runtime paths.

### Results

Alice owns the fresh-database notes below. Bob is the second user.

| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Empty list | Alice `GET /notes` | `200`, empty items | `200 {"items":[]}` | passed |
| 2 | Create owner test note | Alice `POST /notes` | `201`, archive default false | ID 1, `archived:false`, empty body | passed |
| 3 | Create cross-user test note | Alice `POST /notes` | `201`, archive default false | ID 2, `archived:false`, empty body | passed |
| 4 | Create unauthenticated test note | Alice `POST /notes` | `201`, archive default false | ID 3, `archived:false`, empty body | passed |
| 5 | **AP1: Owner archives** | Alice `POST /notes/1/archive`; `GET /notes/1` | Empty `204`; saved archive state | Empty `204`; read returned `200`, `archived:true` | passed |
| 6 | **AP2: Archived note excluded** | Alice `GET /notes` | `200`, excludes ID 1 | `200`, IDs `[2,3]` | passed |
| 7 | **AP3: Another user denied** | Bob `POST /notes/2/archive`; Alice list and detail reads | `404`; ID 2 remains listed and unarchived | **`204`; list contained only ID 3; ID 2 had `archived:true`** | **failed** |
| 8 | **AP4: Unknown ID** | Alice `POST /notes/999999/archive` | `404` | `404 {"error":"not found"}` | passed |
| 9 | No login | Unauthenticated `POST /notes/3/archive`; Alice list and detail reads | `401`; note unchanged | `401`; ID 3 remained listed, `archived:false` | passed |
| 10 | Cross-user archived-note read | Bob `GET /notes/1` | `404` | `404 {"error":"not found"}` | passed |
| 11 | Malformed ID | Alice `POST /notes/not-a-number/archive` | `404` | `404 {"error":"not found"}` | passed |
| 12 | Existing database migration | Start with old notes schema; Alice list, archive, list, detail requests | Existing note preserved; archive works | Initially `archived:false`; archive `204`; list empty; detail `archived:true` | passed |

### Failures

**Acceptance point 3 fails:** Bob can archive Alice’s note.

The archive handler in `src/app.ts:75–77` selects and updates by note ID without checking `owner_id`. Next step: enforce ownership before updating and add a regression check that verifies both the `404` and the unchanged owner’s list. No fix was applied during this assessment.

### Purpose

**Not met.** Three of four acceptance points passed, but the endpoint permits cross-user modification.

### Also seen (not counted)

- Fresh servers ran this branch on ports `65260` and `65279`.
- Both servers were stopped.
- Isolated databases were deleted, including demo users, sessions, fresh notes 1–3, and legacy note 1.
- The working tree remains clean.