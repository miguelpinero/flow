## Can it fail: `change/weak-test`

**1 passed, 2 failed, 0 not-run, 0 could-not-run** — per-test results against `main`.

All three tests passed before mutation. Each mutation ran with:

```sh
bun test test/rename.test.ts --test-name-pattern "<test name>"
```

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| `renames a note` | Owner successfully renames a note | Preserve the old saved title; separately return the old title in the PATCH response | Detected the missing update: expected `"New"`, received `"Old"`. Still passed with an incorrect response title. | `failed` |
| `rejects an empty title` | Empty titles are rejected | Remove empty-title rejection | Still passed: `1 pass, 0 fail`. | `failed` |
| `does not rename another user's note` | Another user receives `404` and cannot rename | Remove PATCH ownership check | Assertion failed: expected `404`, received `200`. | `passed` |

### Weak tests

- **`renames a note`:** Detects a missing database update, but never reads the PATCH response body. It needs an assertion that the response contains the new title.
- **`rejects an empty title`:** Only asserts that a response exists and its status is not `500`. It needs assertions for `400` and an unchanged saved title.

### Acceptance-point evidence

These results assess test protection, not a separate live-server smoke test.

| Acceptance point | Proof | Result |
|---|---|---|
| Owner receives `200` with the new title | Returning the old response title escaped detection. | `failed` |
| Empty or over-120-character titles return `400`, leaving the title unchanged | Removing empty-title rejection escaped detection; no overlength test was added. | `failed` |
| Another user cannot rename and receives `404` | Removing ownership enforcement caused the expected assertion failure. | `passed` |

### Also seen

- No new test covers a title longer than 120 characters.
- No fixes or additional tests were made.

After restoration, `bun test test/rename.test.ts` reported **3 pass, 0 fail**. That baseline does not negate the weaknesses above.

**Working tree restored: yes**, verified after every mutation against the saved patch, Git status, and original file bytes. No server was started and nothing was committed.

[Mutation patches and execution logs](/var/folders/r3/cskc2t_94g114n9m4g9x93k80000gn/T/can-it-fail-66r8ke0z)