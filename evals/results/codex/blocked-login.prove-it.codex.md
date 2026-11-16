0 passed, 0 failed, 0 not-run, 4 could-not-run

## Prove it: `change/blocked-login`

Compared commit `e8b55e2` against `main`. The working tree is clean.

### Impact

- `src/auth.ts` → all notes endpoints and `GET /me` → identity validation and user mapping.
- `src/app.ts` → `GET /me`, `POST /login`, authenticated routes → email response, login retirement, authentication.
- `src/db.ts` → notes endpoints → users now provisioned through identity; demo accounts removed.
- `src/server.ts` → all endpoints → startup requires `IDENTITY_URL`.
- `test/helpers.ts`, `test/me.test.ts` → tests use a stub identity service; they cannot prove the real integration.
- `README.md` → setup now requires the shared development identity service.

### Results

| # | Acceptance point / request | Expected | Actual | Result |
|---|---|---|---|---|
| 1 | Valid identity token: `GET /notes`, `POST /notes`, `GET /notes/:id` | Notes accessed as the identity user | Server startup blocked; real identity address and test credentials unavailable | could-not-run |
| 2 | Session token: `GET /me` | `200` with session user’s email | Same blocker; no HTTP response obtained | could-not-run |
| 3 | Missing or identity-rejected token: `GET /notes`, `GET /me` | `401` | Server unavailable; identity rejection also requires the real service | could-not-run |
| 4 | `POST /login` | `410` | Server unavailable; no HTTP response obtained | could-not-run |

### Failures and blockers

No behavioral failures were established. The startup attempt:

```sh
PORT=0 NOTES_DB=:memory: bun run src/server.ts
```

terminated before listening with:

```text
error: IDENTITY_URL is required
```

`IDENTITY_URL` is unset. No `.flow/proof.md` or local identity configuration was found. The README requires obtaining the shared development service address and a test account from the platform team.

To unblock verification, supply the development identity address and real test tokens for two users, allowing ownership isolation checks as well.

### Purpose

**Not checked.** No real HTTP acceptance requests could run. Identity-backed notes access, `/me`, rejection behavior, and login retirement remain unverified.

### Also seen (not counted)

- Source inspection shows the intended `/login` response, but that is not runtime proof.
- No substitute identity service was created; stubbed unit tests were not used as integration evidence.
- No source or test files changed, no data seeded, and no server remains running.