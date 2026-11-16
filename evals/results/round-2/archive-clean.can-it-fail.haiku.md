## Can it fail: change/archive-clean
4 passed, 0 failed, 0 not-run, 0 could-not-run

Command: `bun test test/archive.test.ts`. Baseline before any break: 4 of 4 green. Full suite: 8 pass, 0 fail.

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| archives a note and removes it from the list | Archived note is gone from `GET /notes` | T1a: removed `AND archived = 0` from the list query | Red: `expect(list.items).toEqual([])` got the note back | `passed` |
| archives a note and removes it from the list | Archive persists the flag and returns 204 | T1b: removed the `UPDATE notes SET archived = 1` line | Red: same list assertion, note still listed | `passed` |
| returns 404 for an unknown note | Unknown id gives 404 | T2: in the archive handler only, `!row \|\| ...` became `row && ...` | Red: `Expected 404`, got 204 | `passed` |
| adds the archived column to a database created before this change | The migration adds `archived` with default 0 and keeps old rows | T3: `ALTER ... DEFAULT 0` changed to `DEFAULT 1` | Red: `toEqual([{ title: "Kept", archived: 0 }])` failed | `passed` |
| does not let another user archive the note | Non-owner gets 404 and the note stays listed | T4: in the archive handler only, owner check reduced to `if (!row)` | Red: `Expected 404`, got 204 | `passed` |

Two of my first attempts were wrong. `perl -0pi s///` without `/g` changed the first matching line, which was in the `GET /notes/:id` handler, so the archive handler was untouched and the tests stayed green. I restored the tree, then redid T2 and T4 with the match anchored to the archive handler and checked the diff text. Only the results from the redo count.

### Weak tests
None found. Each test went red on an assertion tied to its behavior.

### Also seen
- `GET /notes/:id` still returns archived notes. The acceptance points don't cover this, so I did not change it. Check whether it is intended.
- The migration test calls `rmSync` only at the end. If an assertion fails, the temp database file is left behind. Cleanup in a `finally` would fix it.
- No test covers archiving a note that is already archived. The current code returns 204 again. Not in the acceptance points.

Working tree restored: yes, checked against the saved patch. `git diff` matches the saved empty patch, and `git status --short` is empty after the final run. Nothing was committed.