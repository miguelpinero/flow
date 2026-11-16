## Can it fail: change/weak-test
2 passed, 1 failed, 0 not-run, 0 could-not-run

Command for one test: `bun test test/rename.test.ts -t "<test name>"`. Baseline before any break: 3 of 3 rename tests passed.

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| renames a note | The owner's PATCH returns 200 and the title is saved | Removed the title write from the UPDATE in `src/app.ts` | Red: `Expected "New", Received "Old"` on the saved-title assertion | `passed` |
| rejects an empty title | An empty title returns 400 and the title does not change | Removed the `title.length === 0` check | Still green: 1 pass, 0 fail. Only asserts `status !== 500` | `failed` |
| does not rename another user's note | Another user gets 404 and the note is unchanged | Removed the `row.owner_id !== user.id` check | Red: `Expected 404, Received 200` | `passed` |

### Weak tests
- **rejects an empty title**: I removed the empty-title check. The test still passed because it asserts only `expect(res).toBeDefined()` and `expect(res.status).not.toBe(500)`. Without the check the request returns 200 and writes an empty title, and neither assertion sees it. It needs `expect(res.status).toBe(400)`, and a re-read of the note asserting the title is still `"Keep"`.
- **Length limit (over 120 characters) has no test.** Acceptance point 2 requires a 400 for a title longer than 120 characters, and no test in the diff sends one. I did not break this check, because no test claims the behavior, so there is nothing to run. It needs a test that sends 121 characters, asserts 400, and asserts the title is unchanged.

### Acceptance points
| Acceptance point | Proof | Result |
|---|---|---|
| 1. Owner renames and gets 200 with the new title | "renames a note" passes on the baseline and goes red when the write is removed | `passed` |
| 2. Empty or over-120 title returns 400, title unchanged | Empty title: test is green with the check removed, so it is weak. Over-120: no test | `failed` |
| 3. Another user gets 404 | "does not rename another user's note" goes red when the owner check is removed | `passed` |

I did not start the dev server. Every check above ran through `bun test`, not HTTP.

Working tree restored: yes, checked against the saved patch. The patch was empty at the start and after each of the three restores (`cmp` matched every time). `git status --short` is empty, and the full suite is 7 of 7 green after the last restore. Nothing was committed.