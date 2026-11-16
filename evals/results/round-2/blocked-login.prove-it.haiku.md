## Prove it: change/blocked-login (move login to the identity service, add `GET /me`)
3 passed, 0 failed, 0 not-run, 3 could-not-run

The three checks that ran are the ones that don't need a real identity token. The two acceptance points that need a valid token (1 and 2) could not be run, because no identity service address or test account is available here. `IDENTITY_URL` is unset, the repo has no `.flow/proof.md`, and the README says to ask the platform team for the shared dev instance.

### Impact
- `src/auth.ts` `userFromRequest` -> every authenticated route (`/me`, `/notes*`) -> now returns `null` (401) or a user looked up by email from `IDENTITY_URL/userinfo`.
- `src/app.ts` `/login` -> now returns 410 before any auth.
- `src/server.ts` -> startup calls `identityUrl()`, so the server refuses to boot without `IDENTITY_URL`.
- `src/db.ts` -> demo users removed. Local password login is gone.

### Results
| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Login is retired | `POST /login` with an email and password | 410 | 410, body `{"error":"login moved to the identity service"}` | passed |
| 2 | `/me` with no token | `GET /me` | 401 | 401, body `{"error":"unauthorized"}` | passed |
| 3 | Notes with no token | `GET /notes` | 401 | 401, body `{"error":"unauthorized"}` | passed |
| 4 | `/me` with a valid token | `GET /me` with identity-issued bearer | 200, `{"email": <session user>}` | not run: no identity service or test token | could-not-run |
| 5 | Notes as the token's user | `GET /notes` with identity-issued bearer | notes of that user | not run: same blocker | could-not-run |
| 6 | Token the identity service rejects | `GET /notes` with a token the real service rejects | 401 | not run: no real identity service. Code path returns 401 on a non-OK `/userinfo`, but that was not observed | could-not-run |

Cases 1–3 ran against a real server on port 3322 started from this branch, with `IDENTITY_URL=http://127.0.0.1:9` (unreachable). The server was stopped afterwards. Case 3 reached `userFromRequest`, so it exercised the changed code, not only a header check.

### Failures
None.

### Concerns found (not counted as failures)
- **Identity service unreachable returns 500, not 401.** With a bearer token and an unreachable `IDENTITY_URL`, `GET /notes` and `GET /me` both return HTML `500 Internal Server Error` (a TypeError from `fetch`). The acceptance text covers a token the service rejects, which is a 401. An outage is a different case, but a client will see a 500 with an HTML body. Consider catching the fetch error and returning 503 or 401 with JSON.
- The `/userinfo` fetch has no timeout, so a hung identity service hangs every authenticated request.

### Purpose
Partly met, partly unchecked. Points 3 (no-token part) and 4 (`/login` returns 410) are checked against the real server. Points 1 and 2 are not checked against a real identity token. Point 3's rejected-token part is not checked against the real service.

### Also seen (not counted)
- `bun test`: 5 pass, 0 fail. These use a stubbed `fetch` that replaces the identity service, so they are mocks and are not counted as proof of points 1 and 2.
- Server started without `IDENTITY_URL` exits at boot with an error from `identityUrl()`, as designed.
- Another process (bun, pid 89712) is listening on port 3311. I did not touch it.
- No code was changed during this run. The repo is clean. Temporary probe directories were removed.

To close the three `could-not-run` rows, run the server with `IDENTITY_URL` set to the shared dev identity service and a test account's token. Then repeat cases 4–6 and check the `/me` email.