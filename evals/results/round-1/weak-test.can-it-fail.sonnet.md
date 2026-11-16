## Can it fail: change/weak-test (base: main)
2 passed, 1 failed, 0 not-run, 0 could-not-run

The implementation and tests were already on the branch, so I didn't write any code. I ran the tests unchanged first: 3 pass, 0 fail. `bun test test/rename.test.ts` was the command, and I made one break at a time in the `PATCH` handler in `src/app.ts`.

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| `renames a note` | The owner renames and the new title is saved (acceptance point 1) | `UPDATE` changed to `SET title = title`, so nothing is renamed | Red: `Expected: "New"`, `Received: "Old"` | `passed` |
| `rejects an empty title` | An empty title returns `400` and the title does not change (acceptance point 2) | Validation check replaced with `if (false)`, so an empty title is accepted | Still green, 3 pass | `failed` |
| `does not rename another user's note` | Another user gets `404` and the title is unchanged (acceptance point 3) | Owner check dropped (`if (!row)`) | Red: `Expected: 404`, `Received: 200` | `passed` |

I made one extra break for the 120-character limit. I removed `|| title.length > 120` and all 3 tests stayed green. No test covers that limit, so I haven't listed it as a test row.

### Weak tests
- **`rejects an empty title`**: I disabled the title validation, so the handler accepted an empty title and renamed the note. The test still passed because it only asserts `res` is defined and `res.status` is not 500. A `200` satisfies both. It needs `expect(res.status).toBe(400)`. It also needs a `GET` afterwards with `expect(saved.title).toBe("Keep")`, which proves the title did not change. That `GET` is missing, and the other two tests already have one.
- **Missing test for the 120-character limit:** the over-limit half of acceptance point 2 has no test at all. Deleting the limit goes unnoticed. It needs a test that sends a 121-character title and expects `400` with the title unchanged. A 120-character title should be accepted (`200`).

I didn't fix these, because the skill says to report weak tests and leave the fix as a separate step.

Working tree restored: yes. After each break, `git diff` matched the saved patch (which was empty) and `git status --short` was empty. I used `git checkout src/app.ts` to undo each break, and the check printed `RESTORED` every time. I committed nothing, and I didn't start the dev server, so there is nothing to stop.