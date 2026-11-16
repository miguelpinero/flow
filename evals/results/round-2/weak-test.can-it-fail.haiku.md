## Can it fail: change/weak-test
2 passed, 1 failed, 0 not-run, 0 could-not-run

Scope: the three tests in `test/rename.test.ts`, against the `PATCH /notes/:id` block in `src/app.ts`. I ran them with `bun test` in-process, so no dev server was started and none needed stopping.

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| renames a note | Owner gets 200 and the title is saved | Removed the UPDATE and returned the old row | Red on `saved.title`: Expected "New", Received "Old" | `passed` |
| rejects an empty title | Empty title gets 400 and the title does not change | Removed the length check (`if (false)`) | Stayed green: 3 pass, 0 fail | `failed` |
| does not rename another user's note | Other user gets 404 and the title does not change | Removed the ownership check | Red on the status: Expected 404, Received 200 | `passed` |

One break attempt was wrong: my first edit only changed the returned value and left the UPDATE running. That run proved nothing, so I redid break 1 properly. The result above is from the corrected break.

### Weak tests
- **rejects an empty title**: I removed the empty/too-long title check, so an empty title is saved. The test still passed because it only asserts `res.status` is not 500 and that `res` is defined. It never checks for 400, and it never checks that the title is unchanged. It needs an assertion on `res.status` being 400 and on the saved title still being "Keep".

### Also seen
- **No test for the 120-character limit.** Acceptance point 2 says a title longer than 120 characters returns 400 and does not change. No test covers that case, so the `> 120` half of the check is unproven. A test should send a 121-character title and assert 400 with the title unchanged.
- The 400 path has no check that the title is unchanged, even after the empty-title test is fixed. That is part of the same gap.

Working tree restored: yes, checked against the saved patch after each break. The saved patch was empty, since the change is committed, and `git status --short` is clean. I made no commits and no fixes.