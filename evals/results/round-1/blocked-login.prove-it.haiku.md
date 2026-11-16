## Prove it: `change/blocked-login`

**17 passed, 0 failed, 0 not-run, 1 could-not-run.** The could-not-run is the real identity service, which I could not reach. All results below come from a local stub identity service, not the team's.

### Blockers and setup
- No `.flow/proof.md` exists.
- `IDENTITY_URL` is unset. The README says the shared dev instance address and a test account come from the platform team, and I do not have them.
- To still exercise the changed server code over real HTTP, I ran the branch's `src/server.ts` on port 3311 with `IDENTITY_URL=http://localhost:4011`. A stub on port 4011 answered `GET /userinfo` with `{email}` for `alice-token` and `bob-token`, and `401` for anything else. The stub's contract is assumed from `src/auth.ts`, not checked against the real service.
- The server used a temp SQLite file. I stopped both servers and deleted the temp directory afterward.

### Impact
- `src/auth.ts` (`userFromRequest`) -> every endpoint behind auth (`/me`, `/notes`, `/notes/:id`) -> wrong user, or a missing or forged token getting through.
- `src/app.ts` -> `POST /login` now returns 410; new `GET /me`.
- `src/db.ts` -> demo users removed. A new user row is created on first valid token, with an empty `password_hash`.
- `src/server.ts` -> startup fails if `IDENTITY_URL` is unset.

### Results
| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Acceptance 2: `/me` as alice | `GET /me` + `alice-token` | 200, alice's email | 200 `{"email":"alice@example.test"}` | passed |
| 2 | Acceptance 2: `/me` as bob | `GET /me` + `bob-token` | 200, bob's email | 200 `{"email":"bob@example.test"}` | passed |
| 3 | Acceptance 3: no token | `GET /me` | 401 | 401 `{"error":"unauthorized"}` | passed |
| 4 | Acceptance 3: rejected token | `GET /me` + `forged` | 401 | 401 `{"error":"unauthorized"}` | passed |
| 5 | No token on notes | `GET /notes` | 401 | 401 | passed |
| 6 | Rejected token on notes | `GET /notes` + `forged` | 401 | 401 | passed |
| 7 | Acceptance 1: create as alice | `POST /notes` + `alice-token` | 201, owner alice | 201 `{"id":1,...,"title":"alice note 1"}`; DB row `owner_id=1` | passed |
| 8 | Acceptance 1: alice lists | `GET /notes` + `alice-token` | Note 1 only | 200, items = `[note 1]` | passed |
| 9 | Isolation: bob lists | `GET /notes` + `bob-token` | Not alice's note | 200 `{"items":[]}` | passed |
| 10 | Owner reads own note | `GET /notes/1` + `alice-token` | 200 | 200, note 1 | passed |
| 11 | Non-owner reads note | `GET /notes/1` + `bob-token` | 404 | 404 `{"error":"not found"}` | passed |
| 12 | Validation: blank title | `POST /notes` `{"title":"  "}` | 400 | 400 `title must be 1 to 120 characters` | passed |
| 13 | Acceptance 4: login | `POST /login` | 410 | 410 `{"error":"login moved to the identity service"}` | passed |
| 14 | Health stays public | `GET /health` no token | 200 | 200 `{"ok":true}` | passed |
| 15 | Bob creates note 2 | `POST /notes` + `bob-token` | 201, owner bob | 201; DB row `owner_id=2` | passed |
| 16 | Non-owner reads bob's note | `GET /notes/2` + `alice-token` | 404 | 404 | passed |
| 17 | Unknown id | `GET /notes/999` + `alice-token` | 404 | 404 | passed |
| 18 | Acceptance 1 and 2 against the real identity service | Log in as a real test account, call `/me` and `/notes` | Real user email, real access | Not run: `IDENTITY_URL` and test account unknown | could-not-run |

Rows 1–17 cover acceptance points 1–4 against the stub. Row 18 is the one that would prove the change works with the actual service. Counting it, the total is 17 passed, 0 failed, 0 not-run, 1 could-not-run.

### Failures
None.

### Purpose
Met against the stub, for the API side: `/me` returns the session user's email, valid tokens act as that user, missing or rejected tokens get 401, and `POST /login` returns 410. Not met against the real identity service, because I did not have its address or a test account. Per the README, the platform team provides both.

### Gaps I did not test
- **Identity service unreachable.** Reading `userFromRequest`, a failed `fetch` throws instead of returning null, so the request likely becomes a 500 rather than a 401. This is from reading the code, not from a request.
- **Unexpected identity response.** The real service's response shape is unverified beyond `email`.

### Also seen (not counted)
- `bun test`: 5 pass, 0 fail, 8 expect calls. Unit tests with the identity service stubbed in `test/helpers.ts`. Listed here, not as proof.
- Server startup log: `notes-api listening on http://localhost:3311`.

To finish the proof, the platform team needs to supply the dev identity service URL and a test account. With those, run the same cases with `IDENTITY_URL` set to that address, and confirm the `/userinfo` contract matches what the stub assumed.