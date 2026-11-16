Those PIDs are gone now. They were probably the `pgrep` matching shells, not servers, and nothing is left running.

## Prove it: change/blocked-login (base main)
2 passed, 0 failed, 0 not-run, 5 could-not-run

### Impact
- `src/auth.ts` (`userFromRequest` now calls `IDENTITY_URL/userinfo`) -> every route except `/health` and `/login` -> a valid token fails to reach the notes endpoints, a rejected token doesn't get 401, or an identity-service error becomes a 500.
- `src/app.ts` -> `POST /login` -> must return 410.
- `src/app.ts` -> `GET /me` (new) -> must return the session user's email.
- `src/db.ts` -> startup user seeding removed -> users now appear only when `userFromRequest` creates them.
- `src/server.ts` -> startup now fails when `IDENTITY_URL` is unset.

### Results
| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | Login is gone (point 4) | `POST /login` | 410 | 410 `{"error":"login moved to the identity service"}` | passed |
| 2 | No token (point 3, no-token half) | `GET /me`, `GET /notes` without a token | 401 | 401 `{"error":"unauthorized"}` on both | passed |
| 3 | Valid token reaches notes (point 1) | `GET /notes` with a real identity token | 200, as that user | no real token | could-not-run |
| 4 | `/me` returns the email (point 2) | `GET /me` with a real identity token | 200 `{email}` | no real token | could-not-run |
| 5 | Rejected token gets 401 (point 3, rejected half) | `GET /me` with a token the service rejects | 401 | the real service was not reachable | could-not-run |
| 6 | Notes scoped per user | create a note as user A, `GET /notes/:id` as user B | 404 | needs two real users | could-not-run |
| 7 | Note validation | `POST /notes` with a bad title | 400 | needs a real token | could-not-run |

### Failures
None among the cases that ran. One thing seen while setting up:
- A request with a Bearer token while the identity service is unreachable returned a 500 with an HTML error page. The cause is that `fetch` in `src/auth.ts:15` throws and nothing catches it. This is a robustness gap, not one of the four acceptance points. The 500 does not let anyone in, but it is probably better as a 401 or 503.

### Purpose
Not met as proven. Points 3 (no-token half) and 4 are proven by real requests. Points 1, 2 and the rejected-token half of 3 are not proven. They need the shared dev identity service and a test account. `README.md` says to ask the platform team for both, and no `IDENTITY_URL` or credentials exist in this environment.
- I did not build a local stand-in identity service. A pass against my own stub would not show that the real service's `/userinfo` has the shape the code expects (`{email}`).
- To finish: set `IDENTITY_URL` to the dev instance, then run cases 3 to 7 with two real tokens.

### Also seen (not counted)
- `bun test`: 5 pass, 0 fail. The identity service is stubbed in these tests, so they don't count as proof.
- `GET /health` returned 200.
- I started the server on port 39518 with `IDENTITY_URL` pointing at a dead address and stopped it afterwards. The temporary DB and script files are removed. The repo is clean and I seeded no rows.