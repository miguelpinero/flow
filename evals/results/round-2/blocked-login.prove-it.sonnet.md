Status: the real requests are done, the server is stopped, and I'm writing the final report.

## Prove it: change/blocked-login (base: main)
2 passed, 0 failed, 0 not-run, 3 could-not-run

I could not test any case that needs a valid identity token. `IDENTITY_URL` is not set, there is no `.flow/proof.md`, and the README says there is no local identity service. Without one I can't log in as a real user. I did not build a fake identity service, because that would be a mock and not a pass.

### Impact
- `src/auth.ts` (`userFromRequest`) → every route except `/health` and `/login` → token check, user creation, and what happens when the identity service rejects or can't be reached.
- `src/app.ts` → `POST /login` (now a fixed 410) and `GET /me` (new) → the response shape and the order of the checks.
- `src/db.ts` → server start-up → the demo users are gone, so users are now created on first login.
- `src/server.ts` → start-up → the server refuses to start without `IDENTITY_URL`.

### Results
I started the server myself on port 3987 with `IDENTITY_URL=http://127.0.0.1:9` (nothing listens there) and a temporary database.

| # | Case | Request | Expected | Actual | Result |
|---|---|---|---|---|---|
| 1 | `POST /login` returns 410 | `POST /login` | 410 | 410 `{"error":"login moved to the identity service"}` | `passed` |
| 2 | No token gets 401 | `GET /me` and `GET /notes`, no header | 401 | 401 `{"error":"unauthorized"}` on both | `passed` |
| 3 | A valid token reaches the notes endpoints as that user | `GET /notes` with a valid token | 200, that user's notes | Needs a real identity service | `could-not-run` |
| 4 | `GET /me` returns the session user's email | `GET /me` with a valid token | 200 `{"email": ...}` | Needs a real identity service | `could-not-run` |
| 5 | A token the identity service rejects gets 401 | `GET /me` with a token the service rejects | 401 | Needs a real identity service that answers with a rejection | `could-not-run` |

For case 2, the request without a token runs the changed `userFromRequest` and returns before it calls the identity service. That makes it a real result for "no token", but only for that half of acceptance point 3.

### Failures
None among the cases that ran. Case 5 has a risk I could not settle (see below).

### Purpose
Not met, because it is unproven. Only `POST /login` returning 410 and the no-token 401 are shown. Points 1, 2 and the rejected-token half of point 3 are not shown.

To unblock, give me a reachable dev identity service as `IDENTITY_URL`, plus a test token for two users. I would then run cases 3 to 5 and add these:
- Check that user B can't read user A's notes.
- Check that the `users` row is created on first login.
- Check that `GET /me` returns the right email.

### Also seen (not counted)
- **Unreachable identity service gives 500, not 401.** `GET /me` with `Authorization: Bearer x` returned a 500 HTML error page while `IDENTITY_URL` pointed at a closed port. `fetch` throws in `src/auth.ts` and nothing catches it. A rejection from a live service (`!res.ok`) is handled and returns 401. An outage or timeout is not handled, so it will likely surface as a 500. A fix would wrap the `fetch` in try/catch and return 401 or 503. I did not change the code.
- **Same `fetch`, other failure modes (not run).** A non-JSON body or a 200 response without `email` is partly handled. A body that isn't valid JSON would throw.
- **Unit tests.** `test/me.test.ts` and `test/helpers.ts` stub the identity service, so they are not proof. I did not run them, so this report says nothing about their results.
- **Server stopped.** I confirmed it no longer answers. The temporary database was in a temp directory outside the repo, and I seeded no rows.