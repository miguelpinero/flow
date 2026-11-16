# notes-api

A small API used to demonstrate and test the flow skills. Bun, TypeScript,
SQLite, no dependencies.

```
bun run dev      # http://localhost:3210, or set PORT
bun test
```

## Log in

Two demo users exist after the first start. They are public test accounts.

| Email | Password |
|---|---|
| alice@example.test | alice-demo-password |
| bob@example.test | bob-demo-password |

```
curl -s -X POST localhost:3210/login \
  -H 'content-type: application/json' \
  -d '{"email":"alice@example.test","password":"alice-demo-password"}'
```

Send the token as `Authorization: Bearer <token>`.

## Endpoints

| Request | Does |
|---|---|
| `GET /health` | Health check, no login |
| `POST /login` | Returns a session token |
| `GET /notes` | Lists your notes |
| `POST /notes` | Creates a note: `title` (1 to 120 characters), `body` (optional) |
| `GET /notes/:id` | Returns one of your notes |

The database file is `data/notes.db`. Set `NOTES_DB` to use another path.
