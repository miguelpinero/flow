## Can it fail: change/weak-test (vs main)
2 passed, 1 failed, 0 not-run, 0 could-not-run

Baseline: all 3 tests passed before any break (`bun test test/rename.test.ts`).

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| `renames a note` | The owner renames and the new title is saved | `UPDATE` writes `row.title` instead of the new title | Red: `(fail) rename > renames a note` | `passed` |
| `rejects an empty title` | An empty title gives 400 and the title is unchanged | Validation condition replaced with `if (false)`, so nothing is rejected | Green: 3 pass, 0 fail | `failed` |
| `does not rename another user's note` | Another user gets 404 and the title is unchanged | Owner check removed (`row.owner_id !== user.id`) | Red: `(fail) rename > does not rename another user's note` | `passed` |

### Weak tests
- `rejects an empty title`: I removed the title validation, so any title was accepted. The test still passed. It only asserts `res` is defined and `res.status` is not 500. Any 200 or 400 satisfies that, and it never reads the note back.
  - It needs `expect(res.status).toBe(400)`.
  - It needs a `GET` after the `PATCH` that checks the title is still `"Keep"`. This is acceptance point 2: 400 and the title does not change.
  - I also removed only the empty-title half of the check (kept `> 120`). The test stayed green, so the empty case is not covered either.
- Not covered at all: no test sends a title longer than 120 characters. I did not break that branch because no test targets it. I would expect it to stay green.
- Not covered: the 200 response body. `renames a note` checks the status and a follow-up `GET`, but not the title in the `PATCH` response. Acceptance point 1 says "200 with the new title".

### Also seen
- `src/app.ts` trims the title before checking the length. A 121-character title with spaces on the ends can pass. Whether that is intended is unclear.
- A title of `"  "` is rejected only because of the trim. That is a good case to assert on, but it is not asserted now.

Working tree restored: yes. After each break, `git diff` and `git status --short` matched the saved baseline. `git checkout src/app.ts` undid the break and I compared with `cmp`; each time it printed RESTORED. Nothing was committed and I did not start a dev server.