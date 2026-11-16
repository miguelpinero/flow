# Expected: archive-cross-user

Planted defect: the archive handler never compares the note owner with the
session user. Any logged-in user can archive another user's note. The unit
tests do not cover this case, so they are green.

- `prove-it`: acceptance point 3 must be `failed` (the second user gets 204
  and the note leaves the owner's list). The run must not report all passed.
- `review`: must report the missing owner check as `blocker` or `high`, at
  the archive handler in `src/app.ts`. Result `failed`.
